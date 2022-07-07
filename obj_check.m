clear all
clc


csv_dir = 'Data/anno_SL';
% save_dir = csv_dir + "_2";
save_dir = csv_dir;

if ~exist(save_dir, 'dir')
    mkdir(save_dir);
end

dir_anno = dir(fullfile(csv_dir, '*.csv'));
[m,n] = size(dir_anno);

for iter_file = 1 : m
    name = split(dir_anno(iter_file).name, ".");       
    anno = dlmread([csv_dir, '/', name{1}, '.csv']);
    temp = anno(2,1);
    [obj, N] = size(anno(:,1));
    obj = obj - 2;
    
    if temp ~= obj
        anno(2,1) = obj;
        disp(strcat(name{1}, " :  ", num2str(temp), "  -->  ", num2str(obj)))
        
        file_name = strcat(save_dir, '\', name{1}, '.csv');
        csvwrite(file_name, anno);
    end    
end
