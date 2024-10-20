DROP TABLE persona CASCADE CONSTRAINTS;
DROP TABLE telefono CASCADE CONSTRAINTS;
DROP TABLE pasajero CASCADE CONSTRAINTS;
DROP TABLE contrato CASCADE CONSTRAINTS;
DROP TABLE empleado CASCADE CONSTRAINTS;
DROP TABLE familiar CASCADE CONSTRAINTS;
DROP TABLE conductor CASCADE CONSTRAINTS;
DROP TABLE empleado_estacion CASCADE CONSTRAINTS;
DROP TABLE empresa CASCADE CONSTRAINTS;
DROP TABLE autobus CASCADE CONSTRAINTS;
DROP TABLE linea CASCADE CONSTRAINTS;
DROP TABLE autobus_urbano CASCADE CONSTRAINTS;
DROP TABLE parada CASCADE CONSTRAINTS;
DROP TABLE lineas_paradas CASCADE CONSTRAINTS;
DROP TABLE autobus_interurbano CASCADE CONSTRAINTS;
DROP TABLE ruta CASCADE CONSTRAINTS;
DROP TABLE viaje CASCADE CONSTRAINTS;
DROP TABLE servicio CASCADE CONSTRAINTS;
DROP TABLE venta_billete CASCADE CONSTRAINTS;
DROP TABLE billete CASCADE CONSTRAINTS;
DROP TABLE billete_combinado CASCADE CONSTRAINTS;
DROP TABLE alquiler_autobus CASCADE CONSTRAINTS;
DROP TABLE abono CASCADE CONSTRAINTS;
DROP TABLE venta_abono CASCADE CONSTRAINTS;
DROP TABLE abono_normal CASCADE CONSTRAINTS;
DROP TABLE abono_ilimitado CASCADE CONSTRAINTS;
DROP TABLE abono_empleado CASCADE CONSTRAINTS;
DROP TABLE abono_familiar CASCADE CONSTRAINTS;


CREATE TABLE persona(
    dni VARCHAR(9) NOT NULL CHECK (REGEXP_LIKE (dni, '^[0-9]{8}[A-Z]$')),
    nombre VARCHAR(30) NOT NULL CHECK (LENGTH (nombre) > 0),
    apellidos VARCHAR(60) NOT NULL CHECK (LENGTH (apellidos) > 0),
    fecha_nacimiento DATE NOT NULL,
    
    PRIMARY KEY(dni)
);

CREATE TABLE telefono(
    dni VARCHAR(9) NOT NULL,
    telefono VARCHAR(9) NOT NULL UNIQUE CHECK (REGEXP_LIKE (telefono, '^[0-9]{9}$')),
    
    PRIMARY KEY (dni, telefono),
    FOREIGN KEY (dni) REFERENCES persona(dni) ON DELETE CASCADE
);

CREATE TABLE pasajero(
    dni VARCHAR(9) NOT NULL,
    acompanante VARCHAR(9),
    
    PRIMARY KEY(dni),
    
    FOREIGN KEY (dni) REFERENCES persona(dni) ON DELETE CASCADE,
    FOREIGN KEY (acompanante) REFERENCES pasajero(dni) ON DELETE CASCADE --si se borra el acompa�ante tambi�n el pasajero
);

CREATE TABLE contrato(
    id_contrato NUMBER NOT NULL CHECK (id_contrato > 0),
    tipo VARCHAR(10) NOT NULL CHECK (tipo IN ('INDEFINIDO', 'TEMPORAL', 'PR�CTICAS', 'FORMACI�N')),
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE,
    horas_semana NUMBER NOT NULL CHECK (horas_semana > 0),
    salario NUMBER NOT NULL CHECK (salario > 0),
    
    PRIMARY KEY (id_contrato),
    CHECK(fecha_fin IS NULL OR fecha_fin > fecha_inicio)
);

CREATE TABLE empleado(
    dni VARCHAR(9) NOT NULL,
    contrato NUMBER NOT NULL,
    
    PRIMARY KEY (dni),
    FOREIGN KEY (dni) REFERENCES persona(dni) ON DELETE CASCADE,
    FOREIGN KEY (contrato) REFERENCES contrato(id_contrato) ON DELETE CASCADE
);

CREATE TABLE familiar(
    dni VARCHAR(9) NOT NULL CHECK (REGEXP_LIKE (dni, '^[0-9]{8}[A-Z]$')),
    empleado VARCHAR(9) NOT NULL,
    --es subclase de persona o no?
    relacion VARCHAR(20) NOT NULL CHECK (LENGTH(relacion) > 0),
    
    PRIMARY KEY(dni, empleado),
    FOREIGN KEY (empleado) REFERENCES empleado(dni) ON DELETE CASCADE
);

