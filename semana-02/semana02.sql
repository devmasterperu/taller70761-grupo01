--Funciones de conversión de tipo

--Cuando es factible convertir
select codigo,cast(codigo as int) as codigo_entero
from produccion.tbUbigeo

--Cuando se aplica sobre un NULL
select cast(NULL as int)

--Cuando no es factible convertir
select try_cast(departamento as int) from produccion.tbUbigeo

--Validación de try_cast
create table produccion.valores_3
(
	valor varchar(1000)
)

insert into produccion.valores_3 values ('1000'),('1001'),('1002'),('_1003')

select cast(valor as int) from produccion.valores_3
select try_cast(valor as int) from produccion.valores_3

--Convert y Try_Convert

select 
convert(varchar(20),getdate(),112) as [YYYYMMDD],
convert(varchar(20),getdate(),111) as [YYYY/MM/DD],
convert(varchar(20),getdate(),102) as [YYYY.MM.DD]

select CONVERT(DATE, '01/02/2019', 101)  as [MM/DD/YYYY]
select TRY_CONVERT(DATE,'29/02/2019', 101)  as [MM/DD/YYYY]

select convert(varchar(20),fecinicio,112) from produccion.tbEmprendimiento

--Uso de Parse y Try_Parse

select PARSE('01/02/2019' AS DATE USING 'en-GB'),--Using OPCIONAL
       PARSE('01/02/2019' AS DATE)--Culura en .NET

select TRY_PARSE('29/02/2019' AS DATE USING 'en-GB') --Culura en .NET

--Funciones de Cadena

--SUBSTRING(expression, start, length)
select ciiu,descripcion, 
SUBSTRING(descripcion,0,20) as [descripcion020],
SUBSTRING(descripcion,10,20) as [descripcion1020]
from produccion.tbActividadEconomica

--LEFT(expression, integer_value)
--NOTA: Considerar tamaño cadena
select ciiu,descripcion, 
SUBSTRING(descripcion,1,20) as [descripcion020],
LEFT(descripcion,20) as [descripcionLEFT]
from produccion.tbActividadEconomica
where SUBSTRING(descripcion,1,20)<>LEFT(descripcion,20)--Validar resultado

--RIGHT(expression, integer_value)
--NOTA: Considerar tamaño cadena
select ciiu,descripcion, 
RIGHT(descripcion,20) as [descripcionRIGHT]
from produccion.tbActividadEconomica

--LEN y DATALENGTH
select 
ciiu, LEN(ciiu) as LENCIIU,
descripcion, LEN(descripcion) as LENDESC,
RIGHT(descripcion,20) as [descripcionRIGHT],
len(RIGHT(descripcion,20)) as [LENdescripcionRIGHT]
from produccion.tbActividadEconomica

--Devolver aquellas actividades económicas que contengan cultivo en su descripción
--y la descripción tenga un tamaño entre 20 y 30

select ciiu, descripcion from produccion.tbActividadEconomica
--where descripcion like '%CULTIVO%' and LEN(descripcion)>=20 and LEN(descripcion)<=30
where descripcion like '%CULTIVO%' and LEN(descripcion) between 20 and 30

select 
LEN(' base_datos') as l1,
DATALENGTH(' base_datos') as dl1,--espacio al inicio
LEN('base datos') as l2,
DATALENGTH('base datos') as dl2,--espacio al medio
LEN('base datos') as l3,
DATALENGTH('base datos   ') as dl3--espacio al final

--CHARINDEX(expressionToFind, expressionToSearch)
select descripcion,CHARINDEX('ULT', descripcion)
from produccion.tbActividadEconomica

--Elaborar un reporte de las actividades cuya descripción 
--su posición 7 sea una 'O' y su tamaño sea menor a 30 o mayor a 15.
--y sus 2 últimos caracteres sea 'OS'

select ciiu,descripcion
from produccion.tbActividadEconomica
where CHARINDEX('O', descripcion)=7 and (len(descripcion)<30 or len(descripcion)>15)
and right(descripcion,2)='OS'

--REPLACE(string_expression, string_pattern, string_replacement)
select 
razonsocial,
REPLACE(razonsocial,'COMERCIAL','EMPRESA') as razonsocialrep,
REPLACE(razonsocial,'SAC','SA') as razonsocialrep2
from produccion.tbEmprendimiento

