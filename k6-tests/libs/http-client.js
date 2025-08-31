// Lấy base URL của Gateway từ biến môi trường
export const BASE_URL = __ENV.BASE_URL || 'http://localhost:8080';
export const CUSTOMERS_ENDPOINT = `${BASE_URL}/customer-service/customers`;
export const PRODUCTS_ENDPOINT = `${BASE_URL}/inventory-service/products`;
export const ORDERS_ENDPOINT = `${BASE_URL}/order-service/orders`;

/**
 * Xây dựng URL hoàn chỉnh để gọi đến một service qua API Gateway.
 * @param {string} serviceName - Tên service được định nghĩa trong gateway (vd: 'customer-service').
 * @param {string} path - Đường dẫn của endpoint (vd: '/customers').
 * @returns {string} URL hoàn chỉnh.
 */
export function buildApiUrl(serviceName, path) {
    return `${BASE_URL}/${serviceName}${path}`;
}

// Các header chung cho các request
export const HEADERS = {
    headers: {
        'Content-Type': 'application/json',
    },
};
