--CREACIÓN USUARIO
CREATE USER MDY3131_P2 IDENTIFIED BY "MDY3131.practica_2"
DEFAULT TABLESPACE "DATA"
TEMPORARY TABLESPACE "TEMP";
ALTER USER MDY3131_P2 QUOTA UNLIMITED ON DATA;
GRANT CREATE SESSION TO MDY3131_P2;
GRANT "RESOURCE" TO MDY3131_P2;
ALTER USER MDY3131_P2 DEFAULT ROLE "RESOURCE";

--CASO 1
VARIABLE ANIO_PROC NUMBER;
EXEC :ANIO_PROC :=EXTRACT(YEAR FROM SYSDATE);

VARIABLE RUT_EMP NUMBER;
EXEC :RUT_EMP := &RUTEMP;

VARIABLE COM1 VARCHAR2;
VARIABLE VAL1 NUMBER;
VARIABLE COM2 VARCHAR2;
VARIABLE VAL2 NUMBER;
VARIABLE COM3 VARCHAR2;
VARIABLE VAL3 NUMBER;
VARIABLE COM4 VARCHAR2;
VARIABLE VAL4 NUMBER;
VARIABLE COM5 VARCHAR2;
VARIABLE VAL5 NUMBER;

EXEC :COM1 := '&&COMUNA1';
EXEC :VAL1 := &&VALOR1;
EXEC :COM2 := '&&COMUNA2';
EXEC :VAL2 := &&VALOR2;
EXEC :COM3 := '&&COMUNA3';
EXEC :VAL3 := &&VALOR3;
EXEC :COM4 := '&&COMUNA4';
EXEC :VAL4 := &&VALOR4;
EXEC :COM5 := '&&COMUNA5';
EXEC :VAL5 := &&VALOR5;

DECLARE
        V_DVRUT         EMPLEADO.DVRUN_EMP%TYPE;
        V_NOM_EMP       VARCHAR2(300); 
        V_SUELDO        EMPLEADO.SUELDO_BASE%TYPE;
        V_PORC_MOV      NUMBER(3);
        V_MOV_NORM      NUMBER(10);
        V_MOV_ADIC      NUMBER(10);
        V_MOV_TOT       NUMBER(20);
BEGIN
    SELECT 
        DVRUN_EMP,
        PNOMBRE_EMP||' '||SNOMBRE_EMP||' '||APPATERNO_EMP||' '||APMATERNO_EMP,
        SUELDO_BASE,
        TRUNC(SUELDO_BASE/100000),
        ROUND(SUELDO_BASE * (TRUNC(SUELDO_BASE/100000)/100)),
        CASE NOMBRE_COMUNA
            WHEN :COM1 THEN :VAL1
            WHEN :COM2 THEN :VAL2
            WHEN :COM3 THEN :VAL3
            WHEN :COM4 THEN :VAL4
            WHEN :COM5 THEN :VAL5
            ELSE 0
        END
    INTO
        V_DVRUT, V_NOM_EMP, V_SUELDO,V_PORC_MOV,V_MOV_NORM,V_MOV_ADIC
    FROM empleado NATURAL JOIN comuna
    WHERE NUMRUN_EMP = :RUT_EMP;
    
    v_mov_tot := v_mov_norm + v_mov_adic;
    
    INSERT INTO proy_movilizacion
    VALUES (:ANIO_PROC,:RUT_EMP,V_DVRUT,
    V_NOM_EMP,V_SUELDO,V_PORC_MOV,V_MOV_NORM,V_MOV_ADIC,v_mov_tot);    
END;

commit;

--CASO 2

VARIABLE rut_emp NUMBER;
EXEC :rut_emp := &RUTEMP;


DECLARE

    v_mess_anno     NUMBER;
    v_rut_emp       empleado.numrun_emp%TYPE;
    v_dv_rut_emp    empleado.dvrun_emp%TYPE;
    v_nombre_emp    VARCHAR2(300);
    v_nombre_user   VARCHAR2(300);
    v_contra_user   VARCHAR2(300);
    
