import Chance from 'https://cdn.skypack.dev/chance';
import crypto from 'k6/crypto';

const chance = new Chance();

export function createRandomCustomer() {
    const uniqueId = crypto.randomBytes(16).toString('hex').substring(0, 8);
    const baseUsername = chance.twitter().substring(1);
    const uniqueSuffix = `${Date.now()}-${uniqueId}`;
    const uniqueUsername = `${baseUsername}-${uniqueSuffix}`;

    return {
        username: uniqueUsername,
        fullName: `${chance.first()} ${chance.last()}`,
        balance: parseFloat(chance.floating({ min: 0, max: 100000, fixed: 2 })),
    };
}

/**
 * Tạo dữ liệu ngẫu nhiên cho một sản phẩm bằng Chance.js
 */
export function createRandomProduct() {
    const name = chance.word({ syllables: 3 });
    const stocks = chance.integer({ min: 0, max: 1000 });

    return {
        name: name.charAt(0).toUpperCase() + name.slice(1), // Viết hoa chữ cái đầu
        stocks: stocks,
    };
}