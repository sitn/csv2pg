csv2pg
======

Helpful scripts for importing meteo and air quality csv data into postgres db - Specific to swiss csv structures, needs customization


These scripts are specific to meteo and air quality csv format, with their limitations. They can't be used "as is".

They are meant to prepare date for publication trough SITN Meteo data plugin based on Mapfish ExtJS developpements that will soon be published

Nevertheless, they might be useful to other institutions working with similar data: code is rather direct and simple

CONTENT

- sql/create_shema.sql: sql script to create the schema, tables and views required to store the data and for the plugin to work

- bat/csv2pg.py: python main script to synchronize and upload data to the db
- bat/application_params.txt: local configuration file. Need to be edited and then copied into a new application_params.py file. This files stores the path and connexion parameters for your postgres database
- bat/meteoUpdate.bat & bat.qualityUpdate.bat helping bat files useful for launching the script from, for instance windows server task scheduler

- bat/utils/directorySyncAndClean.py: directory synchronization (time range selection, check for file differences), directory and db cleaning
- bat/utils/import_Combilog.py: csv2Pg loading script, specific to the Combilog data
- bat/utils/import_SwissMetNet.py: csv2Pg loading script, specific to the SwissMetNet data
- bat/utils/import_SamWi.py: csv2Pg loading script, specific to the Combilog data
- bat/utils/import_Nabel.py: csv2Pg loading script, specific to the Combilog data