BEGIN

    select 
--Mes anno
        to_number(extract(month from sysdate)) || to_number(extract(year from sysdate)) as "MES_ANNO",      
--RUT   
        NUMRUN_EMP,
--dv_RUT   
        DVRUN_EMP,
--Nombre de empleado
        PNOMBRE_EMP || ' ' || SNOMBRE_EMP || ' ' || APPATERNO_EMP || ' ' || APMATERNO_EMP as "NOMBRE_EMPLEADO",
--Crear nombre de usuario
        substr(PNOMBRE_EMP, 1,3) || 
        length(pnombre_emp) ||
        '*' || 
        substr(SUELDO_BASE, -1) ||
        DVRUN_EMP || 
        (EXTRACT(YEAR FROM SYSDATE) - EXTRACT(YEAR FROM FECHA_CONTRATO)) ||
        case when (EXTRACT(YEAR FROM SYSDATE) - EXTRACT(YEAR FROM FECHA_CONTRATO)) > 10 then 'X' else '' end as "NOMBRE_USUARIO",

--Crear contraseña de usuario
        substr(NUMRUN_EMP, 3,1) ||
        (EXTRACT(YEAR FROM FECHA_NAC) + 2) ||
        LPAD((TO_NUMBER(substr(SUELDO_BASE, -3)) - 1), 3, '0') ||
        case 
            when NOMBRE_ESTADO_CIVIL in ('CASADO','ACUERDO DE UNION CIVIL') then lower((substr(APPATERNO_EMP, 1,2)))
            when NOMBRE_ESTADO_CIVIL in ('DIVORCIADO','SOLTERO') then lower(substr(APPATERNO_EMP, 1,1)) || lower(substr(APPATERNO_EMP, -1))
            when NOMBRE_ESTADO_CIVIL in ('VIUDO') then lower(substr(APPATERNO_EMP, -3,2))
            when NOMBRE_ESTADO_CIVIL in ('SEPARADO') then lower(substr(APPATERNO_EMP, -2,2))
        end ||
        to_number(extract(month from sysdate)) || to_number(extract(year from sysdate)) ||
        substr(nombre_comuna,1,1) as "CLAVE_USUARIO"
        
        INTO
            v_mess_anno, v_rut_emp, v_dv_rut_emp, v_nombre_emp, v_nombre_user, v_contra_user
    FROM empleado natural join estado_civil natural join comuna where NUMRUN_EMP = :rut_emp;
    
    INSERT INTO USUARIO_CLAVE
    VALUES (v_mess_anno, v_rut_emp, v_dv_rut_emp, v_nombre_emp, v_nombre_user, v_contra_user);


END;


