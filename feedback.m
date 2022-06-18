function feedback(hObject,eventdata,handles,text6)
%UNTITLED Summary of this function goes here,
%   Detailed explanation goes here
% % check for image query
% hObject
% guidata(hObject,handles);
siradata=getappdata(0,'siradata');
dataset = getappdata(siradata,'dataset');
guidata(hObject, handles);
% if (isappdata(siradata, 'feedbackdataset'))
%     handles.feedbackdataset=getappdata(siradata,'feedbackdataset');
% else
%     errordlg('FEEDBACK: VUI LONG TAI feedbackdataset !');
%     return;
% end
if (isappdata(siradata, 'numOfReturnedImages'))
    handles.no_of_return_images=getappdata(siradata,'numOfReturnedImages');
else
    errordlg('FEEDBACK: VUI LONG TAI numOfReturnedImages !');
    return;
end


if (isappdata(siradata, 'sortedImgs'))
    handles.sortedImgs=getappdata(siradata,'sortedImgs');
else
    errordlg('FEEDBACK: VUI LONG TAI sortedImgs!');
    return;
end

if (isappdata(siradata, 'checkbox'))
    handles.checkbox=getappdata(siradata,'checkbox');
else
    errordlg('FEEDBACK: VUI LONG CHON checkbox !');
    return;
end

% if (isappdata(siradata, 'feedbackpath'))
%     handles.feedbackpath=getappdata(siradata,'feedbackpath');
% else
%     errordlg('FEEDBACK: VUI LONG TAI feedbackpath !');
%     return;
% end

if (isappdata(siradata, 'dataset'))
    handles.dataset=getappdata(siradata,'dataset');
    %     handles.dataset=datasethandler.dataset;
else
    errordlg('FEEDBACK: FEEDBACK: VUI LONG CAP NHAT TAP DU LIEU !');
    return;
end
if (isappdata(siradata, 'queryimagename') || isappdata(siradata, 'queryimagepath') || isappdata(siradata, 'queryimageext'))
    queryimagename=str2num(getappdata(siradata, 'queryimagename'));
    queryImagepath=getappdata(siradata, 'queryimagepath');
    queryImageext=getappdata(siradata,'queryimageext');
else
    errordlg('FEEDBACK: VUI LONG CAP NHAT TAP DU LIEU !');
    return;
end

tic
% %truyen data feedback
a=handles.imagedataset.dataset;
b={};
data_neg = {};
label = [];
n=0;
% Lay anh tich chon dua vao mang
for m=1:handles.no_of_return_images
    val=get(handles.checkbox(m),'Value');
    x=get(handles.checkbox(m),'string');
    parts = strsplit(x{1}, '/');
    I_name = parts{end};
    if val == 1
        b=[b;I_name(:)];
        n = n + 1;
        label=[label;1];
    else
        data_neg = [data_neg;I_name(:)];
        label=[label;-1];
    end
end

c=[];
name = handles.label_name;
name_data = {};
for i=1:size(name,1)
    spilts= strsplit(name{i,:}, '/');
    name_data{i} = spilts{end};
