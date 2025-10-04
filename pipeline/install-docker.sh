#!/bin/bash

# 🐳 PostgreSQL Docker - Install Docker Pipeline
# Script para instalar Docker automáticamente y verificar la instalación

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
check_docker_installed() {
    if command -v docker >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# Función para verificar si Docker está funcionando
check_docker_running() {
    if docker info >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# Función para obtener la versión de Docker
get_docker_version() {
    if check_docker_installed; then
        docker --version | cut -d' ' -f3 | cut -d',' -f1
    else
        echo "Docker no está instalado"
    fi
}

# Función para instalar Docker en Ubuntu/Debian
install_docker_ubuntu() {
    log "Instalando Docker en Ubuntu/Debian..."
    
    # Actualizar paquetes
    sudo apt-get update
    
    # Instalar prerequisitos
    sudo apt-get install -y \
        ca-certificates \
        curl \
        gnupg \
        lsb-release
    
    # Agregar clave GPG oficial de Docker
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    
    # Configurar repositorio
    echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
        $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    # Actualizar paquetes
    sudo apt-get update
    
    # Instalar Docker Engine
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    
    # Agregar usuario al grupo docker
    sudo usermod -aG docker $USER
    
    success "Docker instalado correctamente en Ubuntu/Debian"
}

# Función para instalar Docker en CentOS/RHEL
install_docker_centos() {
    log "Instalando Docker en CentOS/RHEL..."
    
    # Instalar prerequisitos
    sudo yum install -y yum-utils
    
    # Agregar repositorio de Docker
    sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    
    # Instalar Docker Engine
    sudo yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    
    # Iniciar y habilitar Docker
    sudo systemctl start docker
    sudo systemctl enable docker
    
    # Agregar usuario al grupo docker
    sudo usermod -aG docker $USER
    
    success "Docker instalado correctamente en CentOS/RHEL"
}

# Función para instalar Docker en macOS
install_docker_macos() {
    log "Instalando Docker en macOS..."
    
    if command -v brew >/dev/null 2>&1; then
        # Instalar Docker Desktop via Homebrew
        brew install --cask docker
        success "Docker Desktop instalado via Homebrew"
    else
        error "Homebrew no está instalado. Instala Homebrew primero o descarga Docker Desktop manualmente."
        exit 1
    fi
}

# Función para instalar Docker en Windows
install_docker_windows() {
    log "Instalando Docker en Windows..."
    
    if command -v winget >/dev/null 2>&1; then
        # Instalar Docker Desktop via winget
        winget install Docker.DockerDesktop
        success "Docker Desktop instalado via winget"
    else
        error "winget no está disponible. Descarga Docker Desktop manualmente desde https://www.docker.com/products/docker-desktop"
        exit 1
    fi
}

# Función para detectar el sistema operativo
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if [ -f /etc/os-release ]; then
            . /etc/os-release
            case $ID in
                ubuntu|debian)
                    echo "ubuntu"
                    ;;
                centos|rhel|fedora)
                    echo "centos"
                    ;;
                *)
                    echo "linux"
                    ;;
            esac
        else
            echo "linux"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
        echo "windows"
    else
        echo "unknown"
    fi
}

# Función para verificar la instalación de Docker
verify_docker_installation() {
    log "Verificando instalación de Docker..."
    
    if ! check_docker_installed; then
        error "Docker no está instalado"
        return 1
    fi
    
    if ! check_docker_running; then
        warning "Docker está instalado pero no está funcionando"
        log "Intentando iniciar Docker..."
        
        # Intentar iniciar Docker
        if command -v systemctl >/dev/null 2>&1; then
            sudo systemctl start docker
            sudo systemctl enable docker
        fi
        
        # Esperar un momento
        sleep 5
        
        if ! check_docker_running; then
            error "No se pudo iniciar Docker"
            return 1
        fi
    fi
    
    # Verificar versión
    local version=$(get_docker_version)
    success "Docker está funcionando correctamente (versión: $version)"
    
    # Verificar Docker Compose
    if command -v docker-compose >/dev/null 2>&1; then
        local compose_version=$(docker-compose --version | cut -d' ' -f3 | cut -d',' -f1)
        success "Docker Compose está disponible (versión: $compose_version)"
    else
        warning "Docker Compose no está disponible"
    fi
    
    return 0
}

