% Create a custom dialog box
dlg = uifigure('Name', 'Folder Selection', 'Position', [500 500 400 150]);
messageLabel = uilabel(dlg, 'Text', 'Hey! Please choose the folder of the data you would like to load.', 'FontSize', 12, 'WordWrap', 'on', 'Position', [20 60 360 50]);
okButton = uibutton(dlg, 'Text', 'OK', 'Position', [150 10 100 30], 'ButtonPushedFcn', @(btn,event) close(dlg));

% Wait for the custom dialog box to be closed (i.e., the "OK" button is pressed)
uiwait(dlg);

% Ask the user for the folder path
dataDirectory = uigetdir('C:\Users\User\PycharmProjects\FinalProject', 'Select the folder containing EDF files');


if dataDirectory == 0
    disp('Folder selection canceled by the user.');
    return;
end

% List all EDF files in the directory
edfFiles = dir(fullfile(dataDirectory, '*.edf'));
numFiles = numel(edfFiles);

% Create a waitbar to display the progress
progressBar = waitbar(100, 'Processing EDF files...', 'Name', 'EDF File Processing');

% Get the handle to the waitbar figure
waitbarFigure = findall(progressBar, 'Type', 'figure');

% Set the desired width of the waitbar figure in pixels
desiredWidth = 400;

% Adjust the waitbar figure width
set(waitbarFigure, 'Position', [500 500 400 75]); % Adjust the position as needed (x, y, width, height)

