# Incremental copy of meteo and air quality data files (customized csv files) from repository into local directory and 
# loading into PostGres DataBase
# SITN 2013

import os, sys, shutil, csv, psycopg2, uuid
from datetime import datetime as dt
from matching_dictionnary import SamWi
from matching_dictionnary import Nabel
from datetime import datetime, timedelta
from application_params import *

conn = psycopg2.connect(host=connParams['host'], database=connParams['database'], user=connParams['user'], password=connParams['password'])
cur = conn.cursor()

# SamWi Data

def importSamWi(fileList):
    nbFile = len(fileList)
    k = 0

    for item in fileList:
        filename = item[0]
        isNewFile = item[1]
        station_id = filename[0:3]
        # if isAlreadyLoaded == 0:
        k+=1
        print 'loading file : ' + filename
        filePath = targetDir + 'SamWi/' + filename
        f = open(filePath)
        csv.register_dialect('SamWi', delimiter=',', skipinitialspace=1)
        reader = csv.reader(f, dialect='SamWi')
        l1 = reader.next()
        reader.next()
        reader.next()
        m = 0
        for v in l1:
            m+=1
            if v=='':
                startIndex = m
        l1 = l1[startIndex:len(l1)]   
        headers = l1
        targetFields = ''
        t = 0
        u = 0
        for header in headers:
            # ugly data = ugly cleaning !!!
            if header=='Vvit' and t==0:
                targetFields += 'vvit_2,'
                t+=1
            elif header=='PM10-C' and u==0:
                targetFields += 'pm10_c_2,'
                u+=1
            else:
                targetFields += SamWi[header] +','   
        targetFields = 'idobj,station_id,date_time,' + targetFields
        targetFields = targetFields[0:-1]
        targetFields += ',sourcefile_name'
        reader = csv.reader(f,dialect='SamWi')
        for row in reader:
            dateString = str(row[0] + ' ' + row[1])
            date = datetime.strptime(dateString, '%d.%m.%Y %H:%M')
            if date <= datetime.today() - timedelta(hours = 1):
                idobj = str(uuid.uuid4())
                # replace dummy/empty values
                for i in range(0,len(row)):
                    if row[i].strip()=='':
                        row[i]='-9999'
                dateTime = row[0] + ' ' + row [1]
                sqlCheckRecordExists = "select count(*) as countItem from stations_air.quality_log where station_id = '" + station_id + "' and date_time = '" + str(dateTime) + "';"
                cur.execute(sqlCheckRecordExists)
                isRecordLoaded = int(cur.fetchone()[0])  
                if isRecordLoaded == 0:
                    sql = "insert into stations_air.quality_log ("
                    sql += targetFields + ") VALUES ('"+ idobj + "','" + station_id + "','" + dateTime + "',"+ str(row[2:len(row)])[1 : -1] 
                    sql += ",'" + filename + "');"
                    cur.execute(sql)
                elif isRecordLoaded > 0:
                    sql = "update stations_air.quality_log set(" + targetFields + ") =  ('"+ idobj + "','" + station_id + "','" + dateTime + "',"+ str(row[2:len(row)])[1 : -1] 
                    sql += ",'" + filename + "') "    
                    sql += "where station_id = '" + station_id + "' and date_time = '" + str(dateTime)  + "'"                
                    cur.execute(sql)
                conn.commit()
    cur.close()
    conn.close()
    print 'loading of SamWi data successfull, ' + str(k) + ' new files loaded into the database'
    f = open('log.txt', 'a')
    f.write('\nloading of SamWi data successfull, ' + str(k) + ' new files loaded into the database')
    f.close()