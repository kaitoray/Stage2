#!/bin/bash

#Convert four pcaps to four CSV
python3 toCSV.py IED_TRSF1
python3 toCSV.py IED_TRSF2
python3 toCSV.py IED_FDR
python3 toCSV.py PrimaryPlant
python3 toCSV.py IED_BFP




