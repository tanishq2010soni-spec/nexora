import http from 'k6/http';
import { check, sleep, group } from 'k6';
import { SharedArray } from 'k6/data';

export const options = {
  stages: [
    { duration: '2m', target: 100 },
    { duration: '5m', target: 100 },
    { duration: '2m', target: 500 },
    { duration: '5m', target: 500 },
    { duration: '2m', target: 1000 },
    { duration: '3m', target: 1000 },
    { duration: '2m', target: 0 },
  ],
  thresholds: {
    http_req_duration: ['p(95)<5000', 'p(99)<10000'],
    http_req_failed: ['rate<0.02'],
    http_reqs: ['rate>50'],
  },
};

const BASE_URL = __ENV.BASE_URL || 'http://localhost:8000';

const users = new SharedArray('users', () => {
  return Array.from({ length: 100 }, (_, i) => ({
    email: `load-${i}@nexora.ai`,
    password: 'LoadTest123!',
    org: `LoadOrg-${i}`,
  }));
});

export default function () {
  const user = users[__VU % users.length];
  let token = '';

  group('Auth', () => {
    const loginRes = http.post(`${BASE_URL}/api/v1/auth/login`, {
      email: user.email,
      password: user.password,
    });

    if (loginRes.status === 200) {
      token = loginRes.json('access_token');
    } else {
      // Signup if not exists
      const signupRes = http.post(`${BASE_URL}/api/v1/auth/signup`, {
        email: user.email,
        password: user.password,
        organization_name: user.org,
      });
      if (signupRes.status === 201) {
        token = signupRes.json('access_token');
      }
    }
  });

  if (!token) return;

  const params = {
    headers: {
      Authorization: `Bearer ${token}`,
      'Content-Type': 'application/json',
    },
  };

  group('Read Operations', () => {
    http.get(`${BASE_URL}/api/v1/health`, params);
    http.get(`${BASE_URL}/api/v1/leads?limit=20`, params);
    http.get(`${BASE_URL}/api/v1/customers?limit=20`, params);
    http.get(`${BASE_URL}/api/v1/dashboard`, params);
    http.get(`${BASE_URL}/api/v1/conversations?limit=10`, params);
  });

  group('Write Operations', () => {
    if (Math.random() < 0.3) {
      http.post(`${BASE_URL}/api/v1/leads`, {
        name: `Lead-${Date.now()}`,
        email: `lead-${Date.now()}-${__VU}@test.com`,
        status: 'new',
      }, params);
    }

    if (Math.random() < 0.1) {
      http.post(`${BASE_URL}/api/v1/customers`, {
        name: `Cust-${Date.now()}`,
        email: `cust-${Date.now()}@test.com`,
        segment: 'standard',
      }, params);
    }
  });

  group('Analytics', () => {
    if (Math.random() < 0.2) {
      http.get(`${BASE_URL}/api/v1/analytics/reports`, params);
      http.get(`${BASE_URL}/api/v1/analytics/reports/leads`, params);
    }
  });

  group('Metrics', () => {
    http.get(`${BASE_URL}/metrics`);
  });

  sleep(Math.random() * 2 + 1);
}
