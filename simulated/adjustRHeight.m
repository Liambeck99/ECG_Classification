% Function used to correct the R peak height across the dataset

% Try to load data
if exist( 'simulatedData_temp/ ' , 'dir' )
    
    files = dir('simulatedData_temp/*.csv');
    psource = 'simulatedData_temp\';
    
else
    error('Error. no folder "simulatedData_temp" found')
end

% Create new folder if doesnt exist
if ~exist( 'simulatedData_final' , 'dir' )
 
    mkdir( 'simulatedData_final' );
    pdest = 'simulatedData_final\';
    
else
    pdest = 'simulatedData_final\';
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
  
   % Ensure only using the first portion of the ECG
   % Absolute values to deal with annomlies in dataset
   ECG = sourceFile(1:5000);
   
   multiple = randomEffects( 558.08, 350 );
   
   ECG = ECG * multiple;

   filename = sprintf('S%05.0f.csv', i+623 );
   fileDest = fullfile( pdest, filename );
   writematrix( ECG, fileDest);
           
end

% returns an random number that conforms to the distribution provided
function normal = randomEffects( kbar, sigma )
    %rng(0,'twister');   % sets seed to ensure its reproducable
    
    normal = sigma.*randn(1,1) + kbar;
end