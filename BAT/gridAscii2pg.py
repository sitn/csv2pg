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


for filename in os.listdir(gridSourceDir):

    inputFile =  gridSourceDir + '/' + filename
    
    targetFile =  gridTargetDir + '/' + filename
    
    # print 'Extracting and copying gridascii file: ' + filename
    
    # Import only data that are within a given time range
    today = datetime.today()
    
    
    # shutil.copy(inputFile, targetFile)
    cmd = ''
    strFileDate = ''
    destFilePath = ''
    destFileRootPath = ''
    
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
                
    if os.path.exists(destFilePath) and today - fileDate > timedelta(days = (nbDaysGrid)):
        os.remove(destFilePath)
        print 'Deleted old file: ' + destFilePath
