# Contents

There are three types of datasets. **Original** remain as raw datasets collected from the testbed while **Normalised** are normalised datasets after several data pre-processes, including format conversion, data merging, data normalisation, feature selection, feature extraction, and labelling.

Each Scenario consists of network traffic and system logs (simulink)
* **network traffic** contains 5 network PCAP files and 5 CSV files which are converted from those 5 pcap files
* **simulink** consists of 4 CSV files record physical features from four IEDs

**Final** are one-sheet datasets summarised from all benign and malicious scenarios. It includes six groups of datasets which are explained in details below:

	Applied sliding window	Labelling methods	# of training scenarios	# of testing scenarios	# of training samples	# of testing samples	# of features	# of different labels
Group 1	No	Type 3	23	8	27919	9902	27	10
Group 2	Time-based	Sequential labelling	23	8	various	various	27	10
Group 3	Quantity-based	Sequential labelling	23	8	various	various	27	10
Group 4	No	Type 3	23	8	27919	9902	16	10
Group 5	Time-based	Sequential labelling	23	8	various	various	16	10
Group 6	Quantity-based	Sequential labelling	23	8	various	various	16	10
