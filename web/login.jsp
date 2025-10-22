<%--
    login.jsp
    Propósito:
    - Permitir que un usuario existente inicie sesión (Pestaña 1).
    - Permitir que un nuevo usuario se registre (Pestaña 2).
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*"%>
<%@page import="datos.Conexion"%>

<%
// --- Lógica de la Página ---

String mensaje = "";
String tipoMensaje = "danger"; // Por defecto para errores

// Variables para "recordar" los campos en caso de error
String loginCorreo = "";
String regNombre = "";
String regCorreo = "";

// Variable para saber qué pestaña mostrar en caso de error
String activeTab = "login"; // Por defecto, la de login

// Procesar el formulario solo si es una petición POST
if ("POST".equalsIgnoreCase(request.getMethod())) {
    
    // Distinguir qué formulario se envió
    String accion = request.getParameter("accion");

    // ===================================
    // ACCIÓN: INICIAR SESIÓN
    // ===================================
    if ("login".equals(accion)) {
        activeTab = "login"; // Permanecer en esta pestaña
        String correo = request.getParameter("correo");
        String clave = request.getParameter("clave");
        
        loginCorreo = correo; // Guardar correo para re-mostrarlo

        if (correo == null || clave == null || correo.trim().isEmpty() || clave.trim().isEmpty()) {
            mensaje = "Por favor complete todos los campos";
            tipoMensaje = "warning";
        } else {
            Connection conn = null;
            try {
                conn = Conexion.getConnection();
                PreparedStatement ps = conn.prepareStatement(
                        "SELECT * FROM usuarios WHERE correo = ? AND clave = ?");
                ps.setString(1, correo);
                ps.setString(2, clave);
                ResultSet rs = ps.executeQuery();

                if (rs.next()) {
                    // LOGIN EXITOSO
                    session.setAttribute("usuarioId", rs.getInt("id"));
                    session.setAttribute("usuarioNombre", rs.getString("nombre"));
                    session.setAttribute("usuarioCorreo", rs.getString("correo"));
                    response.sendRedirect("index.jsp");
                    return;
                } else {
                    mensaje = "Usuario o contraseña incorrectos";
                    tipoMensaje = "danger";
                }
                rs.close();
                ps.close();
            } catch (SQLException e) {
                mensaje = "Error al conectar con la base de datos: " + e.getMessage();
                tipoMensaje = "danger";
                e.printStackTrace();
            } finally {
                Conexion.closeConnection(conn);
            }
        }
    }

    // ===================================
    // ACCIÓN: REGISTRAR NUEVO USUARIO
    // ===================================
    else if ("register".equals(accion)) {
        activeTab = "register"; // Permanecer en esta pestaña
        
        // Tomar valores del formulario de registro
        String nombre = request.getParameter("nombre");
        String correo = request.getParameter("correo");
        String clave = request.getParameter("clave");
        String confirmarClave = request.getParameter("confirmarClave");
        String tipo = "usuario"; // Asignar tipo "usuario" por defecto
        
        // Guardar valores para re-mostrarlos si hay error
        regNombre = nombre;
        regCorreo = correo;

        // --- 1. Validación de campos (copiada de agregarUsuario.jsp) ---
        boolean valido = true;
        if (nombre == null || nombre.trim().isEmpty() || correo == null || correo.trim().isEmpty()
                || clave == null || clave.trim().isEmpty() || confirmarClave == null || confirmarClave.trim().isEmpty()) {
            mensaje = "Por favor complete todos los campos de registro";
            tipoMensaje = "warning";
            valido = false;
        } else if (!clave.equals(confirmarClave)) {
            mensaje = "Las contraseñas no coinciden";
            tipoMensaje = "danger";
            valido = false;
        } else if (clave.length() < 4) {
            mensaje = "La contraseña debe tener al menos 4 caracteres";
            tipoMensaje = "warning";
            valido = false;
        }

        // --- 2. Validación de BD (copiada de agregarUsuario.jsp) ---
        if (valido) {
            Connection conn = null;
            PreparedStatement ps = null;
            ResultSet rs = null;
            try {
                conn = Conexion.getConnection();
                // Verificar si el correo ya existe
                ps = conn.prepareStatement("SELECT COUNT(*) FROM usuarios WHERE correo = ?");
                ps.setString(1, correo);
                rs = ps.executeQuery();
                if (rs.next() && rs.getInt(1) > 0) {
                    mensaje = "El correo electrónico ya está registrado";
                    tipoMensaje = "danger";
                    valido = false;
                }
                
                // Cerrar recursos de la verificación
                if (rs != null) rs.close();
                if (ps != null) ps.close();

                // --- 3. Inserción en BD (copiada de confirmar.jsp) ---
                if (valido) {
                    ps = conn.prepareStatement(
                            "INSERT INTO usuarios (nombre, correo, clave, tipo) VALUES (?, ?, ?, ?)");
                    ps.setString(1, nombre);
                    ps.setString(2, correo);
                    ps.setString(3, clave);
                    ps.setString(4, tipo); // Tipo por defecto "usuario"
                    ps.executeUpdate();

                    // ¡REGISTRO EXITOSO!
                    mensaje = "¡Registro exitoso! Ahora puedes iniciar sesión.";
                    tipoMensaje = "success";
                    activeTab = "login"; // Mover al login
                    
                    // Limpiar campos de registro tras éxito
                    regNombre = "";
                    regCorreo = ""; 
                    
                } // Fin de inserción

            } catch (SQLException e) {
                // Manejar error de SQL (ej. 1062 = duplicado, aunque ya lo chequeamos)
                if (e.getErrorCode() == 1062) {
                     mensaje = "El correo electrónico ya está registrado.";
                     tipoMensaje = "danger";
                } else {
                    mensaje = "Error en la base de datos: " + e.getMessage();
                    tipoMensaje = "danger";
                    e.printStackTrace();
                }
            } finally {
                if (ps != null) try { ps.close(); } catch (SQLException e) {}
                Conexion.closeConnection(conn);
            }
        }
    } // Fin de "register"
} // Fin de "POST"
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Iniciar Sesión</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap/5.3.2/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    
    <style>
        :root {
            --color-primary: #519AED;
            --color-primary-hover: #408bdb;
            --color-primary-light: #e6f0ff;
            --color-secondary: #677F89;
            --color-secondary-hover: #5C6A6E;
            --color-dark: #343842;
            --color-darkest: #222A33;
            --color-text: #343842;
            --color-text-light: #5C6A6E;
            --color-bg: #f8f9fa;
            --color-container: #ffffff;
            --color-border: #dee2e6;
        }
        body {
            background-color: var(--color-bg);
            color: var(--color-text);
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
            display: flex;
            align-items: center;
            justify-content: center;
            min-height: 100vh;
            padding: 20px;
        }
        .app-container {
            background: var(--color-container);
            border-radius: 12px;
            box-shadow: 0 4px 25px rgba(0, 0, 0, 0.08);
            max-width: 450px;
            width: 100%;
            padding: 0;
            overflow: hidden;
        }
        .app-container-padded {
            padding: 30px 40px 40px;
        }
        .btn {
            padding: 12px 20px;
            font-weight: 600;
            border-radius: 8px;
            transition: all 0.3s ease;
            border: none;
        }
        .btn-primary {
            background-color: var(--color-primary);
            color: white;
        }
        .btn-primary:hover {
            background-color: var(--color-primary-hover);
            color: white;
            transform: translateY(-2px);
            box-shadow: 0 4px 10px rgba(81, 154, 237, 0.4);
        }
        .form-control, .form-select {
            border-radius: 8px;
            padding: 12px;
            border: 1px solid var(--color-border);
        }
        .form-control:focus, .form-select:focus {
            border-color: var(--color-primary);
            box-shadow: 0 0 0 0.25rem rgba(81, 154, 237, 0.25);
        }
        .form-label {
            color: var(--color-text-light);
            font-weight: 600;
            margin-bottom: 8px;
        }
        .nav-tabs {
            border-bottom: 1px solid var(--color-border);
            background-color: var(--color-bg);
        }
        .nav-tabs .nav-link, 
        .nav-tabs .nav-link:hover {
            border: none;
            color: var(--color-text-light);
            font-weight: 500;
            padding: 1rem 1.5rem;
            border-radius: 12px 12px 0 0;
        }
        .nav-tabs .nav-link:hover {
            color: var(--color-primary);
        }
        .nav-tabs .nav-link.active {
            border-bottom: 3px solid var(--color-primary);
            color: var(--color-darkest);
            font-weight: 700;
            background-color: var(--color-container);
        }
        .input-with-icon {
            position: relative;
        }
        .input-with-icon .form-control {
            padding-left: 3rem;
        }
        .input-with-icon .input-icon-label {
            position: absolute;
            left: 1rem;
            top: 50%;
            transform: translateY(-50%);
            color: var(--color-text-light);
            font-size: 1.2rem;
            pointer-events: none;
        }
        .input-group .form-control { 
             padding-left: 1rem;
             border-right: none;
        }
        .input-group-text {
            cursor: pointer;
            background-color: white;
            border: 1px solid var(--color-border);
            border-left: none;
            color: var(--color-text-light);
            border-radius: 0 8px 8px 0;
        }
    </style>
