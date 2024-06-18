function convertEDFtoMAT(folder)
    % Get a list of all EDF files in the folder
    edfFiles = dir(fullfile(folder, '*.edf'));

    % Iterate through each file
    for i = 1:length(edfFiles)
        % Get the file name and path
        filename = edfFiles(i).name;
        filepath = fullfile(folder, filename);

        % Import the EDF file
        trials = edfImport(filepath, [1 1 1]);

        % Get the MAT file name
        [~, name, ~] = fileparts(filename);
        matFile = fullfile(folder, [name '.mat']);

        % Save the trials variable as a MAT file
        save(matFile, 'trials');
    end
end
