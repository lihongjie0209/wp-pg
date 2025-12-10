# WordPress + OpenHalo (PostgreSQL) Demo

This project demonstrates how to run WordPress with OpenHalo, a MySQL wire protocol compatibility layer for PostgreSQL. This allows WordPress (which traditionally requires MySQL) to run on PostgreSQL without any code modifications.

## 🎯 Project Overview

**OpenHalo** (https://www.openhalo.org/) is a compatibility layer that enables PostgreSQL to speak the MySQL wire protocol. This means:
- WordPress connects thinking it's talking to MySQL
- OpenHalo translates MySQL queries to PostgreSQL
- You get PostgreSQL's performance and features with WordPress

## 📋 Architecture

```
WordPress (Port 8080)
    ↓
OpenHalo (Port 3306) - MySQL Protocol Layer
    ↓
PostgreSQL (Port 5432) - Actual Database
```

## 🚀 Quick Start

### Prerequisites

- Docker (version 20.10+)
- Docker Compose (version 2.0+)
- At least 4GB RAM available
- 10GB free disk space

### Installation Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/lihongjie0209/wp-pg.git
   cd wp-pg
   ```

2. **Start all services**
   ```bash
   docker-compose up -d
   ```

3. **Check service status**
   ```bash
   docker-compose ps
   ```

4. **View logs (if needed)**
   ```bash
   # All services
   docker-compose logs -f
   
   # Specific service
   docker-compose logs -f wordpress
   docker-compose logs -f openhalo
   docker-compose logs -f postgres
   ```

5. **Access WordPress**
   - Open your browser to: http://localhost:8080
   - Follow WordPress installation wizard
   - Configure your site

### Verification Steps

1. **Check PostgreSQL is running**
   ```bash
   docker-compose exec postgres psql -U wordpress -d wordpress -c "SELECT version();"
   ```

2. **Verify OpenHalo MySQL protocol**
   ```bash
   docker-compose exec openhalo mysql -h localhost -P 3306 -u wordpress -pwordpress_password -e "SHOW DATABASES;"
   ```

3. **Check WordPress connection**
   ```bash
   docker-compose exec wordpress wp db check --allow-root
   ```

## 📊 Service Details

### PostgreSQL
- **Port**: 5432
- **Database**: wordpress
- **User**: wordpress
- **Password**: wordpress_password

### OpenHalo (MySQL Protocol Layer)
- **Port**: 3306 (MySQL-compatible)
- **Function**: Translates MySQL wire protocol to PostgreSQL
- **Built from**: https://github.com/HaloTech-Co-Ltd/openHalo

### WordPress
- **Port**: 8080
- **URL**: http://localhost:8080
- **Connects to**: OpenHalo (as if it were MySQL)

## 🛠️ Useful Commands

### Start services
```bash
docker-compose up -d
```

### Stop services
```bash
docker-compose stop
```

### Stop and remove all containers
```bash
docker-compose down
```

### Remove all data (complete cleanup)
```bash
docker-compose down -v
```

### Rebuild OpenHalo image
```bash
docker-compose build openhalo
```

### Execute SQL in PostgreSQL
```bash
docker-compose exec postgres psql -U wordpress -d wordpress
```

### WordPress CLI access
```bash
docker-compose exec wordpress wp --info --allow-root
```

## 🔍 Troubleshooting

### OpenHalo build fails
If the OpenHalo build fails, you can check the build logs:
```bash
docker-compose build --no-cache openhalo
```

### WordPress can't connect to database
1. Check if OpenHalo is running:
   ```bash
   docker-compose ps openhalo
   ```

2. Check OpenHalo logs:
   ```bash
   docker-compose logs openhalo
   ```

3. Verify OpenHalo is listening on port 3306:
   ```bash
   docker-compose exec openhalo netstat -tlnp | grep 3306
   ```

### PostgreSQL connection issues
Check if PostgreSQL is healthy:
```bash
docker-compose exec postgres pg_isready -U wordpress
```

## 📝 Demo Scenarios

See [DEMO.md](./DEMO.md) for detailed demonstration scenarios and screenshots.

## 📖 Conclusion

See [CONCLUSION.md](./CONCLUSION.md) for test results, performance findings, and compatibility notes.

## 🔗 References

- [OpenHalo Official Site](https://www.openhalo.org/)
- [OpenHalo GitHub Repository](https://github.com/HaloTech-Co-Ltd/openHalo)
- [WordPress Official Documentation](https://wordpress.org/documentation/)
- [PostgreSQL Official Documentation](https://www.postgresql.org/docs/)

## 📄 License

This demo project is provided as-is for educational and testing purposes.

## 🤝 Contributing

Feel free to open issues or submit pull requests for improvements to this demo setup.