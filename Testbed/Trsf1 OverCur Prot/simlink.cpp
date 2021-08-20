#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <netdb.h>
#include <string.h>
#include <pthread.h>
#include <arpa/inet.h>
#include <sys/socket.h>
#include <time.h>

#include <iostream>
#include <fstream>
#include <string>
#include <ctime>
#include <ratio>
#include <chrono>

#define TYPE_ANALOGIN		0
#define TYPE_ANALOGOUT		1
#define TYPE_DIGITALIN		2
#define TYPE_DIGITALOUT		3

#define ANALOG_BUF_SIZE		8
#define DIGITAL_BUF_SIZE	16

#define PLC_STATIONS_PORT	6668

using namespace std;

char simulink_ip[100];

FILE *fp;

pthread_mutex_t bufferLock;

/*********************** unix timestamp to time string [begin] ***********************/

#define UTC_BASE_YEAR   1970
#define MONTH_PER_YEAR  12
#define DAY_PER_YEAR    365
#define SEC_PER_DAY     86400
#define SEC_PER_HOUR    3600
#define SEC_PER_MIN     60

/* Num of days in each month */
const unsigned char g_day_per_mon[MONTH_PER_YEAR] = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};

/* is leap_year or not */
static unsigned char applib_dt_is_leap_year(unsigned short year)
{

    if ((year % 400) == 0) {
        return 1;
    } else if ((year % 100) == 0) {
        return 0;
    } else if ((year % 4) == 0) {
        return 1;
    } else {
        return 0;
    }
}

/*How many days in that month*/
static unsigned char applib_dt_last_day_of_mon(unsigned char month, unsigned short year)
{
    if ((month == 0) || (month > 12)) {
        return g_day_per_mon[1] + applib_dt_is_leap_year(year);
    }

    if (month != 2) {
        return g_day_per_mon[month - 1];
    } else {
        return g_day_per_mon[1] + applib_dt_is_leap_year(year);
    }
}


static void change(uint64_t ts)
{
    int year = 0;
    int month = 0;
    int day = 0;
    int hour = 0;
    int minute = 0;
    int second = 0;

    int days = ts / SEC_PER_DAY;
    //Transfer in years
    int yearTmp = 0;
    int dayTmp = 0;
    
    //how many years
    for (yearTmp = UTC_BASE_YEAR; days > 0; yearTmp++) {
        dayTmp = (DAY_PER_YEAR + applib_dt_is_leap_year(yearTmp)); //how many days in this year
        if (days >= dayTmp)
        {
           days -= dayTmp;
        }
        else
        {
           break;
        }
    }
    year = yearTmp;

    //Transfer in months 
    int monthTmp = 0;
    for (monthTmp = 1; monthTmp < MONTH_PER_YEAR; monthTmp++) {
       dayTmp = applib_dt_last_day_of_mon(monthTmp, year);
       if (days >= dayTmp) {
           days -= dayTmp;
       }
       else
       {
           break;
       }
    }
    month = monthTmp;

    day = days + 1;

    //Transfer To total seconds
    int secs = ts % SEC_PER_DAY;
    //Transfer In Hours
    hour = (secs / SEC_PER_HOUR);
    //Transfer In Minutes
    secs %= SEC_PER_HOUR;
    minute = secs / SEC_PER_MIN;
    //Transfer In Seconds
    second = secs % SEC_PER_MIN;
    
     //Open File//
    	fp=fopen("/media/sf_sharing/Simulation testbed for Stage 1/Datasets/Simulink/IED_TRSF1_physical.csv","a");
    	
    	if(fp==NULL) {
        printf("File cannot open! " );
        exit(0);
     	}
    //write values to file//
	fprintf(fp,"%d,%d,%d,%d,%d,%d,", year, month, day, hour, minute, second);
    //Close file//
    	fclose(fp);
}


