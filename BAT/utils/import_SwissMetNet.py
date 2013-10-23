# Incremental loading into PostGres DataBase of meteo data
# SITN 2013
import os, sys, shutil, csv, psycopg2, uuid
from datetime import datetime as dt
from matching_dictionnary import Combilog
from matching_dictionnary import SwissMetNet
from datetime import datetime
from application_params import *

conn = psycopg2.connect(host=connParams['host'], database=connParams['database'], user=connParams['user'], password=connParams['password'])
cur = conn.cursor()

    
# START loading data into postgres database

def importSwissMetNet(fileList):
    nbFile = len(fileList)
    k = 0
    for filename in fileList:
        sqlCheckImport = "select count(*) as countItem from stations_air.import_log where filename = '" + filename+ "';"
        cur.execute(sqlCheckImport)
        isAlreadyLoaded = int(cur.fetchone()[0])
        if isAlreadyLoaded == 0:
            k+=1
            print 'loading file : ' + filename
            filePath = targetDir + 'swissMetNet/' + filename
            f = open(filePath)
            csv.register_dialect('SwissMetNet', delimiter=' ', skipinitialspace=1)
            reader = csv.reader(f, dialect='SwissMetNet')
            # skip 2 first lines
            reader.next()
            reader.next()
            # get headers
            headers = reader.next()
            targetFields = ''
            for header in headers:
                targetFields += SwissMetNet[header] +','
            targetFields = 'idobj,' + targetFields[0:-1]
            # insert each row into table
            for row in reader:
                idobj = str(uuid.uuid4())
                # replace dummy/empty values
                for i in range(0,len(row)):
                    if row[i].strip() =='-':
                        row[i]='-9999'
                # change dateTime format...
                recordDateTime = datetime.strptime(str(row[1]),'%Y%m%d%H%M')
                row[1] = str(recordDateTime)
                # check if record exist for given station and date time
                sqlCheckRecordExists = "select count(*) as countItem from stations_air.meteo_log where station_id = '" + row[0] + "' and date_time = '" + row[1] + "';"
                cur.execute(sqlCheckRecordExists)
                isRecordLoaded = int(cur.fetchone()[0])
                # if no record: insert
                if isRecordLoaded == 0:
                    sql = "insert into stations_air.meteo_log ("
                    sql += targetFields + ") VALUES ('"+ idobj + "'," + str(row)[1 : -1] + ");"
                    cur.execute(sql)
                # if record exists already, update with most recent
                elif isRecordLoaded == 1:
                    sql = "update stations_air.meteo_log set(" + targetFields + ") =  ('" + idobj + "',"+ str(row)[1 : -1] + ") " 
                    sql += "where station_id = '" + row[0] + "' and date_time = '" + row[1] + "';"      
                    cur.execute(sql)
                
            idobjLog = idobj = str(uuid.uuid4())
            currentDateTime = str(dt.now().isoformat(' '))[0:19].replace('-','').replace(':','')
            sqlLog = "insert into stations_air.import_log (idobj, filename, importdatetime, sucess) values ('" + idobjLog + "','" + filename + "','" + currentDateTime + "', 'true');"
            cur.execute(sqlLog)
        else:
            print 'skipping file : ' + filename + ' => already loaded into the database'
        conn.commit()
    cur.close()
    conn.close()
    print 'loading of swissMetNet data successfull, ' + str(k) + ' new files loaded into the database'