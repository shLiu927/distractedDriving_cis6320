% CIS*6320 Image Processing Algorithm Assignment 2
% Created by Shanhong Liu, Student number: 1110595
% Date: 06/12/2020
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all;

% create a folder to store the enhanced images and also resized images
[status, msg, msgID] = mkdir('Data\bm_29112020\Enhanced');
[status, msg, msgID] = mkdir('Data\bm_29112020\OriginalResize');

% create a table to log the image quality score
imgScores = table();
k = 1;

for class = 1:10
    % create subfolder corresponding to original class
    [status, msg, msgID] = mkdir(strcat('Data\bm_29112020\Enhanced\class', num2str(class)));
    [status, msg, msgID] = mkdir(strcat('Data\bm_29112020\OriginalResize\class', num2str(class)));
    
    % get the images in each class
    classFolder = strcat('Data\bm_29112020\Organized\class', num2str(class), '\');
    a = dir(classFolder);
    
    for i = 1:length(a)
        if (a(i).isdir==0)
            img = imread(strcat(classFolder, a(i).name));
            
            % 0.
            % resize the image and save
            img = imresize(img, [300, NaN]);
            imwrite(img, strcat('Data\bm_29112020\OriginalResize\class', num2str(class), '\', a(i).name));
            oriScore = piqe(img);
            

            % 1.
            % enhance the low lighting issue
            imgInv = imcomplement(img);
            imgInvEnh = imreducehaze(imgInv);
            imgEnh = imcomplement(imgInvEnh);

            enhScore = piqe(imgEnh);

            % 2. 
            % enhance the contrast in lab space
            imgLab = rgb2lab(imgEnh);
            maxLum = 100;
            L = imgLab(:,:,1)/maxLum;
            imgContrastL = imgLab;
            imgContrastL(:,:,1) = adapthisteq(L)*maxLum;
            imgContrastL = lab2rgb(imgContrastL);

            labScore = piqe(imgContrastL);

            % enhance the contrast in rgb space
            imgContrastR = imgEnh;
            imgContrastR(:,:,1) = adapthisteq(imgContrastR(:,:,1));
            imgContrastR(:,:,2) = adapthisteq(imgContrastR(:,:,2));
            imgContrastR(:,:,3) = adapthisteq(imgContrastR(:,:,3));

            rgbScore = piqe(imgContrastR);

            if(labScore < rgbScore)
                imgContrast = imgContrastL;
                contrastScore = labScore;
            else
                imgContrast = imgContrastR;
                contrastScore = rgbScore;
            end


            % 3. 
            % perform the gamma correction on both images
            imgContrastLin = lin2rgb(imgContrast);
            tempScore = piqe(imgContrastLin);
            if(tempScore < contrastScore)
                imgContrast = imgContrastLin;
                contrastScore = tempScore;
            end

            imgEnhLin = lin2rgb(imgEnh);
            tempScore = piqe(imgEnhLin);
            if(tempScore < enhScore)
                imgEnh = imgEnhLin;
                enhScore = tempScore;
            end


            % 4. 
            % choose between the one that with light or light + contrast
            if(contrastScore < enhScore)
                imgToSave = imgContrast;
            else
                imgToSave = imgEnh;
            end
            
            imwrite(imgToSave, strcat('Data\bm_29112020\Enhanced\class', num2str(class), '\', a(i).name));
            imgScores.class(k) = class;
            imgScores.imgName{k} = a(i).name;
            imgScores.oriScore(k) = oriScore;
            imgScores.enhScore(k) = enhScore;
            imgScores.contrastScore(k) = contrastScore;
            k = k+1;
        end
    end
end

% export the table with all the score to csv file for later retrieval
writetable(imgScores, 'Data\bm_29112020\imgScores.csv');











