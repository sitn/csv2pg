# Incremental loading into PostGres DataBase of meteo data
# SITN 2013
import os, sys, shutil, csv, psycopg2, uuid
from datetime import datetime as dt
from matching_dictionnary import Combilog
from matching_dictionnary import SwissMetNet
from application_params import *

def importCombilog(fileList):    

    conn = psycopg2.connect(host=connParams['host'], database=connParams['database'], user=connParams['user'], password=connParams['password'])
    cur = conn.cursor()

    # START Combilog Data
    nbFile = len(fileList)
    k = 0
    maxImport = 145 # ugly data => ugly cleaning
    for filename in fileList:
        station_id =filename[0:3]
        print station_id
        k+=1
        print 'loading file : ' + filename
        filePath = targetDir + 'Combilog/' + filename
        f = open(filePath)
        csv.register_dialect('Combilog', delimiter=';', skipinitialspace=1)
        reader = csv.reader(f, dialect='Combilog')
        # get headers
        headers = reader.next()
        targetFields = ''
        for header in headers:
            targetFields += Combilog[header] +','
        targetFields = 'idobj, station_id, '+ targetFields[0:-1]
        # insert each row into table
        rowImportNumber = 0
        for row in reader:
            rowImportNumber+=1
            if rowImportNumber <= maxImport:
                idobj = str(uuid.uuid4())
                 # replace dummy/empty values
                for i in range(0,len(row)):
                    if row[i].strip()=='-':
                        row[i]='-9999'
                sqlCheckRecordExists = "select count(*) as countItem from stations_air.meteo_log where station_id = '" + station_id + "' and date_time = '" + str(row[0]) + "';"
                cur.execute(sqlCheckRecordExists)
                isRecordLoaded = int(cur.fetchone()[0])
                # if no record: insert
                if isRecordLoaded == 0:
                    sql = "insert into stations_air.meteo_log ("
                    sql += targetFields + ") VALUES ('"+ idobj + "','" + station_id +  "'," + str(row)[1 : -1] +");"
                    cur.execute(sql)
                # if record exists already, update with most recent
                elif isRecordLoaded == 1:
                    sql = "update stations_air.meteo_log set(" + targetFields + ") =  ('"+ idobj + "','" + station_id +  "'," + str(row)[1 : -1] +") " 
                    sql += "where station_id = '" + station_id + "' and date_time = '" + str(row[0]) + "';"      
                    cur.execute(sql)
        conn.commit()
    cur.close()
    conn.close()
    print 'loading of Combilog data successfull, ' + str(k) + ' new files loaded into the database'
