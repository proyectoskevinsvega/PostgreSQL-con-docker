# 🚀 Node.js Express Example - PostgreSQL

Este es un ejemplo completo de aplicación Node.js con Express que se conecta a PostgreSQL usando Docker.

## 🎯 Características

- **Express.js**: Framework web para Node.js
- **PostgreSQL**: Base de datos relacional
- **JWT**: Autenticación con tokens
- **Helmet**: Seguridad HTTP
- **CORS**: Cross-Origin Resource Sharing
- **Morgan**: Logging de requests
- **Joi**: Validación de datos
- **bcryptjs**: Encriptación de contraseñas

## 🏗️ Arquitectura

```
┌─────────────────────────────────────────────────────────────┐
│                    Node.js Express App                      │
│  ┌─────────────────┐  ┌─────────────────┐                  │
│  │   Express       │  │   PostgreSQL    │                  │
│  │   Server        │  │   Database      │                  │
│  │   Port: 3000    │  │   Port: 5432    │                  │
│  └─────────────────┘  └─────────────────┘                  │
│           │                     │                           │
│  ┌────────▼─────────┐  ┌────────▼─────────┐                │
│  │   API Routes     │  │   Database       │                │
│  │   /api/users     │  │   Connection     │                │
│  │   /api/products  │  │   Pool           │                │
│  │   /api/orders    │  │   Queries        │                │
│  └──────────────────┘  └──────────────────┘                │
└─────────────────────────────────────────────────────────────┘
```

## 📁 Estructura del Proyecto

```
nodejs-express/
├── config/                 # Configuración
│   ├── database.js         # Configuración PostgreSQL
│   └── redis.js            # Configuración Redis
├── routes/                 # Rutas de la API
│   ├── users.js            # Rutas de usuarios
│   ├── products.js         # Rutas de productos
│   └── orders.js           # Rutas de órdenes
├── middleware/             # Middleware personalizado
│   └── errorHandler.js     # Manejo de errores
├── models/                 # Modelos de datos
├── utils/                  # Utilidades
├── server.js               # Servidor principal
├── package.json            # Dependencias
├── env.example             # Variables de entorno
└── README.md               # Este archivo
```

## 🚀 Inicio Rápido

### 1. **Instalar Dependencias**
```bash
npm install
```

### 2. **Configurar Variables de Entorno**
```bash
cp env.example .env
nano .env
```

### 3. **Iniciar PostgreSQL + Redis**
```bash
# Desde el directorio raíz del proyecto
make start
```

### 4. **Iniciar la Aplicación**
```bash
# Modo desarrollo
npm run dev

# Modo producción
npm start
```

### 5. **Verificar Funcionamiento**
```bash
# Health check
curl http://localhost:3000/health

# API info
curl http://localhost:3000/
```

## 🛠️ Comandos Disponibles

### **Desarrollo**
```bash
npm run dev          # Modo desarrollo con nodemon
npm start            # Modo producción
npm test             # Ejecutar tests
npm run lint         # Linter
npm run format       # Formatear código
```

### **Base de Datos**
```bash
# Conectar a PostgreSQL
make db-connect

# Ver datos de ejemplo
make db-connect
# \dt
# SELECT * FROM users;
```

### **Redis**
```bash
# Conectar a Redis
make redis-connect

# Ver claves
KEYS *
```

## 🔧 Configuración

### **Variables de Entorno**
```bash
# Server
PORT=3000
NODE_ENV=development

# Database
DB_HOST=localhost
DB_PORT=5432
DB_NAME=development
DB_USER=postgres
DB_PASSWORD=postgres123

# Redis
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=redis123

# JWT
JWT_SECRET=your-super-secret-jwt-key
JWT_EXPIRES_IN=24h
```

### **PostgreSQL**
- **Host**: localhost
- **Puerto**: 5432
- **Base de datos**: development
- **Usuario**: postgres
- **Contraseña**: postgres123

### **Redis**
- **Host**: localhost
- **Puerto**: 6379
- **Contraseña**: redis123

## 📊 API Endpoints

### **Health Check**
```http
GET /health
```

### **API Info**
```http
GET /
```

### **Usuarios**
```http
GET    /api/users          # Listar usuarios
POST   /api/users          # Crear usuario
GET    /api/users/:id      # Obtener usuario
PUT    /api/users/:id      # Actualizar usuario
DELETE /api/users/:id      # Eliminar usuario
```

### **Productos**
```http
GET    /api/products       # Listar productos
POST   /api/products       # Crear producto
GET    /api/products/:id   # Obtener producto
PUT    /api/products/:id   # Actualizar producto
DELETE /api/products/:id   # Eliminar producto
```

### **Órdenes**
```http
GET    /api/orders         # Listar órdenes
POST   /api/orders          # Crear orden
GET    /api/orders/:id      # Obtener orden
PUT    /api/orders/:id      # Actualizar orden
DELETE /api/orders/:id      # Eliminar orden
```

## 🔒 Seguridad

### **Middleware de Seguridad**
- **Helmet**: Headers de seguridad HTTP
- **CORS**: Configuración de origen cruzado
- **Rate Limiting**: Límite de requests
- **JWT**: Autenticación con tokens

