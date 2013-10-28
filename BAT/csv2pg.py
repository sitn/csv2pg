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
    importCombilog(dictFilesToLoad['Combilog'])
    
# SwissMetNet Data
if dictFilesToLoad.has_key('SwissMetNet'):
    importSwissMetNet(dictFilesToLoad['SwissMetNet'])
    
# Nabel Data
if dictFilesToLoad.has_key('Nabel'):
    importNabel(dictFilesToLoad['Nabel'])
    
# SamWi Data
if dictFilesToLoad.has_key('SamWI'):
    importSamWi(dictFilesToLoad['SamWI'])
    
stopUpdateTime = datetime.now()
executionTime = stopUpdateTime - startUpdateTime
f = open('log.txt', 'a')
f.write('\nMeteo update task completed at ' + str(stopUpdateTime) + ' duration:' + str(executionTime))
f.write('\n############################')
f.close()

