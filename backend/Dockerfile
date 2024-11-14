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

# JAR 파일 경로 변수 설정
ARG JAR_FILE=build/libs/PickingParking-0.0.1-SNAPSHOT.jar

# .env 파일을 이미지에 복사
COPY .env /app/.env

# JAR 파일을 컨테이너에 복사
COPY ${JAR_FILE} /app.jar

# 애플리케이션 실행
ENTRYPOINT ["java", "-jar", "/app.jar"]