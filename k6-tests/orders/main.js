// main.js
import http from 'k6/http';
import { SharedArray } from 'k6/data';

// Import thư viện và kịch bản
import { buildApiUrl, HEADERS } from './lib/http_client.js';
import { createRandomCustomer, createRandomProduct } from './lib/data_generator.js';
import { createCustomerTest, readCustomerTest } from './scenarios/customer_scenarios.js';
import { createProductTest, readProductByIdTest } from './scenarios/inventory_scenarios.js';
import { placeOrderTest } from './scenarios/order_scenarios.js';

// --- Định nghĩa hằng số ---
const CUSTOMER_SERVICE = 'customer-service';
const INVENTORY_SERVICE = 'inventory-service';
const ORDER_SERVICE = 'order-service';
const CUSTOMERS_PATH = '/customers';
const PRODUCTS_PATH = '/products';
const ORDERS_PATH = '/orders';

// --- Cấu hình Test ---
export const options = {
    scenarios: {
        // Scenarios cho Customer Service
        create_customers: {
            executor: 'constant-arrival-rate',
            rate: 10, timeUnit: '1s', duration: '30s',
            preAllocatedVUs: 10, maxVUs: 30,
            exec: 'runCreateCustomers',
        },
        read_customers: {
            executor: 'constant-vus',
            vus: 5, duration: '30s',
            exec: 'runReadCustomers',
        },
        // Scenarios cho Inventory Service
        create_products: {
            executor: 'constant-arrival-rate',
            rate: 15, timeUnit: '1s', duration: '30s',
            preAllocatedVUs: 10, maxVUs: 30,
            exec: 'runCreateProducts',
        },
        read_products: {
            executor: 'constant-vus',
            vus: 5, duration: '30s',
            exec: 'runReadProducts',
        },
        // Scenario cho Order Service
        place_orders: {
            executor: 'constant-arrival-rate',
            rate: 5, // Tỷ lệ đặt hàng thấp hơn tạo/đọc
            timeUnit: '1s',
            duration: '30s',
            preAllocatedVUs: 5,
            maxVUs: 20,
            exec: 'runPlaceOrders',
        },
    },
    thresholds: {
        'http_req_failed': ['rate<0.01'],
        'http_req_duration{service:customer}': ['p(95)<800'],
        'http_req_duration{service:inventory}': ['p(95)<500'],
        'http_req_duration{service:order}': ['p(95)<1200'], // Cho phép thời gian xử lý đơn hàng lâu hơn
    },
};

// --- Dữ liệu dùng chung ---
// SharedArray là cách tốt nhất để chia sẻ dữ liệu ban đầu từ setup
const customerIds = new SharedArray('customerIds', () => []);
const productIds = new SharedArray('productIds', () => []);

// --- Giai đoạn Setup ---
export function setup() {
    console.log('--- Setup: Creating initial data ---');
    // Tạo dữ liệu mồi cho Customer
    for (let i = 0; i < 10; i++) {
        const url = buildApiUrl(CUSTOMER_SERVICE, CUSTOMERS_PATH);
        const res = http.post(url, JSON.stringify(createRandomCustomer()), HEADERS);
        if (res.status === 201 && res.json('id')) customerIds.push(res.json('id'));
    }

    // Tạo dữ liệu mồi cho Product
    for (let i = 0; i < 20; i++) {
        const url = buildApiUrl(INVENTORY_SERVICE, PRODUCTS_PATH);
        const res = http.post(url, JSON.stringify(createRandomProduct()), HEADERS);
        if (res.status === 201 && res.json('id')) productIds.push(res.json('id'));
    }
    
    console.log(`Setup complete. Initial Customers: ${customerIds.length}, Initial Products: ${productIds.length}`);
    
    // Không cần return gì vì SharedArray đã được cập nhật
}

// --- Hàm Wrappers thực thi kịch bản ---
export function runCreateCustomers() {
    createCustomerTest(customerIds);
}

export function runReadCustomers() {
    readCustomerTest(customerIds);
}

export function runCreateProducts() {
    createProductTest(productIds);
}

export function runReadProducts() {
    readProductByIdTest(productIds);
}

export function runPlaceOrders() {
    // Kịch bản đặt hàng cần cả customerIds và productIds
    placeOrderTest(customerIds, productIds);
}

// --- Giai đoạn Teardown ---
export function teardown() {
    console.log('--- Teardown: Test finished ---');
}
