% Try to load data
if exist( 'training2017/ ' , 'dir' )
    
    files = dir('training2017/*.mat');
    labels = readtable('training2017/REFERENCE-v3.csv', 'ReadVariableNames',false);
    psource = 'training2017\';
    
else
    error('Error. no folder "training2017" found')
end

% Create new folder if doesnt exist
if ~exist( 'ammendedData' , 'dir' )
 
    mkdir( 'ammendedData' );
    pdest = 'ammendedData\';
    
else
    error('Error. folder "ammendedData" already exists');
end

% For each file
for i=1:length(files)
    
   % Load source file
   sourceFile = load( fullfile( psource, files(i).name ) );
   
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

% Create a files at destination
destFile = fullfile( pdest, sprintf('ammendedData.csv')  );
destLabels = fullfile( pdest, sprintf('ammendedLabels.csv')  );
           
% Write data to files
writematrix(matrix, destFile);
writetable(newlabels, destLabels, 'WriteVariableNames', false);