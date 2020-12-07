% CIS*6320 Image Processing Algorithm Assignment 2
% Created by Shanhong Liu, Student number: 1110595
% Date: 06/12/2020
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all;

% read the data, either with csv method or load method
% X = readmatrix('Data\bm_29112020\originalImgData.csv');
% Y = readmatrix('Data\bm_29112020\ImgLabel.csv');

% uncomment to load the dataset you want for classification
% load('Data\bm_29112020\originalImgData.mat');
% load('Data\bm_29112020\enhancedImgData.mat');


% split the data into training and testing (80-20)
totalData = length(Y);
maskPoints = randsample(totalData, floor(0.8 * totalData));
xTrain = X(maskPoints,:);
yTrain = Y(maskPoints);

noMaskPoints = [1:totalData]';
noMaskPoints(maskPoints) = [];
xTest = X(noMaskPoints,:);
yTest = Y(noMaskPoints,:);


knnMDL = fitcknn(xTrain,yTrain);

% Cross validate the KNN classifier using the default 10-fold cross validation. Examine the classification error.
% rng(1); % For reproducibility
% CVKNNMdl = crossval(knnMDL);
% classError = kfoldLoss(CVKNNMdl)


[yPredict,score,cost] = predict(knnMDL,xTest(1:100,:));


