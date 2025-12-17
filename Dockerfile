# Use an OpenJDK base image
FROM openjdk:17


# Set working directory
WORKDIR /app

# Copy the WAR file
COPY target/TrainBook-1.0.0-SNAPSHOT.war app.war

# Expose the default Tomcat port
EXPOSE 8080

# Run the WAR using webapp-runner
COPY target/dependency/webapp-runner.jar /app/webapp-runner.jar
ENTRYPOINT ["java","-jar","/app/webapp-runner.jar","--port","8080","/app/app.war"]
