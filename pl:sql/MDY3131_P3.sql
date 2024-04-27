--CASO 1: 

--Iniciamos variable rut_cli, y ejecutamos
VARIABLE rut_cli    NUMBER;
exec    :rut_cli := &rutcli;

DECLARE

--Declaramos variables, tanto como las que tengo en el select
--Como las variables que utilizaré en mi sentencia condicional
v_nro_cliente   cliente.nro_cliente%TYPE;
v_rut_cli       VARCHAR2(20);
v_nom_cli       VARCHAR2(100);
v_tipo_cli      tipo_cliente.nombre_tipo_cliente%TYPE;
v_tot_cre       NUMBER;
v_pesos_extras  NUMBER;
v_pesos_totales NUMBER;
p_base NUMBER := &pesosBase;
p_extra NUMBER := &pesosExtras;
v_total_credito NUMBER    := &totalCredito;
v_tramo_min NUMBER := &tramoMinimo;
v_tramo_medio NUMBER := &tramoMedio;
v_tramo_max NUMBER := &tramoMax;

BEGIN
    
    -- Calcular pesos extras según tramo de montos dados de manera parametricas y total credito
        IF v_nom_cli = 'Trabajadores independientes' THEN
            IF v_total_credito < v_tramo_min THEN
                v_pesos_extras := v_total_credito / 100000 * p_extra;
            ELSIF v_total_credito BETWEEN v_tramo_min AND v_tramo_medio THEN
                v_pesos_extras := v_total_credito / 100000 * p_extra;
            ELSE
                v_pesos_extras := v_total_credito / 100000 * p_extra;
            END IF;
        END IF;
    
        -- Calcular pesos totales
        v_pesos_totales := (v_total_credito / 100000) * (p_base + p_extra);
    
    SELECT  cli.nro_cliente,
        TO_CHAR(numrun,'999G999G999')||'-'||dvrun "RUN_CLIENTE",
        pnombre||' '||snombre||' '||appaterno||' '||apmaterno "NOMBRE_CLIENTE",
        nombre_tipo_cliente,
        MONTO_SOLIC_CREDITOS 
        
        INTO
        v_nro_cliente, v_rut_cli, v_nom_cli, v_tipo_cli, v_tot_cre
            
    FROM    
        (SELECT nro_cliente,
                numrun, dvrun,
                pnombre, snombre, appaterno, apmaterno,
                nombre_tipo_cliente    
        FROM cliente NATURAL JOIN tipo_cliente) cli
    JOIN    
        (SELECT nro_cliente, SUM(monto_solicitado) MONTO_SOLIC_CREDITOS
        FROM credito_cliente
        WHERE EXTRACT (YEAR FROM fecha_solic_cred) = EXTRACT(YEAR FROM SYSDATE) - 1
        GROUP BY nro_cliente) cre
        
    ON cli.nro_cliente = cre.nro_cliente
    WHERE numrun = :rut_cli;
    
    INSERT INTO CLIENTE_TODOSUMA
    VALUES(v_nro_cliente, v_rut_cli, v_nom_cli, v_tipo_cli, v_tot_cre,v_pesos_totales);
    
    dbms_output.put_line(v_nro_cliente||','||v_rut_cli||','|| v_nom_cli||','|| v_tipo_cli||','||v_tot_cre || ', ' || v_pesos_totales);
END;











--CASO 2: 

--Iniciamos variable rut_cli, y ejecutamos
VARIABLE rut_cli    NUMBER;
exec    :rut_cli := &rutcli;

DECLARE
v_nro_cliente   cliente.nro_cliente%TYPE;
v_rut_cli       VARCHAR2(20);
v_nom_cli       VARCHAR2(100);
v_nomb_prof_ofic VARCHAR2(100);
v_dia_cumpl     VARCHAR2(100);
v_monto_total_ahorrado NUMBER := &monto_total_ahorrado;
v_tramo_1   NUMBER := &tramo_1;
v_tramo_2   NUMBER := &tramo_2;
v_tramo_3   NUMBER := &tramo_3;
v_tramo_4   NUMBER := &tramo_4;
v_tramo_5   NUMBER := &tramo_5;
v_monto_giftcard NUMBER;
v_mes_actual NUMBER;
v_mes_siguiente NUMBER;
v_mes_cumpleanno NUMBER;


BEGIN
    
    select  nro_cliente,
        to_char(numrun,'999G999G999') || '-' ||dvrun "RUN_CLIENTE",
        initcap(pnombre || ' ' || snombre || ' ' || appaterno || ' '|| apmaterno) "NOMBRE_CLIENTE",
        NOMBRE_PROF_OFIC,
        EXTRACT(DAY FROM FECHA_NACIMIENTO) || ' de ' || to_char(FECHA_NACIMIENTO, 'month') "DIA_CUMPLEANNO",
        EXTRACT(MONTH FROM FECHA_NACIMIENTO) "MES_CUMPLEANNO"
        
    INTO    v_nro_cliente,
            v_rut_cli,
            v_nom_cli,
            v_nomb_prof_ofic,
            v_dia_cumpl,
            v_mes_cumpleanno
    from cliente natural join profesion_oficio natural join producto_inversion_cliente
    where numrun = :rut_cli;
    
     -- Obtener mes actual y mes siguiente
      v_mes_actual := EXTRACT(MONTH FROM SYSDATE);
      v_mes_siguiente := v_mes_actual + 1;
      IF v_mes_siguiente > 12 THEN
        v_mes_siguiente := 1;
      END IF;
    
        -- Calcular valor giftcard según tramo de total ahorrado dados de manera parametricas 
        IF v_monto_total_ahorrado < v_tramo_1 THEN
            v_monto_giftcard := 0;
            
        ELSIF v_monto_total_ahorrado BETWEEN v_tramo_1 AND v_tramo_2 THEN
            v_monto_giftcard := 50000;
            
        ELSIF v_monto_total_ahorrado BETWEEN v_tramo_2 AND v_tramo_3 THEN
            v_monto_giftcard := 100000;
            
        ELSIF v_monto_total_ahorrado BETWEEN v_tramo_3 AND v_tramo_4 THEN
            v_monto_giftcard := 200000;
            
        ELSE v_monto_giftcard := 300000;
        END IF;
        
        
        -- Validar si el cliente está de cumpleaños en el mes siguiente
      IF v_mes_cumpleanno <> v_mes_siguiente THEN
        v_monto_giftcard := 0;
      END IF;

    dbms_output.put_line(v_nro_cliente||','||v_rut_cli||','|| v_nom_cli||','|| v_nomb_prof_ofic||','||v_dia_cumpl || ', ' || v_monto_giftcard);
END;



select * from cliente natural join profesion_oficio natural join producto_inversion_cliente;



