# FROM openjdk:21-jdk-slim

# # 앱 디렉토리 생성
# RUN mkdir -p /app

# ENV APP_HOME=/app/
# WORKDIR $APP_HOME

# # .jar 파일을 /usr/app/ 디렉토리로 복사
# COPY build/libs/*.jar app.jar
# EXPOSE 8080

# ENTRYPOINT ["java", "-jar", "/usr/app/PickingParking-0.0.1-SNAPSHOT.jar"]
FROM openjdk:21-jdk-slim

ARG JAR_FILE=build/libs/PickingParking-0.0.1-SNAPSHOT.jar

COPY ${JAR_FILE} /app.jar

ENTRYPOINT ["java", "-jar", "/app.jar"]