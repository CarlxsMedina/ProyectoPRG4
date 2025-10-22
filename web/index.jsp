<%-- 
    index.jsp
    Propósito: Menú principal de la aplicación.
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    // --- Lógica de Sesión y Mensajes (SIN CAMBIOS) ---
    if (session.getAttribute("usuarioNombre") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    String accion = request.getParameter("accion");
    if ("salir".equals(accion)) {
        session.invalidate();
        response.sendRedirect("login.jsp");
        return;
    }
    String mensaje = "";
    String tipoMensaje = "success";
    String registroParam = request.getParameter("registro");
    String actualizadoParam = request.getParameter("actualizado");
    String accionParam = request.getParameter("accion"); 

    if ("exitoso".equals(registroParam)) {
        mensaje = "Usuario registrado correctamente.";
        tipoMensaje = "success";
    } else if ("editar".equals(accionParam) && "exitoso".equals(actualizadoParam)) {
        mensaje = "Datos actualizados correctamente en la base de datos.";
        tipoMensaje = "success";
    } else if ("editar".equals(accionParam) && "error".equals(request.getParameter("error"))) {
        mensaje = "No se pudo actualizar el usuario (no encontrado).";
        tipoMensaje = "danger";
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Menú Principal</title>
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
        .btn-danger {
            background-color: #dc3545;
            color: white;
        }
        .btn-danger:hover {
            background-color: #c82333;
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
            background-color: var(--color-bg);
            border: 1px solid var(--color-border);
            color: var(--color-primary);
            border-radius: 8px;
        }
        
        /* Estilos específicos del menú */
        .btn-menu-action {
            background-color: white;
            border: 1px solid var(--color-border);
            color: var(--color-text);
            text-align: left;
            padding: 15px 20px;
            margin-bottom: 12px;
            width: 100%;
            display: flex;
            align-items: center;
            font-weight: 500;
        }
        .btn-menu-action i {
            font-size: 1.2rem;
            margin-right: 15px;
            color: var(--color-primary);
            width: 20px;
        }
        .btn-menu-action:hover {
            background-color: var(--color-primary);
            color: white;
            border-color: var(--color-primary);
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(81, 154, 237, 0.3);
        }
        .btn-menu-action:hover i {
            color: white;
        }
    </style>
</head>
<body>

    <div class="app-container">
        <h2 class="app-title">Menú Principal</h2>

        <p class="text-center mb-4 text-muted">
            Bienvenido, <strong><%= session.getAttribute("usuarioNombre")%></strong>
        </p>

        <% if (!mensaje.isEmpty()) {%>
        <div class="alert alert-<%= tipoMensaje%> alert-dismissible fade show" role="alert">
            <%= mensaje%>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <% }%>
        
        <div class="d-grid gap-2 mt-4">
            <button type="button" class="btn btn-menu-action" onclick="location.href = 'agregarUsuario.jsp'">
                <i class="bi bi-plus-circle"></i> Nuevo Usuario
            </button>
            <button type="button" class="btn btn-menu-action" onclick="location.href = 'buscar.jsp?accion=buscar'">
                <i class="bi bi-search"></i> Buscar Usuario
            </button>
            <button type="button" class="btn btn-menu-action" onclick="location.href = 'buscar.jsp?accion=editar'">
                <i class="bi bi-pencil-square"></i> Editar Usuario
            </button>
            <button type="button" class="btn btn-menu-action" onclick="location.href = 'buscar.jsp?accion=eliminar'">
                <i class="bi bi-trash"></i> Eliminar Usuario
            </button>
            <button type="button" class="btn btn-menu-action" onclick="location.href = 'lista.jsp'">
                <i class="bi bi-list-ul"></i> Listado de Usuarios
            </button>
            
            <hr class="my-3">
            
            <button type="button" class="btn btn-secondary" onclick="location.href = 'index.jsp?accion=salir'">
                <i class="bi bi-box-arrow-right"></i> Salir
            </button>
        </div>
    </div>

    <script src="https://cdnjs.cloudflare.com/ajax/libs/bootstrap/5.3.2/js/bootstrap.bundle.min.js"></script>
</body>
</html>