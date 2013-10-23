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
if dictFilesToLoad.has_key('SamWi'):
    importSamWi(dictFilesToLoad['SamWi'])
    
