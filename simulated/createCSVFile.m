% program which adds all simulated ECG to singular csv file
% Also creates csv file with labels

% Try to load data
if exist( 'simulatedData_final/ ' , 'dir' )
    
    files_afib = dir('simulatedData_final/*.csv');
    psource_afib = 'simulatedData_final\';
    
else
    error('Error. no folder "simulatedData_final" found')
end

% Create new folder if doesnt exist
if ~exist( 'simulatedData' , 'dir' )
 
    mkdir( 'simulatedData' );
    pdest = 'simulatedData\';
    
else
    error('Error. folder "simulatedData" already exists');
end

labels = ["A" "N"];

% For each afib file append and create label
for i=1:length(files_afib)

   % Load source file
   sourceFile = load( fullfile( psource_afib, files_afib(i).name ) );
   
   % If matrix doesnt exist create it
   if( exist('matrix' , 'var' ) == false )
       matrix = sourceFile;
   else
       matrix = cat( 1 , matrix, sourceFile ); % else concatanate
   end
   
   % Adds the corresponding label to a new array
   if( exist('newlabels' , 'var' ) == false )
       newlabels = labels(1);
   else
       newlabels = cat( 1 , newlabels, labels(1) ); % else concatanate
   end
end

% For each normal file append and create label
for i=1:length(files_norm)

   % Load source file
   sourceFile = load( fullfile( psource_norm, files_norm(i).name ) );
   
   % If matrix doesnt exist create it
   if( exist('matrix' , 'var' ) == false )
       matrix = sourceFile;
   else
       matrix = cat( 1 , matrix, sourceFile ); % else concatanate
   end
   
   % Adds the corresponding label to a new array
   if( exist('newlabels' , 'var' ) == false )
       newlabels = labels(1);
   else
       newlabels = cat( 1 , newlabels, labels(2) ); % else concatanate
   end
end

% Create a files at destination
destFile = fullfile( pdest, sprintf('simulatedData.csv')  );
destLabels = fullfile( pdest, sprintf('simulatedDataLabels.csv')  );
           
% Write data to files
writematrix(matrix, destFile);
writematrix(newlabels, destLabels);