# Saga Pattern Microservices

![CircleCI](https://img.shields.io/circleci/build/github/uuhnaut69/saga-pattern-microservices/master?color=green&logo=circleci&style=for-the-badge)
![Spring Boot](https://img.shields.io/maven-central/v/org.springframework.boot/spring-boot-starter-parent?color=green&label=spring-boot&logo=spring-boot&style=for-the-badge)
![Terraform](https://img.shields.io/badge/Terraform-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)
![k6](https://img.shields.io/badge/k6-8A46FF?style=for-the-badge&logo=k6&logoColor=white)

Một dự án demo kiến trúc microservices với luồng xử lý đơn hàng đơn giản, thể hiện các khái niệm hiện đại trong phát triển phần mềm:

- **Kiến trúc Microservices**: Xây dựng với `Spring Boot`, `Spring Cloud`, và `Spring Cloud Stream`.
- **Database per Service**: Mỗi service sở hữu một database `PostgreSQL` riêng biệt, đảm bảo tính tự chủ.
- **Saga Pattern (Orchestration)**: Đảm bảo tính nhất quán của các giao dịch phân tán qua nhiều service.
- **Outbox Pattern**: Tránh lỗi "dual-writes" kinh điển, không cần đến Two-Phase Commit (2PC) nhờ sự kết hợp của `Kafka`, `Kafka Connect`, `Debezium`, và `Outbox Event Router`.
- **Infrastructure as Code (IaC)**: Toàn bộ cơ sở hạ tầng được quản lý và triển khai bằng **Terraform**, giúp tự động hóa và đảm bảo tính nhất quán trên các môi trường.
- **Performance Testing**: Bộ kịch bản kiểm thử hiệu năng toàn diện được xây dựng bằng **k6**, cho phép mô phỏng tải trọng người dùng thực tế và đánh giá khả năng chịu tải của hệ thống.

![Banner](./assets/banner.jpg)

## Kiến trúc hệ thống

Dự án bao gồm các thành phần chính sau:
- **API Gateway**: Cổng vào duy nhất cho tất cả các request từ client.
- **Customer Service**: Quản lý thông tin khách hàng.
- **Inventory Service**: Quản lý thông tin sản phẩm và kho hàng.
- **Order Service**: Xử lý logic đặt hàng, điều phối Saga.
- **Hệ thống Messaging**: Sử dụng Apache Kafka làm bus sự kiện trung tâm.
- **Hệ thống Logging & Monitoring**: ELK Stack, Prometheus và Grafana.

---

## Yêu cầu cài đặt

- `Java 21`
- `Docker` & `Docker Compose`
- `Terraform` (v1.0+)
- `k6` (v0.40.0+)
- `Maven`

---

## Hướng dẫn Bắt đầu

### 1. Triển khai Cơ sở hạ tầng với Terraform

Toàn bộ các dịch vụ nền tảng (databases, Kafka, monitoring tools) được định nghĩa dưới dạng Infrastructure as Code và triển khai bằng Terraform.

Điều hướng đến thư mục k8s chứa mã nguồn Terraform

```shell
cd k8s
```

Khởi tạo Terraform để tải các provider cần thiết
```shell
terraform init
```

Xem trước những gì sẽ được tạo ra (khuyến khích)
```shell
terraform plan
```

Áp dụng và triển khai toàn bộ cơ sở hạ tầng
```shell
terraform apply --auto-approve
```

Sau khi hoàn tất, bạn sẽ có toàn bộ các dịch vụ nền tảng đang chạy trên Docker.

### 2. Xây dựng các Microservices

Biên dịch và đóng gói tất cả các service Spring Boot.

Từ thư mục gốc của dự án
```shell
./mvnw clean package -DskipTests=true
```


### 3. Khởi chạy các Microservices

Khởi chạy từng service. Mở các terminal riêng biệt cho mỗi lệnh sau:

Chạy API Gateway
```shell
./mvnw -f api-gateway/pom.xml spring-boot:run
```

Chạy Order Service
```shell
./mvnw -f order-service/pom.xml spring-boot:run
```

Chạy Customer Service
```shell
./mvnw -f customer-service/pom.xml spring-boot:run
```

Chạy Inventory Service
```shell
./mvnw -f inventory-service/pom.xml spring-boot:run
```


**Bảng các Endpoint:**

| Service's name    | Endpoint (qua Gateway)                | Cổng nội bộ |
| ----------------- | ------------------------------------- | ------------ |
| Api Gateway       | `http://localhost:8080`               | 8080         |
| Order service     | `http://localhost:8080/order-service`   | 9090         |
| Customer service  | `http://localhost:8080/customer-service`| 9091         |
| Inventory service | `http://localhost:8080/inventory-service`| 9093         |

### 4. Đăng ký Debezium Connectors

Sau khi tất cả các service đã khởi động, chạy script sau để đăng ký các Debezium connector, cho phép chúng bắt đầu theo dõi các bảng outbox.

```shell
sh register-connectors.sh
```


---

## Kiểm thử hiệu năng với k6

Dự án đi kèm một bộ test hiệu năng toàn diện để mô phỏng tải trọng người dùng và đánh giá hiệu năng của các service.

Điều hướng đến thư mục chứa các bài test k6
```shell
cd k6-tests
```

Chạy toàn bộ các kịch bản test (tạo/đọc customer, product và đặt hàng)
```shell
k6 run main.js
```


Để chạy test trên một môi trường khác (ví dụ: staging), bạn có thể truyền biến môi trường:
```shell
k6 run -e BASE_URL=https://staging.api.example.com main.js
```


---

## Dọn dẹp

Để dừng và xóa toàn bộ cơ sở hạ tầng đã tạo:

Xóa các Debezium connectors
```shell
sh delete-connectors.sh
```

Dọn dẹp cơ sở hạ tầng bằng Terraform
```shell
cd k8s
terraform destroy --auto-approve
```


---

## Đóng góp

Pull request luôn được chào đón. Đối với các thay đổi lớn, vui lòng mở một issue trước để chúng ta có thể thảo luận về những gì bạn muốn thay đổi.

Vui lòng đảm bảo cập nhật các bài test một cách phù hợp.

## Giấy phép

[MIT](./LICENSE)
