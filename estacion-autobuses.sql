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

