# ECG_Classification
My final year project based upon the classification of electrocardiogram signals using deep neural networks and the introduction of simulated data into training sets used to train these networks.

## Goal of Project
The goal of this project is to create a deep neural network able to classify ECG signals and cardiac arrhythmia with a high degree of accuracy. Alongside this goal is the aim to explore the implications of introducing simulated data into the training sets in hopes of improving the overall accuracy of the model.

The simulated data will be created using a model of delay differential equations proposed by [Cheffer and Savi](https://www.sciencedirect.com/science/article/abs/pii/S0303264720300769) with the ability to replicate cardiac arrhythmias we see in the real world.

### Why simulated data ?
Though there already exists relatively large data sets for cardiac arrhythmia classification research such as the; [MIT-BIH Arrhythmia Database](https://physionet.org/content/mitdb/1.0.0/) and the [10,000 Patient ECG database](https://figshare.com/collections/ChapmanECG/4560497/2). Due to the nature of the conditions being relatively rare, the databases relating to them tend to be quite small and imbalanced due to the relative scaricty of conditions in the real world. Meaning that when creating models using these data sets the size and imbalance found in them can have implications when training models meaning they can potentially be less accurate and not be as good at generalising out into a real world setting. 

[Ødegaard et al](https://ieeexplore.ieee.org/document/7485270) have shown that simulated data can be helpful in training convolutional neural networks. Using this knowledge of potential benefits of simulated data alongside the recently proposed simulated Arrhythmia models by Cheffer and Savi the introduction of these into the training set for Arrhythmia classifiers could be extremley useful in not only expanding the size of the existing datasets, but in reducing/removing the imbalance found in them also.

## Instructions on how to run
The only additional dependencies to run this project are access to Matlab to generate the simulated ECG and then access to google colab to run and train the models.
The project only supports loading data from google drive, this can be changed thorugh tweaking the load data function in the classifier file however this is not currently supported.

The general re-implementation of the Cheffer and Savi models can be seen in cardiacSimulation.m for future use.

To simulate the artial fibrillation instances all programs needed are in the simulated folder:
* Firstly run the generateData.m program to generate the initial dataset
* After this run the adjustRHeightm program to correct the R wave height
* Running the simulatedWaveDetect.m at this point will calculate the statistics for the simulated data set.
* Finally running createCSVFile.m will convert this dataset into a single .csv file and generate the labels.

Correcting the real dataset ready for use in training:
* Firstly you need to have downloaded the dataset from https://physionet.org/content/challenge-2017/1.0.0/ the folder 'training2017' with all of the ECGs needs to be placed inside of the folder data_procesing with the labels file 'REFERENCE-v3.csv' placed inside it.
* Running the program ammendData.m will update the length of the ECG so theyre all the same length and then save them into a single .csv file alongside and then create a new .csv file with the updated labels.
* Using waveDetect.m will generate the statsistcis for the real datset.
* If the simulated dataset has already been created running mergeSimRealData.m will create a new dataset and labels containing both the real and simulated data.

Using the classifier:
* Once the dataset has been put in the correct format it can be uploaded to google colab using google drive
* From there load ECG_Classification.ipynb into google colab, then each cell needs to be ran to initialise each function
* Running the final cell will create each k fold and then train the model
  * Note: inside this final cell you can change parametrs and comment out lines to either adjust the amount of simulated data or to use only real data
