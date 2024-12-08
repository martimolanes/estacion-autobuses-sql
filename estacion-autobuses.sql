SET AUTOCOMMIT on;
SET SERVEROUTPUT on;

-- drops vistas
DROP VIEW VISTA_PERSONA;
DROP VIEW PASAJEROS_MENORES;
DROP VIEW VISTA_INFO_CONTRATO;
DROP VIEW VISTA_AB_NORMALES_DISPONIBLES;
-- drops tables
DROP TABLE PERSONA CASCADE CONSTRAINTS;
DROP TABLE TELEFONO CASCADE CONSTRAINTS;
DROP TABLE PASAJERO CASCADE CONSTRAINTS;
DROP TABLE CONTRATO CASCADE CONSTRAINTS;
DROP TABLE EMPLEADO CASCADE CONSTRAINTS;
DROP TABLE FAMILIAR CASCADE CONSTRAINTS;
DROP TABLE CONDUCTOR CASCADE CONSTRAINTS;
DROP TABLE EMPLEADO_ESTACION CASCADE CONSTRAINTS;
DROP TABLE EMPRESA CASCADE CONSTRAINTS;
DROP TABLE AUTOBUS CASCADE CONSTRAINTS;
DROP TABLE LINEA CASCADE CONSTRAINTS;
DROP TABLE AUTOBUS_URBANO CASCADE CONSTRAINTS;
DROP TABLE PARADA CASCADE CONSTRAINTS;
DROP TABLE LINEAS_PARADAS CASCADE CONSTRAINTS;
DROP TABLE AUTOBUS_INTERURBANO CASCADE CONSTRAINTS;
DROP TABLE RUTA CASCADE CONSTRAINTS;
DROP TABLE VIAJE CASCADE CONSTRAINTS;
DROP TABLE PASAJERO_VIAJE CASCADE CONSTRAINTS;
DROP TABLE SERVICIO CASCADE CONSTRAINTS;
DROP TABLE BILLETE CASCADE CONSTRAINTS;
DROP TABLE VENTA_BILLETE CASCADE CONSTRAINTS;
DROP TABLE BILLETE_COMBINADO CASCADE CONSTRAINTS;
DROP TABLE ALQUILER_AUTOBUS CASCADE CONSTRAINTS;
DROP TABLE ABONO CASCADE CONSTRAINTS;
DROP TABLE VENTA_ABONO CASCADE CONSTRAINTS;
DROP TABLE ABONO_NORMAL CASCADE CONSTRAINTS;
DROP TABLE ABONO_ILIMITADO CASCADE CONSTRAINTS;
DROP TABLE ABONO_EMPLEADO CASCADE CONSTRAINTS;
DROP TABLE ABONO_FAMILIAR CASCADE CONSTRAINTS;

-- drops procedimientos y funciones
DROP PROCEDURE ACTUALIZARSALARIOS;
DROP PROCEDURE RENOVARABONOILIMITADO;
DROP PROCEDURE ESEMPLEADO;
DROP PROCEDURE OBTENERCONDUCTORESMASVIAJES;
DROP FUNCTION TOTALABONOSVENDIDOS;
DROP FUNCTION DETALLESLINEAAUTOBUSURBANO;

--Sentencias de creacion de tablas
CREATE TABLE PERSONA(
    dni VARCHAR(9) NOT NULL CHECK (REGEXP_LIKE (dni, '^[0-9]{8}[A-Z]$')),
    nombre VARCHAR(30) NOT NULL CHECK (LENGTH (nombre) > 0),
    apellidos VARCHAR(60) NOT NULL CHECK (LENGTH (apellidos) > 0),
    fecha_nacimiento DATE NOT NULL,
    
    PRIMARY KEY(dni)
);

CREATE TABLE TELEFONO(
    dni VARCHAR(9) NOT NULL,
    telefono VARCHAR(14) NOT NULL UNIQUE CHECK (REGEXP_LIKE (telefono, '^([+]\d{1,3})?\s?[0-9]{9}$')),
    
    PRIMARY KEY (dni, telefono),
    FOREIGN KEY (dni) REFERENCES persona(dni) ON DELETE CASCADE
);

CREATE TABLE PASAJERO(
    dni VARCHAR(9) NOT NULL,
    acompanante VARCHAR(9),
    
    PRIMARY KEY(dni),
    
    FOREIGN KEY (dni) REFERENCES persona(dni) ON DELETE CASCADE,
    FOREIGN KEY (acompanante) REFERENCES pasajero(dni) ON DELETE CASCADE --si se borra el acompanante tambien el pasajero
);

CREATE TABLE CONTRATO(
    id_contrato NUMBER NOT NULL CHECK (id_contrato > 0),
    tipo VARCHAR(10) NOT NULL CHECK (tipo IN ('INDEFINIDO', 'TEMPORAL', 'PRACTICAS', 'FORMACION')),
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE,
    horas_semana NUMBER NOT NULL CHECK (horas_semana > 0),
    salario NUMBER NOT NULL CHECK (salario > 0),
    
    PRIMARY KEY (id_contrato),
    CHECK(fecha_fin IS NULL OR fecha_fin > fecha_inicio)
);

CREATE TABLE EMPLEADO(
    dni VARCHAR(9) NOT NULL,
    contrato NUMBER NOT NULL,
    
    PRIMARY KEY (dni),
    FOREIGN KEY (dni) REFERENCES persona(dni) ON DELETE CASCADE,
    FOREIGN KEY (contrato) REFERENCES contrato(id_contrato) ON DELETE CASCADE
);

CREATE TABLE FAMILIAR(
    dni VARCHAR(9) NOT NULL,
    empleado VARCHAR(9) NOT NULL,
    relacion VARCHAR(20) NOT NULL CHECK (LENGTH(relacion) > 0),
    
    PRIMARY KEY(dni, empleado),
    FOREIGN KEY (dni) REFERENCES persona(dni) ON DELETE CASCADE,
    FOREIGN KEY (empleado) REFERENCES empleado(dni) ON DELETE CASCADE
);

CREATE TABLE CONDUCTOR(
    dni VARCHAR(9) NOT NULL,
    num_licencia VARCHAR(15) NOT NULL UNIQUE CHECK (LENGTH(num_licencia) > 0),
    
    PRIMARY KEY (dni),
    FOREIGN KEY(dni) REFERENCES empleado(dni) ON DELETE CASCADE
);

CREATE TABLE EMPLEADO_ESTACION(
    dni VARCHAR(9) NOT NULL,
    abonos_vendidos NUMBER NOT NULL CHECK (abonos_vendidos >= 0),
    billetes_vendidos NUMBER NOT NULL CHECK (billetes_vendidos >= 0),
    
    PRIMARY KEY (dni),
    FOREIGN KEY (dni) REFERENCES empleado(dni) ON DELETE CASCADE
);

CREATE TABLE EMPRESA(
    cif VARCHAR(9) NOT NULL CHECK (REGEXP_LIKE(cif, '^[A-Z][0-9]{7}[A-Z]$')),
    nombre VARCHAR(30) NOT NULL UNIQUE CHECK (LENGTH(nombre) > 0),
    direccion VARCHAR(60) NOT NULL CHECK (LENGTH(direccion) > 0),
    telefono VARCHAR(14) NOT NULL UNIQUE CHECK (REGEXP_LIKE (telefono, '^([+]\d{1,3})?\s?[0-9]{9}$')),
    
    PRIMARY KEY (cif)
);

