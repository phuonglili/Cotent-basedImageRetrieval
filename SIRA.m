function varargout = SIRA(varargin)
% SIRA MATLAB code for SIRA.fig
%      SIRA, by itself, creates a new SIRA or raises the existing
%      singleton*.
%      H = SIRA returns the handle to a new SIRA or the handle to
%      the existing singleton*.
%      SIRA('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SIRA.M with the given input arguments.
%      SIRA('Property','Value',...) creates a new SIRA or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SIRA_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SIRA_OpeningFcn via varargin.
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SIRA

% Last Modified by GUIDE v2.5 19-Jul-2020 00:43:08

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SIRA_OpeningFcn, ...
                   'gui_OutputFcn',  @SIRA_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end


% End initialization code - DO NOT EDIT


% --- Executes just before SIRA is made visible.
function SIRA_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SIRA (see VARARGIN)

% Choose default command line output for SIRA
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);

setappdata(0, 'siradata', gcf);

% UIWAIT makes SIRA wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = SIRA_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structurehh
%                                                                                                                       b                                     .
varargout{1} = handles.output;


% --- Executes on button press in btn_selectImage.
function btn_selectImage_Callback(hObject, eventdata, handles)
% hObject    handle to btn_selectImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


siradata = getappdata(0, 'siradata');

 startingFolder = 'Data\';
 defaultFileName = fullfile(startingFolder, '*.jpg; *.png; *.bmp');
% [baseFileName, folder] = uigetfile(defaultFileName, 'Select a file');

[query_filename, query_pathname] = uigetfile(defaultFileName, 'Select Query Image');

if(query_filename ~= 0)
    query_fullpath = strcat(query_pathname,query_filename);
    [pathstr, name, ext] = fileparts(query_fullpath);    
    if(strcmp(lower(ext), '.jpg') == 1 || strcmp(lower(ext), '.png') == 1 || strcmp(lower(ext), '.bmp') == 1)
        query_image = imread( fullfile(pathstr, strcat(name,ext)));      
        setappdata(siradata, 'queryimagename', name);
        setappdata(siradata, 'queryimagepath', pathstr);
        setappdata(siradata, 'queryimageext', ext); 
       
        query_image = imresize(query_image, [227 227]);
     
        axes(handles.axes_query_image);     
        guidata(hObject, handles);
        imshow(query_image);
        
        
        color_moments = colorMoments(query_image);
        
        hsv_histogram = hsvHistogram(query_image);
        
        auto_correlogram = colorAutoCorrelogram(query_image);
        
        % for gabor filters we need gary scale image
        img = double(rgb2gray(query_image))/255;
        [mean_amplitude, ms_energy] = gaborWavelet(img, 4, 6); % 4 = number of scales, 6 = number of orientations
        
        wavelet_moments = waveletTransform(query_image);
        
        query_image_feature = [hsv_histogram auto_correlogram color_moments mean_amplitude ms_energy wavelet_moments str2double(name)];
%         [color_moments auto_correlogram hsv_histogram mean_amplitude ms_energy wavelet_moments str2double(name)];
%         max = load('max_norm_feaData.mat');
%         query_image_feature(:,97:126) =query_image_feature(:,97:126)./max.ans(:,97:126);
%         query_image_feature(:,151:190) =query_image_feature(:,151:190)./max.ans(:,151:190);
        handles.query_image_feature = query_image_feature;
        label_name = load('DataExtract/190d/label_name.mat');
        ch = '\';
        parts = strsplit(pathstr, ch);
        DirPart = parts{end};
        Q_name = strcat(DirPart,ch,name, ext);
        handles.label_name = label_name.ans;
        handles.query_label_name = Q_name;
        guidata(hObject, handles);
        
        helpdlg('Nhan Tra cuu de hien thi anh ket qua !');
        
        clear('query_filename', 'query_pathname', 'query_fullpath', 'pathstr', 'name', 'ext',...
            'mean_amplitude', 'ms_energy', 'img', 'auto_correlogram', 'query_image', 'color_moments', 'hsv_Histogram',...
            'wavelet_moments','query_image_feature');
    else
        errordlg('Ban da chon sai dinh dang !');
    end