# Función para mostrar información del sistema
show_system_info() {
    log "Información del sistema:"
    echo "  OS: $(uname -s)"
    echo "  Architecture: $(uname -m)"
    echo "  Kernel: $(uname -r)"
    
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if [ -f /etc/os-release ]; then
            . /etc/os-release
            echo "  Distribution: $PRETTY_NAME"
        fi
    fi
}

# Función para mostrar ayuda
show_help() {
    cat << EOF
🐳 PostgreSQL Docker - Install Docker Pipeline

Uso: $0 [OPCIONES]

OPCIONES:
    -h, --help              Mostrar esta ayuda
    -c, --check             Solo verificar si Docker está instalado
    -f, --force             Forzar reinstalación de Docker
    -v, --verbose           Mostrar output detallado
    -s, --skip-verification Omitir verificación post-instalación

FUNCIONES:
    - Detecta automáticamente el sistema operativo
    - Instala Docker en la última versión disponible
    - Verifica la instalación y funcionamiento
    - Configura permisos de usuario
    - Instala Docker Compose

SISTEMAS SOPORTADOS:
    - Ubuntu/Debian
    - CentOS/RHEL/Fedora
    - macOS (via Homebrew)
    - Windows (via winget)

EJEMPLOS:
    $0                      # Instalar Docker automáticamente
    $0 -c                   # Solo verificar instalación
    $0 -f                   # Forzar reinstalación
    $0 -v                   # Modo verbose

EOF
}

# Variables por defecto
CHECK_ONLY=false
FORCE_INSTALL=false
VERBOSE=false
SKIP_VERIFICATION=false

# Parsear argumentos
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -c|--check)
            CHECK_ONLY=true
            shift
            ;;
        -f|--force)
            FORCE_INSTALL=true
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -s|--skip-verification)
            SKIP_VERIFICATION=true
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
    log "🐳 Iniciando pipeline de instalación de Docker..."
    
    # Mostrar información del sistema
    show_system_info
    
    # Verificar si Docker ya está instalado
    if check_docker_installed; then
        local version=$(get_docker_version)
        success "Docker ya está instalado (versión: $version)"
        
        if [ "$CHECK_ONLY" = true ]; then
            if check_docker_running; then
                success "Docker está funcionando correctamente"
                exit 0
            else
                error "Docker está instalado pero no está funcionando"
                exit 1
            fi
        fi
        
        if [ "$FORCE_INSTALL" = false ]; then
            warning "Docker ya está instalado. Usa -f para forzar reinstalación"
            exit 0
        fi
    fi
    
    # Detectar sistema operativo
    local os=$(detect_os)
    log "Sistema operativo detectado: $os"
    
    # Instalar Docker según el sistema operativo
    case $os in
        ubuntu)
            install_docker_ubuntu
            ;;
        centos)
            install_docker_centos
            ;;
        macos)
            install_docker_macos
            ;;
        windows)
            install_docker_windows
            ;;
        linux)
            warning "Sistema Linux genérico detectado. Intentando instalación para Ubuntu/Debian..."
            install_docker_ubuntu
            ;;
        *)
            error "Sistema operativo no soportado: $os"
            exit 1
            ;;
    esac
    
    # Verificar instalación
    if [ "$SKIP_VERIFICATION" = false ]; then
        verify_docker_installation
    fi
    
    success "🎉 Pipeline de instalación de Docker completado!"
    
    # Mostrar próximos pasos
    echo ""
    info "Próximos pasos:"
    echo "1. Reinicia la sesión o ejecuta: newgrp docker"
    echo "2. Verifica la instalación: docker --version"
    echo "3. Ejecuta el proyecto: ./scripts/start.sh"
    echo "4. Accede a pgAdmin4 en: http://localhost:8080"
}

# Ejecutar función principal
main "$@"
