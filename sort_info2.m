% Read the file
file_path = 'info.txt';
file_id = fopen(file_path, 'r');
data = textscan(file_id, '%s %s %f', 'Delimiter', ' ');
fclose(file_id);

% Extract the data into separate variables
first_column = data{1};
second_column = data{2};
third_column = data{3};

% Extract numerical values from the second column for sorting
num_values = regexp(second_column, '\d+', 'match');
num_values = cellfun(@(x) str2double(x{1}), num_values);

% Combine the data into a table for sorting
data_table = table(first_column, second_column, third_column, num_values);

% Sort the table by the numerical values extracted from the second column
sorted_table = sortrows(data_table, 'num_values');

% Write the sorted data back to a new file
sorted_file_path = 'sorted_info.txt';
file_id = fopen(sorted_file_path, 'w');
for i = 1:height(sorted_table)
    fprintf(file_id, '%s %s %.6f\n', sorted_table.first_column{i}, sorted_table.second_column{i}, sorted_table.third_column(i));
end
fclose(file_id);
