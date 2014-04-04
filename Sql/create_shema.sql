-- shema "stations_air" creation script for the logging of meteorological and air quality mesurements
-- stations_air.description: description and position in space of the station
-- stations_air.metadata: metadata for the logging tables. Description of the attributes and units
-- meteo_log: logging table for the physical parameters recorded by SwissMetNet and Combilog systems
-- quality_log: logging tables for the air parameters recorded by Sam-Wi and the Nabel systems. This table... 
-- ...contains all attributes present in meteo_log as thoses are often also recorder by air quality stations_air
-- @SITN 2013

CREATE SCHEMA stations_air;

-- create station description table: name of the station, geomtry, and any additionnal information required
CREATE TABLE stations_air.description
(
  idobj character(40) NOT NULL,
  network  character(40), 
  fullname  character(40),
  id  int,
  station_type character(40),
  altitude double precision,
  X double precision,
  Y double precision,
  geom geometry,
  pluginlink character(1024
  ),
  CONSTRAINT description_pkey PRIMARY KEY (idobj ),
  CONSTRAINT enforce_dims_geom CHECK (st_ndims(geom) = 2),
  CONSTRAINT enforce_geotype_geom CHECK (geometrytype(geom) = 'POINT'::text OR geom IS NULL),
  CONSTRAINT enforce_srid_geom CHECK (st_srid(geom) = 21781)
)
WITH (
  OIDS=TRUE
);
ALTER TABLE stations_air.description
  OWNER TO mapfish;
GRANT ALL ON TABLE stations_air.description TO mapfish;
GRANT SELECT ON TABLE stations_air.description TO "www-data";

CREATE INDEX description_geom_index
  ON stations_air.description
  USING gist
  (geom );
  
-- create metadata table: attributes and units description of the logging tables

CREATE TABLE stations_air.metadata
(
  idobj character(40) NOT NULL,
  attribute_id  character(40),
  attribute_code  int,
  attribute_description  character(40),
  attribute_fullname  character(40),
  units character(40),  
  CONSTRAINT metadata_pkey PRIMARY KEY (idobj )
)
WITH (
  OIDS=TRUE
);
ALTER TABLE stations_air.metadata
  OWNER TO mapfish;
GRANT ALL ON TABLE stations_air.metadata TO mapfish;
GRANT SELECT ON TABLE stations_air.metadata TO "www-data";

CREATE INDEX metadata_index
  ON stations_air.metadata
  USING btree
  (idobj);

-- create logging table for meteorological data

CREATE TABLE stations_air.meteo_log
(
  -- record identification
  idobj character(40) NOT NULL,
  station_id character(40),
  date_time timestamp,
    -- wind
  vvit double precision,
  vraf double precision,
  vvscal double precision,
  vvert double precision,
  vvnorth double precision,
  vvest double precision,
  vfreq double precision,
  vdir double precision,
  mbar double precision,
  
  -- temperature
  ta double precision,
  t05 double precision,
  t2 double precision,
  t10 double precision,
  tusa double precision,
  tpt100 double precision,
  tnv double precision,
  tdp double precision,
  tpsy double precision,
  t36 double precision,
  tpt1000 double precision,
  
  -- humidity
  hr double precision,
  hr2 double precision,
  
  -- sun radiation
  ren double precision,
  rbil double precision,
  rglo double precision,
  rdur double precision,
  
  -- atmospheric pressure
  patm double precision,
  patmr double precision,
  pvap double precision,
  
  -- rainfall
  prec_h double precision,
  prec_d double precision,
  prec_s double precision,
  
  -- fog
  neb double precision,
  
  -- atlitude
  alt850 double precision,
  
  -- ***station state parameters***
  
  ti double precision,
  hi double precision,
  te_1471 double precision,
  te_0513 double precision,
  te_bat double precision,
  te_pan double precision,
  te_vt3_2 double precision,
  te_vt3_10 double precision,
  tboit double precision,
  tcell double precision,

  --***reserves***
  
  res1 double precision,
  res2 double precision,
  res3 double precision, 
  
  sourcefile_name character(256),
  
  CONSTRAINT meteo_log_pkey PRIMARY KEY (idobj )
)
WITH (
  OIDS=TRUE
);
ALTER TABLE stations_air.meteo_log
  OWNER TO mapfish;
GRANT ALL ON TABLE stations_air.meteo_log TO mapfish;
GRANT SELECT ON TABLE stations_air.meteo_log TO "www-data";

CREATE INDEX meteo_log_index
  ON stations_air.meteo_log
  USING btree
  (idobj);

-- create logging table for air quality data

CREATE TABLE stations_air.quality_log
(
  -- record identification
  idobj character(40) NOT NULL,
  station_id character(40),
  date_time timestamp,
  -- ***chemical parameters***
  
  -- base parameters
  no double precision,  
  no2 double precision,  
  nox double precision,  
  o3 double precision,  
  so2 double precision,  
  co double precision,
  
  -- advanced parameters  
  voc_thc double precision,  
  voc_n_ch4 double precision,  
  voc_ch4 double precision, 
   
  -- aerosols
  pm1 double precision,
  pm10_c double precision,  
  pm10_c_2 double precision,  
  pm10_m double precision,  
  pm10_rm double precision,  
  pm10_s double precision,  
  pm10_is double precision,  
  pm10_t1 double precision,  
  pm10_t2 double precision,  
  pm10_t3 double precision,  
  pm10_t4 double precision,  
  pm10_p1 double precision,  
  pm10_p2 double precision,  
  pm10_p3 double precision,
  pm10_percent_hc double precision,
  pm10_status double precision,
  pm10_status_time double precision,
  pm10_limit double precision,
  pm10_time_limit double precision,
  pm10_error double precision,
  pm10_time_error double precision,
  pm10_cmin double precision,
  pm10_cmax double precision,
  pm10_qop double precision,
  pm10_rh double precision,
  pm10_percent_off double precision,
  pm10_m2 double precision,
  pm10_bcl double precision,
  pm10_bcs double precision,
  pm10_bc double precision,
  pm10_na double precision,
  pm10_ncf double precision,
  pm10_ncl double precision,
  pm10_nc double precision,
  pm10_2_5c double precision,
  
  -- benzene family
  btx_be double precision,
  btx_to double precision,
  btx_mx double precision,
  btx_px double precision,
  btx_ox double precision,
  btx_mpx double precision,
  btx_ebe double precision,
  
  -- ***physical parameters***
  
  -- wind
  vvit double precision,
  vvit_2 double precision,
  vraf double precision,
  vvscal double precision,
  vvert double precision,
  vvnorth double precision,
  vvest double precision,
  vfreq double precision,
  vdir double precision,
  mbar double precision,
  
  -- temperature
  ta double precision,
  t05 double precision,
  t2 double precision,
  t10 double precision,
  tusa double precision,
  tpt100 double precision,
  tnv double precision,
  tdp double precision,
  tpsy double precision,
  t36 double precision,
  tpt1000 double precision,
  
  -- humidity
  hr double precision,
  hr2 double precision,
  
  -- sun radiation
  ren double precision,
  rbil double precision,
  rglo double precision,
  rdur double precision,
  
  -- atmospheric pressure
  patm double precision,
  patmr double precision,
  pvap double precision,
  
  -- rainfall
  prec_h double precision,
  prec_d double precision,
  prec_s double precision,
  
  -- fog
  neb double precision,
  
  -- atlitude
  alt850 double precision,
  
  -- ***station state parameters***
  
  ti double precision,
  hi double precision,
  te_1471 double precision,
  te_0513 double precision,
  te_bat double precision,
  te_pan double precision,
  te_vt3_2 double precision,
  te_vt3_10 double precision,
  tboit double precision,
  tcell double precision,

  --***reserves***
  
  res1 double precision,
  res2 double precision,
  res3 double precision,
  
  sourcefile_name character(256),
    
  CONSTRAINT quality_log_pkey PRIMARY KEY (idobj )
)
WITH (
  OIDS=TRUE
);
ALTER TABLE stations_air.quality_log
  OWNER TO mapfish;
