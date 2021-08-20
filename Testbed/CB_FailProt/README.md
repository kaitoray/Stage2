## Source codes explanation 
* plc.xml: the plc program in OpenPLC written in Ladder Logic
* interface.cfg: configuration file for interface between Simulink and OpenPLC
* simlink.cpp: the interface program connecting Simulink and OpenPLC, and also connecting OpenPLC and goose_publisher
* run.sh: shell executables file for running all necessary programs
* src/goose_publisher_*.c: API of GOOSE publisher based on libiec61850
* src/goose_subscriber_*.c: API of GOOSE subscriber based on libiec61850

## Executable files explanaiton
* simlink: executable file of "simlink.cpp"
* goose_publisher_*: executable file of "goose_publisher_*.c"
* goose_subscriber_*: executable file of "goose_subscriber_*.c"
* *.st: the compiled file of "plc.xml" for uploading to OpenPLC runtime

## System logs
* TripRecord: CB status records from different IEDs, TripFromPLC is recorded from the local IED.