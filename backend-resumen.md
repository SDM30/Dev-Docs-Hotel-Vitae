# Backend — Hotel Vitae (Fundación Eisamar)

> **Propósito**: Este documento es una guía de onboarding para desarrolladores que se incorporan al proyecto. Explica la arquitectura, el modelo de dominio, las reglas de negocio y cómo empezar a trabajar.

---

## Índice

1. [¿Qué es Hotel Vitae?](#1-qué-es-hotel-vitae)
2. [Stack tecnológico](#2-stack-tecnológico)
3. [Arquitectura en capas](#3-arquitectura-en-capas)
4. [Modelo de dominio](#4-modelo-de-dominio)
5. [API REST](#5-api-rest)
6. [Seguridad y roles](#6-seguridad-y-roles)
7. [Reglas de negocio](#7-reglas-de-negocio)
8. [Ejecución y perfiles](#8-ejecución-y-perfiles)
9. [Datos semilla](#9-datos-semilla)
10. [Estructura del proyecto](#10-estructura-del-proyecto)

---

## 1. ¿Qué es Hotel Vitae?

Hotel Vitae es una solución tecnológica para la **Fundación Eisamar**, una red de alojamiento temporal con fines sociales que atiende a pacientes con enfermedades catastróficas y sus acompañantes, remitidos por diferentes EPS a nivel nacional.

El sistema centraliza y optimiza la gestión de:
- **Reservas** de alojamiento en 3 sedes en Bogotá
- **Pacientes** y sus datos clínicos
- **Habitaciones** y disponibilidad en tiempo real
- **Facturación** con ciclo de estados (borrador → emitida → pagada/anulada)
- **Prórrogas** (extensiones de estadía)
- **Servicios** (códigos SHA/NPBS por EPS)
- **Auditoría** (bitácora inmutable de cambios)
- **Usuarios** con control de acceso por roles

El problema que resuelve: antes del sistema, la operación se manejaba con registros manuales y hojas de cálculo, causando fragmentación de datos, errores operativos y falta de trazabilidad.

---

## 2. Stack tecnológico

| Componente | Tecnología |
|---|---|
| Lenguaje | Java 17 |
| Framework | Spring Boot 3.3.2 |
| Base de datos | H2 (archivo en default, memoria en test) |
| ORM | Spring Data JPA / Hibernate 6.5.2 |
| Seguridad | Spring Security + JWT (HS512) |
| Mappers | MapStruct 1.5.5 + Lombok 1.18.30 |
| PDF | Apache PDFBox 3.0.3 |
| API Docs | Springdoc OpenAPI 2.6.0 (Swagger UI) |
| Build | Maven Wrapper (./mvnw) |

---

## 3. Arquitectura en capas

```
┌─────────────────────────────────────────────────────────┐
│                   Controller (REST)                      │
│   Recibe peticiones HTTP, delega al servicio,            │
│   devuelve DTOs. Sin lógica de negocio.                  │
├─────────────────────────────────────────────────────────┤
│               Service (IService + Service)               │
│   Lógica de negocio. Cada agregado tiene su propia       │
│   interfaz IService* e implementación Service*.          │
├─────────────────────────────────────────────────────────┤
│               Repository (Spring Data JPA)               │
│   Acceso a datos. Métodos CRUD y consultas personalizadas│
├─────────────────────────────────────────────────────────┤
│                   Entity (JPA)                           │
│   Clases @Entity que mapean tablas H2.                   │
└─────────────────────────────────────────────────────────┘
         ↑                                      ↓
         │          DTO (Request/Response)       │
         └──────────────────┬───────────────────┘
                            ↓
                     HTTP Response
```

**Principios:**
- Los controladores no contienen lógica de negocio
- Los servicios siguen el patrón interfaz + implementación
- Los DTOs son records de Java (inmutables)
- MapStruct convierte entre entidades y DTOs
- Las excepciones se manejan centralizadamente en `GlobalExceptionHandler`

---

## 4. Modelo de dominio

El modelo de datos del sistema se ilustra en dos diagramas Mermaid embebidos en el `README.md` del backend:

- **Diagrama de clases** (`CLASSES_ENTITIES.mmd`): muestra todas las entidades JPA con sus atributos y relaciones.
- **Diagrama entidad-relación** (`ERD.mmd`): vista simplificada de las tablas y sus conexiones.

### Entidades principales (18)

| Entidad | Tabla | Rol en el sistema |
|---|---|---|
| `Persona` | PERSONA | Base de datos personales. 1:1 con Paciente y UsuarioEntity |
| `Paciente` | PACIENTE | Perfil clínico del huésped. FK a Ciudad, EPS |
| `UsuarioEntity` | USUARIO | Credenciales de acceso. FK a Rol, Persona, Sede |
| `Rol` | ROL | Catálogo: ADMIN, RESERVA, FACTURACION, COORDINADOR_RUTAS |
| `Sede` | SEDE | Sedes físicas (Galery, Galerias, Corferias) |
| `Habitacion` | HABITACION | Habitaciones con tipo, capacidad, estado |
| `Reserva` | RESERVA | Núcleo del sistema. FK a Paciente, Habitacion |
| `ServicioReserva` | SERVICIO_RESERVA | Servicio consumido en una reserva |
| `ServicioEps` | SERVICIO_EPS | Catálogo de códigos SHA/NPBS por EPS |
| `Eps` | EPS | Entidad Promotora de Salud |
| `AcompananteEntity` | ACOMPANANTE | Acompañante del paciente (máx 2) |
| `Factura` | FACTURA | Facturación con ciclo de estados |
| `FacturaItem` | FACTURA_ITEM | Líneas de factura |
| `Prorroga` | PRORROGA | Solicitud de extensión de estadía |
| `Departamento` | DEPARTAMENTO | Departamentos de Colombia |
| `Ciudad` | CIUDAD | Ciudades. FK a Departamento |
| `Notificacion` | NOTIFICACION | Notificaciones del sistema |
| `Auditoria` | AUDITORIA | Bitácora de cambios |

### Relaciones clave

```
Persona ──1:1──> UsuarioEntity
Persona ──1:1──> Paciente
Paciente ──1:N──> Reserva
Reserva ──1:1──> Factura
Reserva ──1:N──> ServicioReserva
Reserva ──1:N──> Prorroga
Reserva ──1:N──> AcompananteEntity
Sede ──1:N──> Habitacion
Eps ──1:N──> ServicioEps
Paciente ──N:1──> Eps
Paciente ──N:1──> Ciudad
```

### Mapa mental del dominio

![Modelo de dominio](../Dev-Docs-Hotel-Vitae/modelo_dominio.png)

---

## 5. API REST

El backend expone **16 controladores** con más de **70 endpoints**. La especificación OpenAPI completa está disponible en:

- **Swagger UI** (interactivo): `http://localhost:8080/swagger-ui/index.html`
- **JSON estático**: `api-docs.json` en la raíz del proyecto
- **Endpoint dinámico**: `GET /v3/api-docs`

### Controladores por funcionalidad

| Controlador | Ruta base | Descripción |
|---|---|---|
| `UsuarioReservasController` | `/api/usuario-reservas` | Login, CRUD usuarios, perfil actual |
| `ReservaController` | `/api/reservas` | CRUD reservas con filtros |
| `PacienteController` | `/api/pacientes` | CRUD pacientes |
| `PersonaController` | `/api/personas` | CRUD personas |
| `AcompananteController` | `/api/acompanantes` | CRUD acompañantes |
| `HabitacionController` | `/api/habitaciones` | CRUD + disponibilidad |
| `SedeController` | `/api/sedes` | CRUD sedes |
| `EpsController` | `/api/eps` | CRUD EPS + servicios por EPS |
| `ServicioEpsController` | `/api/servicios-eps` | CRUD códigos de servicio |
| `ServicioReservaController` | `/api/servicio-reserva` | CRUD servicios de reserva |
| `ProrrogaController` | `/api/prorrogas` | CRUD prórrogas |
| `FacturaController` | `/api/facturas` | CRUD + emitir/pagar/anular + PDF |
| `RolController` | `/api/roles` | Listar roles |
| `CiudadController` | `/api/ciudades` | Listar ciudades |
| `AuditoriaController` | `/api/auditoria` | Consultar bitácora |
| `EnumController` | `/api/enums` | Listar enums del dominio |

---

## 6. Seguridad y roles

### Autenticación

El sistema usa **JWT (HS512)** para autenticación:

1. `POST /api/usuario-reservas/login` con `{ usuario, password }` → devuelve un token JWT
2. El frontend almacena el token y lo envía como `Authorization: Bearer <token>`
3. El token se valida en cada request mediante `JWTAuthenticationFilter`

> ⚠️ La clave HS512 se genera al iniciar el servidor. **Todos los tokens se invalidan al reiniciar el backend.**

### Roles del sistema

| Rol | Descripción | Acceso |
|---|---|---|
| **ADMIN** | Acceso total | Todos los endpoints |
| **RESERVA** | Operación directa del huésped | CRUD reservas, pacientes, habitaciones, facturas (solo BORRADOR) |
| **FACTURACION** | Gestión de facturación | Facturas (CRUD completo + emitir/pagar/anular), consulta reservas |
| **COORDINADOR_RUTAS** | Transporte | Solo GET reservas |

### Reglas de acceso (SecurityConfig)

| Patrón de ruta | Acceso |
|---|---|
| `POST /api/usuario-reservas/login` | Público |
| `/h2/**` | Público |
| `OPTIONS /**` | Público |
| `/api/enums/**` | Autenticado |
| `/api/usuario-reservas/me` | Autenticado |
| `/api/auditoria/**` | Solo ADMIN |
| `/api/usuario-reservas/**` | ADMIN o RESERVA |
| `/api/reservas/**`, `/api/pacientes/**`, etc. | ADMIN, RESERVA o FACTURACION |
| `GET /api/reservas/**` | ADMIN o COORDINADOR_RUTAS |

---

## 7. Reglas de negocio

Estas reglas provienen del SRS (Software Requirements Specification) y están implementadas en la capa de servicios:

### Autorización única (SRS HU-3)
El número de autorización de un servicio de reserva debe ser único en todo el sistema. Se valida antes de crear un `ServicioReserva` para evitar facturar múltiples veces la misma autorización.

### Prórroga (SRS HU-5)
- Una prórroga nace en estado `PENDIENTE`
- Al autorizarla (`AUTORIZADA`), se extiende automáticamente el `checkOut` de la reserva y se incrementa la `cantidad` del `ServicioReserva` asociado
- Si se rechaza (`RECHAZADA`), no hay cambios en la reserva

### Facturación (SRS HU-4, HU-15, HU-16)
- El personal de **RESERVA** solo puede crear/editar facturas en estado `BORRADOR`
- El personal de **FACTURACION** puede emitir (`BORRADOR → EMITIDA`), pagar (`EMITIDA → PAGADA`) y anular (`EMITIDA → ANULADA`)
- La factura incluye items que referencian `ServicioReserva` con unidades autorizadas y facturadas
- Se genera PDF bajo demanda con Apache PDFBox (sin persistencia en disco)

### Acompañantes
- Máximo 2 acompañantes por habitación
- Comparten la misma reserva y factura que el paciente

### Solapamiento de reservas
Se valida que no haya reservas activas en el mismo rango de fechas para la misma habitación o el mismo paciente.

### Check-in / Check-out
- `checkIn` y `checkOut` son obligatorios
- `checkOut` debe ser posterior a `checkIn`
- `checkOutRealizado` se registra cuando el huésped se retira antes de la fecha límite (consumo de días)

### Bitácora de auditoría (SRS RNF-02)
Todas las acciones de creación, modificación y eliminación en 7 controladores (Paciente, Reserva, Factura, UsuarioReservas, ServicioReserva, Acompanante, Prorroga) quedan registradas en la tabla `AUDITORIA` con:
- Usuario que realizó la acción
- Fecha y hora
- Tipo de acción
- Entidad afectada
- Valor anterior y valor nuevo
- La bitácora es **inmutable** y solo consultable por **ADMIN**

---

## 8. Ejecución y perfiles

### Perfil default (H2 en archivo, puerto 8080)

```bash
cd Hoteles-De-Salud-Back
./mvnw spring-boot:run
```

- BD: `jdbc:h2:file:./data/hoteles-salud-db` (persistente)
- Consola H2: `http://localhost:8080/h2`
- Seed data solo si BD vacía

### Perfil test (H2 en memoria, puerto 8099)

```bash
./mvnw spring-boot:run -Dspring-boot.run.profiles=test
```

- BD: `jdbc:h2:mem:testdb` (en memoria)
- Consola H2: `http://localhost:8099/h2-test`
- Seed data en cada arranque

### Build

```bash
./mvnw clean package -DskipTests
java -jar target/HotelesDeSalud-*.jar
```

### Requisitos

- Java 17+
- Maven 3.8+ (o usar `./mvnw`)
- Sin base de datos externa

---

## 9. Datos semilla

`InitDatabase.java` inserta datos al arrancar si las tablas están vacías:

### Usuarios predefinidos

| Usuario | Contraseña | Rol | Email |
|---|---|---|---|
| `admin` | `admin123` | ADMIN | admin@hotel-salud.local |
| `usr_reservas123` | `12345` | RESERVA | usr_reservas123@hotel-salud.local |
| `facturacion` | `fact123` | FACTURACION | facturacion@hotel-salud.local |
| `coordinador_rutas` | `ruta123` | COORDINADOR_RUTAS | rutas@hotel-salud.local |

### Otros datos

- 5 departamentos y 5 ciudades
- 3 sedes (Galery 33 hab, Galerias 25 hab, Corferias 22 hab)
- 5 habitaciones con tipos (SIMPLE, DOBLE, SUITE)
- 12 EPS (Salud Total, Famisanar, Nueva EPS, Sura, Sanitas, etc.)
- ~30 servicios EPS con códigos SHA/NPBS/PART
- 5 reservas en estados PENDIENTE, EN_SEDE, FINALIZO
- 8 servicios de reserva, 1 factura (BORRADOR), 2 prórrogas (PENDIENTE, AUTORIZADA)

---

## 10. Estructura del proyecto

```
src/main/java/org/example/hotelesdesalud/
├── configs/           # Configuración CORS y beans globales
├── controllers/       # 16 controladores REST
├── database/          # InitDatabase.java (seed)
├── dtos/              # DTOs de entrada/salida y mappers MapStruct
├── entities/          # 18 entidades JPA
├── enums/             # Enumeraciones de dominio
├── exceptions/        # BadRequestException, ResourceNotFoundException, BusinessException
├── repositories/      # 16 interfaces Spring Data JPA
├── security/          # JWT, filtros, autenticación
└── services/          # Lógica de negocio (interfaz + impl por agregado)
```

### Referencias útiles

| Recurso | Ubicación |
|---|---|
| README completo | `Hoteles-De-Salud-Back/README.md` |
| Diagrama de clases | `Hoteles-De-Salud-Back/CLASSES_ENTITIES.mmd` |
| Diagrama ER | `Hoteles-De-Salud-Back/ERD.mmd` |
| Especificación OpenAPI | `Hoteles-De-Salud-Back/api-docs.json` |
| SRS formal | `Dev-Docs-Hotel-Vitae/srs.pdf` |
