# Incremental copy of meteo and air quality data files (customized csv files) from repository into local directory and 
# loading into PostGres DataBase
# SITN 2013

import os, sys, shutil, csv, psycopg2, uuid
from datetime import datetime as dt
from matching_dictionnary import SamWi
from matching_dictionnary import Nabel
from application_params import *

conn = psycopg2.connect(host=connParams['host'], database=connParams['database'], user=connParams['user'], password=connParams['password'])
cur = conn.cursor()

# Nabel Data

def importNabel(fileList):

    nbFile = len(fileList)
    k = 0

    for item in fileList:
        filename = item[0]
        isFileModified = item[1]
        
        if isFileModified:
            sql = "delete from stations_air.quality_log where sourcefile_name = '" + filename + "';" 
            cur.execute(sql)
            
        if filename[0:16] == 'airmet_kt_CHA_NE':
            station_id = '999'
        elif filename[0:16] == 'airmet_kt_PAY_NE':
            station_id = '998'
            
        k+=1
        print 'loading file : ' + filename
        filePath = targetDir + 'Nabel/' + filename
        f = open(filePath)
        csv.register_dialect('Nabel', delimiter=';', skipinitialspace=1)
        reader = csv.reader(f, dialect='Nabel')
        headers = reader.next()
        headers = headers[1:len(headers)] # skip first item (blank)
        reader.next() 
        targetFields = ''
        for header in headers:
            targetFields += Nabel[header] +',' 
        targetFields = 'idobj,station_id,date_time,' + targetFields
        targetFields = targetFields[0:-1]
        targetFields += ',sourcefile_name'
        reader = csv.reader(f,dialect='Nabel')
        for row in reader:
            idobj = str(uuid.uuid4())
            # replace dummy/empty values
            for i in range(0,len(row)):
                if row[i].strip()=='':
                    row[i]='-9999'  
            sql = "insert into stations_air.quality_log ("
            sql += targetFields + ") VALUES ('"+ idobj + "','" + station_id + "',"+ str(row)[1 : -1]
            sql += ",'" + filename + "');"

        conn.commit()
    cur.close()
    conn.close()
    print 'loading of Nabel data successfull, ' + str(k) + ' files loaded into the database'
    f = open('log.txt', 'a')
    f.write('\nloading of Nabel data successfull, ' + str(k) + ' files loaded into the database')
    f.close()