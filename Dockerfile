FROM eclipse-temurin:8-jre

WORKDIR /app

COPY target/Snowman.jar /app/Snowman.jar

EXPOSE 8050

ENTRYPOINT ["java", "-jar", "/app/Snowman.jar", "--server.port=8050"]
