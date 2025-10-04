#!/bin/bash

# 🔍 PostgreSQL Docker - Verify Script
# Script para verificar el funcionamiento de PostgreSQL + pgAdmin4

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Función para logging
log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

success() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] ✅ $1${NC}"
}

warning() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] ⚠️  $1${NC}"
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ❌ $1${NC}"
}

info() {
    echo -e "${CYAN}[$(date +'%Y-%m-%d %H:%M:%S')] ℹ️  $1${NC}"
}

# Función para verificar si Docker Compose está disponible
check_docker_compose() {
    if ! command -v docker-compose >/dev/null 2>&1; then
        if ! docker compose version >/dev/null 2>&1; then
            error "Docker Compose no está disponible"
            exit 1
        fi
        COMPOSE_CMD="docker compose"
    else
        COMPOSE_CMD="docker-compose"
    fi
}

# Función para verificar estado de contenedores
check_containers() {
    log "Verificando estado de contenedores..."
    
    local containers=("postgresql-db" "pgadmin4-web")
    local all_running=true
    
    for container in "${containers[@]}"; do
        if docker ps --format "table {{.Names}}\t{{.Status}}" | grep -q "$container.*Up"; then
            success "Contenedor $container está funcionando"
        else
            error "Contenedor $container no está funcionando"
            all_running=false
        fi
    done
    
    if [ "$all_running" = false ]; then
        return 1
    fi
    
    return 0
}

# Función para verificar PostgreSQL
check_postgresql() {
    log "Verificando PostgreSQL..."
    
    # Verificar conexión
    if docker exec postgresql-db pg_isready -U postgres >/dev/null 2>&1; then
        success "PostgreSQL está funcionando"
    else
        error "PostgreSQL no está funcionando"
        return 1
    fi
    
    # Verificar bases de datos
    local databases=$(docker exec postgresql-db psql -U postgres -t -c "SELECT datname FROM pg_database WHERE datistemplate = false;" 2>/dev/null | tr -d ' \n')
    
    if [[ $databases == *"postgres"* ]]; then
        success "Base de datos 'postgres' existe"
    else
        error "Base de datos 'postgres' no existe"
        return 1
    fi
    
    if [[ $databases == *"development"* ]]; then
        success "Base de datos 'development' existe"
    else
        warning "Base de datos 'development' no existe"
    fi
    
    # Verificar extensiones
    local extensions=$(docker exec postgresql-db psql -U postgres -d postgres -t -c "SELECT extname FROM pg_extension;" 2>/dev/null | tr -d ' \n')
    
    if [[ $extensions == *"uuid-ossp"* ]]; then
        success "Extensión 'uuid-ossp' instalada"
    else
        warning "Extensión 'uuid-ossp' no instalada"
    fi
    
    return 0
}

# Función para verificar pgAdmin4
check_pgadmin() {
    log "Verificando pgAdmin4..."
    
    # Verificar que el contenedor esté funcionando
    if docker ps --format "table {{.Names}}\t{{.Status}}" | grep -q "pgadmin4-web.*Up"; then
        success "Contenedor pgAdmin4 está funcionando"
    else
        error "Contenedor pgAdmin4 no está funcionando"
        return 1
    fi
    
    # Verificar que el servicio web esté respondiendo
    if curl -f http://localhost:8080/misc/ping >/dev/null 2>&1; then
        success "pgAdmin4 web está respondiendo"
    else
        error "pgAdmin4 web no está respondiendo"
        return 1
    fi
    
    # Verificar que se pueda acceder a la interfaz
    if curl -f http://localhost:8080 >/dev/null 2>&1; then
        success "Interfaz web de pgAdmin4 accesible"
    else
        error "Interfaz web de pgAdmin4 no accesible"
        return 1
    fi
    
    return 0
}


