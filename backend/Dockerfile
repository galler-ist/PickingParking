FROM openjdk:21-jdk-slim

ENV APP_HOME=/usr/app/
WORKDIR $APP_HOME

# .jar 파일이 하나만 있을 경우, 단일 파일을 복사
COPY build/libs/*.jar /usr/app/

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]