CREATE TABLE AUTOBUS(
    matricula VARCHAR(7) NOT NULL CHECK (REGEXP_LIKE(matricula, '^[0-9]{4}[A-Z]{3}$')),
    num_asientos NUMBER NOT NULL CHECK  (num_asientos > 0),
    modelo VARCHAR(30) NOT NULL CHECK (LENGTH(modelo) > 0),
    fecha_itv DATE NOT NULL,
    propietario VARCHAR(9) NOT NULL,
    
    PRIMARY KEY (matricula),
    FOREIGN KEY (propietario) REFERENCES empresa(cif) ON DELETE CASCADE
);

CREATE TABLE LINEA(
    num_linea NUMBER NOT NULL CHECK (num_linea > 0), --puede ser varchar si es tipo '12B'
    descripcion VARCHAR(40) NOT NULL CHECK (LENGTH(descripcion) > 0),
    
    PRIMARY KEY(num_linea)
);

CREATE TABLE AUTOBUS_URBANO(
    matricula VARCHAR(7) NOT NULL,
    aforo NUMBER NOT NULL CHECK (aforo > 0),
    linea NUMBER NOT NULL,
    
    PRIMARY KEY (matricula),
    FOREIGN KEY (matricula) REFERENCES autobus(matricula) ON DELETE CASCADE,
    FOREIGN KEY (linea) REFERENCES linea(num_linea) ON DELETE CASCADE
);

CREATE TABLE PARADA(
    cod_parada NUMBER NOT NULL CHECK (cod_parada > 0), --puede ser varchar tambien
    direccion VARCHAR(50) NOT NULL UNIQUE CHECK (LENGTH(direccion) > 0),
    
    PRIMARY KEY(cod_parada)
);

CREATE TABLE LINEAS_PARADAS(
    linea NUMBER NOT NULL,
    parada NUMBER NOT NULL,
    orden NUMBER NOT NULL CHECK (orden > 0),
    
    PRIMARY KEY (linea, parada),
    FOREIGN KEY (linea) REFERENCES linea(num_linea) ON DELETE CASCADE,
    FOREIGN KEY (parada) REFERENCES parada(cod_parada) ON DELETE CASCADE,
    UNIQUE (linea, orden)
);

CREATE TABLE AUTOBUS_INTERURBANO(
    matricula VARCHAR(7) NOT NULL,
    num_plazas NUMBER NOT NULL CHECK (num_plazas > 0),
    
    PRIMARY KEY (matricula),
    FOREIGN KEY (matricula) REFERENCES autobus(matricula) ON DELETE CASCADE
);

CREATE TABLE RUTA(
    id_ruta NUMBER NOT NULL CHECK (id_ruta > 0),
    origen VARCHAR(50) NOT NULL CHECK (LENGTH(origen) > 0),
    destino VARCHAR(50) NOT NULL CHECK (LENGTH(destino) > 0),
    duracion NUMBER NOT NULL CHECK (duracion > 0), --en minutos
    
    PRIMARY KEY (id_ruta)
);

CREATE TABLE VIAJE(
    id_viaje NUMBER NOT NULL CHECK (id_viaje > 0),
    fecha DATE NOT NULL,
    ruta NUMBER,
    conductor VARCHAR(9),
    autobus VARCHAR(7),
    
    PRIMARY KEY (id_viaje),
    FOREIGN KEY (ruta) REFERENCES ruta(id_ruta) ON DELETE SET NULL,
    FOREIGN KEY (conductor) REFERENCES conductor(dni) ON DELETE SET NULL,
    FOREIGN KEY (autobus) REFERENCES autobus(matricula) ON DELETE SET NULL
);

CREATE TABLE PASAJERO_VIAJE(
    id_viaje NUMBER NOT NULL,
    dni VARCHAR(9) NOT NULL,

    PRIMARY KEY (id_viaje, dni),
    FOREIGN KEY (id_viaje) REFERENCES viaje(id_viaje) ON DELETE CASCADE,
    FOREIGN KEY (dni) REFERENCES pasajero(dni) ON DELETE CASCADE
);

CREATE TABLE SERVICIO(
    id_servicio NUMBER NOT NULL CHECK (id_servicio > 0),
    precio NUMBER(8,2) NOT NULL CHECK (precio > 0),
    contratado_por VARCHAR(9),
    fecha DATE NOT NULL,
    
    PRIMARY KEY (id_servicio),
    FOREIGN KEY (contratado_por) REFERENCES pasajero(dni) ON DELETE SET NULL
);

CREATE TABLE BILLETE(
    id_billete NUMBER NOT NULL CHECK (id_billete > 0),
    viaje NUMBER NOT NULL,
    
    PRIMARY KEY (id_billete),
    FOREIGN KEY (viaje) REFERENCES viaje(id_viaje) ON DELETE CASCADE
);

CREATE TABLE VENTA_BILLETE(
    id_servicio NUMBER NOT NULL,
    billete NUMBER,
    
    PRIMARY KEY (id_servicio),
    FOREIGN KEY (id_servicio) REFERENCES servicio(id_servicio) ON DELETE CASCADE,
    FOREIGN KEY (billete) REFERENCES billete(id_billete) ON DELETE SET NULL
);

CREATE TABLE BILLETE_COMBINADO(
    id_servicio NUMBER NOT NULL,
    tipo VARCHAR(20) NOT NULL CHECK(tipo IN ('BUS+TREN', 'BUS+AVION', 'BUS+FERRY')),
    billete NUMBER,
    
    PRIMARY KEY (id_servicio),
    FOREIGN KEY (billete) REFERENCES billete(id_billete) ON DELETE SET NULL,
    FOREIGN KEY (id_servicio) REFERENCES servicio(id_servicio) ON DELETE CASCADE
);
    
CREATE TABLE ALQUILER_AUTOBUS(
    id_servicio NUMBER NOT NULL,
    autobus VARCHAR(7) NOT NULL,
    
    PRIMARY KEY(id_servicio),
    FOREIGN KEY (id_servicio) REFERENCES servicio(id_servicio) ON DELETE CASCADE,
    FOREIGN KEY (autobus) REFERENCES autobus_interurbano(matricula) ON DELETE CASCADE
);

CREATE TABLE ABONO(
    id_abono NUMBER NOT NULL CHECK (id_abono > 0),
    fecha_contrato DATE NOT NULL,
    fecha_caducidad DATE NOT NULL,
    
    PRIMARY KEY(id_abono),
    
    CHECK(fecha_caducidad > fecha_contrato)
);

CREATE TABLE VENTA_ABONO(
    id_servicio NUMBER NOT NULL,
    abono NUMBER NOT NULL,
        
    PRIMARY KEY(id_servicio),
    FOREIGN KEY (id_servicio) REFERENCES servicio(id_servicio) ON DELETE CASCADE,
    FOREIGN KEY (abono) REFERENCES abono(id_abono) ON DELETE CASCADE
);

CREATE TABLE ABONO_NORMAL(
    id_abono NUMBER NOT NULL,
    limite_viajes NUMBER NOT NULL CHECK (limite_viajes > 0),
    viajes_consumidos NUMBER NOT NULL CHECK (viajes_consumidos >= 0),
    
    PRIMARY KEY (id_abono),
    FOREIGN KEY (id_abono) REFERENCES abono(id_abono) ON DELETE CASCADE,
    
    CHECK (limite_viajes >= viajes_consumidos)
);

CREATE TABLE ABONO_ILIMITADO(
    id_abono NUMBER NOT NULL,
    
    PRIMARY KEY(id_abono),
    FOREIGN KEY (id_abono) REFERENCES abono(id_abono) ON DELETE CASCADE
);