struct plcData
{
	uint16_t analogIn[ANALOG_BUF_SIZE];
	uint16_t analogOut[ANALOG_BUF_SIZE];
	bool digitalIn[DIGITAL_BUF_SIZE];
	bool digitalOut[DIGITAL_BUF_SIZE];
};

struct stationInfo
{
	char ip[100];
	uint16_t analogInPorts[ANALOG_BUF_SIZE];
	uint16_t analogOutPorts[ANALOG_BUF_SIZE];
	uint16_t digitalInPorts[DIGITAL_BUF_SIZE];
	uint16_t digitalOutPorts[DIGITAL_BUF_SIZE];
};

struct plcData *stations_data;
struct stationInfo *stations_info;
uint8_t num_stations = 0;
uint16_t comm_delay = 100;

//-----------------------------------------------------------------------------
// Helper function - Convert a byte array into a double
//-----------------------------------------------------------------------------
double convertBufferToDouble(unsigned char *buff)
{
	double returnVal;
	memcpy(&returnVal, buff, 8);

	return returnVal;
}

//-----------------------------------------------------------------------------
// Helper function - Makes the running thread sleep for the ammount of time
// in milliseconds
//-----------------------------------------------------------------------------
void sleep_ms(int milliseconds)
{
	struct timespec ts;
	ts.tv_sec = milliseconds / 1000;
	ts.tv_nsec = (milliseconds % 1000) * 1000000;
	nanosleep(&ts, NULL);
}

//-----------------------------------------------------------------------------
// Finds the data between the separators on the line provided
//-----------------------------------------------------------------------------
void getData(char *line, char *buf, char separator1, char separator2)
{
	int i=0, j=0;

	while (line[i] != separator1 && line[i] != '\0')
	{
		i++;
	}
	i++;

	while (line[i] != separator2 && line[i] != '\0')
	{
		buf[j] = line[i];
		i++;
		j++;
		buf[j] = '\0';
	}
}

//-----------------------------------------------------------------------------
// Get the number of the station
//-----------------------------------------------------------------------------
int getStationNumber(char *line)
{
	char temp[5];
	int i = 0, j = 7;

	while (line[j] != '.')
	{
		temp[i] = line[j];
		i++;
		j++;
		temp[i] = '\0';
	}

	return(atoi(temp));
}

//-----------------------------------------------------------------------------
// get the type of function or parameter for the station
//-----------------------------------------------------------------------------
void getFunction(char *line, char *parameter)
{
	int i = 0, j = 0;

	while (line[j] != '.')
	{
		j++;
	}
	j++;

	while (line[j] != ' ' && line[j] != '=' && line[j] != '(')
	{
		parameter[i] = line[j];
		i++;
		j++;
		parameter[i] = '\0';
	}
}

//-----------------------------------------------------------------------------
// Add the UDP Port number to the plc station info
//-----------------------------------------------------------------------------
void addPlcPort(char *line, struct stationInfo *station_info)
{
	char type[100];
	uint16_t *dataPointer;
	getData(line, type, '(', ')');

	if(!strncmp(type, "digital_in", 10) || !strncmp(type, "discrete_input", 4))
	{
		dataPointer = station_info->digitalInPorts;
	}

	else if(!strncmp(type, "digital_out", 11) || !strncmp(type, "coil", 14))
	{
		dataPointer = station_info->digitalOutPorts;
	}

	else if(!strncmp(type, "analog_in", 9) || !strncmp(type, "input", 5))
	{
		dataPointer = station_info->analogInPorts;
	}

	else if(!strncmp(type, "analog_out", 10) || !strncmp(type, "holding", 7))
	{
		dataPointer = station_info->analogOutPorts;
	}

	int i = 0;
	while (dataPointer[i] != 0)
	{
		i++;
	}

	char temp_buffer[100];
	getData(line, temp_buffer, '"', '"');
	dataPointer[i] = atoi(temp_buffer);
}

