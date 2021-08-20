## Source codes explanation 
* Testbed_v3.slx: Simulink model (source codes) of the primary plant
* interface.cfg: configuration file for interface between Simulink and OpenPLC
* simlink.cpp: the interface program connecting Simulink and goose_subscriber
* run.sh: shell executables file for running all necessary programs
* src/goose_subscriber_*.c: API of GOOSE subscriber based on libiec61850

## Executable files explanaiton
* simlink: executable file of "simlink.cpp"
* goose_subscriber_*: executable file of "goose_subscriber_*.c"

## System logs
* TripRecord: CB status records from different IEDs, TripFromPLC is recorded from the local IED.