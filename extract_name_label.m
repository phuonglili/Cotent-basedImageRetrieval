function extract_name_label(dataset)

%dataset 2
data = load('DataExtract/190d/31695_data_full_norm.mat');
data = data.data;
label_data = load('DataExtract/190d/31695_data_full_label.mat');
label_data = label_data.name;
rootFolder = fullfile('/Volumes/Datas/NCS Project/DataSet/Corel30K/corel30k_db/', 'Data/');



dirinfo = dir(rootFolder);
tf = ismember( {dirinfo.name}, {'.', '..'});
dirinfo(tf) = [];
categories = {dirinfo.name};
%%
% Create an |ImageDatastore| to help you manage the data.
imds = imageDatastore(fullfile(rootFolder, categories), 'LabelSource', 'foldernames');

% sum the number of images per category.
tbl = countEachLabel(imds);
% Set the ImageDatastore ReadFcn
imds.ReadFcn = @(filename)readAndPreprocessImage(filename);
totalImages = sum(tbl.Count);
a=2;b=2;c=2;
numReturn = 100;
for k = 1:totalImages
        Filename = imds.Files{k};
        [pathstr, name1, ext] = fileparts(fullfile(Filename)); 
        name{k} = strcat(name1, ext);    
end
ka=2;

%%
% Note that other CNN models will have different input size constraints,
% and may require other pre-processing steps.
 
function Iout = readAndPreprocessImage(filename)

    I = imread(filename);

    if ismatrix(I)
        I = cat(3,I,I,I);
    end

    Iout = imresize(I, [227 227]);  

end
end