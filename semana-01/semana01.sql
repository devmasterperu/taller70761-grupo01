--Crear consultas utilizando SELECT
--SELECT y su orden de ejecución
--1. Cantidad de actividades económicas por emprendimiento (Utilizar sólo la tabla tbEmprendimientoActividad)
--select * from dbo.tbEmpleado<> produccion.tbEmpleado

select * from produccion.tbEmprendimientoActividad

 --1 from produccion.tbEmprendimientoActividad
 --5 select *

 /*
 select ciiu as actividad --5
 from produccion.tbEmprendimientoActividad --1
 where actividad=1 --2
 */

 --NO cumple
 select idemprendimiento,count(ciiu) as totactividades --5
 from produccion.tbEmprendimientoActividad --1
 group by idemprendimiento--3
 having totactividades>3--4

 --SI CUMPLE
 select idemprendimiento,count(ciiu) as totactividades --5
 from produccion.tbEmprendimientoActividad --1
 group by idemprendimiento--3
 having count(ciiu)>3--4

 --2. Cantidad de actividades económicas por emprendimiento ordenados por número de actividades de
 --mayor a menor (Utilizar sólo la tabla tbEmprendimientoActividad)

 select idemprendimiento,count(ciiu) as totactividades --5
 from produccion.tbEmprendimientoActividad --1
 group by idemprendimiento --3
 --order by count(ciiu) desc
 order by totactividades --6

 --3. Cantidad de actividades económicas por emprendimiento ordenados por número de actividades de
 --mayor a menor (Utilizar sólo la tabla tbEmprendimientoActividad)
 --NOTA: Considere los idemprendimiento con id<10 y mostrar solo agrupaciones con número de actividades>10

 select idemprendimiento,count(ciiu) as totactividades --5
 from produccion.tbEmprendimientoActividad --1
 where idemprendimiento<10--2
 group by idemprendimiento --3
 having count(ciiu)>10--4
 order by totactividades --6

 select idemprendimiento,--5.1
        count(ciiu) as totactividades,--5.2
		count(ciiu) +1 as totactividadesnuevas--5.3
		--totactividades+1
 from produccion.tbEmprendimientoActividad --1
 group by idemprendimiento --3
 order by totactividadesnuevas --6


 --Uso de esquemas

 select count(1) from dbo.tbActividadEconomica
 select count(1) from produccion.tbActividadEconomica

 --Uso de alias en tablas-columnas
 select ea.idemprendimiento,
        --count(ea.ciiu) as totactividades,
		count(ea.ciiu)  totactividades,
		100*count(ea.ciiu)+1  totactividadesfact
 --from produccion.tbEmprendimientoActividad as ea
 from produccion.tbEmprendimientoActividad ea
 group by idemprendimiento
 order by totactividades 

 --Uso de expresiones en tablas
 --Mostrar el id y RUC-razon social concatenada
 select id,ruc+'-'+razonsocial as nombre,'*****'+nombre+'*****'
 from produccion.tbEmprendimiento

 --Uso de DISTINCT

 -- 1 1
 -- 1 2
 -- 1 2
 ---1 3

 create table dbo.Valores(
 valor1 int,
 valor2 int
 )

 insert into dbo.Valores
 select 1,1 union all
 select 1,2 union all
 select 1,2 union all
 select 1,3 union all
 select 2,2

 select * from dbo.Valores

 --select distinct valor1 from dbo.Valores--2
 --select distinct valor2 from dbo.Valores--3
 --select distinct valor1,valor2 from dbo.Valores--4

 select distinct departamento,provincia,distrito from produccion.tbUbigeo--2

 --Uso de IS NULL/IS NOT NULL (WHERE|HAVING)
 --Obtener los emprendimiento cuya fecha de inicio se desconoce
 SELECT * FROM produccion.tbEmprendimiento
 WHERE fecinicio IS NULL

  --Obtener los emprendimiento cuya fecha de inicio si conocemos
 SELECT * FROM produccion.tbEmprendimiento
 WHERE fecinicio IS NOT NULL--PREDICADO
 --TRUE:  SE MUESTRA
 --FALSE: NO SE MUESTRA

 --Uso de predicados
 --AND
 SELECT * FROM produccion.tbEmprendimiento
 WHERE (1=1) AND (1=0)
 --OR
 SELECT * FROM produccion.tbEmprendimiento
 WHERE ((1=1) OR (1=0)) AND (1=0)

--Obtener aquellos ubigeos que cumplan al menos una de las siguientes condiciones:
--Departamento AMAZONAS, poblacion>10000
--Departamento LORETO, areakm2<50000 
--No sean del distrito de INDIANA,provincia MAYNAS, departamento LORETO 

--Obtener aquellos ubigeos que no cumplan la 1 ni 2 condición pero si la 3:
--Departamento AMAZONAS, poblacion>10000 (CONDICION 1)
--Departamento LORETO, areakm2<50000 (CONDICION 2)
--No sean del distrito de INDIANA,provincia MAYNAS, departamento LORETO (CONDICION 3)

select * from produccion.tbUbigeo
WHERE
NOT
	(
		(departamento='AMAZONAS' and poblacion>10000) OR
		(departamento='LORETO' and areakm2<50000 )
	)   
