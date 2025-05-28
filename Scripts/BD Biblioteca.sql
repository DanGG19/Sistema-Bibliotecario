-- ===========================================================
-- BASE DE DATOS BIBLIOTECA (PostgreSQL) - ESTRUCTURA OPTIMIZADA
-- ===========================================================
-- Autor: ChatGPT + Usuario
-- Fecha: 28 de mayo de 2025
-- Descripción: Estructura completa, refinada, sin datos de ejemplo.
-- ===========================================================

-- Elimina y crea la base de datos (omite DROP/CREATE si ya existe)
DROP DATABASE IF EXISTS Biblioteca;
CREATE DATABASE Biblioteca
  WITH 
    ENCODING = 'UTF8'
    LC_COLLATE = 'es_SV.UTF-8'
    LC_CTYPE = 'es_SV.UTF-8'
    TEMPLATE = template0;


-- Cambiar de forma automatica la base de datos

-- ============ FUNCIONES DE AUDITORÍA ===============
CREATE OR REPLACE FUNCTION fn_actualizar_fecha_modificacion()
RETURNS TRIGGER AS $$
BEGIN
   NEW.fecha_modificacion = NOW();
   RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============ TIPOS ENUM ===========================
CREATE TYPE tipo_estado_publicacion AS ENUM ('pendiente', 'aprobado', 'rechazado');
CREATE TYPE tipo_estado_ejemplar AS ENUM ('disponible', 'prestado', 'en_reparacion', 'perdido', 'reservado', 'no_disponible');
CREATE TYPE tipo_estado_prestamo AS ENUM ('activo', 'devuelto', 'retrasado', 'cancelado');
CREATE TYPE tipo_estado_lectura AS ENUM ('leyendo', 'leido', 'abandonado');
CREATE TYPE tipo_estado_reserva AS ENUM ('activa', 'lista_para_recoger', 'cancelada', 'expirada', 'completada');
CREATE TYPE tipo_privacidad_lista AS ENUM ('publica', 'privada', 'solo_enlace');
CREATE TYPE tipo_rol_miembro_club AS ENUM ('miembro', 'administrador', 'moderador');
CREATE TYPE tipo_reporte_usuario AS ENUM ('Libro dañado', 'Contenido inapropiado', 'Error de datos', 'Problema con préstamo', 'Sugerencia', 'Otro');
CREATE TYPE tipo_estado_reporte AS ENUM ('pendiente', 'en_revision', 'resuelto', 'cerrado', 'rechazado');

