# This is an auto-generated Django model module.
# You'll have to do the following manually to clean this up:
#   * Rearrange models' order
#   * Make sure each model has one field with primary_key=True
#   * Make sure each ForeignKey and OneToOneField has `on_delete` set to the desired behavior
#   * Remove `managed = False` lines if you wish to allow Django to create, modify, and delete the table
# Feel free to rename the models, but don't rename db_table values or field names.
from django.db import models


class Autores(models.Model):
    id_autor = models.OneToOneField('Usuarios', models.DO_NOTHING, db_column='id_autor', primary_key=True)
    biografia = models.TextField(blank=True, null=True)
    sitio_web = models.CharField(max_length=255, blank=True, null=True)
    libros_publicados_contador = models.IntegerField()
    fecha_creacion = models.DateTimeField()
    fecha_modificacion = models.DateTimeField()

    class Meta:
        managed = False
        db_table = 'autores'


class ClubesLectura(models.Model):
    id_club = models.AutoField(primary_key=True)
    nombre_club = models.CharField(unique=True, max_length=255)
    descripcion = models.TextField(blank=True, null=True)
    fecha_creacion = models.DateTimeField(blank=True, null=True)
    id_creador = models.ForeignKey('Usuarios', models.DO_NOTHING, db_column='id_creador')
    imagen_url = models.CharField(max_length=255, blank=True, null=True)
    es_privado = models.BooleanField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'clubes_lectura'


class ComentariosCalificaciones(models.Model):
    id_comentario = models.AutoField(primary_key=True)
    id_libro = models.ForeignKey('Libros', models.DO_NOTHING, db_column='id_libro')
    id_usuario = models.ForeignKey('Usuarios', models.DO_NOTHING, db_column='id_usuario')
    calificacion = models.IntegerField(blank=True, null=True)
    comentario = models.TextField(blank=True, null=True)
    fecha_comentario = models.DateTimeField()
    visible = models.BooleanField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'comentarios_calificaciones'


class Ejemplares(models.Model):
    id_ejemplar = models.AutoField(primary_key=True)
    id_libro = models.ForeignKey('Libros', models.DO_NOTHING, db_column='id_libro')
    numero_inventario = models.CharField(unique=True, max_length=100, blank=True, null=True)
    estado_ejemplar = models.TextField()  # This field type is a guess.
    ubicacion = models.CharField(max_length=255, blank=True, null=True)
    es_digital = models.BooleanField()
    notas_ejemplar = models.TextField(blank=True, null=True)
    fecha_adquisicion = models.DateField(blank=True, null=True)
    fecha_creacion = models.DateTimeField()
    fecha_modificacion = models.DateTimeField()

    class Meta:
        managed = False
        db_table = 'ejemplares'


class Etiquetas(models.Model):
    id_etiqueta = models.AutoField(primary_key=True)
    nombre_etiqueta = models.CharField(unique=True, max_length=100)

    class Meta:
        managed = False
        db_table = 'etiquetas'


class EventosBiblioteca(models.Model):
    id_evento = models.AutoField(primary_key=True)
    nombre_evento = models.CharField(max_length=255)
    descripcion = models.TextField(blank=True, null=True)
    fecha_hora_inicio = models.DateTimeField()
    fecha_hora_fin = models.DateTimeField(blank=True, null=True)
    ubicacion = models.CharField(max_length=255, blank=True, null=True)
    tipo_evento = models.CharField(max_length=50, blank=True, null=True)
    id_organizador = models.ForeignKey('Usuarios', models.DO_NOTHING, db_column='id_organizador', blank=True, null=True)
    url_registro = models.CharField(max_length=255, blank=True, null=True)
    fecha_creacion = models.DateTimeField(blank=True, null=True)
    imagen_url = models.CharField(max_length=255, blank=True, null=True)
    capacidad_maxima = models.IntegerField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'eventos_biblioteca'