# Función para verificar puertos
check_ports() {
    log "Verificando puertos..."
    
    # Verificar puerto PostgreSQL
    if netstat -tuln 2>/dev/null | grep -q ":5432 "; then
        success "Puerto 5432 (PostgreSQL) está abierto"
    else
        error "Puerto 5432 (PostgreSQL) no está abierto"
        return 1
    fi
    
    # Verificar puerto pgAdmin4
    if netstat -tuln 2>/dev/null | grep -q ":8080 "; then
        success "Puerto 8080 (pgAdmin4) está abierto"
    else
        error "Puerto 8080 (pgAdmin4) no está abierto"
        return 1
    fi
    
    
    return 0
}

# Función para verificar volúmenes
check_volumes() {
    log "Verificando volúmenes..."
    
    local volumes=("postgresql_data" "pgadmin_data")
    
    for volume in "${volumes[@]}"; do
        if docker volume ls --format "table {{.Name}}" | grep -q "$volume"; then
            success "Volumen $volume existe"
        else
            warning "Volumen $volume no existe"
        fi
    done
    
    return 0
}

# Función para verificar logs
check_logs() {
    log "Verificando logs..."
    
    # Verificar logs de PostgreSQL
    local postgres_logs=$(docker logs postgresql-db 2>&1 | tail -10)
    if echo "$postgres_logs" | grep -q "database system is ready"; then
        success "PostgreSQL iniciado correctamente"
    else
        warning "PostgreSQL puede no haber iniciado correctamente"
    fi
    
    # Verificar logs de pgAdmin4
    local pgadmin_logs=$(docker logs pgadmin4-web 2>&1 | tail -10)
    if echo "$pgadmin_logs" | grep -q "Booting"; then
        success "pgAdmin4 iniciado correctamente"
    else
        warning "pgAdmin4 puede no haber iniciado correctamente"
    fi
    
    return 0
}

# Función para mostrar resumen
show_summary() {
    echo ""
    success "🎉 Verificación completada!"
    echo ""
    info "📋 Resumen:"
    echo "  PostgreSQL: ✅ Funcionando"
    echo "  pgAdmin4: ✅ Funcionando"
    echo ""
    info "🔗 Accesos:"
    echo "  PostgreSQL: localhost:5432"
    echo "  pgAdmin4: http://localhost:8080"
    echo ""
    info "🔧 Comandos útiles:"
    echo "  Ver logs: $COMPOSE_CMD logs -f"
    echo "  Parar: ./scripts/stop.sh"
    echo "  Reiniciar: $COMPOSE_CMD restart"
}

# Función para mostrar ayuda
show_help() {
    cat << EOF
🔍 PostgreSQL Docker - Verify Script

Uso: $0 [OPCIONES]

OPCIONES:
    -h, --help              Mostrar esta ayuda
    -c, --containers         Solo verificar contenedores
    -p, --postgresql         Solo verificar PostgreSQL
    -g, --pgadmin           Solo verificar pgAdmin4
    -r, --redis             Solo verificar Redis
    -o, --ports             Solo verificar puertos
    -v, --volumes           Solo verificar volúmenes
    -l, --logs              Solo verificar logs
    -a, --all               Verificar todo (default)

FUNCIONES:
    - Verifica estado de contenedores
    - Verifica funcionamiento de PostgreSQL
    - Verifica funcionamiento de pgAdmin4
    - Verifica funcionamiento de Redis
    - Verifica puertos abiertos
    - Verifica volúmenes
    - Verifica logs

EJEMPLOS:
    $0                      # Verificar todo
    $0 -c                   # Solo contenedores
    $0 -p                   # Solo PostgreSQL
    $0 -g                   # Solo pgAdmin4
    $0 -a                   # Verificar todo

EOF
}

# Variables por defecto
CHECK_CONTAINERS=true
CHECK_POSTGRESQL=true
CHECK_PGADMIN=true
CHECK_REDIS=true
CHECK_PORTS=true
CHECK_VOLUMES=true
CHECK_LOGS=true

