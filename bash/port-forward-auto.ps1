# Cấu hình ánh xạ cổng: "service-name:local-port:remote-port"
$services = @(
    # Databases
    "orderdb-svc:5432:5432",
    "customerdb-svc:5433:5432",
    "inventorydb-svc:5434:5432",

    # Kafka & Confluent Stack
    "broker-svc:9092:9092",
    "connect-svc:8083:8083",
    "control-center-svc:9021:9021",
    "consul-svc:8500:8500",

    # Monitoring & Logging
    "elasticsearch-svc:9200:9200",
    "kibana-svc:5601:5601",
    "logstash-svc:12201:12201", # kubectl tự động xử lý TCP/UDP
    "prometheus-svc:9090:9090",
    "grafana-svc:3000:3000",
    "kafka-exporter-svc:9308:9308",
    "postgres-exporter-svc:9187:9187"
)

Write-Host "Starting port-forwarding for all services..."

foreach ($serviceConfig in $services) {
    $parts = $serviceConfig -split ":"
    $svcName = $parts[0]
    $localPort = $parts[1]
    $remotePort = $parts[2]

    Write-Host " - Setting up: localhost:${localPort} -> ${svcName}:${remotePort}"
    Start-Process -FilePath "kubectl" -ArgumentList @("port-forward", "svc/$svcName", "${localPort}:${remotePort}", "--address", "127.0.0.1") -NoNewWindow
    Start-Sleep -Seconds 1
}

Write-Host ""
Write-Host "All port-forward processes started in the background."
Read-Host "Press ENTER to exit."