GRANT ALL ON TABLE stations_air.quality_log TO mapfish;
GRANT SELECT ON TABLE stations_air.quality_log TO "www-data";

CREATE INDEX quality_log_index
  ON stations_air.quality_log
  USING btree
  (idobj);

-- create import log table to keep track of bugs & friends
CREATE TABLE stations_air.import_log
(
  idobj character(40) NOT NULL,
  filename  character(40), 
  importDateTime timestamp,
  sucess boolean,
  CONSTRAINT import_log_pkey PRIMARY KEY (idobj)
)
WITH (
  OIDS=TRUE
);
ALTER TABLE stations_air.import_log
  OWNER TO mapfish;
GRANT ALL ON TABLE stations_air.import_log TO mapfish;
GRANT SELECT ON TABLE stations_air.import_log TO "www-data";

CREATE INDEX import_log_index
  ON stations_air.import_log
  USING btree
  (idobj); 


-- GRANT SELECT RIGHT TO WWW USER
-- copy columns name into metadata table
--insert into stations_air.metadata (attribute_id,idobj) select column_name,uuid_generate_v4() from information_schema.columns where table_name = 'quality_log';

--INSERT METADATA VALUES

--delete from metadata;
-- nitrogen
insert into stations_air.metadata (idobj, attribute_id, attribute_code,attribute_description, attribute_fullname, units) values (uuid_generate_v4(), 'no',2001, 'Monoxyde d''azote', 'Monoxyde d''azote', 'ppb');
insert into stations_air.metadata (idobj, attribute_id, attribute_code,attribute_description, attribute_fullname, units) values (uuid_generate_v4(), 'no2',2002, 'Dioxyde d''azote', 'Dioxyde d''azote', 'ppb');
insert into stations_air.metadata (idobj, attribute_id, attribute_code,attribute_description, attribute_fullname, units) values (uuid_generate_v4(), 'nox',2003, 'Oxyde d''azote', 'Oxyde d''azote', 'ppb');
-- ozone
insert into stations_air.metadata (idobj, attribute_id, attribute_code,attribute_description, attribute_fullname, units) values (uuid_generate_v4(), 'o3',2021, 'Ozone', 'Ozone', 'ppb');
-- sulfur
insert into stations_air.metadata (idobj, attribute_id, attribute_code,attribute_description, attribute_fullname, units) values (uuid_generate_v4(), 'so2',2041, 'Anhydryde sulfureux', 'Anhydryde sulfureux', 'ppb');
-- carbon
insert into stations_air.metadata (idobj, attribute_id, attribute_code,attribute_description, attribute_fullname, units) values (uuid_generate_v4(), 'co',2061, 'Monoxyde de carbone', 'Monoxyde de carbone', 'ppm');
-- VOC
insert into stations_air.metadata (idobj, attribute_id, attribute_code,attribute_description, attribute_fullname, units) values (uuid_generate_v4(), 'voc_thc',2081, 'Hydrocarbures totaux', 'Hydrocarbures totaux', 'ppm');
insert into stations_air.metadata (idobj, attribute_id, attribute_code,attribute_description, attribute_fullname, units) values (uuid_generate_v4(), 'voc_n_ch4',2081, 'Non-Methane', 'Non-Methane', 'ppm');
insert into stations_air.metadata (idobj, attribute_id, attribute_code,attribute_description, attribute_fullname, units) values (uuid_generate_v4(), 'voc_ch4',2081, 'Methane', 'Methane', 'ppm');
-- PM10
insert into stations_air.metadata (idobj, attribute_id, attribute_code,attribute_description, attribute_fullname, units) values (uuid_generate_v4(), 'pm10_c',2101, 'Concentration', 'Concentration', 'µg/m³');
insert into stations_air.metadata (idobj, attribute_id, attribute_code,attribute_description, attribute_fullname, units) values (uuid_generate_v4(), 'pm10_m',2102, 'Masse', 'Masse', 'ug');
insert into stations_air.metadata (idobj, attribute_id, attribute_code,attribute_description, attribute_fullname, units) values (uuid_generate_v4(), 'pm10_s',2103, 'Suie', 'Suie', 'µg/m³');
insert into stations_air.metadata (idobj, attribute_id, attribute_code,attribute_description, attribute_fullname, units) values (uuid_generate_v4(), 'pm10_is',2104, 'Indice de suie', 'Indice de suie', 'Nb');
insert into stations_air.metadata (idobj, attribute_id, attribute_code,attribute_description, attribute_fullname, units) values (uuid_generate_v4(), 'pm10_t1',2105, 'Temperature T1 (externe)', 'Temperature T1 (externe)', '°c');
insert into stations_air.metadata (idobj, attribute_id, attribute_code,attribute_description, attribute_fullname, units) values (uuid_generate_v4(), 'pm10_t2',2106, 'Temperature T2 (cellule)', 'Temperature T2 (cellule)', '°c');
insert into stations_air.metadata (idobj, attribute_id, attribute_code,attribute_description, attribute_fullname, units) values (uuid_generate_v4(), 'pm10_t3',2107, 'Temperature T3 (cellule)', 'Temperature T3 (cellule)', '°c');
insert into stations_air.metadata (idobj, attribute_id, attribute_code,attribute_description, attribute_fullname, units) values (uuid_generate_v4(), 'pm10_t4',2108, 'Temperature T4 (pied de la sonde)', 'Temperature T4 (pied de la sonde)', '°c');
insert into stations_air.metadata (idobj, attribute_id, attribute_code,attribute_description, attribute_fullname, units) values (uuid_generate_v4(), 'pm10_p1',2109, 'Pression P1', 'Pression P1', 'mbar');
insert into stations_air.metadata (idobj, attribute_id, attribute_code,attribute_description, attribute_fullname, units) values (uuid_generate_v4(), 'pm10_p2',2110, 'Pression P2', 'Pression P2', 'mbar');
insert into stations_air.metadata (idobj, attribute_id, attribute_code,attribute_description, attribute_fullname, units) values (uuid_generate_v4(), 'pm10_p3',2111, 'Pression P3', 'Pression P3', 'mbar');
insert into stations_air.metadata (idobj, attribute_id, attribute_code,attribute_description, attribute_fullname, units) values (uuid_generate_v4(), 'pm10_status',2112, 'Status (compteur)', 'Status (compteur)', 'nombre');
insert into stations_air.metadata (idobj, attribute_id, attribute_code,attribute_description, attribute_fullname, units) values (uuid_generate_v4(), 'pm10_status_time',2113, 'Status (duree - 1 log)', 'Status (duree - 1 log', 'sec');
insert into stations_air.metadata (idobj, attribute_id, attribute_code,attribute_description, attribute_fullname, units) values (uuid_generate_v4(), 'pm10_limit',2114, 'Limite (compteur)', 'Limite (compteur)', 'nombre');
insert into stations_air.metadata (idobj, attribute_id, attribute_code,attribute_description, attribute_fullname, units) values (uuid_generate_v4(), 'pm10_limit_time',2115, 'Limite (duree - log)', 'Limite (duree - log)', 'sec');
insert into stations_air.metadata (idobj, attribute_id, attribute_code,attribute_description, attribute_fullname, units) values (uuid_generate_v4(), 'pm10_error',2116, 'Erreur (compteur)', 'Erreur (compteur)', 'nombre');
insert into stations_air.metadata (idobj, attribute_id, attribute_code,attribute_description, attribute_fullname, units) values (uuid_generate_v4(), 'pm10_time_error',2117, 'Erreur (duree - 1 log)', 'Erreur (duree - 1 log)', 'sec');
insert into stations_air.metadata (idobj, attribute_id, attribute_code,attribute_description, attribute_fullname, units) values (uuid_generate_v4(), 'pm10_cmin',2118, 'Concentration minimum (1 log)', 'Concentration minimum (1 log)', 'µg/m³');
insert into stations_air.metadata (idobj, attribute_id, attribute_code,attribute_description, attribute_fullname, units) values (uuid_generate_v4(), 'pm10_cmax',2119, 'Concentration maximum (1 log)', 'Concentration maximum (1 log)', 'µg/m³');
insert into stations_air.metadata (idobj, attribute_id, attribute_code,attribute_description, attribute_fullname, units) values (uuid_generate_v4(), 'pm10_qop',2120, 'Debit operationel', 'Debit operationel', 'l/h');
insert into stations_air.metadata (idobj, attribute_id, attribute_code,attribute_description, attribute_fullname, units) values (uuid_generate_v4(), 'pm10_rh',2121, 'Humidite relative avant le filtre', 'Humidite relative avant le filtre', '%');
insert into stations_air.metadata (idobj, attribute_id, attribute_code,attribute_description, attribute_fullname, units) values (uuid_generate_v4(), 'pm10_percent_off',2122, '% offset', '% offset', '%');
insert into stations_air.metadata (idobj, attribute_id, attribute_code,attribute_description, attribute_fullname, units) values (uuid_generate_v4(), 'pm10_m2',2123, 'Masse', 'Masse', 'µg');
-- benzenes
insert into stations_air.metadata (idobj, attribute_id, attribute_code,attribute_description, attribute_fullname, units) values (uuid_generate_v4(), 'btx_be',2131, 'Benzène C6H6', 'Benzène C6H6', 'ppb');
insert into stations_air.metadata (idobj, attribute_id, attribute_code,attribute_description, attribute_fullname, units) values (uuid_generate_v4(), 'btx_to',2132, 'Toluène C7H8', 'Toluène C7H8', 'ppb');
insert into stations_air.metadata (idobj, attribute_id, attribute_code,attribute_description, attribute_fullname, units) values (uuid_generate_v4(), 'btx_mx',2133, 'm-Xylène', 'm-Xylène', 'ppb');
insert into stations_air.metadata (idobj, attribute_id, attribute_code,attribute_description, attribute_fullname, units) values (uuid_generate_v4(), 'btx_px',2134, 'p-Xylène', 'p-Xylène', 'ppb');
insert into stations_air.metadata (idobj, attribute_id, attribute_code,attribute_description, attribute_fullname, units) values (uuid_generate_v4(), 'btx_ox',2135, 'o-Xylène', 'o-Xylène', 'ppb');
insert into stations_air.metadata (idobj, attribute_id, attribute_code,attribute_description, attribute_fullname, units) values (uuid_generate_v4(), 'btx_mpx',2136, 'mp-Xylène', 'mp-Xylèn', 'ppb');
insert into stations_air.metadata (idobj, attribute_id, attribute_code,attribute_description, attribute_fullname, units) values (uuid_generate_v4(), 'btx_ebe',2137, 'Ethylbenzène C8H10', 'Ethylbenzène C8H10', 'ppb');
-- wind velocity
insert into stations_air.metadata (idobj, attribute_id, attribute_code,attribute_description, attribute_fullname, units) values (uuid_generate_v4(), 'vvit',1001, 'vitesse du vent', 'vitesse du vent', 'km/h');
insert into stations_air.metadata (idobj, attribute_id, attribute_code,attribute_description, attribute_fullname, units) values (uuid_generate_v4(), 'cdir',1002, 'vitesse du vent', 'vitesse du vent', 'km/h');
insert into stations_air.metadata (idobj, attribute_id, attribute_code,attribute_description, attribute_fullname, units) values (uuid_generate_v4(), 'vraf',1003, 'vitesse max du vent durant les rafales', 'vitesse rafales', 'km/h');
insert into stations_air.metadata (idobj, attribute_id, attribute_code,attribute_description, attribute_fullname, units) values (uuid_generate_v4(), 'vvscal',1004, 'vitesse du vent scalaire', 'vitesse du vent scalaire', 'km/h');
insert into stations_air.metadata (idobj, attribute_id, attribute_code,attribute_description, attribute_fullname, units) values (uuid_generate_v4(), 'vvert',1005, 'vitesse du vent vertical', 'vitesse du vent vertical', 'km/h');
insert into stations_air.metadata (idobj, attribute_id, attribute_code,attribute_description, attribute_fullname, units) values (uuid_generate_v4(), 'vvnord',1006, 'vitesse du vent Nord', 'vitesse du vent Nord', 'km/h');
insert into stations_air.metadata (idobj, attribute_id, attribute_code,attribute_description, attribute_fullname, units) values (uuid_generate_v4(), 'vvest',1007 ,'vitesse du vent Est', 'vitesse du vent Est', 'km/h');
insert into stations_air.metadata (idobj, attribute_id, attribute_code,attribute_description, attribute_fullname, units) values (uuid_generate_v4(), 'vfreq',1008, 'Frequence de la vitesse du vent', 'Frequence de la vitesse du vent', 'km/h');
-- temperature
insert into stations_air.metadata (idobj, attribute_id, attribute_code,attribute_description, attribute_fullname, units) values (uuid_generate_v4(), 'ta',1021, 'Temperature ambiante ventilee', 'Temperature ambiante ventilee', '°c');
insert into stations_air.metadata (idobj, attribute_id, attribute_code,attribute_description, attribute_fullname, units) values (uuid_generate_v4(), 't05',1022, 'Temperature a 5cm', 'Temperature a 5cm', '°c');
insert into stations_air.metadata (idobj, attribute_id, attribute_code,attribute_description, attribute_fullname, units) values (uuid_generate_v4(), 't2',1023, 'Temperature a 2m ventilee', 'Temperature a 2m ventilee', '°c');
insert into stations_air.metadata (idobj, attribute_id, attribute_code,attribute_description, attribute_fullname, units) values (uuid_generate_v4(), 't10',1024, 'Temperature a 2m ventilee', 'Temperature a 2m ventilee', '°c');
insert into stations_air.metadata (idobj, attribute_id, attribute_code,attribute_description, attribute_fullname, units) values (uuid_generate_v4(), 'tusa',1025, 'Temperature ambiante', 'Temperature ambiante', '°c');
insert into stations_air.metadata (idobj, attribute_id, attribute_code,attribute_description, attribute_fullname, units) values (uuid_generate_v4(), 'tpt100',1026, 'Temperature ambiante ventilee', 'Temperature ambiante ventilee', '°c');
insert into stations_air.metadata (idobj, attribute_id, attribute_code,attribute_description, attribute_fullname, units) values (uuid_generate_v4(), 'tnv', 1027,'Temperature ambiante non-ventilee', 'Temperature ambiante non-ventilee', '°c');
insert into stations_air.metadata (idobj, attribute_id, attribute_code,attribute_description, attribute_fullname, units) values (uuid_generate_v4(), 'tdp',1028, 'Temperature poitn de rosee', 'Temperature point de rosee', '°c');
insert into stations_air.metadata (idobj, attribute_id, attribute_code,attribute_description, attribute_fullname, units) values (uuid_generate_v4(), 'tpsy',1029, 'Temperature psychromnetrique', 'Temperature psychromnetrique', '°c');
insert into stations_air.metadata (idobj, attribute_id, attribute_code,attribute_description, attribute_fullname, units) values (uuid_generate_v4(), 't36',1030, 'Temperature 36m ventilee', 'Temperature 36m ventilee', '°c');
insert into stations_air.metadata (idobj, attribute_id, attribute_code,attribute_description, attribute_fullname, units) values (uuid_generate_v4(), 'tpt1000',1031, 'Temperature ambiante ventilee', 'Temperature ambiante ventilee', '°c');
-- water content
insert into stations_air.metadata (idobj, attribute_id, attribute_code,attribute_description, attribute_fullname, units) values (uuid_generate_v4(), 'hr', 1041,'Humidite relative', 'Humidite relative', '%');
insert into stations_air.metadata (idobj, attribute_id, attribute_code,attribute_description, attribute_fullname, units) values (uuid_generate_v4(), 'hr2',1042, 'Humidite 2m ventilee', 'Humidite 2m ventilee', '%');
--radiation
insert into stations_air.metadata (idobj, attribute_id, attribute_code,attribute_description, attribute_fullname, units) values (uuid_generate_v4(), 'ren',1061, 'Ensoleillement', 'Ensoleillement', 'W/m2');
insert into stations_air.metadata (idobj, attribute_id, attribute_code,attribute_description, attribute_fullname, units) values (uuid_generate_v4(), 'rbil',1062, 'Bilan de radiation solaire', 'Bilan de radiation solaire', 'W/m2');
insert into stations_air.metadata (idobj, attribute_id, attribute_code,attribute_description, attribute_fullname, units) values (uuid_generate_v4(), 'rglo', 1063,'Rayonnement global (moyenne horaire)', 'Ensoleillement', 'W/m2');
insert into stations_air.metadata (idobj, attribute_id, attribute_code,attribute_description, attribute_fullname, units) values (uuid_generate_v4(), 'ren', 1064,'Duree d''ensoleillement (somme horaire)', 'Duree d''ensoleillement', 'W/m2');
-- atmospheric pressure
insert into stations_air.metadata (idobj, attribute_id, attribute_code,attribute_description, attribute_fullname, units) values (uuid_generate_v4(), 'patm', 1081,'Pression atmospherique', 'Pression atmospherique', 'hPa');
insert into stations_air.metadata (idobj, attribute_id, attribute_code,attribute_description, attribute_fullname, units) values (uuid_generate_v4(), 'patmr',1082, 'Pression atmospherique reduite', 'Pression atmospherique reduite', 'hPa');
--precipitations
insert into stations_air.metadata (idobj, attribute_id, attribute_code,attribute_description, attribute_fullname, units) values (uuid_generate_v4(), 'prec_h', 1101,'Hauteur des precipitations (somme)', 'Hauteur des precipitations', 'mm');
insert into stations_air.metadata (idobj, attribute_id, attribute_code,attribute_description, attribute_fullname, units) values (uuid_generate_v4(), 'prec_d', 1102,'Duree des precipitations', 'Duree des precipitations', 'min/sec');
insert into stations_air.metadata (idobj, attribute_id, attribute_code,attribute_description, attribute_fullname, units) values (uuid_generate_v4(), 'prec_h', 1103,'Status (0:sec; 1: pluie)', 'Status', '-');
-- nebulosity
insert into stations_air.metadata (idobj, attribute_id, attribute_code,attribute_description, attribute_fullname, units) values (uuid_generate_v4(), 'neb', 1121,'Nebulosite totale', 'Nebulosite totale', 'code');
-- altitude
insert into stations_air.metadata (idobj, attribute_id, attribute_code,attribute_description, attribute_fullname, units) values (uuid_generate_v4(), 'alt850', 1141,'Altitude de la couche a 850 hPa', 'Altitude de la couche a 850 hPa', 'm');
-- stations_air internal parameters
insert into stations_air.metadata (idobj, attribute_id, attribute_code,attribute_description, attribute_fullname, units) values (uuid_generate_v4(), 'ti', 3001,'Temperature interne', 'Temperature interne', '°c');
insert into stations_air.metadata (idobj, attribute_id, attribute_code,attribute_description, attribute_fullname, units) values (uuid_generate_v4(), 'hi', 3002,'Humidite interne', 'Humidite interne', '%');
insert into stations_air.metadata (idobj, attribute_id, attribute_code,attribute_description, attribute_fullname, units) values (uuid_generate_v4(), 'te_1471', 3003,'Tension 1.471', 'Tension 1.471', 'V');
insert into stations_air.metadata (idobj, attribute_id, attribute_code,attribute_description, attribute_fullname, units) values (uuid_generate_v4(), 'te_0513', 3004,'Tension 0.513', 'Tension 0.513', 'V');
insert into stations_air.metadata (idobj, attribute_id, attribute_code,attribute_description, attribute_fullname, units) values (uuid_generate_v4(), 'te_bat', 3005,'Tension batterie', 'Tension batterie', 'V');
insert into stations_air.metadata (idobj, attribute_id, attribute_code,attribute_description, attribute_fullname, units) values (uuid_generate_v4(), 'te_pan', 3006,'Tension panneau solaire', 'Tension panneau solaire', 'V');
insert into stations_air.metadata (idobj, attribute_id, attribute_code,attribute_description, attribute_fullname, units) values (uuid_generate_v4(), 'te_vt3_2', 3007,'Tension VT3 a 2m', 'Tension VT3 a 2m', 'V');
insert into stations_air.metadata (idobj, attribute_id, attribute_code,attribute_description, attribute_fullname, units) values (uuid_generate_v4(), 'te_vt3_10', 3008,'Tension VT3 a 10m', 'Tension VT3 a 10m', 'V');
insert into stations_air.metadata (idobj, attribute_id, attribute_code,attribute_description, attribute_fullname, units) values (uuid_generate_v4(), 'tboit', 3009,'Temperature boîtier', 'Temperature boîtier', '°c');
insert into stations_air.metadata (idobj, attribute_id, attribute_code,attribute_description, attribute_fullname, units) values (uuid_generate_v4(), 'tcell', 3010,'Temperature cellule', 'Temperature cellule', '°c');
-- reserves
insert into stations_air.metadata (idobj, attribute_id, attribute_code,attribute_description, attribute_fullname, units) values (uuid_generate_v4(), 'res1', 4001,'Reserve 1', 'Reserve 1', '-');
insert into stations_air.metadata (idobj, attribute_id, attribute_code,attribute_description, attribute_fullname, units) values (uuid_generate_v4(), 'res2', 4002,'Reserve 2', 'Reserve 2', '-');
insert into stations_air.metadata (idobj, attribute_id, attribute_code,attribute_description, attribute_fullname, units) values (uuid_generate_v4(), 'res3', 4001,'Reserve 3', 'Reserve 3', '-');

