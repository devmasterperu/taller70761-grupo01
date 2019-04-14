--1 Uso de BEGIN TRAN|COMMIT TRAN|ROLLBACK
--begin tran
update tb_Colaborador
set idUbigeo='140116'
where numeroDocumentoColaborador='-'
--rollback
--commit
rollback
select distinct idUbigeo from tb_Colaborador
where numeroDocumentoColaborador='-'

--2 Uso de XACT_ABORT

--2.1 Reversión automática de Transacción (Desactivada)

SET XACT_ABORT OFF;--Modo por defecto
GO  

IF OBJECT_ID(N't2', N'U') IS NOT NULL  
    DROP TABLE t2;  
GO  
IF OBJECT_ID(N't1', N'U') IS NOT NULL  
    DROP TABLE t1;  
GO  
CREATE TABLE t1  
    (a INT NOT NULL PRIMARY KEY);  
CREATE TABLE t2  
    (a INT NOT NULL REFERENCES t1(a));  
GO  
INSERT INTO t1 VALUES (1);  
INSERT INTO t1 VALUES (3);  
INSERT INTO t1 VALUES (4);  
INSERT INTO t1 VALUES (6);  
GO 
select * from t1
BEGIN TRANSACTION;  
INSERT INTO t2 VALUES (1);  
INSERT INTO t2 VALUES (2);--Error de FK
INSERT INTO t2 VALUES (3);  
COMMIT TRANSACTION;

select * from t2 
GO  

--2.2 Reversión automática de Transacción activada 

SET XACT_ABORT ON; --Manualmente se activa
GO  

IF OBJECT_ID(N't2', N'U') IS NOT NULL  
    DROP TABLE t2;  
GO  
IF OBJECT_ID(N't1', N'U') IS NOT NULL  
    DROP TABLE t1;  
GO  
CREATE TABLE t1  
    (a INT NOT NULL PRIMARY KEY);  
CREATE TABLE t2  
    (a INT NOT NULL REFERENCES t1(a));  
GO  

BEGIN TRANSACTION;  
INSERT INTO t2 VALUES (4);  
INSERT INTO t2 VALUES (5);  
INSERT INTO t2 VALUES (6);  
COMMIT TRANSACTION;  
GO 

select * from t2
--3 Uso de XACT_STATE
SET XACT_ABORT OFF; 

BEGIN TRY--Bloque de operación
	BEGIN TRAN
	    insert into tb_Rol values ('PRACTICANTE_2')--No presenta error
		print 'registro de PRACTICANTE'
		--delete from tb_Producto where idProducto=1
		--delete from tb_Producto where idProducto=15
		select 1/0--Error
		print 'Transacción exitosa:'+cast(XACT_STATE() as varchar)
	COMMIT TRAN
END TRY
BEGIN CATCH--Bloque de Error
	IF XACT_STATE() = -1
	BEGIN
		print 'Toda la transacción debe ser revertida: '+cast(XACT_STATE() as varchar)
		ROLLBACK TRANSACTION;  
	END;

	IF XACT_STATE() = 1
	BEGIN
		print 'Existen errores pero aún puede guardarse cambios: '+cast(XACT_STATE() as varchar)
		COMMIT TRANSACTION;  
	END;
END CATCH

PRINT XACT_STATE()
--delete from tb_Rol where nombreRol='PRACTICANTE'
--select * from tb_Rol where nombreRol='PRACTICANTE_2'

--4 Uso de @@TRANCOUNT 

SET XACT_ABORT ON; 

print '@@TRANCOUNT 1:'+cast(@@TRANCOUNT as varchar)

BEGIN TRY
	BEGIN TRAN
	print '@@TRANCOUNT 2:'+cast(@@TRANCOUNT as varchar)--Aumenta en 1 luego de un BEGIN TRAN
		insert into tb_Rol values ('ASISTENTE') 
		--delete from tb_Producto where idProducto=1
		--delete from tb_Producto where idProducto=15
		select 1/0
	BEGIN TRAN
	print '@@TRANCOUNT 3:'+cast(@@TRANCOUNT as varchar)
	COMMIT TRAN --Reduce en 1 luego de un COMMIT TRANSACTION
	print '@@TRANCOUNT 4:'+cast(@@TRANCOUNT as varchar)
