-- MODIFICA EL FORMATO DE FECHA
alter session set nls_date_format ='DD-MM-YYYY';

drop table SERVICIO_TECNICO cascade constraints;
drop table MANTENCION cascade constraints;
drop table COMUNA  cascade constraints;
drop table BENEFICIO  cascade constraints;
drop table DETALLE_MANTENCION  cascade constraints;
drop table ESPECIALIDAD  cascade constraints;
drop table MECANICO  cascade constraints;
drop table NACIONALIDAD  cascade constraints;
drop table VEHICULO  cascade constraints;
drop table SERVICIO  cascade constraints;
drop table TALLER  cascade constraints;
drop table PROPIETARIO  cascade constraints;


CREATE TABLE servicio_tecnico (
    id_serv_tec   NUMBER(2) NOT NULL,
    nombre       VARCHAR2(30) NOT NULL,
    fono         NUMBER NOT NULL
)
LOGGING;

ALTER TABLE servicio_tecnico ADD CONSTRAINT servicio_tecnico_pk PRIMARY KEY ( id_serv_tec );

CREATE TABLE mantencion (
    id_mantencion             NUMBER(7) NOT NULL,
    fecha               DATE NOT NULL,
    descuento         NUMBER(8),
    neto              NUMBER(8) NOT NULL,
    iva               NUMBER(7) NOT NULL,
    total             NUMBER(8) NOT NULL,
    id_mecanico        NUMBER(4) NOT NULL,
    id_vehiculo        NUMBER(4) NOT NULL
)
LOGGING;

ALTER TABLE mantencion ADD CONSTRAINT mantencion_pk PRIMARY KEY ( id_mantencion );

CREATE TABLE comuna (
    cod_com   NUMBER(3) NOT NULL,
    nombre    VARCHAR2(30) NOT NULL
)
LOGGING;

ALTER TABLE comuna ADD CONSTRAINT comuna_pk PRIMARY KEY ( cod_com );

CREATE TABLE beneficio (
    id          NUMBER(3) NOT NULL,
    rango_ini   NUMBER(8) NOT NULL,
    rango_fin   NUMBER(8) NOT NULL,
    porc_desc   NUMBER(4,1) NOT NULL
)
LOGGING;

ALTER TABLE beneficio ADD CONSTRAINT beneficio_pk PRIMARY KEY ( id );

CREATE TABLE detalle_mantencion (
    id_mantencion         NUMBER(7) NOT NULL,
    codigo_serv   NUMBER(3) NOT NULL
)
LOGGING;

ALTER TABLE detalle_mantencion ADD CONSTRAINT detalle_mantencion_pk PRIMARY KEY ( id_mantencion,
codigo_serv );

CREATE TABLE especialidad (
    codigo_esp   NUMBER(3) NOT NULL,
    nombre       VARCHAR2(30) NOT NULL
)
LOGGING;

ALTER TABLE especialidad ADD CONSTRAINT especialidad_pk PRIMARY KEY ( codigo_esp );

CREATE TABLE mecanico (
    id_mecanico     NUMBER(4) NOT NULL,
    nombre    VARCHAR2(30) NOT NULL,
    fec_nac   DATE,
    codigo_esp    NUMBER(3) NOT NULL,
    codigo_nac    NUMBER(3) NOT NULL,
    cod_taller    NUMBER(4) NOT NULL
)
LOGGING;

ALTER TABLE mecanico ADD CONSTRAINT mecanico_pk PRIMARY KEY ( id_mecanico );

CREATE TABLE nacionalidad (
    codigo_nac   NUMBER(3) NOT NULL,
    nombre       VARCHAR2(30) NOT NULL
)
LOGGING;

ALTER TABLE nacionalidad ADD CONSTRAINT nacionalidad_pk PRIMARY KEY ( codigo_nac );

CREATE TABLE vehiculo (
    id_vehiculo     NUMBER(4) NOT NULL,
    marca           VARCHAR2(30) NOT NULL,
    año             NUMBER NOT NULL,
    modelo          VARCHAR2(50) NOT NULL,
    id_propietario  NUMBER(4) NOT NULL
)
LOGGING;

ALTER TABLE vehiculo ADD CONSTRAINT vehiculo_pk PRIMARY KEY ( id_vehiculo );

