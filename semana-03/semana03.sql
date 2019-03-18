--17/03/2019

--Uso de OUTPUT+INSERT
INSERT INTO produccion.tbUbigeo(codigo,departamento,provincia,distrito)
OUTPUT
inserted.departamento as nuevo_dpto,
inserted.provincia as nueva_provincia,
inserted.distrito as nuevo_distrito
VALUES('999999','LIMA','HUAURA','SAN JUAN')

INSERT INTO produccion.tbEmprendimiento(ruc,razonsocial)
OUTPUT
inserted.id,--ya tenemos acceso al id autogenerado
inserted.ruc,--los valores enviados
inserted.razonsocial,
inserted.fecinicio
VALUES('66666666667','BODEGA DEL PUEBLO 2')

INSERT INTO produccion.tbEmprendimiento(ruc,razonsocial,fecinicio)
OUTPUT
inserted.id,--ya tenemos acceso al id autogenerado
inserted.ruc,--los valores enviados
inserted.razonsocial,
inserted.fecinicio
VALUES('66666666669','BODEGA DEL PUEBLO 3',getdate())

--Uso de OUTPUT+DELETE
create table produccion.log
(
  idemp int,
  razonsocialemp varchar(500),
  fechora datetime default getdate()
)

DELETE FROM produccion.tbEmprendimiento
OUTPUT
deleted.id,
deleted.razonsocial
INTO produccion.log(idemp,razonsocialemp)
where ruc='66666666667'

--Validando
select * from produccion.log

--Uso de OUTPUT+UPDATE
UPDATE produccion.tbUbigeo
SET    poblacion=3000,
       areakm2=700,
	   estado=0
OUTPUT 
inserted.id as n_id,
deleted.id as a_id,
inserted.poblacion as n_poblacion,
deleted.poblacion as a_poblacion,
inserted.areakm2 as n_areakm2,
deleted.areakm2 as a_areakm2,
inserted.estado as n_estado,
deleted.estado as a_estado
WHERE codigo='110303'

--SUBCONSULTA EN SELECT
--Mostrar la cantidad de emprendimientos y la cantidad de actividades económicas
--utilizando una sola ejecución.

SELECT 
(select count(distinct id) from produccion.tbEmprendimiento),
(select count(distinct ciiu) from produccion.tbActividadEconomica)

--SUBCONSULTA FROM
--Mostrar por emprendimiento el ruc,la razón social y el total de actividades por emprendimiento.
--RUC             RAZON        TOTAL
--11111111111111  DEV MASTER    4
--11111111111112  DEV CODE      5

--CI: el total de actividades por emprendimiento

 select idemprendimiento,count(ciiu) as totalact from produccion.tbEmprendimientoActividad
 group by idemprendimiento
--CE: Mostrar por emprendimiento el ruc,la razón social y el total de actividades por emprendimiento.

select e.id,e.ruc,e.razonsocial,
isnull(et.totalact,0) as total
from produccion.tbEmprendimiento e
left join
(
 select idemprendimiento as id,count(ciiu) as totalact from produccion.tbEmprendimientoActividad
 group by idemprendimiento
) et on e.id=et.id

--select count(1) from produccion.tbEmprendimientoActividad
--where idemprendimiento=18

--Mostrar por emprendimiento el ruc,la razón social y el areakm2 por departamento del ubigeo asociado.
--RUC             RAZON        AREAKM2
--11111111111111  DEV MASTER    400
--11111111111112  DEV CODE      500

--CI:areakm2 por departamento 

 select departamento, sum(areakm2) as totdpto from produccion.tbUbigeo
 where areakm2 is not null and departamento is not null
 group by departamento
 order by departamento

 --CE

select e.id,e.ruc,e.razonsocial, u.departamento,
ut.totdpto
from produccion.tbEmprendimiento e
left join produccion.tbUbigeo u on e.idubigeo=u.id
left join 
(
 select departamento, sum(areakm2) as totdpto from produccion.tbUbigeo
 where areakm2 is not null and departamento is not null
 group by departamento
) ut on ut.departamento=u.departamento

select e.*,u.* from produccion.tbEmprendimiento e
left join produccion.tbUbigeo u on e.idubigeo=u.id

update produccion.tbUbigeo
set departamento='AMAZONAS'
where departamento is null

