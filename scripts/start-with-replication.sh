#!/bin/bash

# 🚀 PostgreSQL Docker - Start with Replication
# Script para iniciar PostgreSQL con replicación

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

# Función para crear archivo .env si no existe
create_env_file() {
    if [ ! -f .env ]; then
        log "Creando archivo .env desde env.example..."
        cp env.example .env
        success "Archivo .env creado"
    else
        info "Archivo .env ya existe"
    fi
}

# Función para configurar replicación
configure_replication() {
    log "Configurando replicación..."
    
    # Habilitar replicación
    sed -i 's/REPLICATION_ENABLED=false/REPLICATION_ENABLED=true/' .env
    
    # Configurar puertos
    sed -i 's/POSTGRES_REPLICA_PORT=5433/POSTGRES_REPLICA_PORT=5433/' .env
    
    success "Replicación configurada"
}

# Función para configurar monitoreo
configure_monitoring() {
    log "Configurando monitoreo..."
    
    # Habilitar Prometheus y Grafana
    sed -i 's/PROMETHEUS_ENABLED=false/PROMETHEUS_ENABLED=true/' .env
    sed -i 's/GRAFANA_ENABLED=false/GRAFANA_ENABLED=true/' .env
    
    success "Monitoreo configurado"
}

# Función para iniciar servicios básicos
start_basic_services() {
    log "Iniciando servicios básicos (PostgreSQL + pgAdmin4)..."
    
    $COMPOSE_CMD up -d postgresql pgadmin
    
    success "Servicios básicos iniciados"
}

# Función para iniciar servicios de replicación
start_replication_services() {
    log "Iniciando servicios de replicación..."
    
    $COMPOSE_CMD --profile replication up -d postgresql-replica
    
    success "Servicios de replicación iniciados"
}

# Función para iniciar servicios de monitoreo
start_monitoring_services() {
    log "Iniciando servicios de monitoreo (Prometheus + Grafana)..."
    
    $COMPOSE_CMD --profile monitoring up -d
    
    success "Servicios de monitoreo iniciados"
}

# Función para verificar servicios
check_services() {
    log "Verificando servicios..."
    
    # Esperar a que PostgreSQL esté listo
    log "Esperando a que PostgreSQL esté listo..."
    timeout 60 bash -c 'until docker exec postgresql-db pg_isready -U postgres; do sleep 2; done'
    
    # Esperar a que pgAdmin4 esté listo
    log "Esperando a que pgAdmin4 esté listo..."
    timeout 60 bash -c 'until curl -f http://localhost:8080/misc/ping >/dev/null 2>&1; do sleep 2; done'
    
    # Esperar a que PostgreSQL Replica esté listo
    log "Esperando a que PostgreSQL Replica esté listo..."
    timeout 60 bash -c 'until docker exec postgresql-replica pg_isready -U postgres; do sleep 2; done'
    
    # Esperar a que Prometheus esté listo
    log "Esperando a que Prometheus esté listo..."
    timeout 60 bash -c 'until curl -f http://localhost:9090/-/healthy >/dev/null 2>&1; do sleep 2; done'
    
    # Esperar a que Grafana esté listo
    log "Esperando a que Grafana esté listo..."
    timeout 60 bash -c 'until curl -f http://localhost:3000/api/health >/dev/null 2>&1; do sleep 2; done'
    
    success "Todos los servicios están funcionando"
}

# Función para verificar replicación
check_replication() {
    log "Verificando estado de replicación..."
    
    # Verificar que la réplica esté funcionando
    if docker exec postgresql-replica pg_isready -U postgres >/dev/null 2>&1; then
        success "PostgreSQL Replica está funcionando"
    else
        error "PostgreSQL Replica no está funcionando"
        return 1
    fi
    
    # Verificar lag de replicación
    local lag=$(docker exec postgresql-replica psql -U postgres -t -c "SELECT EXTRACT(EPOCH FROM (now() - pg_last_xact_replay_timestamp()));" 2>/dev/null | tr -d ' \n')
    
    if [ -n "$lag" ] && [ "$lag" != "" ]; then
        success "Replicación funcionando (lag: ${lag}s)"
    else
        warning "No se pudo verificar el lag de replicación"
    fi
}

