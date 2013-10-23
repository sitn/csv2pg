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

    for filename in fileList:
        if filename[0:16] == 'airmet_kt_CHA_NE':
            station_id = '999'
        elif filename[0:16] == 'airmet_kt_PAY_NE':
            station_id = '998'
        # if isAlreadyLoaded == 0:
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
        targetFields += 'sourcefile_name'
        reader = csv.reader(f,dialect='Nabel')
        for row in reader:
            idobj = str(uuid.uuid4())
            # replace dummy/empty values
            for i in range(0,len(row)):
                if row[i].strip()=='':
                    row[i]='-9999'
            # check if the record is already loaded into database
            sqlCheckRecordExists = "select count(*) as countItem from stations_air.quality_log where station_id = '" + station_id + "' and date_time = '" + row[0] + "';"
            cur.execute(sqlCheckRecordExists)
            isRecordLoaded = int(cur.fetchone()[0])  
            if isRecordLoaded == 0:
                sql = "insert into stations_air.quality_log ("
                sql += targetFields + ") VALUES ('"+ idobj + "','" + station_id + "',"+ str(row)[1 : -1]
                sql += ",'" + filename + "');"
                
                cur.execute(sql)
            elif isRecordLoaded == 1:
                sql = "update stations_air.quality_log set(" + targetFields + ") =  ('" + idobj + "','" + station_id + "',"+ str(row)[1 : -1] + ") " 
                sql += "where station_id = '" + station_id + "' and date_time = '" + row[0] 
                sql += ",'" + filename + "');"
                cur.execute(sql)
        conn.commit()
    cur.close()
    conn.close()
    print 'loading of Nabel data successfull, ' + str(k) + ' new files loaded into the database'