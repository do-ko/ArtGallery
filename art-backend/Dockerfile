FROM maven:3.8.7-eclipse-temurin-17 AS build
ARG COGNITO_USER_POOL_ID
WORKDIR /art-backend
COPY pom.xml .
COPY src ./src
RUN sed -i "s/userpoolid/$COGNITO_USER_POOL_ID/g" ./src/main/resources/application.properties

RUN mvn clean package -DskipTests


FROM eclipse-temurin:17
ENV JAVA_OPTS="-XX:+UseG1GC -XX:MaxRAMPercentage=75"
WORKDIR /art-backend
COPY --from=build /art-backend/target/art-backend-0.0.1-SNAPSHOT.jar .
EXPOSE 8080
ENTRYPOINT ["sh","-c","java $JAVA_OPTS -jar art-backend-0.0.1-SNAPSHOT.jar"]