FROM openjdk:17
EXPOSE 8080
ADD target/springboot-github-action.jar springboot-github-action.jar
ENTRYPOINT ["java","-jar","/springboot-github-action.jar"]

# FROM openjdk:17
# ARG JAR_FILE=target/*.jar
# COPY ${JAR_FILE} springboot-github-action.jar
# ENTRYPOINT ["java", "-jar", "/springboot-github-action.jar"]
# EXPOSE 8080




