-- shema "stations" creation script for the logging of meteorological and air quality mesurements
-- stations.description: description and position in space of the station
-- stations.metadata: metadata for the logging tables. Description of the attributes and units
-- meteo_log: logging table for the physical parameters recorded by SwissMetNet and Combilog systems
-- quality_log: logging tables for the air parameters recorded by Sam-Wi and the Nabel systems. This table... 
-- ...contains all attributes present in meteo_log as thoses are often also recorder by air quality stations
-- @SITN 2013

BEGIN;
CREATE SCHEMA stations;

-- create station description table: name of the station, geomtry, and any additionnal information required
CREATE TABLE stations.description
(
  idobj character(40) NOT NULL,
  name  character(40), 
  geom geometry,
  CONSTRAINT description_pkey PRIMARY KEY (idobj ),
  CONSTRAINT enforce_dims_geom CHECK (st_ndims(geom) = 2),
  CONSTRAINT enforce_geotype_geom CHECK (geometrytype(geom) = 'POINT'::text OR geom IS NULL),
  CONSTRAINT enforce_srid_geom CHECK (st_srid(geom) = 21781)
)
WITH (
  OIDS=TRUE
);
ALTER TABLE stations.description
  OWNER TO mapfish;
GRANT ALL ON TABLE stations.description TO mapfish;
GRANT SELECT ON TABLE stations.description TO "www-data";

CREATE INDEX description_geom_index
  ON stations.description
  USING gist
  (geom );

-- create metadata table: attributes and units description of the logging tables

CREATE TABLE stations.metadata
(
  idobj character(40) NOT NULL,
  attribute_id  character(40),
  attribute_description  character(40),
  units character(40),  
  CONSTRAINT metadata_pkey PRIMARY KEY (idobj )
)
WITH (
  OIDS=TRUE
);
ALTER TABLE stations.metadata
  OWNER TO mapfish;
GRANT ALL ON TABLE stations.metadata TO mapfish;
GRANT SELECT ON TABLE stations.metadata TO "www-data";

CREATE INDEX metadata_index
  ON stations.metadata
  USING btree
  (idobj);

-- create logging table for meteorological data

CREATE TABLE stations.meteo_log
(
  -- record identification
  idobj character(40) NOT NULL,
  date_time timestamp, 
  station_id integer,
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
  CONSTRAINT meteo_log_pkey PRIMARY KEY (idobj )
)
WITH (
  OIDS=TRUE
);
ALTER TABLE stations.meteo_log
  OWNER TO mapfish;
GRANT ALL ON TABLE stations.meteo_log TO mapfish;
GRANT SELECT ON TABLE stations.meteo_log TO "www-data";

CREATE INDEX meteo_log_index
  ON stations.meteo_log
  USING btree
  (idobj);

-- create logging table for air quality data

CREATE TABLE stations.quality_log
(
  -- record identification
  idobj character(40) NOT NULL,
  date_time timestamp,
  station_id integer,
  
  -- ***chemical parameters***
  
  -- base parameters
  no_ double precision,  
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
  pm10_c double precision,  
  pm10_m double precision,  
  pm10_s double precision,  
  pm10_is double precision,  
  pm10_t1 double precision,  
  pm10_t2 double precision,  
  pm10_t3 double precision,  
  pm10_t4 double precision,  
  pm10_p1 double precision,  
  pm10_p2 double precision,  
  pm10_p3 double precision,
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
    
  CONSTRAINT quality_log_pkey PRIMARY KEY (idobj )
)
WITH (
  OIDS=TRUE
);
ALTER TABLE stations.quality_log
  OWNER TO mapfish;
GRANT ALL ON TABLE stations.quality_log TO mapfish;
GRANT SELECT ON TABLE stations.quality_log TO "www-data";

CREATE INDEX quality_log_index
  ON stations.quality_log
  USING btree
  (idobj);


COMMIT;

-- copy columns name into metadata table
--insert into stations.metadata (attribute_id,idobj) select column_name,uuid_generate_v4() from information_schema.columns where table_name = 'quality_log';