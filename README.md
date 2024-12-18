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
  
## Requisitos 
- Este proyecto usa postgreSQL en su version 9.4 la dependencia ya esta cargada dentro del proyecto pero esta verion es recomendable tener para evitar posibles errores.
- Se requiere crear un usuario administrador previamente en la base de datos para poder acceder a las funcionalidades del proyecto.
  ![image](https://github.com/user-attachments/assets/23c141dd-ea2b-4161-ae14-72c456bfa777)
-En la clase Conexion cambia segun tu base de datos
  ![image](https://github.com/user-attachments/assets/f152e4b4-4bdb-4fac-966e-d79607125831)

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

# Clases Auxiliares para la Realización del Proyecto

Este repositorio incluye diversas clases auxiliares que facilitan la implementación y el funcionamiento del proyecto. A continuación, se describen las clases disponibles y su funcionalidad.

---

## AgregarEmpleadosSQL

Clase encargada de gestionar operaciones relacionadas con empleados y usuarios en la base de datos.

### Métodos principales:
- **`insertarEmpleado`**:  
  Inserta un empleado o administrador en la base de datos. Determina automáticamente la tabla según el rol.
  
- **`crearUsuario`**:  
  Crea un usuario en PostgreSQL, asigna permisos y roles, y otorga privilegios adicionales si el rol es de administrador.

### Código:
```java
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.Statement;

public class AgregarEmpleadosSQL {

    public void insertarEmpleado(Connection connection, String nombre, String apellido, String correo, String telefono, String nombreUsuario, String contraseña, String rol) throws SQLException {
        String tabla = rol.equals("administrador") ? "auto.administrador" : "auto.empleados";
        String sql = "INSERT INTO " + tabla + " (nombre, apellido, correo, telefono, nombre_usuario, contraseña) VALUES (?, ?, ?, ?, ?, ?)";

        try (PreparedStatement pstmt = connection.prepareStatement(sql)) {
            pstmt.setString(1, nombre);
            pstmt.setString(2, apellido);
            pstmt.setString(3, correo);
            pstmt.setString(4, telefono);
            pstmt.setString(5, nombreUsuario);
            pstmt.setString(6, contraseña);
            pstmt.executeUpdate();
        }
    }

    public void crearUsuario(Connection connection, String nombreUsuario, String contraseña, String rol) throws SQLException {
        String sqlCrearUsuario = "CREATE USER " + nombreUsuario + " PASSWORD '" + contraseña + "' NOSUPERUSER LOGIN INHERIT";
        try (Statement stmt = connection.createStatement()) {
            stmt.executeUpdate(sqlCrearUsuario);
        }

        String sqlAsignarRol = "GRANT " + rol + " TO " + nombreUsuario;
        try (Statement stmt = connection.createStatement()) {
            stmt.executeUpdate(sqlAsignarRol);
        }

        if ("administrador".equalsIgnoreCase(rol)) {
            String sqlCrearole = "ALTER ROLE " + nombreUsuario + " WITH CREATEROLE";
            try (Statement stmt = connection.createStatement()) {
                stmt.executeUpdate(sqlCrearole);
            }
        }
    }
}
```

---

## CocheDetalle

Clase que encapsula los detalles de un coche, incluyendo atributos como nombre, características, descripción, precio e imagen.

### Atributos principales:
- **`nombreCoche`**: Nombre del coche.  
- **`caracteristicas`**: Características del vehículo.  
- **`descripcion`**: Breve descripción del coche.  
- **`precio`**: Precio del coche.  
- **`imagen`**: Imagen del coche en formato `ImageIcon`.

### Código:
```java
import javax.swing.ImageIcon;

public class CocheDetalle {
    private String nombreCoche;
    private String caracteristicas;
    private String descripcion;
    private double precio;
    private ImageIcon imagen;

    public String getNombreCoche() { return nombreCoche; }
    public void setNombreCoche(String nombreCoche) { this.nombreCoche = nombreCoche; }
    public String getCaracteristicas() { return caracteristicas; }
    public void setCaracteristicas(String caracteristicas) { this.caracteristicas = caracteristicas; }
    public String getDescripcion() { return descripcion; }
    public void setDescripcion(String descripcion) { this.descripcion = descripcion; }
    public double getPrecio() { return precio; }
    public void setPrecio(double precio) { this.precio = precio; }
    public ImageIcon getImagen() { return imagen; }
    public void setImagen(ImageIcon imagen) { this.imagen = imagen; }
}
```

---

## CocheDetalleC

Clase que obtiene información detallada sobre coches desde la base de datos.

### Métodos principales:
- **`obtenerDetalleCoche`**:  
  Recupera los detalles de un coche específico, incluyendo la imagen escalada.  

- **`obtenerColoresCoche`**:  
  Obtiene los colores disponibles de un coche.  

- **`obtenerStockCoche`**:  
  Recupera el stock disponible de un coche específico.  

### Código:
```java
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import javax.swing.ImageIcon;
import java.awt.Image;
import java.util.List;
import java.util.ArrayList;

public class CocheDetalleC {
    public static CocheDetalle obtenerDetalleCoche(String nombreCoche) throws SQLException {
        String sql = "SELECT imagen, nombreCoche, caracteristicas, descripcion, precio FROM coches_detalle WHERE nombreCoche = ?";
        try (Connection conn = ConexionBD.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, nombreCoche);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    CocheDetalle detalle = new CocheDetalle();
                    detalle.setNombreCoche(rs.getString("nombreCoche"));
                    detalle.setCaracteristicas(rs.getString("caracteristicas"));
                    detalle.setDescripcion(rs.getString("descripcion"));
                    detalle.setPrecio(rs.getDouble("precio"));

                    String rutaImagen = rs.getString("imagen");
                    if (rutaImagen != null && !rutaImagen.isEmpty()) {
                        ImageIcon originalIcon = new ImageIcon(rutaImagen);
                        Image imagenEscalada = originalIcon.getImage().getScaledInstance(400, 250, Image.SCALE_SMOOTH);
                        detalle.setImagen(new ImageIcon(imagenEscalada));
                    }

                    return detalle;
                }
            }
        }
        return null;
    }

    public static List<String> obtenerColoresCoche(String nombreCoche) throws SQLException {
        List<String> colores = new ArrayList<>();
        String sql = "SELECT UNNEST(colores) AS color FROM coches WHERE CONCAT(marca, ' ', modelo) = ?";

        try (Connection conn = ConexionBD.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, nombreCoche);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    colores.add(rs.getString("color"));
                }
            }
        }
        return colores;
    }

    public static int obtenerStockCoche(String nombreCoche) throws SQLException {
        String sql = "SELECT stock FROM coches WHERE CONCAT(marca, ' ', modelo) = ?";
        try (Connection conn = ConexionBD.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, nombreCoche);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("stock");
                }
            }
        }
        return 0;
    }
}
```

---

## EmpleadoTemporal

Clase contenedor que almacena datos temporales de un empleado durante la ejecución de la aplicación.

### Métodos principales:
- **`guardarDatos`**: Guarda temporalmente la información del empleado.  
- **`limpiarDatos`**: Limpia los datos almacenados.

### Código:
```java
public class EmpleadoTemporal {
    private static String nombre;
    private static String apellido;
    private static String correo;
    private static String telefono;

    public static void guardarDatos(String nombre, String apellido, String correo, String telefono) {
        EmpleadoTemporal.nombre = nombre;
        EmpleadoTemporal.apellido = apellido;
        EmpleadoTemporal.correo = correo;
        EmpleadoTemporal.telefono = telefono;
    }

    public static String getNombre() { return nombre; }
    public static String getApellido() { return apellido; }
    public static String getCorreo() { return correo; }
    public static String getTelefono() { return telefono; }

    public static void limpiarDatos() {
        nombre = null;
        apellido = null;
        correo = null;
        telefono = null;
    }
}
```

---

## EnviarCorreo

Clase diseñada para enviar correos electrónicos con archivos adjuntos utilizando la API de JavaMail.

### Método principal:
- **`enviarCorreoConAdjunto`**:  
  Envía un correo electrónico a un destinatario, con asunto, mensaje y un archivo adjunto.

### Código:
```java
import java.util.Properties;
import javax.mail.*;
import javax.mail.internet.*;
import javax.activation.*;
import javax.swing.JOptionPane;

public class EnviarCorreo {
    public static void enviarCorreoConAdjunto(String destinatario, String asunto, String mensaje, String rutaAdjunto) {
        final String remitente = "cochestap@gmail.com";
        final String contraseña = "flkbwcyckbevkiuf";

        Properties props = new Properties();
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.host", "smtp.gmail.com");
        props.put("mail.smtp.port", "587");

        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(remitente, contraseña);
            }
        });

        try {
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(remitente));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(destinatario));
            message.setSubject(asunto);

            MimeBodyPart cuerpoMensaje = new MimeBodyPart();
            cuerpoMensaje.setText(mensaje);

            MimeBodyPart adjunto = new MimeBodyPart();
            DataSource fuente = new FileDataSource(rutaAdjunto);
            adjunto.setDataHandler(new DataHandler(fuente));
            adjunto.setFileName(fuente.getName());

            Multipart multipart = new MimeMultipart();
            multipart.addBodyPart(cuerpoMensaje);
            multipart.addBodyPart(adjunto);

            message.setContent(multipart);
            Transport.send(message);

            JOptionPane.showMessageDialog(null, "Correo enviado exitosamente.");
        } catch (MessagingException e) {
            e.printStack

Trace();
            JOptionPane.showMessageDialog(null, "Error al enviar el correo: " + e.getMessage());
        }
    }
}
```
---
Aquí tienes el código en formato Markdown para GitHub, estructurado y con una descripción para cada método:


# TablaCoches

Esta clase proporciona métodos para cargar y mostrar datos de coches en una tabla (`JTable`). Incluye soporte para filtrar datos según permisos (admin o usuario normal) y filtros personalizados como nombre, precio, año, y categoría.

---

## Métodos principales

### `cargarDatosEnTabla`

Carga los datos en una tabla sin aplicar filtros personalizados, con la opción de diferenciar entre usuarios administradores y normales.

#### Parámetros:
- **`tabla`**: La tabla (`JTable`) donde se cargarán los datos.
- **`esAdmin`**: Indica si el usuario es administrador.

#### Descripción:
Este método recupera datos de la base de datos y los presenta en la tabla. Para usuarios normales, se filtran solo coches activos y con stock disponible.

#### Código:
```java
public static void cargarDatosEnTabla(JTable tabla, boolean esAdmin) {
    DefaultTableModel modeloTabla = new DefaultTableModel(new Object[]{"Imagen", "Nombre", "Precio", "Año", "Stock"}, 0) {
        @Override
        public boolean isCellEditable(int row, int column) {
            return false;
        }
        @Override
        public Class<?> getColumnClass(int columnIndex) {
            return columnIndex == 0 ? ImageIcon.class : super.getColumnClass(columnIndex);
        }
    };
    tabla.setModel(modeloTabla);
    NumberFormat formatoMoneda = NumberFormat.getCurrencyInstance(Locale.US);
    String sql = "SELECT cd.imagen, cd.nombreCoche, cd.precio, c.año, c.stock FROM coches_detalle cd JOIN coches c ON cd.id = c.id";
    if (!esAdmin) sql += " WHERE c.stock > 0 AND c.activo = TRUE";

    try (Connection conn = ConexionBD.getPublicConnection();
         PreparedStatement pstmt = conn.prepareStatement(sql);
         ResultSet rs = pstmt.executeQuery()) {
        modeloTabla.setRowCount(0);
        while (rs.next()) {
            String rutaImagen = rs.getString("imagen");
            String nombre = rs.getString("nombreCoche");
            double precio = rs.getDouble("precio");
            int ano = rs.getInt("año");
            int stock = rs.getInt("stock");
            ImageIcon icono = null;
            if (rutaImagen != null && !rutaImagen.isEmpty()) {
                ImageIcon originalIcon = new ImageIcon(rutaImagen);
                Image imagenEscalada = originalIcon.getImage().getScaledInstance(100, 100, Image.SCALE_SMOOTH);
                icono = new ImageIcon(imagenEscalada);
            }
            modeloTabla.addRow(new Object[]{icono, nombre, formatoMoneda.format(precio), ano, stock});
        }
    } catch (SQLException e) {
        JOptionPane.showMessageDialog(null, "Error al cargar datos: " + e.getMessage(), "Error", JOptionPane.ERROR_MESSAGE);
    }
}
```

---

### `cargarDatosEnTablaConFiltros`

Carga los datos en una tabla aplicando filtros personalizados como nombre, rango de precios, año y categoría.

#### Parámetros:
- **`tabla`**: La tabla (`JTable`) donde se cargarán los datos.
- **`nombre`**: Filtro de nombre del coche.
- **`minPrecio`** y **`maxPrecio`**: Filtros para el rango de precios.
- **`año`**: Filtro para el año del coche.
- **`categoria`**: Filtro para la categoría del coche.
- **`esAdmin`**: Indica si el usuario es administrador.

#### Descripción:
Este método permite realizar búsquedas avanzadas según los parámetros especificados. Para usuarios normales, se filtran coches activos y con stock disponible.

#### Código:
```java
public static void cargarDatosEnTablaConFiltros(JTable tabla, String nombre, String minPrecio, String maxPrecio, String año, String categoria, boolean esAdmin) {
    DefaultTableModel modeloTabla = new DefaultTableModel(new Object[]{"Imagen", "Nombre", "Precio", "Año", "Stock"}, 0) {
        @Override
        public Class<?> getColumnClass(int columnIndex) {
            return columnIndex == 0 ? ImageIcon.class : super.getColumnClass(columnIndex);
        }
    };
    tabla.setModel(modeloTabla);

    StringBuilder sql = new StringBuilder(
        "SELECT cd.imagen, cd.nombreCoche, cd.precio, c.año, c.stock, c.categoria FROM coches_detalle cd JOIN coches c ON cd.id = c.id WHERE 1=1 "
    );
    List<Object> parametros = new ArrayList<>();
    if (!nombre.isEmpty()) {
        sql.append("AND cd.nombreCoche ILIKE ? ");
        parametros.add("%" + nombre + "%");
    }
    if (!minPrecio.isEmpty()) {
        sql.append("AND cd.precio >= ? ");
        parametros.add(Double.parseDouble(minPrecio));
    }
    if (!maxPrecio.isEmpty()) {
        sql.append("AND cd.precio <= ? ");
        parametros.add(Double.parseDouble(maxPrecio));
    }
    if (!año.isEmpty()) {
        sql.append("AND c.año = ? ");
        parametros.add(Integer.parseInt(año));
    }
    if (categoria != null && !categoria.equals("Todas")) {
        sql.append("AND c.categoria = ? ");
        parametros.add(categoria);
    }
    if (!esAdmin) sql.append("AND c.stock > 0 AND c.activo = TRUE");

    try (Connection conn = ConexionBD.getPublicConnection();
         PreparedStatement pstmt = conn.prepareStatement(sql.toString())) {
        for (int i = 0; i < parametros.size(); i++) pstmt.setObject(i + 1, parametros.get(i));
        try (ResultSet rs = pstmt.executeQuery()) {
            while (rs.next()) {
                String rutaImagen = rs.getString("imagen");
                String nombreCoche = rs.getString("nombreCoche");
                double precioCoche = rs.getDouble("precio");
                int añoCoche = rs.getInt("año");
                int stock = rs.getInt("stock");
                ImageIcon icono = null;
                if (rutaImagen != null && !rutaImagen.isEmpty()) {
                    ImageIcon originalIcon = new ImageIcon(rutaImagen);
                    Image imagenEscalada = originalIcon.getImage().getScaledInstance(100, 100, Image.SCALE_SMOOTH);
                    icono = new ImageIcon(imagenEscalada);
                }
                modeloTabla.addRow(new Object[]{icono, nombreCoche, precioCoche, añoCoche, stock});
            }
        }
    } catch (SQLException e) {
        JOptionPane.showMessageDialog(null, "Error al cargar datos: " + e.getMessage(), "Error", JOptionPane.ERROR_MESSAGE);
    } catch (NumberFormatException e) {
        JOptionPane.showMessageDialog(null, "Error en el formato de los filtros numéricos: " + e.getMessage(), "Error", JOptionPane.ERROR_MESSAGE);
    }
}
```

---

### `cargarDatosEnTablaPorNombre`

Filtra los datos por nombre de coche y los muestra en la tabla.

#### Parámetros:
- **`tabla`**: La tabla (`JTable`) donde se cargarán los datos.
- **`nombre`**: Nombre o parte del nombre del coche para filtrar.
- **`esAdmin`**: Indica si el usuario es administrador.

#### Código:
```java
public static void cargarDatosEnTablaPorNombre(JTable tabla, String nombre, boolean esAdmin) {
    DefaultTableModel modeloTabla = new DefaultTableModel(new Object[]{"Imagen", "Nombre", "Precio", "Año", "Stock"}, 0) {
        @Override
        public Class<?> getColumnClass(int columnIndex) {
            return columnIndex == 0 ? ImageIcon.class : Object.class;
        }
    };
    tabla.setModel(modeloTabla);

    String sql = "SELECT cd.imagen, cd.nombreCoche, cd.precio, c.año, c.stock FROM coches_detalle cd JOIN coches c ON cd.id = c.id WHERE cd.nombreCoche ILIKE ?";
    if (!esAdmin) sql += " AND c.stock > 0 AND c.activo = TRUE";

    try (Connection conn = ConexionBD.getPublicConnection();
         PreparedStatement pstmt = conn.prepareStatement(sql)) {
        pstmt.setString(1, "%" + nombre + "%");
        try (ResultSet rs = pstmt.executeQuery()) {
            while (rs.next()) {
                String rutaImagen = rs.getString("imagen");
                String nombreCoche = rs.getString("nombreCoche");
                double precioCoche = rs.getDouble("precio");
                int añoCoche = rs.getInt("año");
                int stock = rs.getInt("stock");
                ImageIcon icono = null;
                if (rutaImagen != null && !rutaImagen.isEmpty()) {
                    ImageIcon originalIcon = new ImageIcon(rutaImagen);
                    Image imagenEscalada = originalIcon.getImage().getScaledInstance(100, 100, Image.SCALE_SMOOTH);
                    icono = new ImageIcon(imagenEscalada);
                }
                modeloTabla.addRow(new Object[]{icono, nombreCoche, precioCoche, añoCoche, stock});
            }
        }
    } catch (SQLException e) {
        JOptionPane.showMessageDialog(null, "Error al cargar datos: " + e.getMessage(), "Error", JOptionPane.ERROR_MESSAGE);
    }
}
```

---
### Resumen del código

#### Funcionalidad:
El código presenta una clase llamada `TablaVentas` que tiene un método principal para cargar datos en una tabla (`JTable`). Esta funcionalidad es útil para mostrar registros de ventas, con filtros opcionales según el cliente, el coche, y la fecha de venta.

---

#### **Detalles del método `cargarDatosEnTabla`**

1. **Configuración de la tabla:**
   - Se crea un modelo de tabla (`DefaultTableModel`) con las columnas: `ID`, `Fecha`, `Cliente`, `Coche` y `Total`.
   - La tabla se configura para que sus celdas no sean editables.
   - Se oculta la columna `ID` (clave primaria).

2. **Consulta SQL:**
   - Se construye dinámicamente según los filtros opcionales proporcionados:
     - `nombreCliente`: Filtra por nombre o apellido del cliente (insensible a mayúsculas/minúsculas, usando `ILIKE`).
     - `nombreCoche`: Filtra por marca o modelo del coche.
     - `fechaVenta`: Filtra por fecha exacta de venta.
   - Si no se especifican filtros, devuelve todas las ventas.

3. **Parámetros:**
   - Los valores proporcionados para los filtros se asignan dinámicamente con índices en el `PreparedStatement`, lo que asegura la protección contra inyecciones SQL.

4. **Formato de salida:**
   - Se usa un `DecimalFormat` para formatear los valores monetarios en la columna `Total` con un formato legible.
   - Las filas recuperadas se agregan al modelo de la tabla.

5. **Gestión de errores:**
   - Se manejan excepciones SQL con un mensaje claro que se muestra al usuario.

---

### **Estructura del código**

1. **Clase:**  
   `TablaVentas`

2. **Método:**  
   - `cargarDatosEnTabla(JTable tabla, String nombreCliente, String nombreCoche, Date fechaVenta)`  

3. **Parámetros:**  
   - `tabla`: Objeto `JTable` donde se mostrarán los datos.  
   - `nombreCliente`: Nombre o apellido del cliente para el filtro.  
   - `nombreCoche`: Marca o modelo del coche para el filtro.  
   - `fechaVenta`: Fecha específica para filtrar ventas.  

4. **Columnas del modelo de tabla:**  
   - `ID`: Clave primaria (oculta).  
   - `Fecha`: Fecha de la venta.  
   - `Cliente`: Nombre completo del cliente.  
   - `Coche`: Marca y modelo del coche vendido.  
   - `Total`: Total de la venta, formateado con separadores de miles y decimales.

---

### **Ventajas del diseño**

1. **Flexibilidad:**  
   - Permite aplicar filtros opcionales sin duplicar código SQL.
   - Es fácil de extender añadiendo más filtros o columnas.

2. **Seguridad:**  
   - Uso de `PreparedStatement` para prevenir inyecciones SQL.

3. **Compatibilidad:**  
   - Compatible con bases de datos que soportan `ILIKE` y operaciones con fechas.

---

### **Explicación del código**

Este código implementa una clase llamada `UsuarioActivoRenderer` que extiende `DefaultTableCellRenderer`. Su propósito es personalizar la apariencia de las celdas de una tabla (`JTable`) para destacar visualmente al usuario activo, cuyo nombre se obtiene desde una sesión en curso.

---

#### **Funcionamiento**

1. **Herencia de `DefaultTableCellRenderer`:**
   - `DefaultTableCellRenderer` es la clase por defecto usada para renderizar celdas en un `JTable`.
   - Al sobrescribir el método `getTableCellRendererComponent`, se puede modificar cómo se renderiza cada celda de la tabla.

2. **Personalización de celdas:**
   - Para cada celda, se obtiene el valor de la columna específica que representa el usuario (en este caso, la columna 4).
   - Si el usuario de la fila actual coincide con el usuario activo (`Sesion.getUsuario()`), se cambia el fondo de la celda a un color celeste (`Color(173, 216, 230)`).
   - De lo contrario, la celda conserva sus colores por defecto:
     - Fondo y texto según la selección (si la fila está seleccionada).
     - Fondo y texto por defecto (si la fila no está seleccionada).

3. **Clase `Sesion`:**
   - `Sesion.getUsuario()` devuelve el nombre del usuario que está actualmente en sesión.
   - Este nombre se compara con el valor en la tabla para determinar si la fila debe destacarse.

---

#### **Código comentado**

```java
import BD.Sesion; // Clase que gestiona la sesión activa
import java.awt.Color;
import java.awt.Component;
import javax.swing.JTable;
import javax.swing.table.DefaultTableCellRenderer;

public class UsuarioActivoRenderer extends DefaultTableCellRenderer {

    @Override
    public Component getTableCellRendererComponent(JTable table, Object value, boolean isSelected, boolean hasFocus, int row, int column) {
        // Llamar al método de la clase padre para obtener el componente base de la celda
        Component c = super.getTableCellRendererComponent(table, value, isSelected, hasFocus, row, column);

        // Obtener el nombre del usuario de la fila actual (columna 4, "Usuario")
        String nombreUsuario = (String) table.getValueAt(row, 4); 

        // Comparar el usuario de la fila con el usuario activo en sesión
        if (nombreUsuario.equals(Sesion.getUsuario())) {
            // Si coincide, aplicar un fondo celeste y texto negro
            c.setBackground(new Color(173, 216, 230)); // Color celeste
            c.setForeground(Color.BLACK);
        } else {
            // Si no coincide, usar los colores predeterminados
            c.setBackground(isSelected ? table.getSelectionBackground() : table.getBackground());
            c.setForeground(isSelected ? table.getSelectionForeground() : table.getForeground());
        }

        // Devolver el componente renderizado
        return c;
    }
}
```

---

#### **Componentes clave**

1. **`Sesion.getUsuario()`**  
   - Método que retorna el usuario activo.  
   - Se asume que la clase `Sesion` maneja la sesión del usuario, incluyendo su autenticación y estado.

2. **Renderización dinámica:**
   - `getTableCellRendererComponent` es llamado para cada celda de la tabla.
   - Este método permite modificar dinámicamente cómo se verá cada celda dependiendo de la lógica implementada.

3. **Colores personalizados:**
   - Fondo celeste (`Color(173, 216, 230)`) para destacar al usuario activo.
   - Colores por defecto o de selección para los demás usuarios.

4. **Selección y enfoque:**
   - Se preserva el comportamiento de selección y enfoque cuando la fila está activa, asegurando que la celda destaque según la interacción del usuario.

---
### **Explicación del código**

Este código pertenece a una clase `UsuarioDAO` que interactúa con la base de datos para obtener información de usuarios (administradores y empleados). Tiene dos métodos principales que generan modelos de tabla (`DefaultTableModel`) para mostrar usuarios en una interfaz gráfica, con características como priorizar al usuario activo o listar todos los usuarios.

---

### **Método 1: `obtenerUsuariosConActivoPrimero`**

#### **Descripción**

Este método genera un modelo de tabla donde los usuarios se muestran en este orden:
1. **El usuario actualmente activo (según la sesión) se lista primero.**
2. **Los demás usuarios se añaden después.**

#### **Funcionamiento**
1. **Consulta SQL combinada con `UNION ALL`:**
   - Se consulta la tabla de `administrador` y `empleados` para obtener todos los usuarios, asignando un rol ('Administrador' o 'Empleado').

   ```sql
   SELECT nombre, apellido, correo, telefono, nombre_usuario, 'Administrador' AS tipo FROM administrador
   UNION ALL
   SELECT nombre, apellido, correo, telefono, nombre_usuario, 'Empleado' AS tipo FROM empleados
   ```

2. **Identificación del usuario activo:**
   - Se utiliza `Sesion.getUsuario()` para obtener el nombre del usuario activo.

3. **Ordenamiento de los usuarios:**
   - Se recorre el `ResultSet` para separar al usuario activo de los demás.
   - El usuario activo se añade primero al modelo de la tabla (`DefaultTableModel`).
   - Los demás usuarios se almacenan temporalmente en una lista (`usuarios`) y luego se añaden al modelo.

4. **Propiedad de celdas no editables:**
   - Se sobrescribe `isCellEditable` para que ninguna celda de la tabla sea editable.

#### **Código del método**

```java
public DefaultTableModel obtenerUsuariosConActivoPrimero() {
    String usuarioActivo = Sesion.getUsuario();

    // Consulta para obtener usuarios de ambas tablas con su rol
    String sql = "SELECT nombre, apellido, correo, telefono, nombre_usuario, 'Administrador' AS tipo FROM administrador "
               + "UNION ALL "
               + "SELECT nombre, apellido, correo, telefono, nombre_usuario, 'Empleado' AS tipo FROM empleados";

    // Modelo de tabla con encabezados
    DefaultTableModel modelo = new DefaultTableModel(new Object[]{"Nombre", "Apellido", "Correo", "Teléfono", "Usuario", "Tipo"}, 0) {
        @Override
        public boolean isCellEditable(int row, int column) {
            return false; // Celdas no editables
        }
    };

    // Lista para usuarios no activos
    List<Object[]> usuarios = new ArrayList<>();

    try (Connection conn = ConexionBD.getConnection();
         PreparedStatement pstmt = conn.prepareStatement(sql);
         ResultSet rs = pstmt.executeQuery()) {

        while (rs.next()) {
            String nombre = rs.getString("nombre");
            String apellido = rs.getString("apellido");
            String correo = rs.getString("correo");
            String telefono = rs.getString("telefono");
            String nombreUsuario = rs.getString("nombre_usuario");
            String tipo = rs.getString("tipo");

            // Filas para el modelo
            Object[] fila = new Object[]{nombre, apellido, correo, telefono, nombreUsuario, tipo};

            // Priorizar al usuario activo
            if (nombreUsuario.equals(usuarioActivo)) {
                modelo.addRow(fila); // Añadir al inicio
            } else {
                usuarios.add(fila); // Añadir a la lista temporal
            }
        }

        // Agregar usuarios no activos
        for (Object[] usuario : usuarios) {
            modelo.addRow(usuario);
        }

    } catch (SQLException e) {
        e.printStackTrace();
    }

    return modelo;
}
```

---

### **Método 2: `obtenerUsuariosModelo`**

#### **Descripción**

Este método es más simple: genera un modelo de tabla con todos los usuarios (administradores y empleados) sin priorizar a ninguno.

#### **Funcionamiento**
1. **Consulta SQL combinada:**
   - Al igual que en el primer método, se usa una consulta con `UNION ALL` para obtener los usuarios de ambas tablas junto con su rol.

   ```sql
   SELECT nombre, apellido, correo, telefono, nombre_usuario, 'administrador' AS rol FROM administrador
   UNION ALL
   SELECT nombre, apellido, correo, telefono, nombre_usuario, 'empleado' AS rol FROM empleados
   ```

2. **Modelo de tabla:**
   - Se crea un modelo de tabla con encabezados: Nombre, Apellido, Correo, Teléfono, Usuario, Rol.

3. **Población del modelo:**
   - Se recorre el `ResultSet` y se añaden todas las filas directamente al modelo sin priorizar.

4. **Propiedad de celdas no editables:**
   - Se sobrescribe `isCellEditable` para que las celdas no sean editables.

#### **Código del método**

```java
public DefaultTableModel obtenerUsuariosModelo(Connection conn) {
    // Modelo de tabla con encabezados
    DefaultTableModel modelo = new DefaultTableModel(new String[]{"Nombre", "Apellido", "Correo", "Teléfono", "Usuario", "Rol"}, 0) {
        @Override
        public boolean isCellEditable(int row, int column) {
            return false; // Celdas no editables
        }
    };

    // Consulta SQL para obtener usuarios y sus roles
    String sql = "SELECT nombre, apellido, correo, telefono, nombre_usuario, 'administrador' AS rol FROM administrador "
               + "UNION ALL "
               + "SELECT nombre, apellido, correo, telefono, nombre_usuario, 'empleado' AS rol FROM empleados";

    try (PreparedStatement pstmt = conn.prepareStatement(sql);
         ResultSet rs = pstmt.executeQuery()) {

        while (rs.next()) {
            String nombre = rs.getString("nombre");
            String apellido = rs.getString("apellido");
            String correo = rs.getString("correo");
            String telefono = rs.getString("telefono");
            String usuario = rs.getString("nombre_usuario");
            String rol = rs.getString("rol");

            // Añadir fila al modelo
            modelo.addRow(new Object[]{nombre, apellido, correo, telefono, usuario, rol});
        }

        return modelo;

    } catch (SQLException e) {
        e.printStackTrace();
        return null; // Devuelve null en caso de error
    }
}
```

---

### **Diferencias entre los métodos**

| Característica                             | `obtenerUsuariosConActivoPrimero`       | `obtenerUsuariosModelo`          |
|-------------------------------------------|-----------------------------------------|----------------------------------|
| **Prioridad al usuario activo**           | Sí                                      | No                               |
| **Propósito principal**                   | Mostrar usuarios destacando al activo  | Listar todos los usuarios       |
| **Parámetros necesarios**                 | Ninguno                                 | Conexión a la base de datos (`conn`) |
| **Estructura de datos temporal**          | Usa una lista (`List<Object[]>`)        | No usa estructuras temporales    |

---

# Ventana de inicio
- En esta ventana simplemente se pueden apreciar imagenes y 3 botones en la parte inferior, estos botones rediriguen a la clase catalogo y aplican el flitro de la categoria que se tiene guardado.
![image](https://github.com/user-attachments/assets/15b92a2d-d129-4c80-80d5-7e2ce4b82f3c)
![image](https://github.com/user-attachments/assets/381e3778-6630-47de-8228-9822aa7d4b50)

# Catalogo
- Se muestran todos los registros de coches que tengan un stock mayor a 0 con ciertas caracteristicas en un Jtable y tiene filtros de busqueda para encontrar el coche deseado con mayor facilidad, tambien al presionar alguna de las filas, se sera redireccionado a una ventana con mas detalles de ese coche.
![image](https://github.com/user-attachments/assets/c633cbbf-a491-413b-952d-5f9793fa2ae9)
![image](https://github.com/user-attachments/assets/c87adbbd-07c9-4e26-84fd-c2b1f390e085)
# Compra de vehiculo
- En este formulario se ingresan los datos de la persona que va a comprar y una vez que se da aceptar, toma el valor puesto en el correo electronico y manda un pdf con los datos de la persona y el coche seleccionado al correo dado.
![image](https://github.com/user-attachments/assets/c0d2b255-43db-48ea-8410-c176d206783f)
# Uso de componente usado en clase
- Se usa el componente creado en clase para una pequeña ventana de contacto, este componente es un textArea con una funcionalidad que al seleccionar el texto deseado sale un boton emergente que tiene la fuincionalidad de copiar en el portapapeles.
![image](https://github.com/user-attachments/assets/8bf2f87e-6d34-4349-a8de-3cf42fd7f317)
# Busqueda
- Abre una ventana donde se puede buscar el coche por nombre con una busqueda en tiempo real, y tambien a presionar el vehiculo abre la ventana con sus detalles.
![image](https://github.com/user-attachments/assets/bd3f8a2c-cda9-42a2-9e8c-4e4d8c40b10c)
![image](https://github.com/user-attachments/assets/47df3b37-a6e3-4325-bb8b-ab0ab9a9274a)
# Login
- Ventana de login que redirecciona a la vista del usuario ingresado (Empleado o administrador).
![image](https://github.com/user-attachments/assets/4c26a2cb-a310-431e-a461-b08e6901ac20)
# Inicio de Admin y Empleado
- Se muestra lo mismo que en el inicio normal con la diferencia que aqui se pueden cambiar las imagenes, los textos y las categorias a las cuales va a redirigir el boton, eso se aplicara al dar en actualizar.
![image](https://github.com/user-attachments/assets/c4f94c6a-fad9-4b7c-a4a3-2868009e4030)
# Catalogo Admin y Empleado
- En lo que se diferencia con el Catalogo normal es que aqui se pueden ver coches con stock de 0 y tambien hay un boton para agregar nuevos coches.
![image](https://github.com/user-attachments/assets/6d765750-11e6-4a0e-a9ff-3aa38443ce9a)
# Detalle del coche para admnin y empleados
- En estas vistas se pueden editar los campos de caracteristicas, el nombre, stock, descripcio y la imagen del coche lo cual se vera reflejado en los detalles del usuario normal.
![image](https://github.com/user-attachments/assets/02f3651b-1e11-43e8-bd70-07cf530d815e)
# Ventas
-En esta ventana se veran todas las ventas realizadas, quien las realizo y el coche que fue comprado, tiene filtros para la busqueda de las ventas lables para ver el total de ventas e ingresos que se tienen y un boton que genera un reporte de la venta seleccionada.
![image](https://github.com/user-attachments/assets/10bf2fc3-39df-4333-aa8d-d8f0f4a6c2cf)
# Usuaris (Solo Admin)
- Este boton manda a dos posibles opciones, o agregar o administrar usuarios.
![image](https://github.com/user-attachments/assets/9291c27a-e2e6-4e94-bc66-c1d0fc7fe911)
- En agregar se ingresa la informacion personal del nuevo usuario asi como sus credenciales de acceso y su respectivo rol y una vez creado se guarda y esa persona puede acceder al proyecto ingresando sus credenciales en el login.
![image](https://github.com/user-attachments/assets/ce53f4db-6e3c-4969-a41b-e03307704df0)
![image](https://github.com/user-attachments/assets/5a046f73-628a-4488-a610-c939d16b1fcd)
- En administrar se carga una tabla con todos los usuarios creados actualmente, y si se selecciona alguno se cargan los datos de esa persona en los textField que se tienen en la parte izquierda, aqui se pueden modificar los datos de esa persona y actualizarlos con el boton actalizar, y si se seleciona un persona y se da eliminar esta sera eliminada de la base de datos, tanto sus datos como su usuario, tambien en la tabla el primer resultado que se muestra es el usuario que actualmente esta activo, este no puede modificarse ni eliminarse asi mismo.
![image](https://github.com/user-attachments/assets/0a27ba18-3aef-4849-8260-bc4bf4fab2ef)

---

### **Video**

https://github.com/user-attachments/assets/5e736d01-2d49-4b64-b22e-d67fa1668209





