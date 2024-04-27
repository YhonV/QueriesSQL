--SET SERVEROUTPUT ON;

--Para resolver el caso 1, necesito empezar sacando la fecha de antiguedad de la persona.
--Por lo tanto, necesito obtener la fecha en que ejecuto el programa y almacenarlo en una variable.

VAR b_fec_proceso   VARCHAR2;
EXEC :b_fec_proceso := '&FECHA_PROCESO';

VAR b_carga_fam     NUMBER;
EXEC :b_carga_fam := &CARGA_FAMILIAR;

TRUNCATE TABLE HABER_MES_VENDEDOR;
TRUNCATE TABLE DESCUENTO_MES_VENDEDOR;

DECLARE

    v_anio_antiguedad           NUMBER(5);
    v_fec_proceso               DATE;
    v_fec_contrato              VENDEDOR.FEC_CONTRATO%TYPE;
    v_porc_bonif                bonificacion_antig.PORC_BONIF%TYPE;
    v_min_vendedor              VENDEDOR.ID_VENDEDOR%TYPE;
    v_max_vendedor              VENDEDOR.ID_VENDEDOR%TYPE;
    v_asig_antig                NUMBER(10);
    v_sueldo_base               VENDEDOR.SUELDO_BASE%TYPE;
    v_carg_fami                 NUMBER(2);
    v_asig_carga_familiar       NUMBER(6);
    v_monto_comis               NUMBER(6);
    v_id_categoria              VARCHAR(2);
    v_porcentaje                CATEGORIA.porcentaje%TYPE;
    v_bono_especial             NUMBER(6);
    v_total_haberes             NUMBER(6);
    v_porc_descto_afp           AFP.PORC_DESCTO_AFP%TYPE;
    v_id_afp                    VENDEDOR.ID_AFP%TYPE;
    v_desct_afp                 NUMBER(6);
    v_porc_descto_salud         SALUD.PORC_DESCTO_SALUD%TYPE;
    v_id_salud                  SALUD.PORC_DESCTO_SALUD%TYPE; 
    v_desct_salud               NUMBER(6);
    v_total_descuento           NUMBER(7);
    v_rut_vendedor              VENDEDOR.RUT_VENDEDOR%TYPE;
    v_mes_proceso               NUMBER(2);
    v_anio_proceso              NUMBER(4);
    
BEGIN

-- Obtenemos id de cada uno de los vendedores, para extraer los datos correspondientes
-- Ya que se deben procesar todos los vendedores
    SELECT MIN(ID_VENDEDOR), MAX(ID_VENDEDOR)
    INTO v_min_vendedor, v_max_vendedor
    FROM VENDEDOR;

