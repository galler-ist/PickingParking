FROM openjdk:21-jdk-slim


ENV APP_HOME=/usr/app/
WORKDIR $APP_HOME


COPY build/libs/*.jar app.jar


EXPOSE 8080


ENTRYPOINT ["java", "-jar", "app.jar"]