CREATE TABLE conductor(
    dni VARCHAR(9) NOT NULL,
    num_licencia VARCHAR(15) NOT NULL UNIQUE CHECK (LENGTH(num_licencia) > 0),
    
    PRIMARY KEY (dni),
    FOREIGN KEY(dni) REFERENCES empleado(dni) ON DELETE CASCADE
);

CREATE TABLE empleado_estacion(
    dni VARCHAR(9) NOT NULL,
    abonos_vendidos NUMBER NOT NULL CHECK (abonos_vendidos >= 0),
    
    PRIMARY KEY (dni),
    FOREIGN KEY (dni) REFERENCES empleado(dni) ON DELETE CASCADE
);

CREATE TABLE empresa(
    cif VARCHAR(9) NOT NULL CHECK (REGEXP_LIKE(cif, '^[A-Z][0-9]{7}[A-Z]$')),
    nombre VARCHAR(30) NOT NULL UNIQUE CHECK (LENGTH(nombre) > 0),
    direccion VARCHAR(60) NOT NULL CHECK (LENGTH(direccion) > 0),
    telefono VARCHAR(9) NOT NULL CHECK (REGEXP_LIKE(telefono, '^[0-9]{9}$')),
    
    PRIMARY KEY (cif)
);

CREATE TABLE autobus(
    matricula VARCHAR(7) NOT NULL CHECK (REGEXP_LIKE(matricula, '^[0-9]{4}[A-Z]{3}$')),
    num_asientos NUMBER NOT NULL CHECK  (num_asientos > 0),
    modelo VARCHAR(30) NOT NULL CHECK (LENGTH(modelo) > 0),
    fecha_itv DATE NOT NULL,
    propietario VARCHAR(9) NOT NULL,
    tipo_autobus VARCHAR(11) NOT NULL CHECK (tipo_autobus IN ('INTERURBANO', 'URBANO')),
    
    PRIMARY KEY (matricula),
    FOREIGN KEY (propietario) REFERENCES empresa(cif) ON DELETE CASCADE
);

CREATE TABLE linea(
    num_linea NUMBER NOT NULL CHECK (num_linea > 0), --puede ser varchar si es tipo '12B'
    descripcion VARCHAR(40) NOT NULL CHECK (LENGTH(descripcion) > 0),
    
    PRIMARY KEY(num_linea)
);

CREATE TABLE autobus_urbano(
    matricula VARCHAR(7) NOT NULL,
    aforo NUMBER NOT NULL CHECK (aforo > 0),
    linea NUMBER NOT NULL,
    
    PRIMARY KEY (matricula),
    FOREIGN KEY (linea) REFERENCES linea(num_linea) ON DELETE CASCADE
);

CREATE TABLE parada(
    cod_parada NUMBER NOT NULL CHECK (cod_parada > 0), --puede ser varchar tambien
    direccion VARCHAR(50) NOT NULL UNIQUE CHECK (LENGTH(direccion) > 0),
    
    PRIMARY KEY(cod_parada)
);

CREATE TABLE lineas_paradas(
    linea NUMBER NOT NULL,
    parada NUMBER NOT NULL,
    orden NUMBER NOT NULL CHECK (orden > 0),
    
    PRIMARY KEY (linea, parada),
    FOREIGN KEY (linea) REFERENCES linea(num_linea) ON DELETE CASCADE,
    FOREIGN KEY (parada) REFERENCES parada(cod_parada) ON DELETE CASCADE,
    UNIQUE (linea, orden)
);

CREATE TABLE autobus_interurbano(
    matricula VARCHAR(7) NOT NULL,
    num_plazas NUMBER NOT NULL CHECK (num_plazas > 0),
    
    PRIMARY KEY (matricula),
    FOREIGN KEY (matricula) REFERENCES autobus(matricula) ON DELETE CASCADE
);

CREATE TABLE ruta(
    id_ruta NUMBER NOT NULL CHECK (id_ruta > 0),
    origen VARCHAR(50) NOT NULL CHECK (LENGTH(origen) > 0),
    destino VARCHAR(50) NOT NULL CHECK (LENGTH(destino) > 0),
    duracion NUMBER NOT NULL CHECK (duracion > 0), --en minutos
    
    PRIMARY KEY (id_ruta)
);