--Actualizar la razon social 'COMERCIAL' por 'EMPRESA' de aquellas empresas que contengan
--la palabra 'COMERCIAL' en su razon social y finalicen en 'SAC'
--NOTA: excluya aquellas empresas cuya fecha de inicio es desconocida
/*Saber num. resultados
begin tran
 update produccion.tbEmprendimiento set razonsocial=''
rollback
*/
begin tran
update produccion.tbEmprendimiento 
set    razonsocial=REPLACE(razonsocial,'COMERCIAL','EMPRESA') 
where  RIGHT(razonsocial,3)='SAC' and fecinicio is not null
rollback

select  razonsocial from produccion.tbEmprendimiento 

--Uso de UPPER y LOWER
select  LOWER(razonsocial) as LOWER,
        UPPER('dev master') as UPPER 
from    produccion.tbEmprendimiento 


--Uso de funciones de fecha y hora actual
select 
GETDATE() as GETDATE,
GETUTCDATE() as GETUTCDATE,
CURRENT_TIMESTAMP as [CURRENT_TIMESTAMP],
SYSDATETIME() as SYSDATETIME,
SYSUTCDATETIME() as SYSUTCDATETIME,
SYSDATETIMEOFFSET() as SYSDATETIMEOFFSET

--DATENAME( datepart, date)

select datename(yyyy,getdate()),
       datepart(yyyy,getdate()),
	   YEAR(getdate()) as YEAR,
       datename(mm,getdate()) as nombre_mes,
	   datepart(mm,getdate()) as valor_mes,
	   MONTH(getdate()) as MONTH,
       datename(dd,getdate()) as nombre_dia,
	   datepart(dd,getdate()) as valor_dia,
	   DAY(getdate()) as DAY,
	   datename(dw,getdate()+6) as nombre_dia_semana,
	   datepart(dw,getdate()+6) as valor_dia_semana,
	   datepart(hh,getdate()+6) as valor_hora,
	   datepart(mi,getdate()+6) as valor_minuto,
	   datepart(SS,getdate()+6) as valor_segundo
--TZoffset
SELECT DATEPART (tz, SYSDATETIMEOFFSET());--En minutos

--DATEFROMPARTS ( year, month, day )
select 
YEAR(DATEFROMPARTS (datepart(yyyy,getdate()),datepart(MM,getdate()),datepart(dd,getdate()) )),
MONTH(DATEFROMPARTS (datepart(yyyy,getdate()),datepart(MM,getdate()),datepart(dd,getdate()) )),
DAY(DATEFROMPARTS (datepart(yyyy,getdate()),datepart(MM,getdate()),datepart(dd,getdate()) ))

--DATETIME2FROMPARTS ( year, month, day, hour, minute, seconds, fractions, precision ) 
--NOTA: Considerar fraction relacionado a la precision
SELECT DATETIME2FROMPARTS ( 2019, 3, 10, 14, 23, 44, 2, 1 ),--precision al decimo
	   DATETIME2FROMPARTS ( 2019, 3, 10, 14, 23, 44, 50, 2 ), --precision al centesimo
       DATETIME2FROMPARTS ( 2019, 3, 10, 14, 23, 44, 500, 7 )

--DATETIMEFROMPARTS ( year, month, day, hour, minute, seconds, milliseconds )
SELECT DATETIMEFROMPARTS ( 2019, 3, 10, 14, 23, 44,45 )--precision al milesimo

--DATEADD(datepart, interval, date)
select 
DATEADD(dd, 1, getdate()),DATEADD(dd, -1, getdate()),
DATEADD(mm, 1, getdate()),DATEADD(mm, -1, getdate()),
DATEADD(YYYY, 1, getdate()),DATEADD(YYYY, -1, getdate())

--DATEDIFF(datepart,startdate ,enddate )  

SELECT fecinicio,
       DATEDIFF(day,fecinicio,getdate()),
       DATEDIFF(day,getdate(),fecinicio) 
from   produccion.tbEmprendimiento

--EOMONTH(start_date, interval)
select EOMONTH(getdate()),--ultimo día del mes
	   EOMONTH(getdate(),-1),--ultimo día del mes anterior
	   EOMONTH(getdate(),-12),--ultimo día de hace un año
	   EOMONTH(getdate(),1),--ultimo día de hace un año,
	   EOMONTH(getdate(),2)--ultimo día de hace un año

--TODATETIMEOFFSET