CREATE TABLE servicio (
    codigo_serv   NUMBER(3) NOT NULL,
    descripcion   VARCHAR2(30) NOT NULL,
    precio        NUMBER(7) NOT NULL
)
LOGGING;

ALTER TABLE servicio ADD CONSTRAINT servicio_pk PRIMARY KEY ( codigo_serv );

CREATE TABLE taller (
    cod_taller      NUMBER(4) NOT NULL,
    nombre_taller      VARCHAR2(30) NOT NULL,
    direccion_taller   VARCHAR2(50) NOT NULL,
    cod_com         NUMBER(3) NOT NULL,
    id_serv_tec      NUMBER(2) NOT NULL
)
LOGGING;

ALTER TABLE taller ADD CONSTRAINT taller_pk PRIMARY KEY ( cod_taller );

CREATE TABLE propietario (
    id_propietario  NUMBER(4) NOT NULL,
    nombre          VARCHAR2(30) NOT NULL,
    telefono        VARCHAR2(15) NOT NULL,
    direccion       VARCHAR2(100) NOT NULL
)
LOGGING;

ALTER TABLE propietario ADD CONSTRAINT propietario_pk PRIMARY KEY ( id_propietario );


ALTER TABLE mantencion
    ADD CONSTRAINT man_mec_fk FOREIGN KEY ( id_mecanico )
        REFERENCES mecanico ( id_mecanico )
    NOT DEFERRABLE;

ALTER TABLE mantencion
    ADD CONSTRAINT man_veh_fk FOREIGN KEY ( id_vehiculo )
        REFERENCES vehiculo ( id_vehiculo )
    NOT DEFERRABLE;

ALTER TABLE detalle_mantencion
    ADD CONSTRAINT det_man_mant_fk FOREIGN KEY ( id_mantencion )
        REFERENCES mantencion ( id_mantencion )
    NOT DEFERRABLE;

ALTER TABLE detalle_mantencion
    ADD CONSTRAINT det_man_se_fk FOREIGN KEY ( codigo_serv )
        REFERENCES servicio ( codigo_serv )
    NOT DEFERRABLE;

ALTER TABLE mecanico
    ADD CONSTRAINT mecanico_especialidad_fk FOREIGN KEY ( codigo_esp )
        REFERENCES especialidad ( codigo_esp )
    NOT DEFERRABLE;

ALTER TABLE mecanico
    ADD CONSTRAINT mecanico_nacionalidad_fk FOREIGN KEY ( codigo_nac )
        REFERENCES nacionalidad ( codigo_nac )
    NOT DEFERRABLE;

ALTER TABLE mecanico
    ADD CONSTRAINT mecanico_taller_fk FOREIGN KEY ( cod_taller )
        REFERENCES taller ( cod_taller )
    NOT DEFERRABLE;

ALTER TABLE taller
    ADD CONSTRAINT taller_serv_tec_fk FOREIGN KEY ( id_serv_tec )
        REFERENCES servicio_tecnico ( id_serv_tec )
    NOT DEFERRABLE;

ALTER TABLE taller
    ADD CONSTRAINT taller_com_fk FOREIGN KEY ( cod_com )
        REFERENCES comuna ( cod_com )
    NOT DEFERRABLE;

ALTER TABLE vehiculo
    ADD CONSTRAINT vehiculo_propietario_fk FOREIGN KEY ( id_propietario )
        REFERENCES propietario ( id_propietario )
    NOT DEFERRABLE;


insert into COMUNA values (1, 'Cerrillos');
insert into COMUNA values (2,'La Reina');
insert into COMUNA values (3,'Pudahuel');
insert into COMUNA values (4,'Cerro Navia');
insert into COMUNA values (5,'Las Condes');
insert into COMUNA values (6,'Quilicura');
insert into COMUNA values (7,'Conchalí');
insert into COMUNA values (8,'Lo Barnechea');
insert into COMUNA values (9,'Quinta Normal');
insert into COMUNA values (10,'El Bosque');
insert into COMUNA values (11,'Lo Espejo');
insert into COMUNA values (12,'Recoleta');
insert into COMUNA values (13,'Estación Central');