CREATE TABLE ABONO_EMPLEADO(
    id_abono NUMBER NOT NULL,
    empleado VARCHAR(9) NOT NULL,
    descuento NUMBER NOT NULL CHECK (descuento BETWEEN 10 AND 60),
    
    PRIMARY KEY (id_abono),
    FOREIGN KEY (id_abono) REFERENCES abono(id_abono) ON DELETE CASCADE,
    FOREIGN KEY (empleado) REFERENCES empleado(dni) ON DELETE CASCADE
);

CREATE TABLE ABONO_FAMILIAR(
    id_abono NUMBER NOT NULL,
    familiar VARCHAR(9) NOT NULL,
    empleado VARCHAR(9) NOT NULL,
    descuento NUMBER NOT NULL CHECK (descuento BETWEEN 10 AND 60),
    
    PRIMARY KEY (id_abono),
    FOREIGN KEY (id_abono) REFERENCES abono(id_abono) ON DELETE CASCADE,
    FOREIGN KEY (familiar, empleado) REFERENCES familiar(dni, empleado) ON DELETE CASCADE
);

-- Sentencias de Creacion de Indices

/* Indice compuesto para optimizar consultas que filtren registros en la tabla 'persona', 
   priorizando busquedas por 'nombre' seguido de 'apellidos', aprovechando el acceso rapido mediante indice en filtros WHERE */ 
CREATE INDEX indice_persona ON persona(nombre, apellidos);

/* Indice sobre la columna 'fecha_inicio' para acelerar las consultas que filtran o clasifican 
    registros de la tabla 'contrato', mejorando el rendimiento de busquedas basadas en rangos de fechas o comparaciones en filtros WHERE. */
CREATE INDEX indice_contrato ON contrato(fecha_inicio);

/* Indice en la columna 'fecha_contrato' para optimizar el acceso a los registros en la tabla 'abono' que dependen de la fecha del contrato, 
    especialmente util en consultas que involucren agrupacion o filtrado por fecha. */
CREATE INDEX indice_abono ON abono(fecha_contrato);

/* Indice sobre la columna 'fecha' en la tabla 'viaje', creado para mejorar el tiempo de respuesta de consultas que busquen o filtren viajes 
    por fechas especificas o rangos de fechas, evitando full table scans. */ 
CREATE INDEX indice_viaje ON viaje(fecha);

-- Sentencias para la creacion de vistas

/*Vista que muestra la edad*/
/*Vista actualizable*/
CREATE OR REPLACE VIEW VISTA_PERSONA AS
   SELECT dni, (nombre || ' ' || apellidos) AS nombre_completo,
   fecha_nacimiento, TRUNC((sysdate - fecha_nacimiento)/365,0) AS edad
FROM persona;

/*Vista que muestra los pasajeros menores de edad*/
/*Vista no actualizable*/
CREATE OR REPLACE VIEW PASAJEROS_MENORES AS
   SELECT p.dni, p.nombre, p.apellidos, p.fecha_nacimiento
   FROM Persona p
   JOIN Pasajero pa ON p.dni = pa.dni
   WHERE (sysdate - p.fecha_nacimiento) / 365 < 18;
   
/*Vista que muestra la informacion de un contrato y un empleado*/
/*Vista no actualizable*/
CREATE  OR REPLACE VIEW VISTA_INFO_CONTRATO AS
SELECT e.dni,
   c.id_contrato,
   c.tipo,
   c.salario,
   c.horas_semana,
   c.fecha_inicio,
   c.fecha_fin
FROM EMPLEADO e JOIN CONTRATO c ON e.CONTRATO = c.ID_CONTRATO JOIN PERSONA p ON e.dni= p.dni;

/*Vista que muestra los abonos normales que aun no caducaron y que aun tienen viajes disponibles*/
/*Vista no actualizable*/
CREATE  OR REPLACE VIEW VISTA_AB_NORMALES_DISPONIBLES AS
SELECT a.id_abono,
    a.fecha_contrato,
    a.fecha_caducidad,
    (an.limite_viajes - an.viajes_consumidos) AS viajes_restantes
FROM ABONO a JOIN ABONO_NORMAL an ON a.id_abono=an.id_abono
WHERE fecha_caducidad > sysdate AND (an.limite_viajes - an.viajes_consumidos) > 0;

-- Sentencias de insercion

-- tabla PERSONA
INSERT INTO PERSONA(dni, nombre, apellidos, fecha_nacimiento ) VALUES('35225389S', 'Pepe', 'Gonzalez', TO_DATE('10/02/1995','DD/MM/YYYY'));
INSERT INTO PERSONA(dni, nombre, apellidos, fecha_nacimiento ) VALUES('59643874T', 'Lucas', 'Etxebarri', TO_DATE('23/05/2000','DD/MM/YYYY'));
INSERT INTO PERSONA(dni, nombre, apellidos, fecha_nacimiento ) VALUES('25647312F', 'Maria', 'Gutierrez', TO_DATE('02/12/2004','DD/MM/YYYY'));
INSERT INTO PERSONA(dni, nombre, apellidos, fecha_nacimiento ) VALUES('35674242X', 'Carmen', 'Vazquez', TO_DATE('1980/01/30','YYYY/MM/DD'));
INSERT INTO PERSONA(dni, nombre, apellidos, fecha_nacimiento ) VALUES('35749531Z', 'Daniela', 'Gonzalez', TO_DATE('22/08/2022','DD/MM/YYYY'));
INSERT INTO PERSONA(dni, nombre, apellidos, fecha_nacimiento ) VALUES('35674253N', 'Diego', 'Barja', TO_DATE('14/01/1998','DD/MM/YYYY'));
INSERT INTO PERSONA(dni, nombre, apellidos, fecha_nacimiento ) VALUES('46813937H', 'Alba', 'Cid', TO_DATE('1976/10/05','YYYY/MM/DD'));
INSERT INTO PERSONA(dni, nombre, apellidos, fecha_nacimiento ) VALUES('82082351Y', 'Alfredo', 'Diaz', TO_DATE('20/03/1970','DD/MM/YYYY'));
INSERT INTO PERSONA(dni, nombre, apellidos, fecha_nacimiento ) VALUES('35537699R', 'Rosa', 'Prado', TO_DATE('24/04/1965','DD/MM/YYYY'));


-- tabla PASAJERO
INSERT INTO PASAJERO(dni) VALUES('35225389S');
INSERT INTO PASAJERO(dni) VALUES('59643874T');
INSERT INTO PASAJERO(dni) VALUES('25647312F');
INSERT INTO PASAJERO(dni) VALUES('35674242X');
INSERT INTO PASAJERO(dni) VALUES('35674253N');
INSERT INTO PASAJERO(dni) VALUES('46813937H');
INSERT INTO PASAJERO(dni, acompanante) VALUES('35749531Z', NULL);


-- tabla TELEFONO
INSERT INTO TELEFONO(dni, telefono) VALUES ('35225389S', '630335980');
INSERT INTO TELEFONO(dni, telefono) VALUES ('35225389S', '973451258'); 
INSERT INTO TELEFONO(dni, telefono) VALUES ('59643874T', '690221154');
INSERT INTO TELEFONO(dni, telefono) VALUES ('25647312F', '651801206');
INSERT INTO TELEFONO(dni, telefono) VALUES ('35674242X', '615458792');

