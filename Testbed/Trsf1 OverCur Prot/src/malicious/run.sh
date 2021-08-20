#!/bin/bash

#Compile simlink.cpp
g++ simlink.cpp -o simlink -pthread

#Collect pcap from interface enp0s8 and dump to file "IED_TRSF1.pcapng"
gnome-terminal --hide-menubar -t CollectPCAP --geometry=36x4+46+300 -- tshark -i enp0s8 -w /media/sf_sharing/Simulation\ testbed\ for\ Stage\ 1/Datasets/Network\ traffics/IED_TRSF1.pcapng -f "not udp" -F pcap

#Run simlink -- the interface among libiec61850, OpenPLC and MATLAB/Simulink
gnome-terminal --hide-menubar -t INTFtoSimulink --geometry=36x8+46+520 -- ./simlink

#Running program SUBtoTRSF2
gnome-terminal --hide-menubar -t SUB_TRSF2 --geometry=36x13+46+4 -- ./goose_subscriber_to_TRSF2

#Running program SUBtoFDR
gnome-terminal --hide-menubar -t SUB_FDR --geometry=36x13+46+740 -- ./goose_subscriber_to_FDR

echo "Enter your scenario ID"
read n
case $n in

0)
#Running benign program Publisher_PIOC_TRSF1
gnome-terminal --hide-menubar -t PUB_TRSF1 --geometry=36x4+46+410 -- ./goose_publisher_PIOC_TRSF1 ;;

901)
#Running malicious program goose_publisher_PIOC_TRSF1_901 -- inject another mal_Pub_TRSF1 (open CB1_66KV, CB_TRSF1 message) every 1 minute
gnome-terminal --hide-menubar -t PUB_TRSF1 --geometry=36x4+46+410 -- ./goose_publisher_PIOC_TRSF1_901
gnome-terminal --hide-menubar -t PUB_TRSF1 --geometry=36x4+46+410 -- ./goose_publisher_PIOC_TRSF1 ;;

902)
#Running malicious program goose_publisher_PIOC_TRSF1_902 --  modify Pub_TRSF1 to (open CB1_66KV, CB_TRSF1 message) every 1 minute
gnome-terminal --hide-menubar -t PUB_TRSF1 --geometry=36x4+46+410 -- ./goose_publisher_PIOC_TRSF1_902 ;;

903)
#Running malicious program goose_publisher_PIOC_TRSF1_903 -- inject another mal_Pub_TRSF1 (open CB1_66KV and CB_TRSF1, close CB2_22KV message) every 1 minute
gnome-terminal --hide-menubar -t PUB_TRSF1 --geometry=36x4+46+410 -- ./goose_publisher_PIOC_TRSF1_903
gnome-terminal --hide-menubar -t PUB_TRSF1 --geometry=36x4+46+410 -- ./goose_publisher_PIOC_TRSF1 ;;

904)
#Running malicious program goose_publisher_PIOC_TRSF1_904 --  modify Pub_TRSF1 to (open CB1_66KV and CB_TRSF1, close CB2_22KV message) every 1 minute
gnome-terminal --hide-menubar -t PUB_TRSF1 --geometry=36x4+46+410 -- ./goose_publisher_PIOC_TRSF1_904 ;;

905)
#Running malicious program goose_publisher_PIOC_TRSF1_905 -- inject Pub_TRSF2 (open CB2_66KV, CB3_66KV, CB_TRSF2 message) when a short-circuit happens around TRSF1 
gnome-terminal --hide-menubar -t PUB_TRSF1 --geometry=36x4+46+410 -- ./goose_publisher_PIOC_TRSF1_905 ;;

906)
#Running malicious program goose_publisher_PIOC_TRSF1_906 -- modify Pub_TRSF1 payloads to (open CB1_66KV, CB2_66KV, CB_TRSF1 message) when a short-circuit happens around TRSF2
gnome-terminal --hide-menubar -t PUB_TRSF1 --geometry=36x4+46+410 -- ./goose_publisher_PIOC_TRSF1_906 ;;

907)
#Running malicious program goose_publisher_PIOC_TRSF1_907 -- inject Pub_TRSF1 (0101) when a short-circuit happens around TRSF1 -- publish both (0101) and (1110) simultaneously
gnome-terminal --hide-menubar -t PUB_TRSF1 --geometry=36x4+46+410 -- ./goose_publisher_PIOC_TRSF1_907 ;;

908)
#Running malicious program goose_publisher_PIOC_TRSF1_908 -- modify Pub_TRSF1 payloads to (0101) even when a short-circuit happens around TRSF1 -- Always close CB
gnome-terminal --hide-menubar -t PUB_TRSF1 --geometry=36x4+46+410 -- ./goose_publisher_PIOC_TRSF1_908 ;;

909)
#Running malicious program goose_publisher_PIOC_TRSF1_909 -- dealy (open CB1_66KV, CB2_66KV, CB_TRSF1 message, close CB2_22KV) after 10 seconds
gnome-terminal --hide-menubar -t PUB_TRSF1 --geometry=36x4+46+410 -- ./goose_publisher_PIOC_TRSF1_909 ;;


*)
echo "Sorry, wrong scenario ID" ;;
esac




