function [Score, ActivityMask, NoticeableArtifactsMask, NoiseMask] = piqe(I)
%PIQE Perception based Image Quality Evaluator (PIQE) no-reference image quality score 
%   [Score, ActivityMask, NoticeableArtifactsMask, NoiseMask] = PIQE(I)
%   calculates the no-reference image quality score and also returns
%   spatial quality masks i.e., ActivityMask, NoticeableArtifactsMask and
%   NoiseMask for image I. Size of spatial quality masks is always M-by-N.
%   Image I can be either a 2-D grayscale image or an RGB image.
%
%   Class Support
%   -------------
%   I must be a real, non-sparse, M-by-N or M-by-N-by-3 matrix of one of
%   the following classes: uint8, uint16, int16, single or double. Score is
%   a scalar of class double, where as ActivityMask,
%   NoticeableArtifactsMask and NoiseMask are of class logical.
%
%   Notes
%   -----
%   1. The main objective of PIQE is to measure the amount of distortion
%      present in a given test image and produce a quality score. It also
%      returns block-level spatial quality masks. These masks are useful
%      for categorizing and localizing image distortions.
%
%   2. PIQE is inspired by two human perception based criteria for
%      image quality assessment.
%      
%      a. Human visual attention is highly directed towards salient
%         regions in the image. Hence, salient regions contribute more
%         towards overall image quality assessment.
%
%      b. Local quality at region level adds up to the overall image
%         quality.
%
%      In PIQE, the image is divided into non-overlapping blocks of size
%      16x16. Each block is verified towards saliency(2(a)). The blocks
%      that are spatially active are considered as salient blocks. The
%      distortion measurement at each of these blocks will contribute to
%      the overall image quality(2(b)).
%
%   3. The PIQE score is a scalar value in the range [0, 100], where 0
%      indicates excellent quality and 100 indicates bad quality. PIQE
%      score increases with image quality degradation.
%
%   4. Representation of ActivityMask, NoticeableArtifactsMask and
%      NoiseMask:
%
%      ActivityMask: 
%      It represents high spatially active blocks(i.e., salient blocks) in
%      the image.
%
%      NoticeableArtifactsMask: 
%      It represents high spatially active blocks of an image that are
%      affected by compression artifacts(i.e., blockiness) (or) any sudden
%      artifacts.
%    
%      NoiseMask: 
%      It represents high spatially active blocks of an image that are
%      affected by Gaussian noise. 
%
%   5. If input image I, is uniform or homogeneous, PIQE provides 100 as
%      output score indicating bad image quality.
%
%   6. This method does not involve prior modelling of the image features
%      and hence, the accuracy of the spatial quality masks depends on
%      image texture.
%
%   Example
%   -------
%   % This example shows how to compute the quality score and spatial
%   % quality masks like ActivityMask, NoticeableArtifactsMask and
%   % NoiseMask for a JP2K compressed image with added AWGN noise patch.
%
%   I = imread('DistortedImage.png');
%   [Score, ActivityMask, NoticeableArtifactsMask, NoiseMask] = piqe(I);
%   J  = labeloverlay(I, ActivityMask, 'Colormap', 'winter', 'Transparency', 0.25);
%   K  = labeloverlay(I, NoticeableArtifactsMask, 'Colormap', 'autumn', 'Transparency', 0.25);
%   L  = labeloverlay(I, NoiseMask, 'Colormap', 'hot', 'Transparency', 0.25);
%
%   % Visualization of Fused High Spatial Activity, Noticeable Artifact 
%   % and Noisy Labels over the Input Image I.
%   
%   figure;
%   imshow(I);
%   title('Input Image: JP2K Compressed Image with added AWGN noise patch');
%   figure;
%   imshow(J);
%   title('Fused High Spatial Activity Labels over Input Image I');
%   figure;
%   imshow(K);
%   title('Fused Noticeable Artifact Labels over Input Image I');
%   figure;
%   imshow(L);
%   title('Fused Noisy Labels over Input Image I');
%
%   fprintf('PIQE score for the Input Image I is  %0.4f \n', Score);
%
%   References:
%   -----------
%   [1] Venkatanath N, D. Praneeth, Maruthi Chandrasekhar Bh, Sumohana
%       S.Channappayya, and Swarup S. Medasani. "Blind image quality
%       evaluation using perception based features." In
%       Communications(NCC), 2015 Twenty First National Conference on,
%       pp.1-6. IEEE, 2015.
%
%   See also IMMSE, SSIM, PSNR, BRISQUE, NIQE.