### **Validación**
- **Joi**: Validación de esquemas
- **Sanitización**: Limpieza de datos
- **Escape**: Prevención de inyección

### **Encriptación**
- **bcryptjs**: Hash de contraseñas
- **JWT**: Tokens seguros
- **HTTPS**: Encriptación en tránsito

## 📈 Performance

### **Conexión a Base de Datos**
- **Pool de conexiones**: Máximo 20 conexiones
- **Timeout**: 2 segundos para conexión
- **Idle timeout**: 30 segundos

### **Caché con Redis**
- **TTL**: 1 hora por defecto
- **Estrategia**: Cache-aside
- **Invalidación**: Automática por TTL

### **Optimizaciones**
- **Compresión**: Gzip habilitado
- **Keep-alive**: Conexiones persistentes
- **Caching**: Headers de caché

## 🧪 Testing

### **Ejecutar Tests**
```bash
npm test
```

### **Tests Disponibles**
- **Unit tests**: Funciones individuales
- **Integration tests**: API endpoints
- **Database tests**: Consultas PostgreSQL
- **Redis tests**: Operaciones de caché

### **Coverage**
```bash
npm run test:coverage
```

## 🚨 Troubleshooting

### **Problemas Comunes**

#### **No se puede conectar a PostgreSQL**
```bash
# Verificar que PostgreSQL esté funcionando
make status

# Verificar puerto
netstat -tuln | grep 5432
```

#### **No se puede conectar a Redis**
```bash
# Verificar que Redis esté funcionando
make status

# Verificar puerto
netstat -tuln | grep 6379
```

#### **Error de permisos**
```bash
# Verificar variables de entorno
cat .env

# Verificar configuración de base de datos
```

### **Comandos de Diagnóstico**
```bash
# Ver logs de la aplicación
npm run dev

# Ver logs de PostgreSQL
docker logs postgresql-db

# Ver logs de Redis
docker logs postgresql-redis
```

## 📚 Casos de Uso

### **Desarrollo Local**
```bash
# Iniciar entorno completo
make start

# Iniciar aplicación
npm run dev

# Abrir pgAdmin4
make pgadmin-open
```

### **Testing**
```bash
# Iniciar servicios
make start

# Ejecutar tests
npm test

# Parar servicios
make stop
```

### **Producción**
```bash
# Iniciar en producción
NODE_ENV=production npm start

# Con monitoreo
pm2 start server.js --name "postgresql-api"
```

## 🔄 Backup y Restore

### **Backup de Base de Datos**
```bash
# Backup automático
make backup

# Backup manual
docker exec postgresql-db pg_dump -U postgres development > backup.sql
```

### **Restore de Base de Datos**
```bash
# Restore automático
make restore FILE=backup.sql

# Restore manual
docker exec -i postgresql-db psql -U postgres development < backup.sql
```

## 📋 Checklist de Implementación

### **Pre-requisitos**
- [ ] Node.js 18+ instalado
- [ ] PostgreSQL funcionando
- [ ] Redis funcionando
- [ ] Variables de entorno configuradas

### **Instalación**
- [ ] Dependencias instaladas
- [ ] Variables de entorno configuradas
- [ ] Base de datos conectada
- [ ] Redis conectado

### **Verificación**
- [ ] Servidor iniciado
- [ ] Health check funcionando
- [ ] API endpoints respondiendo
- [ ] Base de datos accesible
- [ ] Redis funcionando

## 🎯 Ventajas del Ejemplo

### **Completo**
- **API REST**: Endpoints completos
- **Base de datos**: PostgreSQL integrado
- **Caché**: Redis para performance
- **Seguridad**: Middleware de seguridad

### **Profesional**
- **Código limpio**: Estructura organizada
- **Documentación**: Comentarios y README
- **Testing**: Tests incluidos
- **Configuración**: Variables de entorno

### **Escalable**
- **Pool de conexiones**: Base de datos optimizada
- **Caché**: Redis para performance
- **Middleware**: Extensible
- **Modular**: Código organizado

## 📚 Recursos Adicionales

### **Documentación Oficial**
- [Express.js Documentation](https://expressjs.com/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Redis Documentation](https://redis.io/docs/)
- [Node.js Documentation](https://nodejs.org/docs/)

### **Herramientas y Utilidades**
- [Joi Validation](https://joi.dev/)
- [bcryptjs](https://www.npmjs.com/package/bcryptjs)
- [jsonwebtoken](https://www.npmjs.com/package/jsonwebtoken)
- [Helmet Security](https://helmetjs.github.io/)

### **Comunidad y Soporte**
- [Node.js Community](https://nodejs.org/community/)
- [Express.js Community](https://expressjs.com/en/resources/community.html)
- [PostgreSQL Community](https://www.postgresql.org/community/)

---

**¡El ejemplo de Node.js Express está listo para conectarse a PostgreSQL y Redis!** 🚀

**Características clave:**
- ✅ API REST completa
- ✅ Conexión a PostgreSQL
- ✅ Caché con Redis
- ✅ Autenticación JWT
- ✅ Seguridad HTTP
- ✅ Testing incluido
- ✅ Documentación completa
