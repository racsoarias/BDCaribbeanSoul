USE CaribbeanSoul;

--10
SELECT	p1.nombrePersona Nombre, p1.Apellido1 Apellido, 
		FORMAT(e.SalarioBase, 'c', 'es-cr') Salario, p2.nombrePersona Nombre_Jefe
FROM	persona p1, empleado e, persona p2
WHERE	p1.Identificacion = e.Identificacion AND
		e.SupIdentificacion = p2.Identificacion;

--11
SELECT	o.NumeroOrden, p.nombrePersona, 
		CAST(o.HoraCreacion AS DATETIME) as 'Hora Creacion', 
		CONCAT(o.Salon,'-',o.NumeroMesa) as 'Salon-Mesa'
FROM	persona p, empleado e, orden o, mesa m
WHERE	o.IdentificacionEmpleado = e.Identificacion AND
		e.Identificacion = p.Identificacion AND
		o.Salon = m.Salon AND
		o.NumeroMesa = m.NumeroMesa
ORDER BY p.nombrePersona;

--12
SELECT * FROM orden
WHERE NumeroMesa = 1;

--13
SELECT	o.HoraCreacion Hora_Pedido, per.NombrePersona Mesero, p.NombrePlatillo, p.PrecioVenta
FROM	orden o, ordenContienePlatillo ocp, platillo p, persona per
WHERE	o.HoraCreacion = ocp.HoraCreacion AND
		o.IdentificacionEmpleado = ocp.IdentificacionEmpleado AND
		o.Salon = ocp.Salon AND
		o.NumeroMesa = ocp.NumeroMesa AND
		ocp.codigoPlatillo = p.CodigoPlatillo AND
		per.Identificacion = ocp.IdentificacionEmpleado AND
		o.numeroOrden = 9000;



SELECT * FROM persona;
SELECT * FROM empleado;
SELECT * FROM orden order by NumeroOrden;
SELECT * FROM platillo;
SELECT * FROM mesa;
SELECT * FROM ordenContienePlatillo order by HoraCreacion, IdentificacionEmpleado, Salon, NumeroMesa;
