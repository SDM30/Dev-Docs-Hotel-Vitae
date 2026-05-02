# Documentación del Backend

> [!IMPORTANT]
> Esta documentación es de __carácter informal__, para la documentación completa __referirse__ a los documentos PDF, o los archivo .typ. Dichos documentos
> tiene los apartados y diseños relevante para la comprensión del sistema Backend

## Tabla de contenidos

## Levantamiento del Servidor Backend

### Paso 1

Para el levantamiento del servicio Backend, se debe tener instalado `mvn`, y se debe tener un archivo `env` o `.env`, donde se especifiquen las siguientes
variables de entorno.

```sh
# archivo: .env o env

CORS_ALLOWED_ORIGINS=http://localhost:4200 # configura los origins o fronts permitidos para consumir los endpoints (si hay varios separarlos por , )
```

### Paso 2

Correr el siguiente comando en una distribución linux (si se esta en otro sistema operativo, ver la respectiva traducción para dicho sistema operativo).

> [!NOTE]
> 1. Se asume que el archivo mencionado en el __Paso 1__ fue nombrado `env` y se encuentra en el directorio de trabajo actual.
> 2. Si se requiere dejar el proceso encendido, se pueden utilizar herramientas como `tmux` [pagina oficial de tmux](https://github.com/tmux/tmux/wiki)

```sh
set -a && source env && set +a && mvn spring-boot:run
```

