# Backend — Resumen Técnico

## Stack
- Java 17, Spring Boot 3.3.2, Maven Wrapper
- H2 (archivo en default, memoria en test)
- Spring Security + JWT (HS512, clave regenerada en cada reinicio)
- MapStruct 1.5.5 + Lombok 1.18.30
- Apache PDFBox 3.0.3 (generación de facturas PDF)

## Perfiles
| Perfil | Puerto | BD | ddl-auto | Seed |
|---|---|---|---|---|
| default | 8080 | `./data/hoteles-salud-db` | update | Solo si BD vacía |
| test | 8099 | memoria `testdb` | create-drop | Cada arranque |

## Arquitectura en capas
```
Controller → IService / Service (lógica negocio) → Repository (Spring Data JPA) → Entity (JPA)
```

DTO + mapper pattern manual (records Java). Todos los servicios siguen interfaz IService* + Service*.

## Roles y acceso (SecurityConfig)
| Rol | Acceso |
|---|---|
| ADMIN | Todo |
| RESERVA | CRUD reservas, pacientes, personas, habitaciones, sedes, EPS, servicios, prórrogas, acompañantes. Factura solo BORRADOR |
| FACTURACION | Facturas (CRUD completo), consulta reservas, EPS, servicios |
| COORDINADOR_RUTAS | Solo GET reservas |

## Usuarios sembrados (InitDatabase)
| Usuario | Contraseña | Rol |
|---|---|---|
| admin | admin123 | ADMIN |
| usr_reservas123 | 12345 | RESERVA |
| facturacion | fact123 | FACTURACION |
| coordinador_rutas | ruta123 | COORDINADOR_RUTAS |

## Entidades principales (17)
Persona, UsuarioEntity, Rol, Paciente, AcompananteEntity, Sede, Habitacion, Eps, ServicioEps, ServicioReserva, Reserva, Prorroga, Factura, FacturaItem, Notificacion, Auditoria, Departamento, Ciudad

## Reglas de negocio clave
- **Autorización única**: `Reserva.autorizacion` tiene `@Column(unique = true)` — validado en ServiceReserva
- **Prórroga**: Al autorizar, extiende `checkOut` + incrementa `ServicioReserva.cantidad`
- **Factura**: RESERVA fuerza estado BORRADOR, no puede emitir/pagar/anular. FACTURACIÓN gestiona estados
- **Acompañantes**: Máximo 2 por reserva
- **Solapamiento**: Valida que no haya reservas activas en el mismo rango de fechas para misma habitación o paciente
- **Fechas**: checkIn y checkOut obligatorios, checkOut > checkIn
- **PDF**: Se genera bajo demanda vía Apache PDFBox, sin persistencia en disco. Contiene código de servicio y unidades facturadas (sin montos)

## Bitácora (Auditoria)
Cableada en 7 controllers: Paciente, Reserva, Factura, UsuarioReservas, ServicioReserva, Acompanante, Prorroga. Cada registro guarda usuario, acción, entidad, ID, valor anterior/nuevo y timestamp.

## Documentación detallada
Ver `Hoteles-De-Salud-Back/.wiki/` para documentación exhaustiva por capa.