class Generos(models.Model):
    id_genero = models.AutoField(primary_key=True)
    nombre = models.CharField(unique=True, max_length=100)
    descripcion = models.TextField(blank=True, null=True)
    fecha_creacion = models.DateTimeField()
    fecha_modificacion = models.DateTimeField()

    class Meta:
        managed = False
        db_table = 'generos'


class HistorialLectura(models.Model):
    id_historial = models.AutoField(primary_key=True)
    id_usuario = models.ForeignKey('Usuarios', models.DO_NOTHING, db_column='id_usuario')
    id_libro = models.ForeignKey('Libros', models.DO_NOTHING, db_column='id_libro')
    fecha_inicio_lectura = models.DateTimeField(blank=True, null=True)
    fecha_fin_lectura = models.DateTimeField(blank=True, null=True)
    estado_lectura = models.TextField()  # This field type is a guess.
    ultima_pagina_leida = models.IntegerField(blank=True, null=True)
    fecha_creacion = models.DateTimeField()
    fecha_modificacion = models.DateTimeField()

    class Meta:
        managed = False
        db_table = 'historial_lectura'
        unique_together = (('id_usuario', 'id_libro'),)


class HistorialPrestamos(models.Model):
    id_historial = models.AutoField(primary_key=True)
    id_prestamo = models.ForeignKey('Prestamos', models.DO_NOTHING, db_column='id_prestamo')
    id_usuario = models.ForeignKey('Usuarios', models.DO_NOTHING, db_column='id_usuario')
    id_ejemplar = models.ForeignKey(Ejemplares, models.DO_NOTHING, db_column='id_ejemplar')
    accion = models.CharField(max_length=20)
    fecha_accion = models.DateTimeField()
    observaciones = models.TextField(blank=True, null=True)
    usuario_registra = models.CharField(max_length=100, blank=True, null=True)
    fecha_registro = models.DateTimeField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'historial_prestamos'


class Libros(models.Model):
    id_libro = models.AutoField(primary_key=True)
    titulo = models.CharField(max_length=255)
    isbn = models.CharField(unique=True, max_length=20, blank=True, null=True)
    sinopsis = models.TextField(blank=True, null=True)
    ano_publicacion = models.IntegerField(blank=True, null=True)
    editorial = models.CharField(max_length=255, blank=True, null=True)
    portada_url = models.CharField(max_length=255, blank=True, null=True)
    archivo_libro_url = models.CharField(max_length=255, blank=True, null=True)
    id_autor_subida = models.ForeignKey(Autores, models.DO_NOTHING, db_column='id_autor_subida', blank=True, null=True)
    id_admin_aprobacion = models.ForeignKey('Usuarios', models.DO_NOTHING, db_column='id_admin_aprobacion', blank=True, null=True)
    estado_publicacion = models.TextField()  # This field type is a guess.
    fecha_subida = models.DateTimeField()
    fecha_aprobacion = models.DateTimeField(blank=True, null=True)
    idioma = models.CharField(max_length=50, blank=True, null=True)
    numero_paginas = models.IntegerField(blank=True, null=True)
    fecha_modificacion = models.DateTimeField()

    class Meta:
        managed = False
        db_table = 'libros'


class LibrosAutores(models.Model):
    id_libro = models.OneToOneField(Libros, models.DO_NOTHING, db_column='id_libro', primary_key=True)  # The composite primary key (id_libro, id_autor) found, that is not supported. The first column is selected.
    id_autor = models.ForeignKey(Autores, models.DO_NOTHING, db_column='id_autor')
    rol_autor = models.CharField(max_length=50, blank=True, null=True)
    fecha_asociacion = models.DateTimeField()

    class Meta:
        managed = False
        db_table = 'libros_autores'
        unique_together = (('id_libro', 'id_autor'),)


class LibrosEtiquetas(models.Model):
    id_libro = models.OneToOneField(Libros, models.DO_NOTHING, db_column='id_libro', primary_key=True)  # The composite primary key (id_libro, id_etiqueta) found, that is not supported. The first column is selected.
    id_etiqueta = models.ForeignKey(Etiquetas, models.DO_NOTHING, db_column='id_etiqueta')

    class Meta:
        managed = False
        db_table = 'libros_etiquetas'
        unique_together = (('id_libro', 'id_etiqueta'),)


