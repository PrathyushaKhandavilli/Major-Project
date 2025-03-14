clc
clear all
close all
warning off
%Creating Database
for numimages=1:20
I = imread(strcat('DATABASE\WITHOUT STONE\',num2str(numimages),'.jpg'));
    figure(1), imshow(I); title('Training Kidney  Image');
In = imresize(I,[256,256]);
I = In;
%figure, imshow(I); title('Query Micro Organism Image');
row=256;
colum=256;
% Enhance Contrast
I = imadjust(I,stretchlim(I));
% Convert to grayscale
gray = rgb2gray(I);
% Otsu Binarization for segmentation
level = graythresh(I);
img = im2bw(I,level);
figure(2), imshow(img);title('Otsu Thresholded Image');


% K means Clustering

cform = makecform('srgb2lab');
% Apply the colorform
lab_he = applycform(I,cform);

% Classify the colors in a*b* colorspace using K means clustering.
% Since the image has 3 colors create 3 clusters.
% Measure the distance using Euclidean Distance Metric.
ab = double(lab_he(:,:,2:3));
nrows = size(ab,1);
ncols = size(ab,2);
ab = reshape(ab,nrows*ncols,2);
nColors = 1;
[cluster_idx cluster_center] = kmeans(ab,nColors,'distance','sqEuclidean', ...
                                      'Replicates',1);
%[cluster_idx cluster_center] = kmeans(ab,nColors,'distance','sqEuclidean','Replicates',3);
% Label every pixel in tha image using results from K means
pixel_labels = reshape(cluster_idx,nrows,ncols);
%figure,imshow(pixel_labels,[]), title('Image Labeled by Cluster Index');

% Create a blank cell array to store the results of clustering
segmented_images = cell(1,3);
% Create RGB label using pixel_labels
rgb_label = repmat(pixel_labels,[1,1,3]);

for k = 1:nColors
    colors = I;
    colors(rgb_label ~= k) = 0;
    segmented_images{k} = colors;
end

%
figure(3), imshow(segmented_images{1});title('Objects in Cluster 1');

%figure, imshow(segmented_images{2});title('Objects in Cluster 2');

seg_img = im2bw(segmented_images{1});
figure(4), imshow(seg_img);title('Segmented Kidney Objects');
%seg_img = img;
% Extract features using DWT
x = double(seg_img);
m = size(seg_img,1);
n = size(seg_img,2);
%signal1 = (rand(m,1));
%winsize = floor(size(x,1));
%winsize = int32(floor(size(x)));
%wininc = int32(10);
%J = int32(floor(log(size(x,1))/log(2)));
%Features = getmswpfeat(signal,winsize,wininc,J,'matlab');

%m = size(img,1);
%signal = rand(m,1);
signal1 = seg_img(:,:);
%Feat = getmswpfeat(signal,winsize,wininc,J,'matlab');
%Features = getmswpfeat(signal,winsize,wininc,J,'matlab');

[cA1,cH1,cV1,cD1] = dwt2(signal1,'db4');
[cA2,cH2,cV2,cD2] = dwt2(cA1,'db4');
[cA3,cH3,cV3,cD3] = dwt2(cA2,'db4');

DWT_feat = [cA3,cH3,cV3,cD3];
G = pca(DWT_feat);
whos DWT_feat
whos G
g = graycomatrix(G);
stats = graycoprops(g,'Contrast Correlation Energy Homogeneity');
Contrast = stats.Contrast;
Correlation = stats.Correlation;
Energy = stats.Energy;
Homogeneity = stats.Homogeneity;
Mean = mean2(G);
Standard_Deviation = std2(G);
Entropy = entropy(G);
RMS = mean2(rms(G));
%Skewness = skewness(img)
Variance = mean2(var(double(G)));
a = sum(double(G(:)));
Smoothness = 1-(1/(1+a));
Kurtosis = kurtosis(double(G(:)));
Skewness = skewness(double(G(:)));
% Inverse Difference Movement
m = size(G,1);
n = size(G,2);
in_diff = 0;
for i = 1:m
    for j = 1:n
        temp = G(i,j)./(1+(i-j).^2);
        in_diff = in_diff+temp;
    end
end
IDM = double(in_diff);
    
WITHOUTSTONE_feat(numimages,:) = [Contrast,Correlation,Energy,Homogeneity, Mean, Standard_Deviation, Entropy, RMS, Variance, Smoothness, Kurtosis, Skewness, IDM];

end


for numimages=21:60
I = imread(strcat('DATABASE\WITH STONE\',num2str(numimages),'.jpg'));
    figure(1), imshow(I); title('Training Kidney Image');
In = imresize(I,[256,256]);
I = In;
%figure, imshow(I); title('Query Micro Organism Image');
row=256;
colum=256;
% Enhance Contrast
I = imadjust(I,stretchlim(I));
% Convert to grayscale
gray = rgb2gray(I);
% Otsu Binarization for segmentation
level = graythresh(I);
img = im2bw(I,level);
figure(2), imshow(img);title('Otsu Thresholded Image');


% K means Clustering

cform = makecform('srgb2lab');
% Apply the colorform
lab_he = applycform(I,cform);

% Classify the colors in a*b* colorspace using K means clustering.
% Since the image has 3 colors create 3 clusters.
% Measure the distance using Euclidean Distance Metric.
ab = double(lab_he(:,:,2:3));
nrows = size(ab,1);
ncols = size(ab,2);
ab = reshape(ab,nrows*ncols,2);
nColors = 1;
[cluster_idx cluster_center] = kmeans(ab,nColors,'distance','sqEuclidean', ...
                                      'Replicates',1);
%[cluster_idx cluster_center] = kmeans(ab,nColors,'distance','sqEuclidean','Replicates',3);
% Label every pixel in tha image using results from K means
pixel_labels = reshape(cluster_idx,nrows,ncols);
%figure,imshow(pixel_labels,[]), title('Image Labeled by Cluster Index');

% Create a blank cell array to store the results of clustering
segmented_images = cell(1,3);
% Create RGB label using pixel_labels
rgb_label = repmat(pixel_labels,[1,1,3]);

for k = 1:nColors
    colors = I;
    colors(rgb_label ~= k) = 0;
    segmented_images{k} = colors;
end

%
figure(3), imshow(segmented_images{1});title('Objects in Cluster 1');

%figure, imshow(segmented_images{2});title('Objects in Cluster 2');

seg_img = im2bw(segmented_images{1});
figure(4), imshow(seg_img);title('Segmented Kidney Objects');
%seg_img = img;
% Extract features using DWT
x = double(seg_img);
m = size(seg_img,1);
n = size(seg_img,2);
%signal1 = (rand(m,1));
%winsize = floor(size(x,1));
%winsize = int32(floor(size(x)));
%wininc = int32(10);
%J = int32(floor(log(size(x,1))/log(2)));
%Features = getmswpfeat(signal,winsize,wininc,J,'matlab');

%m = size(img,1);
%signal = rand(m,1);
signal1 = seg_img(:,:);
%Feat = getmswpfeat(signal,winsize,wininc,J,'matlab');
%Features = getmswpfeat(signal,winsize,wininc,J,'matlab');

[cA1,cH1,cV1,cD1] = dwt2(signal1,'db4');
[cA2,cH2,cV2,cD2] = dwt2(cA1,'db4');
[cA3,cH3,cV3,cD3] = dwt2(cA2,'db4');

DWT_feat = [cA3,cH3,cV3,cD3];
G = pca(DWT_feat);
whos DWT_feat
whos G
g = graycomatrix(G);
stats = graycoprops(g,'Contrast Correlation Energy Homogeneity');
Contrast = stats.Contrast;
Correlation = stats.Correlation;
Energy = stats.Energy;
Homogeneity = stats.Homogeneity;
Mean = mean2(G);
Standard_Deviation = std2(G);
Entropy = entropy(G);
RMS = mean2(rms(G));
%Skewness = skewness(img)
Variance = mean2(var(double(G)));
a = sum(double(G(:)));
Smoothness = 1-(1/(1+a));
Kurtosis = kurtosis(double(G(:)));
Skewness = skewness(double(G(:)));
% Inverse Difference Movement
m = size(G,1);
n = size(G,2);
in_diff = 0;
for i = 1:m
    for j = 1:n
        temp = G(i,j)./(1+(i-j).^2);
        in_diff = in_diff+temp;
    end
end
IDM = double(in_diff);
    
WITHSTONE_feat(numimages,:) = [Contrast,Correlation,Energy,Homogeneity, Mean, Standard_Deviation, Entropy, RMS, Variance, Smoothness, Kurtosis, Skewness, IDM];

end
TRAIN_FEAT=[WITHOUTSTONE_feat;WITHSTONE_feat];

%TEST THE APPICATION
[filename,pathname]=uigetfile('*.*','Pick a MATLAB code file');
filename=strcat(pathname,filename);
a=imread(filename);
imshow(a);test123=a;
a111=a;
In = imresize(I,[256,256]);
I = In;
%figure, imshow(I); title('Query Micro Organism Image');
row=256;
colum=256;
% Enhance Contrast
I = imadjust(I,stretchlim(I));
% Convert to grayscale
gray = rgb2gray(I);
% Otsu Binarization for segmentation
level = graythresh(I);
img = im2bw(I,level);
figure(2), imshow(img);title('Otsu Thresholded Image');


% K means Clustering

cform = makecform('srgb2lab');
% Apply the colorform
lab_he = applycform(I,cform);

% Classify the colors in a*b* colorspace using K means clustering.
% Since the image has 3 colors create 3 clusters.
% Measure the distance using Euclidean Distance Metric.
ab = double(lab_he(:,:,2:3));
nrows = size(ab,1);
ncols = size(ab,2);
ab = reshape(ab,nrows*ncols,2);
nColors = 1;
[cluster_idx cluster_center] = kmeans(ab,nColors,'distance','sqEuclidean', ...
                                      'Replicates',1);
%[cluster_idx cluster_center] = kmeans(ab,nColors,'distance','sqEuclidean','Replicates',3);
% Label every pixel in tha image using results from K means
pixel_labels = reshape(cluster_idx,nrows,ncols);
%figure,imshow(pixel_labels,[]), title('Image Labeled by Cluster Index');

% Create a blank cell array to store the results of clustering
segmented_images = cell(1,3);
% Create RGB label using pixel_labels
rgb_label = repmat(pixel_labels,[1,1,3]);

for k = 1:nColors
    colors = I;
    colors(rgb_label ~= k) = 0;
    segmented_images{k} = colors;
end

%
figure(3), imshow(segmented_images{1});title('Objects in Cluster 1');

%figure, imshow(segmented_images{2});title('Objects in Cluster 2');

seg_img = im2bw(segmented_images{1});
figure(4), imshow(seg_img);title('Segmented Kidney Objects');
%seg_img = img;
% Extract features using DWT
x = double(seg_img);
m = size(seg_img,1);
n = size(seg_img,2);
%signal1 = (rand(m,1));
%winsize = floor(size(x,1));
%winsize = int32(floor(size(x)));
%wininc = int32(10);
%J = int32(floor(log(size(x,1))/log(2)));
%Features = getmswpfeat(signal,winsize,wininc,J,'matlab');

%m = size(img,1);
%signal = rand(m,1);
signal1 = seg_img(:,:);
%Feat = getmswpfeat(signal,winsize,wininc,J,'matlab');
%Features = getmswpfeat(signal,winsize,wininc,J,'matlab');

[cA1,cH1,cV1,cD1] = dwt2(signal1,'db4');
[cA2,cH2,cV2,cD2] = dwt2(cA1,'db4');
[cA3,cH3,cV3,cD3] = dwt2(cA2,'db4');

DWT_feat = [cA3,cH3,cV3,cD3];
G = pca(DWT_feat);
whos DWT_feat
whos G
g = graycomatrix(G);
stats = graycoprops(g,'Contrast Correlation Energy Homogeneity');
Contrast = stats.Contrast;
Correlation = stats.Correlation;
Energy = stats.Energy;
Homogeneity = stats.Homogeneity;
Mean = mean2(G);
Standard_Deviation = std2(G);
Entropy = entropy(G);
RMS = mean2(rms(G));
%Skewness = skewness(img)
Variance = mean2(var(double(G)));
a = sum(double(G(:)));
Smoothness = 1-(1/(1+a));
Kurtosis = kurtosis(double(G(:)));
Skewness = skewness(double(G(:)));
% Inverse Difference Movement
m = size(G,1);
n = size(G,2);
in_diff = 0;
for i = 1:m
    for j = 1:n
        temp = G(i,j)./(1+(i-j).^2);
        in_diff = in_diff+temp;
    end
end
IDM = double(in_diff);
    
Test_feat = [Contrast,Correlation,Energy,Homogeneity, Mean, Standard_Deviation, Entropy, RMS, Variance, Smoothness, Kurtosis, Skewness, IDM];

load('Train_FeatMO.mat')
load('Train_LabelMO.mat')

% Put the test features into variable 'test'
test = Test_feat;
result = cnn(Train_Feat,Train_Label,test);
cnnevaluateperform11;%
a=imread(filename);

b=rgb2gray(test123);
figure;
imshow(b);
impixelinfo;
c=b>20;
figure;
imshow(c);
d=imfill(c,'holes');
figure;
imshow(d);
e=bwareaopen(d,1000);
figure;
imshow(e);
PreprocessedImage=uint8(double(a).*repmat(e,[1 1 3]));
figure;
imshow(PreprocessedImage);
PreprocessedImage=imadjust(PreprocessedImage,[0.3 0.7],[])+50;
figure;
imshow(PreprocessedImage);
uo=rgb2gray(PreprocessedImage);
figure;
imshow(uo);
mo=medfilt2(uo,[5 5]);
figure;
imshow(mo);
po=mo>250;
figure;
imshow(po);
[r c m]=size(po);
x1=r/2;
y1=c/3;
row=[x1 x1+200 x1+200 x1];
col=[y1 y1 y1+40 y1+40];
BW=roipoly(po,row,col);
figure;
imshow(BW);
k=po.*double(BW);
figure;
imshow(k);
M=bwareaopen(k,4);
[ya number]=bwlabel(M);
if(number>=1)
    disp('Stone is Detected');
    if(number<=3)
        disp('Small Stone is Detected');
        helpdlg('Small Stone is Detected');
    elseif(number>4)
        disp('Major Stone is Detected');
        helpdlg('Major Stone is Detected');
    end
else
    disp('No Stone is detected');
end








