<%-- 
    confirmar.jsp
    Propósito: Página intermedia para "confirmar" acciones.
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*"%>
<%@page import="datos.Conexion"%>
<%
    // --- Lógica de la Página (SIN CAMBIOS) ---
    String source = (String) session.getAttribute("source");
    boolean isRegisterMode = "register".equals(source);
    boolean isSearchMode = "buscar".equals(source);
    boolean isEditMode = "editar".equals(source);
    boolean isDeleteMode = "eliminar".equals(source);
    
    String nombre = "", correo = "", clave = "", tipo = "", original_correo = "";
    String pageTitle = "", labelClave = "";

    if (isRegisterMode || isEditMode) {
        nombre = (String) session.getAttribute("temp_nombre");
        correo = (String) session.getAttribute("temp_correo");
        clave = (String) session.getAttribute("temp_clave");
        tipo = (String) session.getAttribute("temp_tipo");
        if (isEditMode) {
            pageTitle = "Confirmar Edición";
            original_correo = (String) session.getAttribute("original_correo");
            labelClave = "Nueva Clave";
        } else {
            pageTitle = "Confirmar Registro";
            labelClave = "Clave";
        }
    } else {
        nombre = (String) session.getAttribute("usuario_nombre");
        correo = (String) session.getAttribute("usuario_correo");
        clave = (String) session.getAttribute("usuario_clave");
        tipo = (String) session.getAttribute("usuario_tipo");
        if (isSearchMode) {
            pageTitle = "Datos del Usuario";
        }
        if (isDeleteMode) {
            pageTitle = "¿Eliminar este Usuario?";
        }
        labelClave = "Clave Registrada";
    }

    if (nombre == null || nombre.isEmpty()) {
        response.sendRedirect("index.jsp");
        return;
    }

    String accion = request.getParameter("accion");

    if (isRegisterMode) {
        if ("confirmar".equals(accion)) {
            Connection conn = null;
            PreparedStatement ps = null;
            try {
                conn = Conexion.getConnection();
                ps = conn.prepareStatement("INSERT INTO usuarios (nombre, correo, clave, tipo) VALUES (?, ?, ?, ?)");
                ps.setString(1, nombre);
                ps.setString(2, correo);
                ps.setString(3, clave);
                ps.setString(4, tipo);
                ps.executeUpdate();
                session.removeAttribute("source");
                session.removeAttribute("temp_nombre");
                session.removeAttribute("temp_correo");
                session.removeAttribute("temp_clave");
                session.removeAttribute("temp_tipo");
                response.sendRedirect("index.jsp?registro=exitoso");
                return;
            } catch (SQLException e) {
                if (e.getErrorCode() == 1062) {
                    response.sendRedirect("agregarUsuario.jsp?error=" + java.net.URLEncoder.encode("El correo ya está registrado.", "UTF-8"));
                    return;
                }
                e.printStackTrace();
            } finally {
                if (ps != null) try { ps.close(); } catch (SQLException e) {}
                Conexion.closeConnection(conn);
            }
        }
        if ("cancelar".equals(accion)) {
            String url = String.format("agregarUsuario.jsp?nombre=%s&correo=%s&clave=%s&confirmarClave=%s&tipo=%s",
                    java.net.URLEncoder.encode(nombre, "UTF-8"),
                    java.net.URLEncoder.encode(correo, "UTF-8"),
                    java.net.URLEncoder.encode(clave, "UTF-8"),
                    java.net.URLEncoder.encode(clave, "UTF-8"),
                    java.net.URLEncoder.encode(tipo, "UTF-8"));
            response.sendRedirect(url);
            return;
        }
    }

    if (isEditMode) {
        if ("confirmar".equals(accion)) {
            Connection conn = null;
            PreparedStatement ps = null;
            try {
                conn = Conexion.getConnection();
                ps = conn.prepareStatement("UPDATE usuarios SET nombre = ?, correo = ?, clave = ?, tipo = ? WHERE correo = ?");
                ps.setString(1, nombre);
                ps.setString(2, correo);
                ps.setString(3, clave);
                ps.setString(4, tipo);
                ps.setString(5, original_correo);
                int rowsAffected = ps.executeUpdate();
                session.removeAttribute("source");
                session.removeAttribute("temp_nombre");
                session.removeAttribute("temp_correo");
                session.removeAttribute("temp_clave");
                session.removeAttribute("temp_tipo");
                session.removeAttribute("original_correo");
                if (rowsAffected > 0) {
                    response.sendRedirect("index.jsp?accion=editar&actualizado=exitoso");
                } else {
                    response.sendRedirect("index.jsp?accion=editar&error=noencontrado");
                }
                return;
            } catch (SQLException e) {
                e.printStackTrace();
            } finally {
                if (ps != null) try { ps.close(); } catch (SQLException e) {}
                Conexion.closeConnection(conn);
            }
        }
        if ("cancelar".equals(accion)) {
            String url = String.format("agregarUsuario.jsp?nombre=%s&correo=%s&clave=%s&tipo=%s&source=editar",
                    java.net.URLEncoder.encode(nombre, "UTF-8"),
                    java.net.URLEncoder.encode(correo, "UTF-8"),
                    java.net.URLEncoder.encode(clave, "UTF-8"),
                    java.net.URLEncoder.encode(tipo, "UTF-8"));
            response.sendRedirect(url);
            return;
        }
    }

    if (isSearchMode) {
        if ("regresar".equals(accion) || "menu".equals(accion)) {
            session.removeAttribute("source");
            session.removeAttribute("usuario_nombre");
            session.removeAttribute("usuario_correo");
            session.removeAttribute("usuario_clave");
            session.removeAttribute("usuario_tipo");
            if ("regresar".equals(accion)) {
                response.sendRedirect("buscar.jsp?accion=" + source);
            }
            if ("menu".equals(accion)) {
                response.sendRedirect("index.jsp");
            }
            return;
        }
    }

    if (isDeleteMode) {
        if ("eliminar_confirmado".equals(accion)) {
            Connection conn = null;
            PreparedStatement ps = null;
            try {
                conn = Conexion.getConnection();
                ps = conn.prepareStatement("DELETE FROM usuarios WHERE correo = ?");
                ps.setString(1, correo);
                int rowsAffected = ps.executeUpdate();
                session.removeAttribute("source");
                session.removeAttribute("usuario_nombre");
                session.removeAttribute("usuario_correo");
                session.removeAttribute("usuario_clave");
                session.removeAttribute("usuario_tipo");
                if (rowsAffected > 0) {
                    response.sendRedirect("buscar.jsp?accion=eliminar&eliminado=exitoso");
                } else {
                    response.sendRedirect("buscar.jsp?accion=eliminar&error=noencontrado");
                }
                return;
            } catch (SQLException e) {
                e.printStackTrace();
            } finally {
                if (ps != null) try { ps.close(); } catch (SQLException e) {}
                Conexion.closeConnection(conn);
            }
        }
        if ("regresar".equals(accion)) {
            session.removeAttribute("source");
            session.removeAttribute("usuario_nombre");
            session.removeAttribute("usuario_correo");
            session.removeAttribute("usuario_clave");
            session.removeAttribute("usuario_tipo");
            response.sendRedirect("buscar.jsp?accion=eliminar");
            return;
        }
    }
    
    // --- LÓGICA PARA LINK DE REGRESAR (ELIMINADA) ---
    // La variable backUrl ya no es necesaria si no se muestra el enlace.
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
            max-width: 500px;
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
        .btn-danger {
            background-color: #dc3545;
            color: white;
        }
        .btn-danger:hover {
            background-color: #c82333;
            color: white;
            transform: translateY(-2px);
        }
        /* Estilos de la info */
        .info-box {
            background-color: var(--color-bg);
            border: 1px solid var(--color-border);
            border-radius: 8px;
            padding: 15px 20px;
            margin-bottom: 15px;
        }
        .info-label {
            font-weight: 600;
            color: var(--color-text-light);
            font-size: 0.85rem;
            margin-bottom: 2px;
            text-transform: uppercase;
        }
        .info-value {
            color: var(--color-darkest);
            font-size: 1.1rem;
            font-weight: 500;
            word-break: break-all;
        }
        .toggle-password-icon {
            cursor: pointer;
            color: var(--color-primary);
            font-size: 1.5rem;
            transition: color 0.2s;
        }
        .toggle-password-icon:hover {
            color: var(--color-primary-hover);
        }
    </style>
