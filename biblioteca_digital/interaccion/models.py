from django.db import models

# Create your models here.
class HistorialLectura(models.Model):
    """Registro del avance y estado de lectura de libros por usuario."""
    id_historial = models.AutoField(primary_key=True)
    id_usuario = models.ForeignKey('usuarios.Usuarios', models.DO_NOTHING, db_column='id_usuario')
    id_libro = models.ForeignKey('catalogo.Libros', models.DO_NOTHING, db_column='id_libro')
    fecha_inicio_lectura = models.DateTimeField(blank=True, null=True)
    fecha_fin_lectura = models.DateTimeField(blank=True, null=True)
    estado_lectura = models.TextField()
    ultima_pagina_leida = models.IntegerField(blank=True, null=True)
    fecha_creacion = models.DateTimeField()
    fecha_modificacion = models.DateTimeField()
    class Meta:
        managed = False
        db_table = 'historial_lectura'
        unique_together = (('id_usuario', 'id_libro'),)
    def __str__(self):
        return f"{self.id_usuario} - {self.id_libro} ({self.estado_lectura})"

class ComentariosCalificaciones(models.Model):
    """Comentarios y calificaciones de libros por usuarios."""
    id_comentario = models.AutoField(primary_key=True)
    id_libro = models.ForeignKey('catalogo.Libros', models.DO_NOTHING, db_column='id_libro')
    id_usuario = models.ForeignKey('usuarios.Usuarios', models.DO_NOTHING, db_column='id_usuario')
    calificacion = models.IntegerField(blank=True, null=True)
    comentario = models.TextField(blank=True, null=True)
    fecha_comentario = models.DateTimeField()
    visible = models.BooleanField(blank=True, null=True)
    class Meta:
        managed = False
        db_table = 'comentarios_calificaciones'
    def __str__(self):
        return f"Comentario #{self.id_comentario} de {self.id_usuario} a {self.id_libro}"

class RecomendacionesCompartidas(models.Model):
    """Recomendaciones personalizadas de libros entre usuarios."""
    id_recomendacion = models.AutoField(primary_key=True)
    id_libro = models.ForeignKey('catalogo.Libros', models.DO_NOTHING, db_column='id_libro')
    id_usuario_origen = models.ForeignKey('usuarios.Usuarios', models.DO_NOTHING, db_column='id_usuario_origen')
    id_usuario_destino = models.ForeignKey('usuarios.Usuarios', models.DO_NOTHING, db_column='id_usuario_destino', related_name='recomendaciones_destino')
    mensaje = models.TextField(blank=True, null=True)
    fecha_recomendacion = models.DateTimeField()
    leido_destino = models.BooleanField(blank=True, null=True)
    class Meta:
        managed = False
        db_table = 'recomendaciones_compartidas'
    def __str__(self):
        return f"Recomendación #{self.id_recomendacion} de {self.id_usuario_origen} a {self.id_usuario_destino}"

class ListasLectura(models.Model):
    """Listas de lectura personalizadas por usuario."""
    id_lista = models.AutoField(primary_key=True)
    id_usuario = models.ForeignKey('usuarios.Usuarios', models.DO_NOTHING, db_column='id_usuario')
    nombre_lista = models.CharField(max_length=100)
    descripcion = models.TextField(blank=True, null=True)
    privacidad = models.TextField(blank=True, null=True)
    fecha_creacion = models.DateTimeField(blank=True, null=True)
    fecha_modificacion = models.DateTimeField()
    class Meta:
        managed = False
        db_table = 'listas_lectura'
        unique_together = (('id_usuario', 'nombre_lista'),)
    def __str__(self):
        return f"{self.nombre_lista} ({self.id_usuario})"

class ListaLibros(models.Model):
    """Relación muchos a muchos entre listas de lectura y libros."""
    id_lista = models.ForeignKey('interaccion.ListasLectura', models.DO_NOTHING, db_column='id_lista')
    id_libro = models.ForeignKey('catalogo.Libros', models.DO_NOTHING, db_column='id_libro')
    fecha_agregado = models.DateTimeField(blank=True, null=True)
    orden_en_lista = models.IntegerField(blank=True, null=True)
    class Meta:
        managed = False
        db_table = 'lista_libros'
        unique_together = (('id_lista', 'id_libro'),)
    def __str__(self):
        return f"Libro {self.id_libro} en {self.id_lista}"

class Logros(models.Model):
    """Logros y recompensas por actividad en la plataforma."""
    id_logro = models.AutoField(primary_key=True)
    nombre_logro = models.CharField(unique=True, max_length=100)
    descripcion = models.TextField(blank=True, null=True)
    icono_url = models.CharField(max_length=255, blank=True, null=True)
    puntos_recompensa = models.IntegerField(blank=True, null=True)
    class Meta:
        managed = False
        db_table = 'logros'
    def __str__(self):
        return self.nombre_logro

class UsuarioLogros(models.Model):
    """Logros obtenidos por cada usuario."""
    id_usuario = models.ForeignKey('usuarios.Usuarios', models.DO_NOTHING, db_column='id_usuario')
    id_logro = models.ForeignKey('interaccion.Logros', models.DO_NOTHING, db_column='id_logro')
    fecha_obtenido = models.DateTimeField(blank=True, null=True)
    class Meta:
        managed = False
        db_table = 'usuario_logros'
        unique_together = (('id_usuario', 'id_logro'),)
    def __str__(self):
        return f"{self.id_usuario} => {self.id_logro}"