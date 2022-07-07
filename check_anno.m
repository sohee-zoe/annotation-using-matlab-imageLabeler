clc; clear all;
% close all;
addpath(genpath(pwd));

%% Debug
% 57 line 

%%
anno_dir_n = 'Data/csv_temp';
anno_save_dir = 'Data/csv';
% img_dir_n = 'img';
img_dir_n = 'Data/img';

if ~exist(anno_save_dir, 'dir')
    mkdir(anno_save_dir);
end

dir_anno = dir(fullfile(anno_dir_n, '*.csv'));
dir_img = dir(fullfile(img_dir_n, '*.jpg'));
[m,n] = size(dir_anno);
for iter_file = 1 : m
    anno = [];
    name = split(dir_anno(iter_file).name, ".");

    img = imread([img_dir_n, '/', name{1}, '.jpg']);
    imshow(img), hold on;
    
    anno = dlmread([anno_dir_n, '/', name{1}, '.csv']);
    
    temp=anno(1,1);
    anno(1,1)=anno(1,2);
    anno(1,2)=temp;
    
    for iter_obj = 1:anno(2,1)

        num = anno(2,1);
        c = rand(1, 3);
                
        rectangle('Position',...
            [anno(iter_obj+2,1), anno(iter_obj+2,2),...
            anno(iter_obj+2,3)-anno(iter_obj+2,1)+1,...
            anno(iter_obj+2,4)-anno(iter_obj+2,2)+1],...
            'EdgeColor', c, 'LineWidth', 2);
                
        xt = [anno(iter_obj+2,1)+10];
        yt = [anno(iter_obj+2,2)];
        str = mat2str(anno(iter_obj+2, 5));        
        text(xt,yt,str,'FontSize', 15, 'Fontweight', 'bold', 'Color', 'g')
        text(390, 530, mat2str(name{1}), 'FontSize', 20, 'Fontweight', 'bold', 'Color', 'r')    % 이미지 번호
        text(490, 530, mat2str(anno(2,1)), 'FontSize', 20, 'Fontweight', 'bold', 'Color', 'r')  % 객체 수
        file_n = strcat(num2str(iter_file), "  /  ", num2str(m))
        text(10, 530, file_n, 'FontSize', 20, 'Fontweight', 'bold', 'Color', 'k') 
    end
    hold off;
    
    disp(['F5 ==> save   ', name{1}, '.csv']);
    csvwrite([anno_save_dir, '\', name{1}, '.csv'], anno);
% 
%     if iter_file <= 323
%         continue
%     else
%         csvwrite([anno_save_dir, '\', name{1}, '.csv'], anno);
%     end
    
    clear anno;
end