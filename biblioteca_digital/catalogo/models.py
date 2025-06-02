from django.db import models

class Generos(models.Model):
    """Catálogo de géneros literarios."""
    id_genero = models.AutoField(primary_key=True)
    nombre = models.CharField(unique=True, max_length=100)
    descripcion = models.TextField(blank=True, null=True)
    fecha_creacion = models.DateTimeField()
    fecha_modificacion = models.DateTimeField()
    class Meta:
        managed = False
        db_table = 'generos'
    def __str__(self):
        return self.nombre

class Libros(models.Model):
    """Modelo para los libros en el catálogo."""
    id_libro = models.AutoField(primary_key=True)
    titulo = models.CharField(max_length=255)
    isbn = models.CharField(unique=True, max_length=20, blank=True, null=True)
    sinopsis = models.TextField(blank=True, null=True)
    ano_publicacion = models.IntegerField(blank=True, null=True)
    editorial = models.CharField(max_length=255, blank=True, null=True)
    portada_url = models.CharField(max_length=255, blank=True, null=True)
    archivo_libro_url = models.CharField(max_length=255, blank=True, null=True)
    id_autor_subida = models.ForeignKey('usuarios.Autores', models.DO_NOTHING, db_column='id_autor_subida', blank=True, null=True)
    id_admin_aprobacion = models.ForeignKey('usuarios.Usuarios', models.DO_NOTHING, db_column='id_admin_aprobacion', blank=True, null=True)
    estado_publicacion = models.TextField()
    fecha_subida = models.DateTimeField()
    fecha_aprobacion = models.DateTimeField(blank=True, null=True)
    idioma = models.CharField(max_length=50, blank=True, null=True)
    numero_paginas = models.IntegerField(blank=True, null=True)
    fecha_modificacion = models.DateTimeField()
    class Meta:
        managed = False
        db_table = 'libros'
    def __str__(self):
        return self.titulo

class Etiquetas(models.Model):
    """Etiquetas (tags) para libros."""
    id_etiqueta = models.AutoField(primary_key=True)
    nombre_etiqueta = models.CharField(unique=True, max_length=100)
    class Meta:
        managed = False
        db_table = 'etiquetas'
    def __str__(self):
        return self.nombre_etiqueta

class LibrosAutores(models.Model):
    """Relación libros-autores (muchos a muchos)."""
    id_libro = models.ForeignKey('catalogo.Libros', models.DO_NOTHING, db_column='id_libro')
    id_autor = models.ForeignKey('usuarios.Autores', models.DO_NOTHING, db_column='id_autor')
    rol_autor = models.CharField(max_length=50, blank=True, null=True)
    fecha_asociacion = models.DateTimeField()
    class Meta:
        managed = False
        db_table = 'libros_autores'
        unique_together = (('id_libro', 'id_autor'),)
    def __str__(self):
        return f"{self.id_libro} x {self.id_autor}"

class LibrosGeneros(models.Model):
    """Relación libros-géneros (muchos a muchos)."""
    id_libro = models.ForeignKey('catalogo.Libros', models.DO_NOTHING, db_column='id_libro')
    id_genero = models.ForeignKey('catalogo.Generos', models.DO_NOTHING, db_column='id_genero')
    fecha_asociacion = models.DateTimeField()
    class Meta:
        managed = False
        db_table = 'libros_generos'
        unique_together = (('id_libro', 'id_genero'),)
    def __str__(self):
        return f"{self.id_libro} x {self.id_genero}"

class LibrosEtiquetas(models.Model):
    """Relación libros-etiquetas (muchos a muchos)."""
    id_libro = models.ForeignKey('catalogo.Libros', models.DO_NOTHING, db_column='id_libro')
    id_etiqueta = models.ForeignKey('catalogo.Etiquetas', models.DO_NOTHING, db_column='id_etiqueta')
    class Meta:
        managed = False
        db_table = 'libros_etiquetas'
        unique_together = (('id_libro', 'id_etiqueta'),)
    def __str__(self):
        return f"{self.id_libro} x {self.id_etiqueta}"

class Ejemplares(models.Model):
    """Ejemplares físicos o digitales de los libros."""
    id_ejemplar = models.AutoField(primary_key=True)
    id_libro = models.ForeignKey('catalogo.Libros', models.DO_NOTHING, db_column='id_libro')
    numero_inventario = models.CharField(unique=True, max_length=100, blank=True, null=True)
    estado_ejemplar = models.TextField()
    ubicacion = models.CharField(max_length=255, blank=True, null=True)
    es_digital = models.BooleanField()
    notas_ejemplar = models.TextField(blank=True, null=True)
    fecha_adquisicion = models.DateField(blank=True, null=True)
    fecha_creacion = models.DateTimeField()
    fecha_modificacion = models.DateTimeField()
    class Meta:
        managed = False
        db_table = 'ejemplares'
    def __str__(self):
        return f"Ejemplar #{self.id_ejemplar} de {self.id_libro.titulo}"
