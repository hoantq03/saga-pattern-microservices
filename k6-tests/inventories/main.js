// main.js
import http from 'k6/http';
import { SharedArray } from 'k6/data';

// Import các thư viện dùng chung
import { buildApiUrl, HEADERS } from './lib/http_client.js';
import { createRandomCustomer, createRandomProduct } from './lib/data_generator.js';

// Import các kịch bản test
import { createCustomerTest, readCustomerTest } from './scenarios/customer_scenarios.js'; // Giả sử bạn đổi tên file cũ
import { createProductTest, readProductByIdTest } from './scenarios/inventory_scenarios.js';

// --- Định nghĩa các hằng số ---
const CUSTOMER_SERVICE = 'customer-service';
const INVENTORY_SERVICE = 'inventory-service';
const CUSTOMERS_PATH = '/customers';
const PRODUCTS_PATH = '/products';

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
    },
    thresholds: {
        'http_req_failed': ['rate<0.01'],
        'http_req_duration{service:customer}': ['p(95)<800'],
        'http_req_duration{service:inventory}': ['p(95)<500'],
    },
};

// --- Dữ liệu dùng chung giữa các VUs ---
const customerIds = new SharedArray('customerIds', () => []);
const productIds = new SharedArray('productIds', () => []);

// --- Giai đoạn Setup: Chạy 1 lần duy nhất trước khi test ---
export function setup() {
    console.log('--- Setup: Creating initial data for all services ---');
    const initialCustomerIds = [];
    for (let i = 0; i < 5; i++) {
        const url = buildApiUrl(CUSTOMER_SERVICE, CUSTOMERS_PATH);
        const res = http.post(url, JSON.stringify(createRandomCustomer()), HEADERS);
        if (res.status === 201 && res.json('id')) initialCustomerIds.push(res.json('id'));
    }

    const initialProductIds = [];
    for (let i = 0; i < 5; i++) {
        const url = buildApiUrl(INVENTORY_SERVICE, PRODUCTS_PATH);
        const res = http.post(url, JSON.stringify(createRandomProduct()), HEADERS);
        if (res.status === 201 && res.json('id')) initialProductIds.push(res.json('id'));
    }
    
    // Đẩy dữ liệu mồi vào mảng dùng chung
    initialCustomerIds.forEach(id => customerIds.push(id));
    initialProductIds.forEach(id => productIds.push(id));
    
    console.log(`Setup complete. Initial Customers: ${customerIds.length}, Initial Products: ${productIds.length}`);
}

// --- Hàm Wrappers để thực thi các kịch bản ---
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

// --- Giai đoạn Teardown: Chạy 1 lần sau khi test xong ---
export function teardown() {
    console.log('--- Teardown: Cleaning up test data if necessary ---');
    // Thêm logic dọn dẹp ở đây nếu cần
}
