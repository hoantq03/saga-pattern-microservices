# =================================================================
# STAGE 1: Build application
# =================================================================
FROM maven:3.9-eclipse-temurin-21 AS build

WORKDIR /app

# Copy TOÀN BỘ mã nguồn vào ngay từ đầu.
# Điều này đảm bảo Maven có đầy đủ ngữ cảnh về project cha và tất cả các module con.
COPY . .

# Build toàn bộ project bằng lệnh "install".
# Lệnh này sẽ build và cài đặt tất cả các module, giải quyết mọi phụ thuộc nội bộ.
RUN mvn clean install -DskipTests

# =================================================================
# STAGE 2: Run application
# =================================================================
FROM eclipse-temurin:21-jre-jammy

WORKDIR /app

# Copy file jar của customer-service từ stage build.
COPY --from=build /app/customer-service/target/customer-service-*.jar app.jar

# Mở cổng 9091.
EXPOSE 9091

# Lệnh khởi chạy ứng dụng.
ENTRYPOINT ["java", "-jar", "app.jar"]