--delete from stations_air.description;

insert into stations_air.description (idobj, network, fullname,id, station_type, altitude,x,y,geom, pluginlink) values (uuid_generate_v4(),'Nabel','Payerne',998,'quality',489,562285,184775, GeometryFromText( 'POINT(562285 184775)', 21781 ), '<a href="javascript:sitn.meteoDataWindow(''998'',true, true)"><img src="http://nesitnd1.ne.ch/demo_air/wsgi/proj/images/normal/chart.png" onload="sitn.meteoDataWindow(''998'',true, true)" onerror"sitn.meteoDataWindow(''998'',true, true)"></a>' );
insert into stations_air.description (idobj, network, fullname,id, station_type, altitude,x,y,geom, pluginlink) values (uuid_generate_v4(),'Nabel','Chaumont',999,'quality',1136,565090,211040, GeometryFromText( 'POINT(565090 211040)', 21781 ), '<a href="javascript:sitn.meteoDataWindow(''999'',true, false);"><img src="http://nesitnd1.ne.ch/demo_air/wsgi/proj/images/normal/chart.png" onload="sitn.meteoDataWindow(''999'',true, false)" onerror="sitn.meteoDataWindow(''999'',true, false)"></a>' );
insert into stations_air.description (idobj, network, fullname,id, station_type, altitude,x,y,geom, pluginlink) values (uuid_generate_v4(),'SamWI','Le Landeron',902,'quality',431,571175,210800, GeometryFromText( 'POINT(571175 210800)', 21781 ), '<a href="javascript:sitn.meteoDataWindow(''902'',true, false);"><img src="http://nesitnd1.ne.ch/demo_air/wsgi/proj/images/normal/chart.png" onload="sitn.meteoDataWindow(''902'',true, false)" onerror"sitn.meteoDataWindow(''902'',true, false)"></a>' );
insert into stations_air.description (idobj, network, fullname,id, station_type, altitude,x,y,geom, pluginlink) values (uuid_generate_v4(),'SamWI','Neuchatel',904,'quality',460,561518,204935, GeometryFromText( 'POINT(561518 204935)', 21781 ), '<a href="javascript:sitn.meteoDataWindow(''904'',true, false);"><img src="http://nesitnd1.ne.ch/demo_air/wsgi/proj/images/normal/chart.png" onload="sitn.meteoDataWindow(''904'',true, false)" onerror="sitn.meteoDataWindow(''904'',true, false)"></a>');
insert into stations_air.description (idobj, network, fullname,id, station_type, altitude,x,y,geom, pluginlink) values (uuid_generate_v4(),'SamWI','la Chaux-de-Fonds',905,'quality',997,553467,216963, GeometryFromText( 'POINT(553467 216963)', 21781 ), '<a href="javascript:sitn.meteoDataWindow(''905'',true, false);"><img src="http://nesitnd1.ne.ch/demo_air/wsgi/proj/images/normal/chart.png" onload="sitn.meteoDataWindow(''905'',true, false)" onerror="sitn.meteoDataWindow(''905'',true, false)"></a>');
insert into stations_air.description (idobj, network, fullname,id, station_type, altitude,x,y,geom, pluginlink) values (uuid_generate_v4(),'SamWI','Locle',907,'quality',931,548581,212842, GeometryFromText( 'POINT(548581 212842)', 21781 ), '<a href="javascript:sitn.meteoDataWindow(''907'',true, false);"><img src="http://nesitnd1.ne.ch/demo_air/wsgi/proj/images/normal/chart.png" onload="sitn.meteoDataWindow(''907'',true, false)" onerror="sitn.meteoDataWindow(''907'',true, false)"></a>' );
insert into stations_air.description (idobj, network, fullname,id, station_type, altitude,x,y,geom, pluginlink) values (uuid_generate_v4(),'Combilog','Bevaix (vis-a-vis Apollo)',32,'meteo',494,553241,198441, GeometryFromText( 'POINT(553241 198441)', 21781 ), '<a href="javascript:sitn.meteoDataWindow(''032'',true, true);"><img src="http://nesitnd1.ne.ch/demo_air/wsgi/proj/images/normal/chart.png" onload="sitn.meteoDataWindow(''032'',true, true)" onerror="sitn.meteoDataWindow(''032'',true, true)"></a>' );
insert into stations_air.description (idobj, network, fullname,id, station_type, altitude,x,y,geom, pluginlink) values (uuid_generate_v4(),'Combilog','Jolimont (Erlach)',36,'meteo',450,571321,208498, GeometryFromText( 'POINT(571321 208498)', 21781 ), '<a href="javascript:sitn.meteoDataWindow(''036'',true, true);"><img src="http://nesitnd1.ne.ch/demo_air/wsgi/proj/images/normal/chart.png" onload="sitn.meteoDataWindow(''036'',true, true)" onerror="sitn.meteoDataWindow(''036'',true, true)"></a>');
insert into stations_air.description (idobj, network, fullname,id, station_type, altitude,x,y,geom, pluginlink) values (uuid_generate_v4(),'Combilog','Neuchatel (Nid-du-Cro)',40,'meteo',435,563041,205228, GeometryFromText( 'POINT(563041 205228)', 21781 ), '<a href="javascript:sitn.meteoDataWindow(''040'',true, true);"><img src="http://nesitnd1.ne.ch/demo_air/wsgi/proj/images/normal/chart.png" onload="sitn.meteoDataWindow(''040'',true, true)" onerror="sitn.meteoDataWindow(''040'',true, true)"></a>' );
insert into stations_air.description (idobj, network, fullname,id, station_type, altitude,x,y,geom, pluginlink) values (uuid_generate_v4(),'Combilog','Cernier (Evologia)',41,'meteo',777,559710,211909, GeometryFromText( 'POINT(559710 211909)', 21781 ), '<a href="javascript:sitn.meteoDataWindow(''041'',true, true);"><img src="http://nesitnd1.ne.ch/demo_air/wsgi/proj/images/normal/chart.png" onload="sitn.meteoDataWindow(''041'',true, true)" onerror="sitn.meteoDataWindow(''041'',true, true)"></a>' );
insert into stations_air.description (idobj, network, fullname,id, station_type, altitude,x,y,geom, pluginlink) values (uuid_generate_v4(),'Combilog','La Sagne (Step)',42,'meteo',1015,551005,209287, GeometryFromText( 'POINT(551005 209287)', 21781 ), '<a href="javascript:sitn.meteoDataWindow(''042'',true, true);"><img src="http://nesitnd1.ne.ch/demo_air/wsgi/proj/images/normal/chart.png" onload="sitn.meteoDataWindow(''042'',true, true)" onerror="sitn.meteoDataWindow(''042'',true, true)"></a>' );
insert into stations_air.description (idobj, network, fullname,id, station_type, altitude,x,y,geom, pluginlink) values (uuid_generate_v4(),'Combilog','Travers (Step)',49,'meteo',728,540601,198348, GeometryFromText( 'POINT(540601 198348)', 21781 ),'<a href="javascript:sitn.meteoDataWindow(''049'',true, true);"><img src="http://nesitnd1.ne.ch/demo_air/wsgi/proj/images/normal/chart.png" onload="sitn.meteoDataWindow(''049'',true, true)" onerror="sitn.meteoDataWindow(''049'',true, true)"></a>' );
insert into stations_air.description (idobj, network, fullname,id, station_type, altitude,x,y,geom, pluginlink) values (uuid_generate_v4(),'SwissMetNet','Chasseral',12,'meteo',1594,570842,220155, GeometryFromText( 'POINT(570842 220155)', 21781 ), '<a href="javascript:sitn.meteoDataWindow(''012'',true, true);"><img src="http://nesitnd1.ne.ch/demo_air/wsgi/proj/images/normal/chart.png" onload="sitn.meteoDataWindow(''012'',true, true)" onerror="sitn.meteoDataWindow(''012'',true, true)"></a>' );
insert into stations_air.description (idobj, network, fullname,id, station_type, altitude,x,y,geom, pluginlink) values (uuid_generate_v4(),'SwissMetNet','Neuchatel',23,'meteo',485,563075,205545, GeometryFromText( 'POINT(563075 205545)', 21781 ), '<a href="javascript:sitn.meteoDataWindow(''023'',true, true);"><img src="http://nesitnd1.ne.ch/demo_air/wsgi/proj/images/normal/chart.png" onload="sitn.meteoDataWindow(''023'',true, true)" onerror="sitn.meteoDataWindow(''023'',true, true)"></a>' );
insert into stations_air.description (idobj, network, fullname,id, station_type, altitude,x,y,geom, pluginlink) values (uuid_generate_v4(),'SwissMetNet','La Chaux-de-Fonds',38,'meteo',1017,550923,214893, GeometryFromText( 'POINT(550923 214893)', 21781 ), '<a href="javascript:sitn.meteoDataWindow(''038'',true, true);"><img src="http://nesitnd1.ne.ch/demo_air/wsgi/proj/images/normal/chart.png" onload="sitn.meteoDataWindow(''038'',true, true)" onerror="sitn.meteoDataWindow(''038'',true, true)"></a>');
insert into stations_air.description (idobj, network, fullname,id, station_type, altitude,x,y,geom, pluginlink) values (uuid_generate_v4(),'SwissMetNet','La Fretaz (Bullet)',52,'meteo',1205,534221,188081, GeometryFromText( 'POINT(534221 188081)', 21781 ), '<a href="javascript:sitn.meteoDataWindow(''052'',true, true);"><img src="http://nesitnd1.ne.ch/demo_air/wsgi/proj/images/normal/chart.png" onload="sitn.meteoDataWindow(''052'',true, true)" onerror="sitn.meteoDataWindow(''052'',true, true)"></a>' );
insert into stations_air.description (idobj, network, fullname,id, station_type, altitude,x,y,geom, pluginlink) values (uuid_generate_v4(),'SwissMetNet','La Brevine',213,'meteo',1050,536987,203976, GeometryFromText( 'POINT(536987 203976)', 21781 ),'<a href="javascript:sitn.meteoDataWindow(''213'',true, true);"><img src="http://nesitnd1.ne.ch/demo_air/wsgi/proj/images/normal/chart.png" onload="sitn.meteoDataWindow(''213'',true, true)" onerror="sitn.meteoDataWindow(''213'',true, true)"></a>');
insert into stations_air.description (idobj, network, fullname,id, station_type, altitude,x,y,geom, pluginlink) values (uuid_generate_v4(),'SwissMetNet','Le Landeron (Cressier)',228,'meteo',431,571160,210800, GeometryFromText( 'POINT(571160 210800)', 21781 ), '<a href="javascript:sitn.meteoDataWindow(''228'',true, true);"><img src="http://nesitnd1.ne.ch/demo_air/wsgi/proj/images/normal/chart.png" onload="sitn.meteoDataWindow(''228'',true, true)" onerror="sitn.meteoDataWindow(''228'',true, true)"></a>' );

