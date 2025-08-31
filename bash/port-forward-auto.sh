#!/bin/bash

# Cấu hình ánh xạ cổng: "service-name:local-port:remote-port"
services=(
  # Databases (với cổng local khác nhau để tránh xung đột)
    "orderdb-svc:5432:5432",
    "customerdb-svc:5433:5432",
    "inventorydb-svc:5434:5432"

  # Kafka & Confluent Stack
  "broker-svc:9092:9092"
  "connect-svc:8083:8083"
  "control-center-svc:9021:9021"
  "consul-svc:8500:8500"

  # Monitoring & Logging
  "elasticsearch-svc:9200:9200"
  "kibana-svc:5601:5601"
  "logstash-svc:12201:12201/udp" # Ghi rõ protocol UDP cho Logstash
  "prometheus-svc:9090:9090"
  "grafana-svc:3000:3000"
  "kafka-exporter-svc:9308:9308"
  "postgres-exporter-svc:9187:9187"
)

# Hàm chạy và giám sát một kết nối port-forward
run_port_forward() {
  local service_config=$1
  
  # Vòng lặp vô tận để đảm bảo kết nối luôn được duy trì
  while true; do
    echo "Thiết lập port-forward cho: $service_config"
    kubectl port-forward "svc/$service_config" --address=127.0.0.1
    echo "Kết nối đến $service_config bị ngắt. Khởi động lại sau 5 giây..."
    sleep 5
  done
}

# Chạy tất cả các lệnh port-forward trong nền (background)
for config in "${services[@]}"; do
  # Tách cấu hình để hiển thị log
  service_name=$(echo "$config" | cut -d':' -f1)
  run_port_forward "$config" &
done

echo "Tất cả các kết nối port-forward đang chạy trong nền."
echo "Sử dụng 'jobs' để xem các tiến trình hoặc 'kill %<job_number>' để dừng một tiến trình."
echo "Nhấn Ctrl+C để dừng script này (sẽ không dừng các tiến trình nền)."

# Chờ tất cả các tiến trình con kết thúc
wait
