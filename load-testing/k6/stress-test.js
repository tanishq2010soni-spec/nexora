import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  stages: [
    { duration: '1m', target: 200 },
    { duration: '2m', target: 500 },
    { duration: '1m', target: 1000 },
    { duration: '3m', target: 2000 },
    { duration: '1m', target: 0 },
  ],
  thresholds: {
    http_req_duration: ['p(95)<10000'],
    http_req_failed: ['rate<0.05'],
  },
};

const BASE_URL = __ENV.BASE_URL || 'http://localhost:8000';

export default function () {
  const payloads = [
    { path: '/api/v1/health', method: 'GET' },
    { path: '/metrics', method: 'GET' },
  ];

  const p = payloads[Math.floor(Math.random() * payloads.length)];

  if (p.method === 'GET') {
    const res = http.get(`${BASE_URL}${p.path}`);
    check(res, { [`${p.path} status 200`]: (r) => r.status === 200 });
  }

  sleep(0.5);
}
