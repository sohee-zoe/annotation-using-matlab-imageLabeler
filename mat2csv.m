clear all;
clc

%% Setting

img_old = '소희/image';     % 기존 이미지 폴더

load('LabelData.mat');      % labeled mat file

start_n = 3617;             % 이미지 시작 번호

start_n = start_n - 1;


%% Save csv (xywh ver)
disp("========  save csv (xywh)  ========")

csv_dir = 'Data/csv_xywh/temp';
% csv_dir = 'csv';
if ~exist(csv_dir, 'dir')
    mkdir(csv_dir);
end


LabelData = gTruth.LabelData;

cls = LabelData.Properties.VariableNames;
[cls, idx] = natsort(cls(:));
LabelData = LabelData(:,idx);
data = LabelData.Variables; % (img, cls)      % == % LData = LabelData{:,:};
data= data';        % (cls,img) (18 * 1200)
[m, n] = size(data);

% data         [x,y,width,height] 
%                 img1    img2    img3     ...
% class1      (1,1)     (1,2)     (1,3)
% class2      (2,1)     (2,2)     (2,3)
%   ...

for idx_cls = 1 : m
    for idx_img = 1 : n
        [M, N] = size(data{idx_cls, idx_img});
        csv_data = zeros(M, N+3);
        csv_data(:, 1:N) = data{idx_cls, idx_img};  
        csv_data(:, 5) = idx_cls;
%         disp(['class', num2str(idx_cls), '_img', num2str(idx_img)]);
        name_n = idx_img + start_n;
        save_dir = [csv_dir, '/img', num2str(name_n)];
        if ~exist(save_dir, 'dir')
            mkdir(save_dir);
        end
        csvwrite([save_dir, '/', 'class', num2str(idx_cls), '_img', num2str(name_n), '.csv'], csv_data);        
    end
end




%% Merge csv 
disp("========  merge csv  ========")

save_dir = 'Data/csv_xywh/merge';
if ~exist(save_dir, 'dir')
    mkdir(save_dir);
end

F = dir(csv_dir);
[FM,FN] = size([F(:).isdir]);
FN = FN-2;

for i = 1:FN
    P = ['Data/csv_xywh/temp/img', num2str(i+start_n)]; % put the path where the files are!    
    S = dir(fullfile(P,'*.csv'));
    N = numel(S);
    C = cell(1,N);
    
    name = struct2cell(S);
    name = name(1,:)';
    name = natsort(name(:));

    for k = 1 : N
        F = fullfile(P,name(k));
        F = char(F);
        t = load(F);
        [m, n] = size(t);
        
        if m == 0
            continue
        else
            C{k} = csvread(F);
        end
        %
    end
    mat = vertcat(C{:});
    
    csvwrite([save_dir, '/', 'img', num2str(i+start_n), '.csv'], mat);
    
%     disp(['save img', num2str(i)]);
end   


%% Convert xywh --> sx sy ex ey
disp("========  convert csv  ========")

csv_dir = 'Data/csv_temp';
old_dir = 'Data/csv_xywh/merge';

if ~exist(csv_dir, 'dir')
    mkdir(csv_dir);
end

mnc = [512 512 3 0 0 0 0];

S = dir(fullfile(old_dir, '*.csv'));
N = numel(S);
C = cell(1,N);

name = struct2cell(S);
name = name(1,:)';
name = natsort(name(:));

for k = 1 : N
    F = fullfile(old_dir,name(k));
    F = char(F);
    t = load(F);
    [m, n] = size(t);
    
    if m == 0
        continue
    else
        C{k} = csvread(F);
    end
end

C = C';
t = find(~cellfun(@isempty,C));
[m, n] = size(t);

img_dir = 'Data/img'; 

if ~exist(img_dir, 'dir')
    mkdir(img_dir);
end

