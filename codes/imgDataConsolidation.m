% CIS*6320 Image Processing Algorithm Assignment 2
% Created by Shanhong Liu, Student number: 1110595
% Date: 06/12/2020
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% consolidate the data into csv format for the original image data
X = [];  % to store the image data
F = [];  % to store the HOG feature vector
Y = [];  % to store the label
for class = 1:10
    % get the images in each class
    classFolder = strcat('Data\bm_29112020\OriginalResize\class', num2str(class), '\');
    a = dir(classFolder);
    
    for i = 1:length(a)
        if (a(i).isdir==0)
            img = imread(strcat(classFolder, a(i).name));
            
            % organize the image data (in row vector) according to each label
            x = img(:)';
            if(length(x)==360000) %discard those image with different length
                X = [X; x];
                
                [f, h] = extractHOGFeatures(img);
                F = [F; f];
                if (class == 1)
                    Y = [Y; 0];  % 0 to indicate safe
                else
                    Y = [Y; 1];  % 1 to indicate impaired
                end
            end
            
        end
    end
end
%export to the csv format that can be retrieved by other program
writematrix(X, 'Data\bm_29112020\originalImgData2.csv');
writematrix(Y, 'Data\bm_29112020\ImgLabel2.csv');

%save in the .mat format for quick and efficient retrieval via matlab
save('Data\bm_29112020\originalImgData2.mat', 'X', 'Y', '-v7.3');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% consolidate the data into csv format for the enhanced image data
X = [];  % to store the image data
F = [];  % to store the HOG feature vector
Y = [];  % to store the label
for class = 1:10
    % get the images in each class
    classFolder = strcat('Data\bm_29112020\Enhanced\class', num2str(class), '\');
    a = dir(classFolder);
    
    for i = 1:length(a)
        if (a(i).isdir==0)
            img = imread(strcat(classFolder, a(i).name));
            
            % organize the image data (in row vector) according to each label
            x = img(:)';
            if(length(x)==360000) %discard those image with different length
                X = [X; x];
                
                [f, h] = extractHOGFeatures(img);
                F = [F; f];
                if (class == 1)
                    Y = [Y; 0];  % 0 to indicate safe
                else
                    Y = [Y; 1];  % 1 to indicate impaired
                end
            end
            
        end
    end
end
%export to the csv format that can be retrieved by other program
writematrix(X, 'Data\bm_29112020\enhancedImgData2.csv');
% writematrix(Y, 'Data\bm_29112020\ImgLabel2.csv');

%save in the .mat format for quick and efficient retrieval via matlab
save('Data\bm_29112020\enhancedImgData2.mat', 'X', 'Y', '-v7.3');