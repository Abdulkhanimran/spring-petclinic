FROM maven:3.9-eclipse-temurin-17 AS build

WORKDIR /app

COPY pom.xml .

RUN mvn -B dependency:go-offline

COPY src ./src

RUN mvn -B package -DskipTests

FROM eclipse-temurin:17-jre

WORKDIR /app

RUN groupadd -r app && useradd -r -g app app

COPY --chown=app:app --from=build /app/target/*.jar app.jar

USER app

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=3s --start-period=60s --retries=3 CMD curl -fs http://localhost:8080/actuator/health || exit 1

ENTRYPOINT [ "java", "-jar", "app.jar" ]