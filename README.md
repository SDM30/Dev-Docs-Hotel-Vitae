
# 📄 Documentación Hotel Vitae

Este repositorio contiene la **documentación técnica y funcional** del sistema de gestión para **Hotel Vitae (Fundación Eisamar)**, desarrollado en el marco del proyecto de Ingeniería de Sistemas de la Pontificia Universidad Javeriana.

## 📁 Contenido del repositorio

- **SRS (Software Requirements Specification)** - Especificación de requisitos del sistema


## 🛠️ Tecnología de documentación

Los documentos están escritos en **Typst**, una moderna alternativa de composición tipográfica para documentación técnica.

### ¿Por qué Typst?

- ✅ Sintaxis simple e intuitiva
- ✅ Compilación rápida
- ✅ Sistema de tipografía profesional
- ✅ Soporte nativo para tablas, figuras, referencias cruzadas
- ✅ Fácil de versionar con Git (formato de texto plano)

## 🚀 Cómo usar

### Opción 1: Web (recomendada para colaboración)

Usa la aplicación web oficial de Typst:

1. Visita [https://typst.app](https://typst.app)
2. Crea una cuenta gratuita
3. Importa los archivos `.typ` de este repositorio
4. Colabora en tiempo real con otros usuarios

### Opción 2: CLI local

Si tienes Typst instalado localmente:

```bash
# Compilar a PDF
typst compile srs.typ documento.pdf

# Ver en modo observador (auto-recarga)
typst watch srs.typ documento.pdf
```

### Opción 3: VS Code con extensión Tinymist Typst (recomendada para desarrollo)

**Tinymist** es la extensión más completa y moderna para trabajar con Typst en Visual Studio Code.

#### Instalación:

1. Abre **Visual Studio Code**
2. Ve a la pestaña de extensiones (`Ctrl+Shift+X`)
3. Busca `Tinymist Typst`
4. Haz clic en **Instalar**


#### Uso básico:

1. Abre la carpeta del proyecto en VS Code
2. Abre el archivo `.typ` que deseas editar
3. Usa `Ctrl+Shift+P` → `Tinymist: Export to PDF` para generar el documento
4. O activa la previsualización automática con `Ctrl+K V`

#### Configuración recomendada (`.vscode/settings.json`):

```json
{
  "tinymist.formatterMode": "typstyle",
  "tinymist.pinMainFile": "srs.typ",
  "tinymist.exportPdf": "onSave",
  "[typst]": {
    "editor.defaultFormatter": "myriad-dreamin.tinymist",
    "editor.formatOnSave": true
  }
}
```

## 📤 Formatos de exportación

Typst permite exportar a múltiples formatos:

| Formato | Comando (CLI) | Uso recomendado |
|---------|---------------|-----------------|
| **PDF** | `typst compile archivo.typ` | Distribución final, impresión |
| **LaTeX** | `typst compile --format latex archivo.typ` | Integración con flujos LaTeX existentes |
| **Word (DOCX)** | `typst compile --format docx archivo.typ` | Edición por usuarios no técnicos |
| **PNG/SVG** | `typst compile --format png archivo.typ` | Imágenes para informes |

*En VS Code con Tinymist, puedes exportar desde el menú contextual o con comandos de la paleta.*

## 📋 Estructura del documento principal

```
srs.typ
├── Historial de cambios
├── Tabla de contenidos
├── Introducción
├── Visión del producto
├── Restricciones del producto
├── Modelo de dominio
├── Características de los usuarios
├── Funciones del producto (Historias de usuario)
└── Requisitos no funcionales
```

