<%-- 
    agregarUsuario.jsp
    Propósito: formulario para registrar o editar un usuario.
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*"%>
<%@page import="datos.Conexion"%>
<%
    // --- Lógica de la Página (SIN CAMBIOS) ---
    String source = request.getParameter("source");
    boolean isEditMode = "editar".equals(source);
    String pageTitle = isEditMode ? "Editar Usuario" : "Registro de Usuario";
    String buttonText = isEditMode ? "Guardar Cambios" : "Registrar Usuario";
    String nombre = "", correo = "", clave = "", confirmarClave = "", tipo = "", originalCorreo = "";
    String mensaje = "", tipoMensaje = "danger";
    String paso = request.getParameter("paso");
    if ("validar".equals(paso) && "POST".equalsIgnoreCase(request.getMethod())) {
        nombre = request.getParameter("nombre");
        correo = request.getParameter("correo");
        clave = request.getParameter("clave");
        confirmarClave = request.getParameter("confirmarClave");
        tipo = request.getParameter("tipo");
        source = request.getParameter("source");
        isEditMode = "editar".equals(source);
        originalCorreo = request.getParameter("correo_original");
        boolean valido = true;
        if (nombre == null || nombre.trim().isEmpty() || correo == null || correo.trim().isEmpty()
                || clave == null || clave.trim().isEmpty() || confirmarClave == null || confirmarClave.trim().isEmpty()
                || tipo == null || tipo.trim().isEmpty()) {
            mensaje = "Por favor complete todos los campos";
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
        if (valido) {
            Connection conn = null;
            PreparedStatement ps = null;
            ResultSet rs = null;
            try {
                conn = Conexion.getConnection();
                if (isEditMode) {
                    if (!correo.equals(originalCorreo)) {
                        ps = conn.prepareStatement("SELECT COUNT(*) FROM usuarios WHERE correo = ?");
                        ps.setString(1, correo);
                        rs = ps.executeQuery();
                        if (rs.next() && rs.getInt(1) > 0) {
                            mensaje = "El correo electrónico ya está registrado";
                            tipoMensaje = "danger";
                            valido = false;
                        }
                    }
                } else {
                    ps = conn.prepareStatement("SELECT COUNT(*) FROM usuarios WHERE correo = ?");
                    ps.setString(1, correo);
                    rs = ps.executeQuery();
                    if (rs.next() && rs.getInt(1) > 0) {
                        mensaje = "El correo electrónico ya está registrado";
                        tipoMensaje = "danger";
                        valido = false;
                    }
                }
            } catch (SQLException e) {
                mensaje = "Error al verificar el correo: " + e.getMessage();
                valido = false;
                e.printStackTrace();
            } finally {
                if (rs != null) try { rs.close(); } catch (SQLException e) {}
                if (ps != null) try { ps.close(); } catch (SQLException e) {}
                Conexion.closeConnection(conn);
            }
        }
        if (valido) {
            session.setAttribute("source", isEditMode ? "editar" : "register");
            session.setAttribute("temp_nombre", nombre);
            session.setAttribute("temp_correo", correo);
            session.setAttribute("temp_clave", clave);
            session.setAttribute("temp_tipo", tipo);
            if (isEditMode && originalCorreo != null && !originalCorreo.trim().isEmpty()) {
                session.setAttribute("original_correo", originalCorreo);
            }
            response.sendRedirect("confirmar.jsp");
            return;
        }
    } else {
        mensaje = request.getParameter("error") != null ? request.getParameter("error") : "";
        nombre = request.getParameter("nombre") != null ? request.getParameter("nombre") : "";
        correo = request.getParameter("correo") != null ? request.getParameter("correo") : "";
        clave = request.getParameter("clave") != null ? request.getParameter("clave") : "";
        confirmarClave = clave;
        tipo = request.getParameter("tipo") != null ? request.getParameter("tipo") : "";
        String idParam = request.getParameter("id");
        if (idParam != null && !idParam.isEmpty()) {
            try {
                Connection con = Conexion.getConnection();
                PreparedStatement ps = con.prepareStatement("SELECT * FROM usuarios WHERE id = ?");
                ps.setInt(1, Integer.parseInt(idParam));
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    nombre = rs.getString("nombre");
                    correo = rs.getString("correo");
                    clave = rs.getString("clave");
                    confirmarClave = clave;
                    tipo = rs.getString("tipo");
                    originalCorreo = correo;
                    isEditMode = true;
                    if ("lista".equals(request.getParameter("source"))) {
                        source = "lista";
                    } else {
                        source = "editar";
                    }
                    pageTitle = "Editar Usuario";
                    buttonText = "Guardar Cambios";
                }
                con.close();
            } catch (Exception e) {
                mensaje = "Error al cargar datos del usuario: " + e.getMessage();
                tipoMensaje = "danger";
            }
        } else if (isEditMode) {
            originalCorreo = correo;
        }
    }
    String cancelUrl = "index.jsp";
    if ("editar".equals(source)) {
        cancelUrl = "buscar.jsp?accion=editar";
    } else if ("lista".equals(source)) {
        cancelUrl = "lista.jsp";
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= pageTitle%></title>
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
            padding: 30px 40px;
            max-width: 550px;
            width: 100%;
        }
        .app-title {
            color: var(--color-darkest);
            font-weight: 700;
            text-align: center;
            margin-bottom: 30px;
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
        .btn-secondary {
            background-color: var(--color-secondary);
            color: white;
        }
        .btn-secondary:hover {
            background-color: var(--color-secondary-hover);
            color: white;
            transform: translateY(-2px);
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
        .input-group-text {
            cursor: pointer;
            background-color: white;
            border: 1px solid var(--color-border);
            border-left: none;
            color: var(--color-text-light);
            border-radius: 0 8px 8px 0;
        }
        
        /* Contenedor de input con icono para campos Nombre y Correo */
        .input-with-icon {
            position: relative;
        }
        .input-with-icon .form-control {
            padding-left: 3rem; /* Espacio para el icono */
        }
        .input-with-icon .input-icon-label {
            position: absolute;
            left: 1rem;
            top: 50%; /* Centra verticalmente respecto al input */
            transform: translateY(-50%); /* Ajuste fino para el centrado */
            color: var(--color-text-light);
            font-size: 1.2rem;
            pointer-events: none; /* Permite hacer clic a través del icono al input */
        }
        /* Ajuste para inputs dentro de input-group (contraseñas) */
        .input-group .form-control { 
             padding-left: 1rem; /* No necesita icono fijo */
             border-right: none; /* Para que el ojo tenga su propio borde */
        }
        .form-select {
            padding-left: 1rem; /* Los selects no llevan icono fijo */
        }
    </style>
</head>
<body>

    <div class="app-container">
        <h2 class="app-title"><%= pageTitle%></h2>

        <% if (!mensaje.isEmpty()) {%>
        <div class="alert alert-<%= tipoMensaje%> alert-dismissible fade show" role="alert">
            <%= mensaje%>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <% }%>
        
        <form method="POST" action="agregarUsuario.jsp" class="mt-4">
            <input type="hidden" name="paso" value="validar">
            <input type="hidden" name="source" value="<%= source != null ? source : ""%>">
            <input type="hidden" name="correo_original" value="<%= originalCorreo%>">

            <div class="mb-3">
                <label for="nombre" class="form-label">Nombre</label>
                <div class="input-with-icon">
                    <span class="input-icon-label"><i class="bi bi-person"></i></span>
                    <input type="text" class="form-control" id="nombre" name="nombre" placeholder="Ingrese el nombre" value="<%= nombre%>" required>
                </div>
            </div>
            
            <div class="mb-3">
                <label for="correo" class="form-label">Correo</label>
                <div class="input-with-icon">
                    <span class="input-icon-label"><i class="bi bi-envelope"></i></span>
                    <input type="email" class="form-control" id="correo" name="correo" placeholder="correo@ejemplo.com" value="<%= correo%>" required>
                </div>
            </div>
            
            <div class="mb-3">
                <label for="clave" class="form-label">Clave</label>
                <div class="input-group">
                    <input type="password" class="form-control" id="clave" name="clave" placeholder="Ingrese la contraseña" value="<%= clave%>" required>
                    <span class="input-group-text" onclick="togglePassword('clave', 'toggleIconClave')">
                        <i class="bi bi-eye-slash" id="toggleIconClave"></i>
                    </span>
                </div>
            </div>
            
            <div class="mb-3">
                <label for="confirmarClave" class="form-label">Confirmar Clave</label>
                <div class="input-group">
                    <input type="password" class="form-control" id="confirmarClave" name="confirmarClave" placeholder="Confirme la contraseña" value="<%= confirmarClave%>" required>
                    <span class="input-group-text" onclick="togglePassword('confirmarClave', 'toggleIconConfirmar')">
                        <i class="bi bi-eye-slash" id="toggleIconConfirmar"></i>
                    </span>
                </div>
            </div>
            
            <div class="mb-4">
                <label for="tipo" class="form-label">Tipo de Usuario</label>
                <select class="form-select" id="tipo" name="tipo" required>
                    <option value="">Seleccione un tipo</option>
                    <option value="usuario" <%= "usuario".equals(tipo) ? "selected" : ""%>>Usuario</option>
                    <option value="asistente" <%= "asistente".equals(tipo) ? "selected" : ""%>>Asistente</option>
                    <option value="administrador" <%= "administrador".equals(tipo) ? "selected" : ""%>>Administrador</option>
                </select>
            </div>
            
            <div class="row g-3">
                <div class="col-md-6">
                    <button type="button" class="btn btn-secondary w-100" onclick="location.href = '<%= cancelUrl %>'">
                        <i class="bi bi-x-lg"></i> Cancelar
                    </button>
                </div>
                <div class="col-md-6">
                    <button type="submit" class="btn btn-primary w-100">
                        <i class="bi bi-check-lg"></i> <%= buttonText%>
                    </button>
                </div>
            </div>
        </form>
    </div>

    <script src="https://cdnjs.cloudflare.com/ajax/libs/bootstrap/5.3.2/js/bootstrap.bundle.min.js"></script>
    <script>
        function togglePassword(fieldId, iconId) {
            const passwordField = document.getElementById(fieldId);
            const toggleIcon = document.getElementById(iconId);
            const type = passwordField.getAttribute('type') === 'password' ? 'text' : 'password';
            passwordField.setAttribute('type', type);
            toggleIcon.className = type === 'password' ? 'bi bi-eye-slash' : 'bi bi-eye';
        }
    </script>
</body>
</html>