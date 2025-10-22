<%-- 
    buscar.jsp
    Propósito: Buscar un usuario por correo.
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*"%>
<%@page import="datos.Conexion"%>
<%@page import="java.net.URLEncoder"%>
<%
    // --- Lógica de la Página (SIN CAMBIOS) ---
    String accion = request.getParameter("accion");
    String pageTitle = "Buscar Usuario";
    if ("editar".equals(accion)) {
        pageTitle = "Editar Usuario";
    }
    if ("eliminar".equals(accion)) {
        pageTitle = "Eliminar Usuario";
    }
    String mensaje = "";
    String tipoMensaje = "danger";
    String eliminadoParam = request.getParameter("eliminado");
    if ("exitoso".equals(eliminadoParam)) {
        mensaje = "Usuario eliminado correctamente.";
        tipoMensaje = "success";
    }
    String actualizadoParam = request.getParameter("actualizado");
    if ("exitoso".equals(actualizadoParam)) {
        mensaje = "Usuario actualizado correctamente.";
        tipoMensaje = "success";
    }
    String errorParam = request.getParameter("error");
    if ("noencontrado".equals(errorParam)) {
        mensaje = "Error: La operación falló porque el usuario no fue encontrado.";
        tipoMensaje = "warning";
    }
    String correoBusqueda = request.getParameter("correo") != null ? request.getParameter("correo") : "";
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        accion = request.getParameter("accion");
        if (correoBusqueda.trim().isEmpty()) {
            mensaje = "Por favor, ingrese un correo para buscar.";
            tipoMensaje = "warning";
        } else {
            Connection conn = null;
            PreparedStatement ps = null;
            ResultSet rs = null;
            try {
                conn = Conexion.getConnection();
                ps = conn.prepareStatement("SELECT * FROM usuarios WHERE correo = ?");
                ps.setString(1, correoBusqueda);
                rs = ps.executeQuery();

                if (rs.next()) {
                    if ("editar".equals(accion)) {
                        String url = String.format("agregarUsuario.jsp?id=%d&source=editar", rs.getInt("id"));
                        response.sendRedirect(url);
                        return;
                    } else {
                        session.setAttribute("source", accion);
                        session.setAttribute("usuario_nombre", rs.getString("nombre"));
                        session.setAttribute("usuario_correo", rs.getString("correo"));
                        session.setAttribute("usuario_clave", rs.getString("clave"));
                        session.setAttribute("usuario_tipo", rs.getString("tipo"));
                        response.sendRedirect("confirmar.jsp");
                        return;
                    }
                } else {
                    mensaje = "No se encontró ningún usuario con el correo: " + correoBusqueda;
                    tipoMensaje = "warning";
                }
            } catch (SQLException e) {
                mensaje = "Error en la base de datos: " + e.getMessage();
                tipoMensaje = "danger";
                e.printStackTrace();
            } finally {
                if (rs != null) try { rs.close(); } catch (SQLException e) {}
                if (ps != null) try { ps.close(); } catch (SQLException e) {}
                Conexion.closeConnection(conn);
            }
        }
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
            max-width: 450px;
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
        .form-control {
            border-radius: 8px;
            padding: 12px;
            border: 1px solid var(--color-border);
        }
        .form-control:focus {
            border-color: var(--color-primary);
            box-shadow: 0 0 0 0.25rem rgba(81, 154, 237, 0.25);
        }
        .form-label {
            color: var(--color-text-light);
            font-weight: 600;
            margin-bottom: 8px;
        }
        /* Contenedor de input con icono */
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

        <form method="POST" class="mt-4">
            <input type="hidden" name="accion" value="<%= accion%>">
            
            <div class="mb-3">
                <label for="correo" class="form-label">Correo del Usuario</label>
                <div class="input-with-icon">
                    <span class="input-icon-label"><i class="bi bi-search"></i></span>
                    <input type="email" class="form-control" id="correo" name="correo" placeholder="Ingrese el correo a buscar" value="<%= correoBusqueda%>" required>
                </div>
            </div>
            
            <div class="d-grid gap-3 mt-4">
                <button type="submit" class="btn btn-primary">
                    <i class="bi bi-search"></i> Buscar
                </button>
                <button type="button" class="btn btn-secondary" onclick="location.href = 'index.jsp'">
                    <i class="bi bi-x-lg"></i> Cancelar
                </button>
            </div>
        </form>
    </div>

    <script src="https://cdnjs.cloudflare.com/ajax/libs/bootstrap/5.3.2/js/bootstrap.bundle.min.js"></script>
</body>
</html>