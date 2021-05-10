% Program to join the reala dn simulated data into a single file

% Try to load data
if exist( 'training2017/ ' , 'dir' )
    
    files_real = dir('training2017/*.mat');
    labels = readtable('training2017/REFERENCE-v3.csv', 'ReadVariableNames',false);
    psource_real = 'training2017\';
    
else
    error('Error. no folder "training2017" found')
end

% Try to load data
if exist( 'simulatedData/ ' , 'dir' )
    
    files_afib = dir('../simulated/simulatedData/*.csv');
    psource_afib = '../simulated/simulatedData\';
    
else
    error('Error. no folder "simulatedData" found')
end

% Create new folder if doesnt exist
if ~exist( 'mergedData' , 'dir' )
 
    mkdir( 'mergedData' );
    pdest = 'mergedData\';
    
else
    error('Error. folder "mergedData" already exists');
end

% For each file
for i=1:length(files_real)
    
   % If not normal ECG or atrial fibrilation continue
   if( ismember(labels.Var2(i), 'O') || ismember(labels.Var2(i), '~') )
       continue;
   end
    
   % Load source file
   sourceFile = load( fullfile( psource_real, files_real(i).name ) );
   
   % If the length of the file is equal/over 5000 copy to new folder
   if( size( sourceFile.val , 2 ) > 5000 )
       
       % If equal to 5000 copy file to folder
       if ( size( sourceFile.val , 2 ) == 5000 )
           
           % If matrix doesnt exist create it
           if( exist('matrix' , 'var' ) == false )
               matrix = sourceFile.val;
           else
               matrix = cat( 1 , matrix, sourceFile.val ); % else concatanate
           end
       
       % Else if over 5000 shoten array and then move to folder
       else
           
           % Cut array length
           sourceFile.val = sourceFile.val(1:5000);
           
           % If matrix doesnt exist create it
           if( exist('matrix' , 'var' ) == false )
               matrix = sourceFile.val;
           else
               matrix = cat( 1 , matrix, sourceFile.val ); % else concatanate
           end
                  
       end
       
       % Adds the corresponding label to a new array
       if( exist('newlabels' , 'var' ) == false )
           newlabels = labels(i,2);
       else
           newlabels = cat( 1 , newlabels, labels(i,2) ); % else concatanate
       end
   end
end

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
       newlabels = cat( 1 , newlabels, labels(4,2) ); % else concatanate
   end
end

% Create a files at destination
destFile = fullfile( pdest, sprintf('mergedData.csv')  );
destLabels = fullfile( pdest, sprintf('mergedDataLabels.csv')  );
           
% Write data to files
writematrix(matrix, destFile);
writetable(newlabels, destLabels, 'WriteVariableNames', false);