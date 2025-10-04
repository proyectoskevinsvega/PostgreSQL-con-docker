#!/bin/bash

# 🛑 PostgreSQL Docker - Stop Script
# Script para parar PostgreSQL + pgAdmin4

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

# Función para parar servicios
stop_services() {
    log "Parando servicios..."
    
    # Parar servicios
    $COMPOSE_CMD down
    
    success "Servicios parados"
}

# Función para limpiar recursos
cleanup_resources() {
    log "Limpiando recursos..."
    
    # Eliminar contenedores
    $COMPOSE_CMD rm -f
    
    # Eliminar volúmenes si se solicita
    if [ "$CLEANUP_VOLUMES" = true ]; then
        warning "Eliminando volúmenes de datos..."
        $COMPOSE_CMD down -v
        success "Volúmenes eliminados"
    fi
    
    # Eliminar imágenes si se solicita
    if [ "$CLEANUP_IMAGES" = true ]; then
        warning "Eliminando imágenes personalizadas..."
        docker rmi postgresql-custom:latest 2>/dev/null || true
        docker rmi pgadmin-custom:latest 2>/dev/null || true
        success "Imágenes eliminadas"
    fi
}

# Función para mostrar estado
show_status() {
    log "Estado actual de los servicios:"
    $COMPOSE_CMD ps
}

# Función para mostrar ayuda
show_help() {
    cat << EOF
🛑 PostgreSQL Docker - Stop Script

Uso: $0 [OPCIONES]

OPCIONES:
    -h, --help              Mostrar esta ayuda
    -v, --volumes            Eliminar volúmenes de datos
    -i, --images             Eliminar imágenes personalizadas
    -a, --all                Eliminar todo (volúmenes + imágenes)
    -s, --status             Mostrar estado antes de parar
    -f, --force              Forzar parada sin confirmación

FUNCIONES:
    - Para todos los servicios (PostgreSQL + pgAdmin4 + Redis)
    - Opcionalmente elimina volúmenes de datos
    - Opcionalmente elimina imágenes personalizadas
    - Muestra estado de los servicios

EJEMPLOS:
    $0                      # Parar servicios
    $0 -v                   # Parar y eliminar volúmenes
    $0 -i                   # Parar y eliminar imágenes
    $0 -a                   # Parar y eliminar todo
    $0 -s                   # Mostrar estado y parar

ADVERTENCIA:
    -v, --volumes: Elimina TODOS los datos de PostgreSQL
    -i, --images: Elimina las imágenes personalizadas
    -a, --all: Elimina volúmenes e imágenes (DESTRUCTIVO)

EOF
}

# Variables por defecto
CLEANUP_VOLUMES=false
CLEANUP_IMAGES=false
CLEANUP_ALL=false
SHOW_STATUS=false
FORCE=false

# Parsear argumentos
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -v|--volumes)
            CLEANUP_VOLUMES=true
            shift
            ;;
        -i|--images)
            CLEANUP_IMAGES=true
            shift
            ;;
        -a|--all)
            CLEANUP_ALL=true
            CLEANUP_VOLUMES=true
            CLEANUP_IMAGES=true
            shift
            ;;
        -s|--status)
            SHOW_STATUS=true
            shift
            ;;
        -f|--force)
            FORCE=true
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
    log "🛑 Parando PostgreSQL + pgAdmin4..."
    
    # Verificar Docker Compose
    check_docker_compose
    
    # Mostrar estado si se solicita
    if [ "$SHOW_STATUS" = true ]; then
        show_status
    fi
    
    # Confirmar si se van a eliminar datos
    if [ "$CLEANUP_VOLUMES" = true ] || [ "$CLEANUP_ALL" = true ]; then
        if [ "$FORCE" = false ]; then
            warning "⚠️  ADVERTENCIA: Se eliminarán los datos de PostgreSQL"
            read -p "¿Estás seguro? (y/N): " confirm_choice
            if [[ ! $confirm_choice =~ ^[Yy]$ ]]; then
                warning "Operación cancelada"
                exit 0
            fi
        fi
    fi
    
    # Parar servicios
    stop_services
    
    # Limpiar recursos si se solicita
    if [ "$CLEANUP_VOLUMES" = true ] || [ "$CLEANUP_IMAGES" = true ] || [ "$CLEANUP_ALL" = true ]; then
        cleanup_resources
    fi
    
    success "🎉 Servicios parados correctamente"
    
    # Mostrar información
    echo ""
    info "📋 Información:"
    echo "  Servicios parados: PostgreSQL, pgAdmin4, Redis"
    if [ "$CLEANUP_VOLUMES" = true ]; then
        echo "  Volúmenes eliminados: postgresql_data, pgadmin_data, redis_data"
    fi
    if [ "$CLEANUP_IMAGES" = true ]; then
        echo "  Imágenes eliminadas: postgresql-custom, pgadmin-custom"
    fi
    echo ""
    info "🔧 Para reiniciar: ./scripts/start.sh"
}

# Ejecutar función principal
main "$@"