</head>
<body>

    <div class="app-container">
        <h2 class="app-title"><%= pageTitle%></h2>

        <% if (isEditMode && original_correo != null && !original_correo.equals(correo)) {%>
        <div class="alert alert-info d-flex align-items-center">
            <i class="bi bi-info-circle-fill me-2"></i>
            <div>
                <strong>Nota:</strong> El correo será cambiado de <strong><%= original_correo%></strong> a <strong><%= correo%></strong>
            </div>
        </div>
        <% }%>
        
        <% if (isDeleteMode) {%>
        <div class="alert alert-danger d-flex align-items-center">
            <i class="bi bi-exclamation-triangle-fill me-2"></i>
            <div>
                <strong>¡Atención!</strong> Esta acción es permanente.
            </div>
        </div>
        <% }%>

        <div class="info-box">
            <div class="info-label">Nombre:</div>
            <div class="info-value"><%= nombre%></div>
        </div>
        <div class="info-box">
            <div class="info-label">Correo:</div>
            <div class="info-value"><%= correo%></div>
        </div>

        <% if (!isDeleteMode) {%>
        <div class="info-box d-flex justify-content-between align-items-center">
            <div>
                <div class="info-label"><%= labelClave%>:</div>
                <div class="info-value" id="passwordDisplay" data-password="<%= clave%>">
                    <%= "●".repeat(clave.length())%>
                </div>
            </div>
            <i class="bi bi-eye-slash toggle-password-icon" id="toggleIcon"></i>
        </div>
        <% }%>

        <div class="info-box">
            <div class="info-label">Tipo:</div>
            <div class="info-value" style="text-transform: capitalize;"><%= tipo%></div>
        </div>

        <div class="row g-3 mt-3">
            <% if (isRegisterMode || isEditMode) {%>
            <div class="col-md-6">
                <form method="POST" class="d-grid">
                    <input type="hidden" name="accion" value="cancelar">
                    <button type="submit" class="btn btn-secondary">
                        <i class="bi bi-pencil"></i> Corregir
                    </button>
                </form>
            </div>
            <div class="col-md-6">
                <form method="POST" class="d-grid">
                    <input type="hidden" name="accion" value="confirmar">
                    <button type="submit" class="btn btn-primary">
                        <i class="bi bi-check-lg"></i> <%= isEditMode ? "Guardar Cambios" : "Confirmar"%>
                    </button>
                </form>
            </div>
            <% } else if (isSearchMode) { %>
            <div class="col-md-6">
                <form method="POST" class="d-grid">
                    <input type="hidden" name="accion" value="regresar">
                    <button type="submit" class="btn btn-primary">
                        <i class="bi bi-arrow-left"></i> Regresar
                    </button>
                </form>
            </div>
            <div class="col-md-6">
                <form method="POST" class="d-grid">
                    <input type="hidden" name="accion" value="menu">
                    <button type="submit" class="btn btn-secondary">
                        <i class="bi bi-house"></i> Menú
                    </button>
                </form>
            </div>
            <% } else if (isDeleteMode) { %>
            <div class="col-md-6">
                <form method="POST" class="d-grid">
                    <input type="hidden" name="accion" value="regresar">
                    <button type="submit" class="btn btn-secondary">
                        <i class="bi bi-x-lg"></i> Cancelar
                    </button>
                </form>
            </div>
            <div class="col-md-6">
                <form method="POST" class="d-grid">
                    <input type="hidden" name="accion" value="eliminar_confirmado">
                    <button type="submit" class="btn btn-danger">
                        <i class="bi bi-trash-fill"></i> Eliminar
                    </button>
                </form>
            </div>
            <% }%>
        </div>
    </div>

    <script>
        const toggleIcon = document.getElementById('toggleIcon');
        if (toggleIcon) {
            toggleIcon.addEventListener('click', function () {
                const passwordDisplay = document.getElementById('passwordDisplay');
                const realPassword = passwordDisplay.dataset.password;
                const isHidden = passwordDisplay.textContent.includes('●');
                if (isHidden) {
                    passwordDisplay.textContent = realPassword;
                    this.classList.replace('bi-eye-slash', 'bi-eye');
                } else {
                    passwordDisplay.textContent = '●'.repeat(realPassword.length);
                    this.classList.replace('bi-eye', 'bi-eye-slash');
                }
            });
        }
    </script>
</body>
</html>