-- tabla CONTRATO
INSERT INTO CONTRATO(id_contrato, tipo, fecha_inicio, fecha_fin, horas_semana, salario) VALUES ('1', 'INDEFINIDO', TO_DATE('14/03/1992', 'DD/MM/YYYY'), NULL, '40', '1350');
INSERT INTO CONTRATO(id_contrato, tipo, fecha_inicio, fecha_fin, horas_semana, salario) VALUES ('2', 'TEMPORAL', TO_DATE('31/08/2024', 'DD/MM/YYYY'), TO_DATE('31/12/2024', 'DD/MM/YYYY'), '40', '1200');
INSERT INTO CONTRATO(id_contrato, tipo, fecha_inicio, fecha_fin, horas_semana, salario) VALUES ('3', 'PRACTICAS', TO_DATE('16/09/2024', 'DD/MM/YYYY'), TO_DATE('27/12/2024', 'DD/MM/YYYY'), '20', '400');
INSERT INTO CONTRATO(id_contrato, tipo, fecha_inicio, fecha_fin, horas_semana, salario) VALUES ('4', 'FORMACION', TO_DATE('14/09/2022', 'DD/MM/YYYY'), TO_DATE('24/05/2024', 'DD/MM/YYYY'), '20', '600');

  
-- tabla EMPLEADO
INSERT INTO EMPLEADO (dni, contrato) VALUES ('35674253N', 1);
INSERT INTO EMPLEADO (dni, contrato) VALUES ('46813937H', 2);
INSERT INTO EMPLEADO (dni, contrato) VALUES ('82082351Y', 3);
INSERT INTO EMPLEADO (dni, contrato) VALUES ('35537699R', 4);

-- tabla FAMILIAR
INSERT INTO FAMILIAR (dni, empleado, relacion) VALUES ('35225389S', '35674253N', 'Padre');

-- tabla CONDUCTOR

INSERT INTO CONDUCTOR (dni, num_licencia) VALUES ('35674253N', '22301');
INSERT INTO CONDUCTOR (dni, num_licencia) VALUES ('82082351Y', '22536');
INSERT INTO CONDUCTOR (dni, num_licencia) VALUES ('35537699R', '22456');

-- tabla EMPLEADO_ESTACION
INSERT INTO EMPLEADO_ESTACION (dni, abonos_vendidos, billetes_vendidos) VALUES ('46813937H', '25', '10');

-- tabla EMPRESA
INSERT INTO EMPRESA (cif, nombre, direccion, telefono) VALUES ('B2322468R', 'BUSDII', 'AVENIDA OTERO PEDRAYO', '926434765');
INSERT INTO EMPRESA (cif, nombre, direccion, telefono) VALUES ('P2353389X', 'RUTADIRECTA', 'RUA DO PROGRESO', '957875323');

-- tabla AUTOBUS
INSERT INTO AUTOBUS (matricula, num_asientos, modelo, fecha_itv, propietario) VALUES ('5624SQL', '30', 'Iveco Citelis', TO_DATE('21/08/2024', 'DD/MM/YYYY'), 'B2322468R');
INSERT INTO AUTOBUS (matricula, num_asientos, modelo, fecha_itv, propietario) VALUES ('2024BRR', '30', 'Iveco Citelis', TO_DATE('01/05/2024', 'DD/MM/YYYY'), 'B2322468R');
INSERT INTO AUTOBUS (matricula, num_asientos, modelo, fecha_itv, propietario) VALUES ('8644NMO', '45', 'Iveco Citelis Articulado', TO_DATE('28/04/2024', 'DD/MM/YYYY'), 'B2322468R');
INSERT INTO AUTOBUS (matricula, num_asientos, modelo, fecha_itv, propietario) VALUES ('9191SOL', '45', 'Iveco Citelis Articulado', TO_DATE('15/11/2023', 'DD/MM/YYYY'), 'B2322468R');
INSERT INTO AUTOBUS (matricula, num_asientos, modelo, fecha_itv, propietario) VALUES ('2234KFC', '60', 'Iveco Citelis', TO_DATE('30/09/2024', 'DD/MM/YYYY'), 'B2322468R');
INSERT INTO AUTOBUS (matricula, num_asientos, modelo, fecha_itv, propietario) VALUES ('6754BDI', '75', 'Mercedes Benz O-405 G', TO_DATE('10/10/2024', 'DD/MM/YYYY'), 'P2353389X');
INSERT INTO AUTOBUS (matricula, num_asientos, modelo, fecha_itv, propietario) VALUES ('3223BUS', '40', 'Mercedes Benz O-405 N2', TO_DATE('14/12/2023', 'DD/MM/YYYY'), 'P2353389X');
INSERT INTO AUTOBUS (matricula, num_asientos, modelo, fecha_itv, propietario) VALUES ('3060RTX', '40', 'Mercedes Benz O-405 N2', TO_DATE('24/12/2023', 'DD/MM/YYYY'), 'P2353389X');
INSERT INTO AUTOBUS (matricula, num_asientos, modelo, fecha_itv, propietario) VALUES ('4455USB', '40', 'Mercedes Benz O-405 N2', TO_DATE('14/10/2024', 'DD/MM/YYYY'), 'P2353389X');

-- tabla LINEA
INSERT INTO LINEA (num_linea, descripcion) VALUES ('1', 'San Lazaro - Residencia');
INSERT INTO LINEA (num_linea, descripcion) VALUES ('2', 'Alameda - Campus As Lagoas');
INSERT INTO LINEA (num_linea, descripcion) VALUES ('3', 'O Cumial- Seixalvo');
INSERT INTO LINEA (num_linea, descripcion) VALUES ('4', 'Tanatorio - Sainza');
INSERT INTO LINEA (num_linea, descripcion) VALUES ('5', 'Covadonga - Quintela');
INSERT INTO LINEA (num_linea, descripcion) VALUES ('6', 'Rairo - Cudeiro');

-- tabla AUTOBUS_URBANO
INSERT INTO AUTOBUS_URBANO (matricula, aforo, linea) VALUES ('5624SQL', '40', '1');
INSERT INTO AUTOBUS_URBANO (matricula, aforo, linea) VALUES ('2024BRR', '40', '3');
INSERT INTO AUTOBUS_URBANO (matricula, aforo, linea) VALUES ('8644NMO', '55', '2');
INSERT INTO AUTOBUS_URBANO (matricula, aforo, linea) VALUES ('9191SOL', '55', '4');
INSERT INTO AUTOBUS_URBANO (matricula, aforo, linea) VALUES ('3223BUS', '50', '1');
INSERT INTO AUTOBUS_URBANO (matricula, aforo, linea) VALUES ('3060RTX', '50', '5');
INSERT INTO AUTOBUS_URBANO (matricula, aforo, linea) VALUES ('4455USB', '50', '6');

-- tabla PARADA
INSERT INTO PARADA (cod_parada, direccion) VALUES ('1', 'RUA CURROS ENRIQUEZ');
INSERT INTO PARADA (cod_parada, direccion) VALUES ('2', 'AVENIDA DE MARIN');
INSERT INTO PARADA (cod_parada, direccion) VALUES ('3', 'PARQUE DE SAN LAZARO');
INSERT INTO PARADA (cod_parada, direccion) VALUES ('4', 'XARDIN DO POSIO');
INSERT INTO PARADA (cod_parada, direccion) VALUES ('5', 'AVENIDA DE SANTIAGO');
INSERT INTO PARADA (cod_parada, direccion) VALUES ('6', 'RUA DO PROGRESO');
INSERT INTO PARADA (cod_parada, direccion) VALUES ('7', 'RUA XOAN XXIII');
INSERT INTO PARADA (cod_parada, direccion) VALUES ('8', 'RUA ANGEL BARJA');
INSERT INTO PARADA (cod_parada, direccion) VALUES ('9', 'RUA DOUTOR TERMES');

