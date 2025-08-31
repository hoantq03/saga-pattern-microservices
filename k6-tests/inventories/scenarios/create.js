// scenarios/inventory_scenarios.js
import http from 'k6/http';
import { check, sleep } from 'k6';
import { buildApiUrl, HEADERS } from '../lib/http_client.js';
import { createRandomProduct } from '../lib/data_generator.js';

const SERVICE_NAME = 'inventory-service';
const PRODUCTS_PATH = '/products';

/**
 * Kịch bản test tạo một sản phẩm mới.
 * @param {Array} productIds - Mảng dùng chung để lưu ID của sản phẩm mới tạo.
 */
export function createProductTest(productIds) {
    const payload = createRandomProduct();
    const url = buildApiUrl(SERVICE_NAME, PRODUCTS_PATH);

    const res = http.post(url, JSON.stringify(payload), HEADERS);
    const isSuccess = check(res, {
        'CREATE PRODUCT: status is 201': (r) => r.status === 201,
    });

    if (isSuccess && res.json('id')) {
        productIds.push(res.json('id'));
    }
    sleep(1);
}
