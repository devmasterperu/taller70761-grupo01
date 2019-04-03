--TABLAS DERIVADAS
select resdepartamento.departamento, resdepartamento.total
from
(
SELECT departamento, MAX(poblacion) as total
FROM produccion.tbUbigeo
GROUP BY departamento
) resdepartamento--Tabla derivada
--COMMON TABLE EXPRESSION (CTE)
/*
(
SELECT departamento, MAX(poblacion) as total
FROM produccion.tbUbigeo
GROUP BY departamento
) resdepartamento--Tabla derivada
(
SELECT departamento, MAX(poblacion) as total
FROM produccion.tbUbigeo
GROUP BY departamento
) resdepartamento2--Tabla derivada
*/
--Mostrar por cada emprendimiento la población de su departamento
WITH 
CTE_POBLACIONDPTO
AS
(
SELECT departamento, SUM(poblacion) as poblaciontot
FROM produccion.tbUbigeo
GROUP BY departamento--consulta interna
),
CTE_POBLACIONPROV
AS
(
SELECT provincia, SUM(poblacion) as poblaciontot
FROM produccion.tbUbigeo
GROUP BY provincia--consulta interna
)
--select top 1 * from CTE_POBLACIONDPTO;--consulta externa
SELECT
(select max(poblaciontot) from CTE_POBLACIONDPTO) as maxpoblaciontotdpto,
(select min(poblaciontot) from CTE_POBLACIONDPTO) as minpoblaciontotdpto,
(select max(poblaciontot) from CTE_POBLACIONPROV) as maxpoblaciontotprov,
(select min(poblaciontot) from CTE_POBLACIONPROV) as minpoblaciontotprov
;--consulta externa

select top 10 * from CTE_POBLACIONDPTO;

--Mostrar por emprendimiento el ruc,la razón social y el total de actividades por emprendimiento
--utilizando CTEs
WITH CTE_resumen
AS
(
 select idemprendimiento as id,count(ciiu) as totalact from produccion.tbEmprendimientoActividad
 group by idemprendimiento
)
select e.id,e.ruc,e.razonsocial,
isnull(et.totalact,0) as total,
(select sum(totalact) from CTE_resumen) as total_actividades
from produccion.tbEmprendimiento e
left join CTE_resumen et on e.id=et.id;

--CTE 
WITH 
CTE_POBLACIONDPTO
AS
(
SELECT departamento, SUM(poblacion) as poblaciontot
FROM produccion.tbUbigeo
GROUP BY departamento--consulta interna
),
CTE_POBLACIONPROV
AS
(
SELECT TOP 10 * from CTE_POBLACIONDPTO--Utilizar un CTE dentro de la definición de otro CTE
)
select * from CTE_POBLACIONPROV;

--Uso de VISTAS
CREATE VIEW produccion.vResumen
AS
WITH CTE_resumen
AS
(
 select idemprendimiento as id,count(ciiu) as totalact from produccion.tbEmprendimientoActividad
 group by idemprendimiento
)
select e.id,e.ruc,e.razonsocial,
isnull(et.totalact,0) as total,
(select sum(totalact) from CTE_resumen) as total_actividades
from produccion.tbEmprendimiento e
left join CTE_resumen et on e.id=et.id;

select top 1 * from produccion.vResumen
select top 10 * from produccion.vResumen
select top 20 * from produccion.vResumen

--CREATE VIEW produccion.vResumen(@idemprendimiento)--NO APLICA

--Uso de funciones de valor tabla
--produccion.vResumen->función escalar-tabla que acepte como parámetro
--el idemprendimiento y devuelve su total de actividades

CREATE FUNCTION produccion.fnActPorEmprendimiento(@idemprendimiento int)
RETURNS TABLE
AS
RETURN
WITH CTE_resumen
AS
(
 select idemprendimiento as id,count(ciiu) as totalact from produccion.tbEmprendimientoActividad
 group by idemprendimiento
)
select e.id,e.ruc,e.razonsocial,
isnull(et.totalact,0) as total,
(select sum(totalact) from CTE_resumen) as total_actividades
from produccion.tbEmprendimiento e
left join CTE_resumen et on e.id=et.id
where e.id=@idemprendimiento

