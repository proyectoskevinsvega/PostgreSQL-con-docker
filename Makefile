# PostgreSQL Docker - Makefile
# Comandos para gestionar PostgreSQL + pgAdmin4 con Docker

.PHONY: help install start stop restart status logs clean build verify

# Variables por defecto
COMPOSE_CMD := $(shell command -v docker-compose >/dev/null 2>&1 && echo "docker-compose" || echo "docker compose")
ENVIRONMENT := development

help:
	@echo "🐳 PostgreSQL Docker - Comandos Disponibles"
	@echo "============================================="
	@echo "make install        - Instalar Docker automáticamente"
	@echo "make start          - Iniciar PostgreSQL + pgAdmin4"
	@echo "make start-monitoring - Iniciar con Prometheus + Grafana"
	@echo "make start-replication - Iniciar con replicación"
	@echo "make start-full     - Iniciar todo (PostgreSQL + Replica + Monitoreo)"
	@echo "make stop           - Parar servicios"
	@echo "make restart        - Reiniciar servicios"
	@echo "make status         - Ver estado de servicios"
	@echo "make logs           - Ver logs de servicios"
	@echo "make build          - Construir imágenes"
	@echo "make verify         - Verificar funcionamiento"
	@echo "make clean          - Limpiar recursos"
	@echo "make clean-all      - Limpiar todo (volúmenes + imágenes)"
	@echo ""
	@echo "Variables:"
	@echo "  ENVIRONMENT=development|staging|production"
	@echo "  COMPOSE_CMD=docker-compose|docker compose"
	@echo "  PROMETHEUS_ENABLED=true|false"
	@echo "  GRAFANA_ENABLED=true|false"
	@echo "  REPLICATION_ENABLED=true|false"

# Instalar Docker
install:
	@echo "🔧 Instalando Docker..."
	@./pipeline/install-docker.sh

# Iniciar servicios básicos
start:
	@echo "🚀 Iniciando PostgreSQL + pgAdmin4..."
	@./scripts/start.sh

# Iniciar con monitoreo
start-monitoring:
	@echo "📊 Iniciando PostgreSQL + pgAdmin4 + Prometheus + Grafana..."
	@./scripts/start-with-monitoring.sh

# Iniciar con replicación
start-replication:
	@echo "🔄 Iniciando PostgreSQL con replicación..."
	@./scripts/start-with-replication.sh

# Iniciar todo (básico + replicación + monitoreo)
start-full:
	@echo "🚀 Iniciando todo (PostgreSQL + Replica + Monitoreo)..."
	@./scripts/start-with-replication.sh

# Parar servicios
stop:
	@echo "🛑 Parando servicios..."
	@./scripts/stop.sh

# Reiniciar servicios
restart: stop start
	@echo "🔄 Servicios reiniciados"

# Ver estado
status:
	@echo "📊 Estado de servicios:"
	@$(COMPOSE_CMD) ps

# Ver logs
logs:
	@echo "📋 Logs de servicios:"
	@$(COMPOSE_CMD) logs -f

# Construir imágenes
build:
	@echo "🔨 Construyendo imágenes..."
	@./scripts/start.sh --build

# Verificar funcionamiento
verify:
	@echo "🔍 Verificando funcionamiento..."
	@./scripts/verify.sh

# Limpiar recursos
clean:
	@echo "🧹 Limpiando recursos..."
	@./scripts/stop.sh --images

# Limpiar todo
clean-all:
	@echo "🧹 Limpiando todo (volúmenes + imágenes)..."
	@./scripts/stop.sh --all

# Comandos de desarrollo
dev-start: start
	@echo "🔧 Modo desarrollo iniciado"
	@echo "PostgreSQL: localhost:5432"
	@echo "pgAdmin4: http://localhost:8080"

dev-stop: stop
	@echo "🔧 Modo desarrollo parado"

dev-restart: restart
	@echo "🔧 Modo desarrollo reiniciado"

# Comandos de producción
prod-start: 
	@echo "🚀 Iniciando en modo producción..."
	@ENVIRONMENT=production ./scripts/start.sh

prod-stop:
	@echo "🛑 Parando modo producción..."
	@./scripts/stop.sh

# Comandos de testing
test-start:
	@echo "🧪 Iniciando para testing..."
	@ENVIRONMENT=testing ./scripts/start.sh

test-stop:
	@echo "🛑 Parando testing..."
	@./scripts/stop.sh

# Comandos de monitoreo
monitor:
	@echo "📊 Monitoreando servicios..."
	@watch -n 5 '$(COMPOSE_CMD) ps'

# Comandos de backup
backup:
	@echo "💾 Creando backup de PostgreSQL..."
	@docker exec postgresql-db pg_dumpall -U postgres > backup_$(shell date +%Y%m%d_%H%M%S).sql
	@echo "Backup creado: backup_$(shell date +%Y%m%d_%H%M%S).sql"

# Comandos de restore
restore:
	@echo "🔄 Restaurando backup..."
	@if [ -z "$(FILE)" ]; then echo "Usa: make restore FILE=backup.sql"; exit 1; fi
	@docker exec -i postgresql-db psql -U postgres < $(FILE)
	@echo "Backup restaurado: $(FILE)"

# Comandos de base de datos
db-connect:
	@echo "🔌 Conectando a PostgreSQL..."
	@docker exec -it postgresql-db psql -U postgres

