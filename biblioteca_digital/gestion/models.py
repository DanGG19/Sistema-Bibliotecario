from django.db import models

# Create your models here.

class ReportesQuejas(models.Model):
    """Reportes y quejas enviadas por usuarios sobre libros, ejemplares o el sistema."""
    id_reporte = models.AutoField(primary_key=True)
    id_usuario_reporta = models.ForeignKey('usuarios.Usuarios', models.DO_NOTHING, db_column='id_usuario_reporta')
    tipo_reporte = models.TextField()
    id_objeto_afectado = models.IntegerField(blank=True, null=True)
    tabla_objeto_afectado = models.CharField(max_length=100, blank=True, null=True)
    descripcion = models.TextField()
    fecha_reporte = models.DateTimeField(blank=True, null=True)
    estado_reporte = models.TextField(blank=True, null=True)
    comentarios_admin = models.TextField(blank=True, null=True)
    id_admin_gestion = models.ForeignKey(
        'usuarios.Usuarios',
        models.DO_NOTHING,
        db_column='id_admin_gestion',
        related_name='reportesquejas_id_admin_gestion_set',
        blank=True,
        null=True
    )
    fecha_ultima_actualizacion = models.DateTimeField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'reportes_quejas'

    def __str__(self):
        return f"Reporte {self.id_reporte} - {self.tipo_reporte}"