//-----------------------------------------------------------------------------
// Parse the interface.cfg file looking for the IP address of the Simulink app
// and for each OpenPLC station information
//-----------------------------------------------------------------------------
void parseConfigFile()
{
	string line;
	char line_str[1024];
	ifstream cfgfile("interface.cfg");

	if (cfgfile.is_open())
	{
		while (getline(cfgfile, line))
		{
			strncpy(line_str, line.c_str(), 1024);
			if (line_str[0] != '#' && strlen(line_str) > 1)
			{
				if (!strncmp(line_str, "num_stations", 12))
				{
					char temp_buffer[10];
					getData(line_str, temp_buffer, '"', '"');
					num_stations = atoi(temp_buffer);
					stations_data = (struct plcData *)malloc(num_stations*sizeof(struct plcData));
					stations_info = (struct stationInfo *)malloc(num_stations*sizeof(struct stationInfo));
				}
				else if (!strncmp(line_str, "comm_delay", 10))
				{
					char temp_buffer[10];
					getData(line_str, temp_buffer, '"', '"');
					comm_delay = atoi(temp_buffer);
				}
				else if (!strncmp(line_str, "simulink", 8))
				{
					getData(line_str, simulink_ip, '"', '"');
				}

				else if (!strncmp(line_str, "station", 7))
				{
					int stationNumber = getStationNumber(line_str);
					char functionType[100];
					getFunction(line_str, functionType);

					if (!strncmp(functionType, "ip", 2))
					{
						getData(line_str, stations_info[stationNumber].ip, '"', '"');
					}
					else if (!strncmp(functionType, "add", 3))
					{
						addPlcPort(line_str, &stations_info[stationNumber]);
					}
				}
			}
		}
		cfgfile.close();
	}

	else
	{
		cout << "Error trying to open file!" << endl;
	}
}

void displayInfo()
{
	for (int i = 0; i < num_stations; i++)
	{
		printf("\nStation %d:\n", i);
		printf("ip: %s\n", stations_info[i].ip);

		int j = 0;
		while (stations_info[i].analogInPorts[j] != 0)// && j <= 4)
		{
			printf("AnalogIn %d: %d\n", j, stations_info[i].analogInPorts[j]);
			j++;
		}

		j = 0;
		while (stations_info[i].analogOutPorts[j] != 0)// && j <= 4)
		{
			printf("AnalogOut %d: %d\n", j, stations_info[i].analogOutPorts[j]);
			j++;
		}

		j = 0;
		while (stations_info[i].digitalInPorts[j] != 0)// && j <= 4)
		{
			printf("DigitalIn %d: %d\n", j, stations_info[i].digitalInPorts[j]);
			j++;
		}

		j = 0;
		while (stations_info[i].digitalOutPorts[j] != 0)// && j <= 4)
		{
			printf("DigitalOut %d: %d\n", j, stations_info[i].digitalOutPorts[j]);
			j++;
		}
	}
}


