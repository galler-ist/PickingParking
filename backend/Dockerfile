FROM openjdk:21-jdk-slim

# 작업 디렉토리 설정
WORKDIR /usr/app

# JAR 파일 경로 설정
ARG JAR_PATH=./build/libs

# JAR 파일을 /usr/app/ 디렉토리로 복사
COPY ${JAR_PATH}/*.jar /usr/app/

EXPOSE 8080

# JAR 파일 실행
ENTRYPOINT ["java", "-jar", "/usr/app/*.jar"]