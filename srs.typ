#set text(
  font: "New Computer Modern",
  size: 10pt,
)
#set par(
  justify: true,
  leading: 0.52em,
)

#set page(
  margin: (x: 2cm, y: 3cm),
  numbering: none,
)

#align(center + horizon)[
  #text(24pt, weight: "bold")[SRS] \
  #v(1em)
  #text(14pt)[Juan Eduardo Diaz] \
  #v(1em)
  #text(14pt)[Simón Díaz] \
  #v(1em)
  #text(14pt)[Erick Salazar] \
  #v(1em)
  #text(14pt)[Juan Francisco Vargas] \
  #v(1em)
  #datetime.today().display()
]

#pagebreak()

= Historial de cambios
_Propósito: Describir brevemente los cambios que ha sufrido el documento, con el fin de llevar una adecuada administración de configuración._
#align(center, table(
  columns: 3,
  table.header([Fecha del cambio], [Descripción del cambio], [Persona(s) responsable(s)]),
  [#datetime(year: 2026, month: 4, day: 11).display()], [Creación del documento], [Simón Díaz],
))
#pagebreak()

#set heading(numbering: "1.")
#outline(title: [Tabla de contenidos])
#pagebreak()

= Introducción

= Visión del producto
Es una solución tecnológica para la Fundación Eisamar (Hotel Vitae), enfocada en centralizar y optimizar la gestión de reservas, pacientes, habitaciones, facturación y reportes. Desarrollado con Angular, Spring Boot y PostgreSQL, el sistema tiene como propósito corrigir la fragmentación de datos actual (registros manuales y hojas de cálculo), incorpora control por roles, validaciones de negocio (autorizaciones únicas, MIPRES), trazabilidad de cambios, visibilidad de ocupación en tiempo real y automatización de reportes. Busca reducir errores operativos, mejorar la coordinación entre sedes y fortalecer la toma de decisiones, dejando una base sólida para su despliegue en producción
= Restricciones del producto
+ Registro manual de autorizaciones: el registro de las autorizaciones de servicios enviadas por las EPS debe hacerse manualmente en el sistema, debido a la variabilidad en los formatos y canales de envío.
+ Framework backend limitado a Spring Boot: el backend se desarrollará exclusivamente con Spring Boot, por familiaridad y continuidad con el trabajo previo.
+ Framework frontend limitado a Angular: la interfaz de usuario se desarrollará exclusivamente con Angular, por familiaridad y continuidad con el trabajo previo.
+ Base de datos relacional: se utilizará PostgreSQL como sistema de base de datos, manteniendo la consistencia con la implementación existente.
+ Configuración manual de códigos de servicio: los códigos de servicio por EPS deben ser agregados o quitados manualmente por un administrador, sin interfaz automática con fuentes externas.

= Modelo de dominio
#align(center)[
  #image("modelo_dominio.png")
]

El dominio del proyecto Hotel Vitae (operado por la Fundación Eisamar) corresponde a una red de alojamiento temporal con fines sociales, enfocada en atender a pacientes con enfermedades catastróficas y sus acompañantes, quienes son remitidos por diferentes EPS a nivel nacional.
== Estructura operativa
La red de hotetes está compuesto por tres sedes ubicadas en Bogotá:
#align(center, table(
  columns: 2,
  table.header([Sede], [Numero de habitaciones]),
  [Galery], [33],
  [Galerias], [25],
  [Corferias], [22],
))

== Entidades externas
El sistema interactúa con múltiples EPS y entidades pagadoras, incluyendo:

+ Salud Total, Famisanar, Nueva EPS, Sura, Sanitas
+ Colombiana de Trasplantes, Contraminas, Policía Nacional, Fuerza Aérea
+ Expreso Viales (intermediario) y Particulares (acompañantes adicionales)
Cada EPS maneja aproximadamente 5 códigos de servicio utilizados para facturar estadía y transporte.

== Servicios ofrecidos
Manejan un paquete de servicios todo incluido que consta de:
+ Albergue
+ Alimentación
+ Transporte

= Características de los usuarios
== Administrador
Revisa todas las reservas de las tres sedes, genera reportes y configura parámetros del sistema (EPS, códigos, habitaciones).

== Personal de Reservas
Llena el borrador de factura, emite prórrogas (solicitudes para aumentar estadía) y registra consumo de días (salida anticipada). Gestiona la operación directa del huésped.

== Coordinador de ruta
Maneja el transporte de los huéspedes, organizando una planilla de rutas con horarios, arma grupos de huespedes para tranportar y prioriza los traslados según el perfil del paciente (tipo de enfermedad).

== Personal de facturación
Factura todas las sedes, audita que los borradores llenados por Reservas sean válidos y tiene acceso a todas las reservas para verificar consumos.

= Funciones del producto
// Crear indice para historias de usuario
#let hu_counter = counter("hucounter")
#let hu(contenido) = block[
  *#hu_counter.step() HU-#context hu_counter.display():*
  #contenido
]

== Administrador
#hu[Login seguro]
Yo como administrador quiero iniciar sesión de forma segura para acceder al sistema con mi usuario y contraseña.

#hu[Tablero general]
Yo como administrador quiero visualizar un tablero general que muestre la ocupación actual de todas las sedes para tener una visión global del estado del hotel.

#hu[Revisar reservas]
Yo como administrador quiero revisar todas las reservas de las tres sedes, con filtros por sede, fecha y estado, para supervisar la operación.