//-----------------------------------------------------------------------------
// Thread to send data to Simulink using UDP
//-----------------------------------------------------------------------------
void *sendSimulinkData(void *args)
{
	//getting arguments
	int *rcv_args = (int *)args;
	int stationNumber = rcv_args[0];
	int varType = rcv_args[1];
	int varIndex = rcv_args[2];

	int socket_fd, port;
	struct sockaddr_in server_addr;
	struct hostent *server;
	int send_len;
	uint16_t *analogPointer;
	bool *digitalPointer;

	//Create TCP Socket
	socket_fd = socket(AF_INET, SOCK_DGRAM, 0);
	if (socket_fd<0)
	{
		perror("Server: error creating stream socket");
		exit(1);
	}

	//Figure out information about variable
	switch (varType)
	{
		case TYPE_ANALOGOUT:
			port = stations_info[stationNumber].analogOutPorts[varIndex];
			analogPointer = &stations_data[stationNumber].analogOut[varIndex];
			break;
		case TYPE_DIGITALOUT:
			port = stations_info[stationNumber].digitalOutPorts[varIndex];
			digitalPointer = &stations_data[stationNumber].digitalOut[varIndex];
			break;
	}

	//Initialize Server Structures
	server = gethostbyname(simulink_ip);
	if (server == NULL)
	{
		printf("Error locating host %s\n", simulink_ip);
		return 0;
	}

	bzero((char *) &server_addr, sizeof(server_addr));
	server_addr.sin_family = AF_INET;
	server_addr.sin_port = htons(port);
	bcopy((char *)server->h_addr, (char *)&server_addr.sin_addr.s_addr, server->h_length);

	while (1)
	{
		uint16_t value;//[10];
		pthread_mutex_lock(&bufferLock);
		(varType == TYPE_DIGITALOUT) ? value = (uint16_t)*digitalPointer : value = (uint16_t)*analogPointer;//sprintf(value, "%d", *digitalPointer) : sprintf(value, "%d", *analogPointer);
		pthread_mutex_unlock(&bufferLock);

		/*
		//DEBUG
		char varType_str[50];
		(varType == TYPE_ANALOGOUT) ? strncpy(varType_str, "TYPE_ANALOGOUT", 50) : strncpy(varType_str, "TYPE_DIGITALOUT", 50);
		printf("Sending data type %s, station %d, index %d, value: %d\n", varType_str, stationNumber, varIndex, value);
		*/
		const char* value_bytes = (const char*)&value;
		send_len = sendto(socket_fd, value_bytes, sizeof(value), 0, (struct sockaddr *)&server_addr, sizeof(server_addr));
		if (send_len < 0)
		{
			printf("Error sending data to simulink on socket %d\n", socket_fd);
		}

		sleep_ms(comm_delay);
	}
}

//-----------------------------------------------------------------------------
// Create the socket and bind it. Returns the file descriptor for the socket
// created.
//-----------------------------------------------------------------------------
int createUDPServer(int port)
{
	int socket_fd;
	struct sockaddr_in server_addr;
	struct hostent *server;

	//Create TCP Socket
	socket_fd = socket(AF_INET, SOCK_DGRAM, 0);
	if (socket_fd<0)
	{
		perror("Server: error creating stream socket");
		exit(1);
	}

	//Initialize Server Struct
	bzero((char *) &server_addr, sizeof(server_addr));
	server_addr.sin_family = AF_INET;
	server_addr.sin_port = htons(port);
	server_addr.sin_addr.s_addr = INADDR_ANY;

	//Bind socket
	if (bind(socket_fd, (struct sockaddr *)&server_addr, sizeof(server_addr)) < 0)
	{
		perror("Server: error binding socket");
		exit(1);
	}

	printf("Socket %d binded successfully on port %d!\n", socket_fd, port);

	return socket_fd;
}

//-----------------------------------------------------------------------------
// Thread to receive data from Simulink using UDP
//-----------------------------------------------------------------------------
void *receiveSimulinkData(void *arg)
{
	int *rcv_args = (int *)arg;
	int stationNumber = rcv_args[0];
	int varType = rcv_args[1];
	int varIndex = rcv_args[2];

	int socket_fd, port;
	const int BUFF_SIZE = 1024;
	int rcv_len;
	unsigned char rcv_buffer[BUFF_SIZE];
	socklen_t cli_len;
	struct sockaddr_in client;
	uint16_t *analogPointer;
	bool *digitalPointer;

	cli_len = sizeof(client);

	switch (varType)
	{
		case TYPE_ANALOGIN:
			port = stations_info[stationNumber].analogInPorts[varIndex];
			analogPointer = &stations_data[stationNumber].analogIn[varIndex];
			break;
		case TYPE_DIGITALIN:
			port = stations_info[stationNumber].digitalInPorts[varIndex];
			digitalPointer = &stations_data[stationNumber].digitalIn[varIndex];
			break;
	}

	socket_fd = createUDPServer(port);

	while(1)
	{
		rcv_len = recvfrom(socket_fd, rcv_buffer, BUFF_SIZE, 0, (struct sockaddr *) &client, &cli_len);
		if (rcv_len < 0)
		{
			printf("Error receiving data on socket %d\n", socket_fd);
		}

		else
		{
			double valueRcv = convertBufferToDouble(rcv_buffer);

			
			//DEBUG
			/*
			printf("Received packet from %s:%d\n", inet_ntoa(client.sin_addr), ntohs(client.sin_port));
			char varType_str[50];
			(varType == TYPE_ANALOGOUT) ? strncpy(varType_str, "TYPE_ANALOGOUT", 50) : strncpy(varType_str, "TYPE_DIGITALOUT", 50);
			printf("Station: %d, Type: %s, Index: %d, Size: %d, Data: %f\n" , stationNumber, varType_str, varIndex, rcv_len, valueRcv);
			*/

			pthread_mutex_lock(&bufferLock);
			(varType == TYPE_DIGITALIN) ? (*digitalPointer = (bool)valueRcv) : (*analogPointer = (uint16_t)valueRcv);
			pthread_mutex_unlock(&bufferLock);
		}
	}
}

