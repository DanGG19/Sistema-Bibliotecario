from django.db import models
# Create your models here.

class Prestamos(models.Model):
    """Préstamos de ejemplares."""
    id_prestamo = models.AutoField(primary_key=True)
    id_ejemplar = models.ForeignKey('catalogo.Ejemplares', models.DO_NOTHING, db_column='id_ejemplar')
    id_usuario = models.ForeignKey('usuarios.Usuarios', models.DO_NOTHING, db_column='id_usuario')
    fecha_prestamo = models.DateTimeField()
    fecha_devolucion_estimada = models.DateTimeField()
    fecha_devolucion_real = models.DateTimeField(blank=True, null=True)
    estado_prestamo = models.TextField()
    multa_aplicada = models.DecimalField(max_digits=10, decimal_places=2, blank=True, null=True)
    fecha_modificacion = models.DateTimeField()

    class Meta:
        managed = False
        db_table = 'prestamos'

    def __str__(self):
        return f"Prestamo #{self.id_prestamo} - {self.id_usuario}"

class HistorialPrestamos(models.Model):
    """Historial de acciones de préstamos."""
    id_historial = models.AutoField(primary_key=True)
    id_prestamo = models.ForeignKey('prestamos.Prestamos', models.DO_NOTHING, db_column='id_prestamo')
    id_usuario = models.ForeignKey('usuarios.Usuarios', models.DO_NOTHING, db_column='id_usuario')
    id_ejemplar = models.ForeignKey('catalogo.Ejemplares', models.DO_NOTHING, db_column='id_ejemplar')
    accion = models.CharField(max_length=20)
    fecha_accion = models.DateTimeField()
    observaciones = models.TextField(blank=True, null=True)
    usuario_registra = models.CharField(max_length=100, blank=True, null=True)
    fecha_registro = models.DateTimeField(blank=True, null=True)
    
    class Meta:
        managed = False
        db_table = 'historial_prestamos'

    def __str__(self):
        return f"Historial #{self.id_historial} - {self.accion}"

class Multas(models.Model):
    """Multas generadas por préstamos tardíos."""
    id_multa = models.AutoField(primary_key=True)
    id_prestamo = models.ForeignKey('prestamos.Prestamos', models.DO_NOTHING, db_column='id_prestamo')
    fecha_generada = models.DateField()
    fecha_pago = models.DateField(blank=True, null=True)
    monto = models.DecimalField(max_digits=8, decimal_places=2)
    estado = models.CharField(max_length=20)
    observaciones = models.TextField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'multas'

    def __str__(self):
        return f"Multa #{self.id_multa} - {self.estado}"

class Reservas(models.Model):
    """Reservas de ejemplares por usuarios."""
    id_reserva = models.AutoField(primary_key=True)
    id_ejemplar = models.ForeignKey('catalogo.Ejemplares', models.DO_NOTHING, db_column='id_ejemplar')
    id_usuario = models.ForeignKey('usuarios.Usuarios', models.DO_NOTHING, db_column='id_usuario')
    fecha_reserva = models.DateTimeField()
    fecha_caducidad = models.DateTimeField(blank=True, null=True)
    estado_reserva = models.TextField()
    posicion_fila = models.IntegerField(blank=True, null=True)
    fecha_modificacion = models.DateTimeField()

    class Meta:
        managed = False
        db_table = 'reservas'
        unique_together = (('id_ejemplar', 'id_usuario'),)

    def __str__(self):
        return f"Reserva #{self.id_reserva} - {self.id_usuario} ({self.estado_reserva})"