CREATE TABLE viaje(
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

CREATE TABLE servicio(
    id_servicio NUMBER NOT NULL CHECK (id_servicio > 0),
    contratado_por VARCHAR(9),
    
    PRIMARY KEY (id_servicio),
    FOREIGN KEY (contratado_por) REFERENCES pasajero(dni) ON DELETE SET NULL
);

CREATE TABLE billete(
    id_billete NUMBER NOT NULL CHECK (id_billete > 0),
    viaje NUMBER NOT NULL,
    
    PRIMARY KEY (id_billete),
    FOREIGN KEY (viaje) REFERENCES viaje(id_viaje) ON DELETE CASCADE
);

CREATE TABLE venta_billete(
    id_servicio NUMBER NOT NULL,
    billete NUMBER NOT NULL,
    
    PRIMARY KEY (id_servicio),
    FOREIGN KEY (id_servicio) REFERENCES servicio(id_servicio) ON DELETE CASCADE,
    FOREIGN KEY (billete) REFERENCES billete(id_billete) ON DELETE CASCADE
);

CREATE TABLE billete_combinado(
    id_servicio NUMBER NOT NULL,
    tipo VARCHAR(20) NOT NULL CHECK(tipo IN ('BUS+TREN', 'BUS+AVION', 'BUS+FERRY')),
    billete NUMBER NOT NULL,
    
    PRIMARY KEY (id_servicio),
    FOREIGN KEY (billete) REFERENCES billete(id_billete) ON DELETE CASCADE
);
    
CREATE TABLE alquiler_autobus(
    id_servicio NUMBER NOT NULL,
    autobus VARCHAR(7) NOT NULL,
    
    PRIMARY KEY(id_servicio),
    FOREIGN KEY (id_servicio) REFERENCES servicio(id_servicio) ON DELETE CASCADE,
    FOREIGN KEY (autobus) REFERENCES autobus_interurbano(matricula) ON DELETE CASCADE
);

CREATE TABLE abono(
    id_abono NUMBER NOT NULL CHECK (id_abono > 0),
    precio NUMBER NOT NULL CHECK (precio > 0),
    fecha_contrato DATE NOT NULL,
    fecha_caducidad DATE NOT NULL,
    
    PRIMARY KEY(id_abono),
    
    CHECK(fecha_caducidad > fecha_contrato)
);

CREATE TABLE venta_abono(
    id_servicio NUMBER NOT NULL,
    abono NUMBER NOT NULL,
        
    PRIMARY KEY(id_servicio),
    FOREIGN KEY (id_servicio) REFERENCES servicio(id_servicio) ON DELETE CASCADE,
    FOREIGN KEY (abono) REFERENCES abono(id_abono) ON DELETE CASCADE
);

CREATE TABLE abono_normal(
    id_abono NUMBER NOT NULL,
    limite_viajes NUMBER NOT NULL CHECK (limite_viajes > 0),
    viajes_consumidos NUMBER NOT NULL CHECK (viajes_consumidos >= 0),
    
    PRIMARY KEY (id_abono),
    FOREIGN KEY (id_abono) REFERENCES abono(id_abono) ON DELETE CASCADE,
    
    CHECK (limite_viajes >= viajes_consumidos)
);

CREATE TABLE abono_ilimitado(
    id_abono NUMBER NOT NULL,
    
    PRIMARY KEY(id_abono),
    FOREIGN KEY (id_abono) REFERENCES abono(id_abono) ON DELETE CASCADE
);


CREATE TABLE abono_empleado(
    id_abono NUMBER NOT NULL,
    empleado VARCHAR(9) NOT NULL,
    descuento NUMBER NOT NULL CHECK (descuento BETWEEN 10 AND 60),
    
    PRIMARY KEY (id_abono),
    FOREIGN KEY (id_abono) REFERENCES abono(id_abono) ON DELETE CASCADE,
    FOREIGN KEY (empleado) REFERENCES empleado(dni) ON DELETE CASCADE
);

CREATE TABLE abono_familiar(
    id_abono NUMBER NOT NULL,
    familiar VARCHAR(9) NOT NULL,
    empleado VARCHAR(9) NOT NULL,
    descuento NUMBER NOT NULL CHECK (descuento BETWEEN 10 AND 60),
    
    PRIMARY KEY (id_abono),
    FOREIGN KEY (id_abono) REFERENCES abono(id_abono) ON DELETE CASCADE,
    FOREIGN KEY (familiar, empleado) REFERENCES familiar(dni, empleado) ON DELETE CASCADE
);

-- INSERTS

-- tabla PERSONA
INSERT INTO PERSONA(dni, nombre, apellidos, fecha_nacimiento ) VALUES('35225389S', 'Pepe', 'González', TO_DATE('10/02/1995','DD/MM/YYYY'));
INSERT INTO PERSONA(dni, nombre, apellidos, fecha_nacimiento ) VALUES('59643874T', 'Lucas', 'Etxebarri', TO_DATE('23/05/2000','DD/MM/YYYY'));
INSERT INTO PERSONA(dni, nombre, apellidos, fecha_nacimiento ) VALUES('25647312F', 'María', 'Gutiérrez', TO_DATE('02/12/2004','DD/MM/YYYY'));
INSERT INTO PERSONA(dni, nombre, apellidos, fecha_nacimiento ) VALUES('35674242X', 'Carmen', 'Vázquez', TO_DATE('1980/01/30','YYYY/MM/DD'));
INSERT INTO PERSONA(dni, nombre, apellidos, fecha_nacimiento ) VALUES('35749531Z', 'Daniela', 'González', TO_DATE('22/08/2022','DD/MM/YYYY'));
INSERT INTO PERSONA(dni, nombre, apellidos, fecha_nacimiento ) VALUES('35674253N', 'Diego', 'Barja', TO_DATE('14/01/1998','DD/MM/YYYY'));
INSERT INTO PERSONA(dni, nombre, apellidos, fecha_nacimiento ) VALUES('46813937H', 'Alba', 'Cid', TO_DATE('1976/10/05','YYYY/MM/DD'));
INSERT INTO PERSONA(dni, nombre, apellidos, fecha_nacimiento ) VALUES('82082351Y', 'Alfredo', 'Díaz', TO_DATE('20/03/1970','DD/MM/YYYY'));
INSERT INTO PERSONA(dni, nombre, apellidos, fecha_nacimiento ) VALUES('35537699R', 'Rosa', 'Prado', TO_DATE('24/04/1965','DD/MM/YYYY'));


-- tabla PASAJERO
INSERT INTO PASAJERO(dni) VALUES('35225389S');
INSERT INTO PASAJERO(dni) VALUES('59643874T');
INSERT INTO PASAJERO(dni) VALUES('25647312F');
INSERT INTO PASAJERO(dni) VALUES('35674242X');
INSERT INTO PASAJERO(dni, acompanante) VALUES('35749531Z');


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

-- tabla CONDUCTOR

INSERT INTO CONDUCTOR (dni, num_licencia) VALUES ('35674253N', '22301');
INSERT INTO CONDUCTOR (dni, num_licencia) VALUES ('82082351Y', '22536');
INSERT INTO CONDUCTOR (dni, num_licencia) VALUES ('35537699R', '22456');

-- tabla ADMINISTRATIVO 

INSERT INTO ADMINISTRATIVO (dni, abonos_vendidos) VALUES ('46813937H', '25');

-- tabla EMPRESA

INSERT INTO EMPRESA (cif, nombre, direccion, telefono) VALUES ('B2322468R', 'BUSDII', 'AVENIDA OTERO PEDRAYO', '926434765');
INSERT INTO EMPRESA (cif, nombre, direccion, telefono) VALUES ('P2353389X', 'RUTADIRECTA', 'RÚA DO PROGRESO', '957875323');

-- tabla AUTOBUS

INSERT INTO AUTOBUS (matricula, num_asientos, modelo, fecha_itv, propietario, tipo_autobus) VALUES ('5624 SQL', '30', 'Iveco Citelis', TO_DATE('21/08/2024', 'DD/MM/YYYY'), 'B2322468R', 'URBANO');
INSERT INTO AUTOBUS (matricula, num_asientos, modelo, fecha_itv, propietario, tipo_autobus) VALUES ('2024 BRR', '30', 'Iveco Citelis', TO_DATE('01/05/2024', 'DD/MM/YYYY'), 'B2322468R', 'URBANO');
INSERT INTO AUTOBUS (matricula, num_asientos, modelo, fecha_itv, propietario, tipo_autobus) VALUES ('8644 NMO', '45', 'Iveco Citelis Articulado', TO_DATE('28/04/2024', 'DD/MM/YYYY'), 'B2322468R', 'URBANO');
INSERT INTO AUTOBUS (matricula, num_asientos, modelo, fecha_itv, propietario, tipo_autobus) VALUES ('9191 SOL', '45', 'Iveco Citelis Articulado', TO_DATE('15/11/2023', 'DD/MM/YYYY'), 'B2322468R', 'URBANO');
INSERT INTO AUTOBUS (matricula, num_asientos, modelo, fecha_itv, propietario, tipo_autobus) VALUES ('2234 KFC', '60', 'Iveco Citelis', TO_DATE('30/09/2024', 'DD/MM/YYYY'), 'B2322468R', 'INTERURBANO');
INSERT INTO AUTOBUS (matricula, num_asientos, modelo, fecha_itv, propietario, tipo_autobus) VALUES ('6754 BDI', '75', 'Mercedes Benz O-405 G', TO_DATE('10/10/2024', 'DD/MM/YYYY'), 'P2353389X', 'INTERURBANO');
INSERT INTO AUTOBUS (matricula, num_asientos, modelo, fecha_itv, propietario, tipo_autobus) VALUES ('3223 BUS', '40', 'Mercedes Benz O-405 N2', TO_DATE('14/12/2023', 'DD/MM/YYYY'), 'P2353389X', 'URBANO');
INSERT INTO AUTOBUS (matricula, num_asientos, modelo, fecha_itv, propietario, tipo_autobus) VALUES ('3060 RTX', '40', 'Mercedes Benz O-405 N2', TO_DATE('24/12/2023', 'DD/MM/YYYY'), 'P2353389X', 'URBANO');
INSERT INTO AUTOBUS (matricula, num_asientos, modelo, fecha_itv, propietario, tipo_autobus) VALUES ('4455 USB', '40', 'Mercedes Benz O-405 N2', TO_DATE('14/10/2024', 'DD/MM/YYYY'), 'P2353389X', 'URBANO');

-- tabla LINEA

INSERT INTO LINEA (num_linea, descripcion) VALUES ('1', '');
INSERT INTO LINEA (num_linea, descripcion) VALUES ('2', '');
INSERT INTO LINEA (num_linea, descripcion) VALUES ('3', '');
INSERT INTO LINEA (num_linea, descripcion) VALUES ('4', '');
INSERT INTO LINEA (num_linea, descripcion) VALUES ('5', '');
INSERT INTO LINEA (num_linea, descripcion) VALUES ('6', '');

-- tabla AUTOBUS_URBANO

INSERT INTO AUTOBUS_URBANO (matricula, aforo, linea) VALUES ('5624 SQL', '40', '1');
INSERT INTO AUTOBUS_URBANO (matricula, aforo, linea) VALUES ('2024 BRR', '40', '3');
INSERT INTO AUTOBUS_URBANO (matricula, aforo, linea) VALUES ('8644 NMO', '55', '2');
INSERT INTO AUTOBUS_URBANO (matricula, aforo, linea) VALUES ('9191 SOL', '55', '4');
INSERT INTO AUTOBUS_URBANO (matricula, aforo, linea) VALUES ('3223 BUS', '50', '1');
INSERT INTO AUTOBUS_URBANO (matricula, aforo, linea) VALUES ('3060 RTX', '50', '5');
INSERT INTO AUTOBUS_URBANO (matricula, aforo, linea) VALUES ('4455 USB', '50', '6');


-- tabla PARADA

INSERT INTO PARADA (cod_parada, direccion) VALUES ('1', 'RÚA CURROS ENRIQUEZ');
INSERT INTO PARADA (cod_parada, direccion) VALUES ('2', 'AVENIDA DE MARIN');
INSERT INTO PARADA (cod_parada, direccion) VALUES ('3', 'PARQUE DE SAN LAZARO');
INSERT INTO PARADA (cod_parada, direccion) VALUES ('4', 'XARDIN DO POSIO');
INSERT INTO PARADA (cod_parada, direccion) VALUES ('5', 'AVENIDA DE SANTIAGO');

-- tabla LINEAS_PARADAS

INSERT INTO LINEAS_PARADAS (linea, parada, orden) VALUES ('1', '2', '1');
INSERT INTO LINEAS_PARADAS (linea, parada, orden) VALUES ('1', '1', '2');
INSERT INTO LINEAS_PARADAS (linea, parada, orden) VALUES ('1', '3', '3');

INSERT INTO LINEAS_PARADAS (linea, parada, orden) VALUES ('2', '3', '1');
INSERT INTO LINEAS_PARADAS (linea, parada, orden) VALUES ('2', '1', '2');
INSERT INTO LINEAS_PARADAS (linea, parada, orden) VALUES ('2', '2', '3');

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

INSERT INTO AUTOBUS_INTERURBANO (matricula, num_plazas) VALUES ('2234 KFC', '60');
INSERT INTO AUTOBUS_INTERURBANO (matricula, num_plazas) VALUES ('6754 BDI', '75');

-- tabla RUTA

INSERT INTO RUTA (id_ruta, origen, destino, duracion) VALUES ('1', 'OURENSE', 'SANTIAGO', '120');
INSERT INTO RUTA (id_ruta, origen, destino, duracion) VALUES ('2', 'OURENSE', 'VIGO', '90');

-- tabla VIAJE

INSERT INTO VIAJE (id_viaje, fecha, ruta, conductor, autbous) VALUES ();