%   Copyright 2018 The MathWorks, Inc.

ipImage = validateInputImage(I);
blockSize = 16; % Considered 16x16 block size for overall analysis
activityThreshold = 0.1; % Threshold used to identify high spatially prominent blocks
blockImpairedThreshold = 0.1; % Threshold used to identify blocks having noticeable artifacts
windowSize = 6;% Considered segment size in a block edge.
nSegments = blockSize-windowSize+1; % Number of segments for each block edge
distBlockScores = 0;% Accumulation of distorted block scores
NHSA = 0;% Number of high spatial active blocks.

% Pad if size(ipImage) is not divisible by blockSize.
originalSize = size(ipImage); % Actual image size
[rows, columns, ~] = size(ipImage);
rowsPad = rem(rows,blockSize);
columnsPad = rem(columns,blockSize);
isPadded = false;
if(rowsPad>0 || columnsPad>0)
    if rowsPad>0
        rowsPad = blockSize-rowsPad;
    end
    if columnsPad>0
        columnsPad = blockSize-columnsPad;
    end
    isPadded = true;
    padSize = [rowsPad columnsPad];
    ipImage = padarray(ipImage, padSize, 'replicate', 'post');
end

% RGB to Gray Conversion
if(size(ipImage,3) == 3)
    if isa(ipImage,'int16')
        % Since rgb2gray does not support int16
        ipImage = im2double(ipImage);
    end
    ipImage = rgb2gray(ipImage);
end

% Convert input image to double and scaled to the range 0-255
ipImage = round(255*im2double(ipImage));

% Normalize image to zero mean and ~unit std
% used circularly-symmetric Gaussian weighting function sampled out
% to 3 standard deviations.
mu = imgaussfilt(ipImage,7/6,'FilterSize',7,'Padding','replicate');
sigma = sqrt(abs(imgaussfilt(ipImage.*ipImage,7/6,'FilterSize',7,'Padding','replicate') - mu.*mu));
imnorm = (ipImage-mu)./(sigma+1);

% Preallocation for masks
NoticeableArtifactsMask = false(size(imnorm,1), size(imnorm,2));
NoiseMask = false(size(imnorm,1), size(imnorm,2));
ActivityMask = false(size(imnorm,1), size(imnorm,2));

% Start of block by block processing
for i = 1:blockSize:size(imnorm,1)
    for j = 1:blockSize:size(imnorm,2)
        
        % Weights Initialization
        WNDC = 0;
        WNC = 0;
        
        % Compute block variance
        Block = imnorm(i:i+blockSize-1, j:j+blockSize-1);
        blockVar = var(Block(:));
        
        % Considering spatially prominent blocks 
        if(blockVar>activityThreshold)
            ActivityMask(i:i+blockSize-1, j:j+blockSize-1) = true;
            WHSA = 1;
            NHSA = NHSA+1;
            
            % Analyze Block for noticeable artifacts
            blockImpaired = noticeDistCriterion(Block,nSegments,blockSize-1,...
            windowSize,blockImpairedThreshold,blockSize);
            
            if(blockImpaired)
                WNDC = 1;
                NoticeableArtifactsMask(i:i+blockSize-1, j:j+blockSize-1) = true;
            end
            
            % Analyze Block for Gaussian noise distortions
            [blockSigma, blockBeta] = noiseCriterion(Block, blockSize-1, blockVar);
            
            if((blockSigma>2*blockBeta))
                WNC = 1;
                NoiseMask(i:i+blockSize-1,j:j+blockSize-1) = true;
            end
            
            % Pooling/ distortion assignment
            distBlockScores = distBlockScores + WHSA*WNDC*(1-blockVar) + WHSA*WNC*(blockVar);
        end
        
    end
end

% Quality score computation
% C is a positive constant, it is included to prevent numerical instability
C = 1; 
Score = ((distBlockScores + C)/(C + NHSA))*100;