AND
	NOT (departamento='LORETO' and provincia='MAYNAS' and distrito='INDIANA' )
--Obtener aquellos ubigeos que cumplan la 1 o la 2 condición pero no la 3:
--Departamento AMAZONAS, poblacion>10000
--Departamento LORETO, areakm2<50000
--No sean del distrito de INDIANA,provincia MAYNAS, departamento LORETO 
select * from produccion.tbUbigeo
WHERE
	(
		(departamento='AMAZONAS' and poblacion>10000) OR
		(departamento='LORETO' and areakm2<50000 )
	)   
AND
    (departamento='LORETO' and provincia='MAYNAS' and distrito='INDIANA' )

--Filtrado con LIKE
--Uso de %
--Obtener los ubigeos que incluyan la palabra UAU dentro del nombre del distrito

--Obtener los ubigeos que NO cumplan al menos una de las sgtes condiciones:
---Incluyan la palabra UAU dentro del nombre de la provincia 
---El nombre del departamento inicie con A 
---La última letra del distrito sea E 

select * from produccion.tbUbigeo
WHERE 
NOT(
	(provincia LIKE '%UAU%') OR
	(departamento LIKE 'A%') OR
	(distrito LIKE '%E')
)

--Uso de _
--Obtener los ubigeos donde la 3 letra del distrito sea una A
--Obtener los ubigeos donde la 4 letra del departamento sea una A y 
--la 2 letra del departamento sea una E

--Filtro de Lista de Caracteres
--[aeiou]
--[bcd]

--Obtener los ubigeos cuyos distritos inicien con una vocal o terminen con una vocal
--p o q
select * from produccion.tbUbigeo
where distrito LIKE '[aeiou]%' or distrito LIKE '%[aeiou]' 
--Obtener los ubigeos cuyos distritos inicien con una vocal y terminen con una vocal
select * from produccion.tbUbigeo
where distrito LIKE '[aeiou]%' and distrito LIKE '%[aeiou]' 
--Obtener los ubigeos cuyos distritos NO inicien con una vocal ni terminen con una vocal
--NOT (p o q)=not p AND not q
select * from produccion.tbUbigeo
where NOT (distrito LIKE '[aeiou]%' or distrito LIKE '%[aeiou]')

--Filtro de Rango de Caracteres
--[a-c]=[abc]
--[b-e]=[bcde]

--Obtener los ubigeos cuyas provincias su primera letra se encuentre entre la C y la F,
--su tercera letra sea una vocal y su penúltima letra se encuentre entre la A y la E.
select * from produccion.tbUbigeo
where provincia LIKE '[c-f]_[aeiou]%[a-e]_'

--Filtro No se encuentre en Rango de Caracteres
--[^a-c]=Cualquier caracter que no sea a,b y c
--[^b-e]=Cualquier caracter que no sea b,c,d y e

--Obtener los ubigeos cuyas provincias su primera letra NO se encuentre entre la C y la F y
--su tercera letra sea una consonante

select * from produccion.tbUbigeo
where provincia LIKE '[^c-f]_[^aeiou]%'--777

--Obtener los ubigeos cuyas provincias su primera letra NO se encuentre entre la C y la F o
--su tercera letra sea una consonante

select * from produccion.tbUbigeo
where provincia LIKE '[^c-f]%' or provincia LIKE '__[^aeiou]%'--1542

--NOTA: Los nombres no tienen caracteres especiales. Solo vocales y consonantes

--Uso de TOP
select top(2) valor1 from dbo.Valores
order by valor1 desc

select top(2) with ties valor1  from dbo.Valores
order by valor1 desc

select top(50) PERCENT valor1 from dbo.Valores
order by valor1 desc

select top(50) PERCENT with ties valor1 from dbo.Valores
order by valor1 desc

--Uso de OFFSET-FETCH
--OFFSET n ROWS --Obligatorio
--[FETCH NEXT m ROWS ONLY]
--[FETCH FIRST m ROWS ONLY]
select valor1 from dbo.Valores
order by valor1 desc
OFFSET 2 ROWS
FETCH NEXT 3 ROWS ONLY

select valor1 from dbo.Valores
order by valor1 desc
OFFSET 0 ROWS
FETCH FIRST 8 ROWS ONLY

--Uso de UNION, UNION ALL, INTERSECT y EXCEPT

SELECT * FROM dbo.Valores
--Que valores se encuentran en la columna 1 pero no en la columna 2 de la tabla Valores.
--Que valores son comunes entre la columna 1 y la columna 2 de la tabla Valores.

SELECT * into dbo.Valores2 FROM dbo.Valores

insert into dbo.Valores2 values (5,5),(5,6),(6,1),(6,2)

--Que combinaciones de valores se encuentran en la tabla 2 y también tabla 1.
--Que combinaciones de valores se encuentran en la tabla 1 pero no en la tabla 2.
--Que combinaciones de valores se encuentran en la tabla 2 pero no en la tabla 1.

--Mostrar un reporte con todas las combinaciones, incluyendo combinaciones repetidas,
--donde se identifique la tabla origen utilizando como alias para la columna "Origen".

select valor1,valor2,'tabla1' as origen from dbo.Valores
union all 
select valor1,valor2,'tabla2' as origen from dbo.Valores2