CREATE TABLE dbo.fechas   
(  
ColDatetimeoffset datetimeoffset  
);  
GO  

INSERT INTO dbo.fechas   
VALUES ('2019-03-10 7:45:50.71345 -5:00');  
GO  

SELECT SWITCHOFFSET (ColDatetimeoffset, '-08:00')   
FROM dbo.fechas;  
GO  

--TODATETIMEOFFSET

SELECT 
--Obtiene fecha, hora y zona horaria
SYSDATETIMEOFFSET() as SYSDATETIMEOFFSET,
--Reemplaza fecha, hora, minuto y zona horaria
SWITCHOFFSET (SYSDATETIMEOFFSET(), '-07:00') as SWITCHOFFSET,
--Reemplaza zona horaria
TODATETIMEOFFSET (SYSDATETIMEOFFSET(), '-07:00') as TODATETIMEOFFSET;  

--Expresiones CASE 
--Elaborar un reporte de TODOS los emprendimientos que muestre un mensaje:
--Si han transcurrido más de 365 días desde su inicio, mostrar un mensaje 'Empresa tiene más de un año'.
--Si han transcurrido más de 100 y hasta 365 días desde su inicio, mostrar un mensaje '<100-365]'.
--Para los demás casos mostrar 'Otros'.

select razonsocial,fecinicio,
case 
when datediff(dd,fecinicio,getdate())>365 then 'Empresa tiene más de un año'
when datediff(dd,fecinicio,getdate())>100 and datediff(dd,fecinicio,getdate())<=365 then '<100-365]'
else 'Otros'
end as mensaje
from produccion.tbEmprendimiento

--COALESCE
select COALESCE(NULL,NULL,NULL,NULL,'-') as [COALESCE]
select ISNULL(fecinicio,getdate()),COALESCE(fecinicio,getdate()) from produccion.tbEmprendimiento

--Mostrar los ubigeos en base a las sgtes. reglas:
---Si el ubigeo no posee departamento, mostrar la provincia,
---Si el ubigeo no posee departamento ni provincia,mostrar el distrito
---Si el ubigeo no posee departamento, provincia ni distrito mostrar 'sin datos'
update produccion.tbUbigeo
set departamento=null
where departamento='AMAZONAS'

update produccion.tbUbigeo
set provincia=null
where provincia='AZANGARO'

update produccion.tbUbigeo
set distrito=null
where distrito='PURUS'

select COALESCE(departamento,provincia,distrito,'sin datos') from  produccion.tbUbigeo
select ISNULL(ISNULL(departamento,ISNULL(provincia,distrito)),'sin datos') from  produccion.tbUbigeo

--Uso de IIF
select 
fecinicio,
IIF(fecinicio is not null,'Fecha de inicio conocida','-') as mensaje1,
case when fecinicio is not null then 'Fecha de inicio conocida'
else '-' end as mensaje2
from produccion.tbEmprendimiento

--Uso de NULLIF
select NULLIF(fecinicio,getdate()) from produccion.tbEmprendimiento
select NULLIF(fecinicio,fecinicio) from produccion.tbEmprendimiento

--Uso de CHOOSE
select CHOOSE(2,'desarrollo frontend','base de datos','algoritmos','php')

--Uso de @@ROWCOUNT--Devuelve un INT
select CHOOSE(2,'desarrollo frontend','base de datos','algoritmos','php')
select * from produccion.tbActividadEconomica
print 'Número de filas afectadas '+cast(@@ROWCOUNT as varchar)

--ROWCOUNT_BIG()--Devuelve un BIGINT
select * from produccion.tbActividadEconomica
print 'Número de filas afectadas '+cast(ROWCOUNT_BIG() as varchar)

--COMPRESS Y DECOMPRESS
select descripcion,COMPRESS(descripcion) from produccion.tbActividadEconomica

select 
cast(
decompress(0x1F8B08000000000004000DC9410A80300C04C0AFEC51C14FC4BA94406A4AD28AFAFF87E85CA74C1B7A390EA23028C6C4C2BBB00F8744F8BB6E30D6D9F6F8EB41B2A99924DC28554F4FC90FA6AB613145000000)
as varchar(max))

select 
datalength(descripcion) as dl,
datalength(COMPRESS(descripcion)) as dlc
from produccion.tbActividadEconomica
where datalength(descripcion)<datalength(COMPRESS(descripcion))
order by datalength(descripcion)