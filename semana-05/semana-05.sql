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

--2.2 UNPIVOT DE 1.1 (CLIENTE