//-----------------------------------------------------------------------------
// Main function responsible to exchange data with the simulink application
//-----------------------------------------------------------------------------
void exchangeDataWithSimulink()
{
	for (int i = 0; i < num_stations; i++)
	{
		//sending analog data
		/*
		int j = 0;
		while (stations_info[i].analogOutPorts[j] != 0)
		{
			int *args = new int[3];
			args[0] = i; //station number
			args[1] = TYPE_ANALOGOUT; //var type
			args[2] = j; //var index

			pthread_t sendingThread;
			pthread_create(&sendingThread, NULL, sendSimulinkData, args);
			j++;
		}
		*/

		//receiving analog data
		int j = 0;
		while (stations_info[i].analogInPorts[j] != 0)
		{
			int *args = new int[3];
			args[0] = i; //station number
			args[1] = TYPE_ANALOGIN; //var type
			args[2] = j; //var index

			pthread_t receivingThread;
			pthread_create(&receivingThread, NULL, receiveSimulinkData, args);
			j++;
		}
		
		//sending digital data
		/*
		j = 0;
		while (stations_info[i].digitalOutPorts[j] != 0)
		{
			int *args = new int[3];
			args[0] = i; //station number
			args[1] = TYPE_DIGITALOUT; //var type
			args[2] = j; //var index

			pthread_t sendingThread;
			pthread_create(&sendingThread, NULL, sendSimulinkData, args);
			j++;
		}
		*/

		//receiving digital data
		j = 0;
		while (stations_info[i].digitalInPorts[j] != 0)
		{
			int *args = new int[3];
			args[0] = i; //station number
			args[1] = TYPE_DIGITALIN; //var type
			args[2] = j; //var index

			pthread_t receivingThread;
			pthread_create(&receivingThread, NULL, receiveSimulinkData, args);
			j++;
		}
	}
}

