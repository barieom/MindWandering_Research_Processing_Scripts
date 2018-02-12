%% Bin into in, middle, and out zones.
%
% Merges the processed VTCs to investigate whether there exists any
% correlation between mind-wandering/accuracy and objective measure--i.e.
% VTC processed RTs

function [three_bins] = divideToThree(subjID, nprompts)
    %% retrieve VTC information
    disp(sprintf('\n ... Open and save the file...\n'));
    
    fileDest = 'Directory_path_has_been_changed\Research\Classified_study_codename\Results\VTC Analysis\Alpha Phase\VTC Tables\'; 
    cd(fileDest);
    
    if ~exist('subjID', 'var')
        subjID = input('Enter participant ID: ', 's');
    end
    
    disp(sprintf('... Getting gender task data ... \n'));
    VTCData = readtable([fileDest 'Classified_study_codename_' subjID '_VTC_gender_task_data.csv']);
   
    %% retrieve recall task info
    fprintf('\n\n*** Merging behavioral data from task 1 and 2 ***\n\n');

    RecallDataDir = 'Changed_directory_path/Research/Classified_study_codename/Data/';
    if ismac
        RecallDataDir = 'Directory_path/Research/Classified_study_codename/Data/';
    end
    cd(RecallDataDir);

    if ~exist('subjID', 'var')
        subjID = input('Enter participant ID: ','s');
    end

    fprintf('... Getting recall task data ...\n');
    RecallData = readtable([RecallDataDir 'Classified_study_codename_' subjID '_recall_task_data.csv']);

    %% Move to new directory where work will be done and processed.
    
    finalDir = '\\rstore1.tufts.ad.tufts.edu\as_rsch_race_lab01$\EEG_Studies\Research\Classified_study_codename\Results\VTC Analysis\Alpha Phase\VTC Tables Recall\';
    cd(finalDir);
    
    col        = cell(length(VTCData{:,1}),1);
    Response   = cell2table(col, 'VariableNames', {'Response'});
    NewOld     = cell2table(col, 'VariableNames', {'NewOld'});
    Confidence = cell2table(col, 'VariableNames', {'Confidence'});
    Recall_Accuracy    = cell2table(col, 'VariableNames', {'Recall_Accuracy'});
    VTCData    = [VTCData Response NewOld Confidence Recall_Accuracy];
    
    %% Fill in the column and merge recall data
    for i = 1:length(VTCData{:,1})       
        VTCData.Face_ID(i) = VTCData.Face_ID(i) + 1;
    end
    for f = 1:length(RecallData{:,1})
        oldnew = regexp(RecallData.probe_keys{f},'OLD|NEW','match');
        oldnew = oldnew{1};
        conf = regexp(RecallData.probe_keys{f},'Low|High','match');
        conf = conf{1};
       
        if strcmp(oldnew,'NEW')
            RecallData.OldNewResponse{f,1} = 'NEW';
            if strcmp(conf,'Low')
                RecallData.Confidence{f,1} = 'Low';
            else
                RecallData.Confidence{f,1} = 'High';
            end
            if strcmp(RecallData.AlreadySeen{f},'Yes')
                RecallData.Outcome{f,1} = 'Miss';
            else
                RecallData.Outcome{f,1} = 'CorrRej';
            end
        else
            RecallData.OldNewResponse{f,1} = 'OLD';
            if strcmp(conf,'Low')
                RecallData.Confidence{f,1} = 'Low';
            else
                RecallData.Confidence{f,1} = 'High';
            end
            if strcmp(RecallData.AlreadySeen{f},'Yes')
                RecallData.Outcome{f,1} = 'Hit';
            else
                RecallData.Outcome{f,1} = 'FalseAlarm';
            end
        end
    end
    fprintf('.... Recall data is organized and ready to be merged...\n');
    
    RecallData = sortrows(RecallData, 'Task1BlockNum');
    count = 0;
    for f = 1:length(RecallData{:,1})
        num = (RecallData.Outcome{f});
        recall_num = str2double(RecallData.Task1FaceNum{f});
        if (isinteger(recall_num) || ~isempty(recall_num))
               for i = 1:length(VTCData{:,1})
                   if (uint8(VTCData.Face_ID(i)) == (recall_num))
                       count = count + 1;
                       VTCData.Response{i}   = RecallData.probe_keys{f};
                       VTCData.NewOld{i}     = RecallData.OldNewResponse{f};
                       VTCData.Confidence{i} = RecallData.Confidence{f};
                       VTCData.Recall_Accuracy{i} = num;
                   end
               end 
        elseif (count > 300)
            break;
        end
    end
    
    %% Ratio data compilation complete - save data to  file
    sumDir = 'directory_path\Research\Classified_study_codename\Results\VTC Analysis\Alpha Phase\VTC Tables Recall\'
    FileMergeVTC = [sumDir 'Classified_study_codename_' subjID '_VTC_merged_data.csv'];
    writetable(VTCData, FileMergeVTC);
   
   
    
    