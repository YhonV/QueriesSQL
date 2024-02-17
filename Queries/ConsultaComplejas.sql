-- CLASE 11 OCTUBRE 2023

-- ====================================================================================
-- PREGUNTA 1: 
-- Obtener el código y la especie de todos los animales que necesitan el nutriente ‘Riboflavina’
-- y en qué cantidad.

select  a.cod_animal "Animal",
        a.tipo_animal "Especie",
        an.cantidad_necesitada "Cantidad requerida"
from animal a
join animal_nutriente an
on a.cod_animal = an.cod_animal
where an.nombre_nutriente = 'Riboflavina';


-- ====================================================================================
-- PREGUNTA 2: 
-- Obtener todas las vacas que comenzaron la dieta 342567 el 01/01/1999 y que pesan más de
-- 550 kg.

select a.cod_animal "Vacas"
from animal a
join dieta_animal_fechaInicio daf
on a.cod_animal = daf.cod_animal
where a.tipo_animal = 'Vaca' and a.peso > 550 and
        daf.fecha_inicio > to_date('01/01/1999','DD/MM/YYYY');


-- ====================================================================================
-- PREGUNTA 3: 
-- Obtener el alimento más barato que puede tomar el animal ‘L-03-D8’ que necesita el
-- nutriente ‘Vitamina A’ para remediar esta carencia.

select a.coste_alimento "Precio", na.nombre_alimento "Alimento"
from animal_nutriente an
join nutriente n
on an.nombre_nutriente = n.nombre_nutriente
join nutriente_alimento na
on n.nombre_nutriente = na.nombre_nutriente
join alimento a
on na.nombre_alimento = a.nombre_alimento
where n.nombre_nutriente = 'Vitamina A' and an.cod_animal = 'L-03-D8' and 
            a.coste_alimento = (select min(coste_alimento) from alimento);
            
select a.coste_alimento "Precio", na.nombre_alimento "Alimento"
from animal_nutriente an
join nutriente n
on an.nombre_nutriente = n.nombre_nutriente
join nutriente_alimento na
on n.nombre_nutriente = na.nombre_nutriente
join alimento a
on na.nombre_alimento = a.nombre_alimento
where n.nombre_nutriente = 'Vitamina A' and an.cod_animal = 'L-03-D8' and 
            a.coste_alimento =  (select MIN(a.coste_alimento)
                                from animal_nutriente an
                                join nutriente n
                                on an.nombre_nutriente = n.nombre_nutriente
                                join nutriente_alimento na
                                on n.nombre_nutriente = na.nombre_nutriente
                                join alimento a
                                on na.nombre_alimento = a.nombre_alimento
                                where n.nombre_nutriente = 'Vitamina A' and an.cod_animal = 'L-03-D8');
                                
-- ====================================================================================
-- PREGUNTA 4: 
-- Obtener todos los caballos que no necesitan avena en su dieta

select distinct a.cod_animal
from animal a
join dieta_animal_fechaInicio daf
on a.cod_animal = daf.cod_animal
join dieta d
on daf.cod_dieta = d.cod_dieta
join alimento_dieta_toma adt
on daf.cod_dieta = adt.cod_dieta
where a.tipo_animal = 'Caballo' and adt.nombre_alimento not in (select nombre_alimento
                                                                from alimento
                                                                where nombre_alimento = 'Avena');


-- ====================================================================================
-- PREGUNTA 5: 
-- Obtener todos los animales y su tipo que comenzaron alguna dieta el 01/01/1999 y cuál es la dieta.

select a.cod_animal, a.tipo_animal,daf.cod_dieta
from animal a
join dieta_animal_fechaInicio daf
on a.cod_animal = daf.cod_animal
where daf.fecha_inicio = to_date('01/01/1999','DD/MM/YYYY');


-- ====================================================================================
-- PREGUNTA 6: 
-- Obtener todos los alimentos que tienen los nutrientes Calcio o Magnesio

select na.nombre_alimento "Alimentos con Ca o Mg"
from nutriente_alimento na
where nombre_nutriente in ('Calcio','Magnesio');

-- ====================================================================================
-- PREGUNTA 7: 
-- Obtener todos los corderos nacidos en 1999 que han iniciado la dieta 453872 después del
-- 01/11/1999 y cuyo peso se encuentra entre 30 y 35 kilos.

select a.cod_animal "Corderos faltos de peso"
from animal a
join dieta_animal_fechaInicio daf
on a.cod_animal = daf.cod_animal
where a.tipo_animal = 'Cordero' and 
        a.peso between 30 and 35 and
        daf.fecha_inicio > to_date('01/01/1999','DD/MM/YYYY') and
        a.ano_nacimiento = 1999 and
        daf.cod_dieta = 453872;

-- ====================================================================================
-- PREGUNTA 8: 
-- Obtener el peso medio de todas las vacas.

select round(avg(peso),6) "Peso medio de las vacas"
from animal
where tipo_animal = 'Vaca';


-- ====================================================================================
-- PREGUNTA 9: 
-- Cree una consulta que muestre el código del animal, el tipo del animal, el código de las
-- dietas, y la fecha de inicio de las mismas, para todos los animales que pesan más de 200Kg
-- y hayan nacido en 1999

select a.cod_animal, a.tipo_animal, daf.cod_dieta, daf.fecha_inicio
from animal a
join dieta_animal_fechaInicio daf
on a.cod_animal = daf.cod_animal
where a.peso > 200 and ano_nacimiento = 1999;

-- ====================================================================================
-- PREGUNTA 10:
-- Muestre el peso promedio agrupando los animales según su tipo. 

select tipo_animal "Tipo Animal",
        round(avg(peso),1) "Peso Medio"
from animal
group by tipo_animal;













