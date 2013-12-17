# Directory synchronizer & Postgres DB uploader for CSV meteo and air quality data
# SITN 2013

import os, sys
from datetime import datetime, timedelta
from application_params import *
from utils.directorySyncAndClean import *
from utils.import_Combilog import *
from utils.import_SwissMetNet import *
from utils.import_SamWi import *
from utils.import_Nabel import *

startUpdateTime = datetime.now()
f = open('log.txt', 'a')
f.write('\n############################')
f.write('\n\nMeteo update task started at ' + str(startUpdateTime))
f.close()

# if wished, remove all records from folders and database
if reloadAll:
    print 'reloading complete database'
    fullDataBaseReload()



# Synchronize the directories
dictFilesToLoad = dirSync()


# clean target directory from old files: iterate on target directory
removeOldFiles()


# remove old records from database
removeOldRecords()

###### Load files into the database #######

# Combilog Data
if dictFilesToLoad.has_key('Combilog'):
    try:
        importCombilog(dictFilesToLoad['Combilog'])
    except:
        print 'Combilog import crashed' 
    
# SwissMetNet Data
if dictFilesToLoad.has_key('SwissMetNet'):
    try:
        importSwissMetNet(dictFilesToLoad['SwissMetNet'])
    except:
        print 'SwissMetNet import crashed' 
    
# Nabel Data
if dictFilesToLoad.has_key('Nabel'):
    try:
        importNabel(dictFilesToLoad['Nabel'])
    except:
        print 'Nabel import crashed' 

    
# SamWi Data
if dictFilesToLoad.has_key('SamWI'):
    try:
        importSamWi(dictFilesToLoad['SamWI'])
    except:
        print 'Nabel import crashed' 
    
stopUpdateTime = datetime.now()
executionTime = stopUpdateTime - startUpdateTime
f = open('log.txt', 'a')
f.write('\nMeteo update task completed at ' + str(stopUpdateTime) + ' duration:' + str(executionTime))
f.write('\n############################')
f.close()

