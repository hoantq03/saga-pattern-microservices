// scenarios/read_customer.js
import http from 'k6/http';
import { check, sleep, group } from 'k6';
import { CUSTOMERS_ENDPOINT } from '../../libs/http-client.js';

export function readCustomerTest(customerIds) {
    group('Read Operations', function () {
        // Lấy một khách hàng ngẫu nhiên theo ID
        if (customerIds.length > 0) {
            const randomId = customerIds[Math.floor(Math.random() * customerIds.length)];
            const resById = http.get(`${CUSTOMERS_ENDPOINT}/${randomId}`);
            check(resById, {
                'READ by ID: status is 200 or 404': (r) => r.status === 200 || r.status === 404
            });
        }

        // Thi thoảng lấy tất cả khách hàng
        if (__ITER % 25 === 0) {
            const resAll = http.get(CUSTOMERS_ENDPOINT);
            check(resAll, { 'READ All: status is 200': (r) => r.status === 200 });
        }

        // Thi thoảng đếm số lượng
        if (__ITER % 15 === 0) {
            const resCount = http.get(`${CUSTOMERS_ENDPOINT}/count-all`);
            check(resCount, { 'COUNT: status is 200': (r) => r.status === 200 });
        }
    });

    sleep(1);
}
