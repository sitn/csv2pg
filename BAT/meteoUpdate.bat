net use G: /delete /yes
net use G: \\cirrus\Data_transfert
python incremental_copy_meteo.py
python import_Combilog.py
python import_SwissMetNet.py