import http from 'k6/http';
import { check, sleep, group } from 'k6';

export const options = {
  stages: [
    { duration: '5m', target: 200 },
    { duration: '240m', target: 200 },
    { duration: '5m', target: 0 },
  ],
  thresholds: {
    http_req_duration: ['p(95)<5000'],
    http_req_failed: ['rate<0.01'],
  },
};

const BASE_URL = __ENV.BASE_URL || 'http://localhost:8000';

export default function () {
  const res = http.get(`${BASE_URL}/api/v1/health`);
  check(res, { 'health ok': (r) => r.status === 200 });

  if (Math.random() < 0.1) {
    http.get(`${BASE_URL}/metrics`);
  }

  sleep(Math.random() * 3 + 2);
}