update produccion.tbEmprendimiento
set idubigeo=1663
where idubigeo is null

--SUBCONSULTA WHERE|HAVING
--Obtener los emprendimientos que tienen actividades económicas en número mayor al promedio de todos los
--emprendimientos.

--CI
select AVG(tae)
from
(
select idemprendimiento,COUNT(ciiu) as tae from produccion.tbEmprendimientoActividad
group by idemprendimiento
) eat

--CE

select idemprendimiento,COUNT(ciiu) as te from produccion.tbEmprendimientoActividad
group by idemprendimiento
--Mostrar totales>promedio de Total actividades por emprendimiento
having COUNT(ciiu) >
(
    --Obtener promedio de Total actividades por emprendimiento
	select AVG(tae) from
	(   --Total actividades por emprendimiento
		select idemprendimiento,COUNT(ciiu) as tae 
		from produccion.tbEmprendimientoActividad
		group by idemprendimiento
	) eat
)

--Uso de ANY|ALL|SOME
--create schema desarrollo [Esquema]

--select * into desarrollo.tbActividadEconomica [Tabla replica]
---from produccion.tbActividadEconomica
--ciiu,descripcion,estado

/*
select * into desarrollo.tbUbigeo --[Tabla replica]
from produccion.tbUbigeo

SELECT * from desarrollo.tbUbigeo

update desarrollo.tbUbigeo
set areakm2=areakm2*15
where departamento='ANCASH'

delete desarrollo.tbUbigeo
where id=2002

*/

INSERT INTO produccion.tbUbigeo(codigo,departamento,provincia,distrito)
VALUES('999999','LIMA','HUAURA','SAN JUAN')

SELECT *
FROM  desarrollo.tbUbigeo
WHERE areakm2> ALL
(SELECT isnull(areakm2,0) from produccion.tbUbigeo);--34972

--delete from produccion.tbUbigeo
--where areakm2 is null

SELECT *
FROM  desarrollo.tbUbigeo
WHERE areakm2< ALL
(SELECT isnull(areakm2,0) from produccion.tbUbigeo);--34972

SELECT *
FROM  desarrollo.tbUbigeo
WHERE areakm2> ANY
(SELECT isnull(areakm2,0) from produccion.tbUbigeo);--34972

--Uso de CROSS APPLY

--TABLA IZQ
select * from produccion.tbActividadEconomica ae 
--0111
--TABLA DER (LOGICA)

select 
top(3) *
from produccion.tbEmprendimiento e
inner join produccion.tbEmprendimientoActividad ea on e.id=ea.idemprendimiento
where ea.ciiu='6201'
order by razonsocial asc

--JUNTAMOS RESULTADOS 
select ae.ciiu,ae.descripcion,rankemp.razonsocial from 
produccion.tbActividadEconomica ae --TI
CROSS APPLY
(
select 
top(3) *
from produccion.tbEmprendimiento e
inner join produccion.tbEmprendimientoActividad ea on e.id=ea.idemprendimiento
where ea.ciiu=ae.ciiu
order by razonsocial asc
) rankemp --TD
order by ciiu

--Uso de OUTER APPLY

select ae.ciiu,ae.descripcion,rankemp.razonsocial from 
produccion.tbActividadEconomica ae --TI
OUTER APPLY
(
select 
top(3) *
from produccion.tbEmprendimiento e
inner join produccion.tbEmprendimientoActividad ea on e.id=ea.idemprendimiento
where ea.ciiu=ae.ciiu
order by razonsocial asc
) rankemp --TD
order by ciiu

--Funcion de Tabla
CREATE FUNCTION produccion.fnTop3Emprendimientos(@ciiu varchar(4))
returns table
as
return
(
select 
top(3) *
from produccion.tbEmprendimiento e
inner join produccion.tbEmprendimientoActividad ea on e.id=ea.idemprendimiento
where ea.ciiu=@ciiu
order by razonsocial asc
)

--select * from produccion.fnTop3Emprendimientos('6202')

select ae.ciiu,ae.descripcion,rankemp.razonsocial from 
produccion.tbActividadEconomica ae --TI
OUTER APPLY produccion.fnTop3Emprendimientos(ae.ciiu) rankemp
order by ciiu