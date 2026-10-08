-- Script creado por Exneider Nava Para la presentación del examen 1892

-- Primero usamos la base de datos
use coworking_db;

-- Verificamos que no exista la tabla
drop table if exists reservas_externas;

-- creamos la tabla si no existe
create table if not exists reservas_externas(
	id int auto_increment primary key,
    plataforma varchar(50) not null,
    fecha_reserva date not null,
    espacio_id int not null,
    usuario_externo varchar(100) not null,
    duracion int not null,
    constraint fk_reserva_externa_espacio
    foreign key (espacio_id) references espacio(id_espacio)
    on delete cascade
    on update cascade,
    constraint chk_duracion_positiva
    check (duracion > 0)
);

-- Creo un indice para optimización
create index idx_reserva_ext_estado_espacio on reservas_externas(espacio_id, fecha_reserva);


-- validacion
drop procedure if exists sp_importar_reserva_externa;

-- al trabajar con procedimientos debemos cambiar el delimitador
DELIMITER $$

-- Creamos el procedimiento
create procedure sp_importar_reserva_externa(
	in p_id_externo int
)
begin
	-- insertamos el usuario si no existe
    insert ignore into usuario (
		tipo_documento,
        tipo_usuario,
        numero_documento,
        primer_nombre,
        primer_apellido,
        fecha_nacimiento,
        email
    )
    select
		'CC',
        'comun',
        usuario_externo,
        'usuario',
        plataforma,
        '2000-01-01',
        CONCAT(usuario_externo, '@externo.com')
	from reservas_externas
    where id = p_id_externo;
    
    -- Validar que no haya conflictos de horario con reservas existentes.
	if exists (
		select 1
        from reserva r
        join reservas_externas re on r.id_espacio = re.espacio_id
        where re.id = p_id_externo and r.fecha_reserva = re.fecha_reserva 
        and r.estado_reserva in ('confirmada', 'pendiente')
    ) then
		signal sqlstate '45000'
        set message_text = 'Error: hay un conflicto en el horario, el espacio ya esta reservadp en esa fecha';
	end if;
	
    -- Convertir e insertar la reserva
    
    insert into reserva (
		id_usuario,
        id_espacio,
        fecha_reserva,
        hora_inicio,
        hora_fin,
        estado_reserva
    )
    select
		usuario.id_usuario,
        reservas_externas.espacio_id,
        reservas_externas.fecha_reserva,
        '08:00:00',
        '10:00:00',
        'confirmada'
	from reservas_externas join usuario on usuario.numero_documento = reservas_externas.usuario_externo
    where reservas_externas.id = p_id_externo;
    
end $$

DELIMITER ;

-- pruebas
-- 1. Inserto 2 datos de prueba

insert into reservas_externas(
	plataforma,
    fecha_reserva,
    espacio_id,
    usuario_externo,
    duracion
) values 
(
	'Airbnb',
    '2026-12-01',
    1,
    'EXT_101',
    2
),
(
	'Meetup',
    '2026-12-01',
    1,
    'EXT_102',
    2
);

-- Prueba de exito

call sp_importar_reserva_externa(1);

-- evidencia

select * from reserva where fecha_reserva = '2026-12-01';

-- Prueba de conflicto

call sp_importar_reserva_externa(2);


