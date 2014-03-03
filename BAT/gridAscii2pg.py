# This scripts implements following procedures:
# - Incremental copy of hourly air pollution modelling maps in ESRI gris ascii format to local directory
# - Extraction from the .gz format using 7zip.exe executable
# - Removal of old files and records
# - Generation of colored images accordding to color ramps defined in text files (GDAL style)
# - Update of PG Table used for Mapserver WMSTIME layers publications
# ### INPUTS ###
# ESRI grid ascii file compressed in gz format
# Color ramps definitions
# Please adapt local paths config in application_params.py file
# ###
# (c) SITN 2013-2014

import os, sys, shutil, csv, psycopg2, uuid, filecmp, subprocess, zlib
from datetime import datetime, timedelta
from application_params import *

# db connection
conn = psycopg2.connect(host=connParams['host'], database=connParams['database'], user=connParams['user'], password=connParams['password'])

no2Code = 'NE_NO'
o3Code = 'NE_O3'
pm10Code = 'NE_PM'

# Clear the "variable/new folder" in which FME gets the file it has to load into the DB

# for file in os.listdir(gridTargetDir + no2Dir + '/new'):
    # os.remove(gridTargetDir + no2Dir + '/new' + '/' + file)
    
# for file in os.listdir(gridTargetDir + o3Dir + '/new'):
    # os.remove(gridTargetDir + o3Dir + '/new' + '/' + file)
    
# for file in os.listdir(gridTargetDir + pm10Dir + '/new'):
    # os.remove(gridTargetDir + pm10Dir + '/new' + '/' + file)

# Import and extract new files into main folder, make a copy in the "new" subfolder, later used by FME