END TRY
BEGIN CATCH
	IF XACT_STATE() = -1
	BEGIN
		print '@@XACT_STATE:'++cast(XACT_STATE() as varchar)
		ROLLBACK TRANSACTION;  --Asigna a 0 el @@TRANCOUNT 
		print '@@TRANCOUNT 5:'+cast(@@TRANCOUNT as varchar)
	END;

	IF XACT_STATE() = 1
	BEGIN
		print '@@XACT_STATE:'++cast(XACT_STATE() as varchar)
		COMMIT TRANSACTION;  --Reduce en 1 luego de un COMMIT TRANSACTION
		print '@@TRANCOUNT 6:'+cast(@@TRANCOUNT as varchar)
	END;
END CATCH

--5 Uso de @@ERROR

	delete from tb_Producto where idProducto=1 
	go
	print  'Codigo de Error '+cast(@@ERROR as varchar)--547 Código asociado a llave foránea.

	select 1/0 
	go
	print  @@ERROR--8134 Código asociado a división entre 0

	declare @total tinyint--0 a 255
	set @total=240

	select @total=@total+20
	go
	print  @@ERROR--220 Código asociado a valor no soportado a tipo de dato

--6 Uso de THROW

THROW 51001, 'El registro no existe.', 1; --Código de error, Mensaje de error, Estado

BEGIN TRY
	delete from tb_Producto where idProducto=1
	--delete from tb_Producto where idProducto=15
	--select 1/0
END TRY
BEGIN CATCH
	--THROW
	/*
	THROW 2147483647, --Entre 50000 y 2147483647 
		  'El registro no existe.', --nvarchar(2048)
		  1;  --Entre 0 y 255
	*/
	--throw 50002,'Divisón entre CERO no factible!',1
	--throw 50003,'Error de Clave Foránea!',100
	/*
	RAISERROR ('Error raised in TRY block.', -- Message text.  
               16, -- Severity.  
               1 -- State.  
               );  
	*/
	 DECLARE @ErrorNumber INT = ERROR_NUMBER();
     RAISERROR(@ErrorNumber, 16, 1) 
END CATCH

--7 Uso de RAISERROR
--1033 lenguaje inglés
select max(message_id) from sys.messages 
where message_id>13000

--Invocar error usando message_id
RAISERROR (13024, -- message_id.  
              16, -- Severity.  
               1  -- State.  
               );  

--Invocar error usando message_str
RAISERROR ('Mensaje de prueba', -- message_str.  
              16, -- Severity.  
               1  -- State.  
               );  

--Registrar código y mensaje en SQL SERVER
EXEC sp_addmessage @msgnum = 50001, @severity = 16,   
   @msgtext = N'Mensaje de prueba sesión 06.',   
   @lang = 'us_english';  

--Utilizar código registrado en SQL SERVER
 RAISERROR (50001, -- message_str.  
              16, -- Severity.  
              1  -- State.  
            );  
--RAISERROR (15600,-1,-1, 'mysp_CreateCustomer');  

--8 Uso de Funciones Manejo de Error
alter procedure dbo.usp_EliminarProducto
as
begin
BEGIN TRY
	--delete from tb_Producto where idProducto=1
	--delete from tb_Producto where idProducto=15
	select 1/0
END TRY
BEGIN CATCH
	select 
	ERROR_NUMBER() AS ERRNUM,
	ERROR_MESSAGE() AS ERRMSG,
	ERROR_SEVERITY() AS ERRSEV,
	ERROR_PROCEDURE() AS ERRPROC,
	ERROR_LINE() AS ERRLINE;
END CATCH
end

execute dbo.usp_EliminarProducto