--DROP VIEW stations_air_air.public_air_data;

CREATE OR REPLACE VIEW stations_air.public_air_data AS 
 SELECT description.oid, description.idobj, description.fullname, description.altitude, description.geom
   FROM stations_air.description;

   /*
ALTER TABLE stations_air.public_air_data
  OWNER TO mapfish;
GRANT ALL ON TABLE stations_air.public_air_data TO mapfish;
GRANT SELECT ON TABLE stations_air.public_air_data TO "www-data";
*/

CREATE OR REPLACE VIEW stations_air.meteo_layer AS 
  SELECT description.idobj, public_meteo_data.station_id, description.fullname, description.altitude, public_meteo_data.date_time, public_meteo_data.vvit, 
        CASE
            WHEN public_meteo_data.vdir IS NULL THEN (-9999)::double precision
            ELSE public_meteo_data.vdir
        END AS vdir,
        CASE
		WHEN now() - public_meteo_data.date_time > interval '3 hours' THEN 0 
		ELSE 1
	END as isdatauptodate,
        CASE
            WHEN public_meteo_data.vdir IS NULL THEN (-9999)::double precision
            ELSE (- public_meteo_data.vdir) + 90::double precision
        END AS vdir_map, public_meteo_data.vraf, public_meteo_data.vvnorth, public_meteo_data.vvest, public_meteo_data.vfreq, public_meteo_data.hr2, public_meteo_data.t2, public_meteo_data.t2::text || '°'::text AS label_meteo, public_meteo_data.t10, public_meteo_data.tusa, public_meteo_data.tpt100, public_meteo_data.tdp, public_meteo_data.patm, description.geom, description.pluginlink
   FROM ( SELECT last_meteo_log.station_id_u, last_meteo_log.last_log, meteo_log.idobj, meteo_log.station_id, meteo_log.date_time, meteo_log.vvit, meteo_log.vraf, meteo_log.vvscal, meteo_log.vvert, meteo_log.vvnorth, meteo_log.vvest, meteo_log.vfreq, meteo_log.vdir, meteo_log.mbar, meteo_log.ta, meteo_log.t05, meteo_log.t2, meteo_log.t10, meteo_log.tusa, meteo_log.tpt100, meteo_log.tnv, meteo_log.tdp, meteo_log.tpsy, meteo_log.t36, meteo_log.tpt1000, meteo_log.hr, meteo_log.hr2, meteo_log.ren, meteo_log.rbil, meteo_log.rglo, meteo_log.rdur, meteo_log.patm, meteo_log.patmr, meteo_log.pvap, meteo_log.prec_h, meteo_log.prec_d, meteo_log.prec_s, meteo_log.neb, meteo_log.alt850, meteo_log.ti, meteo_log.hi, meteo_log.te_1471, meteo_log.te_0513, meteo_log.te_bat, meteo_log.te_pan, meteo_log.te_vt3_2, meteo_log.te_vt3_10, meteo_log.tboit, meteo_log.tcell, meteo_log.res1, meteo_log.res2, meteo_log.res3, meteo_log.sourcefile_name
           FROM ( SELECT meteo_log.station_id AS station_id_u, max(meteo_log.date_time) AS last_log
                   FROM stations_air.meteo_log
                  GROUP BY meteo_log.station_id) last_meteo_log
      JOIN stations_air.meteo_log ON last_meteo_log.station_id_u = meteo_log.station_id
     WHERE meteo_log.date_time = last_meteo_log.last_log) public_meteo_data, stations_air.description
  WHERE public_meteo_data.station_id::integer = description.id
  ORDER BY public_meteo_data.date_time;

