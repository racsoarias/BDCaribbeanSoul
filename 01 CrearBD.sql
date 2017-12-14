/*
CREATE DATABASE CaribbeanSoul;
*/

CREATE TABLE provincia ( 
	NumeroProvincia TINYINT Not Null, 
	Nombre VARCHAR(30) Not Null, 
	constraint PKProvincia PRIMARY KEY (numeroProvincia)); 

CREATE TABLE canton ( 
	NumeroCanton TINYINT Not Null, 
	NumeroProvincia TINYINT Not Null, 
	Nombre VARCHAR(30) Not Null, 
	constraint PKCanton PRIMARY KEY (numeroProvincia ,numeroCanton), 
	constraint FKCanton FOREIGN KEY (numeroProvincia ) 
		REFERENCES Provincia(numeroProvincia ) ON DELETE CASCADE
); 

CREATE TABLE distrito ( 
	NumeroDistrito TINYINT Not Null, 
	NumeroCanton TINYINT Not Null, 
	NumeroProvincia TINYINT Not Null, 
	Nombre VARCHAR(30) Not Null, 
	constraint PKDistrito PRIMARY KEY (numeroDistrito,numeroCanton,numeroProvincia), 
	constraint FKDistrito FOREIGN KEY (numeroProvincia,numeroCanton) 
		REFERENCES Canton(numeroProvincia,numeroCanton) ON DELETE CASCADE
); 



CREATE TABLE persona (
	Identificacion INT NOT NULL, 
	NombrePersona VARCHAR(56),
	Apellido1 VARCHAR(56),
	Apellido2 VARCHAR(56),
	FechaNacimiento DATE,
	DireccionExacta VARCHAR(255),
	Email VARCHAR(255),
	CodDistrito TINYINT, 
	CodCanton TINYINT, 
	CodProvincia TINYINT, 
	Observaciones VARCHAR(255) DEFAULT 'Sin Observaciones',
	FechaCreacion DATE,
	
	PRIMARY KEY (identificacion),
	FOREIGN KEY (codDistrito, codCanton,codProvincia ) 
		REFERENCES distrito (numeroDistrito, numeroCanton, numeroProvincia)
);


