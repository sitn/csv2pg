# Incremental copy of meteo and air quality data files (customized csv files) from repository into local directory 
# SITN 2013
import os, sys, shutil, csv, psycopg2, uuid
from datetime import datetime, timedelta
from application_params import *

# copy new file into import directory

directories = ['SamWi','Nabel']

print 'checking new file in repository : ' + sourceDir

# copy file from source directory

for dir in directories:
    for filename in os.listdir(sourceDir + dir):
        inputFile = sourceDir + dir + '/' + filename
        targetFile = targetDir + dir + '/' + filename
        date = datetime.today() # initialize object
        if dir == 'Nabel':
            dateString = filename[17:25]
            date = datetime.strptime(dateString, '%d%m%Y')
        elif dir == 'Combilog':
            dateString = filename[6:14]
            date = datetime.strptime(dateString, '%Y%m%d')
        elif dir == 'SwissMetNet':
            dateString = filename[7:19]
            date = datetime.strptime(dateString, '%Y%m%d%H%M')
        elif dir == 'SamWi':
            f = open(inputFile)
            csv.register_dialect('SamWi', delimiter=',', skipinitialspace=1)
            reader = csv.reader(f, dialect='SamWi')
            l1 = reader.next()
            reader.next()
            reader.next()
            dateString = str(reader.next()[0])
            date = datetime.strptime(dateString, '%d.%m.%Y')
            f.close()
        if datetime.today() - date <= timedelta(days = nbDays):
            shutil.copy(inputFile,targetFile)
            print 'copying...' + targetFile + '... from date : ' + str(date)
        else:
            print 'not copying outdated file : ' + inputFile + ' from date: ' + str(date) 
print 'copy of new files finished'

# clean target directory from old files
for dir in directories:
    for filename in os.listdir(targetDir + dir):
        targetFile = targetDir + dir + '/' + filename
        date = datetime.today() # initialize object
        if dir == 'Nabel':
            dateString = filename[17:25]
            date = datetime.strptime(dateString, '%d%m%Y')
        elif dir == 'Combilog':
            dateString = filename[6:14]
            date = datetime.strptime(dateString, '%Y%m%d')
        elif dir == 'SwissMetNet':
            dateString = filename[7:18]
            date = datetime.strptime(dateString, '%Y%m%d%H%M')
        elif dir == 'SamWi':
            f = open(targetFile)
            csv.register_dialect('SamWi', delimiter=',', skipinitialspace=1)
            reader = csv.reader(f, dialect='SamWi')
            l1 = reader.next()
            reader.next()
            reader.next()
            dateString = str(reader.next()[0])
            date = datetime.strptime(dateString, '%d.%m.%Y')
            f.close()
        if datetime.today() - date > timedelta(days = nbDays):
            os.remove(targetFile)
            print 'Removed old file : ' + targetFile + ' from directory'
print 'directory cleaning finished'

# remove old records from database
oldestRecordKept = datetime.today()-timedelta(days = nbDays)
conn = psycopg2.connect(host=connParams[host], database=connParams[database], user=connParams[user], password=connParams[password])
cur = conn.cursor()
sql = "delete from stations_air.quality_log where date_time < '" + str(oldestRecordKept) + "';"
cur.execute(sql)
conn.commit()
cur.close()
conn.close()

print 'removed records older that ' + str(nbDays) + ' days from the datebase'