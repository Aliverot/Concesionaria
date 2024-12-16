-------------1 Creacion de tablas-----------------------

-- Set schema
create schema auto authorization postgres;
set search_path to auto;

-- Tabla para empleados
CREATE TABLE empleados (
    id SERIAL PRIMARY KEY,                     -- Identificador único
    nombre VARCHAR(100) NOT NULL,              -- Nombre del empleado
    apellido VARCHAR(100) NOT NULL,            -- Apellido del empleado
    correo VARCHAR(100) UNIQUE NOT NULL,       -- Correo único del empleado
    telefono VARCHAR(15),                      -- Teléfono del empleado
    activo BOOLEAN DEFAULT TRUE,               -- Indica si el empleado está activo
    nombre_usuario VARCHAR(50) UNIQUE NOT NULL,-- Nombre de usuario único
    contraseña VARCHAR(100) NOT NULL           -- Contraseña del empleado
);

-- Tabla para clientes
CREATE TABLE clientes (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    correo VARCHAR(100),
    telefono VARCHAR(15),
    direccion TEXT
);

-- Tabla para coches (inventario)
CREATE TABLE coches (
    id SERIAL PRIMARY KEY,            -- Identificador único del coche
    marca VARCHAR(50) NOT NULL,       -- Marca del coche
    modelo VARCHAR(50) NOT NULL,      -- Modelo del coche
    año INT NOT NULL,                 -- Año del coche
    precio DECIMAL(10, 2) NOT NULL,   -- Precio del coche
    stock INT NOT NULL DEFAULT 0,     -- Stock disponible (por defecto 0)
    categoria VARCHAR(50) NOT NULL,   -- Categoría del coche (sin valor por defecto)
    colores VARCHAR(150)[]            -- Array de colores del coche (sin valor por defecto)
);
ALTER TABLE coches ADD COLUMN activo BOOLEAN DEFAULT TRUE;

-- Tabla para ventas
CREATE TABLE ventas (
    id SERIAL PRIMARY KEY,            -- Identificador único de la venta
    fecha DATE DEFAULT CURRENT_DATE NOT NULL,  -- Fecha de la venta (por defecto, la fecha actual)
    id_cliente INT REFERENCES clientes(id),  -- Cliente asociado a la venta (opcional)
    id_coche INT REFERENCES coches(id) NOT NULL,  -- Coche vendido (obligatorio)
    cantidad INT NOT NULL CHECK (cantidad > 0),    -- Cantidad de coches vendidos (debe ser mayor que 0)
    total DECIMAL(10, 2) NOT NULL           -- Total de la venta (precio por cantidad)
);

-- Tabla para administrador
CREATE TABLE administrador (
    id SERIAL PRIMARY KEY,                     -- Identificador único
    nombre VARCHAR(100) NOT NULL,              -- Nombre del administrador
    apellido VARCHAR(100) NOT NULL,            -- Apellido del administrador
    correo VARCHAR(100) UNIQUE NOT NULL,       -- Correo único del administrador
    telefono VARCHAR(15),                      -- Teléfono del administrador
    activo BOOLEAN DEFAULT TRUE,               -- Indica si el administrador está activo
    nombre_usuario VARCHAR(50) UNIQUE NOT NULL,-- Nombre de usuario único
    contraseña VARCHAR(100) NOT NULL           -- Contraseña del administrador
);
-- Tabla para coches_detalle
CREATE TABLE coches_detalle (
    id SERIAL PRIMARY KEY,              -- Identificador único
    nombreCoche VARCHAR(100) NOT NULL,  -- Nombre del coche
    caracteristicas TEXT,               -- Características del coche
    descripcion TEXT,                   -- Descripción del coche
    precio DECIMAL(10, 2) NOT NULL,      -- Precio del coche
    imagen TEXT                        -- Ruta de la imagen    
);

CREATE TABLE inicio_datos (
    id SERIAL PRIMARY KEY,
    imagen1 TEXT,
    imagen2 TEXT,
    imagen3 TEXT,
    imagen4 TEXT,
    descripcion1 TEXT,
    descripcion2 TEXT,
    descripcion3 TEXT,
    categoria1 TEXT,
    categoria2 TEXT,
    categoria3 TEXT
);
ALTER TABLE inicio_datos ADD CONSTRAINT unique_id UNIQUE (id);

------------------------------2 Roles y usuarios--------------------------------

-- Crear rol de administrador
CREATE ROLE administrador
NOSUPERUSER
NOCREATEDB
NOCREATEROLE
INHERIT;

-- Crear rol de empleado
CREATE ROLE empleado
NOSUPERUSER
NOCREATEDB
NOCREATEROLE
INHERIT;
-- Crear un usuario público
CREATE USER public_user WITH PASSWORD 'public_password';

----------------------------------3 asignacion de roles y permisos------------------------------------
-- Asignar permisos en la base de datos y esquema
GRANT CONNECT ON DATABASE proyecto TO public_user;
GRANT USAGE ON SCHEMA auto TO public_user;

-- Asignar permisos de acceso a tablas
GRANT SELECT ON ALL TABLES IN SCHEMA auto TO public_user;
GRANT INSERT ON clientes TO public_user;
GRANT INSERT ON ventas TO public_user;
GRANT UPDATE, DELETE ON coches TO public_user;
GRANT SELECT ON inicio_datos TO public_user;

-- Asignar permisos en secuencias
GRANT USAGE, SELECT ON SEQUENCE clientes_id_seq TO public_user;
GRANT USAGE, SELECT ON SEQUENCE ventas_id_seq TO public_user;

-- Permitir a los administradores acceso total a todas las tablas y secuencias
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA auto TO administrador;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA auto TO administrador;

-- Permitir a los empleados acceso limitado a las tablas
GRANT SELECT, INSERT, UPDATE ON auto.empleados TO empleado;
GRANT SELECT, INSERT, UPDATE ON auto.coches TO empleado;
GRANT SELECT, INSERT ON auto.ventas TO empleado;
GRANT SELECT, INSERT ON auto.clientes TO empleado;
GRANT SELECT, INSERT, UPDATE ON auto.coches_detalle TO empleado;
GRANT SELECT, UPDATE ON inicio_datos TO empleado;


-- Modificar los roles para que puedan crear otros roles
ALTER ROLE administrador CREATEROLE;


-- Configurar el esquema de búsqueda de los roles
GRANT USAGE ON SCHEMA auto TO administrador;
GRANT USAGE ON SCHEMA auto TO empleado;

ALTER ROLE administrador SET search_path TO auto;
ALTER ROLE empleado SET search_path TO auto;

-- Permisos para secuencias
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA auto TO administrador;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA auto TO empleado;

-- Configurar herencia de roles
ALTER ROLE administrador1 INHERIT;


----Crear un primer usuario de administrador
CREATE USER administrador1
PASSWORD '123456' 
NOSUPERUSER
LOGIN;
-- Asignar rol de administrador al usuario
GRANT administrador TO administrador1;

-- Modificar los roles para que puedan crear otros roles
ALTER ROLE administrador1 CREATEROLE;

ALTER ROLE administrador INHERIT;
