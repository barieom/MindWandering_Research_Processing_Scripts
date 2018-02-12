%% Organize data by median, SD=1, and bin by MW prompt
%  Check line 24 if there is an error about
%  "matlab.internal.tabular.private.numArguments" or if there is an error
%  in line 24
function [merge] = mergebyMedianSd1(subjID, nprompt)
    disp(sprintf('\n ... Open and save the file...\n'));
    
    currDir = pwd;
    genderTaskDir = 'some_directory_path\Research\Classified_study_codename II\Data\';    
    cd(genderTaskDir);
    
    if ~exist('subjID', 'var')
        subjID = input('Enter participant ID: ', 's');
    end
    
    disp(sprintf('... Getting gender task data ... \n'));
    genderData = readtable([genderTaskDir 'Classified_study_codename_' subjID '_gender_task_data.csv']);
    genderData = table(genderData.LineNum(:),genderData.isCorrect_(:),genderData.GenderResponse_rt(:), genderData.probe_keys(:),'VariableNames', {'Face_ID', 'Accuracy', 'RT','MW'});
    
    %% create table to store data and calculate VTC for only "correct" trials
    fprintf('... Setting up for processing...\n');
    VTCtemp = cell2table(cell(0,4),'VariableNames', {'Face_ID', 'Accuracy', 'RT', 'MW'});

    % The if statement below is used for when the functions fail to read in
    % the data as doubles. This section may cause an error and if it does,
    % comment it out.
    % %{
    if isstr(genderData.RT{1})
        genderData.RT = cellfun(@(x) str2double(x),genderData.RT)
    end
    % %}
    
    % Copy over only trials for VTC calculation - trials that were answered 'Correct'
    for i = 1:length(genderData{:,1})
        if (strcmp(genderData.Accuracy(i),'Correct') && genderData.RT(i) < 2.0)
            VTCtemp = [VTCtemp;(genderData(i,:))];
        end
    end
    
    fprintf('... Normalizing raw RT and calculating VTC...\n');
    stdRT = zscore(VTCtemp.RT);
    VTC   = abs(stdRT);
    VTCtemp = [VTCtemp table(stdRT, 'VariableNames', {'RawVTC'}) table(VTC, 'VariableNames', {'VTC'})];
    
    
    
    %% Distinguish 'wrong' trails between incorrect answers and omission
    fprintf('... Dividing *wrong* trials to omit and wrong...\n');
    for i = 1:length(genderData{:,1})
        if isnan(genderData.RT(i)) && strcmp(genderData.Accuracy{i}, 'Wrong')
            genderData.Accuracy{i} = 'Omit';
        end
    end
    
    
    %% Copy over table from previous to existing table. If trial answered "wrong," place substitute val
    len = length(genderData{:,1})-16;
    VTCdata = cell2table(cell(len,6), 'VariableNames', {'Face_ID', 'Accuracy', 'RT', 'std_RT', 'VTC', 'MW'});
    j = 0
    
    fprintf('... Copying over table while excluding rows containing MW probes...\n');
    % Copy over table while excluding MW probes 
    for i = 1:length(genderData{:,1})
        if ~isnan(genderData.Face_ID(i))
            VTCdata.Face_ID{i-j}  = genderData.Face_ID(i);
            VTCdata.RT{i-j}       = genderData.RT(i);
            VTCdata.Accuracy{i-j} = genderData.Accuracy{i};
        else
            j = j + 1;
            VTCdata.MW{i-2-j}     = genderData.MW{i};
            VTCdata.MW{i-1-j}     = genderData.MW{i};
            VTCdata.MW{i-j}       = genderData.MW{i};
        end
    end
    
    fprintf('... Copying over VTCs from previously calculated table dataset...\n');
    % Copy over VTCs
    for i = 1:length(VTCdata{:,1})
        for j = 1:length(VTCtemp{:,1})
            if (cell2mat(VTCdata.Face_ID(i)) == VTCtemp.Face_ID(j))
                VTCdata.std_RT{i} = VTCtemp.RawVTC(j);
                VTCdata.VTC{i}    = VTCtemp.VTC(j);
            end
        end
    end
    
    %% Bin data according to median or SD=1 cut off
    fprintf('.... Binning data according to the median and SD=1 cut off...\n');
    medianVTC = median(VTCtemp.VTC);
    
    tempCol   = cell(length(VTCdata{:,1}),1);
    medZone   = cell2table(tempCol, 'VariableNames', {'Median_Zone'});
    SD1Zone   = cell2table(tempCol, 'VariableNames', {'SD1_Zone'});
    VTCdata   = [VTCdata medZone SD1Zone];
    
    for i = 1:length(VTCdata{:,1})
        if (cell2mat(VTCdata.VTC(i)) > medianVTC )
            VTCdata.Median_Zone{i} = 'out-of-the-zone';
        elseif (cell2mat(VTCdata.VTC(i)) < medianVTC )
            VTCdata.Median_Zone{i} = 'in-the-zone'
        end
        if (cell2mat(VTCdata.VTC(i)) > 1 )
            VTCdata.SD1_Zone{i}    = 'out-of-the-zone';
        elseif (cell2mat(VTCdata.VTC(i)) < 1 )
            VTCdata.SD1_Zone{i}    = 'in-the-zone';
        end
        if (strcmp(VTCdata.Accuracy{i},'Omit') | (strcmp(VTCdata.Accuracy{i},'Wrong')))
            VTCdata.Median_Zone{i} = 'out-of-the-zone';
            VTCdata.SD1_Zone{i}    = 'out-of-the-zone';
        end
    end
    
    %% Calculate VTC means based on MW - yes/no
    fprintf('... Calculating mean VTC for MW yes and MW no...\n');
    tempMWVTC   = cell(49,2);
    avgMWVTC    = cell(2,1);
    IDMWY       = ['S_' subjID '_yes_MW'];
    IDMWN       = ['S_' subjID '_no_MW'];
    VTC2MW      = cell2table(tempMWVTC, 'VariableNames', {IDMWY, IDMWN});
   
    j = 1;
    k = 1;
    out_count_y = 0;
    out_count_n = 0;
    for i = 1:length(VTCdata{:,1})
        if (strcmp(VTCdata.MW(i), 'Yes'))
            if ~isempty(VTCdata.VTC{i})
                VTC2MW{j, 1} = {VTCdata.VTC{i}};
                j = j + 1;
            else
                out_count_y = out_count_y + 1;
            end
        elseif (strcmp(VTCdata.MW(i), 'No'))
            if ~isempty(VTCdata.VTC{i})
                VTC2MW{k, 2} = {VTCdata.VTC{i}};
                k = k + 1;
            else
                out_count_n = out_count_n + 1;
            end
        end
    end
    VTC2MW{49,1} = {out_count_y};
    VTC2MW{49,2} = {out_count_n}; 
    
    %% Save file
    fprintf('... Saving tables...\n');
    newDest = 'classified_stuff\Research\Classified_study_codename II\VTC Analysis\Alpha Phase\'; 
   
    FileMWVTC =[newDest 'VTC Tables with Analysis\VTC_Percentage.csv'];
    if exist(FileMWVTC, 'file')
        Add_MWVTC = ([readtable(FileMWVTC)]);
        Add_MWVTC = [Add_MWVTC VTC2MW];
        writetable(Add_MWVTC, FileMWVTC);
    else
        writetable(VTC2MW, FileMWVTC);
    end
    
    FileVTC = [newDest 'VTC Tables\' 'Classified_study_codename_' subjID '_VTC_gender_task_data.csv'];
    writetable(VTCdata, FileVTC);
    