db-shell:
	@echo "🐚 Abriendo shell de PostgreSQL..."
	@docker exec -it postgresql-db bash

# Comandos de pgAdmin
pgadmin-open:
	@echo "🌐 Abriendo pgAdmin4..."
	@echo "URL: http://localhost:8080"
	@echo "Email: admin@postgresql.local"
	@echo "Contraseña: admin123"

# Comandos de monitoreo
monitoring-start:
	@echo "📊 Iniciando servicios de monitoreo..."
	@$(COMPOSE_CMD) --profile monitoring up -d

monitoring-stop:
	@echo "📊 Parando servicios de monitoreo..."
	@$(COMPOSE_CMD) --profile monitoring down

monitoring-status:
	@echo "📊 Estado de servicios de monitoreo:"
	@$(COMPOSE_CMD) --profile monitoring ps

monitoring-logs:
	@echo "📊 Logs de servicios de monitoreo:"
	@$(COMPOSE_CMD) --profile monitoring logs -f

# Comandos de Prometheus
prometheus-open:
	@echo "📈 Abriendo Prometheus..."
	@echo "URL: http://localhost:9090"
	@echo "Métricas: http://localhost:9090/metrics"

prometheus-targets:
	@echo "📈 Verificando targets de Prometheus..."
	@curl -s http://localhost:9090/api/v1/targets | jq '.data.activeTargets[] | {job: .labels.job, health: .health, lastScrape: .lastScrape}'

# Comandos de Grafana
grafana-open:
	@echo "📊 Abriendo Grafana..."
	@echo "URL: http://localhost:3000"
	@echo "Usuario: admin"
	@echo "Contraseña: admin123"

grafana-dashboards:
	@echo "📊 Listando dashboards de Grafana..."
	@curl -s -u admin:admin123 http://localhost:3000/api/search?type=dash-db | jq '.[] | {title: .title, url: .url}'

# Comandos de replicación
replication-start:
	@echo "🔄 Iniciando servicios de replicación..."
	@$(COMPOSE_CMD) --profile replication up -d

replication-stop:
	@echo "🔄 Parando servicios de replicación..."
	@$(COMPOSE_CMD) --profile replication down

replication-status:
	@echo "🔄 Estado de servicios de replicación:"
	@$(COMPOSE_CMD) --profile replication ps

replication-logs:
	@echo "🔄 Logs de servicios de replicación:"
	@$(COMPOSE_CMD) --profile replication logs -f

# Comandos de PostgreSQL Replica
postgresql-replica-connect:
	@echo "🔌 Conectando a PostgreSQL Replica..."
	@docker exec -it postgresql-replica psql -U postgres

postgresql-replica-status:
	@echo "🔄 Estado de replicación:"
	@docker exec postgresql-replica psql -U postgres -c "SELECT * FROM pg_stat_replication;"

postgresql-replica-lag:
	@echo "⏱️ Lag de replicación:"
	@docker exec postgresql-replica psql -U postgres -c "SELECT EXTRACT(EPOCH FROM (now() - pg_last_xact_replay_timestamp())) AS replication_lag;"


# Comandos de red
network-ls:
	@echo "🌐 Listando redes Docker..."
	@docker network ls

network-inspect:
	@echo "🔍 Inspeccionando red postgresql_network..."
	@docker network inspect postgresql_network

# Comandos de volúmenes
volume-ls:
	@echo "💾 Listando volúmenes Docker..."
	@docker volume ls

volume-inspect:
	@echo "🔍 Inspeccionando volúmenes..."
	@docker volume inspect postgresql_data pgadmin_data

# Comandos de imágenes
image-ls:
	@echo "🖼️ Listando imágenes Docker..."
	@docker images | grep -E "(postgresql|pgadmin)"

# Comandos de contenedores
container-ls:
	@echo "📦 Listando contenedores..."
	@docker ps -a | grep -E "(postgresql|pgadmin)"

# Comandos de sistema
system-info:
	@echo "ℹ️ Información del sistema:"
	@echo "Docker version: $(shell docker --version)"
	@echo "Docker Compose version: $(shell $(COMPOSE_CMD) --version)"
	@echo "OS: $(shell uname -s)"
	@echo "Architecture: $(shell uname -m)"

# Comandos de ayuda
help-docker:
	@echo "🐳 Comandos Docker útiles:"
	@echo "  docker ps                    - Ver contenedores activos"
	@echo "  docker logs <container>     - Ver logs de contenedor"
	@echo "  docker exec -it <container> bash - Abrir shell en contenedor"
	@echo "  docker stats                 - Ver estadísticas de contenedores"

help-postgresql:
	@echo "🐘 Comandos PostgreSQL útiles:"
	@echo "  make db-connect              - Conectar a PostgreSQL"
	@echo "  make db-shell                - Shell de PostgreSQL"
	@echo "  make backup                   - Crear backup"
	@echo "  make restore FILE=backup.sql - Restaurar backup"

help-pgadmin:
	@echo "🌐 Comandos pgAdmin4 útiles:"
	@echo "  make pgadmin-open            - Abrir pgAdmin4"
	@echo "  URL: http://localhost:8080"
	@echo "  Email: admin@postgresql.local"
	@echo "  Contraseña: admin123"

# Comando por defecto
.DEFAULT_GOAL := help
