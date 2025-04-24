# Etapa 1: Construcción
FROM maven:3.9.8-eclipse-temurin-17-alpine AS build
WORKDIR /app

# Copia los archivos de configuración de Maven y las dependencias
COPY pom.xml .
COPY src ./src
COPY .ssh ./.ssh

# Agrega la clave SSH para acceder al repositorio privado
RUN apk add --no-cache openssh-client && ssh-keyscan ssh.dev.azure.com >| .ssh/known_hosts

# Construye el proyecto
RUN mvn clean package -DskipTests

# Etapa 2: Ejecución
FROM eclipse-temurin:17-jdk-alpine
WORKDIR /app

# Copia el archivo JAR desde la etapa de construcción
COPY --from=build /app/target/*.jar app.jar
COPY --from=build /app/.ssh /root/.ssh

ENV GIT_URI=git@ssh.dev.azure.com:v3/Noatum/PORTOS%20TOS/aks-cloud-configurations
ENV PRIVATEKEY=/root/.ssh/id_rsa/id_rsa

# Expone el puerto en el que se ejecutará la aplicación
EXPOSE 8888

# Define el comando para ejecutar la aplicación
ENTRYPOINT ["java", "-jar", "app.jar"]
