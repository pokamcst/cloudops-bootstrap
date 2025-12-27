# Kustomer Java Application

Professional Spring Boot application for the Kustomer platform with containerized deployment support.

## Overview

This is a Spring Boot 3.2 application running on Java 17 with the following features:

- **REST API** with health check endpoints
- **Actuator** for monitoring and metrics
- **JaCoCo** for code coverage reporting
- **Docker** multi-stage build for efficient containerization
- **Automated CI/CD** via GitHub Actions

## Structure

```
java-app/
├── src/
│   ├── main/
│   │   ├── java/com/kustomer/
│   │   │   ├── KustomerApplication.java        # Spring Boot entry point
│   │   │   └── controller/
│   │   │       └── HealthController.java       # Health & API endpoints
│   │   └── resources/
│   │       └── application.properties          # Configuration
│   └── test/
│       └── java/com/kustomer/
│           ├── KustomerApplicationTests.java
│           └── controller/
│               └── HealthControllerTest.java
├── pom.xml                                      # Maven configuration
├── Dockerfile                                   # Multi-stage build
└── README.md                                    # This file
```

## Prerequisites

- Java 17 or higher
- Maven 3.9+
- Docker (for containerization)
- Docker Buildx (for multi-platform builds)

## Local Development

### Build

```bash
cd java-app
mvn clean package
```

### Run

```bash
java -jar target/java-app-1.0.0.jar
```

Application will start on `http://localhost:8080`

### Testing

```bash
# Run all tests
mvn test

# Generate JaCoCo coverage report
mvn jacoco:report

# Coverage report location: target/site/jacoco/index.html
```

### Development Mode

```bash
mvn spring-boot:run
```

## API Endpoints

### Health Check

```bash
GET http://localhost:8080/api/health

Response:
{
  "status": "UP",
  "message": "Kustomer application is healthy"
}
```

### Spring Boot Actuator

```bash
# Health endpoint
GET http://localhost:8080/actuator/health

# Application info
GET http://localhost:8080/actuator/info

# Metrics
GET http://localhost:8080/actuator/metrics
```

## Docker Build and Run

### Build Docker Image

```bash
docker build -t kustomer-java-app:latest .
```

### Run Docker Container

```bash
docker run -d \
  --name kustomer-java-app \
  -p 8080:8080 \
  -e JAVA_OPTS="-XX:MaxRAMPercentage=75.0" \
  kustomer-java-app:latest
```

### Multi-Platform Build

```bash
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t <registry>/kustomer-java-app:latest \
  --push \
  .
```

## CI/CD Pipeline

The application has automated CI/CD through GitHub Actions (`java-apps-deploy.yml`):

### Pipeline Stages

1. **Build & Test** (runs on push/PR to main/develop)
   - Checkout code
   - Setup JDK 17
   - Build with Maven
   - Run unit tests
   - Generate JaCoCo coverage report
   - Upload test results and JAR artifact

2. **Build Docker Image** (runs after build-and-test succeeds on main/develop)
   - Download JAR artifact
   - Login to Azure Container Registry
   - Build and push Docker image with git SHA tag
   - Cache layers for faster subsequent builds

3. **Deploy** (runs after Docker build on main/develop)
   - Deploy to Azure Web App for Containers
   - Run health checks post-deployment

### Triggers

The pipeline automatically triggers when:
- **Java code changes**: Push to `main` or `develop` branches
- **Dockerfile changes**: Push to `java-app/Dockerfile`
- **Manual trigger**: Use `workflow_dispatch` in GitHub UI

### Environment Variables

Configure these GitHub secrets for deployment:

- `JAVA_WEBAPP_NAME` - Azure Web App name
- `AZURE_ACR_NAME` - Azure Container Registry name
- `AZURE_CREDENTIALS` - Azure service principal (JSON format)

## Configuration

### Application Properties

Edit `src/main/resources/application.properties`:

```properties
# Server port
server.port=8080

# Application info
spring.application.name=kustomer-java-app
application.version=1.0.0

# Logging levels
logging.level.root=INFO
logging.level.com.kustomer=DEBUG

# Actuator endpoints
management.endpoints.web.exposure.include=health,info,metrics
```

### Environment-Specific Configuration

Create additional property files:

- `application-dev.properties` - Development
- `application-staging.properties` - Staging
- `application-prod.properties` - Production

Run with profile:
```bash
java -jar app.jar --spring.profiles.active=prod
```

## Monitoring

### Health Checks

The application includes:

- **Liveness Probe**: `/actuator/health/liveness` - Is the app running?
- **Readiness Probe**: `/actuator/health/readiness` - Is the app ready for traffic?
- **Docker HEALTHCHECK**: Checks `/actuator/health` every 30 seconds

### Kubernetes Deployment

```yaml
livenessProbe:
  httpGet:
    path: /actuator/health/liveness
    port: 8080
  initialDelaySeconds: 30
  periodSeconds: 10

readinessProbe:
  httpGet:
    path: /actuator/health/readiness
    port: 8080
  initialDelaySeconds: 5
  periodSeconds: 5
```

## Troubleshooting

### Build Fails

```bash
# Clear Maven cache
mvn clean

# Rebuild
mvn clean package
```

### Docker Build Issues

```bash
# Check Docker daemon is running
docker ps

# View build logs
docker build -t kustomer-java-app:latest . --progress=plain

# Clear Docker cache if needed
docker system prune -a
```

### Application Won't Start

Check logs:
```bash
# Local
java -jar target/java-app-1.0.0.jar --debug

# Docker
docker logs kustomer-java-app

# Kubernetes
kubectl logs -f deployment/kustomer-java-app
```

## Performance Tuning

### JVM Options

```bash
# Optimize for containers
java -XX:+UseContainerSupport \
     -XX:MaxRAMPercentage=75.0 \
     -XX:+UnlockDiagnosticVMOptions \
     -XX:+DebugNonSafepoints \
     -jar app.jar
```

### Database Connection Pooling

Configure HikariCP in `application.properties`:

```properties
spring.datasource.hikari.maximum-pool-size=20
spring.datasource.hikari.minimum-idle=5
spring.datasource.hikari.connection-timeout=20000
```

## Security

### Vulnerabilities

Scan for security vulnerabilities:

```bash
# OWASP Dependency Check
mvn org.owasp:dependency-check-maven:check

# Trivy Docker image scan
trivy image kustomer-java-app:latest
```

### HTTPS

Enable HTTPS in production:

```properties
server.ssl.enabled=true
server.ssl.key-store=classpath:keystore.p12
server.ssl.key-store-password=${SSL_KEYSTORE_PASSWORD}
server.ssl.key-store-type=PKCS12
```

## Contributing

1. Create feature branch: `git checkout -b feature/add-feature`
2. Make changes and commit: `git commit -am 'Add feature'`
3. Push branch: `git push origin feature/add-feature`
4. Create Pull Request

Pipeline will automatically run tests and build Docker image.

## License

Proprietary - Kustomer Platform

---

**Last Updated**: 2024-12-27
**Version**: 1.0.0
