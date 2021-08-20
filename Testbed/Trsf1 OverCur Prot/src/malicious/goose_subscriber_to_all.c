/*
 * goose_subscriber_FDR
 *
 * This is an example for a standalone GOOSE subscriber
 *
 * Has to be started as root in Linux.
 */

#include "goose_receiver.h"
#include "goose_subscriber.h"
#include "hal_thread.h"

#include <stdlib.h>
#include <stdio.h>
#include <signal.h>

static int running = 1;
int APPID;
char* gocbRef;
FILE *fp;

void sigint_handler(int signalId)
{
    running = 0;
}


void
gooseListener(GooseSubscriber subscriber, void* parameter)
{
    
    
    MmsValue* values = GooseSubscriber_getDataSetValues(subscriber);

    char buffer[1024];

    MmsValue_printToBuffer(values, buffer, 1024);
    
    uint32_t timestamp = GooseSubscriber_getTimestamp(subscriber);
    //Add 10 hours time differences to UTC timestamp 
    timestamp = timestamp + 36000000;
    
    //Open File//
    	fp=fopen("/home/ray/Desktop/Trsf1 OverCur Prot/TripRecord/info.csv","a");
    	
    	if(fp==NULL) {
        printf("File cannot open! " );
        exit(0);
     	}
 
    //write values to file//
	fprintf(fp,"%u,%u,%u,%u,%s\n", GooseSubscriber_getTimeAllowedToLive(subscriber),timestamp,GooseSubscriber_getStNum(subscriber),GooseSubscriber_getSqNum(subscriber),buffer);
		     
    //Close file//
    	fclose(fp);
}


int
main(int argc, char** argv)
{
    GooseReceiver receiver = GooseReceiver_create();

     if (argc > 1) {
         printf("Set interface id: %s\n", argv[1]);
         GooseReceiver_setInterfaceId(receiver, argv[1]);
     }
     else {
         printf("Using interface enp0s8\n");
         GooseReceiver_setInterfaceId(receiver, "enp0s8");
     }
     
//############### store info to local ##########################//  
    //Open File//
    	fp=fopen("/home/ray/Desktop/Trsf1 OverCur Prot/TripRecord/info.csv","w");
    	
    	if(fp==NULL) {
        printf("File cannot open! " );
        exit(0);
     	}
 
    //write values to file//
	fprintf(fp,"APPID,gocbRef,TTL,stnum,sqnum,allData\n");
	     
    //Close file//
    	fclose(fp);
//##############################################################################//

    for (int APPID=0x8000; APPID<0x8099; APPID++)	{
    
    gocbRef = "SimulationTestbed/PIOC$TRSF2$CBStval";
    
    GooseSubscriber subscriber = GooseSubscriber_create(gocbRef, NULL);

    GooseSubscriber_setAppId(subscriber, APPID);

    GooseSubscriber_setListener(subscriber, gooseListener, NULL);
    
    //printf("%#04X", APPID);

    GooseReceiver_addSubscriber(receiver, subscriber);
    }
 
    for (int APPID=0x8000; APPID<0x8099; APPID++)	{
    
    gocbRef = "SimulationTestbed/PIOC$FDR$CBStval";
    
    GooseSubscriber subscriber = GooseSubscriber_create(gocbRef, NULL);

    GooseSubscriber_setAppId(subscriber, APPID);

    GooseSubscriber_setListener(subscriber, gooseListener, NULL);

    GooseReceiver_addSubscriber(receiver, subscriber);
    }
    
    for (int APPID=0x8000; APPID<0x8099; APPID++)	{
    
    gocbRef = "SimulationTestbed/BFP$FDR$CBStaval";
    
    GooseSubscriber subscriber = GooseSubscriber_create(gocbRef, NULL);

    GooseSubscriber_setAppId(subscriber, APPID);

    GooseSubscriber_setListener(subscriber, gooseListener, NULL);

    GooseReceiver_addSubscriber(receiver, subscriber);
    }

    GooseReceiver_start(receiver);

    if (GooseReceiver_isRunning(receiver)) {
        signal(SIGINT, sigint_handler);
        
        while (running) {
            Thread_sleep(100);
        }
    }
    else {
        printf("Failed to start GOOSE subscriber. Reason can be that the Ethernet interface doesn't exist or root permission are required.\n");
    }

    GooseReceiver_stop(receiver);

    GooseReceiver_destroy(receiver);
   
}
