# Frontend — Resumen Técnico

## Stack
- Angular 21, standalone components, TypeScript 5.9
- SSR habilitado (`@angular/ssr`, Express server)
- Bootstrap 5.3 + Angular Material 21
- RxJS (`forkJoin`, `switchMap`, `catchError`)
- Apache PDFBox (PDF generado por backend, descargado vía blob HTTP)

## Arquitectura
```
core/ (modelos, servicios, DTOs, guards, interceptors)
features/ (componentes agrupados por dominio)
shared/ (utilerías)
```

Barrel exports en `core/models/index.ts` y `core/services/index.ts`.

## Patrón SSR post-hidratación
Todas las llamadas API se ejecutan dentro de `afterNextRender` + `NgZone.run()` para evitar errores de SSR (localStorage no disponible en Node.js). Ejemplo:
```typescript
afterNextRender(() => {
  this.zone.run(() => {
    forkJoin({...}).subscribe({...})
  })
})
```

## Formato de fecha global
Configurado en `app.config.ts` via `DATE_PIPE_DEFAULT_OPTIONS: { dateFormat: 'yyyy-MM-dd' }`. Todos los `| date` sin formato explícito heredan este formato.

## Roles en UI
| Rol | Sidebar visible | Factura (BORRADOR) | Factura (EMITIDA) |
|---|---|---|---|
| RESERVA | Todo excepto auditoría/usuarios | Editar, Eliminar | — |
| FACTURACION | Sin Pacientes/Reservas/Servicios | Emitir, Eliminar | Pagar, Anular |
| ADMIN | Todo | Emitir, Eliminar | Pagar, Anular |

## Features principales

### Reservas
- Crear: formulario con validación server-side por campo, split date+time inputs, selección de paciente/habitación, gestión de acompañantes (máx 2), servicio de reserva obligatorio
- Ver: tabla con filtros server-side (sede, estado, rango de fechas)
- Detalle: información completa + servicios + prórrogas + edición inline de factura para RESERVA

### Facturación
- Crear factura desde reserva con items de ServicioReserva
- Emitir: descarga automática de PDF
- Pagar: prompt para ingresar monto
- Anular: prompt para motivo
- Historial: tabla con todas las facturas y montos pagados

### Pacientes
- CRUD completo con gestión de acompañantes
- Detalle con datos personales, clínicos, EPS, ciudad
- Filtro por sede para RESERVA

### Prórrogas
- CRUD con selección de ServicioReserva a extender
- Autorizar propaga a checkout y cantidad del servicio

## Servicios Core
AuthService (HttpBackend), FacturaService, ReservaService, ProrrogaService, AcompananteService, ServicioReservaService, PacienteService, PersonaService, SedeService, HabitacionService, EpsService, EnumService

## Documentación detallada
Ver `Hoteles-De-Salud-Front/.wiki/` para documentación exhaustiva por capa.
