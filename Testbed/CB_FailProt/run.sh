#!/bin/bash

#Compile simlink.cpp
g++ simlink.cpp -o simlink -pthread

#Collect pcap from interface enp0s8 and dump to file
gnome-terminal --hide-menubar -t CollectPCAP --geometry=36x4+46+300 -- tshark -i enp0s8 -w /media/sf_sharing/Simulation\ testbed\ for\ Stage\ 1/Datasets/Network\ traffics/IED_BFP.pcapng -f "not udp" -F pcap

#Run simlink -- the interface among libiec61850, OpenPLC and MATLAB/Simulink
gnome-terminal --hide-menubar -t INTFtoSimulink --geometry=36x8+46+520 -- ./simlink

#Running program SUBtoTRSF1
gnome-terminal --hide-menubar -t SUB_FDR --geometry=36x13+46+4 -- ./goose_subscriber_to_FDR

#Running program SUBtoTRSF2
#gnome-terminal --hide-menubar -t SUB_TRSF2 --geometry=36x13+46+740 -- ./goose_subscriber_to_TRSF2

#Running program Publisher_CB_FailProt
gnome-terminal --hide-menubar -t PUB_BFP --geometry=36x4+46+410 -- ./goose_publisher_CB_FailProt
