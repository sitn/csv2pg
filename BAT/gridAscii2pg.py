import os, sys, shutil, csv, psycopg2, uuid, filecmp, subprocess, zlib
from datetime import datetime, timedelta
from application_params import *

gridTargetDirAsc = gridTargetDir + '/asc'

for filename in os.listdir(gridSourceDir):

    inputFile =  gridSourceDir + '/' + filename
    
    targetFile =  gridTargetDir + '/' + filename
    
    print 'Extracting and copying gridascii file: ' + filename
    
    shutil.copy(inputFile, targetFile)
    
    cmd = '7za.exe e  ' + targetFile + ' -o' + gridTargetDirAsc
    # 7za.exe x NE_NO2_20131130_03.asc.gz -oc:\tmp
    
    subprocess.call(cmd)
    
    