insert into nacionalidad values (1,'argentina');
insert into nacionalidad values (2,'boliviana');
insert into nacionalidad values (3,'brasileña');
insert into nacionalidad values (4,'chilena');
insert into nacionalidad values (5,'colombiana');
insert into nacionalidad values (6,'ecuatoriana');
insert into nacionalidad values (7,'guyanesa');
insert into nacionalidad values (8,'paraguaya');
insert into nacionalidad values (9,'peruana');
insert into nacionalidad values (10,'surinamesa');
insert into nacionalidad values (11,'uruguaya');
insert into nacionalidad values (12,'venezolana');

insert into especialidad values (1,'Mecanica General');
insert into especialidad values (2,'Mecanica Diesel');
insert into especialidad values (3,'Electro Mecanica');
insert into especialidad values (4,'Electro Movilidad');
insert into especialidad values (5,'Desabolladuria');
insert into especialidad values (6,'Electricidad Automotriz');
insert into especialidad values (7,'Automatizacion');
insert into especialidad values (8,'Mecanica de Vehiculos Pesados');

insert into servicio_tecnico  values ('10','Central Frenos','800500420');
insert into servicio_tecnico  values ('20','Pompeyo Carrasco','800200200');
insert into servicio_tecnico  values ('30','Bruno Fritsch','800800100');

insert into taller values (200,'PROVIDENCIA','Av.Simon Bolivar 77',1,20);
insert into taller values (201,'SANTIAGO','San Antonio 90',5,20);
insert into taller values (202,'SANTIAGO','Ahumada 5006',4,10);
insert into taller values (203,'LA FLORIDA','Av. Vicuña Mackenna 6170',8,30);

insert into mecanico values (340,'Jorge Sepulveda','02-02-1991',8,1,200);
insert into mecanico values (350,'Bayron Araya','02-11-1978',7,2,201);		
insert into mecanico values (360,'Andrea Contreras','03-05-1982',6,4,200);
insert into mecanico values(370,'Sandra Briones','04-07-1976',5,3,202);
insert into mecanico values(380,'Jose Gatica','05-11-1978',8,9,203);
insert into mecanico values(390,'Maria Jose Farias','03-05-1990',6,5,200);
insert into mecanico values(400,'Claudio Pizarro','03-07-1968',2,4,203);

insert into propietario values (2001,'Facundo Acuña','97854321','Pedro Lagos 5678');
insert into propietario values (2002,'Sofia Machuca','94567328','Diagonal Oriente 654');		
insert into propietario values (2003,'Maira Manriquez','22667789','Avenida Matta 765');
insert into propietario values(2004,'Amanda Fernandez','228856432','Infante Larrain 1492');
insert into propietario values(2005,'Jorge Aparicio','98909887','Esquina Blanca 5678');
insert into propietario values(2006,'Rosa Canales','87659325','Jorge Hirmas 4563');
insert into propietario values(2007,'Claudio Contreras','227855434','Barrio Oriente 1 63');
insert into propietario values (2008,'Jose Sepulveda','23453232','Bellavista 56');
insert into propietario values (2009,'Nicolar Romero','96748843','Alameda Bernardo Ohiggins 3456');		
insert into propietario values (2010,'Nicolas Araya','24534456','Avenida Central 5678');
insert into propietario values(2011,'Susana Diaz','65785423','Pajaritos 3452');
insert into propietario values(2012,'Alberto Rivera','71980976','Husares de la Muerte 9876');
insert into propietario values(2013,'Roberto Cruces','32789878','Av. Las Torres 5890');
insert into propietario values(2014,'Rodrigo Gatica','57020200','Pasaja Luis Alvarado 5900');

insert into vehiculo values (100,'Subaru',1999,'IMPREZA',2001);
insert into vehiculo values (200,'KIA',2017,'SORENTO',2001);
insert into vehiculo values (300,'CHERY',2018,'TIGGO 7',2002);
insert into vehiculo values (400,'BYD',2013,'S6 GSi 2.0',2003);
insert into vehiculo values (500,'HONDA',1999,'CIVIC',2005);
insert into vehiculo values (600,'Subaru',2016,'LEGACY',2008);
insert into vehiculo values (700,'TOYOTA',1999,'RAV 4',2010);
insert into vehiculo values (800,'BYD',2018,'S1 DCT 1.5L',2009);
insert into vehiculo values (900,'HYUNDAI',2012,'SANTA FE',2002);
insert into vehiculo values (1000,'KIA',2015,'RIO',2011);
insert into vehiculo values (1100,'HYUNDAI',2019,'TUCSON',2003);

