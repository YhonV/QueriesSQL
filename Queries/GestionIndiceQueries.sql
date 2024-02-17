-- Creacion de usuario y asignacion de privilegios:
-- Usuario Master
CREATE USER MDY2131_ET_FB IDENTIFIED BY "Pby3301.masterET"
DEFAULT TABLESPACE "DATA"
TEMPORARY TABLESPACE "TEMP";
ALTER USER MDY2131_ET_FB QUOTA UNLIMITED ON DATA;
GRANT CREATE SESSION TO MDY2131_ET_FB;
GRANT CREATE ANY TABLE TO MDY2131_ET_FB;
GRANT ALTER ANY TABLE TO MDY2131_ET_FB;
GRANT DROP ANY TABLE TO MDY2131_ET_FB;
GRANT CREATE SEQUENCE TO MDY2131_ET_FB;
GRANT CREATE ANY INDEX TO MDY2131_ET_FB;

-- Usuario Desarrollador
CREATE USER MDY2131_ET_FB_DES IDENTIFIED BY "Pby3301.desarrolladoresET"
DEFAULT TABLESPACE "DATA"
TEMPORARY TABLESPACE "TEMP";
GRANT CREATE SESSION TO MDY2131_ET_FB_DES;
GRANT CREATE PROCEDURE TO MDY2131_ET_FB_DES;
GRANT CREATE TRIGGER TO MDY2131_ET_FB_DES;
GRANT CREATE VIEW TO MDY2131_ET_FB_DES;
GRANT CREATE MATERIALIZED VIEW TO MDY2131_ET_FB_DES;

-- Usuario Consulta
CREATE USER MDY2131_ET_FB_CON IDENTIFIED BY "Pby3301.consultaET"
DEFAULT TABLESPACE "DATA"
TEMPORARY TABLESPACE "TEMP";
GRANT CREATE SESSION TO MDY2131_ET_FB_CON;

-- Asignando privilegios: 
GRANT CREATE SYNONYM TO MDY2131_ET_FB;

-- Usuario Master
-- Creando sinonimos necesarios para acceder desde usuario desarrollo y consulta: 
CREATE PUBLIC SYNONYM syn_clienteET
FOR CLIENTE;

CREATE PUBLIC SYNONYM syn_region
FOR REGION;

CREATE SYNONYM syn_selecc_tipo_trans
FOR SELECCION_TIPO_TRANSACCION;

GRANT SELECT ON syn_clienteET to MDY2131_ET_FB_DES WITH GRANT OPTION; 
GRANT SELECT ON syn_region to MDY2131_ET_FB_DES WITH GRANT OPTION; 

GRANT SELECT ON syn_clienteET to MDY2131_ET_FB_CON; 
GRANT SELECT ON syn_region to MDY2131_ET_FB_CON; 
GRANT SELECT ON syn_selecc_tipo_trans to MDY2131_ET_FB_CON;
GRANT UPDATE, INSERT ON syn_selecc_tipo_trans TO MDY2131_ET_FB_CON;

-- Usuario Desarrollo
-- Informe 1:
create or replace view vista_infor_1 as
select r.nombre_region "Nombre",
       count(case 
            when extract(year from sysdate) - extract(year from c.fecha_inscripcion) >= 20 
                then 1 
            end) "Clientes con 20+ años de inscrip",
       count(*) "Total general x Region"
from syn_region r
join syn_clienteet c on r.cod_region = c.cod_region
group by r.nombre_region,c.cod_region
order by "Clientes con 20+ años de inscrip";

select * from vista_infor_1;

-- Creacion de indices para informe 1: 
create index IDX_REGION on region(initcap(nombre_region));
create index  IDX_CLI_REGION on cliente (appaterno);
select * from all_indexes;

drop index IDX_REGION;
drop index IDX_CLI_REGION;


-- Creacion informe 2 desde usuario Master: 
select  to_char(SYSDATE, 'DD-MM-YYYY') "FECHA",
        ttt.cod_tptran_tarjeta "CODIGO",
        upper(ttt.nombre_tptran_tarjeta) "DESCRIPCION",
        round(avg(ttc.monto_transaccion)) "MONTO PROMEDIO TRANSACCION"
from transaccion_tarjeta_cliente ttc
join tipo_transaccion_tarjeta ttt on ttt.cod_tptran_tarjeta = ttc.cod_tptran_tarjeta
group by ttt.nombre_tptran_tarjeta,ttt.cod_tptran_tarjeta
order by "MONTO PROMEDIO TRANSACCION";

-- Creacion informe 2 pero en Subconsulta
insert into SELECCION_TIPO_TRANSACCION
    select
        to_char(SYSDATE, 'DD-MM-YYYY') "FECHA",
        ttt.cod_tptran_tarjeta "CODIGO",
        upper(ttt.nombre_tptran_tarjeta) "DESCRIPCION",
        round(avg(ttc.monto_transaccion)) "MONTO PROMEDIO TRANSACCION"
    from
        tipo_transaccion_tarjeta ttt
    join
        (
            select
                cod_tptran_tarjeta,
                avg(monto_transaccion) monto_transaccion
            from
                transaccion_tarjeta_cliente ttc 
            group by
                cod_tptran_tarjeta
        ) ttc ON ttc.cod_tptran_tarjeta = ttt.cod_tptran_tarjeta
    GROUP BY
        ttt.cod_tptran_tarjeta, ttt.nombre_tptran_tarjeta
    ORDER BY
        "MONTO PROMEDIO TRANSACCION";
commit;

-- Actualizando porcentaje por un 1%
UPDATE tipo_transaccion_tarjeta
SET tasaint_tptran_tarjeta = tasaint_tptran_tarjeta - 0.01
WHERE cod_tptran_tarjeta IN (
    SELECT cod_tipo_transac
    FROM SELECCION_TIPO_TRANSACCION
);
commit;

-- Asignando privilegio al usuario Consulta para acceder a la vista:
GRANT SELECT ON vista_infor_1 TO MDY2131_ET_FB_CON;