for filename in os.listdir(gridSourceDir):

    idobj = str(uuid.uuid4())
    inputFile =  gridSourceDir + '/' + filename # Remote disk on which meteotest data are delivered
    targetFile =  gridTargetDir + '/' + filename # Local disk on which archives will be extracted
     
    # Get the current system time
    today = datetime.today()
    
    # initialize a few variables
    cmd = ''
    gdalcmd = ''
    strFileDate = ''
    destFilePath = ''
    destFileRootPath = ''
    destImageFolder = ''
    sqlInsert = ''
    filePath = ''
    asciigrid_path = ''
    relFilePath = ''
    sqlDel = ''
    
    # adapt for each model
    if filename[0:5] == no2Code:
        strFileDate = filename[7:-7].replace('_', ' ') + '0000'
        fileDate = datetime.strptime(strFileDate , '%Y%m%d %H%M%S')
        cmd = '7za.exe e  ' + inputFile + ' -o' + gridTargetDir + no2Dir
        destFileRootPath =  gridTargetDir + no2Dir + '/' 
        destFilePath =  destFileRootPath + filename[:-3]
        destImageFolder = mapserverFileDir + '/no2/'
        filePath = destImageFolder + filename[:-7] + '.tif'
        # relFilePath = '/no2/' + filename[:-7] + '.tif'
        gdalcmd = gdalpath + '/gdaldem.exe color-relief ' + destFilePath + ' ' + no2ColorRamp + ' ' + filePath + ' -alpha -co ALPHA=YES'
        
        sqlInsert = "insert into stations_air.no2_tileindex (idobj, date_time, filepath, asciigrid_path, geom)"
        sqlInsert += " VALUES ('"+ idobj + "','" + strFileDate +  "','" + filePath + "','" + destFilePath                  
        sqlInsert += "', st_geomfromtext('POLYGON((523500 188900, 523500 224100, 573500 224100, 573500 188900, 523500 188900))', 21781));"
        
        sqlDel = "delete from stations_air.no2_tileindex where date_time = '" +  strFileDate + "';"
      

    elif filename[0:5] == o3Code: 
        strFileDate = filename[6:-7].replace('_', ' ') + '0000'
        fileDate = datetime.strptime(strFileDate , '%Y%m%d %H%M%S')
        cmd = '7za.exe e  ' + inputFile + ' -o' + gridTargetDir + o3Dir 
        destFileRootPath =  gridTargetDir + o3Dir + '/' 
        destFilePath =  destFileRootPath + filename[:-3]
        destImageFolder = mapserverFileDir + '/o3/'
        filePath = destImageFolder + filename[:-7] + '.tif'
        # relFilePath = '/o3/' + filename[:-7] + '.tif'
        gdalcmd = gdalpath + '/gdaldem.exe color-relief ' + destFilePath + ' ' + o3ColorRamp + ' ' + filePath + ' -alpha -co ALPHA=YES'
        
        sqlInsert = "insert into stations_air.o3_tileindex (idobj, date_time, filepath, asciigrid_path, geom)"
        sqlInsert += " VALUES ('"+ idobj + "','" + strFileDate +  "','" + filePath + "','" + destFilePath                   
        sqlInsert += "', st_geomfromtext('POLYGON((523500 188900, 523500 224100, 573500 224100, 573500 188900, 523500 188900))', 21781));"
        
        sqlDel = "delete from stations_air.o3_tileindex where date_time = '" +  strFileDate + "';"

    elif filename[0:5] == pm10Code: 
        strFileDate = filename[8:-7].replace('_', ' ') + '0000'
        fileDate = datetime.strptime(strFileDate , '%Y%m%d %H%M%S')
        cmd = '7za.exe e  ' + inputFile + ' -o' + gridTargetDir + pm10Dir
        destFileRootPath =  gridTargetDir + pm10Dir + '/' 
        destFilePath =  destFileRootPath + filename[:-3]  
        destImageFolder = mapserverFileDir + '/pm10/'
        filePath = destImageFolder + filename[:-7] + '.tif'
        # relFilePath = '/pm10/' + filename[:-7] + '.tif'
        gdalcmd = gdalpath + '/gdaldem.exe color-relief ' + destFilePath + ' ' + pm10ColorRamp + ' ' + filePath + ' -alpha -co ALPHA=YES'  

        sqlInsert = "insert into stations_air.pm10_tileindex (idobj, date_time, filepath, asciigrid_path, geom)"
        sqlInsert += " VALUES ('"+ idobj + "','" + strFileDate +  "','" + filePath  + "','" + destFilePath                  
        sqlInsert += "', st_geomfromtext('POLYGON((523500 188900, 523500 224100, 573500 224100, 573500 188900, 523500 188900))', 21781));"
        
        sqlDel = "delete from stations_air.pm10_tileindex where date_time = '" +  strFileDate + "';"

    # Copy new files in destination folder
    if not os.path.exists(destFilePath):
        
        # Check if file not too old
        if today - fileDate <= timedelta(days = (nbDaysGrid)):
            
            # extract the file using 7zip executable launched by python subprocess
            process = subprocess.Popen(cmd)
            process.communicate()
            # shutil.copy(destFileRootPath + filename[0:-3], destFileRootPath + 'new/' + filename[0:-3])
            
            # Generate the colored image using gdaldem.exe
            process = subprocess.Popen(gdalcmd)
            process.communicate()
            print 'Image: ' + filePath + ' has now been created'
            
            # Delete tileindex entry if it exists already in db
            cur = conn.cursor()
            cur.execute(sqlDel)
            conn.commit()
            cur.close()
            
            # Write file time and path into db table
            cur = conn.cursor()
            cur.execute(sqlInsert)
            conn.commit()
            cur.close()

        else:  
            print 'Not copying outdated file file already existing in destination folder: ' + destFilePath
    
    # Remove old ascii files         
    if os.path.exists(destFilePath) and today - fileDate > timedelta(days = (nbDaysGrid)):
        os.remove(destFilePath)
        print 'Deleted old file: ' + destFilePath
        
    # Remove old image files
    if os.path.exists(filePath) and today - fileDate > timedelta(days = (nbDaysGrid)):
        os.remove(filePath)
        print 'Deleted old file: ' + filePath
# Delete old records from the database

print 'Removing old records from database'


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