% Set the directory path for exposure data
dataDirectory = 'C:\Users\User\PycharmProjects\FinalProject\exposure\';

% List all EDF files in the directory
edfFiles = dir(fullfile(dataDirectory, '*.edf'));

% Loop through each EDF file
for fileIdx = 1:numel(edfFiles)
    % Get the file name and full file path
    fileName = edfFiles(fileIdx).name;
    filePath = fullfile(dataDirectory, fileName);
    
    % Display the current file being processed
    disp(['Processing file: ', fileName]);
    
    % Import data from EDF file
    Trials = edfImport(filePath);
    
    % Perform the data processing steps (same code as in your provided script)
    % ...
    % (Your data processing code goes here)
    % ...
    
    % Create a CSV file name based on the EDF file name
    [~, csvFileName, ~] = fileparts(fileName);  % Remove the file extension from the EDF file name
    csvFileName = [csvFileName, '.csv'];        % Add the .csv extension
    csvFilePath = fullfile(dataDirectory, csvFileName);
    
    % Save the processed data to the CSV file
    writematrix(Data, csvFilePath);
    
    % Clear variables to prepare for the next file
    clearvars -except dataDirectory edfFiles fileIdx
end

disp('Processing and CSV saving completed!');