</head>
<body>

    <div class="app-container">
        
        <ul class="nav nav-tabs nav-fill" id="loginTabs" role="tablist">
            <li class="nav-item" role="presentation">
                <button class="nav-link <%= "login".equals(activeTab) ? "active" : "" %>" id="login-tab" data-bs-toggle="tab" data-bs-target="#login-pane" type="button" role="tab">
                    Iniciar Sesión
                </button>
            </li>
            <li class="nav-item" role="presentation">
                <button class="nav-link <%= "register".equals(activeTab) ? "active" : "" %>" id="register-tab" data-bs-toggle="tab" data-bs-target="#register-pane" type="button" role="tab">
                    Registrarse
                </button>
            </li>
        </ul>

        <div class="tab-content">
            
            <div class="tab-pane fade <%= "login".equals(activeTab) ? "show active" : "" %>" id="login-pane" role="tabpanel">
                <div class="app-container-padded">
                    
                    <%-- 
                      BLOQUE ÚNICO PARA MENSAJES:
                      Muestra CUALQUIER mensaje (error de login O éxito de registro)
                      siempre que la pestaña de login esté activa.
                    --%>
                    <% if (!mensaje.isEmpty() && "login".equals(activeTab)) {%>
                    <div class="alert alert-<%= tipoMensaje%> alert-dismissible fade show" role="alert">
                        <%= mensaje%>
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                    <% } %>
                    
                    <%-- BLOQUE REDUNDANTE ELIMINADO --%>

                    <form method="POST" class="mt-2">
                        <input type="hidden" name="accion" value="login">
                        
                        <div class="mb-3">
                            <label for="correo" class="form-label">Correo Electrónico</label>
                            <div class="input-with-icon">
                                <span class="input-icon-label"><i class="bi bi-envelope"></i></span>
                                <input type="email" class="form-control" id="correo" name="correo"
                                       placeholder="correo@ejemplo.com" value="<%= loginCorreo %>" required>
                            </div>
                        </div>

                        <div class="mb-4">
                            <label for="clave" class="form-label">Contraseña</label>
                            <div class="input-group">
                                <input type="password" class="form-control" id="clave" name="clave"
                                       placeholder="Ingrese su contraseña" required>
                                <span class="input-group-text" onclick="togglePassword('clave', 'toggleIconClave')">
                                    <i class="bi bi-eye-slash" id="toggleIconClave"></i>
                                </span>
                            </div>
                        </div>

                        <button type="submit" class="btn btn-primary w-100">
                            <i class="bi bi-box-arrow-in-right"></i> Iniciar Sesión
                        </button>
                    </form>
                </div>
            </div>
            
            <div class="tab-pane fade <%= "register".equals(activeTab) ? "show active" : "" %>" id="register-pane" role="tabpanel">
                <div class="app-container-padded">
                    
                    <%-- Mostrar alerta si hay mensaje (y estamos en la pestaña de registro) --%>
                    <% if (!mensaje.isEmpty() && "register".equals(activeTab)) {%>
                    <div class="alert alert-<%= tipoMensaje%> alert-dismissible fade show" role="alert">
                        <%= mensaje%>
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                    <% } %>
                    
                    <form method="POST" class="mt-2">
                        <input type="hidden" name="accion" value="register">
                        
                        <div class="mb-3">
                            <label for="nombre" class="form-label">Nombre Completo</label>
                            <div class="input-with-icon">
                                <span class="input-icon-label"><i class="bi bi-person"></i></span>
                                <input type="text" class="form-control" id="nombre" name="nombre"
                                       placeholder="Ingrese su nombre" value="<%= regNombre %>" required>
                            </div>
                        </div>
                        
                        <div class="mb-3">
                            <label for="reg_correo" class="form-label">Correo Electrónico</label>
                            <div class="input-with-icon">
                                <span class="input-icon-label"><i class="bi bi-envelope"></i></span>
                                <input type="email" class="form-control" id="reg_correo" name="correo"
                                       placeholder="correo@ejemplo.com" value="<%= regCorreo %>" required>
                            </div>
                        </div>

                        <div class="mb-3">
                            <label for="reg_clave" class="form-label">Contraseña (4+ caracteres)</label>
                            <div class="input-group">
                                <input type="password" class="form-control" id="reg_clave" name="clave"
                                       placeholder="Cree una contraseña" required>
                                <span class="input-group-text" onclick="togglePassword('reg_clave', 'toggleIconRegClave')">
                                    <i class="bi bi-eye-slash" id="toggleIconRegClave"></i>
                                </span>
                            </div>
                        </div>
                        
                        <div class="mb-4">
                            <label for="reg_confirmarClave" class="form-label">Confirmar Contraseña</label>
                            <div class="input-group">
                                <input type="password" class="form-control" id="reg_confirmarClave" name="confirmarClave"
                                       placeholder="Confirme la contraseña" required>
                                <span class="input-group-text" onclick="togglePassword('reg_confirmarClave', 'toggleIconRegConfirmar')">
                                    <i class="bi bi-eye-slash" id="toggleIconRegConfirmar"></i>
                                </span>
                            </div>
                        </div>

                        <button type="submit" class="btn btn-primary w-100">
                            <i class="bi bi-person-plus"></i> Crear Cuenta
                        </button>
                    </form>
                </div>
            </div>
            
        </div> </div> <script src="https://cdnjs.cloudflare.com/ajax/libs/bootstrap/5.3.2/js/bootstrap.bundle.min.js"></script>
    <script>
        function togglePassword(fieldId, iconId) {
            const passwordField = document.getElementById(fieldId);
            const toggleIcon = document.getElementById(iconId);
            const type = passwordField.getAttribute('type') === 'password' ? 'text' : 'password';
            passwordField.setAttribute('type', type);
            toggleIcon.className = type === 'password' ? 'bi bi-eye-slash' : 'bi bi-eye';
        }
        
        var myTabs = document.querySelectorAll('button[data-bs-toggle="tab"]');
        myTabs.forEach(function (tab) {
            tab.addEventListener('shown.bs.tab', function (event) {
                var alerts = document.querySelectorAll('.alert');
                alerts.forEach(function(alert) {
                     var bsAlert = new bootstrap.Alert(alert);
                     bsAlert.close();
                });
            });
        });
    </script>
</body>
</html>