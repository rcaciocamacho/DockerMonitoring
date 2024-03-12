# DockerMonitoring
Script en bash para mantener un monitoreo de los contenedores que están activos en un servidor. 

# Descripción General

Este proyecto consiste en un script de shell (bash) destinado a la administración remota de contenedores Docker en un servidor. Su principal función es verificar el estado de los contenedores Docker, reintentar iniciar aquellos que no estén corriendo y notificar el estado de los contenedores a través de Telegram. Se utiliza para garantizar que los servicios críticos alojados en los contenedores estén siempre disponibles y para proporcionar una rápida notificación en caso de problemas.

# Requisitos

 - Sistema Operativo: Cualquier distribución de Linux que soporte bash.
 - Docker: Instalado y configurado tanto en el sistema local como en el remoto.
 - SSH: Acceso configurado del sistema local al sistema remoto.
 - yq: Herramienta para procesar archivos YAML, utilizada para leer configuraciones del archivo config.toml.
 - curl: Para enviar notificaciones a través de la API de Telegram.
 - Archivo de Configuración (config.toml)

> Este archivo contiene las configuraciones necesarias para la ejecución del script. Debe estar presente en el mismo directorio que el script y seguir el formato TOML. Ejemplo de estructura del archivo:

'''toml
[CONFIG]
username = "usuario_remoto"
ip_address = "direccion_ip"

[telegram]
token = "tu_token_telegram"
chat_id = "tu_chat_id_telegram"
'''

# Funcionamiento del Script

## El script realiza las siguientes operaciones:

Cargar Configuraciones: Lee las configuraciones necesarias desde config.toml utilizando yq.
Listar Contenedores: Ejecuta un comando remoto vía SSH para listar todos los contenedores Docker (tanto corriendo como detenidos) en el servidor remoto.
Verificar y Reintentar: Para cada contenedor que no esté corriendo, intenta reiniciarlo un número definido de veces.
Notificación: Envía un resumen del estado de los contenedores a través de Telegram, indicando si todos están corriendo o si algunos presentaron problemas persistentes.
Funciones Principales
check_and_retry_container: Verifica y reintentar iniciar un contenedor específico. Si no puede iniciarlo después de varios intentos, lo marca como problemático.
Ejecución

## Para ejecutar el script, simplemente navega al directorio donde se encuentra el archivo y utiliza el comando:

'''bash
./nombre_del_script.sh
'''

> Asegúrate de que el script tenga permisos de ejecución. Puedes otorgarle permisos con el comando chmod +x nombre_del_script.sh si es necesario.

# Notificaciones

Las notificaciones son enviadas a través de Telegram utilizando curl para hacer una petición POST a la API de Telegram. Esto requiere un bot de Telegram configurado previamente y los identificadores correspondientes en el archivo config.toml.

# Consideraciones de Seguridad

Asegúrate de que el acceso SSH al servidor remoto esté correctamente configurado y securizado.
Protege tu config.toml para que solo el usuario que ejecuta el script tenga acceso a él, ya que contiene información sensible.