-- Empecemos a armar el Loop para que me pueda imprimir y manejar todos los vendedores
    WHILE v_min_vendedor <= v_max_vendedor LOOP
    
        v_porc_bonif := 0;
        v_anio_antiguedad := 0;
        v_asig_antig := 0;
        v_monto_comis := 0;
        v_porcentaje := 0;
        v_bono_especial := 0;
        v_total_haberes := 0;
        v_porc_descto_afp := 0;
        v_desct_afp := 0;
        v_porc_descto_salud := 0;
        v_id_salud := 0;
        v_desct_salud := 0;
        v_total_descuento := 0;
      
    --Obtenemos fec_contrato para almacenarla en una variable y calcular v_anio_antiguedad
    --Obtenemos sueldo base para almacenarla en una variable,
    --Obtenemos id_categoria para almacenarla en una variable,
    --Obtenemos id_afp e id_salud para almacenarla en una variable
        SELECT FEC_CONTRATO, SUELDO_BASE,ID_CATEGORIA, ID_AFP, ID_SALUD, RUT_VENDEDOR
        INTO v_fec_contrato, v_sueldo_base, v_id_categoria, v_id_afp, v_id_salud, v_rut_vendedor
        FROM VENDEDOR
        WHERE ID_VENDEDOR = v_min_vendedor;
    
        
     -- Almacenamos datos en las variable anio_antiguedad y v_fec_proceso
        v_fec_proceso := TO_DATE(:b_fec_proceso, 'DD-MM-YYYY');
        v_anio_antiguedad := ROUND(MONTHS_BETWEEN(v_fec_proceso, v_fec_contrato)/12);
        
    -- Almacenamos datos en variables para ser utilizadas luego
        v_mes_proceso := EXTRACT(MONTH FROM v_fec_proceso);
        v_anio_proceso := EXTRACT(YEAR FROM v_fec_proceso);
        
        
        
        IF v_anio_antiguedad > 0 THEN
            SELECT PORC_BONIF
            INTO v_porc_bonif
            FROM bonificacion_antig
            WHERE v_anio_antiguedad BETWEEN ANNO_TRAMO_INF AND ANNO_TRAMO_SUP;
            v_asig_antig := round(v_sueldo_base * (v_porc_bonif/100));
        END IF;
    
        --REQUERIMIENTO 2    
        -- Obtengo total de carga familiar por ID del vendedor
        -- Luego lo multiplicaré para obtener el valor de la asignación por carga
        SELECT count(*)
        INTO v_carg_fami
        FROM CARGA_FAMILIAR
        WHERE id_vendedor = v_min_vendedor;
        
        v_asig_carga_familiar := round(v_carg_fami * :b_carga_fam);
      
      
      --REQUERIMIENTO 3
      --Obtenemos el monto comision de cada vendedor por el mes de la fecha de proceso
      --Le realizamos un sum porque tiene varias comisiones por el mismo id en el mismo mes
      --Manejamos los 0 con un NVL
        SELECT NVL(sum(MONTO_COMISION),0)
        INTO v_monto_comis
        FROM COMISION_VENTA
        WHERE id_vendedor = v_min_vendedor
        AND  MES = v_mes_proceso 
        AND ANNO = v_anio_proceso;
        
        
    -- REQUERIMIENTO 4
    --Filtramos el tipo de categoría, si está entro A y B
    --Y hacemos select del porcentaje correspondiente en base a la categoria
    --Y lo almacenamos en la variable v_bono especial
        IF UPPER(v_id_categoria) IN ('A','B') THEN
        
            SELECT porcentaje
            INTO v_porcentaje
            from CATEGORIA
            WHERE ID_CATEGORIA = v_id_categoria;
        
        END IF;
        
        v_bono_especial := round(v_monto_comis * (v_porcentaje/100));
        
    -- REQUERIMIENTO 5
    -- El total de haberes de un vendedor corresponderá al sueldo 
    -- + bonificación por antigüedad + asignación carga familiar + comisión por ventas + bono por categoría
        v_total_haberes := v_sueldo_base + v_asig_antig + v_asig_carga_familiar + v_monto_comis + v_bono_especial;
        
        
    
    -- REQUERIMIENTO 6
    -- Obtenemos porcentaje descuento afp, la almacenamos, donde id_afp (solicitado antes en el select principal)
    -- Realizamos operación para obtener el descuento correspondiente
        select PORC_DESCTO_AFP
        INTO v_porc_descto_afp
        FROM AFP
        WHERE ID_AFP = v_id_afp;
        
        v_desct_afp := ROUND(v_total_haberes * (v_porc_descto_afp/100));
        
    -- Obtenemos porcentaje descuento salud, la almacenamos, donde id_salud (solicitado antes en el select principal)
    -- Realizamos operación para obtener el descuento correspondiente
        SELECT PORC_DESCTO_SALUD
        INTO v_porc_descto_salud
        FROM SALUD
        WHERE ID_SALUD = v_id_salud;
        
        v_desct_salud := ROUND(v_total_haberes * (v_porc_descto_salud/100));
        
        
        --REQUERIMIENTO 7
        v_total_descuento := v_desct_salud + v_desct_afp;
        
        INSERT INTO HABER_MES_VENDEDOR VALUES
        (v_min_vendedor, 
        v_rut_vendedor, 
        v_mes_proceso, 
        v_anio_proceso, 
        v_sueldo_base, 
        v_asig_antig, 
        v_asig_carga_familiar, 
        v_monto_comis, 
        v_bono_especial,
        v_total_haberes);
        
        
        INSERT INTO DESCUENTO_MES_VENDEDOR VALUES(
        v_min_vendedor,
        v_rut_vendedor,
        v_mes_proceso, 
        v_anio_proceso,
        v_desct_salud,
        v_desct_afp,
        v_total_descuento);
        
        --Los id van de 10 en 10, por lo tanto aumentamos en 10 mi id minimo
        v_min_vendedor := v_min_vendedor + 10;
    END LOOP;
END;


COMMIT;

select * from vendedor;
select * from bonificacion_antig;
select * from CARGA_FAMILIAR;
select * from COMISION_VENTA;
select * from CATEGORIA;
select * from afp;
select * from salud;


    

   
        
    
    