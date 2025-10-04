#!/bin/bash

# 🚀 PostgreSQL Docker - Start Script
# Script para iniciar PostgreSQL + pgAdmin4 con Docker

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

# Función para verificar si Docker está instalado
check_docker() {
    if ! command -v docker >/dev/null 2>&1; then
        error "Docker no está instalado"
        log "Ejecuta: ./pipeline/install-docker.sh"
        exit 1
    fi
    
    if ! docker info >/dev/null 2>&1; then
        error "Docker no está funcionando"
        log "Verifica que Docker esté ejecutándose"
        exit 1
    fi
}

# Función para verificar si Docker Compose está disponible
check_docker_compose() {
    if ! command -v docker-compose >/dev/null 2>&1; then
        warning "Docker Compose no está disponible"
        log "Intentando usar 'docker compose' (nueva sintaxis)..."
        
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

# Función para construir las imágenes
build_images() {
    log "Construyendo imágenes Docker..."
    
    # Construir imagen de PostgreSQL
    log "Construyendo imagen de PostgreSQL..."
    docker build -f docker/Dockerfile.postgresql -t postgresql-custom:latest ./docker/
    
    # Construir imagen de pgAdmin4
    log "Construyendo imagen de pgAdmin4..."
    docker build -f docker/Dockerfile.pgadmin -t pgadmin-custom:latest ./docker/
    
    success "Imágenes construidas correctamente"
}

# Función para iniciar los servicios
start_services() {
    log "Iniciando servicios..."
    
    # Iniciar servicios en segundo plano
    $COMPOSE_CMD up -d
    
    success "Servicios iniciados"
}

# Función para verificar el estado de los servicios
check_services() {
    log "Verificando estado de los servicios..."
    
    # Esperar a que los servicios estén listos
    log "Esperando a que PostgreSQL esté listo..."
    timeout 60 bash -c 'until docker exec postgresql-db pg_isready -U postgres; do sleep 2; done'
    
    log "Esperando a que pgAdmin4 esté listo..."
    timeout 60 bash -c 'until curl -f http://localhost:8080/misc/ping >/dev/null 2>&1; do sleep 2; done'
    
    success "Todos los servicios están funcionando"
}

# Función para mostrar información de conexión
show_connection_info() {
    echo ""
    success "🎉 PostgreSQL + pgAdmin4 están funcionando!"
    echo ""
    info "📋 Información de conexión:"
    echo "  PostgreSQL:"
    echo "    Host: localhost"
    echo "    Puerto: 5432"
    echo "    Usuario: postgres"
    echo "    Contraseña: postgres123"
    echo "    Base de datos: postgres"
    echo ""
    echo "  pgAdmin4:"
    echo "    URL: http://localhost:8080"
    echo "    Email: admin@postgresql.local"
    echo "    Contraseña: admin123"
    echo ""
    echo ""
    info "🔧 Comandos útiles:"
    echo "  Ver logs: $COMPOSE_CMD logs -f"
    echo "  Parar servicios: $COMPOSE_CMD down"
    echo "  Reiniciar: $COMPOSE_CMD restart"
    echo "  Estado: $COMPOSE_CMD ps"
}

# Función para mostrar ayuda
show_help() {
    cat << EOF
🚀 PostgreSQL Docker - Start Script

Uso: $0 [OPCIONES]

OPCIONES:
    -h, --help              Mostrar esta ayuda
    -b, --build             Construir imágenes antes de iniciar
    -f, --force              Forzar reconstrucción de imágenes
    -v, --verbose            Mostrar output detallado
    -s, --skip-check         Omitir verificación de servicios

FUNCIONES:
    - Verifica que Docker esté instalado y funcionando
    - Crea archivo .env si no existe
    - Construye imágenes Docker personalizadas
    - Inicia PostgreSQL + pgAdmin4 + Redis
    - Verifica que todos los servicios estén funcionando
    - Muestra información de conexión

EJEMPLOS:
    $0                      # Iniciar servicios
    $0 -b                   # Construir e iniciar
    $0 -f -b                # Forzar reconstrucción e iniciar
    $0 -v                   # Modo verbose

EOF
}

# Variables por defecto
BUILD_IMAGES=false
FORCE_BUILD=false
VERBOSE=false
SKIP_CHECK=false

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
        *)
            error "Opción desconocida: $1"
            show_help
            exit 1
            ;;
    esac
done

# Función principal
main() {
    log "🚀 Iniciando PostgreSQL + pgAdmin4 con Docker..."
    
    # Verificar Docker
    check_docker
    check_docker_compose
    
    # Crear archivo .env
    create_env_file
    
    # Construir imágenes si es necesario
    if [ "$BUILD_IMAGES" = true ]; then
        if [ "$FORCE_BUILD" = true ]; then
            log "Forzando reconstrucción de imágenes..."
            $COMPOSE_CMD build --no-cache
        else
            build_images
        fi
    fi
    
    # Iniciar servicios
    start_services
    
    # Verificar servicios
    if [ "$SKIP_CHECK" = false ]; then
        check_services
    fi
    
    # Mostrar información
    show_connection_info
}

# Ejecutar función principal
main "$@"