else
    return;
end

% --- Executes on button press in btn_LoadDataBase.
function btn_LoadDataBase_Callback(hObject, eventdata, handles)
% hObject    handle to btn_LoadDataBase (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
siradata = getappdata(0,'siradata');
[filename,pathname] = uigetfile('*.mat','Select the Dataset');
if(filename ~= 0)
    database_fullpath = strcat(pathname,filename);
    [pathstr, name, ext] = fileparts(database_fullpath);
    if(strcmp(lower(ext),'.mat')==1)
        filename = fullfile(pathstr,strcat(name,ext));
        handles.imagedataset = load(filename);
        guidata(hObject, handles);
        setappdata(siradata,'imagedatasetname',name);
        setappdata(siradata,'dataset',handles.imagedataset.dataset);
        guidata(hObject, handles);
        helpdlg('Xac nhan tap du lieu');
    else
        errordlg('Vui long chon tap du lieu cua ban !');
    end
else
    return;
end;   

% --- Executes on button press in btn_CreateDatabase.
function btn_CreateDatabase_Callback(hObject, eventdata, handles)
% hObject    handle to btn_CreateDatabase (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
folder_name = uigetdir(pwd,'Chon tap du lieu');
if( folder_name ~= 0 )
    handles.folder_name = folder_name;
    guidata(hObject,handles);
else
    errordlg('Hay chon tap du lieu !');
    return;
end
png_images_dir = fullfile(handles.folder_name,'*.png');
bmp_images_dir = fullfile(handles.folder_name,'*.bmp');
jpg_images_dir = fullfile(handles.folder_name,'*.jpg');

no_of_png_images = numel(dir(png_images_dir));
no_of_bmp_images = numel(dir(bmp_images_dir));
no_of_jpg_images = numel(dir(jpg_images_dir));
total_images = no_of_png_images + no_of_bmp_images + no_of_jpg_images;

jpg_files = dir(jpg_images_dir);
bmp_files = dir(bmp_images_dir);
png_files = dir(png_images_dir);

if( ~isempty (jpg_files) || ~isempty (bmp_files) || ~isempty (png_files) )
    jpg_count = 0;
    png_count = 0;
    bmp_count = 0;
    progress_bar = waitbar(0,'Loading...','Name','SIRA-Vui long cho trong giay lat !','CreateCancelBtn','setappdata(gcbf,''cancel_callback'',1)');
    setappdata(progress_bar,'cancel_callback',0);
    steps = total_images;
    for k=1:total_images
        
        if getappdata(progress_bar,'cancel_callback')
            break;
        end
        waitbar(k/steps,progress_bar,sprintf('Loading...%.2f%%',k/steps*100));
        if( (no_of_jpg_images - jpg_count) > 0)
            jpg_img_info = imfinfo(fullfile(handles.folder_name, jpg_files(jpg_count+1).name));
            if( strcmp (lower(jpg_img_info.Format), 'jpg') == 1)
                sprintf('%s \n',jpg_files(jpg_count+1).name)
                image = imread(fullfile(handles.folder_name, jpg_files(jpg_count+1).name));
                [pathstr, name, txt] = fileparts(fullfile(handles.folder_name, jpg_files(jpg_count+1).name));
                image = imresize(image, [400 400]);
            end
            jpg_count = jpg_count + 1;
        elseif( (no_of_png_images - png_count) > 0)
            png_img_info = imfinfo(fullfile(handles.folder_name, png_files(png_count+1).name));
            if( strcmp (lower(png_img_info.Format), 'png') == 1)
                sprintf('%s \n',png_files(png_count+1).name)
                image = imread(fullfile(handles.folder_name, png_files(jpg_count+1).name));
                [pathstr, name, txt] = fileparts(fullfile(handles.folder_name, png_files(png_count+1).name));
                image = imresize(image, [400 400]);
            end
            png_count = png_count + 1;
        elseif( (no_of_bmp_images - bmp_count) > 0)
            bmp_img_info = imfinfo(fullfile(handles.folder_name, bmp_files(bmp_count+1).name));
            if( strcmp (lower(bmp_img_info.Format), 'bmp') == 1)
                sprintf('%s \n',bmp_files(bmp_count+1).name)
                image = imread(fullfile(handles.folder_name, bmp_files(bmp_count+1).name));
                [pathstr, name, txt] = fileparts(fullfile(handles.folder_name, bmp_files(jpg_count+1).name));
                image = imresize(image, [400 400]);
            end
            bmp_count = bmp_count + 1;
        end
        
        color_moments = colorMoments(image);
        
        auto_correlogram = colorAutoCorrelogram(image);
        
        hsv_histogram = hsvHistogram(image);
        
        % for gabor filters we need gary scale image
        img = double(rgb2gray(image))/255;
        [mean_amplitude, ms_energy] = gaborWavelet(img, 4, 6); % 4 = number of scales, 6 = number of orientations
        
        wavelet_moments = waveletTransform(image);
        
        %tim hieu 190 chieu 
        set = [color_moments auto_correlogram hsv_histogram mean_amplitude ms_energy wavelet_moments];

        dataset(k, :) = [set str2num(name)];
        
        clear('image','img','color_moments','auto_correlogram','hsv_histogram',...
            'mean_amplitude', 'ms_energy', 'wavelet_moments','set','jpg_img_info',...
           'png_img_info','bmp_img_info');
    end
    delete(progress_bar);
    uisave('dataset','dataset1');
    clear('dataset','jpg_count','png_count','bmp_count');
end    


% --- Executes on selection change in popupmenu_no_of_return_images.
function popupmenu_no_of_return_images_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_no_of_return_images (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_no_of_return_images contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_no_of_return_images

handles.no_of_return_images = get(handles.popupmenu_no_of_return_images, 'Value');
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popupmenu_no_of_return_images_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_no_of_return_images (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in popupmenu_select_feature.
function popupmenu_select_feature_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_select_feature (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_select_feature contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_select_feature

handles.select_feature = get(handles.popupmenu_select_feature, 'Value');
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popupmenu_select_feature_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_select_feature (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in btn_search.
function btn_search_Callback(hObject, eventdata, handles)
% hObject    handle to btn_search (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
tic
if (~isfield(handles,'query_image_feature'))
    errordlg('Hay chon anh ban can tra cuu !');
    return;
end
metric = 'manhatan';
if (~isfield(handles, 'select_feature') && ~isfield(handles, 'no_of_return_images'))
    images = get(handles.popupmenu_no_of_return_images, 'Value');
elseif (~isfield(handles, 'select_feature') || ~isfield(handles, 'no_of_return_images'))
    if (~isfield(handles, 'select_feature'))
        images = handles.no_of_return_images;
    else
        images = get(handles.popupmenu_no_of_return_images, 'Value');
    end
else
    images = handles.no_of_return_images;
end
% ab = str2double(images);
% disp(ab);
%disp(images);
%cla(axes_result_images, 'reset');
%arrayfun(@cla, findall(0, 'type', 'axes'));
%axes(handles.axes_result_images);

Features(hObject,eventdata,handles,images);
%% Features(images, handles.query_image_feature ,handles.imagedataset.dataset, metric,handles,hObject);
%axes(handles.axes_result_images);
guidata(hObject, handles);

toc

% --- Executes during object creation, after setting all properties.
function axes_query_image_CreateFcn(hObject, eventdata, handles)
% hObject handlex to popupmenu_select_feature (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% --- Executes during object creation, after setting all properties.
function btn_CreateDatabase_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_select_feature (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on selection change in no_cluster.
function no_cluster_Callback(hObject, eventdata, handles)
% hObject    handle to no_cluster (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns no_cluster contents as cell array
%        contents{get(hObject,'Value')} returns selected item from no_cluster


% --- Executes during object creation, after setting all properties.
function no_cluster_CreateFcn(hObject, eventdata, handles)
% hObject    handle to no_cluster (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