void *exchangeDataWithPLC(void *args)
{
	int stationNumber = *(int *)args;
	int socket_fd, port = PLC_STATIONS_PORT;
	struct sockaddr_in server_addr;
	struct hostent *server;
	int data_len;
	socklen_t cli_len;
	struct plcData *localBuffer = (struct plcData *)malloc(sizeof(struct plcData));
	char *hostaddr;

	//Create TCP Socket
	socket_fd = socket(AF_INET, SOCK_DGRAM, 0);
	if (socket_fd<0)
	{
		perror("Server: error creating stream socket");
		exit(1);
	}

	//Initialize Server Structures
	server = gethostbyname(stations_info[stationNumber].ip);
	if (server == NULL)
	{
		printf("Error locating host %s\n", hostaddr);
		return 0;
	}

	bzero((char *) &server_addr, sizeof(server_addr));
	server_addr.sin_family = AF_INET;
	server_addr.sin_port = htons(port);
	bcopy((char *)server->h_addr, (char *)&server_addr.sin_addr.s_addr, server->h_length);

	//set timeout of 100ms on receive
	struct timeval tv;
	tv.tv_sec = 0;
	tv.tv_usec = 100000;
	if (setsockopt(socket_fd, SOL_SOCKET, SO_RCVTIMEO, &tv, sizeof(tv)) < 0)
	{
		printf("Error setting timeout\n");
	}

	while (1)
	{
		pthread_mutex_lock(&bufferLock);
		memcpy(localBuffer, &stations_data[stationNumber], sizeof(struct plcData));
		pthread_mutex_unlock(&bufferLock);

		//printf("Sending pressure: %d to station: %d\n", localBuffer->pressure, stationNumber);
		data_len = sendto(socket_fd, localBuffer, sizeof(*localBuffer), 0, (struct sockaddr *)&server_addr, sizeof(server_addr));
		if (data_len < 0)
		{
			printf("Error sending data on socket %d\n", socket_fd);
		}
		else
		{
			//printf("Receiving data from station %d\n", stationNumber);
			data_len = 0;
			int counter = 0;
			while (data_len == 0)
			{
				cli_len = sizeof server_addr;
				data_len = recvfrom(socket_fd, localBuffer, sizeof(*localBuffer), 0, (struct sockaddr *)&server_addr, &cli_len);
				counter++;
				if (data_len == -1)
				{
					perror("Error receiving data: ");
				}
				if (counter > 10)
				{
					data_len = -1;
					break;
				}
			}
			
			if (data_len < 0)
			{
				printf("Error receiving data on socket %d\n", socket_fd);
			}
			else
			{
				
				//DEBUG
				/*
				printf("Received data with size %d:\r\n", data_len);
				for (int i = 0; i < ANALOG_BUF_SIZE; i++)
				{
					printf("AIN[%d]: %d\t", i, localBuffer->analogIn[i]);
				}
				printf("\r\n");
				for (int i = 0; i < ANALOG_BUF_SIZE; i++)
				{
					printf("AOUT[%d]: %d\t", i, localBuffer->analogOut[i]);
				}
				printf("\r\n");
				for (int i = 0; i < DIGITAL_BUF_SIZE; i++)
				{
					printf("DIN[%d]: %d\t", i, localBuffer->digitalIn[i]);
				}
				printf("\r\n");
				for (int i = 0; i < DIGITAL_BUF_SIZE; i++)
				{
					printf("DOUT[%d]: %d\t", i, localBuffer->digitalOut[i]);
				}
				printf("\r\n");
				*/
				
				pthread_mutex_lock(&bufferLock);
				memcpy(&stations_data[stationNumber], localBuffer, sizeof(struct plcData));
				pthread_mutex_unlock(&bufferLock);
			}
		}

		sleep_ms(comm_delay);
	}
}

void connectToPLCStations()
{
	for (int i = 0; i < num_stations; i++)
	{
		int *station = new int[1]; //alloc space on heap
		station[0] = i;

		pthread_t plcThread;
		pthread_create(&plcThread, NULL, exchangeDataWithPLC, &station[0]);

	}
}

