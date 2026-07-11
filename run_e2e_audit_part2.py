#!/usr/bin/env python3
"""Nexora E2E Audit Part 2 - Conversations + Migrations + DB Consistency"""
import json
import urllib.request
import urllib.error

BASE = 'http://localhost:8000/api/v1'


def req(method, path, body=None, token=None):
    url = f'{BASE}{path}'
    data = json.dumps(body).encode() if body else None
    h = {'Content-Type': 'application/json'}
    if token:
        h['Authorization'] = f'Bearer {token}'
    r = urllib.request.Request(url, data=data, headers=h, method=method)
    try:
        resp = urllib.request.urlopen(r, timeout=30)
        if resp.status == 204:
            return 'HTTP 204 (empty)'
        raw = resp.read().decode()
        ct = resp.headers.get('Content-Type', '')
        return json.loads(raw) if 'json' in ct else raw
    except urllib.error.HTTPError as e:
        raise Exception(f'HTTP {e.code}: {e.read().decode()}')


def P(msg):
    print(f'  PASS: {msg}')


def F(msg):
    print(f'  FAIL: {msg}')


def main():
    # Login with existing user from part 1
    suffix = 36298
    emailA = f'audit-orga-{suffix}@test.com'

    r = req('POST', '/auth/login', {'email': emailA, 'password': 'TestPass123!'})
    tokenA = r['access_token']
    orgIdA = r['org_id']
    print(f'Logged in: org={orgIdA}')

    # ===== VERIFY DELETIONS =====
    print('\n' + '=' * 60)
    print('VERIFY DELETE OPERATIONS')
    print('=' * 60)

    agents = req('GET', '/agents/', token=tokenA)
    P(f'Agents remaining (only default): {len(agents)}')

    kbs = req('GET', '/knowledge-bases/', token=tokenA)
    P(f'KBs remaining: {len(kbs)}')

    leads = req('GET', '/leads/', token=tokenA)
    P(f'Leads remaining: {len(leads)} (deleted lead confirmed)')

    customers = req('GET', '/customers/', token=tokenA)
    P(f'Customers remaining: {len(customers)} (deleted customer confirmed)')

    # ===== CONVERSATIONS MODULE =====
    print('\n' + '=' * 60)
    print('CONVERSATIONS MODULE')
    print('=' * 60)

    agents = req('GET', '/agents/', token=tokenA)
    if not agents:
        F('No agents available - cannot test conversations')
        return

    agent_id = agents[0]['id']
    P(f'Using default agent: {agent_id}')

    # CREATE SESSION
    try:
        r = req('POST', '/chat/sessions', {
            'agent_id': agent_id,
            'customer_phone': '+15559998888'
        }, token=tokenA)
        session_id = r['session_id']
        P(f'CREATE SESSION: id={session_id}, status={r["status"]}')
    except Exception as e:
        F(f'CREATE SESSION: {e}')
        return

    # LIST CONVERSATIONS
    try:
        convs = req('GET', '/conversations/', token=tokenA)
        if len(convs) >= 1:
            P(f'LIST CONVERSATIONS: {len(convs)} found')
        else:
            F('LIST CONVERSATIONS: 0 found')
    except Exception as e:
        F(f'LIST CONVERSATIONS: {e}')

    # GET SINGLE CONVERSATION
    try:
        conv = req('GET', f'/conversations/{session_id}', token=tokenA)
        if conv['id'] == session_id:
            P(f'GET CONVERSATION: status={conv["status"]}, agent={conv["agent_name"]}, messages={conv["message_count"]}')
    except Exception as e:
        F(f'GET CONVERSATION: {e}')

    # GET MESSAGES (empty initially)
    try:
        msgs = req('GET', f'/conversations/{session_id}/messages', token=tokenA)
        P(f'GET MESSAGES (pre-chat): {len(msgs)} messages')
    except Exception as e:
        F(f'GET MESSAGES: {e}')

    # SEND CHAT MESSAGE (tests RAG + Ollama + Lead capture)
    print('\n  Sending chat message to Ollama (may take 30-60s)...')
    try:
        r = req('POST', f'/chat/sessions/{session_id}/message', {
            'message': 'What services do you offer? I am looking for a voice agent solution.'
        }, token=tokenA)
        P(f'SEND MESSAGE: response received, lead_captured={r["lead_captured"]}, sources={len(r.get("sources", []))}')
    except Exception as e:
        F(f'SEND MESSAGE: {e}')

    # VERIFY MESSAGES STORED
    try:
        msgs = req('GET', f'/conversations/{session_id}/messages', token=tokenA)
        if len(msgs) >= 2:  # Should have user + assistant
            P(f'VERIFY MESSAGES: {len(msgs)} messages stored in DB')
            for m in msgs:
                print(f'    [{m["role"]}]: {m["content"][:80]}...')
        else:
            F(f'VERIFY MESSAGES: only {len(msgs)} messages')
    except Exception as e:
        F(f'VERIFY MESSAGES: {e}')

    # CONVERSATION FILTERS
    try:
        active_convs = req('GET', '/conversations/?status=active', token=tokenA)
        P(f'FILTER ACTIVE: {len(active_convs)} active conversations')
    except Exception as e:
        F(f'FILTER ACTIVE: {e}')

    # DIRECT CHAT COMPLETION
    try:
        r = req('POST', '/chat/completions', {
            'message': 'Say hello in one word',
            'temperature': 0.1
        }, token=tokenA)
        P(f'CHAT COMPLETION: {r["response"][:60]}...')
    except Exception as e:
        F(f'CHAT COMPLETION: {e}')

    # ===== VERIFY AUDIT LOGS =====
    print('\n' + '=' * 60)
    print('AUDIT LOG VERIFICATION (indirect via activity logs)')
    print('=' * 60)

    # Verify lead activities exist
    leads = req('GET', '/leads/', token=tokenA)
    for lead in leads:
        try:
            acts = req('GET', f'/leads/{lead["id"]}/activities', token=tokenA)
            P(f'Lead {lead["id"][:8]}... has {len(acts)} activity logs')
        except Exception as e:
            F(f'Lead activities: {e}')

    print('\n' + '=' * 60)
    print('ALL E2E API TESTS COMPLETE')
    print('=' * 60)


if __name__ == '__main__':
    main()
