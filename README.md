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
  
## Explicación de la Clase `Conexion`

La clase `Conexion` contiene el método `validarUsuario`, que se encarga de verificar si un usuario existe en la base de datos PostgreSQL y validar sus credenciales. Si el usuario es encontrado, se obtiene su rol y se valida la contraseña. Si la contraseña es correcta, se devuelve el rol del usuario. En caso contrario, se devuelve `null`.

### Descripción del flujo:
1. **Consulta de Usuario:** Realiza una consulta SQL para obtener el rol del usuario desde la tabla `pg_roles` en PostgreSQL, utilizando la relación con `pg_auth_members`.
2. **Validación de Contraseña:** Si el usuario existe, se establece una nueva conexión usando las credenciales proporcionadas (nombre de usuario y contraseña).
3. **Devolución del Rol:** Si la contraseña es correcta, se devuelve el rol del usuario.
4. **Manejo de Errores:** Si ocurre algún error en la consulta o la conexión, se captura y se imprime el error, devolviendo `null`.

### Código

```java
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class Conexion {

    public String validarUsuario(String nombreUsuario, String contraseña) {
        String sql = "SELECT r.rolname AS rol " +
                     "FROM pg_roles r " +
                     "JOIN pg_auth_members m ON r.oid = m.roleid " +
                     "JOIN pg_roles u ON u.oid = m.member " +
                     "WHERE u.rolname = ?;";

        try (Connection conn = ConexionBD.getConnection("postgres", "123456");
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, nombreUsuario);
            ResultSet rs = pstmt.executeQuery();

            if (rs.next()) {
                // Validar conexión con las credenciales del usuario
                try (Connection userConn = ConexionBD.getConnection(nombreUsuario, contraseña)) {
                    String rol = rs.getString("rol");
                    return rol; // Devuelve el rol del usuario si las credenciales son correctas
                } catch (SQLException e) {
                    return null; // Contraseña incorrecta
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null; // Usuario no encontrado o error en la consulta
    }
}
```

## Explicación de la Clase `ConexionBD`

La clase `ConexionBD` gestiona las conexiones a una base de datos PostgreSQL, proporcionando distintos métodos para obtener una conexión dependiendo del usuario y sus credenciales.

### Descripción de los métodos:
1. **`getConnection(String username, String password)`**:
   - Establece una conexión con la base de datos utilizando el nombre de usuario y la contraseña proporcionados.
   - Retorna una conexión establecida con esos credenciales.

2. **`getConnection()`**:
   - Este método obtiene la conexión utilizando las credenciales del usuario almacenadas en la clase `Sesion`.
   - Si las credenciales no están disponibles (es decir, `username` o `password` son `null`), se obtiene una conexión con un usuario público, es decir, con permisos limitados de solo lectura.

3. **`getPublicConnection()`**:
   - Establece una conexión utilizando un usuario público con permisos limitados (solo lectura).
   - Es útil cuando se requiere acceso a la base de datos sin privilegios de escritura o administración.

### Código

```java
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class ConexionBD {

    // Asegúrate de incluir el esquema por defecto aquí
    private static final String URL = "jdbc:postgresql://localhost:5432/proyecto?currentSchema=auto";

    // Método para obtener la conexión con credenciales proporcionadas
    public static Connection getConnection(String username, String password) throws SQLException {
        return DriverManager.getConnection(URL, username, password);
    }

    // Método para obtener la conexión con credenciales del usuario de sesión
    public static Connection getConnection() throws SQLException {
        String username = Sesion.getUsuario();
        String password = Sesion.getContra();
        if (username == null || password == null) {
            return getPublicConnection(); // Si no hay credenciales, obtener conexión pública
        }
        return DriverManager.getConnection(URL, username, password); // Conexión con credenciales de usuario
    }

    // Método para obtener la conexión de solo lectura (usuario público)
    public static Connection getPublicConnection() throws SQLException {
        String publicUser = "public_user";  // Usuario con permisos de solo lectura
        String publicPassword = "public_password"; // Contraseña de solo lectura
        return DriverManager.getConnection(URL, publicUser, publicPassword);
    }
}
```

### Notas:
- **URL de conexión**: La URL de conexión especifica la base de datos `proyecto` en el servidor `localhost` con el esquema predeterminado `auto`. Es importante asegurarse de que este esquema esté configurado correctamente en PostgreSQL.
- **Usuario público**: La conexión pública se realiza con el usuario `public_user` y la contraseña `public_password`, lo que permite acceder a la base de datos con permisos limitados.
- **Manejo de credenciales**: Si el nombre de usuario y la contraseña no están disponibles, se recurre a la conexión pública con permisos de solo lectura. Esto puede ser útil en casos de acceso a datos sin la necesidad de privilegios de escritura.

## Explicación de la Clase `Sesion`

La clase `Sesion` gestiona la información relacionada con la sesión actual del usuario en la aplicación, incluyendo el nombre de usuario, la contraseña y el rol. Esta clase almacena estos datos de forma estática para que estén disponibles globalmente en el programa, y permite acceder a ellos a través de métodos estáticos.

### Descripción de los métodos:
1. **`iniciarSesion(String usuario, String contra, String rol)`**:
   - Este método recibe como parámetros el nombre de usuario, la contraseña y el rol del usuario, y los almacena en las variables estáticas correspondientes para gestionar la sesión.
   - Se usa para iniciar una nueva sesión de usuario.

2. **`getUsuario()`**:
   - Retorna el nombre de usuario almacenado en la sesión.
   
3. **`getContra()`**:
   - Retorna la contraseña almacenada en la sesión.

4. **`getRol()`**:
   - Retorna el rol del usuario (por ejemplo, "administrador" o "empleado") almacenado en la sesión.

5. **`cerrarSesion()`**:
   - Limpia las variables estáticas (usuario, contraseña, rol), cerrando efectivamente la sesión y evitando que se mantengan accesibles los datos después de que el usuario cierre la sesión.

### Código

```java
public class Sesion {
    private static String usuario;
    private static String contra;
    private static String rol;     // Rol del usuario (administrador o empleado)

    // Inicia sesión guardando el usuario, contraseña y rol
    public static void iniciarSesion(String usuario, String contra, String rol) {
        Sesion.usuario = usuario;
        Sesion.contra = contra;
        Sesion.rol = rol;
    }

    // Retorna el nombre de usuario
    public static String getUsuario() {
        return usuario;
    }

    // Retorna la contraseña
    public static String getContra() {
        return contra;
    }
    
    // Retorna el rol del usuario
    public static String getRol() {
        return rol;
    }

    // Cierra sesión limpiando los datos almacenados
    public static void cerrarSesion() {
        Sesion.usuario = null;
        Sesion.contra = null;
        Sesion.rol = null;
    }
}
```



