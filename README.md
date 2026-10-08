Contexto:
El coworking ahora acepta reservas desde una plataforma externa (como Airbnb o Meetup). Debes integrar esos datos.



Tarea:
Crear una tabla ReservasExternas con: id, plataforma, fecha_reserva, espacio_id, usuario_externo, duración.
Escribir un procedimiento sp_importar_reserva_externa que:
Convierta una reserva externa en una reserva interna.
Asigne el espacio correcto.
Genere un usuario temporal si no existe.
Validar que no haya conflictos de horario con reservas existentes.

Creado por: Exneider Nava

Para la validación de los datos tuve que insertar dos datos de prueba y luego ejecutar los dos procedimientos para validar la información.
