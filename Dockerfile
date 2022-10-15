# ===[ STAGE 1 ]===
# =================

# Start with a base image containing Java runtime
FROM openjdk:11-slim as build

# Add maintainer info
LABEL maintainer="Frota Silveira <frota.gm@gmail.com>"

# The application's jar file
ARG JAR_FILE

# Add the application's jar to the container
COPY ${JAR_FILE} app.jar

# Unpackage jar file
RUN mkdir -p target/dependency && (cd target/dependency; jar -xf /app.jar)

# ===[ STAGE 2 ]===
# =================

# Same Java runtime
FROM openjdk:11-slim

# Add volume pointing to /tmp
VOLUME /tmp

# Copy unpackaged application to new container
ARG DEPENDENCY=/target/dependency
COPY --from=build ${DEPENDENCY}/BOOT-INF/lib /app/lib
COPY --from=build ${DEPENDENCY}/META-INF /app/META-INF
COPY --from=build ${DEPENDENCY}/BOOT-INF/classes /app

# Execute the application
ENTRYPOINT ["java", "-cp", "app:app/lib/*", "com.optimagrowth.configserver.ConfigurationServerApplication"]
