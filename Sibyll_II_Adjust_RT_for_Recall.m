%% Process RT and VTC according to adjusted values
function [three_bins] = divideToThree(subjID, nprompts)
    %% retrieve VTC information
    disp(sprintf('\n ... Open and save the file...\n'));
    
    fileDest = 'research_path\Research\Classified_study_codename\Results\VTC Analysis\Alpha Phase\VTC Tables Recall\'; 
    cd(fileDest);
    
    if ~exist('subjID', 'var')
        subjID = input('Enter participant ID: ', 's');
    end
    
    disp(sprintf('... Getting gender task data ... \n'));
    VTCData = readtable([fileDest 'Classified_study_codename_' subjID '_VTC_merged_data.csv']);
   
    %disp(VTCData);
    %% Calculate and readjust RT VTC values
    mean_rt = mean(VTCData.RT(:), 'omitnan');
    std_rt  = std(VTCData.RT(:), 'omitnan');
    
    col         = cell(length(VTCData{:,1}),1);
    Adjusted_RT = cell2table(col, 'VariableNames', {'Adjusted_RT'});
    Adjusted_VTC= cell2table(col, 'VariableNames', {'Adjusted_VTC'});
    Avg3_RT     = cell2table(col, 'VariableNames', {'Avg3_RT'});
    Avg3_VTC    = cell2table(col, 'VariableNames', {'Avg3_VTC'});
    VTCData     = [VTCData Adjusted_RT Adjusted_VTC Avg3_RT Avg3_VTC];
    
    for i = 1:length(VTCData{:,1})   
       if isnan(VTCData.RT(i))
           VTCData.Adjusted_RT{i} = 1.25;
       else
           VTCData.Adjusted_RT{i} = VTCData.RT(i);
       end 
       if isnan(VTCData.VTC(i))
           VTCData.Adjusted_VTC{i} = abs((1.25 - mean_rt)/std_rt);
       else
           VTCData.Adjusted_VTC{i} = VTCData.VTC(i);
       end
    end
   
    for i = 1:length(VTCData{:,1})
        if i > 3
            VTCData.Avg3_RT{i} = (VTCData.Adjusted_RT{i-3} + VTCData.Adjusted_RT{i-1} + VTCData.Adjusted_RT{i-2})/3;
            VTCData.Avg3_VTC{i} = (VTCData.Adjusted_VTC{i-3} + VTCData.Adjusted_VTC{i-1} + VTCData.Adjusted_VTC{i-2})/3;
        end
    end
    
    
    %% Setting up table to store data in
    fprintf('... Setting up table...\n');
    ID = strcat('S',num2str(subjID), '_');
    Hit_RT   = cell2table(col, 'VariableNames', {strcat(ID,'Hit_RT')});
    Miss_RT  = cell2table(col, 'VariableNames', {strcat(ID,'Miss_RT')});
    Hit_VTC  = cell2table(col, 'VariableNames', {strcat(ID,'Hit_VTC')});
    Miss_VTC = cell2table(col, 'VariableNames', {strcat(ID,'Miss_VTC')});
    HitMiss  = [Hit_RT Miss_RT Hit_VTC Miss_VTC];
    
    ID = strcat('S',num2str(subjID), '_');
    Hit_RT3   = cell2table(col, 'VariableNames', {strcat(ID,'Hit_RT3')});
    Miss_RT3  = cell2table(col, 'VariableNames', {strcat(ID,'Miss_RT3')});
    Hit_VTC3  = cell2table(col, 'VariableNames', {strcat(ID,'Hit_VTC3')});
    Miss_VTC3 = cell2table(col, 'VariableNames', {strcat(ID,'Miss_VTC3')});
    HitMiss3  = [Hit_RT3 Miss_RT3 Hit_VTC3 Miss_VTC3];
    
    %% Put all data into summarized table
    a = 1;
    b = 1;
    for i = 1:length(VTCData{:,1})
        if VTCData.Recall_Accuracy{i} == "Hit"
            HitMiss{a, 1}  = VTCData.Adjusted_RT(i);
            HitMiss3{a, 1} = VTCData.Avg3_RT(i);
            HitMiss{a, 3} = VTCData.Adjusted_VTC(i);
            HitMiss3{a, 3}= VTCData.Avg3_VTC(i);
            a = a + 1;
        elseif VTCData.Recall_Accuracy{i} == "Miss"
            HitMiss{b, 2}  = VTCData.Adjusted_RT(i);
            HitMiss3{b, 2} = VTCData.Avg3_RT(i);
            HitMiss{b, 4} = VTCData.Adjusted_VTC(i);
            HitMiss3{b, 4}= VTCData.Avg3_VTC(i);
            b = b + 1;
        end
    end
    
    %% Save data
    %% Ratio data compilation complete - save data to  file
    summary_dir = 'path\Research\Classified_study_codename\Results\VTC Analysis\Alpha Phase\VTC Tables Recall - 2\';
    File_HitMiss =[summary_dir 'VTC_Hit_Miss.csv'];
    File_HitMiss3 =[summary_dir 'avg_VTC_Hit_Miss.csv'];
    
    if exist(File_HitMiss, 'file')
        Add_HitMiss = ([readtable(File_HitMiss)]);
        Add_HitMiss = [Add_HitMiss HitMiss];
        writetable(Add_HitMiss, File_HitMiss);
    else
        writetable(HitMiss, File_HitMiss);
    end
    
    if exist(File_HitMiss3, 'file')
        Add_HitMiss3 = ([readtable(File_HitMiss3)]);
        Add_HitMiss3 = [Add_HitMiss3 HitMiss3];
        writetable(Add_HitMiss3, File_HitMiss3);
    else
        writetable(HitMiss3, File_HitMiss3);
    end
            
    FileVTC = [summary_dir 'Classified_study_codename_' subjID '_merged_data_with_VTC.csv'];
    writetable(VTCData, FileVTC);
    
        