class LibrosGeneros(models.Model):
    id_libro = models.OneToOneField(Libros, models.DO_NOTHING, db_column='id_libro', primary_key=True)  # The composite primary key (id_libro, id_genero) found, that is not supported. The first column is selected.
    id_genero = models.ForeignKey(Generos, models.DO_NOTHING, db_column='id_genero')
    fecha_asociacion = models.DateTimeField()

    class Meta:
        managed = False
        db_table = 'libros_generos'
        unique_together = (('id_libro', 'id_genero'),)


class ListaLibros(models.Model):
    id_lista = models.OneToOneField('ListasLectura', models.DO_NOTHING, db_column='id_lista', primary_key=True)  # The composite primary key (id_lista, id_libro) found, that is not supported. The first column is selected.
    id_libro = models.ForeignKey(Libros, models.DO_NOTHING, db_column='id_libro')
    fecha_agregado = models.DateTimeField(blank=True, null=True)
    orden_en_lista = models.IntegerField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'lista_libros'
        unique_together = (('id_lista', 'id_libro'),)


class ListasLectura(models.Model):
    id_lista = models.AutoField(primary_key=True)
    id_usuario = models.ForeignKey('Usuarios', models.DO_NOTHING, db_column='id_usuario')
    nombre_lista = models.CharField(max_length=100)
    descripcion = models.TextField(blank=True, null=True)
    privacidad = models.TextField(blank=True, null=True)  # This field type is a guess.
    fecha_creacion = models.DateTimeField(blank=True, null=True)
    fecha_modificacion = models.DateTimeField()

    class Meta:
        managed = False
        db_table = 'listas_lectura'
        unique_together = (('id_usuario', 'nombre_lista'),)


class Logros(models.Model):
    id_logro = models.AutoField(primary_key=True)
    nombre_logro = models.CharField(unique=True, max_length=100)
    descripcion = models.TextField(blank=True, null=True)
    icono_url = models.CharField(max_length=255, blank=True, null=True)
    puntos_recompensa = models.IntegerField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'logros'


