FROM openjdk:21-jdk-slim

ENV APP_HOME=/usr/app/
WORKDIR $APP_HOME

# .jar 파일을 /usr/app/ 디렉토리로 복사
COPY build/libs/*.jar /usr/app/app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]
