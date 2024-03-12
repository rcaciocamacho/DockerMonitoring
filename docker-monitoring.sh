#!/bin/bash

# Cargar configuraciones desde el archivo .env
# Cargar configuraciones desde el archivo .env
if [ -f ".env" ]; then
    export $(grep -v '^#' .env | xargs)
else
    echo "Archivo .env no encontrado."
    exit 1
fi

# Comando para listar todos los contenedores (nombre y estado)
list_cmd="docker ps -a --format '{{.Names}}:{{.State}}'"

echo $list_cmd

# Comando para iniciar un contenedor
start_cmd="docker start"

# Función para verificar y reintentar contenedores problemáticos
function check_and_retry_container {
    local container_name=$1
    local attempts=0
    local max_attempts=2
    local wait_time=5 # Tiempo de espera en segundos entre intentos

    while [ $attempts -lt $max_attempts ]; do
        ((attempts++))
        echo "Intentando iniciar $container_name, intento $attempts" | ssh "$REMOTE_USER@$REMOTE_HOST"
        ssh "$REMOTE_USER@$REMOTE_HOST" "$start_cmd $container_name" > /dev/null

        sleep $wait_time # Esperar antes de verificar el estado

        # Verificar el estado después del intento de inicio
        local status=$(ssh "$REMOTE_USER@$REMOTE_HOST" "docker inspect --format '{{.State.Running}}' $container_name")
        if [ "$status" == "true" ]; then
            echo "$container_name iniciado exitosamente."
            return 0 # Éxito, el contenedor está corriendo
        fi
    done

    return 1 # Fracaso después de reintentos
}

# Inicializar la variable para guardar contenedores con problemas persistentes
problem_containers=""

# Obtener y procesar la lista de contenedores
containers=$(ssh "$REMOTE_USER@$REMOTE_HOST" "$list_cmd")
while IFS= read -r line; do
    container_name=$(echo "$line" | cut -d ':' -f1)
    container_state=$(echo "$line" | cut -d ':' -f2)
    
    # Reintentar iniciar contenedores que no estén corriendo
    if [[ "$container_state" != "running" ]]; then
        if ! check_and_retry_container "$container_name"; then
            problem_containers+="$container_name\n"
        fi
    fi
done <<< "$containers"

# Preparar y enviar el mensaje final
message=""
if [ -n "$problem_containers" ]; then
    message="Contenedores con problemas persistentes:\n$problem_containers"
else
    message="Todos los contenedores están corriendo sin problemas."
fi

curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_TOKEN/sendMessage" -d chat_id="$TELEGRAM_CHAT_ID" -d text="$message" -d parse_mode="Markdown"