class MensajesForoClub(models.Model):
    id_mensaje = models.AutoField(primary_key=True)
    id_club = models.ForeignKey(ClubesLectura, models.DO_NOTHING, db_column='id_club')
    id_usuario_emisor = models.ForeignKey('Usuarios', models.DO_NOTHING, db_column='id_usuario_emisor')
    mensaje = models.TextField()
    fecha_mensaje = models.DateTimeField(blank=True, null=True)
    id_mensaje_padre = models.ForeignKey('self', models.DO_NOTHING, db_column='id_mensaje_padre', blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'mensajes_foro_club'


class MiembrosClub(models.Model):
    id_club = models.OneToOneField(ClubesLectura, models.DO_NOTHING, db_column='id_club', primary_key=True)  # The composite primary key (id_club, id_usuario) found, that is not supported. The first column is selected.
    id_usuario = models.ForeignKey('Usuarios', models.DO_NOTHING, db_column='id_usuario')
    fecha_union = models.DateTimeField(blank=True, null=True)
    rol_miembro = models.TextField(blank=True, null=True)  # This field type is a guess.

    class Meta:
        managed = False
        db_table = 'miembros_club'
        unique_together = (('id_club', 'id_usuario'),)


class Multas(models.Model):
    id_multa = models.AutoField(primary_key=True)
    id_prestamo = models.ForeignKey('Prestamos', models.DO_NOTHING, db_column='id_prestamo')
    fecha_generada = models.DateField()
    fecha_pago = models.DateField(blank=True, null=True)
    monto = models.DecimalField(max_digits=8, decimal_places=2)
    estado = models.CharField(max_length=20)
    observaciones = models.TextField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'multas'


class Novedades(models.Model):
    id_novedad = models.AutoField(primary_key=True)
    titulo = models.CharField(max_length=255)
    contenido = models.TextField()
    fecha_publicacion = models.DateTimeField(blank=True, null=True)
    id_autor_novedad = models.ForeignKey('Usuarios', models.DO_NOTHING, db_column='id_autor_novedad', blank=True, null=True)
    visible = models.BooleanField(blank=True, null=True)
    tipo_novedad = models.CharField(max_length=50, blank=True, null=True)
    imagen_url = models.CharField(max_length=255, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'novedades'


class PreferenciasUsuario(models.Model):
    id_usuario = models.OneToOneField('Usuarios', models.DO_NOTHING, db_column='id_usuario', primary_key=True)
    recibir_notificaciones_email = models.BooleanField(blank=True, null=True)
    recibir_notificaciones_app = models.BooleanField(blank=True, null=True)
    tema_interfaz = models.CharField(max_length=50, blank=True, null=True)
    idioma_preferido = models.CharField(max_length=10, blank=True, null=True)
    permitir_recomendaciones_personalizadas = models.BooleanField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'preferencias_usuario'


class Prestamos(models.Model):
    id_prestamo = models.AutoField(primary_key=True)
    id_ejemplar = models.ForeignKey(Ejemplares, models.DO_NOTHING, db_column='id_ejemplar')
    id_usuario = models.ForeignKey('Usuarios', models.DO_NOTHING, db_column='id_usuario')
    fecha_prestamo = models.DateTimeField()
    fecha_devolucion_estimada = models.DateTimeField()
    fecha_devolucion_real = models.DateTimeField(blank=True, null=True)
    estado_prestamo = models.TextField()  # This field type is a guess.
    multa_aplicada = models.DecimalField(max_digits=10, decimal_places=2, blank=True, null=True)
    fecha_modificacion = models.DateTimeField()

    class Meta:
        managed = False
        db_table = 'prestamos'


class RecomendacionesCompartidas(models.Model):
    id_recomendacion = models.AutoField(primary_key=True)
    id_libro = models.ForeignKey(Libros, models.DO_NOTHING, db_column='id_libro')
    id_usuario_origen = models.ForeignKey('Usuarios', models.DO_NOTHING, db_column='id_usuario_origen')
    id_usuario_destino = models.ForeignKey('Usuarios', models.DO_NOTHING, db_column='id_usuario_destino', related_name='recomendacionescompartidas_id_usuario_destino_set')
    mensaje = models.TextField(blank=True, null=True)
    fecha_recomendacion = models.DateTimeField()
    leido_destino = models.BooleanField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'recomendaciones_compartidas'


class ReportesQuejas(models.Model):
    id_reporte = models.AutoField(primary_key=True)
    id_usuario_reporta = models.ForeignKey('Usuarios', models.DO_NOTHING, db_column='id_usuario_reporta')
    tipo_reporte = models.TextField()  # This field type is a guess.
    id_objeto_afectado = models.IntegerField(blank=True, null=True)
    tabla_objeto_afectado = models.CharField(max_length=100, blank=True, null=True)
    descripcion = models.TextField()
    fecha_reporte = models.DateTimeField(blank=True, null=True)
    estado_reporte = models.TextField(blank=True, null=True)  # This field type is a guess.
    comentarios_admin = models.TextField(blank=True, null=True)
    id_admin_gestion = models.ForeignKey('Usuarios', models.DO_NOTHING, db_column='id_admin_gestion', related_name='reportesquejas_id_admin_gestion_set', blank=True, null=True)
    fecha_ultima_actualizacion = models.DateTimeField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'reportes_quejas'


class Reservas(models.Model):
    id_reserva = models.AutoField(primary_key=True)
    id_ejemplar = models.ForeignKey(Ejemplares, models.DO_NOTHING, db_column='id_ejemplar')
    id_usuario = models.ForeignKey('Usuarios', models.DO_NOTHING, db_column='id_usuario')
    fecha_reserva = models.DateTimeField()
    fecha_caducidad = models.DateTimeField(blank=True, null=True)
    estado_reserva = models.TextField()  # This field type is a guess.
    posicion_fila = models.IntegerField(blank=True, null=True)
    fecha_modificacion = models.DateTimeField()

    class Meta:
        managed = False
        db_table = 'reservas'
        unique_together = (('id_ejemplar', 'id_usuario'),)


class Roles(models.Model):
    id_rol = models.AutoField(primary_key=True)
    nombre_rol = models.CharField(unique=True, max_length=50)
    descripcion_rol = models.TextField(blank=True, null=True)
    fecha_creacion = models.DateTimeField()
    fecha_modificacion = models.DateTimeField()

    class Meta:
        managed = False
        db_table = 'roles'


class SesionesClub(models.Model):
    id_sesion = models.AutoField(primary_key=True)
    id_club = models.ForeignKey(ClubesLectura, models.DO_NOTHING, db_column='id_club')
    id_libro_discusion = models.ForeignKey(Libros, models.DO_NOTHING, db_column='id_libro_discusion', blank=True, null=True)
    fecha_hora = models.DateTimeField()
    lugar_o_url_virtual = models.CharField(max_length=255, blank=True, null=True)
    tema_discusion = models.TextField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'sesiones_club'


class UsuarioAutoresFavoritos(models.Model):
    id_usuario = models.OneToOneField('Usuarios', models.DO_NOTHING, db_column='id_usuario', primary_key=True)  # The composite primary key (id_usuario, id_autor) found, that is not supported. The first column is selected.
    id_autor = models.ForeignKey(Autores, models.DO_NOTHING, db_column='id_autor')

    class Meta:
        managed = False
        db_table = 'usuario_autores_favoritos'
        unique_together = (('id_usuario', 'id_autor'),)


class UsuarioGenerosFavoritos(models.Model):
    id_usuario = models.OneToOneField('Usuarios', models.DO_NOTHING, db_column='id_usuario', primary_key=True)  # The composite primary key (id_usuario, id_genero) found, that is not supported. The first column is selected.
    id_genero = models.ForeignKey(Generos, models.DO_NOTHING, db_column='id_genero')

    class Meta:
        managed = False
        db_table = 'usuario_generos_favoritos'
        unique_together = (('id_usuario', 'id_genero'),)


class UsuarioLogros(models.Model):
    id_usuario = models.OneToOneField('Usuarios', models.DO_NOTHING, db_column='id_usuario', primary_key=True)  # The composite primary key (id_usuario, id_logro) found, that is not supported. The first column is selected.
    id_logro = models.ForeignKey(Logros, models.DO_NOTHING, db_column='id_logro')
    fecha_obtenido = models.DateTimeField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'usuario_logros'
        unique_together = (('id_usuario', 'id_logro'),)


class UsuarioRoles(models.Model):
    id_usuario = models.OneToOneField('Usuarios', models.DO_NOTHING, db_column='id_usuario', primary_key=True)  # The composite primary key (id_usuario, id_rol) found, that is not supported. The first column is selected.
    id_rol = models.ForeignKey(Roles, models.DO_NOTHING, db_column='id_rol')
    fecha_asignacion = models.DateTimeField()

    class Meta:
        managed = False
        db_table = 'usuario_roles'
        unique_together = (('id_usuario', 'id_rol'),)


class Usuarios(models.Model):
    id_usuario = models.AutoField(primary_key=True)
    nombre_usuario = models.CharField(unique=True, max_length=255)
    contrasena = models.CharField(max_length=255)
    correo_electronico = models.CharField(unique=True, max_length=255)
    nombre_completo = models.CharField(max_length=255, blank=True, null=True)
    fecha_creacion = models.DateTimeField()
    fecha_modificacion = models.DateTimeField()
    activo = models.BooleanField()

    class Meta:
        managed = False
        db_table = 'usuarios'
