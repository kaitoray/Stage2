# Testbed source codes for stage 1
The testbed simulates both the primary plant and secondary plant of an electricity distribution substation, especially the physical distribution process and a small-scale of the process bus based on the IEC 61850 standard. The testbed runs on an Oracle VirtualBox with five virtual machines (VMs). One VM simulates a small-scale primary plant of a distribution substation using [**MATLAB/Simulink**](https://www.mathworks.com/products/simulink). The other four VMs represent different types of protection relays using [**OpenPLC**](https://www.openplcproject.com), including three instantaneous overcurrent protections and one circuit breaker failure protection. Communication interfaces among each VM, such as GOOSE trip messages between IEDs and the primary plant, are written in C++ based on an open source library - [**libiec61850**](http://libiec61850.com).

*Sincerely thanks **Thiago Alves** for helping solve issues with OpenPLC_Simulink-Interface.*


# Datasets for stage 1
**A total of 24 datasets were collected, include:**
## 15 benign behaviours
* 1 behaviour under normal operation (when no events happen) -- label 0
* 10 behaviours under emergency operation (when a line-to-line fault happens, related overcurrent protetcion triggered) -- label 201-210
* 4 behaviours under emergency operation (when overcurrent protection failed; breaker failure protection triggered) -- label 211-214
## 9 malicious behaviours
* 2 false data injection attacks under normal operation -- label 901, 903
* 2 message modification attacks under normal operation -- label 902, 904
* 2 false data injection attacks under emergency operation -- label 905, 907
* 2 message modification attacks under emergency operation -- label 906, 908
* 1 time delay attack under emergency operation -- label 909
