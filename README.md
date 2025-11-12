# proyecto-asesor-academico-n8n
🎓 Agente Automatizado para Recomendación de Asignaturas (MVP)
Este proyecto implementa un agente inteligente basado en n8n y MySQL que ayuda a los estudiantes universitarios a planificar su inscripción de asignaturas.

El sistema analiza el historial académico del alumno, lo cruza con la malla curricular y las reglas de prerrequisitos, y genera una recomendación personalizada instantánea.


🚀 Funcionalidades Actuales (Sprint 1)
El MVP actual cubre las siguientes capacidades:


Validación de Identidad: Verifica que el alumno exista y corresponda a la carrera ingresada antes de procesar datos.


Análisis de Prerrequisitos: Determina qué asignaturas puede tomar el alumno basándose en sus cursos aprobados.


Detección de Asignaturas Críticas: Prioriza los ramos que corresponden al semestre actual del alumno para evitar atrasos.


Explicación de Bloqueos: Indica claramente qué asignaturas no se pueden tomar y detalla los prerrequisitos faltantes.


Interfaz Web: Formulario HTML simple para interactuar con el agente.

🛠️ Requisitos Previos
Docker instalado y corriendo.

Un cliente de base de datos (DBeaver, MySQL Workbench) o acceso a terminal.

Python (opcional, para levantar el servidor web local) o cualquier extensión de "Live Server".

⚙️ Instalación y Despliegue
Sigue estos pasos para levantar el entorno de desarrollo.

1. Configuración de Red y Base de Datos (Docker)
Primero, creamos una red para que los contenedores se comuniquen y levantamos la base de datos MySQL.

```bash
# 1. Crear la red interna
docker network create n8n-net

# 2. Levantar el contenedor de MySQL (Base de Datos)
# Nota: Se configura con el nombre 'mysql-db' para ser accesible desde n8n
docker run -d --name mysql-db \
  --network n8n-net \
  -e MYSQL_ROOT_PASSWORD=mi_clave_secreta \
  -e MYSQL_DATABASE=syacapp \
  -v mysql_data:/var/lib/mysql \
  mysql:8
```
2. Levantar n8n (Automatización)
Levantamos n8n en la misma red. Importante: Incluimos variables de entorno para habilitar CORS, permitiendo que el formulario HTML local se comunique con n8n sin bloqueos.

```bash
docker run -d \
  --name n8n \
  --network n8n-net \
  -p 5678:5678 \
  -e N8N_CORS_ALLOWED_ORIGINS='*' \
  -e N8N_CORS_ALLOW_CREDENTIALS=true \
  -v n8n_data:/home/node/.n8n \
  n8nio/n8n
```
3. Inicializar la Base de Datos
Conéctate a tu base de datos (Host: localhost, Puerto: 3306 si expusiste el puerto o vía docker exec) y ejecuta el script de inicialización para crear las tablas alumnos y malla_curricular.

<details> <summary>Click para ver el script SQL de inicialización</summary>

```sql
USE syacapp;

-- Tabla Alumnos
CREATE TABLE IF NOT EXISTS alumnos (
    rut_id VARCHAR(15) PRIMARY KEY,
    nombre_completo VARCHAR(150) NOT NULL,
    carrera VARCHAR(100) NOT NULL
);

-- Tabla Malla Curricular
CREATE TABLE IF NOT EXISTS malla_curricular (
    id INT AUTO_INCREMENT PRIMARY KEY,
    carrera VARCHAR(100) NOT NULL,
    codigo_asignatura VARCHAR(20) NOT NULL,
    nombre_asignatura VARCHAR(100) NOT NULL,
    semestre_recomendado INT NOT NULL,
    creditos INT NOT NULL,
    prerrequisitos VARCHAR(255),
    UNIQUE KEY (carrera, codigo_asignatura)
);

-- Datos de Prueba (Semilla)
INSERT INTO alumnos (rut_id, nombre_completo, carrera) VALUES 
('20.123.456-K', 'Bastián González', 'Ingeniería Informática'),
('19.876.543-2', 'Francisca Rojas', 'Ingeniería Informática');

INSERT INTO malla_curricular (carrera, codigo_asignatura, nombre_asignatura, semestre_recomendado, creditos, prerrequisitos) VALUES
('Ingeniería Informática', 'MAT-100', 'Álgebra', 1, 5, NULL),
('Ingeniería Informática', 'INF-100', 'Introducción a la Programación', 1, 6, NULL),
('Ingeniería Informática', 'MAT-200', 'Cálculo I', 2, 5, 'MAT-100'),
('Ingeniería Informática', 'INF-200', 'Programación Avanzada', 2, 6, 'INF-100'),
('Ingeniería Informática', 'MAT-300', 'Cálculo II', 3, 5, 'MAT-200'),
('Ingeniería Informática', 'INF-300', 'Estructuras de Datos', 3, 6, 'INF-200'),
('Ingeniería Informática', 'INF-301', 'Bases de Datos', 3, 6, 'INF-200'),
('Ingeniería Informática', 'EST-300', 'Probabilidad y Estadística', 3, 5, 'MAT-200');
```
</details>

4. Configurar el Flujo en n8n
Abre http://localhost:5678 en tu navegador.

Importa el archivo workflow.json (disponible en este repositorio).

Configura las Credenciales de MySQL en los nodos correspondientes:

Host: mysql-db

User: root

Password: mi_clave_secreta

Database: syacapp

Activa el flujo (Switch "Active" en verde).

5. Ejecutar el Cliente Web
Abre el archivo index.html.

Edita la línea const WEBHOOK_URL = '...' y asegúrate de pegar tu URL de Producción de n8n.

Sirve el archivo localmente (para evitar errores de protocolo de archivo).

```bash
# Si tienes Python instalado
python -m http.server 8000
```
Visita http://localhost:8000 y prueba el formulario.

🧪 Casos de Prueba
Para verificar el funcionamiento, utiliza estos datos en el formulario:

| Caso | RUT | Situación | Resultado Esperado |
| :--- | :--- | :--- | :--- |
| Alumno en Riesgo | 20.123.456-K | Reprobó INF-200 | Bloqueo: INF-300 y INF-301. Razón: Falta INF-200. |
| Alumno al Día | 19.876.543-2 | Aprobó todo | Disponible: Toda la carga de Semestre 3. |
| Error | 1.1.1.1-1 | No existe | Error: "Alumno no encontrado". |

Exportar a Hojas de cálculo

📂 Estructura del Proyecto
```
/
├── README.md           # Documentación del proyecto
├── index.html          # Cliente Web (Frontend)
├── workflow.json       # Flujo de lógica exportado de n8n
└── setup.sql           # Script de creación de Base de Datos
```