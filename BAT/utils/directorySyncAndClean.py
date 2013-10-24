import os, sys, shutil, csv, psycopg2, uuid, filecmp
from datetime import datetime, timedelta
from application_params import *
   
def dirSync():

    dictFilesToLoad = {}
    nbNewFilesCopied = 0
    nbModifiedFilesCopied = 0

    print 'checking for new or modified files in repository : ' + sourceDir

    # copy file from source directory

    for dir in directories:
        filesToLoad = []
        for filename in os.listdir(sourceDir + dir):
            # define current directory
            inputFile = sourceDir + dir + '/' + filename
            targetFile = targetDir + dir + '/' + filename
            date = datetime.today() # initialize object
            
            # get the file date out of it's name as it's more reliable here
            # needed to copy only file created within the choosen number of days
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
                
            # only copy file produced during the choosen time interval
            if datetime.today() - date <= timedelta(days = nbDays):
                # if the file doesn't exist in target sir, it's a new one and we copy it
                if not os.path.exists(targetDir + dir + '/' + filename):
                    shutil.copy(inputFile,targetFile)
                    nbNewFilesCopied += 1
                    filesToLoad.append([filename, False])
                    print targetFile                 
                # if it does exist, we need to check if it has been modified
                else:
                    # check if file has been overwritten in remote directory
                    fileModified = filecmp.cmp(inputFile, targetFile)
                    
                    if not fileModified:
                        shutil.copy(inputFile,targetFile)
                        filesToLoad.append([filename, True])
                        nbModifiedFilesCopied  += 1    
        dictFilesToLoad[dir] = filesToLoad
 
    print 'copied ' + str(nbNewFilesCopied) + ' new files and ' + str(nbModifiedFilesCopied) + ' modified files'
    f = open('log.txt', 'a')
    f.write('\nSynchronization task completed')
    f.close()
    return dictFilesToLoad
    
# clean target directory from old files: iterate on target directory
   
def removeOldFiles():
    print 'Removing old files from target directory'
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
            if datetime.today() - date > timedelta(days = (nbDays + 1)):
                os.remove(targetFile)
                print 'Removed old file : ' + targetFile + ' from directory'
    print 'directory cleaning finished'
 
# remove old records from database
 
def removeOldRecords():

    # db connection
    conn = psycopg2.connect(host=connParams['host'], database=connParams['database'], user=connParams['user'], password=connParams['password'])

    print 'Removing old records from database'
    oldestRecordKept = datetime.today()-timedelta(days = nbDays)
    cur = conn.cursor()
    sql = "delete from stations_air.meteo_log where date_time < '" + str(oldestRecordKept) + "';"
    cur.execute(sql)
    conn.commit()
    cur.close()
    conn.close()
    print 'removed records older that ' + str(nbDays) + ' days from the datebase'
    
    
def fullDataBaseReload():

    # empty database
    conn = psycopg2.connect(host=connParams['host'], database=connParams['database'], user=connParams['user'], password=connParams['password'])

    print 'Removing old files from db'
    cur = conn.cursor()
    sql = "delete from stations_air.meteo_log;"
    cur.execute(sql)
    sql = "delete from stations_air.quality_log;"
    cur.execute(sql)
    conn.commit()
    cur.close()
    conn.close()
    
    # empty folders
    
    for dir in directories:
        curDir = targetDir + dir
        fileList = os.listdir(curDir)
        for file in fileList:
            os.remove(curDir + '/' + file)
            
    print 'Removed all records in database and directories'
    f = open('log.txt', 'a')
    f.write('\nRemoved all records in database and directories')
    f.close()
    
