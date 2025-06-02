from django.db import models

# Create your models here.
class ClubesLectura(models.Model):
    """Clubes de lectura organizados por usuarios."""
    id_club = models.AutoField(primary_key=True)
    nombre_club = models.CharField(unique=True, max_length=255)
    descripcion = models.TextField(blank=True, null=True)
    fecha_creacion = models.DateTimeField(blank=True, null=True)
    id_creador = models.ForeignKey('usuarios.Usuarios', models.DO_NOTHING, db_column='id_creador')
    imagen_url = models.CharField(max_length=255, blank=True, null=True)
    es_privado = models.BooleanField(blank=True, null=True)
    class Meta:
        managed = False
        db_table = 'clubes_lectura'
    def __str__(self):
        return self.nombre_club

class MiembrosClub(models.Model):
    """Relación miembros-clubes de lectura."""
    id_club = models.ForeignKey('comunidad.ClubesLectura', models.DO_NOTHING, db_column='id_club')
    id_usuario = models.ForeignKey('usuarios.Usuarios', models.DO_NOTHING, db_column='id_usuario')
    fecha_union = models.DateTimeField(blank=True, null=True)
    rol_miembro = models.TextField(blank=True, null=True)
    class Meta:
        managed = False
        db_table = 'miembros_club'
        unique_together = (('id_club', 'id_usuario'),)
    def __str__(self):
        return f"{self.id_usuario} en {self.id_club} ({self.rol_miembro})"

class SesionesClub(models.Model):
    """Sesiones y reuniones de clubes de lectura."""
    id_sesion = models.AutoField(primary_key=True)
    id_club = models.ForeignKey('comunidad.ClubesLectura', models.DO_NOTHING, db_column='id_club')
    id_libro_discusion = models.ForeignKey('catalogo.Libros', models.DO_NOTHING, db_column='id_libro_discusion', blank=True, null=True)
    fecha_hora = models.DateTimeField()
    lugar_o_url_virtual = models.CharField(max_length=255, blank=True, null=True)
    tema_discusion = models.TextField(blank=True, null=True)
    class Meta:
        managed = False
        db_table = 'sesiones_club'
    def __str__(self):
        return f"Sesión {self.id_sesion} en {self.id_club}"

class MensajesForoClub(models.Model):
    """Mensajes publicados en los foros internos de los clubes de lectura."""
    id_mensaje = models.AutoField(primary_key=True)
    id_club = models.ForeignKey('comunidad.ClubesLectura', models.DO_NOTHING, db_column='id_club')
    id_usuario_emisor = models.ForeignKey('usuarios.Usuarios', models.DO_NOTHING, db_column='id_usuario_emisor')
    mensaje = models.TextField()
    fecha_mensaje = models.DateTimeField(blank=True, null=True)
    id_mensaje_padre = models.ForeignKey('self', models.DO_NOTHING, db_column='id_mensaje_padre', blank=True, null=True)
    class Meta:
        managed = False
        db_table = 'mensajes_foro_club'
    def __str__(self):
        return f"Mensaje {self.id_mensaje} en {self.id_club}"

class EventosBiblioteca(models.Model):
    """Eventos organizados por la biblioteca (presentaciones, talleres, etc.)."""
    id_evento = models.AutoField(primary_key=True)
    nombre_evento = models.CharField(max_length=255)
    descripcion = models.TextField(blank=True, null=True)
    fecha_hora_inicio = models.DateTimeField()
    fecha_hora_fin = models.DateTimeField(blank=True, null=True)
    ubicacion = models.CharField(max_length=255, blank=True, null=True)
    tipo_evento = models.CharField(max_length=50, blank=True, null=True)
    id_organizador = models.ForeignKey('usuarios.Usuarios', models.DO_NOTHING, db_column='id_organizador', blank=True, null=True)
    url_registro = models.CharField(max_length=255, blank=True, null=True)
    fecha_creacion = models.DateTimeField(blank=True, null=True)
    imagen_url = models.CharField(max_length=255, blank=True, null=True)
    capacidad_maxima = models.IntegerField(blank=True, null=True)
    class Meta:
        managed = False
        db_table = 'eventos_biblioteca'
    def __str__(self):
        return self.nombre_evento

class Novedades(models.Model):
    """Noticias, anuncios y novedades publicados por la biblioteca."""
    id_novedad = models.AutoField(primary_key=True)
    titulo = models.CharField(max_length=255)
    contenido = models.TextField()
    fecha_publicacion = models.DateTimeField(blank=True, null=True)
    id_autor_novedad = models.ForeignKey('usuarios.Usuarios', models.DO_NOTHING, db_column='id_autor_novedad', blank=True, null=True)
    visible = models.BooleanField(blank=True, null=True)
    tipo_novedad = models.CharField(max_length=50, blank=True, null=True)
    imagen_url = models.CharField(max_length=255, blank=True, null=True)
    class Meta:
        managed = False
        db_table = 'novedades'
    def __str__(self):
        return self.titulo