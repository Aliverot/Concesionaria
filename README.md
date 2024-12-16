# Concesionaria
Concesionaria de coches conectada a PostgreSQL
Descripción General del Proyecto
Este proyecto es un Sistema de Gestión de Concesionaria de Autos desarrollado en Java utilizando el entorno de desarrollo NetBeans y una base de datos relacional en PostgreSQL. El sistema está diseñado para ser una solución integral que permita la administración eficiente de vehículos, usuarios, clientes y ventas, ofreciendo una experiencia amigable tanto para administradores como empleados y usuarios finales.

Características Principales
Gestión de Usuarios y Roles:

Soporte para múltiples roles: Administrador, Empleado y Usuario Normal.
Validación de permisos para cada rol, asegurando accesos restringidos a las funciones correspondientes.
Inventario de Autos:

Gestión completa del inventario, incluyendo:
Agregar vehículos.
Modificar detalles (marca, modelo, precio, stock, colores, imágenes).
Consulta de vehículos disponibles y su estado (activo o inactivo).
Formateo de precios en moneda local para mayor claridad.
Catálogo de Autos:

Visualización de los vehículos con sus detalles, incluyendo imágenes, características y precios.
Filtros avanzados por categoría, rango de precios, año y nombre.
Función de selección dinámica de categorías para mejorar la experiencia del usuario.
Gestión de Ventas y Cotizaciones:

Generación de cotizaciones con envío automático por correo electrónico en formato PDF.
Registro de ventas y reducción automática de stock.
Control de disponibilidad de vehículos (desactivación automática cuando el stock es cero).
Interfaz de Usuario:

Diseño intuitivo y adaptable para facilitar la navegación.
Validaciones integradas en los campos de texto:
Restricciones para números (teléfonos, precios, años).
Formato de correo electrónico y manejo de errores en caso de envío fallido.
Soporte para la carga y visualización de imágenes asociadas a los vehículos.
Integración con PostgreSQL:

Base de datos relacional con tablas bien definidas para usuarios, coches, clientes, ventas, y detalles adicionales.
Consultas dinámicas y transacciones seguras para garantizar integridad de los datos.
Tecnologías Utilizadas
Lenguaje de Programación: Java
IDE: NetBeans
Base de Datos: PostgreSQL
Bibliotecas:
javax.mail para envío de correos electrónicos con adjuntos.
JTable para tablas dinámicas en la interfaz gráfica.
NumberFormat para formateo de precios en formato de moneda.
Casos de Uso
Administrador:

Puede agregar, modificar y eliminar usuarios, vehículos y categorías.
Gestiona la configuración general del sistema.
Empleado:

Consulta el inventario, realiza ventas y genera cotizaciones.
Actualiza datos básicos de vehículos, como disponibilidad y características.
Usuario Normal:

Visualiza el catálogo de autos con detalles completos.
Solicita cotizaciones con base en los autos de interés.
Estructura del Proyecto
Clases Principales:

InicioAdmin: Ventana principal del administrador.
InicioEmpleado: Ventana principal para empleados.
Catalogo: Vista para usuarios que muestra los coches disponibles.
DetallesCoche: Muestra detalles completos de un coche específico.
AgregarCoches y AgregarCochesDe: Permiten agregar nuevos vehículos al sistema.
Base de Datos:

Esquema diseñado con normalización adecuada.
Tablas principales: coches, coches_detalle, clientes, ventas, usuarios.
Módulos de Funcionalidad:

Gestión de usuarios.
Gestión de inventario de vehículos.
Control de ventas y cotizaciones.
Generación y envío de documentos en PDF.
