--1 Uso de PIVOT

--1.1 Cuantas veces un colaborador N contactó a un cliente M.
select * from tb_ContactoCliente

select idColaborador,idCliente,count(1) as total
from tb_ContactoCliente
group by idColaborador,idCliente

select idCliente,[6] as col6,[7] as col7,[8] as col8,[9] as col9--Presentar resultados
from
(
select idColaborador,idCliente,idContactabilidad
from tb_ContactoCliente --Fuente de Datos
) p
PIVOT
(
	COUNT(idContactabilidad)--Función agrupadora
	FOR idColaborador in ([6],[7],[8],[9],[10])--Campos cabecera
) as pv

--1.2 Columna no PIVOT será idColaborador y presentar 4 clientes.

--select idColaborador,[1] as cli1,[4] as cli4,[5] as cliente5,[6] as cliente6,[7] as cliente7--Presentar resultados
select idColaborador,[1],[4],[5],[6],[7]
--into ##resumen
--into tb_reporte
into tb_reporte_2
from
(
select idColaborador,idCliente,idContactabilidad
from tb_ContactoCliente --Fuente de Datos
) p
PIVOT
(
	COUNT(idContactabilidad)--Función agrupadora
	FOR idCliente in ([1],[4],[5],[6],[7])--Campos cabecera
) as pv



--2 Uso de UNPIVOT

select * from tb_reporte

--2.1 UNPIVOT de 1.2
select idColaborador,Cliente,total
FROM
(
--SELECT idColaborador,cli1,cli4,cliente5,cliente6,cliente7 FROM tb_reporte
SELECT idColaborador,[1],[4],[5],[6],[7] FROM tb_reporte_2
) p
UNPIVOT
(total FOR Cliente IN ([1],[4],[5],[6],[7])
) as up

--2.2 UNPIVOT DE 1.1

select idCliente,[6],[7],[8],[9]--Presentar resultados
into resumen_cli_col_2
from
(
select idColaborador,idCliente,idContactabilidad
from tb_ContactoCliente --Fuente de Datos
) p
PIVOT
(
	COUNT(idContactabilidad)--Función agrupadora
	FOR idColaborador in ([6],[7],[8],[9],[10])--Campos cabecera
) as pv

select * from resumen_cli_col_2
--UNPIVOT
select idCliente,colaborador,tot
FROM
(
--SELECT idColaborador,cli1,cli4,cliente5,cliente6,cliente7 FROM tb_reporte
SELECT idCliente,[6],[7],[8],[9] FROM resumen_cli_col_2
) p
UNPIVOT
(tot FOR colaborador IN ([6],[7],[8],[9])
) as up

--3 Uso de JSON PATH

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
--select * from OPENJSON(@myjson,'lax $.cursos[1].docente2')
select * from OPENJSON(@myjson,'strict $.cursos[1].docente')

--4 Uso de JSON VALUE

DECLARE @jsonInfo NVARCHAR(MAX)

SET @jsonInfo=N'{  
     "informacion":{    
		 "nombres":"Gianfranco",
		 "apellidos":"Manrique Valentín",
		 "direccion":"Urb. Los Cipreses M-24",
		   "ubigeo":{    
			 "departamento":"Lima",  
			 "provincia":"Huaura",  
			 "distrito":"Huacho"  
		   },  
		 "cursos":["Base de Datos", "Modelamiento de Datos"]  
    }
 }'

 SELECT 
 JSON_VALUE(@jsonInfo,'$.informacion.nombres') as nombres,
 JSON_VALUE(@jsonInfo,'$.informacion.apellidos') as apellidos,
 JSON_VALUE(@jsonInfo,'$.informacion.direccion') as direccion,
 JSON_QUERY(@jsonInfo,' $.informacion.ubigeo2') as ubigeo,
 ISJSON(@jsonInfo) as flag_JSON

DECLARE @jsonInfo2 VARCHAR(MAX)
SET @jsonInfo2=N'{
	"info":{
		"type":1,
		"address":{
			"town":"Bristol",
  			"county":"Avon",
			"country":"England"
		},
		"tags":["Sport","Water Polo"]
	},
	"type":"Basic"
}'

