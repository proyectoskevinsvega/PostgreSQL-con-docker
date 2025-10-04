# 🐳 PostgreSQL Docker - PostgreSQL + pgAdmin4 con Docker

Este proyecto proporciona una **solución completa de PostgreSQL con Docker** que incluye PostgreSQL y pgAdmin4, con **pipeline automático de instalación de Docker** y **scripts de automatización**.

## 🎯 Características Principales

- **PostgreSQL 15**: Base de datos relacional de última generación
- **pgAdmin4**: Panel de gestión web en http://localhost:8080
- **Prometheus**: Monitoreo y métricas en http://localhost:9090
- **Grafana**: Dashboards y visualización en http://localhost:3000
- **Replicación Opcional**: PostgreSQL Master-Slave configurable
- **Docker Compose**: Orquestación de contenedores
- **Pipeline Automático**: Instalación automática de Docker
- **Scripts de Automatización**: Start, stop, verify, backup
- **Configuración Optimizada**: Para desarrollo y producción
- **Datos de Ejemplo**: Incluye datos de prueba

## 🏗️ Arquitectura del Proyecto

```
┌─────────────────────────────────────────────────────────────┐
│                    PostgreSQL Docker                        │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────┐ │
│  │   PostgreSQL    │  │   pgAdmin4      │  │ PostgreSQL  │ │
│  │   Master        │  │   Web Panel     │  │   Replica   │ │
│  │   Port: 5432    │  │   Port: 8080    │  │ Port: 5433  │ │
│  └─────────────────┘  └─────────────────┘  └─────────────┘ │
│           │                     │                   │       │
│  ┌────────▼─────────┐  ┌────────▼─────────┐  ┌────▼─────┐ │
│  │   Prometheus     │  │   Grafana        │  │ Docker   │ │
│  │   Monitoring     │  │   Dashboards     │  │ Compose  │ │
│  │   Port: 9090     │  │   Port: 3000     │  │          │ │
│  └──────────────────┘  └──────────────────┘  └──────────┘ │
└─────────────────────────────────────────────────────────────┘
```

## 📁 Estructura del Proyecto

```
postgreSQL-docker/
├── docker/                     # Configuración Docker
│   ├── Dockerfile.postgresql   # Imagen personalizada PostgreSQL
│   ├── Dockerfile.pgadmin      # Imagen personalizada pgAdmin4
│   ├── postgresql.conf         # Configuración PostgreSQL
│   ├── pg_hba.conf             # Configuración autenticación
│   ├── pgadmin-servers.json    # Configuración servidores pgAdmin
│   └── init-scripts/           # Scripts de inicialización
│       ├── 01-create-databases.sh
│       ├── 02-create-extensions.sh
│       └── 03-create-sample-data.sh
├── pipeline/                   # Pipeline de instalación
│   └── install-docker.sh       # Instalación automática Docker
├── scripts/                    # Scripts de automatización
│   ├── start.sh                # Iniciar servicios
│   ├── stop.sh                 # Parar servicios
│   └── verify.sh               # Verificar funcionamiento
├── examples/                   # Aplicaciones de ejemplo
├── docs/                       # Documentación
├── docker-compose.yml          # Orquestación de contenedores
├── env.example                 # Variables de entorno
├── Makefile                    # Comandos de gestión
└── README.md                   # Este archivo
```

## 🚀 Inicio Rápido

### 1. **Instalación Automática de Docker**
```bash
# Instalar Docker automáticamente
make install

# O directamente
./pipeline/install-docker.sh
```

### 2. **Iniciar Servicios**
```bash
# Iniciar PostgreSQL + pgAdmin4
make start

# O directamente
./scripts/start.sh
```

### 3. **Acceder a los Servicios**
- **PostgreSQL**: `localhost:5432`
- **pgAdmin4**: http://localhost:8080
- **Redis**: `localhost:6379`

### 4. **Verificar Funcionamiento**
```bash
# Verificar que todo esté funcionando
make verify

# O directamente
./scripts/verify.sh
```

## 🛠️ Comandos Disponibles

