FROM eclipse-temurin:17-jre

WORKDIR /app

COPY target/Snowman.jar app.jar

EXPOSE 8087

ENTRYPOINT ["java", "-Dport=8087", "-jar", "app.jar"]
