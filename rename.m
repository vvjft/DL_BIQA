clear; 
directories = {'jp2k', 'jpeg', 'wn', 'gblur', 'fastfading'};
output_dir = 'distorted_images';
status = mkdir(output_dir);
for dirIdx = 1:length(directories)
    dirName = directories{dirIdx};
    cd(dirName);
    
    fileID = fopen('info.txt', 'r');
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
        if score == 0
            delete(current_name)
            fprintf('Deleted %s\n', current_name);
            continue
            %new_name = [category, '.bmp'];
        else
            counters(category) = counters(category) + 1;
            new_name = [category, '_', num2str(distortion), '_', num2str(counters(category)), '.bmp'];
        end
        % If the new name already exists (which can happen if dmos is 0), add an index to make it unique
        if isfile(new_name)
            counters(category) = counters(category) + 1;
            new_name = [category, '_', num2str(distortion), '_', num2str(counters(category)), '.bmp'];
        end
        %movefile(current_name, new_name);
        status=copyfile(current_name, fullfile('..',output_dir, new_name));
        if status
            fprintf('Renamed %s to %s\n', current_name, new_name);
        else
            fprintf('ERROR: cannot copy %s to %s as %s\n', current_name, fullfile('..',output_dir), new_name);
        end
    end
    cd('..');
end