--CASO 3:
--SET SERVEROUTPUT ON;
-- ACTUALIZANDO VALORES EN TABLA CAMION (SI CAMION SE ARRENDO < 5 VECES AL AÑO
VARIABLE nro_pat VARCHAR2(6);
DECLARE
        v_anno      NUMBER(6);
        v_pat       camion.nro_patente%TYPE;
        v_arr_dia   camion.valor_arriendo_dia%TYPE;
        v_gar_dia   camion.valor_garantia_dia%TYPE;
        v_tot_arr   NUMBER(5);
        v_anno_anterior NUMBER(4) := EXTRACT(YEAR FROM TRUNC(ADD_MONTHS(SYSDATE, -12), 'YEAR'));
BEGIN
        :nro_pat := '&nropat';
        SELECT  EXTRACT(YEAR FROM SYSDATE) "ANNO_PROCESO",
                nro_patente,
                valor_arriendo_dia,
                valor_garantia_dia,        
                COUNT(nro_patente) "TOTAL VECES ARRENDADO"
        
        INTO
            v_anno, v_pat, v_arr_dia, v_gar_dia, v_tot_arr
            
        FROM camion NATURAL JOIN arriendo_camion
        WHERE nro_patente = :nro_pat
        AND EXTRACT(YEAR FROM fecha_ini_arriendo) = v_anno_anterior
        GROUP BY 1, nro_patente, valor_arriendo_dia, valor_garantia_dia;        
        
        INSERT INTO HIST_ARRIENDO_ANUAL_CAMION
        VALUES(v_anno, v_pat, v_arr_dia, v_gar_dia, v_tot_arr);
        
        UPDATE CAMION c
    SET (c.valor_arriendo_dia, c.valor_garantia_dia) =
        (SELECT
            CASE
                WHEN COUNT(ac.nro_patente) < 5 THEN ROUND(c.valor_arriendo_dia * 0.775)
                ELSE c.valor_arriendo_dia
            END,
            CASE
                WHEN COUNT(ac.nro_patente) < 5 THEN ROUND(c.valor_garantia_dia * 0.775)
                ELSE c.valor_garantia_dia
            END
        FROM arriendo_camion ac
        WHERE ac.nro_patente = c.nro_patente
        AND EXTRACT(YEAR FROM ac.fecha_ini_arriendo) = v_anno_anterior
        GROUP BY ac.nro_patente
        )
    WHERE c.nro_patente = v_pat;
END;

-- CASO 4:

-- Declaración variables bind
VARIABLE nro_pat VARCHAR2;
VARIABLE valor_multa NUMBER;

DECLARE
  -- Inicializo variables:
  v_anno NUMBER;
  v_pat camion.nro_patente%TYPE;
  v_fech_ini_arriendo arriendo_camion.FECHA_INI_ARRIENDO%TYPE;
  v_dias_solicitados arriendo_camion.DIAS_SOLICITADOS%TYPE;
  v_fech_dev_arriendo arriendo_camion.FECHA_DEVOLUCION%TYPE;
  v_dias_atrasados NUMBER;
  v_mes_anterior DATE;
  v_multa NUMBER;
BEGIN

    -- Ejecuto variables bind:
    :nro_pat := '&nropat';
    :valor_multa := &&valor_multa;
    
    -- Obtener el mes anterior al mes actual
    v_mes_anterior := ADD_MONTHS(TRUNC(SYSDATE, 'MM'), -1);

  -- Inicio mi sentencia SQL
  SELECT EXTRACT(YEAR FROM SYSDATE) "ANNO_PROCESO",
         nro_patente,
         FECHA_INI_ARRIENDO,
         DIAS_SOLICITADOS,
         FECHA_DEVOLUCION
  INTO v_anno,
       v_pat,
       v_fech_ini_arriendo,
       v_dias_solicitados,
       v_fech_dev_arriendo
  FROM camion NATURAL JOIN arriendo_camion
  WHERE nro_patente = :nro_pat
    AND trunc(FECHA_DEVOLUCION, 'MM') = v_mes_anterior;

  v_dias_atrasados := (v_fech_dev_arriendo - v_fech_ini_arriendo) - v_dias_solicitados;
  v_multa := CASE
               WHEN v_dias_atrasados > 0 THEN v_dias_atrasados * :valor_multa
               ELSE 0
             END;

  -- Insertar en la tabla MULTA_ARRIENDO
  INSERT INTO MULTA_ARRIENDO (ANNO_MES_PROCESO, NRO_PATENTE,FECHA_INI_ARRIENDO,DIAS_SOLICITADO,FECHA_DEVOLUCION, DIAS_ATRASO, VALOR_MULTA)
  VALUES (TO_CHAR(v_mes_anterior, 'YYYYMM'), v_pat, v_fech_ini_arriendo,v_dias_solicitados,v_fech_dev_arriendo, v_dias_atrasados, v_multa);
END;


select * from camion NATURAL JOIN arriendo_camion where nro_patente = 'AA1001';
