// scenarios/order_scenarios.js
import http from 'k6/http';
import { check, sleep } from 'k6';
import { faker } from 'https://cdnjs.cloudflare.com/ajax/libs/Faker/8.4.1/faker.js';
import { buildApiUrl, HEADERS } from '../lib/http_client.js';

const SERVICE_NAME = 'order-service';
const ORDERS_PATH = '/orders';

/**
 * Kịch bản test đặt một đơn hàng mới.
 * @param {Array} customerIds - Mảng ID khách hàng có sẵn.
 * @param {Array} productIds - Mảng ID sản phẩm có sẵn.
 */
export function placeOrderTest(customerIds, productIds) {
    // Nếu chưa có đủ dữ liệu mồi, bỏ qua lần lặp này
    if (customerIds.length === 0 || productIds.length === 0) {
        sleep(1);
        return;
    }

    // Lấy ngẫu nhiên một customerId và productId từ danh sách có sẵn
    const randomCustomerId = customerIds[Math.floor(Math.random() * customerIds.length)];
    const randomProductId = productIds[Math.floor(Math.random() * productIds.length)];

    // Tạo payload cho đơn hàng
    const payload = {
        customerId: randomCustomerId,
        productId: randomProductId,
        price: faker.finance.amount({ min: 10, max: 2000, dec: 2 }),
        quantity: faker.number.int({ min: 1, max: 5 }),
    };

    const url = buildApiUrl(SERVICE_NAME, ORDERS_PATH);
    const res = http.post(url, JSON.stringify(payload), HEADERS);

    check(res, {
        'PLACE ORDER: status is 201 Created': (r) => r.status === 201,
    });

    sleep(1.5); // Giả lập thời gian suy nghĩ giữa các lần đặt hàng
}