-- ============= TABLAS PRINCIPALES ===================
CREATE TABLE Roles (
    id_rol SERIAL PRIMARY KEY,
    nombre_rol VARCHAR(50) NOT NULL UNIQUE,
    descripcion_rol TEXT NULL,
    fecha_creacion TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    fecha_modificacion TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE TRIGGER trg_roles_fecha_modificacion
    BEFORE UPDATE ON Roles
    FOR EACH ROW
    EXECUTE FUNCTION fn_actualizar_fecha_modificacion();

CREATE TABLE Usuarios (
    id_usuario SERIAL PRIMARY KEY,
    nombre_usuario VARCHAR(255) NOT NULL UNIQUE,
    contrasena VARCHAR(255) NOT NULL,
    correo_electronico VARCHAR(255) NOT NULL UNIQUE CHECK (correo_electronico ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$'),
    nombre_completo VARCHAR(255) NULL,
    fecha_creacion TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    fecha_modificacion TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    activo BOOLEAN DEFAULT TRUE NOT NULL
);

CREATE TRIGGER trg_usuarios_fecha_modificacion
    BEFORE UPDATE ON Usuarios
    FOR EACH ROW
    EXECUTE FUNCTION fn_actualizar_fecha_modificacion();

CREATE TABLE Usuario_Roles (
    id_usuario INT NOT NULL,
    id_rol INT NOT NULL,
    fecha_asignacion TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    PRIMARY KEY (id_usuario, id_rol),
    FOREIGN KEY (id_usuario) REFERENCES Usuarios(id_usuario) ON DELETE CASCADE,
    FOREIGN KEY (id_rol) REFERENCES Roles(id_rol) ON DELETE CASCADE
);

CREATE TABLE Autores (
    id_autor INT PRIMARY KEY,
    biografia TEXT NULL,
    sitio_web VARCHAR(255) NULL CHECK (sitio_web IS NULL OR sitio_web ~* '^https?://[^\\s/$.?#].[^\\s]*$'),
    libros_publicados_contador INT DEFAULT 0 NOT NULL CHECK (libros_publicados_contador >= 0),
    fecha_creacion TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    fecha_modificacion TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    FOREIGN KEY (id_autor) REFERENCES Usuarios(id_usuario) ON DELETE CASCADE
);

CREATE TRIGGER trg_autores_fecha_modificacion
    BEFORE UPDATE ON Autores
    FOR EACH ROW
    EXECUTE FUNCTION fn_actualizar_fecha_modificacion();

-- ================== Géneros ==================
CREATE TABLE Generos (
    id_genero SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    descripcion TEXT NULL,
    fecha_creacion TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    fecha_modificacion TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE TRIGGER trg_generos_fecha_modificacion
    BEFORE UPDATE ON Generos
    FOR EACH ROW
    EXECUTE FUNCTION fn_actualizar_fecha_modificacion();

-- ================== Libros ===================
CREATE TABLE Libros (
    id_libro SERIAL PRIMARY KEY,
    titulo VARCHAR(255) NOT NULL,
    isbn VARCHAR(20) UNIQUE NULL,
    sinopsis TEXT NULL,
    ano_publicacion INT NULL CHECK (ano_publicacion IS NULL OR (ano_publicacion > 0 AND ano_publicacion <= EXTRACT(YEAR FROM NOW()) + 1)),
    editorial VARCHAR(255) NULL,
    portada_url VARCHAR(255) NULL CHECK (portada_url IS NULL OR portada_url ~* '^https?://[^\\s/$.?#].[^\\s]*$'),
    archivo_libro_url VARCHAR(255) NULL CHECK (archivo_libro_url IS NULL OR archivo_libro_url ~* '^https?://[^\\s/$.?#].[^\\s]*$'),
    id_autor_subida INT NULL,
    id_admin_aprobacion INT NULL,
    estado_publicacion tipo_estado_publicacion NOT NULL DEFAULT 'pendiente',
    fecha_subida TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    fecha_aprobacion TIMESTAMPTZ NULL,
    idioma VARCHAR(50) NULL,
    numero_paginas INT NULL CHECK (numero_paginas IS NULL OR numero_paginas > 0),
    fecha_modificacion TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    FOREIGN KEY (id_autor_subida) REFERENCES Autores(id_autor) ON DELETE SET NULL,
    FOREIGN KEY (id_admin_aprobacion) REFERENCES Usuarios(id_usuario) ON DELETE SET NULL,
    CONSTRAINT CK_Libro_FechaAprobacion CHECK (fecha_aprobacion IS NULL OR estado_publicacion = 'aprobado')
);

CREATE TRIGGER trg_libros_fecha_modificacion
    BEFORE UPDATE ON Libros
    FOR EACH ROW
    EXECUTE FUNCTION fn_actualizar_fecha_modificacion();

-- ================== Libros_Autores ===================
CREATE TABLE Libros_Autores (
    id_libro INT NOT NULL,
    id_autor INT NOT NULL,
    rol_autor VARCHAR(50) DEFAULT 'Principal',
    fecha_asociacion TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    PRIMARY KEY (id_libro, id_autor),
    FOREIGN KEY (id_libro) REFERENCES Libros(id_libro) ON DELETE CASCADE,
    FOREIGN KEY (id_autor) REFERENCES Autores(id_autor) ON DELETE CASCADE
);

-- ================== Libros_Géneros ===================
CREATE TABLE Libros_Generos (
    id_libro INT NOT NULL,
    id_genero INT NOT NULL,
    fecha_asociacion TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    PRIMARY KEY (id_libro, id_genero),
    FOREIGN KEY (id_libro) REFERENCES Libros(id_libro) ON DELETE CASCADE,
    FOREIGN KEY (id_genero) REFERENCES Generos(id_genero) ON DELETE CASCADE
);

-- ================== Ejemplares ===================
CREATE TABLE Ejemplares (
    id_ejemplar SERIAL PRIMARY KEY,
    id_libro INT NOT NULL,
    numero_inventario VARCHAR(100) UNIQUE NULL,
    estado_ejemplar tipo_estado_ejemplar NOT NULL DEFAULT 'disponible',
    ubicacion VARCHAR(255) NULL,
    es_digital BOOLEAN DEFAULT FALSE NOT NULL,
    notas_ejemplar TEXT NULL,
    fecha_adquisicion DATE NULL,
    fecha_creacion TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    fecha_modificacion TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    FOREIGN KEY (id_libro) REFERENCES Libros(id_libro) ON DELETE CASCADE,
    CONSTRAINT CK_Ejemplar_Inventario CHECK (es_digital = TRUE OR numero_inventario IS NOT NULL)
);

CREATE TRIGGER trg_ejemplares_fecha_modificacion
    BEFORE UPDATE ON Ejemplares
    FOR EACH ROW
    EXECUTE FUNCTION fn_actualizar_fecha_modificacion();

-- ================== Préstamos ===================
CREATE TABLE Prestamos (
    id_prestamo SERIAL PRIMARY KEY,
    id_ejemplar INT NOT NULL,
    id_usuario INT NOT NULL,
    fecha_prestamo TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    fecha_devolucion_estimada TIMESTAMPTZ NOT NULL,
    fecha_devolucion_real TIMESTAMPTZ NULL,
    estado_prestamo tipo_estado_prestamo NOT NULL DEFAULT 'activo',
    multa_aplicada NUMERIC(10,2) DEFAULT 0.00 CHECK (multa_aplicada >= 0),
    fecha_modificacion TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    FOREIGN KEY (id_ejemplar) REFERENCES Ejemplares(id_ejemplar) ON DELETE RESTRICT,
    FOREIGN KEY (id_usuario) REFERENCES Usuarios(id_usuario) ON DELETE RESTRICT,
    CONSTRAINT CK_Prestamo_Fechas CHECK (fecha_devolucion_estimada > fecha_prestamo AND (fecha_devolucion_real IS NULL OR fecha_devolucion_real >= fecha_prestamo))
);

CREATE TRIGGER trg_prestamos_fecha_modificacion
    BEFORE UPDATE ON Prestamos
    FOR EACH ROW
    EXECUTE FUNCTION fn_actualizar_fecha_modificacion();

-- ================== Historial de Lectura (inicio) ===================
CREATE TABLE Historial_Lectura (
    id_historial SERIAL PRIMARY KEY,
    id_usuario INT NOT NULL,
    id_libro INT NOT NULL,
    fecha_inicio_lectura TIMESTAMPTZ NULL,
    fecha_fin_lectura TIMESTAMPTZ NULL,
    estado_lectura tipo_estado_lectura NOT NULL DEFAULT 'leyendo',
    ultima_pagina_leida INT NULL CHECK (ultima_pagina_leida IS NULL OR ultima_pagina_leida > 0),
    fecha_creacion TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    fecha_modificacion TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    FOREIGN KEY (id_usuario) REFERENCES Usuarios(id_usuario) ON DELETE CASCADE,
    FOREIGN KEY (id_libro) REFERENCES Libros(id_libro) ON DELETE CASCADE,
    CONSTRAINT UQ_Historial_Usuario_Libro UNIQUE (id_usuario, id_libro),
    CONSTRAINT CK_Historial_Fechas CHECK (fecha_fin_lectura IS NULL OR fecha_inicio_lectura IS NULL OR fecha_fin_lectura >= fecha_inicio_lectura)
);

CREATE TRIGGER trg_historial_lectura_fecha_modificacion
    BEFORE UPDATE ON Historial_Lectura
    FOR EACH ROW
    EXECUTE FUNCTION fn_actualizar_fecha_modificacion();

-- =========== Comentarios y Calificaciones ===========
CREATE TABLE Comentarios_Calificaciones (
    id_comentario SERIAL PRIMARY KEY,
    id_libro INT NOT NULL,
    id_usuario INT NOT NULL,
    calificacion INT NULL CHECK (calificacion IS NULL OR (calificacion >= 1 AND calificacion <= 5)),
    comentario TEXT NULL,
    fecha_comentario TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    visible BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (id_libro) REFERENCES Libros(id_libro) ON DELETE CASCADE,
    FOREIGN KEY (id_usuario) REFERENCES Usuarios(id_usuario) ON DELETE CASCADE,
    CONSTRAINT CK_Comentario_O_Calificacion CHECK (calificacion IS NOT NULL OR comentario IS NOT NULL)
);

-- =========== Recomendaciones Compartidas ===========
CREATE TABLE Recomendaciones_Compartidas (
    id_recomendacion SERIAL PRIMARY KEY,
    id_libro INT NOT NULL,
    id_usuario_origen INT NOT NULL,
    id_usuario_destino INT NOT NULL,
    mensaje TEXT NULL,
    fecha_recomendacion TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    leido_destino BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (id_libro) REFERENCES Libros(id_libro) ON DELETE CASCADE,
    FOREIGN KEY (id_usuario_origen) REFERENCES Usuarios(id_usuario) ON DELETE CASCADE,
    FOREIGN KEY (id_usuario_destino) REFERENCES Usuarios(id_usuario) ON DELETE CASCADE,
    CONSTRAINT CK_OrigenDestinoDiferentes CHECK (id_usuario_origen != id_usuario_destino)
);

-- =========== Etiquetas (Tags) ===========
CREATE TABLE Etiquetas (
    id_etiqueta SERIAL PRIMARY KEY,
    nombre_etiqueta VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE Libros_Etiquetas (
    id_libro INT NOT NULL,
    id_etiqueta INT NOT NULL,
    PRIMARY KEY (id_libro, id_etiqueta),
    FOREIGN KEY (id_libro) REFERENCES Libros(id_libro) ON DELETE CASCADE,
    FOREIGN KEY (id_etiqueta) REFERENCES Etiquetas(id_etiqueta) ON DELETE CASCADE
);

-- =========== Reservas ===========
CREATE TABLE Reservas (
    id_reserva SERIAL PRIMARY KEY,
    id_ejemplar INT NOT NULL,
    id_usuario INT NOT NULL,
    fecha_reserva TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    fecha_caducidad TIMESTAMPTZ NULL,
    estado_reserva tipo_estado_reserva NOT NULL DEFAULT 'activa',
    posicion_fila INT NULL,
    fecha_modificacion TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    FOREIGN KEY (id_ejemplar) REFERENCES Ejemplares(id_ejemplar) ON DELETE CASCADE,
    FOREIGN KEY (id_usuario) REFERENCES Usuarios(id_usuario) ON DELETE CASCADE,
    CONSTRAINT CK_Reservas_Caducidad CHECK (fecha_caducidad IS NULL OR fecha_caducidad > fecha_reserva)
);

CREATE TRIGGER trg_reservas_fecha_modificacion
    BEFORE UPDATE ON Reservas
    FOR EACH ROW
    EXECUTE FUNCTION fn_actualizar_fecha_modificacion();

-- =========== Logros ===========
CREATE TABLE Logros (
    id_logro SERIAL PRIMARY KEY,
    nombre_logro VARCHAR(100) NOT NULL UNIQUE,
    descripcion TEXT NULL,
    icono_url VARCHAR(255) NULL,
    puntos_recompensa INT DEFAULT 0
);

CREATE TABLE Usuario_Logros (
    id_usuario INT NOT NULL,
    id_logro INT NOT NULL,
    fecha_obtenido TIMESTAMPTZ DEFAULT NOW(),
    PRIMARY KEY (id_usuario, id_logro),
    FOREIGN KEY (id_usuario) REFERENCES Usuarios(id_usuario) ON DELETE CASCADE,
    FOREIGN KEY (id_logro) REFERENCES Logros(id_logro) ON DELETE CASCADE
);

-- =========== Listas de Lectura Personalizadas ===========
CREATE TABLE Listas_Lectura (
    id_lista SERIAL PRIMARY KEY,
    id_usuario INT NOT NULL,
    nombre_lista VARCHAR(100) NOT NULL,
    descripcion TEXT NULL,
    privacidad tipo_privacidad_lista DEFAULT 'publica',
    fecha_creacion TIMESTAMPTZ DEFAULT NOW(),
    fecha_modificacion TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    FOREIGN KEY (id_usuario) REFERENCES Usuarios(id_usuario) ON DELETE CASCADE,
    CONSTRAINT UQ_Usuario_NombreLista UNIQUE (id_usuario, nombre_lista)
);

CREATE TRIGGER trg_listas_lectura_fecha_modificacion
    BEFORE UPDATE ON Listas_Lectura
    FOR EACH ROW
    EXECUTE FUNCTION fn_actualizar_fecha_modificacion();

CREATE TABLE Lista_Libros (
    id_lista INT NOT NULL,
    id_libro INT NOT NULL,
    fecha_agregado TIMESTAMPTZ DEFAULT NOW(),
    orden_en_lista INT NULL,
    PRIMARY KEY (id_lista, id_libro),
    FOREIGN KEY (id_lista) REFERENCES Listas_Lectura(id_lista) ON DELETE CASCADE,
    FOREIGN KEY (id_libro) REFERENCES Libros(id_libro) ON DELETE CASCADE
);

-- =========== Clubes de Lectura y sesiones ===========
CREATE TABLE Clubes_Lectura (
    id_club SERIAL PRIMARY KEY,
    nombre_club VARCHAR(255) NOT NULL UNIQUE,
    descripcion TEXT NULL,
    fecha_creacion TIMESTAMPTZ DEFAULT NOW(),
    id_creador INT NOT NULL,
    imagen_url VARCHAR(255) NULL,
    es_privado BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (id_creador) REFERENCES Usuarios(id_usuario) ON DELETE SET NULL
);

CREATE TABLE Miembros_Club (
    id_club INT NOT NULL,
    id_usuario INT NOT NULL,
    fecha_union TIMESTAMPTZ DEFAULT NOW(),
    rol_miembro tipo_rol_miembro_club DEFAULT 'miembro',
    PRIMARY KEY (id_club, id_usuario),
    FOREIGN KEY (id_club) REFERENCES Clubes_Lectura(id_club) ON DELETE CASCADE,
    FOREIGN KEY (id_usuario) REFERENCES Usuarios(id_usuario) ON DELETE CASCADE
);

CREATE TABLE Sesiones_Club (
    id_sesion SERIAL PRIMARY KEY,
    id_club INT NOT NULL,
    id_libro_discusion INT NULL,
    fecha_hora TIMESTAMPTZ NOT NULL,
    lugar_o_url_virtual VARCHAR(255) NULL,
    tema_discusion TEXT NULL,
    FOREIGN KEY (id_club) REFERENCES Clubes_Lectura(id_club) ON DELETE CASCADE,
    FOREIGN KEY (id_libro_discusion) REFERENCES Libros(id_libro) ON DELETE SET NULL
);

-- =========== Mensajes de Foro del Club ===========
CREATE TABLE Mensajes_Foro_Club (
    id_mensaje SERIAL PRIMARY KEY,
    id_club INT NOT NULL,
    id_usuario_emisor INT NOT NULL,
    mensaje TEXT NOT NULL,
    fecha_mensaje TIMESTAMPTZ DEFAULT NOW(),
    id_mensaje_padre INT NULL,
    FOREIGN KEY (id_club) REFERENCES Clubes_Lectura(id_club) ON DELETE CASCADE,
    FOREIGN KEY (id_usuario_emisor) REFERENCES Usuarios(id_usuario) ON DELETE CASCADE,
    FOREIGN KEY (id_mensaje_padre) REFERENCES Mensajes_Foro_Club(id_mensaje) ON DELETE SET NULL
);


-- =========== Eventos de la Biblioteca ===========
CREATE TABLE Eventos_Biblioteca (
    id_evento SERIAL PRIMARY KEY,
    nombre_evento VARCHAR(255) NOT NULL,
    descripcion TEXT NULL,
    fecha_hora_inicio TIMESTAMPTZ NOT NULL,
    fecha_hora_fin TIMESTAMPTZ NULL,
    ubicacion VARCHAR(255) NULL,
    tipo_evento VARCHAR(50) NULL,
    id_organizador INT NULL,
    url_registro VARCHAR(255) NULL,
    fecha_creacion TIMESTAMPTZ DEFAULT NOW(),
    imagen_url VARCHAR(255) NULL,
    capacidad_maxima INT NULL,
    FOREIGN KEY (id_organizador) REFERENCES Usuarios(id_usuario) ON DELETE SET NULL
);

-- =========== Novedades de la Biblioteca ===========
CREATE TABLE Novedades (
    id_novedad SERIAL PRIMARY KEY,
    titulo VARCHAR(255) NOT NULL,
    contenido TEXT NOT NULL,
    fecha_publicacion TIMESTAMPTZ DEFAULT NOW(),
    id_autor_novedad INT NULL,
    visible BOOLEAN DEFAULT TRUE,
    tipo_novedad VARCHAR(50) DEFAULT 'general',
    imagen_url VARCHAR(255) NULL,
    FOREIGN KEY (id_autor_novedad) REFERENCES Usuarios(id_usuario) ON DELETE SET NULL
);

-- =========== Reportes y Quejas de Usuarios ===========
CREATE TABLE Reportes_Quejas (
    id_reporte SERIAL PRIMARY KEY,
    id_usuario_reporta INT NOT NULL,
    tipo_reporte tipo_reporte_usuario NOT NULL,
    id_objeto_afectado INT NULL,
    tabla_objeto_afectado VARCHAR(100) NULL,
    descripcion TEXT NOT NULL,
    fecha_reporte TIMESTAMPTZ DEFAULT NOW(),
    estado_reporte tipo_estado_reporte DEFAULT 'pendiente',
    comentarios_admin TEXT NULL,
    id_admin_gestion INT NULL,
    fecha_ultima_actualizacion TIMESTAMPTZ DEFAULT NOW(),
    FOREIGN KEY (id_usuario_reporta) REFERENCES Usuarios(id_usuario) ON DELETE CASCADE,
    FOREIGN KEY (id_admin_gestion) REFERENCES Usuarios(id_usuario) ON DELETE SET NULL
);

-- =========== Preferencias del Usuario ===========
CREATE TABLE Preferencias_Usuario (
    id_usuario INT PRIMARY KEY,
    recibir_notificaciones_email BOOLEAN DEFAULT TRUE,
    recibir_notificaciones_app BOOLEAN DEFAULT TRUE,
    tema_interfaz VARCHAR(50) DEFAULT 'claro' CHECK (tema_interfaz IN ('claro', 'oscuro', 'sistema')),
    idioma_preferido VARCHAR(10) DEFAULT 'es',
    permitir_recomendaciones_personalizadas BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (id_usuario) REFERENCES Usuarios(id_usuario) ON DELETE CASCADE
);

-- =========== Favoritos (Géneros y Autores) ===========
CREATE TABLE Usuario_Generos_Favoritos (
    id_usuario INT NOT NULL,
    id_genero INT NOT NULL,
    PRIMARY KEY (id_usuario, id_genero),
    FOREIGN KEY (id_usuario) REFERENCES Usuarios(id_usuario) ON DELETE CASCADE,
    FOREIGN KEY (id_genero) REFERENCES Generos(id_genero) ON DELETE CASCADE
);

CREATE TABLE Usuario_Autores_Favoritos (
    id_usuario INT NOT NULL,
    id_autor INT NOT NULL,
    PRIMARY KEY (id_usuario, id_autor),
    FOREIGN KEY (id_usuario) REFERENCES Usuarios(id_usuario) ON DELETE CASCADE,
    FOREIGN KEY (id_autor) REFERENCES Autores(id_autor) ON DELETE CASCADE
);

-- =========== ÍNDICES RECOMENDADOS ===========

-- Búsqueda de texto completo (título, sinopsis)
CREATE INDEX IF NOT EXISTS idx_libros_titulo_fts ON Libros USING GIN (to_tsvector('spanish', titulo));
CREATE INDEX IF NOT EXISTS idx_libros_sinopsis_fts ON Libros USING GIN (to_tsvector('spanish', sinopsis));
CREATE INDEX IF NOT EXISTS idx_libros_editorial ON Libros (editorial);
CREATE INDEX IF NOT EXISTS idx_libros_idioma ON Libros (idioma);

-- Índices para relaciones y búsquedas frecuentes
CREATE INDEX IF NOT EXISTS idx_ejemplares_id_libro ON Ejemplares (id_libro);
CREATE INDEX IF NOT EXISTS idx_prestamos_id_ejemplar ON Prestamos (id_ejemplar);
CREATE INDEX IF NOT EXISTS idx_prestamos_id_usuario ON Prestamos (id_usuario);
CREATE INDEX IF NOT EXISTS idx_historial_lectura_id_libro ON Historial_Lectura (id_libro);
CREATE INDEX IF NOT EXISTS idx_comentarios_id_libro ON Comentarios_Calificaciones (id_libro);
CREATE INDEX IF NOT EXISTS idx_comentarios_id_usuario ON Comentarios_Calificaciones (id_usuario);
CREATE INDEX IF NOT EXISTS idx_reservas_id_ejemplar ON Reservas (id_ejemplar);
CREATE INDEX IF NOT EXISTS idx_reservas_id_usuario ON Reservas (id_usuario);
CREATE INDEX IF NOT EXISTS idx_reservas_estado_reserva ON Reservas (estado_reserva);

-- Índice único parcial para reservas activas o listas para recoger
DROP INDEX IF EXISTS UQ_Reservas_NoTerminal_Ejemplar_Usuario;
CREATE UNIQUE INDEX UQ_Reservas_NoTerminal_Ejemplar_Usuario
ON Reservas (id_ejemplar, id_usuario)
WHERE estado_reserva IN ('activa', 'lista_para_recoger');

-- =========== FIN DE ESTRUCTURA ===========

-- Todos los triggers de fecha_modificacion ya fueron creados para tablas principales.
-- Puedes añadir triggers de lógica de negocio o scripts de datos después.

--Aqui van los nuevos triggers xd
-- === 1. Trigger para actualizar el contador de libros aprobados por autor (en tabla Libros) ===
CREATE OR REPLACE FUNCTION fn_update_autor_books_count_on_libros_change()
RETURNS TRIGGER AS $$
DECLARE
    v_authors_to_update INT[];
BEGIN
    -- Solo actuar si el estado 'aprobado' está involucrado en el cambio
    IF NOT ( (TG_OP = 'UPDATE' AND OLD.estado_publicacion IS DISTINCT FROM NEW.estado_publicacion AND (OLD.estado_publicacion = 'aprobado' OR NEW.estado_publicacion = 'aprobado'))
          OR (TG_OP = 'INSERT' AND NEW.estado_publicacion = 'aprobado')
          OR (TG_OP = 'DELETE' AND OLD.estado_publicacion = 'aprobado') )
    THEN
        IF TG_OP = 'UPDATE' THEN RETURN NEW; ELSE RETURN NULL; END IF;
    END IF;

    -- Obtener autores del libro afectado
    SELECT ARRAY_AGG(DISTINCT la.id_autor)
    INTO v_authors_to_update
    FROM Libros_Autores la
    WHERE la.id_libro = COALESCE(NEW.id_libro, OLD.id_libro);

    IF array_length(v_authors_to_update, 1) > 0 THEN
        UPDATE Autores a
        SET libros_publicados_contador = (
            SELECT COUNT(DISTINCT l_inner.id_libro)
            FROM Libros_Autores la_inner
            JOIN Libros l_inner ON la_inner.id_libro = l_inner.id_libro
            WHERE la_inner.id_autor = a.id_autor AND l_inner.estado_publicacion = 'aprobado'
        )
        WHERE a.id_autor = ANY(v_authors_to_update);
    END IF;

    IF TG_OP = 'UPDATE' THEN RETURN NEW; ELSE RETURN NULL; END IF;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_libros_update_autor_count ON Libros;
CREATE TRIGGER trg_libros_update_autor_count
AFTER INSERT OR DELETE OR UPDATE OF estado_publicacion ON Libros
FOR EACH ROW
EXECUTE FUNCTION fn_update_autor_books_count_on_libros_change();

-- === 2. Trigger para actualizar contador desde Libros_Autores (cuando se añade o elimina asociación autor-libro) ===
CREATE OR REPLACE FUNCTION fn_update_autor_books_count_on_libros_autores_change()
RETURNS TRIGGER AS $$
DECLARE
    v_author_id INT;
    v_libro_id INT;
    v_libro_estado tipo_estado_publicacion;
BEGIN
    IF TG_OP = 'INSERT' THEN
        v_author_id := NEW.id_autor;
        v_libro_id := NEW.id_libro;
    ELSIF TG_OP = 'DELETE' THEN
        v_author_id := OLD.id_autor;
        v_libro_id := OLD.id_libro;
    END IF;

    SELECT estado_publicacion INTO v_libro_estado FROM Libros WHERE id_libro = v_libro_id;

    IF v_author_id IS NOT NULL AND v_libro_estado = 'aprobado' THEN
        UPDATE Autores AS a
        SET libros_publicados_contador = (
            SELECT COUNT(DISTINCT l.id_libro)
            FROM Libros_Autores la_inner
            JOIN Libros l ON la_inner.id_libro = l.id_libro
            WHERE la_inner.id_autor = a.id_autor
              AND l.estado_publicacion = 'aprobado'
        )
        WHERE a.id_autor = v_author_id;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_librosautores_update_autor_count ON Libros_Autores;
CREATE TRIGGER trg_librosautores_update_autor_count
AFTER INSERT OR DELETE ON Libros_Autores
FOR EACH ROW
EXECUTE FUNCTION fn_update_autor_books_count_on_libros_autores_change();

-- === 3. Trigger para actualizar estado del ejemplar al prestar/devolver ===
CREATE OR REPLACE FUNCTION fn_update_ejemplar_status_on_prestamo()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' AND NEW.estado_prestamo = 'activo' THEN
        UPDATE Ejemplares
        SET estado_ejemplar = 'prestado'
        WHERE id_ejemplar = NEW.id_ejemplar AND estado_ejemplar IN ('disponible', 'reservado');
    ELSIF TG_OP = 'UPDATE' THEN
        IF NEW.estado_prestamo = 'activo' AND OLD.estado_prestamo IS DISTINCT FROM 'activo' THEN
             UPDATE Ejemplares
             SET estado_ejemplar = 'prestado'
             WHERE id_ejemplar = NEW.id_ejemplar AND estado_ejemplar IN ('disponible', 'reservado');
        ELSIF OLD.estado_prestamo = 'activo' AND NEW.estado_prestamo IN ('devuelto', 'cancelado') THEN
            IF EXISTS (SELECT 1 FROM Reservas WHERE id_ejemplar = OLD.id_ejemplar AND estado_reserva IN ('activa', 'lista_para_recoger') ORDER BY fecha_reserva LIMIT 1) THEN
                UPDATE Ejemplares
                SET estado_ejemplar = 'reservado'
                WHERE id_ejemplar = OLD.id_ejemplar;
            ELSE
                UPDATE Ejemplares
                SET estado_ejemplar = 'disponible'
                WHERE id_ejemplar = OLD.id_ejemplar;
            END IF;
        END IF;
    END IF;
    IF TG_OP = 'UPDATE' THEN RETURN NEW; ELSE RETURN NULL; END IF;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_prestamo_estado_ejemplar ON Prestamos;
CREATE TRIGGER trg_prestamo_estado_ejemplar
AFTER INSERT OR UPDATE OF estado_prestamo ON Prestamos
FOR EACH ROW
EXECUTE FUNCTION fn_update_ejemplar_status_on_prestamo();

-- === 4. Trigger para actualizar estado del ejemplar al reservar/cancelar reserva ===
CREATE OR REPLACE FUNCTION fn_update_ejemplar_status_on_reserva()
RETURNS TRIGGER AS $$
DECLARE
    v_ejemplar_id INT;
BEGIN
    IF TG_OP = 'INSERT' THEN v_ejemplar_id := NEW.id_ejemplar;
    ELSIF TG_OP = 'UPDATE' THEN v_ejemplar_id := NEW.id_ejemplar;
    ELSIF TG_OP = 'DELETE' THEN v_ejemplar_id := OLD.id_ejemplar;
    END IF;

    -- Solo actualizar estado si el ejemplar NO está 'prestado' activamente
    IF NOT EXISTS (SELECT 1 FROM Prestamos WHERE id_ejemplar = v_ejemplar_id AND estado_prestamo = 'activo') THEN
        IF (TG_OP = 'INSERT' AND NEW.estado_reserva IN ('activa', 'lista_para_recoger')) OR
           (TG_OP = 'UPDATE' AND NEW.estado_reserva IN ('activa', 'lista_para_recoger') AND OLD.estado_reserva IS DISTINCT FROM NEW.estado_reserva) THEN
            UPDATE Ejemplares SET estado_ejemplar = 'reservado' WHERE id_ejemplar = v_ejemplar_id AND estado_ejemplar = 'disponible';
        ELSIF (TG_OP = 'DELETE' AND OLD.estado_reserva IN ('activa', 'lista_para_recoger')) OR
              (TG_OP = 'UPDATE' AND OLD.estado_reserva IN ('activa', 'lista_para_recoger') AND NEW.estado_reserva NOT IN ('activa', 'lista_para_recoger')) THEN
            IF NOT EXISTS (SELECT 1 FROM Reservas WHERE id_ejemplar = v_ejemplar_id AND estado_reserva IN ('activa', 'lista_para_recoger') AND (TG_OP = 'DELETE' OR id_reserva != NEW.id_reserva)) THEN
                 UPDATE Ejemplares SET estado_ejemplar = 'disponible' WHERE id_ejemplar = v_ejemplar_id AND estado_ejemplar = 'reservado';
            END IF;
        END IF;
    END IF;
    IF TG_OP = 'UPDATE' THEN RETURN NEW; ELSE RETURN NULL; END IF;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_reserva_estado_ejemplar ON Reservas;
CREATE TRIGGER trg_reserva_estado_ejemplar
AFTER INSERT OR UPDATE OF estado_reserva OR DELETE ON Reservas
FOR EACH ROW
EXECUTE FUNCTION fn_update_ejemplar_status_on_reserva();



-- =========== FIN DEL SCRIPT ESTRUCTURAL ===========



