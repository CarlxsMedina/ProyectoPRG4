<%-- 
    lista.jsp
    Propósito: Mostrar todos los usuarios en una tabla.
:((((
**
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*"%>
<%@page import="datos.Conexion"%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Lista de Usuarios</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    
    <style>
        :root {
            --color-primary: #519AED;
            --color-primary-hover: #408bdb;
            --color-primary-light: #e6f0ff; /* Celeste muy claro para hover */
            --color-secondary: #677F89;
            --color-secondary-hover: #5C6A6E;
            --color-dark: #343842;
            --color-darkest: #222A33;
            --color-text: #343842;
            --color-bg: #f8f9fa;
            --color-container: #ffffff;
            --color-border: #dee2e6;
        }
        /* Ajuste para que el body no esté centrado */
        body {
            background-color: var(--color-bg);
            color: var(--color-text);
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
            min-height: 100vh;
        }
        .btn {
            padding: 8px 15px; /* Botones más pequeños para la cabecera */
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
        /* Estilos de la tarjeta y tabla */
        .card {
            border: none;
            border-radius: 12px;
            box-shadow: 0 4px 25px rgba(0, 0, 0, 0.08);
        }
        .card-header {
            /* Usando el color más oscuro de tu paleta */
            background-color: var(--color-darkest);
            color: white;
            border-radius: 12px 12px 0 0;
            padding: 1.25rem 1.5rem;
        }
        .table {
            margin-bottom: 0; /* Quitar margen inferior dentro de la tarjeta */
        }
        .table thead {
            /* Usando el color oscuro de tu paleta */
            background-color: var(--color-dark);
            color: white;
        }
        .table thead th {
            border-bottom-width: 0;
        }
        /* El hover que pediste */
        tbody tr {
            transition: background-color 0.2s ease, color 0.2s ease;
        }
        tbody tr:hover {
            background-color: var(--color-primary-light);
            color: var(--color-primary-hover);
            cursor: pointer;
            font-weight: 500;
        }
        .card-footer {
             background-color: var(--color-bg);
             border-top: 1px solid var(--color-border);
             border-radius: 0 0 12px 12px;
        }
    </style>
</head>
<body>
<div class="container mt-5 mb-5" style="max-width: 960px;">
    <div class="card">
        
        <div class="card-header d-flex justify-content-between align-items-center">
            <h3 class="mb-0 h4">Lista de Usuarios</h3>
            <div>
                <a href="index.jsp" class="btn btn-secondary">
                    <i class="bi bi-arrow-left"></i> Volver al Menú
                </a>
                <a href="agregarUsuario.jsp" class="btn btn-primary ms-2">
                    <i class="bi bi-plus-lg"></i> Nuevo Usuario
                </a>
            </div>
        </div>
        
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table table-hover align-middle text-center mb-0">
                    <thead>
                        <tr>
                            <th scope="col" class="p-3">#</th>
                            <th scope="col" class="p-3 text-start">Nombre</th>
                            <th scope="col" class.="p-3 text-start">Correo</th>
                            <th scope="col" class="p-3">Tipo de usuario</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            try {
                                Connection con = Conexion.getConnection();
                                PreparedStatement ps = con.prepareStatement("SELECT * FROM usuarios ORDER BY nombre");
                                ResultSet rs = ps.executeQuery();
                                int contador = 1;
                                while (rs.next()) {
                                    int id = rs.getInt("id");
                        %>
                        <tr onclick="location.href='agregarUsuario.jsp?id=<%= id %>&source=lista'">
                            <th scope="row" class="p-3"><%= contador++ %></th>
                            <td class="p-3 text-start"><%= rs.getString("nombre") %></td>
                            <td class="p-3 text-start"><%= rs.getString("correo") %></td>
                            <td class="p-3" style="text-transform: capitalize;"><%= rs.getString("tipo") %></td>
                        </tr>
                        <%
                                }
                                con.close();
                            } catch (Exception e) {
                        %>
                        <tr>
                            <td colspan="4" class="text-danger p-4">
                                <i class="bi bi-exclamation-triangle-fill me-2"></i> Error al cargar los datos: <%= e.getMessage() %>
                            </td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </div>
        
        <div class="card-footer text-center">
            <small class="text-muted">
                <i class="bi bi-info-circle"></i> Haga clic en cualquier fila para <strong>editar</strong> el usuario.
            </small>
        </div>
        
    </div>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>