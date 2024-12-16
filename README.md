# Sistema de Gestión de Concesionaria de Autos

Este proyecto es un **Sistema de Gestión de Concesionaria de Autos** desarrollado en **Java** utilizando el entorno de desarrollo **NetBeans** y una base de datos relacional en **PostgreSQL**. El sistema está diseñado para ser una solución integral que permita la administración eficiente de vehículos, usuarios, clientes y ventas, ofreciendo una experiencia amigable tanto para administradores como empleados y usuarios finales.

---

## Características Principales
1. **Gestión de Usuarios y Roles**:
   - Soporte para múltiples roles: **Administrador**, **Empleado** y **Usuario Normal**.
   - Validación de permisos para cada rol, asegurando accesos restringidos a las funciones correspondientes.

2. **Inventario de Autos**:
   - Gestión completa del inventario, incluyendo:
     - Agregar vehículos.
     - Modificar detalles (marca, modelo, precio, stock, colores, imágenes).
     - Consulta de vehículos disponibles y su estado (activo o inactivo).
   - Formateo de precios en moneda local para mayor claridad.

3. **Catálogo de Autos**:
   - Visualización de los vehículos con sus detalles, incluyendo imágenes, características y precios.
   - Filtros avanzados por categoría, rango de precios, año y nombre.
   - Función de selección dinámica de categorías para mejorar la experiencia del usuario.

4. **Gestión de Ventas y Cotizaciones**:
   - Generación de cotizaciones con envío automático por correo electrónico en formato PDF.
   - Registro de ventas y reducción automática de stock.
   - Control de disponibilidad de vehículos (desactivación automática cuando el stock es cero).

5. **Interfaz de Usuario**:
   - Diseño intuitivo y adaptable para facilitar la navegación.
   - Validaciones integradas en los campos de texto:
     - Restricciones para números (teléfonos, precios, años).
     - Formato de correo electrónico y manejo de errores en caso de envío fallido.
   - Soporte para la carga y visualización de imágenes asociadas a los vehículos.

6. **Integración con PostgreSQL**:
   - Base de datos relacional con tablas bien definidas para usuarios, coches, clientes, ventas, y detalles adicionales.
   - Consultas dinámicas y transacciones seguras para garantizar integridad de los datos.

---

## Tecnologías Utilizadas
- **Lenguaje de Programación**: Java
- **IDE**: NetBeans
- **Base de Datos**: PostgreSQL
- **Bibliotecas**:
  - `javax.mail` para envío de correos electrónicos con adjuntos.
  - `JTable` para tablas dinámicas en la interfaz gráfica.
  - `NumberFormat` para formateo de precios en formato de moneda.
  - `iText` para la creacion de pdf.
---

## Casos de Uso
1. **Administrador**:
   - Puede agregar, modificar y eliminar usuarios, vehículos y categorías.
   - Gestiona la configuración general del sistema.

2. **Empleado**:
   - Consulta el inventario, realiza ventas y genera cotizaciones.
   - Actualiza datos básicos de vehículos, como disponibilidad y características.

3. **Usuario Normal**:
   - Visualiza el catálogo de autos con detalles completos.
   - Solicita cotizaciones con base en los autos de interés.
