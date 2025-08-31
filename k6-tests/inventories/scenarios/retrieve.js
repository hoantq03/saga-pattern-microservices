// scenarios/inventory_scenarios.js
import http from 'k6/http';
import { check, sleep } from 'k6';
import { buildApiUrl, HEADERS } from '../lib/http_client.js';

const SERVICE_NAME = 'inventory-service';
const PRODUCTS_PATH = '/products';

/**
 * Kịch bản test đọc thông tin một sản phẩm theo ID.
 * @param {Array} productIds - Mảng chứa các ID sản phẩm có sẵn.
 */
export function readProductByIdTest(productIds) {
    if (productIds.length === 0) {
        sleep(1);
        return; // Không có sản phẩm nào để test
    }
    
    // Lấy ngẫu nhiên một ID từ danh sách
    const randomId = productIds[Math.floor(Math.random() * productIds.length)];
    const url = buildApiUrl(SERVICE_NAME, `${PRODUCTS_PATH}/${randomId}`);

    const res = http.get(url, HEADERS);
    check(res, {
        'GET PRODUCT BY ID: status is 200': (r) => r.status === 200,
    });
    sleep(2);
}
