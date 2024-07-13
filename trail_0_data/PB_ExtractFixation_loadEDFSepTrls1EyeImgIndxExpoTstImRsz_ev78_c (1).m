function [AllFixation] = PB_ExtractFixation_loadEDFSepTrls1EyeImgIndxExpoTstImRsz_ev78_c()
% Function for extracting fixation data for multiple block of one subj
% works on Olga's computer for the effect of image size on memory experiemt (Shaima's Exp.5)-
% changes made:
% loading mat files of subjects instead of edf files (this demands
%     edfImport manually for each edf separatly and saving the .mat of
%     imported data (saving as: trials = edfImport('AI6317_1.edf',[1 1 1])->  save('AI6317_1.mat','trials')
% uses data only from one eye (1 = right eye, 0 = left eye)
% adds image index number by indivisual order of presentaion and according
%      to exposure run or test run
% adds information about size of presentation and visual category for each image
% transforming x,y eye positions from monitor space to image space (according to image size)
% edfImport doesn't separeta trials in shaima's data, it creates two
%      trials, trial=2 contains all the data we need (->  WhichTrial  = 2)
% add list of images in order of viewing and image details for each partcipant (strct img_NameOrder)
% AllFixations.Day1 column3 is for object number - only relevant for analysis with mask, so it is 0 for all rows in our data
%
% recalibrating all eye positions by avg position in 3 deg images (ObsHposAvg, ObsVposAvg - this calc is performed in check_calib.m (matlab 2018)
%
%
% Input none, but requires to be in directory /data - with structure 'results\Trier_EDFs\SubjName\Day\FileName.edf'
% It requires also a .mat file with results from experimental design:
%               - dependent on fields Results.Age;Results.Handedness;Results.Sex;Results.CorrectedVision;
%               - and Results.ImNos - where image numbers are stored as
%                 they were presented in experiment (for different result struct, comment out those sections)
% Files should be saved under the path specified below.
%
% Based on Ben De Hass's, Marcel Linka's PB_ExtractFixation function and Petra Borovska's script  GETTING DATA FROM EXAMPLE TRIAL (07/22)



%% extract files and folder path to all edfs

dep             = genpath(pwd);addpath(dep);  % add current dir path
myFolder        = [pwd filesep 'results_EDFs' filesep 'byObs&Day&remane'];     % predefined file structure
Files           = dir(myFolder)        ;                           % get content of directory
SubFolders      = {Files([Files.isdir]).name}    ;                 % extract names
dirNames        = SubFolders(~ismember(SubFolders, {'.', '..'})) ;  % remove unwanted signs swiped from dir fuction
subjects        = 1:length(dirNames); % get number of subj based on nr of directories
days            = {'Exposure','test'} ;

load 'C:\Users\user\Dropbox\Proj-Olga\images-eye_movements\SizeMemoryEyeMovements\results_EDFs\images\exposure\image_indx_Exposure.mat'    % loading index list of image names
load 'C:\Users\user\Dropbox\Proj-Olga\images-eye_movements\SizeMemoryEyeMovements\results_EDFs\images\new\image_indx_test.mat'    % loading index list of image names
load 'C:\Users\user\Dropbox\Proj-Olga\images-eye_movements\SizeMemoryEyeMovements\preproc_data\AvgEyePos3degImg.mat'  % recalibrating eye positions -> ObsHposAvg, ObsVposAvg

% Width=52.0 cm  Res=1920x1080 / ~46.86x27.40 deg    1-cm=0.955 deg 1-pix~=0.0244
%% Image parameters - used to  transform x,y eye positions from monitor space to image space (according to image size)
% screen parms
Display_Width_MM    =   525;    % width of the presentation display pc in mm;
Display_Height_MM   =   295;    % height of the presentation display pc in mm;
Display_Width_Pix   =   1920;   % width of the presentation display pc in pixels;
Display_Height_Pix  =   1080;   % height of the presentation display pc in pixels;
Viewing_Dist_MM     =   600;    % viewing distance from the tower to monitor in mm

Pix_Per_MM          =   Display_Width_Pix ./ Display_Width_MM;  % to convert size in mm to pixels
%Viewing_Dist_Pix    =   Viewing_Dist_MM .* Pix_Per_MM;  % convert viewing distance to pixels
Deg_Per_MM          =   2 .* atand((1./2)./Viewing_Dist_MM);    % in deg - how many degrees is there per 1 mm
Deg_Per_Pix         =   Deg_Per_MM ./ Pix_Per_MM;               % in deg - how many degrees in 1 pixel
Pix_Per_Deg         =   1 ./ Deg_Per_Pix;                       % in pixels - how many pixels is in 1 degree


% stimulus size in pixels
Stimulus24_Width_Pix  = 900;   Stimulus24_Height_Pix = Stimulus24_Width_Pix;
Stimulus12_Width_Pix  = 450;   Stimulus12_Height_Pix = Stimulus12_Width_Pix;
Stimulus6_Width_Pix   = 225;   Stimulus6_Height_Pix  = Stimulus6_Width_Pix;
Stimulus3_Width_Pix   = 112;   Stimulus3_Height_Pix  = Stimulus3_Width_Pix;
Stimulus8_Width_Pix   = 320;   Stimulus8_Height_Pix  = Stimulus8_Width_Pix;

% re-calibration factor (in pixels)
resize24_width = (Display_Width_Pix-Stimulus24_Width_Pix)/2 ; resize24_Height = (Display_Height_Pix-Stimulus24_Height_Pix)/2 ;
resize12_width = (Display_Width_Pix-Stimulus12_Width_Pix)/2 ; resize12_Height = (Display_Height_Pix-Stimulus12_Height_Pix)/2 ;
resize6_width  = (Display_Width_Pix-Stimulus6_Width_Pix)/2  ; resize6_Height = (Display_Height_Pix-Stimulus6_Height_Pix)/2 ;
resize3_width  = (Display_Width_Pix-Stimulus3_Width_Pix)/2  ; resize3_Height = (Display_Height_Pix-Stimulus3_Height_Pix)/2 ;
resize8_width  = (Display_Width_Pix-Stimulus8_Width_Pix)/2  ; resize8_Height = (Display_Height_Pix-Stimulus8_Height_Pix)/2 ;

%% main loop
for iday = 1:size(days,2)  % design specific - don't need if just one session

    day = days{iday};

    %% subj loop
    for isubj =20 % subjects  % loop through subjects

        disp(['Now day ' day ' subject nr ' num2str(isubj) ' ' dirNames{isubj}]);

        % create a header so you know what is in the matrix fields
        AllFixation.Hdr(1,:) = ["image_index","nrEvent","XStart","YStart","XEnd","YEnd", ...
            "Onset","Offset","Duration","nrBlock", ...
            "Amplitude","AmplitudeDeg","vPeakDeg","vAvgDeg",...     % Type: 1 fixation; 2 saccade
            "", "image_size", "image_category","serial_image_number"];          % image size: 900=24deg, 450=12deg, 225=6deg, 112=3deg; image category: 1=face, 2=people, 3=indoor, 4=outdoor

        Data            = zeros(1,size(AllFixation.Hdr,2));     % init empty data matrix filled later
        blockPath       = [myFolder filesep dirNames{isubj}];  % access block path for each subject
        nrEDF           = 1;  % define number of edf files - we had 7 runs, so it would be 7
        %     counter         = 1;  % init row number

        %% block loop
        for iblock = 1:nrEDF   % enter loop for block, here we have only 1 (originally we have 7)

            % get names for result file and edf file
            %                resultsName = PB_GetSubFiles([blockPath filesep day filesep dirNames{i_subj} '_Block' num2str(i_block) '.mat']);
            trialsName  = PB_GetSubFiles([blockPath filesep day filesep dirNames{isubj} '_' num2str(iblock) '.edf']); % !!!!
            % trialsName  = PB_GetSubFiles([blockPath filesep day filesep dirNames{isubj} '_' num2str(iblock) '.mat']);

            % define path to result and edf file
            trials      = [blockPath filesep day filesep trialsName];
            %                results     = [blockPath filesep day filesep resultsName];

            % load actual edf trials and our result struct
            Trials     = edfImport(trials, [1 1 1]);
            %Trials = load ([trials]);
            %                load(results);

            %%
            % Define trials
            WhichTrial  = 2;   % we know it's always second trial with all participants
            OnsetIdx    = find(contains(Trials(WhichTrial).Events.message,'TRIGGER'));   % search for trigger message - index of onset of trial
            OffsetIdx   = find(contains(Trials(WhichTrial).Events.message,'END_TRIAL')); % search for end_trial message - index of offset of trial


            % ensure that you have messages for all trial onset and offset
            if iday==1
                assert(size(OnsetIdx,2)==160,'Error: You have less trials than expected (160)');  % make sure we have right number of trials
                % assert(size(OnsetIdx,2)==size(OffsetIdx,2),'Error: Onset and offset doesnt match - check missing messages?') % does onset and offset match?
            elseif iday==2
                assert(size(OnsetIdx,2)==320,'Error: You have less trials than expected (320)');  % make sure we have right number of trials
            end % if day expoure or test for correct number of trials

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


            end

            %%
            % add image information to Data
            for iimg=1:size(end_trial_msg,2)
                % find image's index number
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


            %%
            
            % re-calibrate eye positions relative to top-left corner of image and not relative to screen
            for i_ifix = 1:size(Data,1)
                if     Data(i_ifix,16)==112
                    Data(i_ifix,3) = Data(i_ifix,3)-resize3_width+1;  Data(i_ifix,4) = Data(i_ifix,4)-resize3_Height+1;   % start x and y
                    Data(i_ifix,5) = Data(i_ifix,5)-resize3_width+1;  Data(i_ifix,6) = Data(i_ifix,6)-resize3_Height+1;   % end x and y
                elseif Data(i_ifix,16)==225
                    Data(i_ifix,3) = Data(i_ifix,3)-resize6_width+1;  Data(i_ifix,4) = Data(i_ifix,4)-resize6_Height+1;
                    Data(i_ifix,5) = Data(i_ifix,5)-resize6_width+1;  Data(i_ifix,6) = Data(i_ifix,6)-resize6_Height+1;
                elseif Data(i_ifix,16)==450
                    Data(i_ifix,3) = Data(i_ifix,3)-resize12_width+1; Data(i_ifix,4) = Data(i_ifix,4)-resize12_Height+1;
                    Data(i_ifix,5) = Data(i_ifix,5)-resize12_width+1; Data(i_ifix,6) = Data(i_ifix,6)-resize12_Height+1;
                elseif Data(i_ifix,16)==900
                    Data(i_ifix,3) = Data(i_ifix,3)-resize24_width+1; Data(i_ifix,4) = Data(i_ifix,4)-resize24_Height+1;
                    Data(i_ifix,5) = Data(i_ifix,5)-resize24_width+1; Data(i_ifix,6) = Data(i_ifix,6)-resize24_Height+1;
                elseif Data(i_ifix,16)==0  % new images
                    Data(i_ifix,3) = Data(i_ifix,3)-resize8_width+1;  Data(i_ifix,4) = Data(i_ifix,4)-resize8_Height+1;
                    Data(i_ifix,5) = Data(i_ifix,5)-resize8_width+1;  Data(i_ifix,6) = Data(i_ifix,6)-resize8_Height+1;
                end
            end

            % re-numbering fixation per image-trial (and not per session)
            fix_counter = 1;
            for i_ifix = 2:size(Data,1)
                if  Data(i_ifix,1) == Data(i_ifix-1,1)
                    fix_counter = fix_counter+1;
                    Data(i_ifix,2) = fix_counter;
                else
                    fix_counter = 1;
                    Data(i_ifix,2) = fix_counter;
                end
            end


            %%
            % save all data to new AllFixation structure  and image indexing table
            AllFixation.(['Day' num2str(iday)]){1,isubj} = Data;
            AllFixation.(['Day' num2str(iday)]){2,isubj}= img_NameOrder;
            AllFixation.Hdr(2,:) = ["im_name","category","size","image_index_number","category_index","","","","","","","","","","","","",""];
            clear img_NameOrder

            AllFixation.Subj{isubj}    = dirNames{isubj};    % subject name
        end   % if block==1


    end  % i_subj



end % i_day


% save info on display parameters and subject demographic in our new AllFixation structure

AllFixation.Disp.WidthMM    = Display_Width_MM;
AllFixation.Disp.HeightMM   = Display_Height_MM;
AllFixation.Disp.HeightPix  = Display_Height_Pix;
AllFixation.Disp.WidthPix   = Display_Width_Pix;
AllFixation.Disp.PixPerDegVisAng = Pix_Per_Deg;    % pixel per degree



%
% save to our directory: preproc_data
save(['preproc_data' filesep 'AllFixation_Img_n' num2str(isubj) '.mat'], 'AllFixation');



disp EndOfFunction-ExtractFixation







