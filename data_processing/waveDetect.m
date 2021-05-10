% Program used to get data statistics for real dataset

% Try to load data
if exist( 'training2017/ ' , 'dir' )
    
    files = dir('training2017/*.mat');
    labels = readtable('training2017/REFERENCE-v3.csv', 'ReadVariableNames',false);
    psource = 'training2017\';
    
else
    error('Error. no folder "training2017" found')
end

% Create new folder if doesnt exist
if ~exist( 'dataStatistics' , 'dir' )
 
    mkdir( 'dataStatistics' );
    pdest = 'dataStatistics\';
    
else
    error('Error. folder "dataStatistics" already exists');
end

fewercounter =0;

% For each file get data
for i=1:length(files)
    
   % If not normal ECG or atrial fibrilation continue
   if( ismember(labels.Var2(i), 'O') || ismember(labels.Var2(i), '~') )
       continue;
   end
   
   % Reset variables to 0
   sum = 0;
   sumArray = 0;
   sumSQRD = 0;
   sumHeight = 0;
    
   % Load source file
   sourceFile = load( fullfile( psource, files(i).name ) );
   
   % Ensure the length of the file is over the threshold
   if( size( sourceFile.val , 2 ) > 5000 )
       
       % Ensure only using the first portion of the ECG
       % Absolute values to deal with annomlies in dataset
       ECG = abs(sourceFile.val(1:5000));
       
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
           fewercounter = fewercounter +1;
           continue;
       end
       
       % If matrix exists append data to matrix
       if( (exist('RRInterval_normal' , 'var' ) == true) && ( ismember(labels.Var2(i), 'N')) )
           RRInterval_normal = cat( 1 , RRInterval_normal, avgRRInterval );
           RPeakTotal_normal = cat( 1 , RPeakTotal_normal, length(locs) );
           RHeight_normal = cat( 1 , RHeight_normal, avgHeight );
       
       elseif( (exist('RRInterval_afib' , 'var' ) == true) && ( ismember(labels.Var2(i), 'A')) )
           RRInterval_afib = cat( 1 , RRInterval_afib, avgRRInterval );
           RPeakTotal_afib = cat( 1 , RPeakTotal_afib, length(locs) );
           RHeight_afib = cat( 1 , RHeight_afib, avgHeight );
       
       % Create matrix for normal cardiac data
       elseif( (exist('RRInterval_normal' , 'var' ) == false) && ( ismember(labels.Var2(i), 'N')) )
           RRInterval_normal = avgRRInterval;
           RPeakTotal_normal = length(locs);
           RHeight_normal = avgHeight;
           
       % Create matrix for atrial fibrialation data
       elseif ( (exist('RRInterval_afib' , 'var' ) == false) && ( ismember(labels.Var2(i), 'A') ) )
           RRInterval_afib = avgRRInterval;
           RPeakTotal_afib = length(locs);
           RHeight_afib = avgHeight;
       end       
   end
end

% Initialise Variables
normalSum = 0;
normalRSum = 0;
normalHSum = 0;
afibSum = 0;
afibRSum = 0;
afibHSum =0;

sumSQRD_normal = 0;
sumSQRD_normalR = 0;
sumSQRD_normalH = 0;
sumSQRD_afib = 0;
sumSQRD_afibR = 0;
sumSQRD_afibH = 0;

% Calculate avg for normal cardiac
for i=1:length(RRInterval_normal)
    normalSum = normalSum + RRInterval_normal(i);
    normalRSum = normalRSum + RPeakTotal_normal(i);
    normalHSum = normalHSum + RHeight_normal(i);
end
avgRRInterval_normal = normalSum / length(RRInterval_normal);
avgRTotal_normal = normalRSum / length(RPeakTotal_normal);
avgRHeight_normal = normalHSum / length(RHeight_normal);

% Calculate standard deviation for normal cardiac
for i=1:length(RRInterval_normal)
    sumSQRD_normal = sumSQRD_normal + (RRInterval_normal(i) - avgRRInterval_normal)^2;
    sumSQRD_normalR = sumSQRD_normalR + (RPeakTotal_normal(i) - avgRTotal_normal)^2;
    sumSQRD_normalH = sumSQRD_normalH + (RHeight_normal(i) - avgRHeight_normal)^2;
end
stdDev_normal = sqrt( sumSQRD_normal/length(RRInterval_normal) );
stdDev_normalR = sqrt( sumSQRD_normalR/length(RPeakTotal_normal) );
stdDev_normalH = sqrt( sumSQRD_normalH/length(RHeight_normal) );

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

% Display answers
fprintf("\nNormal Cardiac :\n");
fprintf("Avg Interval = %03.0f\n", avgRRInterval_normal );
fprintf("STD Interval = %03.0f\n", stdDev_normal );
fprintf("Avg Total RR = %03.0f\n", avgRTotal_normal );
fprintf("STD Total RR = %03.0f\n", stdDev_normalR );
fprintf("Avg Height RR = %03.0f\n", avgRHeight_normal );
fprintf("STD Height RR = %03.0f\n", stdDev_normalH );

fprintf("\nAtrial Fibril :\n");
fprintf("Avg Interval = %03.0f\n", avgRRInterval_afib );
fprintf("STD Interval = %03.0f\n", stdDev_afib );
fprintf("Avg Total RR = %03.0f\n", avgRTotal_afib );
fprintf("STD Total RR = %03.0f\n", stdDev_afibR );
fprintf("Avg Height RR = %03.0f\n", avgRHeight_afib );
fprintf("STD Height RR = %03.0f\n", stdDev_afibH );


fprintf("\nfewer counter = %03.0f\n", fewercounter );
% Write data to file for later use
% file_normalRR = fullfile( pdest, sprintf('normalRRInteval.csv')  );
% writematrix( RRInterval_normal, file_normalRR);
% 
% file_afibRR = fullfile( pdest, sprintf('AfibRRInteval.csv')  );
% writematrix( RRInterval_afib, file_afibRR);
% 
% file_normalR = fullfile( pdest, sprintf('normalTotalR.csv')  );
% writematrix( RPeakTotal_normal, file_normalR);
% 
% file_afibR = fullfile( pdest, sprintf('AfibTotalR.csv')  );
% writematrix( RPeakTotal_afib, file_afibR);