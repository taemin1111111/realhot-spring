# ===== Multi-stage build for production optimization =====

# Build stage
FROM openjdk:21-jdk-slim AS builder

WORKDIR /app

# Copy Maven wrapper and pom.xml first (for better layer caching)
COPY mvnw .
COPY .mvn .mvn
COPY pom.xml .

# Make mvnw executable
RUN chmod +x ./mvnw

# Download dependencies (cached layer)
RUN ./mvnw dependency:go-offline -B

# Copy source code
COPY src ./src

# Build application (skip tests for faster build)
RUN ./mvnw clean package -DskipTests -B

# Runtime stage
FROM openjdk:21-jre-slim AS runtime

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN groupadd -r spring && useradd -r -g spring spring

# Set working directory
WORKDIR /app

# Copy built application from builder stage
COPY --from=builder /app/target/*.jar app.jar

# Create logs directory
RUN mkdir -p logs && chown -R spring:spring /app

# Switch to non-root user
USER spring

# JVM optimization for production
ENV JAVA_OPTS="-Xms512m -Xmx2g -XX:+UseG1GC -XX:G1HeapRegionSize=16m -XX:+UseStringDeduplication -XX:+OptimizeStringConcat -Djava.security.egd=file:/dev/./urandom -Dspring.profiles.active=prod"

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8083/hotplace/actuator/health || exit 1

# Expose port
EXPOSE 8083

# Run application
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
