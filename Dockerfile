FROM amazoncorretto:21
ARG JAR_FILE=target/*.jar
COPY ${JAR_FILE} springboot-github-action.jar
ENTRYPOINT ["java", "-jar", "/springboot-github-action.jar"]