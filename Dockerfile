FROM openjdk:21
ADD target/springboot-github-action.jar springboot-github-action.jar
EXPOSE 8080
ENTRYPOINT ["java","-jar","springboot-github-action.jar"]