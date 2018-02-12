%% Match MW subjective reports to VTC
% VTC data matched with MW reports
function [VTC2MW] = merge(subjID, nprompt)

    disp(sprintf('\n ... Open and save fhe file...\n'));
    
    currDir = pwd;
    fileDir = 'directory_path\Research\Classified_study_codename II\VTC Analysis\Alpha Phase\VTC Tables\';
    cd(fileDir);
    
    if ~exist('subjID', 'var')
        subjID = input('Enter participant ID: ', 's');
    end
    
    disp(sprintf('... Getting gender task data ... \n'));
    VTCdata = readtable([fileDir 'Classified_study_codename_' subjID '_VTC_gender_task_data.csv']);
    
    %% Setting up table to store data in
    fprintf('... Setting up table...\n');
    temp = cell(30,1);
    ID = strcat('S_', num2str(subjID));
    MW2Zone = cell2table(temp, 'VariableNames', {ID});
    mwz = 0;
    
    %% Counting and Correlation process
    fprintf('... Correlation process in progress...\n');
    fprintf('... First cluster processing...\n');
    for h = 1:2
        % Store information about subjective MW reports and zone values
        % into struct
        ratio = struct('MWYI', 0, 'MWYO', 0, 'MWNI', 0, 'MWNO', 0);
        out_zone_total = 0;
        in_zone_total = 0;
        for i = 1:length(VTCdata{:,1})
            if (isempty(VTCdata.MW{i}))
            elseif (VTCdata.MW{i} == "Yes" & VTCdata{i,6+h} == "in-the-zone")
                ratio.MWYI = ratio.MWYI + 1;
            elseif (VTCdata.MW{i} == "Yes" & VTCdata{i,6+h} == "out-of-the-zone")
                ratio.MWYO = ratio.MWYO + 1;
            elseif (VTCdata.MW{i} == "No"  & VTCdata{i,6+h} == "in-the-zone")
                ratio.MWNI = ratio.MWNI + 1;
            elseif (VTCdata.MW{i} == "No"  & VTCdata{i,6+h} == "out-of-the-zone")
                ratio.MWNO = ratio.MWNO + 1;
            end
            if (VTCdata{i, 6+h} == "out-of-the-zone")
                out_zone_total = out_zone_total + 1;
            elseif (VTCdata{i, 6+h} == "in-the-zone")
                in_zone_total  = in_zone_total + 1;
            end
        end 
       
        disp(sprintf('\n... Doing the final calculation and saving the data to the file...\n'));

        % Row labels for MW2Zone:
        % 1: Mind Wandering - yes; in-the-zone
        % 2: Mind Wandering - yes; out-of-the-zone
        % 3: Mind Wandering - no;  in-the-zone
        % 4: Mind Wandering - no;  out-of-the-zone
        % 5: Percentage of out-of-the-zone vs the total zones
        
        % Store ratio struct values to one table
        
        MW2Zone{mwz+1,1} = {ratio.MWYI};
        MW2Zone{mwz+2,1} = {ratio.MWYO};
        MW2Zone{mwz+3,1} = {ratio.MWNI};
        MW2Zone{mwz+4,1} = {ratio.MWNO};
        MW2Zone{mwz+5,1} = {in_zone_total};
        MW2Zone{mwz+6,1} = {out_zone_total};
        mwz = mwz + 6;
    end
    
    fprintf('... Second cluster is being processed...\n');
    for h = 1:2
        % Store information about subjective MW reports and zone values
        % into struct
        ratio = struct('MWYI', 0, 'MWYM', 0, 'MWYO', 0, 'MWNI', 0, 'MWNM',0,'MWNO', 0);
        out_zone_total = 0;
        in_zone_total  = 0;
        mid_zone_total = 0;
        for i = 1:length(VTCdata{:,1})
            if (isempty(VTCdata.MW{i}))
            elseif (VTCdata.MW{i} == "Yes" & VTCdata{i,8+h} == "in-the-zone")
                ratio.MWYI = ratio.MWYI + 1;
            elseif (VTCdata.MW{i} == "Yes" & VTCdata{i,8+h} == "middle-zone")
                ratio.MWYM = ratio.MWYM + 1;
            elseif (VTCdata.MW{i} == "Yes" & VTCdata{i,8+h} == "out-of-the-zone")
                ratio.MWYO = ratio.MWYO + 1;
            elseif (VTCdata.MW{i} == "No"  & VTCdata{i,8+h} == "in-the-zone")
                ratio.MWNI = ratio.MWNI + 1;
            elseif (VTCdata.MW{i} == "No"  & VTCdata{i,8+h} == "middle-zone")
                ratio.MWNM = ratio.MWNM + 1;
            elseif (VTCdata.MW{i} == "No"  & VTCdata{i,8+h} == "out-of-the-zone")
                ratio.MWNO = ratio.MWNO + 1;
            end
            if (VTCdata{i, 8+h} == "out-of-the-zone")
                out_zone_total = out_zone_total + 1;
            elseif (VTCdata{i, 8+h} == "middle-zone")
                mid_zone_total = mid_zone_total + 1;
            elseif (VTCdata{i, 8+h} == "in-the-zone")
                in_zone_total  = in_zone_total + 1;
            end
        end 
       
        disp(sprintf('\n... Doing the final calculation and saving the data to the file...\n'));

        % Row labels for MW2Zone:
        % 1: Mind Wandering - yes; in-the-zone
        % 2: Mind Wandering - yes; out-of-the-zone
        % 3: Mind Wandering - no;  in-the-zone
        % 4: Mind Wandering - no;  out-of-the-zone
        % 5: Percentage of out-of-the-zone vs the total zones
        
        % Store ratio struct values to one table
        
        MW2Zone{mwz+1,1} = {ratio.MWYI};
        MW2Zone{mwz+2,1} = {ratio.MWYM};
        MW2Zone{mwz+3,1} = {ratio.MWYO};
        MW2Zone{mwz+4,1} = {ratio.MWNI};
        MW2Zone{mwz+5,1} = {ratio.MWNM};
        MW2Zone{mwz+6,1} = {ratio.MWNO};
        MW2Zone{mwz+7,1} = {in_zone_total};
        MW2Zone{mwz+8,1} = {mid_zone_total};
        MW2Zone{mwz+9,1} = {out_zone_total};
        mwz = mwz + 9;
    end
    
    
    % Last row of MW2Zone represents percentage of MW - yes responses of
    % the subject
    disp(MW2Zone);
    %% Ratio data compilation complete - save data to  file
    sumDir = 'some_path\Research\Classified_study_codename II\VTC Analysis\Alpha Phase\VTC Tables with Analysis\'
    FileMWVTC =[sumDir 'Revised_VTC_MW_Match_Data.csv'];
    if exist(FileMWVTC, 'file')
        Add_MWVTC = ([readtable(FileMWVTC)]);
        Add_MWVTC = [Add_MWVTC MW2Zone];
        writetable(Add_MWVTC, FileMWVTC);
    else
        writetable(MW2Zone, FileMWVTC);
    end
   
    
    
    
    