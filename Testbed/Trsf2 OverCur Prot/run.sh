#!/bin/bash

#Compile simlink.cpp
g++ simlink.cpp -o simlink -pthread

#Collect pcap from interface enp0s8 and dump to file "IED_TRSF2.pcapng"
gnome-terminal --hide-menubar -t CollectPCAP --geometry=36x4+46+300 -- tshark -i enp0s8 -w /media/sf_sharing/Simulation\ testbed\ for\ Stage\ 1/Datasets/Network\ traffics/IED_TRSF2.pcapng -f "not udp" -F pcap

#Run simlink -- the interface among libiec61850, OpenPLC and MATLAB/Simulink
gnome-terminal --hide-menubar -t INTFtoSimulink --geometry=36x8+46+520 -- ./simlink

#Running program SUBtoTRSF1
gnome-terminal --hide-menubar -t SUB_TRSF1 --geometry=36x13+46+4 -- ./goose_subscriber_to_TRSF1

#Running program SUBtoFDR
gnome-terminal --hide-menubar -t SUB_FDR --geometry=36x13+46+740 -- ./goose_subscriber_to_FDR

echo "Enter your scenario ID"
read n
case $n in

0)
#Running benign program Publisher_PIOC_TRSF2
gnome-terminal --hide-menubar -t PUB_TRSF2 --geometry=36x4+46+410 -- ./goose_publisher_PIOC_TRSF2 ;;

901)
#Running malicious program goose_publisher_PIOC_TRSF2_901 -- inject another mal_Pub_TRSF2 (open CB3_66KV, CB_TRSF2 message) every 1 minute
gnome-terminal --hide-menubar -t PUB_TRSF2 --geometry=36x4+46+410 -- ./goose_publisher_PIOC_TRSF2_901
gnome-terminal --hide-menubar -t PUB_TRSF2 --geometry=36x4+46+410 -- ./goose_publisher_PIOC_TRSF2 ;;

902)
#Running malicious program goose_publisher_PIOC_TRSF2_902 --  modify Pub_TRSF2 to (open CB3_66KV, CB_TRSF2 message) every 1 minute
gnome-terminal --hide-menubar -t PUB_TRSF2 --geometry=36x4+46+410 -- ./goose_publisher_PIOC_TRSF2_902 ;;

903)
#Running malicious program goose_publisher_PIOC_TRSF2_903 -- inject another mal_Pub_TRSF2 (open CB3_66KV and CB_TRSF2, close CB2_22KV message) every 1 minute
gnome-terminal --hide-menubar -t PUB_TRSF2 --geometry=36x4+46+410 -- ./goose_publisher_PIOC_TRSF2_903
gnome-terminal --hide-menubar -t PUB_TRSF2 --geometry=36x4+46+410 -- ./goose_publisher_PIOC_TRSF2 ;;

904)
#Running malicious program goose_publisher_PIOC_TRSF2_904 --  modify Pub_TRSF2 to (open CB3_66KV and CB_TRSF2, close CB2_22KV message) every 1 minute
gnome-terminal --hide-menubar -t PUB_TRSF2 --geometry=36x4+46+410 -- ./goose_publisher_PIOC_TRSF2_904 ;;

905)
#Running malicious program goose_publisher_PIOC_TRSF2_905 -- inject Pub_TRSF1 (open CB1_66KV, CB2_66KV, CB_TRSF1 message) when a short-circuit happens around TRSF2 
gnome-terminal --hide-menubar -t PUB_TRSF2 --geometry=36x4+46+410 -- ./goose_publisher_PIOC_TRSF2_905 ;;

906)
#Running malicious program goose_publisher_PIOC_TRSF2_906 -- modify Pub_TRSF2 payloads to (open CB2_66KV, CB3_66KV, CB_TRSF2 message) when a short-circuit happens around TRSF1
gnome-terminal --hide-menubar -t PUB_TRSF2 --geometry=36x4+46+410 -- ./goose_publisher_PIOC_TRSF2_906 ;;

907)
#Running malicious program goose_publisher_PIOC_TRSF2_907 -- inject Pub_TRSF2 (1001) when a short-circuit happens around TRSF2 -- publish both (0101) and (1110) simultaneously
gnome-terminal --hide-menubar -t PUB_TRSF2 --geometry=36x4+46+410 -- ./goose_publisher_PIOC_TRSF2_907 ;;

908)
#Running malicious program goose_publisher_PIOC_TRSF2_908 -- modify Pub_TRSF2 payloads to (1001) even when a short-circuit happens around TRSF2 -- Always close CB
gnome-terminal --hide-menubar -t PUB_TRSF2 --geometry=36x4+46+410 -- ./goose_publisher_PIOC_TRSF2_908 ;;

909)
#Running malicious program goose_publisher_PIOC_TRSF2_909 -- dealy (open CB2_66KV, CB3_66KV, CB_TRSF2 message, close CB2_22KV) after 10 seconds
gnome-terminal --hide-menubar -t PUB_TRSF2 --geometry=36x4+46+410 -- ./goose_publisher_PIOC_TRSF2_909 ;;


*)
echo "Sorry, wrong scenario ID" ;;
esac