-- tabla LINEAS_PARADAS
INSERT INTO LINEAS_PARADAS (linea, parada, orden) VALUES ('1', '2', '1');
INSERT INTO LINEAS_PARADAS (linea, parada, orden) VALUES ('1', '1', '2');
INSERT INTO LINEAS_PARADAS (linea, parada, orden) VALUES ('1', '3', '3');

INSERT INTO LINEAS_PARADAS (linea, parada, orden) VALUES ('2', '6', '1');
INSERT INTO LINEAS_PARADAS (linea, parada, orden) VALUES ('2', '7', '2');
INSERT INTO LINEAS_PARADAS (linea, parada, orden) VALUES ('2', '1', '3');
INSERT INTO LINEAS_PARADAS (linea, parada, orden) VALUES ('2', '8', '4');
INSERT INTO LINEAS_PARADAS (linea, parada, orden) VALUES ('2', '9', '5');

INSERT INTO LINEAS_PARADAS (linea, parada, orden) VALUES ('3', '1', '1');
INSERT INTO LINEAS_PARADAS (linea, parada, orden) VALUES ('3', '2', '2');
INSERT INTO LINEAS_PARADAS (linea, parada, orden) VALUES ('3', '5', '3');

INSERT INTO LINEAS_PARADAS (linea, parada, orden) VALUES ('4', '5', '1');
INSERT INTO LINEAS_PARADAS (linea, parada, orden) VALUES ('4', '2', '2');
INSERT INTO LINEAS_PARADAS (linea, parada, orden) VALUES ('4', '1', '3');

INSERT INTO LINEAS_PARADAS (linea, parada, orden) VALUES ('5', '3', '1');
INSERT INTO LINEAS_PARADAS (linea, parada, orden) VALUES ('5', '1', '2');
INSERT INTO LINEAS_PARADAS (linea, parada, orden) VALUES ('5', '4', '3');

INSERT INTO LINEAS_PARADAS (linea, parada, orden) VALUES ('6', '4', '1');
INSERT INTO LINEAS_PARADAS (linea, parada, orden) VALUES ('6', '1', '2');
INSERT INTO LINEAS_PARADAS (linea, parada, orden) VALUES ('6', '3', '3');

-- tabla AUTOBUS_INTERURBANO
INSERT INTO AUTOBUS_INTERURBANO (matricula, num_plazas) VALUES ('2234KFC', '60');
INSERT INTO AUTOBUS_INTERURBANO (matricula, num_plazas) VALUES ('6754BDI', '75');

-- tabla RUTA
INSERT INTO RUTA (id_ruta, origen, destino, duracion) VALUES ('1', 'OURENSE', 'SANTIAGO', '120');
INSERT INTO RUTA (id_ruta, origen, destino, duracion) VALUES ('2', 'OURENSE', 'VIGO', '90');

-- tabla VIAJE
INSERT INTO VIAJE(id_viaje, fecha, ruta, conductor, autobus) VALUES ('1', TO_DATE('14/03/2019', 'DD/MM/YYYY'),'2','35674253N','2024BRR');
INSERT INTO VIAJE(id_viaje, fecha, ruta, conductor, autobus) VALUES ('2', TO_DATE('04/10/2020', 'DD/MM/YYYY'),'1','35537699R','3060RTX');
INSERT INTO VIAJE(id_viaje, fecha, ruta, conductor, autobus) VALUES ('3', TO_DATE('28/07/2023', 'DD/MM/YYYY'),'2','82082351Y','6754BDI');

-- tabla PASAJERO_VIAJE
INSERT INTO PASAJERO_VIAJE(id_viaje, dni) VALUES ('1', '35225389S');
INSERT INTO PASAJERO_VIAJE(id_viaje, dni) VALUES ('1', '25647312F');
INSERT INTO PASAJERO_VIAJE(id_viaje, dni) VALUES ('2', '35225389S');
INSERT INTO PASAJERO_VIAJE(id_viaje, dni) VALUES ('3', '46813937H');

-- tabla SERVICIO
INSERT INTO SERVICIO (id_servicio, precio, contratado_por, fecha) VALUES ('1', '0,50', '35225389S', TO_DATE('14/01/2017', 'DD/MM/YYYY'));
INSERT INTO SERVICIO (id_servicio, precio, contratado_por, fecha) VALUES ('2', '0,70', '59643874T', TO_DATE('03/10/2010', 'DD/MM/YYYY'));
INSERT INTO SERVICIO (id_servicio, precio, contratado_por, fecha) VALUES ('3', '3,10', '25647312F', TO_DATE('17/08/2015', 'DD/MM/YYYY'));
INSERT INTO SERVICIO (id_servicio, precio, contratado_por, fecha) VALUES ('4', '40,00', '35674242X', TO_DATE('12/12/2020', 'DD/MM/YYYY'));
INSERT INTO SERVICIO (id_servicio, precio, contratado_por, fecha) VALUES ('5', '50,00', '35749531Z', TO_DATE('04/03/2021', 'DD/MM/YYYY'));
INSERT INTO SERVICIO (id_servicio, precio, contratado_por, fecha) VALUES ('6', '60,00', '35674253N', TO_DATE('10/06/2019', 'DD/MM/YYYY'));
INSERT INTO SERVICIO (id_servicio, precio, contratado_por, fecha) VALUES ('7', '7000,00', '46813937H', TO_DATE('22/05/2015', 'DD/MM/YYYY'));
INSERT INTO SERVICIO (id_servicio, precio, contratado_por, fecha) VALUES ('8', '8300,00', '59643874T', TO_DATE('24/11/2019', 'DD/MM/YYYY'));
INSERT INTO SERVICIO (id_servicio, precio, contratado_por, fecha) VALUES ('9', '90,00', '35674242X', TO_DATE('30/08/2020', 'DD/MM/YYYY'));
INSERT INTO SERVICIO (id_servicio, precio, contratado_por, fecha) VALUES ('10', '100,00', '35225389S', TO_DATE('03/09/2015', 'DD/MM/YYYY'));
INSERT INTO SERVICIO (id_servicio, precio, contratado_por, fecha) VALUES ('11', '110,00', '59643874T', TO_DATE('09/11/2022', 'DD/MM/YYYY'));
INSERT INTO SERVICIO (id_servicio, precio, contratado_por, fecha) VALUES ('12', '120,00', '25647312F', TO_DATE('10/06/2022', 'DD/MM/YYYY'));
INSERT INTO SERVICIO (id_servicio, precio, contratado_por, fecha) VALUES ('13', '130,00', '35674242X', TO_DATE('16/01/2019', 'DD/MM/YYYY'));
INSERT INTO SERVICIO (id_servicio, precio, contratado_por, fecha) VALUES ('14', '140,00', '35749531Z', TO_DATE('10/06/2011', 'DD/MM/YYYY'));
INSERT INTO SERVICIO (id_servicio, precio, contratado_por, fecha) VALUES ('15', '150,00', '35674253N', TO_DATE('19/07/2018', 'DD/MM/YYYY'));
INSERT INTO SERVICIO (id_servicio, precio, contratado_por, fecha) VALUES ('16', '160,00', '46813937H', TO_DATE('11/10/2019', 'DD/MM/YYYY'));
INSERT INTO SERVICIO (id_servicio, precio, contratado_por, fecha) VALUES ('17', '170,00', '35225389S', TO_DATE('05/06/2020', 'DD/MM/YYYY'));

-- tabla BILLETE
INSERT INTO BILLETE (id_billete, viaje) VALUES ('1', '1');
INSERT INTO BILLETE (id_billete, viaje) VALUES ('2', '2');
INSERT INTO BILLETE (id_billete, viaje) VALUES ('3', '3');
INSERT INTO BILLETE (id_billete, viaje) VALUES ('4', '1');
INSERT INTO BILLETE (id_billete, viaje) VALUES ('5', '2');
INSERT INTO BILLETE (id_billete, viaje) VALUES ('6', '3');

