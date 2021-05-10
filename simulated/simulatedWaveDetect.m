% Program to get statistics on simluated dataset
% Loads data from file calculates sstatistcs
% Then saves data into new file

% Try to load data
if exist( 'simulatedData_final/ ' , 'dir' )
    
       files = dir('simulatedData_final/*.csv');
       psource = 'simulatedData_final\';
    
else
    error('Error. no folder "simulatedData_final" found')
end

% Create new folder if doesnt exist
if ~exist( 'simDataStatistics' , 'dir' )
 
    mkdir( 'simDataStatistics' );
    pdest = 'simDataStatistics\';
    
else
    pdest = 'simDataStatistics\';
end

% For each file get data
for i=1:length(files)
   
   % Reset variables to 0
   sum = 0;
   sumArray = 0;
   sumSQRD = 0;
   sumHeight = 0;
    
   % Load source file
   sourceFile = load( fullfile( psource, files(i).name ) );
   
   % Ensure the length of the file is over the threshold
   if( length(sourceFile) >= 5000 )
       
       % Ensure only using the first portion of the ECG
       % Absolute values to deal with annomlies in dataset
       ECG = abs(sourceFile(1:5000));
       
       % Calculate the average value in the array
       for j=1:length(ECG)
            sumArray = sumArray + ECG(j);
       end
       averageArray = sumArray/length(ECG);
       
       % Calculate the standard deviation
       for j=1:length(ECG)
            sumSQRD = sumSQRD + (ECG(j) - averageArray)^2;
       end
       stdDev = sqrt( sumSQRD/length(ECG) );
       
       
       % Locate the peaks 3 deviations away from the mean
       [qrspeaks,locs] = findpeaks(ECG, 'MinPeakHeight' ,averageArray+3*stdDev, ...
                                        'MinPeakDistance', 100);

       % Calculate the average distance between each of the peaks
       for j=2:length(locs)
            sum = sum + locs(j) - locs(j-1);
       end
       avgRRInterval = sum / length(locs);
       
       % Calculate the average height of the peaks
       for j=1:length(qrspeaks)
            sumHeight = sumHeight + qrspeaks(j);
       end
       avgHeight = sumHeight / length(qrspeaks);
       
       % Ignore Anomalies
       if ( length(locs) <= 3 )
           continue;
       end
       
       if( (exist('RRInterval_afib' , 'var' ) == true) )
           RRInterval_afib = cat( 1 , RRInterval_afib, avgRRInterval );
           RPeakTotal_afib = cat( 1 , RPeakTotal_afib, length(locs) );
           RHeight_afib = cat( 1 , RHeight_afib, avgHeight );
           
       % Create matrix for atrial fibrialation data
       elseif ( (exist('RRInterval_afib' , 'var' ) == false) )
           RRInterval_afib = avgRRInterval;
           RPeakTotal_afib = length(locs);
           RHeight_afib = avgHeight;
       end       
   end
end

% Initialise Variables
normalSum = 0;
afibSum = 0;
normalRSum = 0;
afibRSum = 0;
afibHSum =0;

sumSQRD_normal = 0;
sumSQRD_afib = 0;
sumSQRD_normalR = 0;
sumSQRD_afibR = 0;
sumSQRD_afibH = 0;

% Calculate avg for afib data
for i=1:length(RRInterval_afib)
    afibSum = afibSum + RRInterval_afib(i);
    afibRSum = afibRSum + RPeakTotal_afib(i);
    afibHSum = afibHSum + RHeight_afib(i);
end
avgRRInterval_afib = afibSum / length(RRInterval_afib);
avgRTotal_afib = afibRSum / length(RPeakTotal_afib);
avgRHeight_afib = afibHSum / length(RHeight_afib);

% Calculate standard deviation for afib
for i=1:length(RRInterval_afib)
    sumSQRD_afib = sumSQRD_afib + (RRInterval_afib(i) - avgRRInterval_afib)^2;
    sumSQRD_afibR = sumSQRD_afibR + (RPeakTotal_afib(i) - avgRTotal_afib)^2;
    sumSQRD_afibH = sumSQRD_afibH + (RHeight_afib(i) - avgRHeight_afib)^2;
end
stdDev_afib = sqrt( sumSQRD_afib/length(RRInterval_afib) );
stdDev_afibR = sqrt( sumSQRD_afibR/length(RPeakTotal_afib) );
stdDev_afibH = sqrt( sumSQRD_afibH/length(RHeight_afib) );


fprintf("\nData Statistics :\n");
fprintf("Avg Interval = %03.0f\n", avgRRInterval_afib );
fprintf("STD Interval = %03.0f\n", stdDev_afib );
fprintf("Avg Total RR = %03.0f\n", avgRTotal_afib );
fprintf("STD Total RR = %03.0f\n", stdDev_afibR );
fprintf("Avg Height RR = %03.06f\n", avgRHeight_afib );
fprintf("STD Height RR = %03.06f\n", stdDev_afibH );

file_afibRR = fullfile( pdest, sprintf('RRInterval_afib.csv')  );
writematrix( RRInterval_afib, file_afibRR);

file_afibR = fullfile( pdest, sprintf('TotalR_afib.csv')  );
writematrix( RPeakTotal_afib, file_afibR);

file_afibH = fullfile( pdest, sprintf('RHeight_afib.csv')  );
writematrix( avgRHeight_afib, file_afibH);