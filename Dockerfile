FROM openjdk:21
EXPOSE 8080
ADD target/springboot-github-action.jar springboot-github-action.jar
ENTRYPOINT ["java","-jar","/springboot-github-action.jar"]