function [out] = proposed_cluster_adaptive(he)

cform = makecform('srgb2lab');
lab_he = applycform(he,cform);
ab = double(lab_he(:,:,2:3));
nrows = size(ab,1);
ncols = size(ab,2);
ab = reshape(ab,nrows*ncols,2);
nColors = 3;
[cluster_idx, cluster_center] = kmeans(ab,nColors);
pixel_labels = reshape(cluster_idx,nrows,ncols);
% subplot(3, 3, 2);
% imshow(pixel_labels,[]), title('image labeled by cluster index');
segmented_images = cell(1,3);
rgb_label = repmat(pixel_labels,[1 1 3]);
for k = 1:nColors
	color = he;
	color(rgb_label ~= k) = 0;
	segmented_images{k} = color;
end
figure(2)
subplot(1, 3,1);
imshow(segmented_images{1}), title('objects in cluster 1');
subplot(1, 3, 2);
imshow(segmented_images{2}), title('objects in cluster 2');
subplot(1, 3, 3);
imshow(segmented_images{3}), title('objects in cluster 3');
x=input('enter image cluster number=');

out=segmented_images{x};
end