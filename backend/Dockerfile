FROM openjdk:21-jdk-slim

# 앱 디렉토리 생성
RUN mkdir -p /usr/app

ENV APP_HOME=/usr/app/
WORKDIR $APP_HOME

# .jar 파일을 /usr/app/ 디렉토리로 복사
COPY build/libs/*.jar /usr/app/

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "/usr/app/*.jar"]