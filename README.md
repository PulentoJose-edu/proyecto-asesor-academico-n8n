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

## Guía paso a paso para desplegar todo (Frontend, Backend y BD) en el servidor

---

### 📋 Fase 0: Preparativos (Desde tu Casa)
Si estás en tu casa, primero conéctate a la VPN usando el cliente **FortiClient** con los datos que te entregaron (Gateway: 200.27.73.13). Si estás en la universidad, salta este paso.

### 📡 Fase 1: Conexión al Servidor
Abre tu terminal (PowerShell, CMD, Terminal o Putty) y conéctate por SSH:
```bash
ssh alumno@10.40.5.6
# Password: Unab.2025
# (Nota: Al escribir la contraseña en Linux no aparecerán asteriscos. Tú solo escríbela y presiona Enter).
```

### 🐳 Fase 2: Instalación de Docker
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
Aplicar cambios (sal de la sesión y entra de nuevo):
```bash
exit
# Vuelve a conectarte:
ssh alumno@10.40.5.6
```

### 📂 Fase 3: Crear la Carpeta del Proyecto
```bash
mkdir agente-academico
cd agente-academico
```

### 📄 Fase 4: Crear el Archivo Maestro (docker-compose.yml)
Crea el archivo:
```bash
nano docker-compose.yml
```
Copia y pega este contenido:
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
Guarda y sal (Ctrl+O, Enter y luego Ctrl+X).

### 💾 Fase 5: Subir tus Archivos (SQL y HTML)
Ahora crearemos los archivos `setup.sql` e `index.html` en el servidor.

A. Crear `setup.sql`
```bash
nano setup.sql
```
(Pega el contenido de tu script SQL con `CREATE TABLE`, `TRUNCATE`, `INSERT`).

Guarda (Ctrl+O, Enter) y sal (Ctrl+X).

B. Crear `index.html` (con la IP actualizada)

- Abre tu archivo `index.html` local, busca la línea:
  ```js
  const WEBHOOK_URL = ...
  ```
- Cámbiala por:
  ```js
  const WEBHOOK_URL = 'http://10.40.5.6:5678/webhook/TU-ID-AQUI';
  // O temporalmente:
  const WEBHOOK_URL = 'http://10.40.5.6:5678/webhook/temp';
  ```
- Súbelo al servidor y crea el archivo:
```bash
nano index.html
```
(Pega el código corregido y guarda).

### 🚀 Fase 6: Levantar Todo
```bash
docker compose up -d
```
Docker descargará las imágenes y levantará:
- MySQL (y ejecutará tu `setup.sql`)
- n8n en el puerto 5678
- Tu Web en el puerto 80

### ⚙️ Fase 7: Configuración Final en n8n
1. Entra a [http://10.40.5.6:5678](http://10.40.5.6:5678)
2. Configura tu cuenta de n8n inicial.
3. Importa tu Workflow (`.json`)
4. Configura las Credenciales del nodo MySQL:
   - Host: `mysql-db`
   - Pass: `mi_clave_secreta`
5. Abre el nodo Webhook y copia la Production URL.
6. Edita el `index.html` en el servidor con la nueva URL (-- `nano index.html` -- guarda y sal).
7. Refresca [http://10.40.5.6](http://10.40.5.6).

---
## ✅ ¡Resultado Final!
- **Tu Web:** http://10.40.5.6
- **n8n:** http://10.40.5.6:5678
- **BD:** Corriendo internamente

¡Listo! Ya tienes la solución desplegada.
