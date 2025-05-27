
USE [TuBaseDeDatos]; -- Reemplaza [TuBaseDeDatos] con el nombre de tu base de datos
GO

-- Tabla: Generos
PRINT 'Creando Tabla Generos...';
CREATE TABLE Generos (
    id_genero INT PRIMARY KEY IDENTITY(1,1),
    nombre NVARCHAR(100) NOT NULL UNIQUE,
    descripcion NVARCHAR(MAX) NULL
);
GO

-- Tabla: Usuarios
PRINT 'Creando Tabla Usuarios...';
CREATE TABLE Usuarios (
    id_usuario INT PRIMARY KEY IDENTITY(1,1),
    nombre_usuario VARCHAR(255) NOT NULL UNIQUE,
    contrasena VARCHAR(255) NOT NULL,
    correo_electronico VARCHAR(255) NOT NULL UNIQUE,
    nombre_completo NVARCHAR(255) NULL,
    fecha_registro DATETIME2 DEFAULT GETDATE(),
    rol VARCHAR(10) NOT NULL CHECK (rol IN ('lector', 'autor', 'admin')),
    activo BIT DEFAULT 1
);
GO

-- Tabla: Autores
PRINT 'Creando Tabla Autores...';
CREATE TABLE Autores (
    id_autor INT PRIMARY KEY,
    biografia NVARCHAR(MAX) NULL,
    sitio_web VARCHAR(255) NULL,
    libros_publicados_contador INT DEFAULT 0 NOT NULL,
    CONSTRAINT FK_Autores_Usuarios FOREIGN KEY (id_autor) REFERENCES Usuarios(id_usuario) ON DELETE CASCADE
);
GO

-- Tabla: Libros
PRINT 'Creando Tabla Libros...';
CREATE TABLE Libros (
    id_libro INT PRIMARY KEY IDENTITY(1,1),
    titulo NVARCHAR(255) NOT NULL,
    isbn VARCHAR(20) UNIQUE NULL,
    sinopsis NVARCHAR(MAX) NULL,
    ano_publicacion INT NULL,
    editorial NVARCHAR(255) NULL,
    portada_url VARCHAR(255) NULL,
    archivo_libro_url VARCHAR(255) NULL,
    id_autor_subida INT NULL,
    id_admin_aprobacion INT NULL,
    estado_publicacion VARCHAR(10) NOT NULL DEFAULT 'pendiente' CHECK (estado_publicacion IN ('pendiente', 'aprobado', 'rechazado')),
    fecha_subida DATETIME2 DEFAULT GETDATE(),
    fecha_aprobacion DATETIME2 NULL,
    disponible_prestamo BIT DEFAULT 1,
    disponible_lectura_online BIT DEFAULT 1,
    idioma NVARCHAR(50) NULL,
    CONSTRAINT FK_Libros_AutorSubida FOREIGN KEY (id_autor_subida) REFERENCES Autores(id_autor) ON DELETE SET NULL,
    CONSTRAINT FK_Libros_AdminAprobacion FOREIGN KEY (id_admin_aprobacion) REFERENCES Usuarios(id_usuario) ON DELETE SET NULL
);
GO

-- Tabla: Libros_Autores
PRINT 'Creando Tabla Libros_Autores...';
CREATE TABLE Libros_Autores (
    id_libro INT NOT NULL,
    id_autor INT NOT NULL,
    rol_autor NVARCHAR(50) DEFAULT 'Principal',
    PRIMARY KEY (id_libro, id_autor),
    CONSTRAINT FK_LibrosAutores_Libro FOREIGN KEY (id_libro) REFERENCES Libros(id_libro) ON DELETE CASCADE,
    CONSTRAINT FK_LibrosAutores_Autor FOREIGN KEY (id_autor) REFERENCES Autores(id_autor) ON DELETE CASCADE
);
GO

-- Tabla: Libros_Generos
PRINT 'Creando Tabla Libros_Generos...';
CREATE TABLE Libros_Generos (
    id_libro INT NOT NULL,
    id_genero INT NOT NULL,
    PRIMARY KEY (id_libro, id_genero),
    CONSTRAINT FK_LibrosGeneros_Libro FOREIGN KEY (id_libro) REFERENCES Libros(id_libro) ON DELETE CASCADE,
    CONSTRAINT FK_LibrosGeneros_Genero FOREIGN KEY (id_genero) REFERENCES Generos(id_genero) ON DELETE CASCADE
);
GO

-- Tabla: Prestamos
PRINT 'Creando Tabla Prestamos...';
CREATE TABLE Prestamos (
    id_prestamo INT PRIMARY KEY IDENTITY(1,1),
    id_libro INT NOT NULL,
    id_usuario INT NOT NULL,
    fecha_prestamo DATETIME2 NOT NULL DEFAULT GETDATE(),
    fecha_devolucion_estimada DATETIME2 NOT NULL,
    fecha_devolucion_real DATETIME2 NULL,
    estado_prestamo VARCHAR(10) NOT NULL DEFAULT 'activo' CHECK (estado_prestamo IN ('activo', 'devuelto', 'retrasado')),
    CONSTRAINT FK_Prestamos_Libro FOREIGN KEY (id_libro) REFERENCES Libros(id_libro),
    CONSTRAINT FK_Prestamos_Usuario FOREIGN KEY (id_usuario) REFERENCES Usuarios(id_usuario)
);
GO