# Parsear argumentos
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -c|--containers)
            CHECK_CONTAINERS=true
            CHECK_POSTGRESQL=false
            CHECK_PGADMIN=false
            CHECK_REDIS=false
            CHECK_PORTS=false
            CHECK_VOLUMES=false
            CHECK_LOGS=false
            shift
            ;;
        -p|--postgresql)
            CHECK_CONTAINERS=false
            CHECK_POSTGRESQL=true
            CHECK_PGADMIN=false
            CHECK_REDIS=false
            CHECK_PORTS=false
            CHECK_VOLUMES=false
            CHECK_LOGS=false
            shift
            ;;
        -g|--pgadmin)
            CHECK_CONTAINERS=false
            CHECK_POSTGRESQL=false
            CHECK_PGADMIN=true
            CHECK_REDIS=false
            CHECK_PORTS=false
            CHECK_VOLUMES=false
            CHECK_LOGS=false
            shift
            ;;
        -r|--redis)
            CHECK_CONTAINERS=false
            CHECK_POSTGRESQL=false
            CHECK_PGADMIN=false
            CHECK_REDIS=true
            CHECK_PORTS=false
            CHECK_VOLUMES=false
            CHECK_LOGS=false
            shift
            ;;
        -o|--ports)
            CHECK_CONTAINERS=false
            CHECK_POSTGRESQL=false
            CHECK_PGADMIN=false
            CHECK_REDIS=false
            CHECK_PORTS=true
            CHECK_VOLUMES=false
            CHECK_LOGS=false
            shift
            ;;
        -v|--volumes)
            CHECK_CONTAINERS=false
            CHECK_POSTGRESQL=false
            CHECK_PGADMIN=false
            CHECK_REDIS=false
            CHECK_PORTS=false
            CHECK_VOLUMES=true
            CHECK_LOGS=false
            shift
            ;;
        -l|--logs)
            CHECK_CONTAINERS=false
            CHECK_POSTGRESQL=false
            CHECK_PGADMIN=false
            CHECK_REDIS=false
            CHECK_PORTS=false
            CHECK_VOLUMES=false
            CHECK_LOGS=true
            shift
            ;;
        -a|--all)
            CHECK_CONTAINERS=true
            CHECK_POSTGRESQL=true
            CHECK_PGADMIN=true
            CHECK_REDIS=true
            CHECK_PORTS=true
            CHECK_VOLUMES=true
            CHECK_LOGS=true
            shift
            ;;
        *)
            error "Opción desconocida: $1"
            show_help
            exit 1
            ;;
    esac
done

# Función principal
main() {
    log "🔍 Verificando PostgreSQL + pgAdmin4..."
    
    # Verificar Docker Compose
    check_docker_compose
    
    local all_ok=true
    
    # Verificar contenedores
    if [ "$CHECK_CONTAINERS" = true ]; then
        if ! check_containers; then
            all_ok=false
        fi
    fi
    
    # Verificar PostgreSQL
    if [ "$CHECK_POSTGRESQL" = true ]; then
        if ! check_postgresql; then
            all_ok=false
        fi
    fi
    
    # Verificar pgAdmin4
    if [ "$CHECK_PGADMIN" = true ]; then
        if ! check_pgadmin; then
            all_ok=false
        fi
    fi
    
    # Verificar Redis
    if [ "$CHECK_REDIS" = true ]; then
        if ! check_redis; then
            all_ok=false
        fi
    fi
    
    # Verificar puertos
    if [ "$CHECK_PORTS" = true ]; then
        if ! check_ports; then
            all_ok=false
        fi
    fi
    
    # Verificar volúmenes
    if [ "$CHECK_VOLUMES" = true ]; then
        check_volumes
    fi
    
    # Verificar logs
    if [ "$CHECK_LOGS" = true ]; then
        check_logs
    fi
    
    # Mostrar resumen
    if [ "$all_ok" = true ]; then
        show_summary
    else
        error "❌ Algunas verificaciones fallaron"
        exit 1
    fi
}

# Ejecutar función principal
main "$@"
