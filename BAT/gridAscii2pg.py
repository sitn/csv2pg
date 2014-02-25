import os, sys, shutil, csv, psycopg2, uuid, filecmp, subprocess, zlib
from datetime import datetime, timedelta
from application_params import *

no2Code = 'NE_NO'
o3Code = 'NE_O3'
pm10Code = 'NE_PM'

# Clear the "variable/new folder" in which FME gets the file it has to load into the DB

for file in os.listdir(gridTargetDir + no2Dir + '/new'):
    os.remove(gridTargetDir + no2Dir + '/new' + '/' + file)
    
for file in os.listdir(gridTargetDir + o3Dir + '/new'):
    os.remove(gridTargetDir + o3Dir + '/new' + '/' + file)
    
for file in os.listdir(gridTargetDir + pm10Dir + '/new'):
    os.remove(gridTargetDir + pm10Dir + '/new' + '/' + file)

# Import and extract new files into main folder, make a copy in the "new" subfolder, later used by FME

for filename in os.listdir(gridSourceDir):

    inputFile =  gridSourceDir + '/' + filename # Remote disk on which meteotest data are delivered
    targetFile =  gridTargetDir + '/' + filename # Local disk on which archives will be extracted
     
    # Get the current system time
    today = datetime.today()
    
    # initialize a few variables
    cmd = ''
    strFileDate = ''
    destFilePath = ''
    destFileRootPath = ''
    
    # adapt for each model
    if filename[0:5] == no2Code:
        strFileDate = filename[7:-7].replace('_', ' ') + '0000'
        fileDate = datetime.strptime(strFileDate , '%Y%m%d %H%M%S')
        cmd = '7za.exe e  ' + inputFile + ' -o' + gridTargetDir + no2Dir
        destFileRootPath =  gridTargetDir + no2Dir + '/' 
        destFilePath =  destFileRootPath + filename[:-3]
    elif filename[0:5] == o3Code: 
        strFileDate = filename[6:-7].replace('_', ' ') + '0000'
        fileDate = datetime.strptime(strFileDate , '%Y%m%d %H%M%S')
        cmd = '7za.exe e  ' + inputFile + ' -o' + gridTargetDir + o3Dir 
        destFileRootPath =  gridTargetDir + o3Dir + '/' 
        destFilePath =  destFileRootPath + filename[:-3]     
    elif filename[0:5] == pm10Code: 
        strFileDate = filename[8:-7].replace('_', ' ') + '0000'
        fileDate = datetime.strptime(strFileDate , '%Y%m%d %H%M%S')
        cmd = '7za.exe e  ' + inputFile + ' -o' + gridTargetDir + pm10Dir
        destFileRootPath =  gridTargetDir + pm10Dir + '/' 
        destFilePath =  destFileRootPath + filename[:-3]  
    

    # Copy new files in destination folder
    if not os.path.exists(destFilePath):
        
        # Check if file not too old
        if today - fileDate <= timedelta(days = (nbDaysGrid)):
            
            # extract the file using 7zip executable launched by python subprocess
            process = subprocess.Popen(cmd)
            process.communicate()
            shutil.copy(destFileRootPath + filename[0:-3], destFileRootPath + 'new/' + filename[0:-3])

            print 'File: ' + inputFile + ' has now been extracted to destination directory'
        else:  
            print 'Not copying outdated file file already existing in destination folder: ' + destFilePath
    
    # Remove old files         
    if os.path.exists(destFilePath) and today - fileDate > timedelta(days = (nbDaysGrid)):
        os.remove(destFilePath)
        print 'Deleted old file: ' + destFilePath

# Delete old records from the database

print 'Removing old records from database'
# db connection
conn = psycopg2.connect(host=connParams['host'], database=connParams['database'], user=connParams['user'], password=connParams['password'])
oldestRecordKept = datetime.today()-timedelta(days = nbDaysGrid)
cur = conn.cursor()
sql = "delete from stations_air.no2_grid where date_time < '" + str(oldestRecordKept) + "';"
cur.execute(sql)
sql = "delete from stations_air.o3_grid where date_time < '" + str(oldestRecordKept) + "';"
cur.execute(sql)
sql = "delete from stations_air.pm10_grid where date_time < '" + str(oldestRecordKept) + "';"
cur.execute(sql)
conn.commit()
cur.close()
conn.close()
print 'removed records older that ' + str(nbDaysGrid) + ' days from the datebase'