-- Tabla: Historial_Lectura
PRINT 'Creando Tabla Historial_Lectura...';
CREATE TABLE Historial_Lectura (
    id_historial INT PRIMARY KEY IDENTITY(1,1),
    id_usuario INT NOT NULL,
    id_libro INT NOT NULL,
    fecha_inicio_lectura DATETIME2 NULL,
    fecha_fin_lectura DATETIME2 NULL,
    estado_lectura VARCHAR(15) NOT NULL DEFAULT 'leyendo' CHECK (estado_lectura IN ('leyendo', 'leido', 'abandonado')),
    ultima_pagina_leida INT NULL,
    CONSTRAINT FK_HistorialLectura_Usuario FOREIGN KEY (id_usuario) REFERENCES Usuarios(id_usuario),
    CONSTRAINT FK_HistorialLectura_Libro FOREIGN KEY (id_libro) REFERENCES Libros(id_libro),
    CONSTRAINT UQ_Historial_Usuario_Libro UNIQUE (id_usuario, id_libro)
);
GO

-- Tabla: Comentarios_Calificaciones
PRINT 'Creando Tabla Comentarios_Calificaciones...';
CREATE TABLE Comentarios_Calificaciones (
    id_comentario INT PRIMARY KEY IDENTITY(1,1),
    id_libro INT NOT NULL,
    id_usuario INT NOT NULL,
    calificacion INT NULL CHECK (calificacion IS NULL OR (calificacion >= 1 AND calificacion <= 5)),
    comentario NVARCHAR(MAX) NULL,
    fecha_comentario DATETIME2 NOT NULL DEFAULT GETDATE(),
    visible BIT DEFAULT 1,
    CONSTRAINT FK_ComentariosCalificaciones_Libro FOREIGN KEY (id_libro) REFERENCES Libros(id_libro),
    CONSTRAINT FK_ComentariosCalificaciones_Usuario FOREIGN KEY (id_usuario) REFERENCES Usuarios(id_usuario),
    CONSTRAINT CK_Comentario_O_Calificacion CHECK (calificacion IS NOT NULL OR comentario IS NOT NULL)
);
GO

-- Tabla: Recomendaciones_Compartidas
PRINT 'Creando Tabla Recomendaciones_Compartidas...';
CREATE TABLE Recomendaciones_Compartidas (
    id_recomendacion INT PRIMARY KEY IDENTITY(1,1),
    id_libro INT NOT NULL,
    id_usuario_origen INT NOT NULL,
    id_usuario_destino INT NOT NULL,
    mensaje NVARCHAR(MAX) NULL,
    fecha_recomendacion DATETIME2 NOT NULL DEFAULT GETDATE(),
    leido_destino BIT DEFAULT 0,
    CONSTRAINT FK_RecomendacionesCompartidas_Libro FOREIGN KEY (id_libro) REFERENCES Libros(id_libro),
    CONSTRAINT FK_RecomendacionesCompartidas_UsuarioOrigen FOREIGN KEY (id_usuario_origen) REFERENCES Usuarios(id_usuario),
    CONSTRAINT FK_RecomendacionesCompartidas_UsuarioDestino FOREIGN KEY (id_usuario_destino) REFERENCES Usuarios(id_usuario),
    CONSTRAINT CK_OrigenDestinoDiferentes CHECK (id_usuario_origen != id_usuario_destino)
);
GO

-- TRIGGERS
PRINT 'Creando Triggers...';

CREATE TRIGGER TRG_Libros_EstadoPublicacion_UpdateContador
ON Libros
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE A
    SET A.libros_publicados_contador = ISNULL(A.libros_publicados_contador, 0) + 1
    FROM Autores A
    INNER JOIN Libros_Autores LA ON A.id_autor = LA.id_autor
    INNER JOIN inserted i ON LA.id_libro = i.id_libro
    LEFT JOIN deleted d ON i.id_libro = d.id_libro
    WHERE i.estado_publicacion = 'aprobado' AND (d.id_libro IS NULL OR d.estado_publicacion != 'aprobado');

    UPDATE A
    SET A.libros_publicados_contador = CASE WHEN ISNULL(A.libros_publicados_contador, 0) > 0 THEN A.libros_publicados_contador - 1 ELSE 0 END
    FROM Autores A
    INNER JOIN Libros_Autores LA ON A.id_autor = LA.id_autor
    INNER JOIN deleted d ON LA.id_libro = d.id_libro
    INNER JOIN inserted i ON d.id_libro = i.id_libro
    WHERE d.estado_publicacion = 'aprobado' AND i.estado_publicacion != 'aprobado';
END;
GO

CREATE TRIGGER TRG_LibrosAutores_UpdateContador
ON Libros_Autores
AFTER INSERT, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM inserted) AND NOT EXISTS (SELECT 1 FROM deleted)
    BEGIN
        UPDATE A
        SET A.libros_publicados_contador = ISNULL(A.libros_publicados_contador, 0) + 1
        FROM Autores A
        INNER JOIN inserted i ON A.id_autor = i.id_autor
        INNER JOIN Libros L ON i.id_libro = L.id_libro
        WHERE L.estado_publicacion = 'aprobado';
    END

    IF EXISTS (SELECT 1 FROM deleted) AND NOT EXISTS (SELECT 1 FROM inserted)
    BEGIN
        UPDATE A
        SET A.libros_publicados_contador = CASE WHEN ISNULL(A.libros_publicados_contador, 0) > 0 THEN A.libros_publicados_contador - 1 ELSE 0 END
        FROM Autores A
        INNER JOIN deleted d ON A.id_autor = d.id_autor
        INNER JOIN Libros L ON d.id_libro = L.id_libro
        WHERE L.estado_publicacion = 'aprobado';
    END
END;
GO

PRINT 'Script de creación de base de datos completado.';
GO