select * from produccion.fnActPorEmprendimiento(2)--funcion de valor tabla

--Funciones escalares
alter function produccion.fnCalculaScoreEmprendimiento(@idemprendimiento integer,@ciiu varchar(4))
returns varchar(100)
as 
begin
  declare @score int, @mensaje varchar(100)
  set @score=(select id*100+25 from produccion.tbEmprendimiento where id=@idemprendimiento)
  set @mensaje='El emprendimiento de id:'+cast(@idemprendimiento as varchar)+' tiene ciiu '+@ciiu
  return @mensaje
end

 select produccion.fnCalculaScoreEmprendimiento(1,'9999')--función escalar

 --Uso de tablas temporales
 IF OBJECT_ID('tempdb..##tt_resumen') IS NOT NULL
 BEGIN
	drop table tempdb..##tt_resumen
 END;

WITH CTE_resumen
AS
(
 select idemprendimiento as id,count(ciiu) as totalact from produccion.tbEmprendimientoActividad
 group by idemprendimiento
)
select e.id,e.ruc,e.razonsocial,
isnull(et.totalact,0) as total,
(select sum(totalact) from CTE_resumen) as total_actividades
into tempdb..##tt_resumen
from produccion.tbEmprendimiento e
left join CTE_resumen et on e.id=et.id;

select * from tempdb..##tt_resumen

--Funciones de Agrupamiento+PARTITION
select 
departamento,poblacion,
SUM(poblacion) OVER(PARTITION BY departamento) as SumDpto,
(SELECT SUM(poblacion) FROM produccion.tbUbigeo _u where _u.departamento=u.departamento) as _SumDpto,
COUNT(poblacion) OVER(PARTITION BY departamento) as CountDpto,
(SELECT COUNT(poblacion) FROM produccion.tbUbigeo _u where _u.departamento=u.departamento) as _CountDpto,
AVG(poblacion) OVER(PARTITION BY departamento) as AvgDpto,
(SELECT AVG(poblacion) FROM produccion.tbUbigeo _u where _u.departamento=u.departamento) as _AvgDpto,
MIN(poblacion) OVER(PARTITION BY departamento) as MinDpto,
(SELECT MIN(poblacion) FROM produccion.tbUbigeo _u where _u.departamento=u.departamento) as _MinDpto,
MAX(poblacion) OVER(PARTITION BY departamento) as MaxDpto,
(SELECT MAX(poblacion) FROM produccion.tbUbigeo _u where _u.departamento=u.departamento) as _MaxDpto
from produccion.tbUbigeo u
order by departamento asc

--Funciones de Ranking+PARTITION

/*
update produccion.tbUbigeo 
set poblacion=2498
where id in (43,46)
*/
select 
id,
departamento,
provincia,
distrito,
poblacion,
ROW_NUMBER() OVER(PARTITION BY departamento ORDER BY poblacion DESC) as row_number,
RANK() OVER(PARTITION BY departamento ORDER BY poblacion DESC) as RANK,
DENSE_RANK() OVER(PARTITION BY departamento ORDER BY poblacion DESC) as DENSE_RANK,
NTILE(3) OVER(PARTITION BY departamento ORDER BY poblacion DESC) as NTILE3,
NTILE(4) OVER(PARTITION BY departamento ORDER BY poblacion DESC) as NTILE4
from produccion.tbUbigeo u
order by departamento

SELECT GETDATE(),CAST(GETDATE() AS DATE)

--Funciones OFFSET+PARTITION

select 
id,
departamento,
provincia,
distrito,
poblacion,
LAG(poblacion) OVER(PARTITION BY departamento ORDER BY poblacion DESC) as LAG,
LAG(id) OVER(PARTITION BY departamento ORDER BY poblacion DESC) as LAG_ID,
LEAD(poblacion) OVER(PARTITION BY departamento ORDER BY poblacion DESC) as LEAD,
LEAD(id) OVER(PARTITION BY departamento ORDER BY poblacion DESC) as LEAD_ID,
FIRST_VALUE(poblacion) OVER(PARTITION BY departamento ORDER BY poblacion DESC) as FIRST_VALUE,
LAST_VALUE(poblacion) OVER(PARTITION BY departamento ORDER BY poblacion DESC) as LAST_VALUE
from produccion.tbUbigeo u
order by departamento