select JSON_QUERY(@jsonInfo2,'strict $.info.address'),
 JSON_QUERY(@jsonInfo2,'$.info.address.town'),
 JSON_QUERY(@jsonInfo2,'strict $'),
 JSON_QUERY(@jsonInfo2,'strict  $.info.type[0]')

 --5 Uso de XML
 --5.1 XML RAW
 select * from tb_Categoria
 FOR XML RAW,elements,ROOT('Categorias')

  select * from tb_Categoria
 FOR XML RAW,ROOT('Categorias')
 --5.2 XML AUTO
 select apellidosCliente,nombreTipoDocumento,nombreCliente,emailCliente from tb_Cliente 
 inner join tb_TipoDocumento on tb_Cliente.idTipoDocumento=tb_TipoDocumento.idTipoDocumento
 where emailCliente is not null
 FOR XML AUTO,ROOT('Clientes'),ELEMENTS

 --5.3 XML PATH
 select 
 apellidosCliente as '@apellidos',
 nombreCliente as 'nombres',
 emailCliente as 'email',
 tb_TipoDocumento.idTipoDocumento as'tipo/@id',
 nombreTipoDocumento as 'tipo/@nombre',
 tb_TipoDocumento.idTipoDocumento as'tipo/id',
 nombreTipoDocumento as 'tipo/nombre'
 from tb_Cliente 
 inner join tb_TipoDocumento on tb_Cliente.idTipoDocumento=tb_TipoDocumento.idTipoDocumento
 where emailCliente is not null
 FOR XML PATH('cliente'),--cada resultado llamarse cliente
 ROOT('Clientes')--elemento raiz

 --6. Uso de Vistas

 --6.1 Vista sin protección de columna
 create view dbo.vClienteDocumento
 as
 select apellidosCliente,nombreTipoDocumento,nombreCliente,emailCliente from tb_Cliente 
 inner join tb_TipoDocumento on tb_Cliente.idTipoDocumento=tb_TipoDocumento.idTipoDocumento
 where emailCliente is not null

 alter table tb_TipoDocumento add estado bit

  --6.2 Vista con protección de columnas
 create view dbo.vClienteDocumento2
 WITH SCHEMABINDING --Proteger los campos que estoy utilizando.
 as
 select apellidosCliente,nombreTipoDocumento,nombreCliente,emailCliente from dbo.tb_Cliente 
 inner join dbo.tb_TipoDocumento on tb_Cliente.idTipoDocumento=tb_TipoDocumento.idTipoDocumento
 where emailCliente is not null

 alter table dbo.tb_TipoDocumento add feccreacion datetime default getdate()

  --6.3 Modificar vista retirando SCHEMABINDING o retirando campos dependientes
  --para modificar tabla

 drop view dbo.vClienteDocumento2
 alter view dbo.vClienteDocumento2
 --WITH SCHEMABINDING --Proteger los campos que estoy utilizando.
 as
 select apellidosCliente,nombreTipoDocumento,nombreCliente,emailCliente from dbo.tb_Cliente 
 inner join dbo.tb_TipoDocumento on tb_Cliente.idTipoDocumento=tb_TipoDocumento.idTipoDocumento
 where emailCliente is not null

 alter table dbo.tb_TipoDocumento alter column nombreTipoDocumento varchar(300)

 --7 Vistas Indexadas
 create view dbo.vContacto
 with schemabinding
 as
 select 
 cc.idColaborador,
 concat(c.nombreColaborador,' ',c.apellidoColaborador) as nomcolaborador,
 cc.idCliente,
 concat(cl.nombreCliente,' ',cl.apellidosCliente) as nomcliente,
 cc.idProducto,
 p.nombreProducto
 from dbo.tb_ContactoCliente cc
 join dbo.tb_Colaborador c on cc.idColaborador=c.idColaborador
 join dbo.tb_Cliente cl on cc.idCliente=cl.idCliente
 join dbo.tb_Producto p on cc.idProducto=p.idProducto

 select * from dbo.vContacto

 CREATE UNIQUE CLUSTERED INDEX CIX_vContacto
	ON dbo.vContacto(idColaborador, idCliente,idProducto);

--8 Procedimientos almacenados
--8.1 Retornar la contactabilidad en base a código de cliente
 alter procedure dbo.usp_listarContactos
 (
 @idCliente int,
 @total int output
 )
 as
 begin
 select 
 cc.idColaborador,
 concat(c.nombreColaborador,' ',c.apellidoColaborador) as nomcolaborador,
 cc.idCliente,
 concat(cl.nombreCliente,' ',cl.apellidosCliente) as nomcliente,
 cc.idProducto,
 p.nombreProducto
 from dbo.tb_ContactoCliente cc
 join dbo.tb_Colaborador c on cc.idColaborador=c.idColaborador
 join dbo.tb_Cliente cl on cc.idCliente=cl.idCliente
 join dbo.tb_Producto p on cc.idProducto=p.idProducto
 where cl.idCliente=@idCliente;

 set @total=@@rowcount;

 end

 DECLARE @total2 INT;
 --execute dbo.usp_listarContactos 2,@total2 output
 execute dbo.usp_listarContactos @idCliente=2,@total=@total2 output
 --Aplicar una lógica con la salida OUTPUT
 select @total2 as total

 sp_helptext 'dbo.usp_listarContactos'

 --8.2 Procedure rutina

  create procedure dbo.usp_listarContactos_3
 as
 begin
 select 
 cc.idColaborador,
 concat(c.nombreColaborador,' ',c.apellidoColaborador) as nomcolaborador,
 cc.idCliente,
 concat(cl.nombreCliente,' ',cl.apellidosCliente) as nomcliente,
 cc.idProducto,
 p.nombreProducto
 from dbo.tb_ContactoCliente cc
 join dbo.tb_Colaborador c on cc.idColaborador=c.idColaborador
 join dbo.tb_Cliente cl on cc.idCliente=cl.idCliente
 join dbo.tb_Producto p on cc.idProducto=p.idProducto

 end

 create procedure dbo.usp_rutinaContactabilidad
 as
 begin
	execute dbo.usp_listarContactos_2
	execute dbo.usp_listarContactos_3
 end

 execute dbo.usp_rutinaContactabilidad