-- tabla VENTA_BILLETE
INSERT INTO VENTA_BILLETE (id_servicio, billete) VALUES ('1', '1');
INSERT INTO VENTA_BILLETE (id_servicio, billete) VALUES ('2', '2');
INSERT INTO VENTA_BILLETE (id_servicio, billete) VALUES ('3', '3');

-- tabla BILLETE_COMBINADO
INSERT INTO BILLETE_COMBINADO (id_servicio, tipo, billete) VALUES ('4', 'BUS+TREN', '4');
INSERT INTO BILLETE_COMBINADO (id_servicio, tipo, billete) VALUES ('5', 'BUS+AVION', '5');
INSERT INTO BILLETE_COMBINADO (id_servicio, tipo, billete) VALUES ('6', 'BUS+FERRY', '6');

-- tabla ALQUILER_AUTOBUS
INSERT INTO ALQUILER_AUTOBUS (id_servicio, autobus) VALUES ('7', '2234KFC');
INSERT INTO ALQUILER_AUTOBUS (id_servicio, autobus) VALUES ('8', '6754BDI');

-- tabla ABONO
INSERT INTO ABONO(id_abono, fecha_contrato, fecha_caducidad) VALUES (1, TO_DATE('01/01/2022', 'DD/MM/YYYY'), TO_DATE('31/12/2022', 'DD/MM/YYYY'));
INSERT INTO ABONO(id_abono, fecha_contrato, fecha_caducidad) VALUES (2, TO_DATE('01/06/2024', 'DD/MM/YYYY'), TO_DATE('31/12/2025', 'DD/MM/YYYY'));
INSERT INTO ABONO(id_abono, fecha_contrato, fecha_caducidad) VALUES (3, TO_DATE('15/09/2024', 'DD/MM/YYYY'), TO_DATE('31/12/2024', 'DD/MM/YYYY'));
INSERT INTO ABONO(id_abono, fecha_contrato, fecha_caducidad) VALUES (4, TO_DATE('01/05/2024', 'DD/MM/YYYY'), TO_DATE('30/11/2024', 'DD/MM/YYYY'));
INSERT INTO ABONO(id_abono, fecha_contrato, fecha_caducidad) VALUES (5, TO_DATE('01/01/2023', 'DD/MM/YYYY'), TO_DATE('31/12/2024', 'DD/MM/YYYY'));
INSERT INTO ABONO(id_abono, fecha_contrato, fecha_caducidad) VALUES (6, TO_DATE('16/04/2024', 'DD/MM/YYYY'), TO_DATE('16/04/2025', 'DD/MM/YYYY'));
INSERT INTO ABONO(id_abono, fecha_contrato, fecha_caducidad) VALUES (7, TO_DATE('07/07/2024', 'DD/MM/YYYY'), TO_DATE('25/12/2024', 'DD/MM/YYYY'));
INSERT INTO ABONO(id_abono, fecha_contrato, fecha_caducidad) VALUES (8, TO_DATE('30/04/2024', 'DD/MM/YYYY'), TO_DATE('27/01/2025', 'DD/MM/YYYY'));
INSERT INTO ABONO(id_abono, fecha_contrato, fecha_caducidad) VALUES (9, TO_DATE('30/05/2024', 'DD/MM/YYYY'), TO_DATE('19/02/2026', 'DD/MM/YYYY'));

-- tabla VENTA_ABONO
INSERT INTO VENTA_ABONO(id_servicio, abono) VALUES(9,1);
INSERT INTO VENTA_ABONO(id_servicio, abono) VALUES(10,2);
INSERT INTO VENTA_ABONO(id_servicio, abono) VALUES(11,3);
INSERT INTO VENTA_ABONO(id_servicio, abono) VALUES(12,4);
INSERT INTO VENTA_ABONO(id_servicio, abono) VALUES(13,5);
INSERT INTO VENTA_ABONO(id_servicio, abono) VALUES(14,6);
INSERT INTO VENTA_ABONO(id_servicio, abono) VALUES(15,7);
INSERT INTO VENTA_ABONO(id_servicio, abono) VALUES(16,8);
INSERT INTO VENTA_ABONO(id_servicio, abono) VALUES(17,9);

-- tabla ABONO_NORMAL
INSERT INTO ABONO_NORMAL(id_abono, limite_viajes, viajes_consumidos) VALUES(1, 10, 3);
INSERT INTO ABONO_NORMAL(id_abono, limite_viajes, viajes_consumidos) VALUES(2, 20, 9);
INSERT INTO ABONO_NORMAL(id_abono, limite_viajes, viajes_consumidos) VALUES(3, 5, 5);
INSERT INTO ABONO_NORMAL(id_abono, limite_viajes, viajes_consumidos) VALUES(4, 10, 7);

-- tabla ABONO_ILIMITADO
INSERT INTO ABONO_ILIMITADO(id_abono) VALUES(5);
INSERT INTO ABONO_ILIMITADO(id_abono) VALUES(6);

-- tabla ABONO_EMPLEADO
INSERT INTO ABONO_EMPLEADO(id_abono, empleado, descuento) VALUES(7, '35674253N', 20);
INSERT INTO ABONO_EMPLEADO(id_abono, empleado, descuento) VALUES(8, '46813937H', 30);

-- tabla ABONO_FAMILIAR
INSERT INTO ABONO_FAMILIAR(id_abono, familiar, empleado, descuento) VALUES(9, '35225389S', '35674253N', 10);


-- SENTENCIAS SQL DE COMPROBACION


-- Mostrar las matriculas de autobuses urbanos que pertenecen a la empresa con CIF 'P2353389X'
SELECT a.matricula
FROM AUTOBUS a
JOIN EMPRESA e ON a.propietario = e.cif
JOIN AUTOBUS_URBANO au ON a.matricula = au.matricula
WHERE e.cif = 'P2353389X';


-- Cancelar el billete 3
DELETE FROM BILLETE
WHERE id_billete = '3';


-- Mostrar los buses pertenecientes a la empresa con CIF 'B2322468R'
SELECT *
FROM autobus
WHERE propietario = 'B2322468R';


-- Despedir a un empleado
UPDATE contrato
SET
    fecha_fin = SYSDATE
WHERE
    id_contrato = (
        SELECT contrato
        FROM empleado
        WHERE dni = '46813937H'
    );


-- Mostrar datos de los empleados que ya no trabajan en la estacion
SELECT p.dni, p.nombre, p.apellidos, c.id_contrato, c.fecha_inicio, c.fecha_fin
FROM PERSONA p, EMPLEADO e, CONTRATO c
WHERE p.dni = e.dni AND e.contrato = c.id_contrato AND c.fecha_fin <= SYSDATE;


-- Subir el salario de un empleado
UPDATE contrato
SET
    salario = salario + 100
WHERE
    id_contrato = (
        SELECT contrato
        FROM empleado
        WHERE dni = '46813937H'
    );


-- Comprobar salario de un empleado
SELECT salario
FROM contrato
WHERE id_contrato = (
    SELECT contrato
    FROM empleado
    WHERE dni = '46813937H'
);


-- Cambiar el tipo de contrato de un empleado
UPDATE contrato
SET
    tipo = 'INDEFINIDO'
WHERE
    id_contrato = (
        SELECT contrato
        FROM empleado
        WHERE dni = '46813937H'
    );


