%% Bin into in, middle, and out zones.
%
% Data processed to investigate whether having a 'buffer' reaction time for
% in-the-zone and out-of-the-zone is useful
% Script partitions set of RTs into three zones based on VTC
% RT data binned into three categories of: in-the-zone, middle-zone,
% out-of-the-zone. Match the classification of the RTs to accuracy and
% other objective measures
%
function [three_bins] = divideToThree(subjID, nprompts)
    %% retrieve file information
    disp(sprintf('\n ... Open and save the file...\n'));
    
    fileDest = '\\Directory_path_hass_been_edited_for_privacy_reasons\Research\Classified_study_codename II\VTC Analysis\Alpha Phase\VTC Tables\'; 
    cd(fileDest);
    
    if ~exist('subjID', 'var')
        subjID = input('Enter participant ID: ', 's');
    end
    
    disp(sprintf('... Getting gender task data ... \n'));
    genderData = readtable([fileDest 'Classified_study_codename_' subjID '_VTC_gender_task_data.csv']);
    sortedData = table(genderData.Face_ID(:), genderData.VTC(:), 'VariableNames', {'Face_ID', 'sortedVTC'});
    
    %% sort VTC in ascending order and finalize 
    fprintf('... Sorting VTC in ascending order...\n');
    sortedData = sortrows(sortedData,2);
    
    col        = cell(length(sortedData{:,1}),1);
    colSort    = cell2table(col, 'VariableNames', {'Tri_Zone'});
    genderData = [genderData colSort];
    
    third     = round(length(sortedData{:,1})/3);
    one = 0;
    two = 0;
    three = 0;
    
    fprintf('... Inputting VTC sorted data into original table...\n');
    for i = 1:length(genderData{:,1})
        for j = 1:length(sortedData{:,1})
            if genderData.Face_ID(i) == sortedData.Face_ID(j)
                if j <= third
                    genderData.Tri_Zone{i} = 'in-the-zone';
                    one = one + 1;
                elseif j <= third*2+1
                    genderData.Tri_Zone{i} = 'middle-zone';
                    two = two + 1;
                else
                    genderData.Tri_Zone{i} = 'out-of-the-zone';
                    three = three + 1;
                end
            end
        end
    end
    disp(one)
    disp(two)
    disp(three)
    
    %% Binning by standard deviation
    fprintf('... Initiating binning by standard deviation...\n');
    
    first_std   = .4307;
    second_std  = .9674;
   
    colStd    = cell2table(col, 'VariableNames', {'SD_Tri_Zone'});
    genderData = [genderData colStd];
    
    in  = 0;
    mid = 0;
    out = 0;
    for i = 1:length(genderData{:,1})
        if genderData.VTC(i) <= first_std
            genderData.SD_Tri_Zone{i} = 'in-the-zone';
            in = in + 1;
        elseif genderData.VTC(i) <= second_std
            genderData.SD_Tri_Zone{i} = 'middle-zone';
            mid = mid + 1;
        else 
            genderData.SD_Tri_Zone{i} = 'out-of-the-zone';
            out = out + 1;
        end
    end
    
    disp(genderData);
    
    disp(in);
    disp(mid);
    disp(out);
    
    %% Save files
    fprintf('... Saving data to original file...\n');
    VTCUpdate = [fileDest 'Classified_study_codename_' subjID '_VTC_gender_task_data.csv']
   
    writetable(genderData, VTCUpdate);
   
    
            
    
    