disp("========  copyfile  ========")
for i = 1 : m
    nn = t(i);
    cc = C{nn};
    [obj_n, rows] = size(cc);
    obj = [obj_n 0 0 0 0 0 0];
    
    x = cc(:,1);
    y = cc(:,2);
    w = cc(:,3);
    h = cc(:,4);
    ex = x + w - 1;
    ey = y + h - 1;
    
    if ex > 512 
        ex = 512; 
    end
    
    if ey > 512
        ey = 512;
    end
    
    cc(:,3) = ex;
    cc(:,4) = ey;
    newC = [mnc; obj; cc];
        
    ns = nn+start_n;      
    csv_name = fullfile(csv_dir, sprintf('%04d.csv', ns));
    csvwrite(csv_name, newC);
    
    img_name = fullfile(img_old, sprintf( '%04d.jpg', ns ) );
    re_img_name = split(img_name, "\");
    re_img = fullfile(img_dir,  re_img_name{end});
    copyfile(img_name, re_img);
end


%% Function

function [X,ndx,dbg] = natsort(X,rgx,varargin)

%% Input Wrangling %%
%
assert(iscell(X),'First input <X> must be a cell array.')
tmp = cellfun('isclass',X,'char') & cellfun('size',X,1)<2 & cellfun('ndims',X)<3;
assert(all(tmp(:)),'First input <X> must be a cell array of char row vectors (1xN char).')
%
if nargin<2 || isnumeric(rgx)&&isempty(rgx)
    rgx = '\d+';
else
    assert(ischar(rgx)&&ndims(rgx)<3&&size(rgx,1)==1,...
        'Second input <rgx> must be a regular expression (char row vector).') %#ok<ISMAT>
end
%
% Optional arguments:
tmp = cellfun('isclass',varargin,'char') & cellfun('size',varargin,1)<2 & cellfun('ndims',varargin)<3;
assert(all(tmp(:)),'All optional arguments must be char row vectors (1xN char).')
% Character case:
ccm = strcmpi(varargin,'matchcase');
ccx = strcmpi(varargin,'ignorecase')|ccm;
% Sort direction:
sdd = strcmpi(varargin,'descend');
sdx = strcmpi(varargin,'ascend')|sdd;
% Char/num order:
chb = strcmpi(varargin,'char<num');
chx = strcmpi(varargin,'num<char')|chb;
% NaN/num order:
nab = strcmpi(varargin,'NaN<num');
nax = strcmpi(varargin,'num<NaN')|nab;
% SSCANF format:
sfx = ~cellfun('isempty',regexp(varargin,'^%([bdiuoxfeg]|l[diuox])$'));
%
nsAssert(1,varargin,sdx,'Sort direction')
nsAssert(1,varargin,chx,'Char<->num')
nsAssert(1,varargin,nax,'NaN<->num')
nsAssert(1,varargin,sfx,'SSCANF format')
nsAssert(0,varargin,~(ccx|sdx|chx|nax|sfx))
%
% SSCANF format:
if nnz(sfx)
    fmt = varargin{sfx};
    if strcmpi(fmt,'%b')
        cls = 'double';
    else
        cls = class(sscanf('0',fmt));
    end
else
    fmt = '%f';
    cls = 'double';
end
%
%% Identify Numbers %%
%
[mat,spl] = regexpi(X(:),rgx,'match','split',varargin{ccx});
%
% Determine lengths:
nmx = numel(X);
nmn = cellfun('length',mat);
nms = cellfun('length',spl);
mxs = max(nms);
%
% Preallocate arrays:
bon = bsxfun(@le,1:mxs,nmn).';
bos = bsxfun(@le,1:mxs,nms).';
arn = zeros(mxs,nmx,cls);
ars =  cell(mxs,nmx);
ars(:) = {''};
ars(bos) = [spl{:}];
%
%% Convert Numbers to Numeric %%
%
if nmx
    tmp = [mat{:}];
    if strcmp(fmt,'%b')
        tmp = regexprep(tmp,'^0[Bb]','');
        vec = cellfun(@(s)sum(pow2(s-'0',numel(s)-1:-1:0)),tmp);
    else
        vec = sscanf(sprintf(' %s',tmp{:}),fmt);
    end
    assert(numel(vec)==numel(tmp),'The %s format must return one value for each input number.',fmt)
else
    vec = [];
end
%
%% Debugging Array %%
%
if nmx && nargout>2
    dbg = cell(mxs,nmx);
    dbg(:) = {''};
    dbg(bon) = num2cell(vec);
    dbg = reshape(permute(cat(3,ars,dbg),[3,1,2]),[],nmx).';
    idf = [find(~all(cellfun('isempty',dbg),1),1,'last'),1];
    dbg = dbg(:,1:idf(1));
else
    dbg = {};
end
%
%% Sort Columns %%
%
if ~any(ccm) % ignorecase
    ars = lower(ars);
end
%
if nmx && any(chb) % char<num
    boe = ~cellfun('isempty',ars(bon));
    for k = reshape(find(bon),1,[])
        ars{k}(end+1) = char(65535);
    end
    [idr,idc] = find(bon);
    idn = sub2ind(size(bon),boe(:)+idr(:),idc(:));
    bon(:) = false;
    bon(idn) = true;
    arn(idn) = vec;
    bon(isnan(arn)) = ~any(nab);
    ndx = 1:nmx;
    if any(sdd) % descending
        for k = mxs:-1:1
            [~,idx] = sort(nsGroup(ars(k,ndx)),'descend');
            ndx = ndx(idx);
            [~,idx] = sort(arn(k,ndx),'descend');
            ndx = ndx(idx);
            [~,idx] = sort(bon(k,ndx),'descend');
            ndx = ndx(idx);
        end
    else % ascending
        for k = mxs:-1:1
            [~,idx] = sort(ars(k,ndx));
            ndx = ndx(idx);
            [~,idx] = sort(arn(k,ndx),'ascend');
            ndx = ndx(idx);
            [~,idx] = sort(bon(k,ndx),'ascend');
            ndx = ndx(idx);
        end
    end
else % num<char
    arn(bon) = vec;
    bon(isnan(arn)) = ~any(nab);
    if any(sdd) % descending
        [~,ndx] = sort(nsGroup(ars(mxs,:)),'descend');
        for k = mxs-1:-1:1
            [~,idx] = sort(arn(k,ndx),'descend');
            ndx = ndx(idx);
            [~,idx] = sort(bon(k,ndx),'descend');
            ndx = ndx(idx);
            [~,idx] = sort(nsGroup(ars(k,ndx)),'descend');
            ndx = ndx(idx);
        end
    else % ascending
        [~,ndx] = sort(ars(mxs,:));
        for k = mxs-1:-1:1
            [~,idx] = sort(arn(k,ndx),'ascend');
            ndx = ndx(idx);
            [~,idx] = sort(bon(k,ndx),'ascend');
            ndx = ndx(idx);
            [~,idx] = sort(ars(k,ndx));
            ndx = ndx(idx);
        end
    end
end
%
ndx  = reshape(ndx,size(X));
X = X(ndx);
%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%natsort
function nsAssert(val,inp,idx,varargin)
% Throw an error if an option is overspecified.
if nnz(idx)>val
    tmp = {'Unknown input arguments',' option may only be specified once. Provided inputs'};
    error('%s:%s',[varargin{:},tmp{1+val}],sprintf('\n''%s''',inp{idx}))
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%nsAssert
function grp = nsGroup(vec)
% Groups of a cell array of strings, equivalent to [~,~,grp]=unique(vec);
[vec,idx] = sort(vec);
grp = cumsum([true,~strcmp(vec(1:end-1),vec(2:end))]);
grp(idx) = grp;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%nsGroup
