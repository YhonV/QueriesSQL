--SET SERVEROUTPUT ON;

VAR b_contador      NUMBER;

DECLARE

    v_porc_desc             DESCUENTO.PORC_DESC%TYPE;
    v_min_folio             CIRUGIAS.FOLIO%TYPE;
    v_max_folio             CIRUGIAS.FOLIO%TYPE;
    v_neto                  NUMBER(10);
    v_descuento_servicio    NUMBER(10);
    v_fecha_operacion       DATE;
    v_dia_cirugia           VARCHAR2(20);
    v_total_servicio        NUMBER(10);
    v_nombre_suc            SUCURSAL.NOMBRE_SUC%TYPE;
    v_mes_op                VARCHAR2(10);
    v_anio_op               NUMBER(4);
    v_descto_extraor        NUMBER(5);
    v_total_descuento       NUMBER(10);
    v_iva                   NUMBER(10);
    v_total                 NUMBER(10);
BEGIN

    :b_contador := 0;

    SELECT MIN(FOLIO), MAX(FOLIO)
    INTO v_min_folio, v_max_folio
    FROM CIRUGIAS;
 
    FOR i IN v_min_folio .. v_max_folio LOOP
        
        :b_contador := :b_contador + 1;
                
        SELECT  NETO, FECHA_OPERACION
        INTO v_neto, v_fecha_operacion
        FROM CIRUGIAS
        WHERE FOLIO = v_min_folio;

        
        SELECT SUM(PRECIO)
        INTO v_total_servicio
        FROM CIRUGIAS NATURAL JOIN DET_SERVICIO
        NATURAL JOIN SERVICIO
        WHERE FOLIO = v_min_folio;
        
        
        SELECT PORC_DESC
        INTO v_porc_desc
        FROM DESCUENTO
        WHERE v_total_servicio BETWEEN VALOR_INI AND VALOR_FIN;


        v_descuento_servicio := round(v_total_servicio * (v_porc_desc/100));


        v_dia_cirugia := TO_CHAR(v_fecha_operacion, 'DAY');

        IF  TRIM(v_dia_cirugia) in ('MARTES', 'JUEVES') AND v_porc_desc = 0 THEN
            v_descuento_servicio := round(v_total_servicio * ((v_porc_desc + 5)/100));
        END IF;
        
        IF v_porc_desc > 20 THEN
            IF  TRIM(v_dia_cirugia) in ('DOMINGO') THEN v_porc_desc := v_porc_desc - 10; END IF;
            IF  TRIM(v_dia_cirugia) in ('SÁBADO') THEN v_porc_desc := v_porc_desc - 5; END IF;
        END IF;
        
        SELECT nombre_suc
        INTO v_nombre_suc
        FROM CIRUGIAS NATURAL JOIN MEDICO
        NATURAL JOIN SUCURSAL
        WHERE FOLIO = v_min_folio;
        
        v_mes_op := EXTRACT(MONTH FROM v_fecha_operacion);
        v_anio_op := EXTRACT(YEAR FROM v_fecha_operacion);
        
        
        IF v_mes_op = 'MAYO' AND v_anio_op = 2015 THEN
            IF v_nombre_suc = 'ÑUÑOA' THEN v_descuento_servicio := round(v_total_servicio * ((v_porc_desc + 3)/100)); END IF;
            IF v_nombre_suc = 'SANTIAGO' THEN v_descuento_servicio := round(v_total_servicio * ((v_porc_desc + 3)/100)); END IF;
        END IF;
        
        
        v_total_descuento := v_total_servicio - v_descuento_servicio;
        v_iva := v_total_descuento * 0.19;
        v_total := v_total_descuento + v_iva;
        
        UPDATE CIRUGIAS SET
            DESCUENTO = v_descuento_servicio,
            NETO = v_total_descuento,
            IVA = v_iva,
            TOTAL = v_total
        WHERE FOLIO = v_min_folio;
        
        
        DBMS_OUTPUT.PUT_LINE(v_total_descuento || ' ' || v_iva || ' ' || v_total);
        v_min_folio := v_min_folio +1;
    END LOOP; 
    
    DBMS_OUTPUT.PUT_LINE('============================================');
    DBMS_OUTPUT.PUT_LINE('CANTIDAD DE VECES QUE ITERA ' || :b_contador);
END;

commit;