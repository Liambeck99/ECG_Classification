# ECG_Classification
My final year project based upon the classification of electrocardiogram signals using deep neural networks and the introduction of simulated data into training sets used to train these networks.

## Goal Project
The goal of this project is to create a deep neural network able to classify ECG signals and cardiac arrhythmia with a high degree of accuracy. Alongside this goal is the aim to explore the implications of introducing simulated data into the training sets in hopes of improving the overall accuracy of the model.

The simulated data will be created using a model of delay differential equations proposed by [Cheffer and Savi](https://www.sciencedirect.com/science/article/abs/pii/S0303264720300769) with the ability to replicate cardiac arrhythmias we see in the real world.

### Why simulated data ?
Though there already exists relatively large data sets for cardiac arrhythmia classification research such as the; [MIT-BIH Arrhythmia Database](https://physionet.org/content/mitdb/1.0.0/) and the [10,000 Patient ECG database](https://figshare.com/collections/ChapmanECG/4560497/2). Due to the nature of the conditions being relatively rare, the databases relating to them tend to be quite small and imbalanced due to the relative scaricty of conditions in the real world. Meaning that when creating models using these data sets the size and imbalance found in them can have implications when training models meaning they can potentially be less accurate and not be as good at generalising out into a real world setting. 

[Ødegaard et al](https://ieeexplore.ieee.org/document/7485270) have shown that simulated data can be helpful in training convolutional neural networks. Using this knowledge of potential benefits of simulated data alongside the recently proposed simulated Arrhythmia models by Cheffer and Savi the introduction of these into the training set for Arrhythmia classifiers could be extremley useful in not only expanding the size of the existing datasets, but in reducing/removing the imbalance found in them also.
