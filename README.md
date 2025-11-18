# 🎓 Agente Automatizado para Recomendación de Asignaturas (MVP)

Este proyecto implementa un agente inteligente basado en **n8n** y **MySQL** que ayuda a los estudiantes universitarios a planificar su inscripción de asignaturas.

El sistema analiza el historial académico del alumno, lo cruza con la malla curricular y las reglas de prerrequisitos, y genera una recomendación personalizada instantánea.

## 🚀 Funcionalidades Actuales (Sprint 1)

El MVP actual cubre las siguientes capacidades:

- **Validación de Identidad:** Verifica que el alumno exista y corresponda a la carrera ingresada antes de procesar datos.
- **Análisis de Prerrequisitos:** Determina qué asignaturas puede tomar el alumno basándose en sus cursos aprobados.
- **Detección de Asignaturas Críticas:** Prioriza los ramos que corresponden al semestre actual del alumno para evitar atrasos.
- **Explicación de Bloqueos:** Indica claramente qué asignaturas no se pueden tomar y detalla los prerrequisitos faltantes.
- **Interfaz Web:** Formulario HTML simple para interactuar con el agente.

## 🛠️ Requisitos Previos

- **Windows** (para ejecutar el script `.bat`).
- **Docker Desktop** instalado y corriendo.
- Un navegador web (Chrome, Firefox, etc.).
- **Python** (opcional, para levantar el servidor web local) o cualquier extensión de "Live Server".

## ⚙️ Instalación Automatizada (Windows)

Sigue estos 3 pasos para levantar el entorno completo.

### 1. Iniciar el Entorno (Docker + Base de Datos)

Este script automatiza toda la configuración del backend.

1. Coloca los archivos `iniciar_entorno.bat` y `setup.sql` en la misma carpeta.
2. Asegúrate de que **Docker Desktop** esté corriendo.
3. Haz doble clic en `iniciar_entorno.bat`.

El script se encargará de todo:
- Verificará que Docker esté corriendo.
- Creará la red `n8n-net` si no existe.
- Iniciará el contenedor `mysql-db` con la base de datos `syacapp`.
- Iniciará el contenedor `n8n` con la configuración de CORS necesaria.
- Esperará 30 segundos y luego ejecutará `setup.sql` para crear y poblar las tablas `alumnos` y `malla_curricular` (con la corrección de acentos UTF-8).

<details>
<summary><strong>Ver lo que hace el script .bat (Opcional)</strong></summary>

El script `iniciar_entorno.bat` ejecuta los siguientes comandos de Docker:

```bash
# 1. Crea la red
docker network create n8n-net

# 2. Levanta MySQL
docker run -d --name mysql-db ... -e MYSQL_DATABASE=syacapp mysql:8

# 3. Levanta n8n con CORS
docker run -d --name n8n ... -e N8N_CORS_ALLOWED_ORIGINS="*" ... n8nio/n8n

# 4. Espera e inserta los datos (con fix de acentos)
(echo SET NAMES 'utf8mb4'; & type setup.sql) | docker exec -i mysql-db mysql -u root -p"mi_clave_secreta"
```
</details>

### 2. Configurar el Flujo en n8n

Una vez que el script `.bat` termine, n8n estará corriendo.

1. Abre http://localhost:5678 en tu navegador.
2. Importa el archivo `workflow.json` (puedes arrastrarlo y soltarlo en el canvas).
3. **Configurar Credenciales:** El flujo no funcionará hasta que configures las "llaves" de la base de datos.
    - Haz clic en el nodo `MySQL_Verificar_Alumno` (verás un error de credencial).
    - Selecciona "Create New" en el campo "Credential".
    - Rellena los datos:
        - **Host:** `mysql-db`
        - **User:** `root`
        - **Password:** `mi_clave_secreta`
        - **Database:** `syacapp`
    - Guarda la credencial.
4. Activa el flujo (Switch "Active" en verde en la esquina superior derecha).

### 3. Ejecutar el Cliente Web

1. Abre el archivo `index.html`.
2. Edita la línea `const WEBHOOK_URL = '...'` y asegúrate de pegar tu URL de Producción de n8n (la obtienes del nodo Webhook).
3. Sirve el archivo localmente (para evitar errores de protocolo de archivo).

```bash
# Si tienes Python instalado
python -m http.server 8000
```

Visita http://localhost:8000 y prueba el formulario.

## 🧪 Casos de Prueba

Para verificar el funcionamiento, utiliza estos datos en el formulario:

| Caso | RUT | Situación | Resultado Esperado |
| :--- | :--- | :--- | :--- |
| **Alumno en Riesgo** | `20.123.456-K` | Reprobó INF-200 | **Bloqueo:** INF-300 y INF-301. <br> **Razón:** Falta INF-200. |
| **Alumno al Día** | `19.876.543-2` | Aprobó todo | **Disponible:** Toda la carga de Semestre 3. |
| **Error** | `1.1.1.1-1` | No existe | **Error:** "Alumno no encontrado". |

## 📂 Estructura del Proyecto

```plaintext
/
├── iniciar_entorno.bat     # (NUEVO) Script de inicio automatizado
├── setup.sql               # (NUEVO) Script de creación de Base de Datos
├── workflow.json           # Flujo de lógica exportado de n8n
├── index.html              # Cliente Web (Frontend)
└── README.md               # Documentación del proyecto
```