-- Comprobar tipo de contrato de un empleado
SELECT tipo
FROM contrato
WHERE id_contrato = (
    SELECT contrato
    FROM empleado
    WHERE dni = '46813937H'
);


-- Mostrar los empleados con salarios mayores a 1000 euros
SELECT *
FROM EMPLEADO
WHERE contrato IN (
                SELECT id_contrato
                FROM CONTRATO
                WHERE salario > 1000
                );


-- Mostrar las paradas de la linea 2 en orden ascendente
SELECT lp.parada, p.direccion
FROM LINEAS_PARADAS lp, PARADA p
WHERE linea = 2 AND lp.parada = p.cod_parada
ORDER BY orden ASC;


-- Mostrar las rutas con destino VIGO con una duracion menor a 2 horas
SELECT *
FROM RUTA
WHERE destino = 'VIGO' and duracion < 120;


-- Mostrar el numero de viajes restantes totales de abonos
SELECT SUM(viajes_restantes) AS total_viajes_restantes
FROM VISTA_AB_NORMALES_DISPONIBLES;


-- Actualizar el conductor de un viaje
UPDATE VIAJE
SET conductor = '35674253N'
WHERE id_viaje = 2;


-- Mostrar conductores que tengan 2 o mas viajes
SELECT *
FROM CONDUCTOR
WHERE dni IN (
                SELECT conductor
                FROM VIAJE
                GROUP BY conductor
                HAVING COUNT(*) >= 2
            );


-- Ejemplo de borrado de una persona que sea empleado con un familiar asociado. El familiar tiene un abono tambien
DELETE
FROM PERSONA
WHERE dni = '35674253N';


-- Comprobacion de que todos los datos se borraron en cascada
SELECT *
FROM EMPLEADO
WHERE dni = '35674253N';

SELECT *
FROM FAMILIAR
WHERE empleado = '35674253N';

SELECT *
FROM ABONO_FAMILIAR
WHERE empleado = '35674253N';

-- PROCEDIMIENTOS Y FUNCIONES PL/SQL

CREATE OR REPLACE
PROCEDURE ActualizarSalarios(incremento IN NUMBER)
IS
   CURSOR c_contratos IS
      SELECT salario
      FROM CONTRATO
      FOR UPDATE;
BEGIN
   IF incremento <= 0 THEN
      RAISE_APPLICATION_ERROR(-20000, 'El incremento debe ser mayor que 0.');
   END IF;

   FOR reg_contrato IN c_contratos LOOP
      UPDATE CONTRATO
      SET salario = salario + incremento
      WHERE CURRENT OF c_contratos;
   END LOOP;

   DBMS_OUTPUT.PUT_LINE('Salarios actualizados correctamente.');
   COMMIT;
EXCEPTION
   WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('[ERROR]: ' || SQLERRM);
      ROLLBACK;
      RAISE;
END ActualizarSalarios;
/
SHOW ERRORS;

CREATE OR REPLACE
PROCEDURE RenovarAbonoIlimitado(abono_id IN NUMBER, nueva_fecha IN DATE)
IS
    -- Declaración de cursores
    CURSOR c_abono IS 
        SELECT fecha_contrato 
        FROM ABONO 
        WHERE id_abono = abono_id;

    CURSOR c_abono_ilimitado IS
        SELECT COUNT(*) AS contador
        FROM ABONO_ILIMITADO 
        WHERE id_abono = abono_id;

    -- Variables para almacenar datos de los cursores
    v_fecha_contrato DATE;
    v_contador NUMBER;
BEGIN
    IF nueva_fecha IS NULL THEN
        RAISE_APPLICATION_ERROR(-20000, 'La nueva fecha de caducidad no puede ser nula.');
    END IF;

    -- Abrir y recuperar la fecha de contrato
    OPEN c_abono;
    FETCH c_abono INTO v_fecha_contrato;

    -- Verificar si el abono existe
    IF c_abono%NOTFOUND THEN
        CLOSE c_abono;
        RAISE_APPLICATION_ERROR(-20001, 'El abono especificado no existe.');
    END IF;
    CLOSE c_abono;

    IF nueva_fecha <= v_fecha_contrato THEN
        RAISE_APPLICATION_ERROR(-20002, 'La nueva fecha de caducidad debe ser posterior a la fecha de contrato.');
    END IF;

    -- Verificar si es un abono ilimitado
    OPEN c_abono_ilimitado;
    FETCH c_abono_ilimitado INTO v_contador;

    -- Verificar si es un abono ilimitado
    IF v_contador = 0 THEN
        CLOSE c_abono_ilimitado;
        RAISE_APPLICATION_ERROR(-20003, 'El abono especificado no es ilimitado.');
    END IF;
    CLOSE c_abono_ilimitado;

    -- Actualizar la fecha de caducidad
    UPDATE ABONO
    SET fecha_caducidad = nueva_fecha
    WHERE id_abono = abono_id;

    -- Verificar que la actualización se realizó
    IF SQL%ROWCOUNT = 0 THEN
        RAISE_APPLICATION_ERROR(-20004, 'No se pudo actualizar la fecha de caducidad.');
    END IF;

    -- Confirmar la transacción
    DBMS_OUTPUT.PUT_LINE('Abono ilimitado renovado correctamente.');
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('[ERROR]: ' || SQLERRM);
        ROLLBACK;
        RAISE;
END RenovarAbonoIlimitado;
/
SHOW ERRORS;

-- Función que comprueba si una Persona es de tipo Empleado.
CREATE OR REPLACE PROCEDURE EsEmpleado(dniPersona IN VARCHAR)
IS
    -- Variable para almacenar el DNI
    dniPer Persona.dni%TYPE;
    
    -- cursor para ver existe en la tabla Persona
    CURSOR c_persona IS
        SELECT dni
        FROM Persona
        WHERE dni = dniPersona;
    
    -- cursor para ver si existe en la tabla Empleado
    CURSOR c_Empleado IS
        SELECT dni
        FROM Empleado
        WHERE dni = dniPersona;
    
    -- Excepción personalizada
    personaNoExisteException EXCEPTION;
    PRAGMA EXCEPTION_INIT(personaNoExisteException, -20001);
    
BEGIN
    -- Usamos el cursor para ver si DNI esta en Persona
    OPEN c_persona;
    FETCH c_persona INTO dniPer;

    IF c_persona%FOUND THEN
        -- Si se encuentra
        OPEN c_Empleado;
        FETCH c_Empleado INTO dniPer;
        
        IF c_Empleado%FOUND THEN
            -- Si encontramos el DNI en ambas tablas
            DBMS_OUTPUT.PUT_LINE( dniPersona || ' es un Empleado.');
            CLOSE c_Empleado;
            CLOSE c_persona;
        ELSE
            -- Si no se encuentra en Empleado
            DBMS_OUTPUT.PUT_LINE( dniPersona || ' NO es un Empleado.');
            CLOSE c_Empleado;
            CLOSE c_persona;
        END IF;
    ELSE
        -- Si no se encuentra el DNI en Persona
        CLOSE c_persona;
        RAISE_APPLICATION_ERROR(-20001, 'Esa persona NO existe.');
    END IF;
    
END;
/
SHOW ERRORS;

CREATE OR REPLACE PROCEDURE ObtenerConductoresMasViajes(num_viajes IN NUMBER)
IS
    regCond CONDUCTOR%ROWTYPE;
    NO_CONDUCTORES_EXCEPTION EXCEPTION;
    conductoresCount NUMBER;

    CURSOR c_cond IS
        SELECT c.dni, c.num_licencia
            FROM CONDUCTOR c
            WHERE c.dni IN (
                SELECT conductor
                FROM VIAJE
                GROUP BY conductor
                HAVING COUNT(*) > num_viajes
            );