end
name_data = name_data';
indexes = zeros(size(b,1),1);
for i=1:size(b,1)
    c = ismember(name_data, b{i}');
    indexes(i) = find(c);
end
feedback = a(indexes,:);
d=[];
idx = zeros(size(data_neg,1),1);

for i=1:size(data_neg,1)
    d = ismember(name_data, data_neg{i}');
    idx(i) = find(d);
end
feedback_neg = a(idx,:);
fea = [feedback;feedback_neg];
dataset_image_names = handles.label_name;

label_train = zeros(size(fea,1),1);
label_train(1:size(feedback,1),:) = 1;
fea(:, end) = [];

% doc hinh anh truy van trong tap duu lieu
queryImageFeatureVector = handles.query_image_feature;
query_image_name = handles.query_label_name;
dataset_image_names = handles.label_name;
queryImageFeatureVector(:, end) = [];
dataset(:, end) = [];


%   tìm không gian chiếu - ma trận chiếu W
options.WOptions = [];
options.WOptions.NeighborMode = 'Supervised';
options.WOptions.gnd = label_train;
options.WOptions.WeightMode = 'Binary';
options.WOptions.k = 20;
options.Metric = 'Euclidean';
options.ReducedDim = 40;
W = constructW(fea,options);
[W, eigvalue] = LPP(W, options, fea);
% 


%   

fea1 = fea * W;
data1 = dataset * W;
svm0 = fitcsvm(fea1,label_train,'KernelFunction','rbf','KernelScale','auto','BoxConstraint',100);
[label_svm,Score] = predict(svm0,data1);
[sorted, id] = sortDisImg(dataset, label_svm, Score,name);
sortedImgs = sorted(1:handles.no_of_return_images,2);


% manhattan = zeros(size(dataset, 1), 1);
progress_bar = waitbar(0,'Loading...','Name','SIRA-Vui long cho trong giay lat !','CreateCancelBtn','setappdata(gcbf,''cancel_callback'',1)');
setappdata(progress_bar,'cancel_callback',0);
steps = size(dataset, 1);
% 


delete(progress_bar)
ch='\';
% clear axes
arrayfun(@cla, findall(0, 'type', 'axes'));
arrayfun(@cla, findall(0, 'type', 'checkbox'));
str_name = query_image_name;
query_img = imread( strcat('DataExtract\CorelDB',ch, str_name) );
imshow(query_img, []);
% hien thi anh  returned by query
xaxes=300;
yaxes=500;
cnt=0;
count_pos = 0;
imageitr=1;
for m = 1 : size(sortedImgs)
    img_name = sortedImgs(m);
    img_no = img_name;
     strs = strsplit(img_name{1},'\');
    img_name = strcat(strs{1},ch,strs{2},'.jpg');

        if imageitr <= handles.no_of_return_images
            str_name = strcat('DataExtract/CorelDB',ch, img_name);
            
            returnedImage = imread(str_name);
            ha = axes('Units','Pixels','Position',[xaxes,yaxes,100,100]);
            imshow(returnedImage,[]);
             
            spilts= strsplit(img_name, '\');
            label_returned = spilts{end-1};
            spilts= strsplit(query_image_name, ch);
            label_query = spilts{end-1};
    
            if((strcmp(label_query,label_returned) == 1))
                checkbox(imageitr) = uicontrol('Style','checkbox',...
                                    'string',img_no,'value',1,'tag',sprintf('checkbox%d',imageitr),...
                                    'Position',[xaxes+85 yaxes+85 20 20]);
                count_pos = count_pos + 1;
            else
                checkbox(imageitr) = uicontrol('Style','checkbox',...
                                    'string',img_no,'tag',sprintf('checkbox%d',imageitr),...
                                    'Position',[xaxes+85 yaxes+85 20 20]);
            end
            xaxes = xaxes+110;
            cnt=cnt+1;
            if mod(cnt,7)==0
                yaxes=yaxes-110;
                xaxes=300;
            end
            imageitr=imageitr+1;
        else
            break;
        end
  
end

z = ( count_pos / handles.no_of_return_images ) * 100;
z = num2str(z);
set(handles.text6,'String',[z,'%']);


setappdata(siradata,'no_of_return_images',handles.no_of_return_images);
setappdata(siradata,'sortedImgs',sortedImgs);
setappdata(siradata,'checkbox',checkbox);



% clear('handles.feedbackdataset','feedbackdataset');
% handles.feedbackdataset=handles.sortedImgs;
% % handles.feedbackdataset=handles.feedbackdataset.feedbackdataset;
% setappdata(siradata, 'feedbackdataset',handles.feedbackdataset);
helpdlg('phan hoi lien quan thanh cong !');


% end