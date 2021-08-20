from scapy.all import *
import csv
import sys

TemPCAP=rdpcap("/media/sf_sharing/Simulation testbed for Stage 1/Datasets/Network traffics/{}.pcapng".format(sys.argv[1]))

with open('/media/sf_sharing/Simulation testbed for Stage 1/Datasets/Network traffics/{}.csv'.format(sys.argv[1]), mode='w') as traffic:
    traffic = csv.writer(traffic, delimiter=',', quotechar='"', quoting=csv.QUOTE_MINIMAL)
    
    traffic.writerow(['pkt arrive time in UTC', 'MACsrc', 'MACdst', 'APPID', 'GOOSElength', 'gocbRef', 'Timeallowedtolive', 'datset', 'goID','t', 'stNum', 'sqNum', 'istest?', 'num of data', 'data'])   
    gocbRef=datset=goID=""
    alldata=[]
     
    for pkt in TemPCAP:
    	if hex(raw(pkt)[16]) == '0x88' and hex(raw(pkt)[17]) == '0xb8':
    		len_GOOSE=pkt.load[3]
    		len_total=len_GOOSE+18
    		len_gocbRef=pkt.load[12]
    		len_ttl=pkt.load[13+len_gocbRef+1]
    		len_datset=pkt.load[13+len_gocbRef+2+len_ttl+1]
    		len_goID=pkt.load[13+len_gocbRef+2+len_ttl+2+len_datset+1]
    		
    		SoT=13+len_gocbRef+2+len_ttl+2+len_datset+2+len_goID+2
    		len_stnum=pkt.load[SoT+9]
    		len_sqnum=pkt.load[SoT+10+len_stnum+1]
    		
    		SoData=SoT+10+len_stnum+2+len_sqnum+3+2+pkt.load[SoT+10+len_stnum+2+len_sqnum+3+1]+3+5
    		
    		# APPID #
    		APPID=hex(pkt.load[0]*16**2+pkt.load[1])
    		
    		# gocbRef #
    		for x in range(len_gocbRef):
    			gocbRef+=chr(pkt.load[13+x])
    		
    		# timeallowedtolive #
    		if len_ttl == 1:
    			TLL=pkt.load[13+len_gocbRef+2]
    		if len_ttl == 2:
    			TLL=pkt.load[13+len_gocbRef+2]*256+pkt.load[13+len_gocbRef+3]
    		
    		# datset #
    		for x in range(len_datset):
    			datset+=chr(pkt.load[13+len_gocbRef+6+x])
    		
    		# goID #
    		for x in range(len_goID):
    			goID+=chr(pkt.load[13+len_gocbRef+6+len_datset+2+x])
    		
    		# t (the time at which the last state change was detected) #	
    		t=pkt.load[SoT]*16**6+pkt.load[SoT+1]*16**4+pkt.load[SoT+2]*16**2+pkt.load[SoT+3]
    		
    		# stNum #
    		if len_stnum == 1:
    			stNum=pkt.load[SoT+10]
    		if len_stnum == 2:
    			stNum=pkt.load[SoT+10]*16**2+pkt.load[SoT+11]
    		if len_stnum == 3:
    			stNum=pkt.load[SoT+10]*16**4+pkt.load[SoT+11]*16**2+pkt.load[SoT+12]
    		if len_stnum == 4:
    			stNum=pkt.load[SoT+10]*16**6+pkt.load[SoT+11]*16**4+pkt.load[SoT+12]*16**2+pkt.load[SoT+13]
    		if len_stnum == 5:
    			stNum=pkt.load[SoT+10]*16**8+pkt.load[SoT+11]*16**6+pkt.load[SoT+12]*16**4+pkt.load[SoT+13]*16**2+pkt.load[SoT+14]
    		
    		# sqNum #
    		if len_sqnum == 1:
    			sqNum=pkt.load[SoT+12+len_stnum]
    		if len_sqnum == 2:
    			sqNum=pkt.load[SoT+12+len_stnum]*16**2+pkt.load[SoT+13+len_stnum]
    		if len_sqnum == 3:
    			sqNum=pkt.load[SoT+12+len_stnum]*16**4+pkt.load[SoT+13+len_stnum]*16**2+pkt.load[SoT+14+len_stnum]
    		if len_sqnum == 4:
    			sqNum=pkt.load[SoT+12+len_stnum]*16**6+pkt.load[SoT+13+len_stnum]*16**4+pkt.load[SoT+14+len_stnum]*16**2+pkt.load[SoT+15+len_stnum]
    		if len_sqnum == 5:
    			sqNum=pkt.load[SoT+12+len_stnum]*16**8+pkt.load[SoT+13+len_stnum]*16**6+pkt.load[SoT+14+len_stnum]*16**4+pkt.load[SoT+15+len_stnum]*16**2+pkt.load[SoT+16+len_stnum]
    		
    		# test #
    		simulation=bool(pkt.load[SoT+10+len_stnum+2+len_sqnum+2])
    		
    		# allData #
    		numofalldata=pkt.load[SoData-3]
    		for x in range(numofalldata):
    			alldata.append(pkt.load[SoData-1+3*(x+1)])
    			
    		traffic.writerow([pkt.time, pkt.src, pkt.dst, APPID, len_GOOSE, gocbRef, TLL, datset, goID, t, stNum, sqNum, simulation, numofalldata, alldata])
    		gocbRef=datset=goID=""
    		alldata=[]
    		