% if input image is padded then remove those portions from ActivityMask,
% NoticeableArtifactsMask and NoiseMask and ensure that size of these masks
% are always M-by-N.
if(isPadded)
    NoticeableArtifactsMask = NoticeableArtifactsMask(1:originalSize(1),1:originalSize(2));
    NoiseMask = NoiseMask(1:originalSize(1),1:originalSize(2));
    ActivityMask = ActivityMask(1:originalSize(1),1:originalSize(2));
end
end


% Function to Validate Input Image
function I = validateInputImage(I)

supportedClasses = {'uint8', 'uint16', 'int16', 'double', 'single'};
attributes = {'nonempty', 'nonsparse', 'real', 'nonnan', 'finite'};
validateattributes(I, supportedClasses, attributes, mfilename, 'I', 1);

validColorImage = (ndims(I) == 3) && (size(I,3) == 3);

if ~(ismatrix(I) || validColorImage)
    error(message('images:validate:invalidImageFormat','I'));
end
end


% Function to analyze block for Gaussian noise distortions
function [blockSigma, blockBeta] = noiseCriterion(Block, blockSize, blockVar)
% Compute block standard deviation
blockSigma = sqrt(blockVar);

% Compute ratio of center and surround standard deviation
cenSurDev = centerSurDev(Block, blockSize);

% Relation between center-surround deviation and the block standard deviation
blockBeta = (abs(blockSigma-cenSurDev))./(max(blockSigma,cenSurDev));
end


% Function to compute center surround Deviation of a block
function cenSurDev = centerSurDev(Block, blockSize)
% block center
center1 = (blockSize+1)/2;
center2 = center1+1;
center = [Block(:,center1); Block(:,center2)];

% block surround
Block(:,center1) = [];
Block(:,center2) = [];

% Compute standard deviation of block center and block surround
center_std = std(center);
surround_std = std(Block(:));

% Ratio of center and surround standard deviation
cenSurDev = (center_std/surround_std);

% Check for nan's
if(isnan(cenSurDev))
    cenSurDev = 0;
end
end


% Function to analyze block for noticeable artifacts
function blockImpaired = noticeDistCriterion(Block, nSegments, blockSize, windowSize, blockImpairedThreshold, N)

% Top edge of block
topEdge = Block(1,:);
segTopEdge = segmentEdge(topEdge, nSegments, blockSize, windowSize);

% Right side edge of block
rightSideEdge = Block(:,N);
rightSideEdge = rightSideEdge';
segRightSideEdge = segmentEdge(rightSideEdge, nSegments, blockSize, windowSize);

% Down side edge of block
downSideEdge = Block(N,:);
segDownSideEdge = segmentEdge(downSideEdge, nSegments, blockSize, windowSize);

% Left side edge of block
leftSideEdge = Block(:,1);
leftSideEdge = leftSideEdge';
segLeftSideEdge = segmentEdge(leftSideEdge, nSegments, blockSize, windowSize);

% Compute standard deviation of segments in left, right, top and down side edges of a block
segTopEdge_stdDev = std(segTopEdge,0,2);
segRightSideEdge_stdDev = std(segRightSideEdge,0,2);
segDownSideEdge_stdDev = std(segDownSideEdge,0,2);
segLeftSideEdge_stdDev = std(segLeftSideEdge,0,2);

% Check for segment in block exhibits impairedness, if the standard deviation of the segment is less than blockImpairedThreshold.
blockImpaired = 0;
for segIndex = 1:size(segTopEdge,1)
    if((segTopEdge_stdDev(segIndex,:)<blockImpairedThreshold) || ...
            (segRightSideEdge_stdDev(segIndex,:)<blockImpairedThreshold) ||...
            (segDownSideEdge_stdDev(segIndex,:)<blockImpairedThreshold) || ...
            (segLeftSideEdge_stdDev(segIndex,:)<blockImpairedThreshold))
        blockImpaired = 1;
        break;
    end
end
end


% Function to segment block edges
function segments = segmentEdge(blockEdge, nSegments, blockSize, windowSize)
% Segment is defined as a collection of 6 contiguous pixels in a block edge
segments = zeros(nSegments, windowSize);
for i=1:nSegments
    segments(i,:) = blockEdge(i:windowSize);
    if(windowSize <= (blockSize+1))
        windowSize = windowSize+1;
    end
end
end