ALTER TABLE stations_air.meteo_layer
  OWNER TO mapfish;
GRANT ALL ON TABLE stations_air.meteo_layer TO mapfish;
GRANT SELECT ON TABLE stations_air.meteo_layer TO "www-data";
		
-- add station information from description table
CREATE OR REPLACE VIEW stations_air.quality_layer AS 
SELECT description.idobj, public_quality_data.station_id, description.fullname, description.altitude, public_quality_data.date_time, public_quality_data.vvit, 
        CASE
            WHEN public_quality_data.vdir IS NULL THEN (-9999)::double precision
            ELSE public_quality_data.vdir
        END AS vdir, 
        CASE
		WHEN now() - public_quality_data.date_time > interval '3 hours' THEN 0 
		ELSE 1
	END as isdatauptodate,
        public_quality_data.vvnorth, public_quality_data.vvest, public_quality_data.vraf, public_quality_data.vfreq, public_quality_data.hr2, public_quality_data.t2, public_quality_data.t10, public_quality_data.tusa, public_quality_data.tpt100, public_quality_data.tdp, public_quality_data.patm, public_quality_data.no, public_quality_data.no2, public_quality_data.nox, public_quality_data.o3, public_quality_data.so2, public_quality_data.co, public_quality_data.pm10_c, public_quality_data.ren, public_quality_data.prec_h, description.geom, description.pluginlink
   FROM ( SELECT last_quality_log.station_id_u, last_quality_log.last_log, quality_log.idobj, quality_log.station_id, quality_log.date_time, quality_log.no, quality_log.no2, quality_log.nox, quality_log.o3, quality_log.so2, quality_log.co, quality_log.voc_thc, quality_log.voc_n_ch4, quality_log.voc_ch4, quality_log.pm1, quality_log.pm10_c, quality_log.pm10_c_2, quality_log.pm10_m, quality_log.pm10_rm, quality_log.pm10_s, quality_log.pm10_is, quality_log.pm10_t1, quality_log.pm10_t2, quality_log.pm10_t3, quality_log.pm10_t4, quality_log.pm10_p1, quality_log.pm10_p2, quality_log.pm10_p3, quality_log.pm10_percent_hc, quality_log.pm10_status, quality_log.pm10_status_time, quality_log.pm10_limit, quality_log.pm10_time_limit, quality_log.pm10_error, quality_log.pm10_time_error, quality_log.pm10_cmin, quality_log.pm10_cmax, quality_log.pm10_qop, quality_log.pm10_rh, quality_log.pm10_percent_off, quality_log.pm10_m2, quality_log.pm10_bcl, quality_log.pm10_bcs, quality_log.pm10_bc, quality_log.pm10_na, quality_log.pm10_ncf, quality_log.pm10_ncl, quality_log.pm10_nc, quality_log.pm10_2_5c, quality_log.btx_be, quality_log.btx_to, quality_log.btx_mx, quality_log.btx_px, quality_log.btx_ox, quality_log.btx_mpx, quality_log.btx_ebe, quality_log.vvit, quality_log.vvit_2, quality_log.vraf, quality_log.vvscal, quality_log.vvert, quality_log.vvnorth, quality_log.vvest, quality_log.vfreq, quality_log.vdir, quality_log.mbar, quality_log.ta, quality_log.t05, quality_log.t2, quality_log.t10, quality_log.tusa, quality_log.tpt100, quality_log.tnv, quality_log.tdp, quality_log.tpsy, quality_log.t36, quality_log.tpt1000, quality_log.hr, quality_log.hr2, quality_log.ren, quality_log.rbil, quality_log.rglo, quality_log.rdur, quality_log.patm, quality_log.patmr, quality_log.pvap, quality_log.prec_h, quality_log.prec_d, quality_log.prec_s, quality_log.neb, quality_log.alt850, quality_log.ti, quality_log.hi, quality_log.te_1471, quality_log.te_0513, quality_log.te_bat, quality_log.te_pan, quality_log.te_vt3_2, quality_log.te_vt3_10, quality_log.tboit, quality_log.tcell, quality_log.res1, quality_log.res2, quality_log.res3, quality_log.sourcefile_name
           FROM ( SELECT quality_log.station_id AS station_id_u, max(quality_log.date_time) AS last_log
                   FROM stations_air.quality_log
                  GROUP BY quality_log.station_id) last_quality_log
      JOIN stations_air.quality_log ON last_quality_log.station_id_u = quality_log.station_id
     WHERE quality_log.date_time = last_quality_log.last_log) public_quality_data, stations_air.description
  WHERE public_quality_data.station_id::integer = description.id
  ORDER BY public_quality_data.date_time;

