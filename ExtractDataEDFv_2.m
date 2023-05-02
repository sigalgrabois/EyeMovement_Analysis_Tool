% Sigal and Shachar - Final project import data from EDF files
% this script takes the edf files and creates a data.csv file

% clear the variabls and close all.
clear;
close all;
% create gui to ask from the user the edf file
    % Select a file
    [fileName, folderName] = uigetfile('*.edf');
% first we use edfImport in order to create the Trails struct with the
% experiment data
Trials= edfImport(fileName);
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
            % handle unnecessary rows
            IsStartProblm = Data(:,7) >= 2000 | Data(:,7)==Data(:,8); % if start fixation time is after image offset (2000ms)  or start fixation is equal to end fixation -> dont include fixation data in table , override the data
            Data = Data(~IsStartProblm,:);

            isDblFix =zeros(size(Data,1),1);
            for  i_ifix = 1:size(Data,1)-1   % find fixations that appear twise - once for start (missing info) and second for end fixation - delete rows with start info only
                isDblFix (i_ifix,1) =  ( Data(i_ifix,18) == Data(i_ifix+1,18) &&  Data(i_ifix,7) ==  Data(i_ifix+1,7));  % since start fixation does not include all fixation data and end fixation does,  if start fixation and end fixation are in the same trial  -> leave only one row for fixation
            end
            Data = Data(~isDblFix,:);



            % fix problems with onset offset and duration of fixations
            numFix = size(Data,1);
            for i_ifix = 1:numFix   % fix problems with onset offset and duration of fixations
                if Data(i_ifix,8) ==0   % offset = 0  ,
                    if Data(i_ifix,7) ~=0
                        Data(i_ifix,8) = 2000;  % update fixation end to 2000 (evem if it extends beyond image presentation time)
                        Data(i_ifix,9) = Data(i_ifix,8) -  Data(i_ifix,7); % update fixation duration from fixation start to end
                    end
                end

                if  Data(i_ifix,7) ==0   % fixation onset = 0 <- if fixation started before trial start
                    Data(i_ifix,9) = Data(i_ifix,8) -  Data(i_ifix,7);  % duration should be relative to trial start and nor fixation start
                end

                if Data(i_ifix,8) >2000  % fixation offset is after trial ended
                    Data(i_ifix,8) = 2000;  % change fixation offset to trial end timee
                    Data(i_ifix,9) = Data(i_ifix,8) -  Data(i_ifix,7);  % update fixation duration by end of trial and not end of fixation
                end

                if Data(i_ifix,5) == 0 && i_ifix < numFix  % if x y position of end fixation are missing, take positions from next row (since they are the same fixation, it probably started during one trial and ended in the next trial so there is a row detailing it for both trials)
                    Data(i_ifix,5) = Data(i_ifix+1,5) ;
                    Data(i_ifix,6) = Data(i_ifix+1,6) ;
                elseif Data(i_ifix,5) == 0 && i_ifix == numFix   % if x y position of end fixation are missing and we dont have the next row to take the data from, than take locations from start fixation
                    Data(i_ifix,5) = Data(i_ifix,3) ;
                    Data(i_ifix,6) = Data(i_ifix,4) ;
                end


                
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

% create a csv file from the Data struct holding the data frame
writematrix(Data, 'Data.csv')
            end

% uses data only from one eye (1 = right eye, 0 = left eye) - we will
% choose 0 arbirtary