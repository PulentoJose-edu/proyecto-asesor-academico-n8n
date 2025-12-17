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

---

## Guía de Despliegue en Servidor (Linux/Docker)

## Guía paso a paso para desplegar todo (Frontend, Backend y BD) en el servidor.

📋 Fase 0: Preparativos (Desde tu Casa)
Si estás en tu casa, primero conéctate a la VPN usando el cliente FortiClient con los datos que te entregaron (Gateway: 200.27.73.13). Si estás en la universidad, salta este paso.

📡 Fase 1: Conexión al Servidor
Abre tu terminal (PowerShell, CMD, Terminal o Putty) y conéctate por SSH:

```bash
ssh alumno@10.40.5.6
```
Password: `Unab.2025` (Nota: Al escribir la contraseña en Linux no aparecerán asteriscos. Tú solo escríbela y presiona Enter).

🐳 Fase 2: Instalación de Docker
Una vez dentro del servidor, instalaremos Docker. Copia y pega estos comandos uno por uno:

Actualizar el sistema:
```bash
sudo apt update
```

Instalar Docker y Docker Compose:
```bash
sudo apt install -y docker.io docker-compose-v2
```

Dar permisos a tu usuario (para no usar sudo siempre):
```bash
sudo usermod -aG docker $USER
```

Aplicar cambios:
Cierra la conexión escribiendo `exit`.
Vuelve a conectarte (`ssh alumno@10.40.5.6`) para que los permisos hagan efecto.

📂 Fase 3: Crear la Carpeta del Proyecto
Vamos a crear una carpeta ordenada para tu proyecto.

```bash
mkdir agente-academico
cd agente-academico
```

📄 Fase 4: Crear el Archivo "Maestro" (Docker Compose)
Este archivo reemplazará a tu .bat. Le dirá al servidor cómo levantar MySQL, n8n y tu Web al mismo tiempo.

Crea el archivo:
```bash
nano docker-compose.yml
```

Pega el siguiente contenido dentro (clic derecho para pegar en la mayoría de terminales):

```yaml
version: '3.8'

services:
  # 1. Base de Datos
  mysql-db:
    image: mysql:8
    container_name: mysql-db
    environment:
      MYSQL_ROOT_PASSWORD: mi_clave_secreta
      MYSQL_DATABASE: syacapp
    volumes:
      - mysql_data:/var/lib/mysql
      # Esto carga tu script SQL automáticamente al inicio:
      - ./setup.sql:/docker-entrypoint-initdb.d/setup.sql
    networks:
      - n8n-net

  # 2. Backend (n8n)
  n8n:
    image: n8nio/n8n
    container_name: n8n
    ports:
      - "5678:5678"
    environment:
      - N8N_CORS_ALLOWED_ORIGINS=*
      - N8N_CORS_ALLOW_CREDENTIALS=true
      - WEBHOOK_URL=http://10.40.5.6:5678/
    volumes:
      - n8n_data:/home/node/.n8n
    networks:
      - n8n-net
    depends_on:
      - mysql-db

  # 3. Frontend (Servidor Web para tu HTML)
  website:
    image: nginx:alpine
    container_name: website
    ports:
      - "80:80"
    volumes:
      - ./index.html:/usr/share/nginx/html/index.html
    networks:
      - n8n-net

volumes:
  n8n_data:
  mysql_data:

networks:
  n8n-net:
```
Guarda y sal: Presiona `Ctrl + O` (Enter) y luego `Ctrl + X`.

💾 Fase 5: Subir tus Archivos (SQL y HTML)
Ahora crearemos los archivos `setup.sql` e `index.html` en el servidor.

A. Crear setup.sql
En el servidor ejecuta: `nano setup.sql`

Pega el contenido de tu script SQL (el que tenía los CREATE TABLE y INSERT).
Tip: Asegúrate de incluir el TRUNCATE y el INSERT de datos.
Guarda (Ctrl+O, Enter) y sal (Ctrl+X).

B. Crear index.html (Con IP Actualizada)
⚠️ Importante: Antes de pegar el código, debes editar tu `index.html` en tu bloc de notas local.

Busca la línea `const WEBHOOK_URL = ...`

Cámbiala por la IP del servidor:
```javascript
const WEBHOOK_URL = 'http://10.40.5.6:5678/webhook/TU-ID-AQUI';
```
(Nota: Como es una instalación nueva de n8n, el ID del webhook cambiará. Puedes poner `http://10.40.5.6:5678/webhook/temp` por ahora y corregirlo en el Paso 7).

En el servidor ejecuta: `nano index.html`
Pega tu código HTML corregido.
Guarda (Ctrl+O, Enter) y sal (Ctrl+X).

🚀 Fase 6: ¡Levantar Todo!
Ahora que tienes los 3 archivos (`docker-compose.yml`, `setup.sql`, `index.html`) en la carpeta, ejecuta la magia:

```bash
docker compose up -d
```
Docker descargará las imágenes y levantará:
- MySQL (y ejecutará tu `setup.sql` automáticamente).
- n8n en el puerto 5678.
- Tu Web en el puerto 80.

⚙️ Fase 7: Configuración Final en n8n
1. Abre tu navegador y entra a: `http://10.40.5.6:5678`
2. Configura tu cuenta de n8n inicial.
3. Importa tu Workflow:
   - Usa el botón "Import from File" y carga tu archivo .json (el que tenías en tu computador).
4. Configura las Credenciales:
   - Entra a los nodos MySQL.
   - Host: `mysql-db` (Igual que antes).
   - Pass: `mi_clave_secreta`.
5. Obtener la URL Real del Webhook:
   - Abre el nodo Webhook.
   - Copia la Production URL.
   - Esta URL es la que debes poner en tu `index.html`.

🔧 Ajuste Final (Si cambió la URL del Webhook):
Si la URL cambió (que es lo normal), tienes que editar el `index.html` en el servidor una vez más:
`nano index.html`
Borra la URL vieja y pega la nueva que te dio n8n.
Guarda y sal.

Refresca el navegador (F5) en `http://10.40.5.6`.

✅ ¡Resultado Final!
- Tu Web: Accesible en `http://10.40.5.6`
- Tu n8n: Accesible en `http://10.40.5.6:5678`
- Tu BD: Corriendo internamente.

¡Listo! Ya tienes tu solución desplegada.