ALTER TABLE stations_air.quality_layer
  OWNER TO mapfish;
GRANT ALL ON TABLE stations_air.quality_layer TO mapfish;
GRANT SELECT ON TABLE stations_air.quality_layer TO "www-data";


-- Grid DATA

CREATE TABLE stations_air.no2_tileindex
(
  idobj text,
  date_time timestamp without time zone,
  filepath text,
  asciigrid_path text,
  geom geometry,
  CONSTRAINT enforce_dims_geom CHECK (st_ndims(geom) = 2),
  CONSTRAINT enforce_geotype_geom CHECK (geometrytype(geom) = 'POLYGON'::text OR geom IS NULL),
  CONSTRAINT enforce_srid_geom CHECK (st_srid(geom) = 21781)
)
WITH (
  OIDS=TRUE
);
ALTER TABLE stations_air.no2_tileindex
  OWNER TO mapfish;
GRANT ALL ON TABLE stations_air.no2_tileindex TO mapfish;
GRANT SELECT ON TABLE stations_air.no2_tileindex TO "www-data";

CREATE INDEX no2_tileindex_geom_1386601930931
  ON stations_air.no2_tileindex
  USING gist
  (geom );
  
  CREATE TABLE stations_air.o3_tileindex
(
  idobj text,
  date_time timestamp without time zone,
  filepath text,
  asciigrid_path text,
  geom geometry,
  CONSTRAINT enforce_dims_geom CHECK (st_ndims(geom) = 2),
  CONSTRAINT enforce_geotype_geom CHECK (geometrytype(geom) = 'POLYGON'::text OR geom IS NULL),
  CONSTRAINT enforce_srid_geom CHECK (st_srid(geom) = 21781)
)
WITH (
  OIDS=TRUE
);
ALTER TABLE stations_air.o3_tileindex
  OWNER TO mapfish;
GRANT ALL ON TABLE stations_air.o3_tileindex TO mapfish;
GRANT SELECT ON TABLE stations_air.o3_tileindex TO "www-data";

CREATE INDEX o3_tileindex_geom_1386601930931
  ON stations_air.o3_tileindex
  USING gist
  (geom );
  
  CREATE TABLE stations_air.pm10_tileindex
(
  idobj text,
  date_time timestamp without time zone,
  filepath text,
  asciigrid_path text,
  geom geometry,
  CONSTRAINT enforce_dims_geom CHECK (st_ndims(geom) = 2),
  CONSTRAINT enforce_geotype_geom CHECK (geometrytype(geom) = 'POLYGON'::text OR geom IS NULL),
  CONSTRAINT enforce_srid_geom CHECK (st_srid(geom) = 21781)
)
WITH (
  OIDS=TRUE
);
ALTER TABLE stations_air.pm10_tileindex
  OWNER TO mapfish;
GRANT ALL ON TABLE stations_air.pm10_tileindex TO mapfish;
GRANT SELECT ON TABLE stations_air.pm10_tileindex TO "www-data";

CREATE INDEX pm10_tileindex_geom_1386601930932
  ON stations_air.pm10_tileindex
  USING gist
  (geom );