insert into mantencion values(1000,'17-05-'||TO_CHAR(EXTRACT(YEAR FROM SYSDATE) - 1),0,630000,30000,660000,340,1000);	
insert into mantencion values(1001,'24-05-'||TO_CHAR(EXTRACT(YEAR FROM SYSDATE) - 2),0,110000,70000,180000,340,600);	
insert into mantencion values(1002,'02-05-'||TO_CHAR(EXTRACT(YEAR FROM SYSDATE) - 2),0,180000,70000,2500000,400, 300);	
insert into mantencion values(1003,'09-05-'||TO_CHAR(EXTRACT(YEAR FROM SYSDATE) - 1),0,30000,100000, 4700000,380,300);
insert into mantencion values(1004,'17-04-'||TO_CHAR(EXTRACT(YEAR FROM SYSDATE) - 1),0,50000, 45000, 95000, 350,400);
insert into mantencion values(1005,'06-07-'||TO_CHAR(EXTRACT(YEAR FROM SYSDATE) - 2),0,69000, 100000, 790000,380,600);
insert into mantencion values(1006,'19-12-'||TO_CHAR(EXTRACT(YEAR FROM SYSDATE) - 1),0,120000,30000, 150000,370,700);	
insert into mantencion values(1007,'26-05-'||TO_CHAR(EXTRACT(YEAR FROM SYSDATE) - 2),0,69000,65000, 755000, 380,800);
insert into mantencion values(1008,'04-12-'||TO_CHAR(EXTRACT(YEAR FROM SYSDATE) - 1),0,30000,88000, 3170000, 370,900);	
insert into mantencion values(1009,'17-02-'||TO_CHAR(EXTRACT(YEAR FROM SYSDATE)),0,60000, 1000, 70000, 400,800);	
insert into mantencion values(1010,'03-10-'||TO_CHAR(EXTRACT(YEAR FROM SYSDATE) - 1),0,127000,200000, 1470000, 390,600);	

insert into servicio values(701,'cambio de frenos',270000);
insert into servicio values(702,'mantencion 10000KM',350000);
insert into servicio values(703,'mantencion 20000KM',430000);
insert into servicio values(704,'mantencion 30000KM',650000);
insert into servicio values(705,'Cambio motor',5000000);
insert into servicio values(706,'cambio de Parabrisas',870000);
insert into servicio values(707,'Pintura completa',1800000);
insert into servicio values(708,'mantencion 60000KM',950000);

insert into detalle_mantencion values(1000,702);	
insert into detalle_mantencion values(1000,706);	
insert into detalle_mantencion values(1001,708);	
insert into detalle_mantencion values(1002,704);	
insert into detalle_mantencion values(1003,705);	
insert into detalle_mantencion values(1003,706);	
insert into detalle_mantencion values(1004,701);	
insert into detalle_mantencion values(1005,702);	
insert into detalle_mantencion values(1006,705);	
insert into detalle_mantencion values(1006,702);	
insert into detalle_mantencion values(1006,707);	
insert into detalle_mantencion values(1006,706);	
insert into detalle_mantencion values(1007,703);	
insert into detalle_mantencion values(1008,704);	
insert into detalle_mantencion values(1008,706);	
insert into detalle_mantencion values(1008,701);	
insert into detalle_mantencion values(1009,705);	
insert into detalle_mantencion values(1009,704);	
insert into detalle_mantencion values(1010,701);	
insert into detalle_mantencion values(1010,703);	

insert into beneficio values (1,0, 199999, 0);
insert into beneficio values (2,200000, 400000, 7.4);
insert into beneficio values (3,400001, 650000, 18.4);
insert into beneficio values (4,650001, 800000, 22.8);
insert into beneficio values (5,800001, 1250000, 35.1);
insert into beneficio values (6,1250001, 9000000, 40);

commit;