# Función para mostrar información de conexión
show_connection_info() {
    echo ""
    success "🎉 PostgreSQL + Replica + pgAdmin4 + Prometheus + Grafana están funcionando!"
    echo ""
    info "📋 Información de conexión:"
    echo "  PostgreSQL Master:"
    echo "    Host: localhost"
    echo "    Puerto: 5432"
    echo "    Usuario: postgres"
    echo "    Contraseña: postgres123"
    echo "    Base de datos: postgres"
    echo ""
    echo "  PostgreSQL Replica:"
    echo "    Host: localhost"
    echo "    Puerto: 5433"
    echo "    Usuario: postgres"
    echo "    Contraseña: postgres123"
    echo "    Base de datos: postgres"
    echo ""
    echo "  pgAdmin4:"
    echo "    URL: http://localhost:8080"
    echo "    Email: admin@postgresql.local"
    echo "    Contraseña: admin123"
    echo ""
    echo "  Prometheus:"
    echo "    URL: http://localhost:9090"
    echo "    Métricas: http://localhost:9090/metrics"
    echo ""
    echo "  Grafana:"
    echo "    URL: http://localhost:3000"
    echo "    Usuario: admin"
    echo "    Contraseña: admin123"
    echo ""
    info "🔧 Comandos útiles:"
    echo "  Ver logs: $COMPOSE_CMD logs -f"
    echo "  Parar servicios: $COMPOSE_CMD down"
    echo "  Reiniciar: $COMPOSE_CMD restart"
    echo "  Estado: $COMPOSE_CMD ps"
    echo "  Solo replicación: $COMPOSE_CMD --profile replication up -d"
    echo "  Solo monitoreo: $COMPOSE_CMD --profile monitoring up -d"
}

# Función para mostrar ayuda
show_help() {
    cat << EOF
🚀 PostgreSQL Docker - Start with Replication

Uso: $0 [OPCIONES]

OPCIONES:
    -h, --help              Mostrar esta ayuda
    -b, --build             Construir imágenes antes de iniciar
    -f, --force              Forzar reconstrucción de imágenes
    -v, --verbose            Mostrar output detallado
    -s, --skip-check         Omitir verificación de servicios
    -r, --replication-only   Solo iniciar servicios de replicación
    -m, --monitoring-only    Solo iniciar servicios de monitoreo
    -b, --basic-only         Solo iniciar servicios básicos

FUNCIONES:
    - Verifica que Docker esté instalado y funcionando
    - Crea archivo .env si no existe
    - Configura replicación automáticamente
    - Inicia PostgreSQL Master + Replica + pgAdmin4 + Prometheus + Grafana
    - Verifica que todos los servicios estén funcionando
    - Verifica el estado de replicación
    - Muestra información de conexión

EJEMPLOS:
    $0                      # Iniciar todos los servicios
    $0 -b                   # Construir e iniciar
    $0 -r                   # Solo replicación
    $0 -m                   # Solo monitoreo
    $0 -b                   # Solo servicios básicos

EOF
}

# Variables por defecto
BUILD_IMAGES=false
FORCE_BUILD=false
VERBOSE=false
SKIP_CHECK=false
REPLICATION_ONLY=false
MONITORING_ONLY=false
BASIC_ONLY=false

# Parsear argumentos
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -b|--build)
            BUILD_IMAGES=true
            shift
            ;;
        -f|--force)
            FORCE_BUILD=true
            BUILD_IMAGES=true
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -s|--skip-check)
            SKIP_CHECK=true
            shift
            ;;
        -r|--replication-only)
            REPLICATION_ONLY=true
            shift
            ;;
        -m|--monitoring-only)
            MONITORING_ONLY=true
            shift
            ;;
        -b|--basic-only)
            BASIC_ONLY=true
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
    log "🚀 Iniciando PostgreSQL con Replicación y Monitoreo..."
    
    # Verificar Docker Compose
    check_docker_compose
    
    # Crear archivo .env
    create_env_file
    
    # Configurar replicación
    configure_replication
    
    # Configurar monitoreo
    configure_monitoring
    
    # Construir imágenes si es necesario
    if [ "$BUILD_IMAGES" = true ]; then
        if [ "$FORCE_BUILD" = true ]; then
            log "Forzando reconstrucción de imágenes..."
            $COMPOSE_CMD build --no-cache
        else
            log "Construyendo imágenes..."
            $COMPOSE_CMD build
        fi
    fi
    
    # Iniciar servicios según la opción
    if [ "$BASIC_ONLY" = true ]; then
        start_basic_services
    elif [ "$REPLICATION_ONLY" = true ]; then
        start_basic_services
        start_replication_services
    elif [ "$MONITORING_ONLY" = true ]; then
        start_monitoring_services
    else
        start_basic_services
        start_replication_services
        start_monitoring_services
    fi
    
    # Verificar servicios
    if [ "$SKIP_CHECK" = false ]; then
        check_services
        check_replication
    fi
    
    # Mostrar información
    show_connection_info
}

# Ejecutar función principal
main "$@"
