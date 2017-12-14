


---------------------------------------------
-----------------Trigger---------------------
---------------------------------------------
CREATE TRIGGER TraslapeHorario ON horario
AFTER INSERT  
AS  
IF EXISTS (SELECT *  
           FROM horario AS h, inserted
           WHERE inserted.entrada BETWEEN h.entrada and h.salida 
          )  
BEGIN  
RAISERROR ('Aún no se ha terminado el turno anterior', 16, 1);  
ROLLBACK TRANSACTION;  
RETURN   
END;  
GO 




CREATE TRIGGER TraslapeHorario ON horario
FOR INSERT  
AS  
IF EXISTS (SELECT * FROM horario h, inserted WHERE inserted.IdentificacionEmpleado = h.IdentificacionEmpleado AND
			ABS(DATEDIFF(MINUTE,inserted.entrada,h.entrada)) > ABS(DATEDIFF(MINUTE,h.entrada,h.Salida)) AND
			ABS(DATEDIFF(MINUTE,inserted.entrada,h.salida)) > ABS(DATEDIFF(MINUTE,h.entrada,h.Salida)))
RETURN
ELSE
BEGIN  
RAISERROR ('Horario inválido', 16, 1);  
ROLLBACK TRANSACTION;  
RETURN   
END;  
GO 






CREATE TRIGGER TraslapeReserva ON reserva
FOR INSERT  
AS  
IF EXISTS (SELECT * FROM reserva r, inserted WHERE inserted.SalonReserva = r.SalonReserva AND
		    inserted.NumeroMesaReserva = r.NumeroMesaReserva AND 
			ABS(DATEDIFF(MINUTE,inserted.HoraSolicitada,r.HoraSolicitada)) > ABS(DATEDIFF(MINUTE,r.HoraSolicitada,DATEADD(hour,1,r.HoraSolicitada) )) AND
			ABS(DATEDIFF(MINUTE,inserted.HoraSolicitada,DATEADD(hour,1,r.HoraSolicitada))) > ABS(DATEDIFF(MINUTE,r.HoraSolicitada,DATEADD(hour,1,r.HoraSolicitada))))
RETURN
ELSE
BEGIN  
RAISERROR ('Ya hay una reserva en ese horario', 16, 1);  
ROLLBACK TRANSACTION;  
RETURN   
END;  
GO 


---------------------------------------------
--------Procedimiento Almacenado-------------
---------------------------------------------

CREATE PROCEDURE creaMesas
AS
DECLARE @i INT = 1;
DECLARE @j INT = 1;
--variables
BEGIN
	WHILE @i < 3
	BEGIN
		
		WHILE @j < 3
		BEGIN
			INSERT INTO mesa VALUES(@i,@j,6,'Cuenta Abierta');
			SET @j = @j + 1;
		END ;
		
		WHILE @j < 5
		BEGIN
			INSERT INTO mesa VALUES(@i,@j,2,'Cuenta Abierta');
			SET @j = @j + 1;
		END ;
	
	INSERT INTO mesa VALUES(@i,@j,4,'Cuenta Abierta');
	SET @i = @i + 1;
	SET @j = 1;
	END;
END;
