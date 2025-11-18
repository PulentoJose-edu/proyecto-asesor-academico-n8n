@echo off
echo ===================================
echo  INICIANDO ENTORNO AGENTE ACADEMICO
echo ===================================
echo.

:: 1. Verificar que Docker este corriendo
docker ps >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Docker no esta corriendo.
    echo Por favor, inicia Docker Desktop y vuelve a ejecutar este script.
    goto :eof
)

:: 2. Crear la red de Docker (si no existe)
echo [1/5] Creando la red 'n8n-net'...
docker network inspect n8n-net >nul 2>&1
if %errorlevel% neq 0 (
    docker network create n8n-net
    echo Red 'n8n-net' creada.
) else (
    echo La red 'n8n-net' ya existe.
)
echo.

:: 3. Levantar MySQL
echo [2/5] Iniciando contenedor MySQL 'mysql-db'...
docker run -d --name mysql-db ^
  --network n8n-net ^
  -e MYSQL_ROOT_PASSWORD=mi_clave_secreta ^
  -e MYSQL_DATABASE=syacapp ^
  -v mysql_data:/var/lib/mysql ^
  mysql:8
echo.

:: 4. Levantar n8n (con CORS)
echo [3/5] Iniciando contenedor n8n 'n8n'...
docker run -d --name n8n ^
  --network n8n-net ^
  -p 5678:5678 ^
  -e N8N_CORS_ALLOWED_ORIGINS="*" ^
  -e N8N_CORS_ALLOW_CREDENTIALS=true ^
  -v n8n_data:/home/node/.n8n ^
  n8nio/n8n
echo.

:: 5. Esperar que MySQL este listo
echo [4/5] Esperando que MySQL este listo (30 segundos)...
timeout /t 30 /nobreak >nul
echo.

:: 6. Crear tablas e insertar datos (CON CORRECCION DE ACENTOS)
echo [5/5] Ejecutando script SQL (setup.sql) con UTF-8...
if not exist setup.sql (
    echo ERROR: No se encuentra el archivo 'setup.sql'.
    echo Por favor, crea 'setup.sql' en el mismo directorio.
    goto :eof
)

(echo SET NAMES 'utf8mb4'; & type setup.sql) | docker exec -i mysql-db mysql -u root -p"mi_clave_secreta"

if %errorlevel% equ 0 (
    echo.
    echo ===================================
    echo  ENTORNO INICIADO CON EXITO
    echo ===================================
    echo  n8n esta corriendo en http://localhost:5678
) else (
    echo ERROR: Hubo un problema al ejecutar el script SQL.
    echo Revisa si el contenedor 'mysql-db' se detuvo.
)

echo.
pause