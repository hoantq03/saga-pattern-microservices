// scenarios/create_customer.js
import http from 'k6/http';
import { check, sleep } from 'k6';
import { createRandomCustomer } from '../../libs/data-generators.js';
import { CUSTOMERS_ENDPOINT, HEADERS } from '../../libs/http-client.js';

export function createCustomerTest(customerIds) {
    const payload = createRandomCustomer();

    const res = http.post(CUSTOMERS_ENDPOINT, JSON.stringify(payload), HEADERS);

    const isSuccess = check(res, {
        'CREATE: status is 201': (r) => r.status === 201,
    });

    // Nếu tạo thành công, thêm ID vào danh sách dùng chung
    if (isSuccess && res.json('id')) {
        customerIds.push(res.json('id'));
    }

    sleep(1);
}
