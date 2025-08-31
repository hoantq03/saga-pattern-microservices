import http from 'k6/http';
import { check, sleep } from 'k6';

export let options = {
    vus: 10,  // 1000 concurrent users
    duration: '30s',  // Run for 30 seconds
};

export default function () {
    let randomUser = `user_${Math.random().toString(36).substr(2, 5)}`;
    let balance = 9_999_999_999_999_999;

    let res = http.post('http://localhost:8080/customer-service/customers', JSON.stringify({
        username: randomUser,
        fullName: "Test User",
        balance: balance
    }), { headers: { 'Content-Type': 'application/json' } });

    // let res = http.get('http://localhost:8080/customer-service/customers', { headers: { 'Content-Type': 'application/json' } });

    check(res, { 'status is 201': (r) => r.status === 201 });
    sleep(1);
}
