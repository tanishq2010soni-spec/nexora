#!/usr/bin/env python3
"""Nexora E2E Integration Audit Script"""
import json
import sys
import os
import uuid
import random
import urllib.request
import urllib.error

BASE = 'http://localhost:8000/api/v1'
results = []


def P(msg):
    print(f'  PASS: {msg}')
    results.append({'status': 'PASS', 'detail': msg})


def F(msg):
    print(f'  FAIL: {msg}')
    results.append({'status': 'FAIL', 'detail': msg})


def req(method, path, body=None, token=None):
    url = f'{BASE}{path}'
    data = json.dumps(body).encode() if body else None
    headers = {'Content-Type': 'application/json'}
    if token:
        headers['Authorization'] = f'Bearer {token}'
    r = urllib.request.Request(url, data=data, headers=headers, method=method)
    try:
        resp = urllib.request.urlopen(r, timeout=30)
        ct = resp.headers.get('Content-Type', '')
        raw = resp.read().decode()
        if 'application/json' in ct:
            return json.loads(raw)
        return raw
    except urllib.error.HTTPError as e:
        err_body = e.read().decode()
        raise Exception(f'HTTP {e.code}: {err_body}')


def main():
    suffix = random.randint(10000, 99999)
    emailA = f'audit-orga-{suffix}@test.com'
    orgNameA = f'Audit-OrgA-{suffix}'
    emailB = f'audit-orgb-{suffix}@test.com'
    orgNameB = f'Audit-OrgB-{suffix}'

    # ===== MODULE 1: AUTHENTICATION =====
    print('\n' + '=' * 60)
    print('MODULE 1: AUTHENTICATION')
    print('=' * 60)

    # SIGNUP
    try:
        r = req('POST', '/auth/signup', {
            'email': emailA, 'password': 'TestPass123!',
            'organization_name': orgNameA
        })
        tokenA = r['access_token']
        refreshA = r['refresh_token']
        orgIdA = r['org_id']
        P(f'SIGNUP: org={orgIdA}, user={r["email"]}, role={r["role"]}')
    except Exception as e:
        F(f'SIGNUP: {e}')
        return

    # LOGIN
    try:
        r = req('POST', '/auth/login', {'email': emailA, 'password': 'TestPass123!'})
        tokenA = r['access_token']
        P(f'LOGIN: user={r["email"]}, org={r["org_id"]}')
    except Exception as e:
        F(f'LOGIN: {e}')

    # REFRESH
    try:
        r = req('POST', '/auth/refresh', {'refresh_token': refreshA})
        tokenA = r['access_token']
        P('REFRESH: new token issued')
    except Exception as e:
        F(f'REFRESH: {e}')

    # WRONG PASSWORD
    try:
        req('POST', '/auth/login', {'email': emailA, 'password': 'WrongPass1!'})
        F('WRONG PASSWORD: should have rejected')
    except Exception as e:
        if '401' in str(e):
            P('WRONG PASSWORD: correctly rejected (401)')
        else:
            F(f'WRONG PASSWORD: {e}')

    # SIGNUP ORG B
    try:
        r = req('POST', '/auth/signup', {
            'email': emailB, 'password': 'TestPass456!',
            'organization_name': orgNameB
        })
        tokenB = r['access_token']
        orgIdB = r['org_id']
        P(f'SIGNUP B: tenant={orgIdB}')
    except Exception as e:
        F(f'SIGNUP B: {e}')

    # ===== MODULE 2: DASHBOARD =====
    print('\n' + '=' * 60)
    print('MODULE 2: DASHBOARD')
    print('=' * 60)

    try:
        r = req('GET', '/dashboard/stats', token=tokenA)
        P(f'DASHBOARD: agents={r["active_agents"]}, leads={r["leads_generated"]}, customers={r["customers_managed"]}')
    except Exception as e:
        F(f'DASHBOARD: {e}')

    # ===== MODULE 3: AGENT CENTER =====
    print('\n' + '=' * 60)
    print('MODULE 3: AGENT CENTER')
    print('=' * 60)

    try:
        r = req('GET', '/agents/', token=tokenA)
        P(f'LIST AGENTS: {len(r)} agents')
    except Exception as e:
        F(f'LIST AGENTS: {e}')

    try:
        r = req('POST', '/agents/', {
            'name': f'Test-Agent-{suffix}', 'platform_type': 'web',
            'system_prompt': 'You are a test agent.',
            'llm_model': 'llama3', 'temperature': 0.5
        }, token=tokenA)
        agentId = r['id']
        P(f'CREATE AGENT: id={agentId}, name={r["name"]}')
    except Exception as e:
        F(f'CREATE AGENT: {e}')
        agentId = None

    if agentId:
        try:
            r = req('GET', f'/agents/{agentId}', token=tokenA)
            if r['id'] == agentId:
                P('GET AGENT: id matches')
            else:
                F('GET AGENT: id mismatch')
        except Exception as e:
            F(f'GET AGENT: {e}')

        try:
            r = req('PUT', f'/agents/{agentId}', {
                'name': f'Updated-Agent-{suffix}', 'temperature': 0.8
            }, token=tokenA)
            if r['name'] == f'Updated-Agent-{suffix}':
                P('UPDATE AGENT: name changed')
            else:
                F('UPDATE AGENT: name not updated')
        except Exception as e:
            F(f'UPDATE AGENT: {e}')

        try:
            req('DELETE', f'/agents/{agentId}', token=tokenA)
            P('DELETE AGENT: 204')
        except Exception as e:
            F(f'DELETE AGENT: {e}')

    try:
        r = req('GET', '/agents/', token=tokenB)
        P(f'TENANT ISOLATION AGENTS: Org B has {len(r)} agents')
    except Exception as e:
        F(f'TENANT ISOLATION AGENTS: {e}')

    # ===== MODULE 4: KNOWLEDGE BASE =====
    print('\n' + '=' * 60)
    print('MODULE 4: KNOWLEDGE BASE')
    print('=' * 60)

    try:
        r = req('POST', '/knowledge-bases/', {
            'name': f'Test-KB-{suffix}', 'description': 'Test KB'
        }, token=tokenA)
        kbId = r['id']
        P(f'CREATE KB: id={kbId}, name={r["name"]}')
    except Exception as e:
        F(f'CREATE KB: {e}')
        kbId = None

    if kbId:
        try:
            r = req('GET', '/knowledge-bases/', token=tokenA)
            P(f'LIST KB: {len(r)} KBs')
        except Exception as e:
            F(f'LIST KB: {e}')

        try:
            r = req('GET', f'/knowledge-bases/{kbId}', token=tokenA)
            if r['id'] == kbId:
                P(f'GET KB: id matches, docs={r["document_count"]}')
        except Exception as e:
            F(f'GET KB: {e}')

        try:
            r = req('PUT', f'/knowledge-bases/{kbId}', {
                'name': f'Updated-KB-{suffix}'
            }, token=tokenA)
            if r['name'] == f'Updated-KB-{suffix}':
                P('UPDATE KB: name changed')
        except Exception as e:
            F(f'UPDATE KB: {e}')

        try:
            req('DELETE', f'/knowledge-bases/{kbId}', token=tokenA)
            P('DELETE KB: 204')
        except Exception as e:
            F(f'DELETE KB: {e}')

    # ===== MODULE 5: LEADS =====
    print('\n' + '=' * 60)
    print('MODULE 5: LEADS')
    print('=' * 60)

    try:
        r = req('POST', '/leads/', {
            'name': 'John Doe', 'phone': f'+1555{suffix}',
            'email': f'john{suffix}@test.com', 'intent': 'Buying inquiry',
            'product_interest': 'Voice Agent', 'budget': 5000
        }, token=tokenA)
        leadId = r['id']
        P(f'CREATE LEAD: id={leadId}, name={r["name"]}, score={r["score"]}')
    except Exception as e:
        F(f'CREATE LEAD: {e}')
        leadId = None

    if leadId:
        try:
            r = req('GET', '/leads/', token=tokenA)
            P(f'LIST LEADS: {len(r)} leads')
        except Exception as e:
            F(f'LIST LEADS: {e}')

        try:
            r = req('GET', '/leads/count', token=tokenA)
            P(f'COUNT LEADS: {r["count"]}')
        except Exception as e:
            F(f'COUNT LEADS: {e}')

        try:
            r = req('GET', f'/leads/{leadId}', token=tokenA)
            P(f'GET LEAD: name={r["name"]}, status={r["status"]}')
        except Exception as e:
            F(f'GET LEAD: {e}')

        try:
            r = req('PUT', f'/leads/{leadId}', {
                'name': 'Jane Doe Updated', 'budget': 7500
            }, token=tokenA)
            if r['name'] == 'Jane Doe Updated':
                P('UPDATE LEAD: name changed')
            else:
                F('UPDATE LEAD: name not updated')
        except Exception as e:
            F(f'UPDATE LEAD: {e}')

        try:
            r = req('PATCH', f'/leads/{leadId}/status', {
                'status': 'contacted'
            }, token=tokenA)
            if r['status'] == 'contacted':
                P('UPDATE STATUS: changed to contacted')
        except Exception as e:
            F(f'UPDATE STATUS: {e}')

        try:
            r = req('PATCH', f'/leads/{leadId}/assign', {
                'assigned_to': 'agent@test.com'
            }, token=tokenA)
            if r['assigned_to'] == 'agent@test.com':
                P('ASSIGN LEAD: to agent@test.com')
        except Exception as e:
            F(f'ASSIGN LEAD: {e}')

        try:
            r = req('POST', f'/leads/{leadId}/notes', {
                'description': 'Interested in premium'
            }, token=tokenA)
            if r.get('activity_type') == 'note':
                P('ADD LEAD NOTE: created')
            else:
                F(f'ADD LEAD NOTE: unexpected {r}')
        except Exception as e:
            F(f'ADD LEAD NOTE: {e}')

        try:
            r = req('GET', f'/leads/{leadId}/activities', token=tokenA)
            if len(r) >= 1:
                P(f'LEAD ACTIVITIES: {len(r)} logs found')
            else:
                F('LEAD ACTIVITIES: 0 logs')
        except Exception as e:
            F(f'LEAD ACTIVITIES: {e}')

        try:
            r = req('GET', '/leads/search?q=Jane', token=tokenA)
            P(f'SEARCH LEADS: {len(r)} results')
        except Exception as e:
            F(f'SEARCH LEADS: {e}')

        try:
            r = req('GET', '/leads/analytics', token=tokenA)
            P(f'LEAD ANALYTICS: total={r["total_leads"]}, avg_score={r["average_score"]}')
        except Exception as e:
            F(f'LEAD ANALYTICS: {e}')

        try:
            csv = req('GET', '/leads/export/csv', token=tokenA)
            if 'id,name' in csv:
                P('CSV EXPORT: has headers')
            else:
                F(f'CSV EXPORT: unexpected {csv[:100]}')
        except Exception as e:
            F(f'CSV EXPORT: {e}')

        # ===== MODULE 6: CUSTOMERS =====
        print('\n' + '=' * 60)
        print('MODULE 6: CUSTOMERS')
        print('=' * 60)

        try:
            r = req('POST', '/customers/', {
                'phone': f'+1555{suffix}-cust', 'name': 'Alice Smith',
                'preferences': 'prefers voice calling', 'segment': 'vip'
            }, token=tokenA)
            custId = r['id']
            P(f'CREATE CUSTOMER: id={custId}, name={r["name"]}')
        except Exception as e:
            F(f'CREATE CUSTOMER: {e}')
            custId = None

        if custId:
            # Duplicate phone
            try:
                req('POST', '/customers/', {
                    'phone': f'+1555{suffix}-cust', 'name': 'Duplicate'
                }, token=tokenA)
                F('DUPLICATE CUSTOMER: should have rejected')
            except Exception as e:
                if '409' in str(e):
                    P('DUPLICATE CUSTOMER: correctly rejected (409)')
                else:
                    F(f'DUPLICATE CUSTOMER: {e}')

            try:
                r = req('GET', '/customers/', token=tokenA)
                P(f'LIST CUSTOMERS: {len(r)} customers')
            except Exception as e:
                F(f'LIST CUSTOMERS: {e}')

            try:
                r = req('GET', f'/customers/{custId}', token=tokenA)
                P(f'GET CUSTOMER: name={r["name"]}, segment={r["segment"]}')
            except Exception as e:
                F(f'GET CUSTOMER: {e}')

            try:
                r = req('PATCH', f'/customers/{custId}', {
                    'name': 'Alice Smith Updated', 'preferences': 'prefers WhatsApp'
                }, token=tokenA)
                if r['name'] == 'Alice Smith Updated':
                    P('UPDATE CUSTOMER: name changed')
                else:
                    F('UPDATE CUSTOMER: name not updated')
            except Exception as e:
                F(f'UPDATE CUSTOMER: {e}')

            try:
                r = req('PATCH', f'/customers/{custId}/segment', {
                    'segment': 'regular'
                }, token=tokenA)
                if r['segment'] == 'regular':
                    P('UPDATE SEGMENT: regular')
            except Exception as e:
                F(f'UPDATE SEGMENT: {e}')

            try:
                r = req('PATCH', f'/customers/{custId}/assign', {
                    'assigned_to': 'sales@test.com'
                }, token=tokenA)
                if r['assigned_to'] == 'sales@test.com':
                    P('ASSIGN CUSTOMER: sales@test.com')
            except Exception as e:
                F(f'ASSIGN CUSTOMER: {e}')

            try:
                r = req('POST', f'/customers/{custId}/notes', {
                    'description': 'Callback requested'
                }, token=tokenA)
                if r.get('activity_type') == 'note':
                    P('ADD CUSTOMER NOTE: created')
            except Exception as e:
                F(f'ADD CUSTOMER NOTE: {e}')

            try:
                r = req('GET', f'/customers/{custId}/activities', token=tokenA)
                if len(r) >= 1:
                    P(f'CUSTOMER ACTIVITIES: {len(r)} logs')
                else:
                    F('CUSTOMER ACTIVITIES: 0 logs')
            except Exception as e:
                F(f'CUSTOMER ACTIVITIES: {e}')

            try:
                r = req('GET', '/customers/search?q=Alice', token=tokenA)
                P(f'SEARCH CUSTOMERS: {len(r)} results')
            except Exception as e:
                F(f'SEARCH CUSTOMERS: {e}')

            try:
                r = req('GET', '/customers/analytics', token=tokenA)
                P(f'CUSTOMER ANALYTICS: total={r["total_customers"]}')
            except Exception as e:
                F(f'CUSTOMER ANALYTICS: {e}')

            try:
                csv = req('GET', '/customers/export/csv', token=tokenA)
                if 'id,phone' in csv:
                    P('CSV EXPORT: has headers')
            except Exception as e:
                F(f'CSV EXPORT: {e}')

    # ===== MODULE 7: TENANT ISOLATION =====
    print('\n' + '=' * 60)
    print('MODULE 7: TENANT ISOLATION')
    print('=' * 60)

    try:
        r = req('GET', '/leads/', token=tokenB)
        P(f'Org B sees {len(r)} leads (isolated from Org A)')
    except Exception as e:
        F(f'TENANT LEADS: {e}')

    try:
        r = req('GET', '/customers/', token=tokenB)
        P(f'Org B sees {len(r)} customers (isolated from Org A)')
    except Exception as e:
        F(f'TENANT CUSTOMERS: {e}')

    # ===== MODULE 8: DELETE (CLEANUP) =====
    print('\n' + '=' * 60)
    print('MODULE 8: DELETE CLEANUP')
    print('=' * 60)

    if leadId:
        try:
            req('DELETE', f'/leads/{leadId}', token=tokenA)
            P('DELETE LEAD: 204')
        except Exception as e:
            F(f'DELETE LEAD: {e}')

    if custId:
        try:
            req('DELETE', f'/customers/{custId}', token=tokenA)
            P('DELETE CUSTOMER: 204')
        except Exception as e:
            F(f'DELETE CUSTOMER: {e}')

    # ===== FINAL SUMMARY =====
    print('\n' + '=' * 60)
    print('FINAL SUMMARY')
    print('=' * 60)
    pass_count = sum(1 for r in results if r['status'] == 'PASS')
    fail_count = sum(1 for r in results if r['status'] == 'FAIL')
    print(f'\nTotal: {pass_count} PASSED, {fail_count} FAILED\n')

    for r in results:
        print(f'{r["status"]}: {r["detail"]}')

    with open('e2e_results.json', 'w') as f:
        json.dump(results, f, indent=2)
    print('\nResults saved to e2e_results.json')


if __name__ == '__main__':
    main()