BEGIN
    IF num_viajes < 0 THEN
        RAISE_APPLICATION_ERROR(-20000, 'El numero de viajes no puede ser negativo');
    END IF;

    OPEN c_cond;
    DBMS_OUTPUT.PUT_LINE('Lista de conductores con mas de '|| num_viajes || ' viajes');
    LOOP
        FETCH c_cond INTO regCond;
        EXIT WHEN c_cond%NOTFOUND;
        DBMS_OUTPUT.PUT('DNI: ' || regCond.dni || '. Licencia: ' || regCond.num_licencia);
        DBMS_OUTPUT.PUT_LINE('');
    END LOOP;

    conductoresCount := c_cond%ROWCOUNT;
    IF(conductoresCount = 0) THEN
        RAISE NO_CONDUCTORES_EXCEPTION;
    END IF;
    CLOSE c_cond;

EXCEPTION
    WHEN NO_CONDUCTORES_EXCEPTION THEN
        CLOSE c_cond;
        RAISE_APPLICATION_ERROR(-20001, 'No hay conductores con mas de ' || num_viajes || ' viajes.');
    WHEN OTHERS THEN
        CLOSE c_cond;
        RAISE_APPLICATION_ERROR(-20002, 'Error desconocido: ' || SQLERRM);
    
END ObtenerConductoresMasViajes;
/
SHOW ERRORS;

CREATE OR REPLACE FUNCTION TotalAbonosVendidos
    RETURN NUMBER
    IS
    CURSOR c_abonos IS
        SELECT abonos_vendidos
        FROM EMPLEADO_ESTACION;

    totalAbonos NUMBER := 0;
    v_abono NUMBER;
BEGIN
    -- Abrir y recorrer el cursor
    OPEN c_abonos;
    LOOP
        FETCH c_abonos INTO v_abono;
        EXIT WHEN c_abonos%NOTFOUND; -- Salir cuando no haya más filas
    
        totalAbonos := totalAbonos + NVL(v_abono, 0); -- Sumar cada abono al total
    END LOOP;
    
    CLOSE c_abonos;
    
    RETURN totalAbonos;
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20002, 'Error desconocido: ' || SQLERRM);
        
END TotalAbonosVendidos;
/
SHOW ERRORS;

-- Detalles de la ruta de una línea de un bus urbano
CREATE OR REPLACE FUNCTION DetallesLineaAutobusUrbano(nlinea IN NUMBER)
    RETURN VARCHAR2
IS
    CURSOR c_paradas IS
        SELECT p.direccion
        FROM PARADA p
        JOIN LINEAS_PARADAS lp ON p.cod_parada = lp.parada
        WHERE lp.linea = nlinea
        ORDER BY lp.orden;

    CURSOR c_linea IS
        SELECT descripcion
        FROM LINEA
        WHERE num_linea = nlinea;

    v_parada VARCHAR2(400);
    line_description VARCHAR2(40);

    ruta VARCHAR2(4000) := 'Paradas de la línea ' || nlinea;
BEGIN

    OPEN c_linea;
    FETCH c_linea INTO line_description;
    CLOSE c_linea;

    ruta := ruta || ' (' || line_description || '): ';

    OPEN c_paradas;
    LOOP
        FETCH c_paradas INTO v_parada;
        EXIT WHEN c_paradas%NOTFOUND;

        ruta := ruta || v_parada || ', ';
    END LOOP;

    CLOSE c_paradas;

    RETURN SUBSTR(ruta, 1, LENGTH(ruta) - 2); -- Eliminar la última coma y espacio
END DetallesLineaAutobusUrbano;
/
SHOW ERRORS;

/********************************************************/
/* 9.- Bloque para prueba de Procedimientos y Funciones */
/********************************************************/

DECLARE
    totalAbonos NUMBER;
    lineaDetalles VARCHAR2(4000);
BEGIN
    DBMS_OUTPUT.NEW_LINE;
    DBMS_OUTPUT.PUT_LINE('==== Pruebas de Procedimientos y Funciones ====');
    DBMS_OUTPUT.NEW_LINE;

    -- Actualizar Salarios
    BEGIN
        DBMS_OUTPUT.PUT_LINE('==== Ejecutando ActualizarSalarios ====');
        ActualizarSalarios(100); -- Incremento de 100
        DBMS_OUTPUT.PUT_LINE('Salarios actualizados correctamente.');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('[EXCEPTION]');
            DBMS_OUTPUT.PUT_LINE('[CODE]: ' || SQLCODE);
            DBMS_OUTPUT.PUT_LINE('[MESSAGE]: ' || SQLERRM);
   END;

    -- Actualizar Abono Ilimitado
    BEGIN
        DBMS_OUTPUT.NEW_LINE;
        DBMS_OUTPUT.PUT_LINE('==== Ejecutando RenovarAbonoIlimitado ====');
        RenovarAbonoIlimitado(5, TO_DATE('31/12/2030', 'DD/MM/YYYY')); -- Nueva fecha de caducidad
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('[EXCEPTION]');
            DBMS_OUTPUT.PUT_LINE('[CODE]: ' || SQLCODE);
            DBMS_OUTPUT.PUT_LINE('[MESSAGE]: ' || SQLERRM);
    END;

    -- Comprobar si una persona es empleado
    BEGIN
        DBMS_OUTPUT.NEW_LINE;
        DBMS_OUTPUT.PUT_LINE('==== Ejecutando EsEmpleado ====');
        esEmpleado('46813937H');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('[EXCEPTION]');
            DBMS_OUTPUT.PUT_LINE('[CODE]: ' || SQLCODE);
            DBMS_OUTPUT.PUT_LINE('[MESSAGE]: ' || SQLERRM);
    END;

    -- Obtener conductores con minimo de viajes
    BEGIN
        DBMS_OUTPUT.NEW_LINE;
        DBMS_OUTPUT.PUT_LINE('==== Ejecutando ObtenerConductoresMasViajes ====');
        obtenerConductoresMasViajes(0);
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('[EXCEPTION]');
            DBMS_OUTPUT.PUT_LINE('[CODE]: ' || SQLCODE);
            DBMS_OUTPUT.PUT_LINE('[MESSAGE]: ' || SQLERRM);
    END;

    -- Total de abonos vendidos
    BEGIN
        DBMS_OUTPUT.NEW_LINE;
        DBMS_OUTPUT.PUT_LINE('==== Ejecutando TotalAbonosVendidos ====');
        totalAbonos := TotalAbonosVendidos; -- Asignar el valor retornado
        DBMS_OUTPUT.PUT_LINE('Total de abonos vendidos: ' || totalAbonos);
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('[EXCEPTION]');
            DBMS_OUTPUT.PUT_LINE('[CODE]: ' || SQLCODE);
            DBMS_OUTPUT.PUT_LINE('[MESSAGE]: ' || SQLERRM);
    END;

    -- Detalles de la  línea de un bus urbano
    BEGIN
        DBMS_OUTPUT.NEW_LINE;
        DBMS_OUTPUT.PUT_LINE('==== Ejecutando DetallesLineaAutobusUrbano ====');
        lineaDetalles := DetallesLineaAutobusUrbano(2); -- Línea 1
        DBMS_OUTPUT.PUT_LINE(lineaDetalles);
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('[EXCEPTION]');
            DBMS_OUTPUT.PUT_LINE('[CODE]: ' || SQLCODE);
            DBMS_OUTPUT.PUT_LINE('[MESSAGE]: ' || SQLERRM);
    END;

END;
/