//-----------------------------------------------------------------------------
// Interface main function. Should parse the configuration file, call the
// functions to exchange data with the simulink application and with the
// OpenPLC stations. The main loop must also display periodically the data
// exchanged with each OpenPLC station.
//-----------------------------------------------------------------------------
int main()
{

	parseConfigFile();
	displayInfo();

	exchangeDataWithSimulink();
	connectToPLCStations();
	
    //Open File//
    	fp=fopen("/media/sf_sharing/Simulation testbed for Stage 1/Datasets/Simulink/IED_TRSF1_physical.csv","w");
    	if(fp==NULL) {
        printf("File cannot open! " );
        exit(0);
     	}
    //write values to file//
    	fprintf(fp,"year,month,day,hour,minute,second,millisecond,UTC,open_CB1-66KV,open_CB2-66KV,open_CB-TRSF1,open_CB2-22KV,I_CB1-66KV,I_CB2-66KV,I_TRSF1-W1,I_TRSF1-W2,I_CB-TRSF1,I_CB2-22KV\n");
    //Close file//
    	fclose(fp);


	while(1)
	{
		pthread_mutex_lock(&bufferLock);
		
	
	//	printf(" CB1-66KV: %d A\n CB2-66KV: %d A\n TRSF1-W1: %d A\n TRSF1-W2: %d A\n CB-TRSF1: %d A\n CB2-22KV: %d A\n Reset all CB: %d\n Trip CB1-66KV: %d\n Trip CB2-66KV: %d\n Trip CB-TRSF1: %d\n\n", stations_data[0].analogIn[0], stations_data[0].analogIn[1], stations_data[0].analogIn[2], stations_data[0].analogIn[3], stations_data[0].analogIn[4], stations_data[0].analogIn[5], stations_data[0].digitalIn[0], stations_data[0].digitalOut[0], stations_data[0].digitalOut[1], stations_data[0].digitalOut[2]);
		

    	int i;
    	int CBstval [4] = {0,0,0,0};
    	
    	CBstval [0] = stations_data[0].digitalOut[0];
    	CBstval [1] = stations_data[0].digitalOut[1];
    	CBstval [2] = stations_data[0].digitalOut[2];
    	CBstval [3] = stations_data[0].digitalOut[3];
 
    //Open File//
    	fp=fopen("TripRecord/TripFromPLC.csv","w");
    	
    	if(fp==NULL) {
        printf("File cannot open! " );
        exit(0);
     	}
 
    //write values to file//
	for (i=0; i<4; i++)
	fprintf(fp,"%d,", CBstval[i]);
	     
    //Close file//
    	fclose(fp);
    	    	
//#################store physical parameters with timestamp#########################//
    	
    // current date and time in millisecond based on current system
   	using namespace std::chrono;
   	uint64_t UTCtimestamp = duration_cast<milliseconds>(system_clock::now().time_since_epoch()).count();
   	double UTCtime = static_cast<double> (UTCtimestamp);
   	
   //Add 10 hours time differences to UTC timestamp 
        uint64_t localtimestamp = UTCtimestamp + 36000000;

   // convert now to string form
   	change(localtimestamp / 1000);
    	
    //Open File//
    	fp=fopen("/media/sf_sharing/Simulation testbed for Stage 1/Datasets/Simulink/IED_TRSF1_physical.csv","a");
    	if(fp==NULL) {
        printf("File cannot open! " );
        exit(0);
     	}
 
    //write values to file//
    	fprintf(fp,"%u,", (uint32_t) (localtimestamp % 1000));
    	
    	fprintf(fp,"%f,", UTCtime/1000);
    	
	for (i=0; i<4; i++) {
	fprintf(fp,"%d,", CBstval[i]);
	}
	
	for (i=0; i<6; i++) {
	fprintf(fp,"%d,", stations_data[0].analogIn[i]);
	}
	
	fprintf(fp,"\n");
	     
    //Close file//
    	fclose(fp);

//#################store physical parameters with timestamp#########################//
  		
		//printf("Station 2\nPressure: %d\t\t\tPump: %d\t\tValve: %d\n", stations_data[1].analogIn[0], stations_data[1].digitalOut[0], stations_data[1].digitalOut[1]);
		//printf("Station 3\nPressure: %d\t\t\tPump: %d\t\tValve: %d\n", stations_data[2].analogIn[0], stations_data[2].digitalOut[0], stations_data[2].digitalOut[1]);
		//printf("Station 4\nPressure: %d\t\t\tPump: %d\t\tValve: %d\n", stations_data[3].analogIn[0], stations_data[3].digitalOut[0], stations_data[3].digitalOut[1]);
		//printf("Station 5\nPressure: %d\tTank: %d\t\tPump: %d\t\tValve: %d\n\n", stations_data[4].analogIn[0], stations_data[4].analogIn[1], stations_data[4].digitalOut[0], stations_data[4].digitalOut[1]);
		pthread_mutex_unlock(&bufferLock);

		sleep_ms(100);
	}

}