% Loop through each EDF file
for fileIdx = 1:numFiles
    % Get the file name and full file path
    fileName = edfFiles(fileIdx).name;
    filePath = fullfile(dataDirectory, fileName);
    
    % Update the waitbar with the current progress
    progressPercentage = fileIdx / numFiles;
    waitbar(progressPercentage, progressBar, sprintf('Processing file %d of %d: %s', fileIdx, numFiles, fileName));
    
    % Import data from EDF file
    Trials = edfImport(filePath);
    iblock=1;
    iday =1;
    % loading mat files of subjects instead of edf files (this demands
%     edfImport manually for each edf separatly and saving the .mat of
%     imported data (saving as: trials = edfImport('AI6317_1.edf',[1 1 1])->  save('AI6317_1.mat','trials')
%convertEDFtoMAT('C:\Users\User\Documents\third_year\FINALPROJECT\trail0data');
% split into 2 trails -

 %%
            % Define trials
            WhichTrial  = 2;   % we know it's always second trial with all participants
            OnsetIdx    = find(contains(Trials(WhichTrial).Events.message,'TRIGGER'));   % search for trigger message - index of onset of trial
            OffsetIdx   = find(contains(Trials(WhichTrial).Events.message,'END_TRIAL')); % search for end_trial message - index of offset of trial

            assert(size(OnsetIdx,2)==size(OffsetIdx,2),'Error: Onset and offset doesnt match - check missing messages?') % does onset and offset match?
            % list of images participant viewed by order of presentation
            end_trial_msg = Trials(WhichTrial).Events.message(OffsetIdx);   %  extract END_TRIAL messages
            strt_trial_msg = Trials(WhichTrial).Events.message(OnsetIdx);   %  extract END_TRIAL messages

            for iimg = 1:size(end_trial_msg,2)
                img_dtlsEnd(:,iimg) = split (end_trial_msg(1,iimg));    % extracting image manes from END_TRIAL messages by order of presentation
                img_dtlsTrigger(:,iimg) = split (strt_trial_msg(1,iimg));   %  extracting image size and category from TRIGGER  messages
            end
            img_NameOrder (:,1) = img_dtlsEnd(10,:)';    % names of the images participant viewed by presentation order
            img_NameOrder (:,2:3) = img_dtlsTrigger([3 8],:)';    % size and category of images by presentation order
            % handle images that have 1 instead of 112 in size col (becuase of mistake in p.file , gx was gx=1 instead of gx=112)
            if sum (convertCharsToStrings(img_NameOrder (:,3)) == convertCharsToStrings('1.00') )>0
                indxCorrSize = find(convertCharsToStrings(img_NameOrder (:,3)) == convertCharsToStrings('1.00'));
                img_NameOrder (indxCorrSize,3) = {'112.00'};
            end

            % loop through events and find valid trials
            counter = 1;
            ifix =  1;     % increase event number

            for ievent = 1:size(Trials(WhichTrial).Events.message,2)  % loop through all events
                % for ievent = 2:size(Trials(WhichTrial).Events.message,2)+1   % to use if using both start event 7 and end event 8 to define fixations
                for itrial = 1:size(OnsetIdx,2) % get only trials of interest

                    % here the type of event you want to get is given, 7=start
                    % fixation, 8=end fixation, both must fit in the onset and offset
                    % of trials
                    if  (   ( Trials(WhichTrial).Events.type(ievent) == 7 || Trials(WhichTrial).Events.type(ievent) == 8 )   && ...
                            (ievent > OnsetIdx(itrial)    && ievent < OffsetIdx(itrial) )   ) && ...
                            ( Trials(WhichTrial).Events.eye(ievent)== 0)   % left eye data only

                        %  if (Trials(WhichTrial).Events.type(ievent) == 8 && ievent >= OnsetIdx(itrial)) ...
                        %          && ( Trials(WhichTrial).Events.type(ievent) == 8 && ievent <= OffsetIdx(itrial)) ...
                        %           &&  ( Trials(WhichTrial).Events.eye(ievent)== 0)   % left eye data only



                        fix_gstx   = Trials(WhichTrial).Events.gstx(ievent);  % start x position
                        fix_gsty   = Trials(WhichTrial).Events.gsty(ievent);  % start y position
                        fix_genx   = Trials(WhichTrial).Events.genx(ievent);  % end x position
                        fix_geny   = Trials(WhichTrial).Events.geny(ievent);  % end y position

                        fix_supd_x = Trials(WhichTrial).Events.supd_x(ievent); % start x in degrees
                        fix_supd_y = Trials(WhichTrial).Events.supd_y(ievent); % start y in degrees
                        fix_eupd_x = Trials(WhichTrial).Events.eupd_x(ievent); % end x in degrees
                        fix_eupd_y = Trials(WhichTrial).Events.eupd_y(ievent); % end y in degrees

                        fix_sttime = Trials(WhichTrial).Events.sttime(ievent); % start time of event
                        fix_entime = Trials(WhichTrial).Events.entime(ievent); % end time of event

                        Amplitude  = sqrt((fix_genx - fix_gstx).^2 + (fix_geny - fix_gsty).^2); % calculate amplitude as euclidean distance between point xStart,yStart - xEnd,yEnd

                        dx         = (fix_genx - fix_gstx) / ((fix_eupd_x + fix_supd_x)/2.0);   % calculating amplitude in degrees per pixel as given by eyelink, upd=unitsperdegree I think
                        dy         = (fix_geny - fix_gsty) / ((fix_eupd_y + fix_supd_y)/2.0);
                        AmplDeg    = sqrt(dx*dx + dy*dy); % calculate the distance

                        Data(counter,18)  = itrial;  % write a trial number from 1-160
                        Data(counter,2) = ifix;
                        Data(counter,3)  = fix_gstx; % write start x in pixels
                        Data(counter,4)  = fix_gsty; % write start y in pixels
                        Data(counter,5)  = fix_genx; % write end x in pixels
                        Data(counter,6)  = fix_geny; % write end y in pixels
                        Data(counter,7)  = double(fix_sttime - Trials(WhichTrial).Events.sttime(OnsetIdx(itrial))); % get onset: starttime of the event relative to start of the trial
                        Data(counter,8)  = double(fix_entime - Trials(WhichTrial).Events.sttime(OnsetIdx(itrial)));
                        Data(counter,9)  = double(fix_entime - fix_sttime);  % write duration
                        Data(counter,10) = iblock;                            % block number
                        Data(counter,11)  = Amplitude;  % write amplitude in pixels
                        Data(counter,12) = AmplDeg;    % write amplitude in degrees
                        Data(counter,13) = Trials(WhichTrial).Events.pvel(ievent); % write peak velocity deg/s
                        Data(counter,14) = Trials(WhichTrial).Events.avel(ievent); % write average velocity deg/s



                        counter = counter + 1;  % add 1 to row counter if we meet the criteria - being in the trial and having fixation
                        ifix = ifix + 1;     % increase event number


                    else
                        counter = counter + 0;  % dont inrease row counter if the event is not valid

                    end % if fixation

                end % i_trial

            end % i_event

                
            %%
            % add image information to Data
            for iimg=1:size(end_trial_msg,2)
                % find image's index number
                load('Exposure_image_indx.mat')
                if iday==1
                    img_NameOrder(iimg,4)= Exposure_image_indx(find(contains(Exposure_image_indx(:,1), cellstr( img_NameOrder(iimg,1)))),2)  ;  %find image_index number (from index list) for images by individual order of presentation
                elseif iday==2
                    img_NameOrder(iimg,4)= Test_image_indx(find(contains(Test_image_indx(:,1), cellstr( img_NameOrder(iimg,1)))),2)  ;  %find image_index number (from index list) for images by individual order of presentation
                end % if day exposure or test

                if strcmp(convertCharsToStrings(cellstr( img_NameOrder(iimg,2))),convertCharsToStrings('Face'))    % assigning index numbers to categories
                    img_NameOrder(iimg,5) = {1};
                elseif    strcmp(convertCharsToStrings(cellstr( img_NameOrder(iimg,2))),convertCharsToStrings('People'))
                    img_NameOrder(iimg,5) = {2};
                elseif    strcmp(convertCharsToStrings(cellstr( img_NameOrder(iimg,2))),convertCharsToStrings('Indoor'))
                    img_NameOrder(iimg,5) = {3};
                elseif  strcmp(convertCharsToStrings(cellstr( img_NameOrder(iimg,2))),convertCharsToStrings('Outdoor'))
                    img_NameOrder(iimg,5) = {4};
                end % i_im
            end % categories
            im_NameOrder_Hdr = ["img_name","category","size","image_index_number","category_index"];

            % adding image_index num, size and category to Data table
            for i_ifix = 1:size(Data,1)
                Data(i_ifix,1) =cell2mat(img_NameOrder(Data(i_ifix,18),4));
                Data(i_ifix,16) = convertCharsToStrings(cell2mat(img_NameOrder(Data(i_ifix,18),3)));
                Data(i_ifix,17) = convertCharsToStrings(cell2mat(img_NameOrder(Data(i_ifix,18),5)));
            end

    
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
    clearvars -except dataDirectory edfFiles fileIdx progressBar numFiles
end

% Close the progress bar
close(progressBar);

disp('Processing and CSV saving completed!');