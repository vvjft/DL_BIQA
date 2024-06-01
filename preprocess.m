clear;
dmos_data = load('dmos_realigned.mat');
refnames_data = load('refnames_all.mat');

dmos = dmos_data.dmos_new;
refnames_all = refnames_data.refnames_all;
dmos = dmos';
refnames_all = refnames_all';

% Filter out reference images where dmos is 0
filtered_refnames = refnames_all(dmos ~= 0);

num_images = length(refnames_all);
distortion_types = [ones(227, 1); 2*ones(233,1); 3*ones(174,1); 4*ones(174,1); 5*ones(174,1)];
% Ensure distortion_types matches the number of filtered images
distortion_types = distortion_types(1:num_images);

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
    if dmos(i)~=0
        count = image_count(key);
        final_names{i} = sprintf('%s_%d_%d.bmp', base_name, distortion_type, count);
        image_count(key) = count + 1;
    end
end
T=table(final_names, dmos, VariableNames={'image_filename', 'DMOS'});
T(T.DMOS==0,:) = [];
T=sortrows(T);
writetable(T, 'dmos_with_names.csv')