#hu[Configurar habitaciones]
Yo como administrador quiero configurar el número de habitaciones por sede  para adaptar el sistema a cambios en la capacidad.

#hu[Gestionar EPS]
Gestionar EPS	Yo como administrador quiero gestionar el listado de EPS (crear, editar, deshabilitar) para mantener actualizadas las entidades pagadoras.

#hu[Gestionar códigos de servicio]
Yo como administrador quiero gestionar los códigos de servicio por EPS (asociar, modificar, eliminar) para que facturación pueda utilizarlos correctamente.

#hu[Gestionar usuarios]
Yo como administrador quiero gestionar usuarios del sistema (crear, editar roles, deshabilitar) para controlar quién tiene acceso a la aplicación.

#hu[Ver trazabilidad]
Yo como administrador quiero visualizar la trazabilidad de cambios (quién y cuándo modificó una reserva, factura o autorización) para auditar la operación.
== Personal de Reservas
#hu[Crear reserva]
Yo como usuario de reservas quiero registrar una nueva reserva asociando paciente, acompañante, EPS, número de autorización (con la cantidad disponible) y MIPRES, para formalizar el alojamiento.

#hu[Asignar habitación]
Yo como usuario de reservas quiero asignar una habitación disponible en una sede específica al momento de crear la reserva, para asegurar el cupo.

#hu[Validar autorización única]
Yo como usuario de reservas quiero validar que un número de autorización no esté duplicado en el sistema, para evitar facturar múltiples veces la misma autorización.

#hu[Llenar borrador de factura]
Yo como usuario de reservas quiero llenar el borrador de la factura con los datos de estadía y servicios consumidos, para que facturación pueda revisarlo y emitir la factura final.

#hu[Emitir prórroga]
Yo como usuario de reservas quiero solicitar una prórroga (aumentar días de estadía) sobre una reserva activa, registrando la nueva autorización si es necesaria, para extender el alojamiento del huésped.

#hu[Registrar consumo de días]
Yo como usuario de reservas quiero registrar consumo de días cuando un huésped se va antes de la fecha límite, para reflejar la estancia real y ajustar la facturación.

#hu[Consultar disponibilidad]
Yo como usuario de reservas quiero consultar la disponibilidad de habitaciones en tiempo real por sede, para saber si puedo asignar un nuevo huésped o debo derivar a hotel aliado.

== Coordinador de ruta
#hu[Manejar planilla de rutas]
Yo como coordinador de rutas quiero manejar una planilla de rutas que muestre los traslados programados de los huéspedes (Hora de la cita, origen, destino, nombre del usuario, cantidad de personas), para organizar la logística de transporte.

#hu[Exportar a excel]
Yo como coordinador de ruta quiero exportar la planilla de rutas a un archivo de Excel, para compartir la información con otros departamentos.

== Personal de facturación
#hu[Acceder a todas las reservas]
Yo como usuario de facturación quiero acceder a todas las reservas de las tres sedes para verificar los consumos registrados.

#hu[Revisar borradores]
Yo como usuario de facturación quiero revisar los borradores de factura creados por Reservas, validando que los días consumidos, prórrogas y códigos de servicio sean correctos.

#hu[Auditar borrador]
Yo como usuario de facturación quiero auditar y corregir (si es necesario) un borrador de factura antes de su emisión final, para garantizar la precisión del cobro.

#hu[Marcar factura enviada]
Yo como usuario de facturación quiero marcar una factura como "enviada a EPS" y registrar la fecha de envío, para hacer seguimiento.

#hu[Seguimiento de pagos]
Yo como usuario de facturación quiero registrar el seguimiento de pagos de EPS (fecha de pago, monto, estado de cuenta), para controlar la cartera.

= Requisitos no funcionales / Atributos de calidad

== Transversales (todos los roles)

#align(
  center,
  table(
    columns: (auto, auto, auto, 1fr),
    table.header([ID], [Categoría], [HU origen], [Requerimiento no funcional]),

    [RNF-01],
    [Seguridad],
    [HU-29 - Acceso por rol],
    [
      El sistema debe autenticar a cada usuario mediante credenciales (usuario y contraseña) y
      asignar un #text(weight: "bold")[rol específico] (Administrador, Reservas, Coordinador de
      ruta o Facturación), de modo que cada perfil visualice y acceda #text(weight: "bold")[
        únicamente a las funcionalidades autorizadas
      ] según su rol.
    ],

    [RNF-02],
    [Seguridad],
    [HU-31 - Bitácora de acciones],
    [
      El sistema debe #text(weight: "bold")[registrar en una bitácora de auditoría] todas las
      acciones de los usuarios, incluyendo al menos: identificación del usuario, fecha y hora,
      tipo de acción (creación, modificación, eliminación, consulta), entidad afectada
      (reserva, factura, paciente, etc.) y valor anterior/nuevo cuando aplique. La bitácora debe
      ser #text(weight: "bold")[inmutable y consultable solo por usuarios con rol de Administrador].
    ],

    [RNF-03],
    [Usabilidad],
    [HU-30 - Mensajes de error claros],
    [
      El sistema debe mostrar #text(weight: "bold")[mensajes de error claros, específicos y
        accionables] cuando el usuario ingrese datos incorrectos o falten campos obligatorios.
      Los mensajes deben utilizar un lenguaje sencillo (no técnico), indicar dónde ocurrió el
      error y sugerir la corrección. No se permiten mensajes genéricos como "Error interno" o
      "Fallo en el sistema" para validaciones de entrada de usuario.
    ],
  ),
)

