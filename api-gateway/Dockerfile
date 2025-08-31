# =================================================================
# STAGE 1: Build application
# =================================================================
FROM maven:3.9-eclipse-temurin-21 AS build

WORKDIR /app

# Copy TOÀN BỘ mã nguồn vào ngay từ đầu.
# Điều này cung cấp đầy đủ ngữ cảnh về project cha và tất cả các module con cho Maven.
COPY . .

# Build toàn bộ project bằng lệnh "install".
# Lệnh này sẽ build và cài đặt tất cả các module, giải quyết mọi phụ thuộc nội bộ.
RUN mvn clean install -DskipTests

# =================================================================
# STAGE 2: Run application
# =================================================================
FROM eclipse-temurin:21-jre-jammy

WORKDIR /app

# Copy file .jar đã được build của api-gateway từ stage build.
COPY --from=build /app/api-gateway/target/api-gateway-*.jar app.jar

# Mở cổng 8080.
EXPOSE 8080

# Lệnh khởi chạy ứng dụng.
ENTRYPOINT ["java", "-jar", "app.jar"]
