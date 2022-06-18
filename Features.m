function Features(hObject, eventdata, handles, numOfReturnedImages)
% input:
%   numOfReturnedImages : num of images returned by query
%   queryImageFeatureVector: query image in the form of a feature vector
%   dataset: the whole dataset of images transformed in a matrix of
%   features
% 
% output: 
%   plot: plot images returned by query

guidata(hObject, handles);
siradata = getappdata(0, 'siradata');

if (~isfield(handles, 'imagedataset'))
    errordlg('Vui long chon tap du lieu hoac tao ra chung !');
    return;
else
    dataset = getappdata(siradata,'dataset');
end

% if (isappdata(siradata, 'queryimagename'))
%     
%     queryimagename = str2num(getappdata(siradata,'queryimagename'));
% else
%     errordlg('Please select image for search!');
%     return;
% end

% if(isappdata(siradata,'feedbackdataset'))
%     handles.feedbackdataset = getappdata(siradata,'feedbackdataset');
% else
%     if(exist('feedbackdatabase','file')==0)
%         mkdir 'feedbackdatabase';
%         filepath = fileparts('feedbackdatabase/');
%     else
%         filepath = fileparts('feedbackdatabase/');
%     end
%     filepath = fullfile(filepath,strcat('feedback_',getappdata(siradata,'imagedatasetname'),'.mat'));
%     
%     if(exist(filepath,'file') == 0)
%         [rows,cols] = size(dataset);
%         feedbackdataset = int32.empty(rows,0);
%         feedbackdataset(1:rows,1:rows) = 0;
%         save(filepath,'feedbackdataset');
%         clear('feedbackdataset');
%     else
%         fprintf('Database Exist...Loading Dataset...\r\n');
%     end
%     handles.feedbackdataset = load(filepath);
%     handles.feedbackdataset = handles.feedbackdataset.feedbackdataset;
%     guidata(hObject, handles);
%     setappdata(siradata, 'feedbackdataset', handles.feedbackdataset);
%     setappdata(siradata, 'feedbackpath', filepath);
% end    


queryImageFeatureVector = handles.query_image_feature;
% doc hinh anh truy van trong tap duu lieu
query_image_name = handles.query_label_name;
dataset_image_names = handles.label_name;
queryImageFeatureVector(:, end) = [];
dataset(:, end) = [];

manhattan = zeros(size(dataset, 1), 1);
progress_bar = waitbar(0,'Loading...','Name','SIRA-Vui long cho trong giay lat !','CreateCancelBtn','setappdata(gcbf,''cancel_callback'',1)');
setappdata(progress_bar,'cancel_callback',0);
steps = size(dataset, 1);

manhattan = pdist2(queryImageFeatureVector, dataset);
manhattan = manhattan';
% add anh vao mang manhattan
% manhattan = [manhattan];
%%%%%%%%%
% sap xep khoang cach tang dan
[sortedDist indx] = sortrows(manhattan);
dataset_image_names
sortedImgs = dataset_image_names(indx);
delete(progress_bar)
ch = '\';
% clear axes
arrayfun(@cla, findall(0, 'type', 'axes'));
arrayfun(@cla, findall(0, 'type', 'checkbox'));
str_name = query_image_name;

strs = strsplit(query_image_name,ch);
%             str_name = "";
str_name = strcat(pwd,'\DataExtract\CorelDB\', strs{1},ch,strs{2});

query_img = imread(str_name);
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



        if imageitr <= numOfReturnedImages
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

%%% xu ly tinh do chinh xac

z = ( count_pos * 1.0 / handles.no_of_return_images ) * 100;
z = num2str(z);
set(handles.text6,'String',[z,'%']);
setappdata(siradata,'numOfReturnedImages',numOfReturnedImages);
setappdata(siradata,'sortedImgs',sortedImgs);
setappdata(siradata,'checkbox',checkbox);
% setappdata(siradata,'no_cluster',k);
% arrayfun(@cla, findall(0, 'type', 'chekbox'));
btn = uicontrol('Style','pushbutton','String','Feedback',...
                'Position', [1000 17 100 50],...
                'BackgroundColor',[1.0,0.5,0.0],...
                'ForegroundColor',[1.0,1.0,1.0],...
                'Callback', {@feedback,guidata(hObject)});
guidata(hObject,handles);
end