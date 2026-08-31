# Dockerfile for SIMATS Skill Progress Analytics Web Application
FROM eclipse-temurin:21-jdk-alpine AS builder

WORKDIR /app
COPY src ./src
COPY web ./web
COPY schema.sql ./

# Compile Java sources
RUN mkdir bin && javac -d bin -sourcepath src \
    src/com/simats/analytics/model/*.java \
    src/com/simats/analytics/dao/*.java \
    src/com/simats/analytics/service/*.java \
    src/com/simats/analytics/server/*.java \
    src/com/simats/analytics/test/*.java

# Runtime container
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app
COPY --from=builder /app/bin ./bin
COPY --from=builder /app/web ./web
COPY --from=builder /app/schema.sql ./

EXPOSE 8080
ENV PORT=8080

CMD ["java", "-cp", "bin", "com.simats.analytics.server.AppServer", "8080"]
