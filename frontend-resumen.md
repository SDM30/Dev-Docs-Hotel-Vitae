# Frontend — Hotel Vitae (Fundación Eisamar)

> **Propósito**: Este documento es una guía de onboarding para desarrolladores que se incorporan al proyecto. Explica la arquitectura, la organización del código, el flujo de trabajo por rol y las decisiones técnicas del frontend.

---

## Índice

1. [¿Qué hace el frontend?](#1-qué-hace-el-frontend)
2. [Stack tecnológico](#2-stack-tecnológico)
3. [Arquitectura del proyecto](#3-arquitectura-del-proyecto)
4. [Roles y visibilidad en UI](#4-roles-y-visibilidad-en-ui)
5. [Flujo de trabajo por rol](#5-flujo-de-trabajo-por-rol)
6. [Features principales](#6-features-principales)
7. [Comunicación con el backend](#7-comunicación-con-el-backend)
8. [SSR y post-hidratación](#8-ssr-y-post-hidratación)
9. [Decisiones técnicas](#9-decisiones-técnicas)
10. [Ejecución y build](#10-ejecución-y-build)

---

## 1. ¿Qué hace el frontend?

Es la interfaz de usuario del sistema **Hotel Vitae**, una plataforma de gestión de alojamiento temporal para pacientes con enfermedades catastróficas. El frontend consume la API REST del backend Spring Boot y proporciona una experiencia adaptada a cada rol del sistema.

Los usuarios pueden:
- **Reservas**: crear, consultar, editar y gestionar el ciclo de vida de las reservas
- **Pacientes**: administrar datos clínicos y personales de los huéspedes
- **Habitaciones**: consultar disponibilidad en tiempo real por sede
- **Facturación**: crear borradores, emitir, pagar y anular facturas con descarga de PDF
- **Prórrogas**: solicitar, autorizar o rechazar extensiones de estadía
- **Servicios**: administrar códigos SHA/NPBS por EPS
- **Auditoría**: consultar la bitácora de cambios (solo ADMIN)
- **Usuarios**: gestionar cuentas y roles del sistema (solo ADMIN)

---

## 2. Stack tecnológico

| Componente | Tecnología |
|---|---|
| Framework | Angular 21 (standalone components) |
| Lenguaje | TypeScript 5.9 |
| SSR | `@angular/ssr` (Express server) |
| Estilos | SCSS + Bootstrap 5.3 |
| UI components | Angular Material 21 |
| Estado/reactividad | RxJS (forkJoin, switchMap, catchError) |
| PDF | Generado por backend, descargado vía blob |
| Build | Angular CLI (npm run build) |

---

## 3. Arquitectura del proyecto

```
src/
├── app/
│   ├── core/
│   │   ├── dtos/          # DTOs de respuesta del backend
│   │   ├── guards/        # authGuard, roleGuard
│   │   ├── interceptors/  # Interceptor HTTP (JWT)
│   │   ├── models/        # Interfaces del dominio
│   │   └── services/      # Servicios que llaman al backend
│   ├── features/
│   │   ├── admin/         # Componentes exclusivos de ADMIN
│   │   ├── landing/       # Página de inicio (adaptada por rol)
│   │   ├── reserva/       # Gestión de reservas
│   │   ├── factura/       # Facturación
│   │   ├── paciente/      # Pacientes
│   │   └── ...            # Otros dominios
│   ├── sidebar/           # Barra de navegación lateral
│   └── app.routes.ts      # Definición de rutas
├── assets/                # Imágenes, iconos
└── environments/          # environment.ts, environment.development.ts
```

### Principios de organización

- **core/**: Todo lo compartido (modelos, servicios, DTOs, guards). Barrel exports en `models/index.ts` y `services/index.ts`.
- **features/**: Componentes agrupados **por dominio** (no por rol). Cuando una pantalla es 100% exclusiva de un rol, se crea dentro de `features/<rol>/`.
- **Standalone components**: No hay NgModules. Cada componente importa directamente lo que necesita.
- **Dos capas de servicios**: Siempre usar los de `core/services/` (no los legacy en `service/`).

---

## 4. Roles y visibilidad en UI

El sidebar y la landing page se adaptan según el rol del usuario autenticado:

| Rol | Sidebar | Landing page |
|---|---|---|
| **ADMIN** | Todo (Inicio, Reservas, Pacientes, Habitaciones, Sedes, Servicios, Factura, Pagos, Perfil, **Usuarios**, **Auditoría**) | Métricas del sistema + tarjetas admin + workflow admin |
| **RESERVA** | Inicio, Reservas, Pacientes, Habitaciones, Sedes, Servicios, Factura, Pagos, Perfil | Tarjetas operativas + workflow de reservas |
| **FACTURACION** | Inicio, Habitaciones, Sedes, Factura, Pagos, Perfil | Tarjetas de facturación + workflow de facturación |
| **COORDINADOR_RUTAS** | Sin rutas definidas actualmente | — |

El control se implementa con:
- **roleGuard** en `app.routes.ts`: protege rutas completas (ej. `auditoria` solo ADMIN)
- **@if** en templates: oculta/muestra elementos según `esAdmin`, `esFacturacion`
- **afterNextRender** en sidebar: detecta el rol post-hidratación SSR

---

## 5. Flujo de trabajo por rol

### ADMIN

El administrador supervisa toda la operación. Su flujo típico:

1. **Dashboard** con métricas (reservas activas, habitaciones ocupadas, facturas pendientes, prórrogas pendientes)
2. **Gestionar usuarios** → crear/editar/activar/deshabilitar cuentas con roles y sedes
3. **Administrar códigos de servicio** → configurar códigos SHA/NPBS por EPS
4. **Consultar reservas** → filtrar por sede, estado y fechas
5. **Gestionar facturación** → auditar, emitir, pagar, anular
6. **Administrar prórrogas** → autorizar o rechazar solicitudes
7. **Consultar auditoría** → revisar la bitácora de cambios

### RESERVA (Personal de Reservas)

El personal de reservas gestiona la operación directa del huésped. Su flujo típico:

1. **Crear reserva** → registrar paciente, acompañante, EPS, autorización, código de servicio
2. **Asignar habitación** → seleccionar habitación disponible (el sistema valida solapamiento)
3. **Validar autorización** → el sistema verifica que no esté duplicada
4. **Llenar borrador de factura** → completar con datos de estadía y servicios
5. **Emitir prórroga** → solicitar extensión con nueva autorización si es necesaria
6. **Registrar consumo de días** → marcar checkOutRealizado cuando el huésped se retira
7. **Consultar disponibilidad** → ver ocupación en tiempo real por sede

### FACTURACION (Personal de Facturación)

El personal de facturación audita y gestiona el ciclo de pago:

1. **Consultar reservas** → verificar consumos registrados en todas las sedes
2. **Revisar borradores** → validar días consumidos, prórrogas y códigos de servicio
3. **Auditar y emitir** → corregir si es necesario y emitir la factura final (descarga PDF)
4. **Registrar envío** → marcar como enviada a la EPS
5. **Seguimiento de pagos** → registrar fecha de pago, monto y estado de cuenta

---

## 6. Features principales

### Reservas

- **Crear**: formulario con validación server-side por campo (`setErrors`), split date+time inputs, selección de paciente/habitación, gestión de acompañantes (máx 2), servicio de reserva obligatorio
- **Listar**: tabla con filtros server-side (sede, estado, rango de fechas)
- **Detalle**: información completa + servicios (CRUD inline) + prórrogas + edición inline de factura
- **Estados**: PENDIENTE, EN_SEDE, FINALIZO, NO_TOMO_EL_SERVICIO

### Facturación

- **Crear factura**: desde una reserva, con items de ServicioReserva
- **Estados**: BORRADOR → EMITIDA → PAGADA / ANULADA
- **Emitir**: cambia estado y descarga PDF automáticamente
- **Pagar**: prompt para ingresar monto
- **Anular**: prompt para motivo
- **Historial**: tabla con todas las facturas, montos pagados y estados

### Pacientes

- CRUD completo con gestión de acompañantes
- Detalle con datos personales, clínicos, EPS, ciudad
- Filtro por sede para RESERVA
- Vista diferente para ADMIN vs RESERVA (`/ver-pacientes` vs `/gestionar-pacientes`)

### Prórrogas

- CRUD con selección del ServicioReserva a extender
- Al autorizar, se propaga el cambio al checkout y a la cantidad del servicio
- Estados: PENDIENTE → AUTORIZADA / RECHAZADA

### Servicios (EPS)

- Administración de códigos SHA/NPBS por EPS
- Cada EPS tiene aproximadamente 5 códigos de servicio
- Vista unificada de EPS + servicios asociados

### Auditoría

- Solo accesible para ADMIN
- Bitácora de cambios con filtro por usuario
- Datos: usuario, acción, entidad, valor anterior/nuevo, timestamp

### Landing page

- Adaptada al rol del usuario (3 vistas distintas)
- ADMIN: métricas + tarjetas admin + workflow admin
- RESERVA: tarjetas operativas + workflow reservas
- FACTURACION: tarjetas de facturación + workflow facturación

---

## 7. Comunicación con el backend

### Interceptor HTTP

El `AuthInterceptor` (functional `HttpInterceptorFn`) agrega automáticamente el header `Authorization: Bearer <token>` a todas las peticiones salientes.

### AuthService

Usa `HttpBackend` para crear su propio `HttpClient` y romper la dependencia circular:
```
HttpClient → Interceptor → AuthService → HttpClient
```

### Endpoints principales

| Función | Método | Ruta |
|---|---|---|
| Login | POST | `/api/usuario-reservas/login` |
| Perfil actual | GET | `/api/usuario-reservas/me` |
| CRUD reservas | GET/POST/PUT/DELETE | `/api/reservas/**` |
| CRUD facturas | GET/POST/PUT/DELETE | `/api/facturas/**` |
| Emitir factura | PUT | `/api/facturas/{id}/emitir` |
| PDF factura | GET | `/api/facturas/{id}/pdf` |
| CRUD prórrogas | GET/POST/PUT/DELETE | `/api/prorrogas/**` |
| Disponibilidad | GET | `/api/habitaciones/disponibles` |
| Auditoría | GET | `/api/auditoria` |
| Enums | GET | `/api/enums/**` |

### Proxy de desarrollo

En desarrollo (`npm start`), Angular proxy las peticiones a `http://localhost:8080` (configurado en `proxy.conf.json`).

---

## 8. SSR y post-hidratación

El frontend usa **Server-Side Rendering** (`@angular/ssr`) con un servidor Express.

### El problema

`localStorage` no está disponible en Node.js (SSR). Si un componente intenta leer `localStorage` durante la renderización del servidor, falla.

### La solución

Todas las llamadas a `AuthService` (que usa `localStorage`) y cualquier lógica que dependa del navegador se ejecutan dentro de `afterNextRender` + `NgZone.run()`:

```typescript
afterNextRender(() => {
  this.zone.run(() => {
    const role = this.authService?.getRole() || '';
    this.esAdmin = role === 'ADMIN';
  });
});
```

Esto garantiza que el código solo se ejecute en el navegador, después de la hidratación.

### Rutas

Todas las rutas usan `RenderMode.Server`. No hay lazy loading — todos los componentes se cargan eagerly.

---

## 9. Decisiones técnicas

### Formato de fecha global

Configurado en `app.config.ts` mediante `DATE_PIPE_DEFAULT_OPTIONS` con formato `yyyy-MM-dd`. Todos los pipes `| date` sin formato explícito heredan este formato.

### Bootstrap + Angular Material

Ambos coexisten. Bootstrap se importa globalmente en `main.ts` (CSS + JS). Angular Material se usa para componentes específicos (diálogos, selects, etc.).

### Dos capas de servicios (legacy vs actual)

Existen dos capas paralelas pero solo una debe usarse:

| Capa | Ubicación | Estado |
|---|---|---|
| **Actual** | `src/app/core/services/` | ✅ Usar esta |
| Legacy | `src/app/service/` | ❌ No usar (obsoleta) |

### AuthService con HttpBackend

```typescript
export class AuthService {
  private http = inject(HttpClient);
  private httpBackend = inject(HttpBackend);
  // Para login y /me, crea HttpClient propio
  private httpNoInterceptor = new HttpClient(this.httpBackend);
}
```

Esto evita que el interceptor de JWT intente agregar el token antes de que exista (circularidad).

### Guards de ruta

- **authGuard**: verifica que el usuario tenga token (`localStorage.getItem('token')`)
- **roleGuard**: verifica que el rol del usuario esté en `route.data.roles`

```typescript
{ path: 'auditoria', component: AuditoriaComponent,
  canActivate: [authGuard, roleGuard],
  data: { roles: ['ADMIN'] } }
```

---

## 10. Ejecución y build

### Desarrollo

```bash
cd Hoteles-De-Salud-Front
npm install
npm start
# Servidor en http://localhost:4200
# Proxy API a http://localhost:8080
```

### Producción

```bash
npm run build
# Output: dist/hoteles-de-salud/

npm run serve:ssr:HotelesDeSalud
# Servidor SSR en http://localhost:4000
```

### Tests

```bash
npm test
# Karma + Jasmine
```

### Proyecto

No hay ESLint, Prettier ni CI/CD configurados actualmente.

### Referencias útiles

| Recurso | Ubicación |
|---|---|
| README del frontend | `Hoteles-De-Salud-Front/README.md` |
| Guía del proyecto (AGENTS.md) | `AGENTS.md` (raíz del workspace) |
| Especificación OpenAPI | `Hoteles-De-Salud-Back/api-docs.json` |
| SRS formal | `Dev-Docs-Hotel-Vitae/srs.pdf` |
