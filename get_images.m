clear all
close all
clc

file1 = strcat("Gruppo4\9ms\Cam1\Cam1_0001A.b16");
file2 = strcat("Gruppo4\9ms\Cam2\Cam2_0001A.b16");
imagCam1_filtered = filter_image(file1, [0.001 0.05]);
imagCam2_filtered = filter_image(file2, [0.01 0.45]);
image_filtered = [imagCam2_filtered, imagCam1_filtered];

% Visualizza immagini affiancate
figure() % 1 row, 2 columns, position 1
imshow(imagCam1_filtered, []);
saveas(gca, 'capturedImageC1.jpg','jpg')

figure(); % 1 row, 2 columns, position 2
imshow(imagCam2_filtered, []);
saveas(gca, 'capturedImageC2.jpg','jpg')
