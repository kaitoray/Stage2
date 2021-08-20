# Different machine learning models

We have created five different machine learning models based on libraries in MATLAB. These include SVM, KNN, Decision tree, BiLSTM without sliding window, and BiLSTM with sliding window.

	Classification Types	Main algorithms	Applied datasets	Hyperparameters
Model 1	Traditional individual sample classification	SVM	Group 1 and 4 (Shuffled)	Classifier = ‘onevsone’
Model 2		KNN	Group 1 and 4 (Shuffled)	Find optimal Numer_Neighbours from range 1 to 10
Model 3		Decision Tree	Group 1 and 4 (Shuffled)	Default settings for fitctree()
Model 4	Sequential classification	BiLSTM without sliding window	Group 1 and 4 (Without shuffle)	Number_HiddenUnits = 200
Max_Epochs = 50
Solver = adam
Model 5		BiLSTM with sliding window	Group 2, 3, 5, 6 (Shuffled)	