### **Comandos Principales**
```bash
make install        # Instalar Docker automáticamente
make start          # Iniciar servicios básicos (PostgreSQL + pgAdmin4)
make start-monitoring # Iniciar con monitoreo (Prometheus + Grafana)
make start-replication # Iniciar con replicación
make start-full     # Iniciar todo (PostgreSQL + Replica + Monitoreo)
make stop           # Parar servicios
make restart        # Reiniciar servicios
make status         # Ver estado
make logs           # Ver logs
make verify         # Verificar funcionamiento
make clean          # Limpiar recursos
```

### **Comandos de Monitoreo**
```bash
make monitoring-start    # Iniciar servicios de monitoreo
make monitoring-stop     # Parar servicios de monitoreo
make monitoring-status   # Estado de servicios de monitoreo
make monitoring-logs     # Logs de servicios de monitoreo
make prometheus-open     # Abrir Prometheus
make grafana-open       # Abrir Grafana
```

### **Comandos de Replicación**
```bash
make replication-start      # Iniciar servicios de replicación
make replication-stop        # Parar servicios de replicación
make replication-status      # Estado de servicios de replicación
make replication-logs        # Logs de servicios de replicación
make postgresql-replica-connect # Conectar a PostgreSQL Replica
make postgresql-replica-status  # Estado de replicación
make postgresql-replica-lag    # Lag de replicación
```

### **Comandos de Desarrollo**
```bash
make dev-start      # Modo desarrollo
make dev-stop       # Parar desarrollo
make dev-restart    # Reiniciar desarrollo
```

### **Comandos de Base de Datos**
```bash
make db-connect     # Conectar a PostgreSQL
make db-shell       # Shell de PostgreSQL
make backup         # Crear backup
make restore FILE=backup.sql  # Restaurar backup
```

### **Comandos de pgAdmin4**
```bash
make pgadmin-open   # Abrir pgAdmin4
# URL: http://localhost:8080
# Email: admin@postgresql.local
# Contraseña: admin123
```

### **Comandos de Redis**
```bash
make redis-connect  # Conectar a Redis
```

## 🔧 Configuración

### **Variables de Entorno**
```bash
# Copiar archivo de ejemplo
cp env.example .env

# Editar configuración
nano .env
```

### **Configuración PostgreSQL**
- **Host**: localhost
- **Puerto**: 5432
- **Usuario**: postgres
- **Contraseña**: postgres123
- **Base de datos**: postgres

### **Configuración pgAdmin4**
- **URL**: http://localhost:8080
- **Email**: admin@postgresql.local
- **Contraseña**: admin123

### **Configuración Redis**
- **Host**: localhost
- **Puerto**: 6379
- **Contraseña**: redis123

## 📊 Características Técnicas

### **PostgreSQL 15**
- **Versión**: PostgreSQL 15
- **Configuración**: Optimizada para desarrollo
- **Extensiones**: uuid-ossp, pg_stat_statements, pg_trgm
- **Bases de datos**: postgres, development, testing, staging
- **Datos de ejemplo**: Usuarios, productos, órdenes

### **pgAdmin4**
- **Versión**: Última versión
- **Interfaz**: Web responsive
- **Funciones**: Gestión completa de PostgreSQL
- **Seguridad**: Configuración segura

### **Redis**
- **Versión**: Redis 7
- **Configuración**: Persistencia habilitada
- **Uso**: Caché y sesiones

## 🔒 Seguridad

### **Configuración de Red**
- **Red privada**: postgresql_network
- **Puertos expuestos**: Solo los necesarios
- **Firewall**: Configuración segura

### **Autenticación**
- **PostgreSQL**: SCRAM-SHA-256
- **pgAdmin4**: Autenticación web
- **Redis**: Contraseña requerida

### **Datos**
- **Volúmenes**: Datos persistentes
- **Backup**: Scripts automáticos
- **Encriptación**: SSL/TLS disponible

## 📈 Performance

### **Configuración Optimizada**
- **shared_buffers**: 256MB
- **effective_cache_size**: 1GB
- **work_mem**: 4MB
- **maintenance_work_mem**: 64MB

### **Monitoreo**
- **Logs**: Configuración detallada
- **Métricas**: pg_stat_statements
- **Health checks**: Automáticos

