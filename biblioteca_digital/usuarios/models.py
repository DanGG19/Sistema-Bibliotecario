from django.db import models

# Create your models here.

class Usuarios(models.Model):
    """Modelo de usuarios del sistema."""
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
    def __str__(self):
        return f"{self.nombre_usuario} ({self.correo_electronico})"

class Roles(models.Model):
    """Catálogo de roles de usuario."""
    id_rol = models.AutoField(primary_key=True)
    nombre_rol = models.CharField(unique=True, max_length=50)
    descripcion_rol = models.TextField(blank=True, null=True)
    fecha_creacion = models.DateTimeField()
    fecha_modificacion = models.DateTimeField()
    class Meta:
        managed = False
        db_table = 'roles'
    def __str__(self):
        return self.nombre_rol

class UsuarioRoles(models.Model):
    """Relación muchos a muchos entre usuarios y roles."""
    id_usuario = models.ForeignKey('usuarios.Usuarios', models.DO_NOTHING, db_column='id_usuario')
    id_rol = models.ForeignKey('usuarios.Roles', models.DO_NOTHING, db_column='id_rol')
    fecha_asignacion = models.DateTimeField()
    class Meta:
        managed = False
        db_table = 'usuario_roles'
        unique_together = (('id_usuario', 'id_rol'),)
    def __str__(self):
        return f"{self.id_usuario} - {self.id_rol}"

class Autores(models.Model):
    """Información pública de autores (extiende usuario)."""
    id_autor = models.OneToOneField('usuarios.Usuarios', models.DO_NOTHING, db_column='id_autor', primary_key=True)
    biografia = models.TextField(blank=True, null=True)
    sitio_web = models.CharField(max_length=255, blank=True, null=True)
    libros_publicados_contador = models.IntegerField()
    fecha_creacion = models.DateTimeField()
    fecha_modificacion = models.DateTimeField()
    class Meta:
        managed = False
        db_table = 'autores'
    def __str__(self):
        return f"{self.id_autor.nombre_completo or self.id_autor.nombre_usuario} (Autor)"

class PreferenciasUsuario(models.Model):
    """Preferencias personalizadas de notificaciones, tema, idioma, etc."""
    id_usuario = models.OneToOneField('usuarios.Usuarios', models.DO_NOTHING, db_column='id_usuario', primary_key=True)
    recibir_notificaciones_email = models.BooleanField(blank=True, null=True)
    recibir_notificaciones_app = models.BooleanField(blank=True, null=True)
    tema_interfaz = models.CharField(max_length=50, blank=True, null=True)
    idioma_preferido = models.CharField(max_length=10, blank=True, null=True)
    permitir_recomendaciones_personalizadas = models.BooleanField(blank=True, null=True)
    class Meta:
        managed = False
        db_table = 'preferencias_usuario'
    def __str__(self):
        return f"Preferencias de {self.id_usuario}"

class UsuarioGenerosFavoritos(models.Model):
    """Géneros favoritos por usuario."""
    id_usuario = models.ForeignKey('usuarios.Usuarios', models.DO_NOTHING, db_column='id_usuario')
    id_genero = models.ForeignKey('catalogo.Generos', models.DO_NOTHING, db_column='id_genero')
    class Meta:
        managed = False
        db_table = 'usuario_generos_favoritos'
        unique_together = (('id_usuario', 'id_genero'),)
    def __str__(self):
        return f"{self.id_usuario} - {self.id_genero}"

class UsuarioAutoresFavoritos(models.Model):
    """Autores favoritos por usuario."""
    id_usuario = models.ForeignKey('usuarios.Usuarios', models.DO_NOTHING, db_column='id_usuario')
    id_autor = models.ForeignKey('usuarios.Autores', models.DO_NOTHING, db_column='id_autor')
    class Meta:
        managed = False
        db_table = 'usuario_autores_favoritos'
        unique_together = (('id_usuario', 'id_autor'),)
    def __str__(self):
        return f"{self.id_usuario} - {self.id_autor}"