# distractedDriving_cis6320
This repository contains the code and dataset for distracted driving detection. All the codes are written in Matlab. The dataset are provided in two formats, .csv and .mat format. We also provide the dataset of original image data and enhanced image data. Alternatively, you can regenerate the enhanced image by yourself using our image enhancement method, described below.

# Part I: image enhancement
The proposed heuristic image processing to enhance the image is written in “imgEnhancement.m”. The flow of the code is based on the procedures illustrated in Fig. (see the paper). Both the resized image and the enhanced images are saved into two different folders, i.e., “OriginalResize” and “Enhanced”. All the helper functions are located in the helper folder.

# Part II: data preparation
For the training and testing with classification, we consolidate the data into csv files using “imgDataConsolidation.m”. We also save the data into .mat files allowing quick access for those using Matlab platform.  Note that our dataset consists of the raw image data (i.e., the pixel values) and also the HoG feature vector.

# Part III: classification
Then, using the consolidated dataset (you can directly use the dataset in csv or mat file for this part if you skip part II) for classification training. We provide a kNN classification method, “imgkNNclassification.m” to play with the dataset. You can try the kNN for both types of dataset, i.e., the one with raw image data and HoG feature vector, as well as comparing the kNN performance between the original data and also the enhanced data.

# Note:
Due to the uploading limit, only part of the image data is zipped and uploaded to the dropbox. The complete dataset and the consolidated csv files can be found in the following Github link: 