## 🚨 Troubleshooting

### **Problemas Comunes**

#### **Docker no está instalado**
```bash
# Instalar Docker automáticamente
make install
```

#### **Servicios no inician**
```bash
# Verificar logs
make logs

# Reiniciar servicios
make restart
```

#### **No se puede conectar a PostgreSQL**
```bash
# Verificar estado
make status

# Verificar puertos
netstat -tuln | grep 5432
```

#### **pgAdmin4 no carga**
```bash
# Verificar que esté funcionando
curl http://localhost:8080

# Ver logs
docker logs pgadmin4-web
```

### **Comandos de Diagnóstico**
```bash
# Ver estado de contenedores
make status

# Ver logs de servicios
make logs

# Verificar funcionamiento
make verify

# Ver información del sistema
make system-info
```

## 📚 Casos de Uso

### **Desarrollo Local**
```bash
# Iniciar entorno de desarrollo
make dev-start

# Conectar a base de datos
make db-connect

# Abrir pgAdmin4
make pgadmin-open
```

### **Testing**
```bash
# Iniciar para testing
make test-start

# Ejecutar tests
make verify

# Parar testing
make test-stop
```

### **Producción**
```bash
# Iniciar en producción
make prod-start

# Crear backup
make backup

# Monitorear
make monitor
```

## 🔄 Backup y Restore

### **Crear Backup**
```bash
# Backup automático
make backup

# Backup manual
docker exec postgresql-db pg_dumpall -U postgres > backup.sql
```

### **Restaurar Backup**
```bash
# Restaurar backup
make restore FILE=backup.sql

# Restaurar manual
docker exec -i postgresql-db psql -U postgres < backup.sql
```

## 📋 Checklist de Implementación

### **Pre-requisitos**
- [ ] Sistema operativo soportado
- [ ] Permisos de administrador
- [ ] Conexión a internet
- [ ] Puertos 5432, 8080, 6379 disponibles

### **Instalación**
- [ ] Docker instalado automáticamente
- [ ] Docker Compose disponible
- [ ] Imágenes construidas
- [ ] Servicios iniciados

### **Verificación**
- [ ] PostgreSQL funcionando
- [ ] pgAdmin4 accesible
- [ ] Redis funcionando
- [ ] Datos de ejemplo creados

## 🎯 Ventajas del Proyecto

### **Facilidad de Uso**
- **Instalación automática**: Docker se instala automáticamente
- **Scripts simples**: Comandos fáciles de usar
- **Documentación completa**: Guías paso a paso

### **Configuración Profesional**
- **PostgreSQL optimizado**: Configuración para desarrollo
- **pgAdmin4 configurado**: Panel de gestión listo
- **Redis incluido**: Caché y sesiones

### **Automatización**
- **Pipeline de instalación**: Docker automático
- **Scripts de gestión**: Start, stop, verify
- **Backup automático**: Datos seguros

### **Flexibilidad**
- **Múltiples entornos**: Dev, staging, prod
- **Configuración personalizable**: Variables de entorno
- **Extensiones**: PostgreSQL extendido

## 📚 Recursos Adicionales

### **Documentación Oficial**
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [pgAdmin4 Documentation](https://www.pgadmin.org/docs/)
- [Docker Documentation](https://docs.docker.com/)
- [Redis Documentation](https://redis.io/docs/)

### **Herramientas y Utilidades**
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [PostgreSQL Extensions](https://www.postgresql.org/docs/current/contrib.html)
- [pgAdmin4 Features](https://www.pgadmin.org/features/)

### **Comunidad y Soporte**
- [PostgreSQL Community](https://www.postgresql.org/community/)
- [Docker Community](https://www.docker.com/community)
- [Redis Community](https://redis.io/community)

---

**Características clave:**
- ✅ Instalación automática de Docker
- ✅ PostgreSQL 15 optimizado
- ✅ pgAdmin4 web panel
- ✅ Redis para caché
- ✅ Scripts de automatización
- ✅ Configuración profesional
- ✅ Datos de ejemplo incluidos
- ✅ Backup y restore automático
