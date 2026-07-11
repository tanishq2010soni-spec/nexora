import http from 'k6/http';
import { check, sleep, group } from 'k6';
import { Rate, Trend, Counter } from 'k6/metrics';

export const options = {
  vus: 5,
  duration: '1m',
  thresholds: {
    http_req_duration: ['p(95)<3000'],
    http_req_failed: ['rate<0.01'],
  },
};

const BASE_URL = __ENV.BASE_URL || 'http://localhost:8000';
let accessToken = '';
let orgId = '';

export default function () {
  group('Authentication', () => {
    const signupRes = http.post(`${BASE_URL}/api/v1/auth/signup`, {
      email: `test-${Date.now()}@nexora.ai`,
      password: 'TestPass123!',
      organization_name: `TestOrg-${Date.now()}`,
    });
    check(signupRes, { 'signup status 201': (r) => r.status === 201 });
    if (signupRes.status === 201) {
      accessToken = signupRes.json('access_token');
      orgId = signupRes.json('org_id');
    }
  });

  if (!accessToken) return;

  const params = {
    headers: {
      Authorization: `Bearer ${accessToken}`,
      'Content-Type': 'application/json',
    },
  };

  group('CRUD Operations', () => {
    // Health
    const healthRes = http.get(`${BASE_URL}/api/v1/health`, params);
    check(healthRes, { 'health status 200': (r) => r.status === 200 });

    // Create lead
    const leadRes = http.post(`${BASE_URL}/api/v1/leads`, {
      name: `Lead-${Date.now()}`,
      email: `lead-${Date.now()}@test.com`,
      status: 'new',
    }, params);
    check(leadRes, { 'create lead status 201': (r) => r.status === 201 });
    const leadId = leadRes.json('id');

    // List leads
    const leadsRes = http.get(`${BASE_URL}/api/v1/leads?limit=10`, params);
    check(leadsRes, { 'list leads status 200': (r) => r.status === 200 });

    // Dashboard
    const dashRes = http.get(`${BASE_URL}/api/v1/dashboard`, params);
    check(dashRes, { 'dashboard status 200': (r) => r.status === 200 });

    // Metrics
    const metricsRes = http.get(`${BASE_URL}/metrics`);
    check(metricsRes, { 'metrics status 200': (r) => r.status === 200 });
  });

  group('Analytics & Audit', () => {
    const analyticsRes = http.get(`${BASE_URL}/api/v1/analytics/reports`, params);
    check(analyticsRes, { 'analytics status 200': (r) => r.status === 200 });
  });

  sleep(1);
}