CREATE TABLE telefonoPersona(
	IdentificacionPersona INT NOT NULL,
	Telefono INT NOT NULL,
	
	PRIMARY KEY(identificacionPersona, telefono),
	FOREIGN KEY(identificacionPersona) 
		REFERENCES persona(identificacion) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE cliente (
	Identificacion INT NOT NULL, 
	Puntos INT,
	PorcentajeDescuento DECIMAL,
	MontoCredito INT,
	
	PRIMARY KEY (identificacion),
	FOREIGN KEY (identificacion) 
		REFERENCES persona (identificacion) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE empleado (
	Identificacion INT NOT NULL, 
	NombreUsuario CHAR(15),
	PinAcceso SMALLINT,
	SalarioBase INT,
	HuellaDigital VARBINARY(MAX),
	Horario VARCHAR(255),
	SupIdentificacion INT,
	TipoEmpleado VARCHAR(60),
	CONSTRAINT chk_tipoEmpleado CHECK 
		(UPPER(tipoEmpleado) IN ('MESERO', 'ADMINISTRADOR', 'COCINERO', 
								'ASISTENTE COCINA', 'CAJERO')),
	
	PRIMARY KEY (identificacion),
	FOREIGN KEY (supIdentificacion) 
		REFERENCES persona(identificacion) ON DELETE NO ACTION,
	FOREIGN KEY (identificacion) 
		REFERENCES persona (identificacion) ON UPDATE CASCADE ON DELETE CASCADE,
);
	
CREATE TABLE contactoEmergencia(
	IdentificacionPersona INT NOT NULL,
	Nombre VARCHAR(56),
	Telefonos INT NOT NULL,
	
	PRIMARY KEY(identificacionPersona, Telefonos),
	FOREIGN KEY (identificacionPersona) 
		REFERENCES empleado(identificacion) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE horario (
	IdentificacionEmpleado INT NOT NULL,
	Entrada  DATETIME,
	Salida SMALLDATETIME,
	
	PRIMARY KEY (identificacionEmpleado, entrada),
	FOREIGN KEY (identificacionEmpleado) 
		REFERENCES empleado(identificacion) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE mesa (
	Salon TINYINT NOT NULL,
	NumeroMesa  TINYINT NOT NULL,
	Capacidad TINYINT,
	Estado VARCHAR(25),
		CONSTRAINT chk_estadoReserva CHECK 
		(UPPER(estado) IN ('RESERVADO', 'FACTURA IMPRESA', 
							'CUENTA ABIERTA', 'CUENTA RESERVADA')),
	
	PRIMARY KEY (salon, numeroMesa)
);


CREATE TABLE reserva (
	SalonReserva TINYINT,
	NumeroMesaReserva TINYINT,
	HoraSolicitada DATETIME, 
	NombreReserva VARCHAR (50),
	Observaciones VARCHAR (255),

	PRIMARY KEY (salonReserva, numeroMesaReserva, horaSolicitada),
	FOREIGN KEY	(salonReserva, numeroMesaReserva) 
		REFERENCES mesa(salon, numeroMesa) ON DELETE CASCADE
);

CREATE TABLE orden (
	HoraCreacion DATETIME NOT NULL, 
	NumeroOrden INT,
	IdentificacionEmpleado INT,
	Salon TINYINT,
	NumeroMesa TINYINT,

	PRIMARY KEY (horaCreacion, identificacionEmpleado, salon, numeroMesa),
	FOREIGN KEY	(identificacionEmpleado) 
		REFERENCES empleado(identificacion),
	FOREIGN KEY	(salon, numeroMesa) 
		REFERENCES mesa(salon, numeroMesa)
);

CREATE TABLE platillo (
	CodigoPlatillo SMALLINT, 
	NombrePlatillo VARCHAR (128),
	Receta VARCHAR(8000),
	Descripcion VARCHAR (128),
	PrecioVenta MONEY,
	PrecioCosto MONEY,
	TipoPlatillo VARCHAR (56), 
		CONSTRAINT chk_tipoPlatillo CHECK 
		(UPPER(tipoPlatillo) IN ('BEBIDA', 'ENTRADA', 'POSTRE',
								'PLATO FUERTE', 'ADICIONALES')),

	PRIMARY KEY (codigoPlatillo),
);

CREATE TABLE ordenContienePlatillo (
	HoraCreacion DATETIME NOT NULL, 
	IdentificacionEmpleado INT,
	Salon TINYINT,
	NumeroMesa TINYINT,
	CodigoPlatillo SMALLINT,
	Cantidad TINYINT DEFAULT 1, 
	Facturado BIT DEFAULT 0, 

	PRIMARY KEY (horaCreacion, identificacionEmpleado, salon, numeroMesa, codigoPlatillo),
	FOREIGN KEY	(horaCreacion, identificacionEmpleado, salon, numeroMesa) 
		REFERENCES orden(horaCreacion, identificacionEmpleado, salon, numeroMesa)
			ON DELETE NO ACTION,
	FOREIGN KEY	(codigoPlatillo) 
		REFERENCES platillo(codigoPlatillo) ON DELETE NO ACTION
);

CREATE TABLE facturaVenta (
	NumeroFactura INT,
	DatosEmpresa VARCHAR(5000) 
		DEFAULT 'RESTAURANTE CARIBBEAN SOUL 2222-4241 CED 3-101-34341-1',
	Impuesto DECIMAL,
	PropinaFija REAL,
	PropinaAdicional REAL,
	HoraCreacion DATETIME NOT NULL, 
	IdentificacionEmpleado INT,
	Salon TINYINT,
	NumeroMesa TINYINT,
	IdentificacionCliente INT,
	Estado VARCHAR (56), 
		CONSTRAINT chk_estadoFacVenta CHECK 
		(UPPER(estado) IN ('CANCELADA', 'PENDIENTE', 'ABIERTA')),
	FormaPago VARCHAR (56), 
		CONSTRAINT chk_formaPago CHECK 
		(UPPER(estado) IN ('EFECTIVO', 'TARJETA', 'CHEQUE', 'PUNTOS', 'CUPON')),

	PRIMARY KEY (numeroFactura, horaCreacion, identificacionEmpleado, 
				salon, numeroMesa, identificacionCliente),
	FOREIGN KEY	(horaCreacion, identificacionEmpleado, salon, numeroMesa) 
		REFERENCES orden(horaCreacion, identificacionEmpleado, salon, numeroMesa),
	FOREIGN KEY	(identificacionCliente) 
		REFERENCES cliente(identificacion)
);

CREATE TABLE abono (
	Fecha SMALLDATETIME NOT NULL,
	NumeroFactura INT,
	HoraCreacion DATETIME,
	IdentificacionEmpleado INT,
	Salon TINYINT,
	NumeroMesa TINYINT,
	IdentificacionCliente INT,
	MontoAbonado REAL NOT NULL,
	
	PRIMARY KEY (fecha, numeroFactura, horaCreacion, identificacionEmpleado,
				salon, numeroMesa, identificacionCliente),
	FOREIGN KEY (numeroFactura, horaCreacion, identificacionEmpleado, 
				salon, numeroMesa, identificacionCliente) 
		REFERENCES facturaVenta(numeroFactura, horaCreacion, identificacionEmpleado, 
								salon, numeroMesa, identificacionCliente),
);

CREATE TABLE facturaContienePlatillo (
	NumeroFactura INT,
	HoraCreacion DATETIME,
	IdentificacionEmpleado INT,
	Salon TINYINT,
	NumeroMesa TINYINT,
	IdentificacionCliente INT,
	CodPlatillo SMALLINT,
	Precio MONEY,
	
	PRIMARY KEY(numeroFactura, horaCreacion, identificacionEmpleado,
				salon, numeroMesa, identificacionCliente, codPlatillo),

	FOREIGN KEY(numeroFactura, horaCreacion, identificacionEmpleado,
				salon, numeroMesa, identificacionCliente) 
		REFERENCES facturaVenta(numeroFactura, horaCreacion, identificacionEmpleado,
				salon, numeroMesa, identificacionCliente) ON DELETE NO ACTION,
	FOREIGN KEY(codPlatillo) 
		REFERENCES platillo(CodigoPlatillo) ON DELETE NO ACTION
);

CREATE TABLE indicaciones(
	CodigoPlatillo SMALLINT NOT NULL,
	Indicaciones VARCHAR(128) NOT NULL,
	
	PRIMARY KEY(codigoPlatillo, indicaciones),
	FOREIGN KEY(codigoPlatillo)
		REFERENCES platillo(codigoPlatillo)
);



/*
DROP TABLE telefonoPersona, contactoEmergencia, indicaciones;
DROP TABLE facturaContienePlatillo;
DROP TABLE abono;
DROP TABLE facturaVenta;
DROP TABLE ordenContienePlatillo;
DROP TABLE platillo;
DROP TABLE orden;
DROP TABLE reserva;
DROP TABLE horario, mesa;
DROP TABLE empleado, cliente;
DROP TABLE persona;
DROP TABLE distrito;
DROP TABLE canton;
DROP TABLE provincia;

*/


