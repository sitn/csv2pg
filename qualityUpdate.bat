net use G: /delete /yes
net use G: \\cirrus\Data_transfert
python incremental_copy_quality.py
python import_SamWi.py
python import_Nabel.py