--Uso de JSON y SQL SERVER 2016

select top 10
id,
departamento,
provincia,
distrito,
poblacion,
LAG(poblacion) OVER(PARTITION BY departamento ORDER BY poblacion DESC) as LAG,
LAG(id) OVER(PARTITION BY departamento ORDER BY poblacion DESC) as LAG_ID,
LEAD(poblacion) OVER(PARTITION BY departamento ORDER BY poblacion DESC) as LEAD,
LEAD(id) OVER(PARTITION BY departamento ORDER BY poblacion DESC) as LEAD_ID,
FIRST_VALUE(poblacion) OVER(PARTITION BY departamento ORDER BY poblacion DESC) as FIRST_VALUE,
LAST_VALUE(poblacion) OVER(PARTITION BY departamento ORDER BY poblacion DESC) as LAST_VALUE,
NULL as nuevo_codigo
from produccion.tbUbigeo u
order by departamento
for json auto, INCLUDE_NULL_VALUES, 
ROOT('Ubigeos')
--WITHOUT_ARRAY_WRAPPER

select top 10
id,
departamento,
provincia,
distrito,
poblacion,
LAG(poblacion) OVER(PARTITION BY departamento ORDER BY poblacion DESC) as [resumen.poblacion.LAG],
LEAD(poblacion) OVER(PARTITION BY departamento ORDER BY poblacion DESC) as [resumen.poblacion.LEAD],
FIRST_VALUE(poblacion) OVER(PARTITION BY departamento ORDER BY poblacion DESC) as [resumen.poblacion.FIRST_VALUE],
LAST_VALUE(poblacion) OVER(PARTITION BY departamento ORDER BY poblacion DESC) as [resumen.poblacion.LAST_VALUE],
LAG(id) OVER(PARTITION BY departamento ORDER BY poblacion DESC) as [resumen.id.LAG_ID],
LEAD(id) OVER(PARTITION BY departamento ORDER BY poblacion DESC) as [resumen.id.LEAD_ID]
from produccion.tbUbigeo u
order by departamento
for json path, INCLUDE_NULL_VALUES, 
ROOT('Ubigeos')--,
--WITHOUT_ARRAY_WRAPPER

--Uso de OPENJSON
DECLARE @json NVARCHAR(4000) = N'{
    "StringValue": "Gian",
    "IntValue": 45,
    "TrueValue": true,
    "FalseValue": false,
    "NullValue": null,
    "ArrayValue": ["a","b"],
    "ObjectValue": {
        "edad": "27"
    }
}'

select * from OPENJSON(@json)

--Uso de OPENJSON+PATH
declare @myjson varchar(8000)=N'{
    "empresa":"Dev Master Perú SAC",
    "ruc":"1111111111",
    "numTrabajadores":5,
    "cursos":[
        {
            "curso":"Base de Datos con SQL Server 2016",
            "docente":{
                "nombres":"Gianfranco",
                "apellidos":"Manrique",
                "direccion":"Urb.Los Cipreses M-24",
                "ubigeo":{
                    "departamento":"Lima",
                    "provincia":"Huaura",
                    "distrito":"Santa María",
                    "nombre":"Lima\/Huaura\/Santa María"
                }
            }
        },
        {
            "curso":"Modelamiento de Datos",
            "docente":{
                "nombres":"Gianfranco",
                "apellidos":"Manrique",
                "direccion":"Urb.Los Cipreses M-24",
                "ubigeo":{
                    "departamento":"Lima",
                    "provincia":"Huaura",
                    "distrito":"Santa María",
                    "nombre":"Lima\/Huaura\/Santa María"
                }
            }
        }
    ]
}'

--select * from OPENJSON(@myjson)

--select * from OPENJSON(@myjson,'strict $.cursos[1].docente')
select * from OPENJSON(@myjson,'lax $.cursos[1].docente2')