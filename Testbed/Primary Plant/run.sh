#!/bin/bash

#Compile simlink.cpp
g++ simlink.cpp -o simlink -pthread

#Collect pcap from interface enp0s8 and dump to file "PrimaryPlant.pcapng"
gnome-terminal --hide-menubar -t CollectPCAP --geometry=23x7+1700+4 -- tshark -i enp0s8 -w /media/sf_sharing/Simulation\ testbed\ for\ Stage\ 1/Datasets/Network\ traffics/PrimaryPlant.pcapng -f "not udp" -F pcap

#Run simlink -- the interface between libiec61850 and MATLAB/Simulink
gnome-terminal --hide-menubar -t INTFtoSimulink --geometry=23x41+1700--29 -- ./simlink

#Running program Subscriber from IED_TRSF1
gnome-terminal --hide-menubar -t SUB_TRSF1 --geometry=36x12+46+4 -- ./goose_subscriber_to_TRSF1

#Running program Subscriber from IED_TRSF2
gnome-terminal --hide-menubar -t SUB_TRSF2 --geometry=36x12+46+260 -- ./goose_subscriber_to_TRSF2

#Running program Subscriber from IED_FDR
gnome-terminal --hide-menubar -t SUB_FDR --geometry=36x12+46+515 -- ./goose_subscriber_to_FDR

#Running program Subscriber from IED_BFP
gnome-terminal --hide-menubar -t SUB_BFP --geometry=36x12+46+770 -- ./goose_subscriber_to_BFP
