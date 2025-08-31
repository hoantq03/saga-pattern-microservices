// main.js - Đã sửa lỗi SharedArray

import http from 'k6/http';

// Import các module của bạn
import { createCustomerTest } from './scenarios/create.js';
import { readCustomerTest } from './scenarios/retrieve.js';
import { CUSTOMERS_ENDPOINT } from '../libs/http-client.js';
import { createRandomCustomer } from '../libs/data-generators.js';

export const options = {
    scenarios: {
        // Kịch bản tạo khách hàng với tải trọng đã giảm
        // create_scenario: {
        //     executor: 'constant-arrival-rate',
        //     rate: 2000,          // Giảm từ 200 xuống 100 lượt/giây
        //     timeUnit: '1s',
        //     duration: '10s',
        //     preAllocatedVUs: 2000, // Điều chỉnh tương ứng với rate
        //     maxVUs: 2700,          // Giới hạn VUs để tránh quá tải máy chạy test
        //     exec: 'runCreateTests',
        // },
        // Kịch bản đọc khách hàng với tải trọng đã giảm
        read_scenario: {
            executor: 'constant-vus',
            vus: 100,              // Giảm từ 100 xuống 50 VUs
            duration: '10s',
            exec: 'runReadTests',
        },
    },
    thresholds: {
        'http_req_failed': ['rate<0.002'],   // Cho phép tỷ lệ lỗi dưới 2%
        'http_req_duration': ['p(95)<1000'], // Mục tiêu 95% request phản hồi dưới 2 giây
    },
};


// --- Setup: Chạy 1 lần trước khi test ---
export function setup() {
    console.log('--- Setting up initial data ---');
    
    // Sử dụng một mảng JavaScript thông thường
    const initialIds = [];

    // Tạo 5 khách hàng ban đầu
    for (let i = 0; i < 5; i++) {
        const payload = createRandomCustomer();
        const res = http.post(CUSTOMERS_ENDPOINT, JSON.stringify(payload), { headers: { 'Content-Type': 'application/json' } });
        if (res.status === 201 && res.json('id')) {
            initialIds.push(res.json('id'));
        }
    }
    
    console.log(`Created ${initialIds.length} initial customers.`);

    // Trả về đối tượng chứa mảng ID. 
    // k6 sẽ truyền một bản sao của đối tượng này đến mỗi VU.
    return { customerIds: initialIds };
}

// --- Hàm Wrappers để gọi các kịch bản test ---

// 'data' ở đây là đối tượng được trả về từ hàm setup()
export function runCreateTests(data) {
    // Truyền bản sao của mảng customerIds cho hàm test
    createCustomerTest(data.customerIds);
}

export function runReadTests(data) {
    readCustomerTest(data.customerIds);
}

// --- Teardown: Chạy 1 lần sau khi test xong ---
export function teardown() {
    console.log('--- Tearing down test data ---');
    // Logic dọn dẹp của bạn ở đây
}

