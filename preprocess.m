%% Change 'building2' to 'ocean' (mismatch in orignal info.txt)
file_path = 'wn\info.txt';
file_id = fopen(file_path, 'r');
data = textscan(file_id, '%s %s %f', 'Delimiter', ' ');
fclose(file_id);
first_column = data{1};
if strcmp(first_column{16}, 'building2.bmp')
    first_column{16} = 'ocean.bmp';
end
file_id = fopen(file_path, 'w');
for i = 1:length(first_column)
    fprintf(file_id, '%s %s %.6f\n', first_column{i}, data{2}{i}, data{3}(i));
end
fclose(file_id);
%% Main
clear; 
directories = {'jp2k', 'jpeg', 'wn', 'gblur', 'fastfading'};
output_dir = 'distorted_images';
status = mkdir(output_dir);
save_references = false; % include original images
for dirIdx = 1:length(directories)
    dirName = directories{dirIdx};
    cd(dirName); 
    fileID = fopen('info.txt', 'r');

    if dirIdx == 3 || dirIdx == 4 % only wn and gblur are unsorted
        sort_info('info.txt')
    end

    data = textscan(fileID, '%s %s %f');
    fclose(fileID);
    distortion = dirIdx;
    original_names = data{1};
    current_names = data{2};
    dmos = data{3};
    counters = containers.Map(); % dict to count images in each category
    
    for i = 1:length(original_names)
        category = strtok(original_names{i}, '.');
        current_name = current_names{i};
        score = dmos(i); 
        % Initialize counter for new categories
        if ~isKey(counters, category)
            counters(category) = 0;
        end
        % Determine the new name based on value
        if score == 0 && save_references == false
            delete(current_name)
            fprintf('Deleted %s\n', current_name);
            continue
        else
            counters(category) = counters(category) + 1;
            new_name = [category, '_', num2str(distortion), '_', num2str(counters(category)), '.bmp'];
        end
        % If the new name already exists (which can happen if dmos is 0), add an index to make it unique
        if isfile(new_name)
            counters(category) = counters(category) + 1;
            new_name = [category, '_', num2str(distortion), '_', num2str(counters(category)), '.bmp'];
        end
        status=copyfile(current_name, fullfile('..',output_dir, new_name));
        if status
            fprintf('Renamed %s to %s\n', current_name, new_name);
        else
            fprintf('ERROR: cannot copy %s to %s as %s\n', current_name, fullfile('..',output_dir), new_name);
        end
    end
    cd('..');
end

%% Create dmos_with_names.csv
dmos_data = load('dmos_realigned.mat');
refnames_data = load('refnames_all.mat');

dmos = dmos_data.dmos_new';
refnames_all = refnames_data.refnames_all';
num_images = length(refnames_all);
distortion_types = [ones(227, 1); 2*ones(233,1); 3*ones(174,1); 4*ones(174,1); 5*ones(174,1)];
% Ensure distortion_types matches the number of filtered images
distortion_types = distortion_types(1:num_images);
distortion_name = cell(num_images, 1);

final_names = cell(num_images, 1);
image_count = containers.Map('KeyType', 'char', 'ValueType', 'any');

for i = 1:num_images
    base_name = strtok(refnames_all{i}, '.'); % Extract base name
    distortion_type = distortion_types(i);
    % Initialize counter for this base name and distortion type if not exists
    key = sprintf('%s_%d', base_name, distortion_type);
    if ~isKey(image_count, key)
        image_count(key) = 1;
    end
    % Skip reference images
    if dmos(i) ~= 0 || save_references == true
        count = image_count(key);
        final_names{i} = sprintf('%s_%d_%d.bmp', base_name, distortion_type, count);
        image_count(key) = count + 1;
        distortion_name{i} = directories{distortion_type};
    end
end
T=table(final_names, dmos, distortion_name, VariableNames={'image_filename', 'DMOS', 'Distortion'});
if save_references == false
    T(T.DMOS==0,:) = [];
end
T=sortrows(T);
writetable(T, 'dmos_with_names.csv')

%% Sort by filenames in info.txt
function sort_info(input_file)
    file_id = fopen(input_file, 'r');
    data = textscan(file_id, '%s %s %f', 'Delimiter', ' ');
    fclose(file_id);
    first_column = data{1};
    second_column = data{2};
    third_column = data{3};
    % Extract numerical values from the second column for sorting
    num_values = regexp(second_column, '\d+', 'match');
    num_values = cellfun(@(x) str2double(x{1}), num_values);
    % Combine the data into a table for sorting
    data_table = table(first_column, second_column, third_column, num_values);
    sorted_table = sortrows(data_table, 'num_values');
    % Write the sorted data back to a new file
    file_id = fopen(input_file, 'w');
    for i = 1:height(sorted_table)
        fprintf(file_id, '%s %s %.6f\n', sorted_table.first_column{i}, sorted_table.second_column{i}, sorted_table.third_column(i));
    end
    fclose(file_id);
end