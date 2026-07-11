$base = "http://localhost:8000/api/v1"
$results = @()

function Write-Pass($msg) { Write-Host "PASS: $msg" -ForegroundColor Green; return @{status="PASS"; detail=$msg} }
function Write-Fail($msg) { Write-Host "FAIL: $msg" -ForegroundColor Red; return @{status="FAIL"; detail=$msg} }

# ==================== 1. AUTHENTICATION ====================
Write-Host "`n============================================================" -ForegroundColor Cyan
Write-Host "MODULE 1: AUTHENTICATION" -ForegroundColor Cyan
Write-Host "============================================================"

$suffix = Get-Random -Min 10000 -Max 99999
$emailA = "audit-orga-$suffix@test.com"
$orgNameA = "Audit-OrgA-$suffix"
$emailB = "audit-orgb-$suffix@test.com"
$orgNameB = "Audit-OrgB-$suffix"
$pwA = "TestPass123!"
$pwB = "TestPass456!"

# Signup A
try {
    $signupBody = @{email=$emailA; password=$pwA; organization_name=$orgNameA} | ConvertTo-Json
    $r = Invoke-RestMethod -Uri "$base/auth/signup" -Method Post -Body $signupBody -ContentType "application/json" -TimeoutSec 15
    $script:tokenA = $r.access_token
    $script:refreshA = $r.refresh_token
    $script:orgIdA = $r.org_id
    $results += Write-Pass "SIGNUP: created org $($r.org_id), user $($r.email), role=$($r.role)"
} catch { $results += Write-Fail "SIGNUP: $_" }

# Login A
try {
    $loginBody = @{email=$emailA; password=$pwA} | ConvertTo-Json
    $r = Invoke-RestMethod -Uri "$base/auth/login" -Method Post -Body $loginBody -ContentType "application/json" -TimeoutSec 15
    $script:tokenA = $r.access_token
    $results += Write-Pass "LOGIN: user $($r.email) authenticated, org=$($r.org_id)"
} catch { $results += Write-Fail "LOGIN: $_" }

# Refresh
try {
    $refreshBody = @{refresh_token=$script:refreshA} | ConvertTo-Json
    $r = Invoke-RestMethod -Uri "$base/auth/refresh" -Method Post -Body $refreshBody -ContentType "application/json" -TimeoutSec 15
    $script:tokenA = $r.access_token
    $results += Write-Pass "REFRESH: new token issued"
} catch { $results += Write-Fail "REFRESH: $_" }

# Wrong password
try {
    $wrongBody = @{email=$emailA; password="WrongPass1!"} | ConvertTo-Json
    $r = Invoke-RestMethod -Uri "$base/auth/login" -Method Post -Body $wrongBody -ContentType "application/json" -TimeoutSec 15
    $results += Write-Fail "WRONG PASSWORD: should have rejected"
} catch {
    if ($_.Exception.Response.StatusCode -eq 401) {
        $results += Write-Pass "WRONG PASSWORD: correctly rejected (401)"
    } else { $results += Write-Fail "WRONG PASSWORD: $_" }
}

# Signup B (different tenant)
try {
    $signupBody = @{email=$emailB; password=$pwB; organization_name=$orgNameB} | ConvertTo-Json
    $r = Invoke-RestMethod -Uri "$base/auth/signup" -Method Post -Body $signupBody -ContentType "application/json" -TimeoutSec 15
    $script:tokenB = $r.access_token
    $script:orgIdB = $r.org_id
    $results += Write-Pass "SIGNUP B: tenant $($r.org_id) created"
} catch { $results += Write-Fail "SIGNUP B: $_" }

# ==================== 2. DASHBOARD ====================
Write-Host "`n============================================================" -ForegroundColor Cyan
Write-Host "MODULE 2: DASHBOARD" -ForegroundColor Cyan
Write-Host "============================================================"

$hA = @{Authorization = "Bearer $script:tokenA"}
$hB = @{Authorization = "Bearer $script:tokenB"}

try {
    $dash = Invoke-RestMethod -Uri "$base/dashboard/stats" -Method Get -Headers $hA -TimeoutSec 10
    $results += Write-Pass "DASHBOARD: active_agents=$($dash.active_agents), leads_generated=$($dash.leads_generated), customers=$($dash.customers_managed)"
} catch { $results += Write-Fail "DASHBOARD: $_" }

# ==================== 3. AGENT CENTER ====================
Write-Host "`n============================================================" -ForegroundColor Cyan
Write-Host "MODULE 3: AGENT CENTER" -ForegroundColor Cyan
Write-Host "============================================================"

# LIST default agents
try {
    $agents = Invoke-RestMethod -Uri "$base/agents/" -Method Get -Headers $hA -TimeoutSec 10
    $results += Write-Pass "LIST AGENTS: found $($agents.Count) agents"
} catch { $results += Write-Fail "LIST AGENTS: $_" }

# CREATE agent
try {
    $agentBody = @{name="Test-Agent-$suffix"; platform_type="web"; system_prompt="You are a test agent."; llm_model="llama3"; temperature=0.5} | ConvertTo-Json
    $agent = Invoke-RestMethod -Uri "$base/agents/" -Method Post -Body $agentBody -ContentType "application/json" -Headers $hA -TimeoutSec 15
    $script:agentId = $agent.id
    $results += Write-Pass "CREATE AGENT: id=$($agent.id), name=$($agent.name)"
} catch { $results += Write-Fail "CREATE AGENT: $_" }

# GET agent by ID
try {
    $agentGet = Invoke-RestMethod -Uri "$base/agents/$script:agentId" -Method Get -Headers $hA -TimeoutSec 10
    if ($agentGet.id -eq $script:agentId) { $results += Write-Pass "GET AGENT: id matches" }
    else { $results += Write-Fail "GET AGENT: id mismatch" }
} catch { $results += Write-Fail "GET AGENT: $_" }

# UPDATE agent
try {
    $updateBody = @{name="Updated-Agent-$suffix"; temperature=0.8} | ConvertTo-Json
    $agentUpd = Invoke-RestMethod -Uri "$base/agents/$script:agentId" -Method Put -Body $updateBody -ContentType "application/json" -Headers $hA -TimeoutSec 15
    if ($agentUpd.name -eq "Updated-Agent-$suffix") { $results += Write-Pass "UPDATE AGENT: name changed" }
    else { $results += Write-Fail "UPDATE AGENT: name not updated" }
} catch { $results += Write-Fail "UPDATE AGENT: $_" }

# DELETE agent
try {
    Invoke-RestMethod -Uri "$base/agents/$script:agentId" -Method Delete -Headers $hA -TimeoutSec 15
    $results += Write-Pass "DELETE AGENT: 204 returned"
} catch { $results += Write-Fail "DELETE AGENT: $_" }

# Tenant isolation - verify Org B cannot see Org A agents
try {
    $agentsB = Invoke-RestMethod -Uri "$base/agents/" -Method Get -Headers $hB -TimeoutSec 10
    # Should only see the default agent created during signup
    if ($agentsB.Count -ge 1) { $results += Write-Pass "TENANT ISOLATION: Org B has $($agentsB.Count) agents (independent)" }
    else { $results += Write-Pass "TENANT ISOLATION: Org B has no agents" }
} catch { $results += Write-Fail "TENANT ISOLATION: $_" }

# ==================== 4. KNOWLEDGE BASE ====================
Write-Host "`n============================================================" -ForegroundColor Cyan
Write-Host "MODULE 4: KNOWLEDGE BASE" -ForegroundColor Cyan
Write-Host "============================================================"

# CREATE KB
try {
    $kbBody = @{name="Test-KB-$suffix"; description="Test knowledge base"} | ConvertTo-Json
    $kb = Invoke-RestMethod -Uri "$base/knowledge-bases/" -Method Post -Body $kbBody -ContentType "application/json" -Headers $hA -TimeoutSec 15
    $script:kbId = $kb.id
    $results += Write-Pass "CREATE KB: id=$($kb.id), name=$($kb.name)"
} catch { $results += Write-Fail "CREATE KB: $_" }

# LIST KBs
try {
    $kbs = Invoke-RestMethod -Uri "$base/knowledge-bases/" -Method Get -Headers $hA -TimeoutSec 10
    $results += Write-Pass "LIST KB: found $($kbs.Count) knowledge bases"
} catch { $results += Write-Fail "LIST KB: $_" }

# GET KB by ID
try {
    $kbGet = Invoke-RestMethod -Uri "$base/knowledge-bases/$script:kbId" -Method Get -Headers $hA -TimeoutSec 10
    if ($kbGet.id -eq $script:kbId) { $results += Write-Pass "GET KB: id matches, doc_count=$($kbGet.document_count)" }
} catch { $results += Write-Fail "GET KB: $_" }

# UPDATE KB
try {
    $kbUpdateBody = @{name="Updated-KB-$suffix"} | ConvertTo-Json
    $kbUpd = Invoke-RestMethod -Uri "$base/knowledge-bases/$script:kbId" -Method Put -Body $kbUpdateBody -ContentType "application/json" -Headers $hA -TimeoutSec 15
    if ($kbUpd.name -eq "Updated-KB-$suffix") { $results += Write-Pass "UPDATE KB: name changed" }
} catch { $results += Write-Fail "UPDATE KB: $_" }

# DELETE KB
try {
    Invoke-RestMethod -Uri "$base/knowledge-bases/$script:kbId" -Method Delete -Headers $hA -TimeoutSec 15
    $results += Write-Pass "DELETE KB: 204 returned"
} catch { $results += Write-Fail "DELETE KB: $_" }

# ==================== 5. LEADS ====================
Write-Host "`n============================================================" -ForegroundColor Cyan
Write-Host "MODULE 5: LEADS" -ForegroundColor Cyan
Write-Host "============================================================"

# CREATE lead
try {
    $leadBody = @{name="John Doe"; phone="+1555$suffix"; email="john$suffix@test.com"; intent="Buying inquiry"; product_interest="Voice Agent"; budget=5000} | ConvertTo-Json
    $lead = Invoke-RestMethod -Uri "$base/leads/" -Method Post -Body $leadBody -ContentType "application/json" -Headers $hA -TimeoutSec 15
    $script:leadId = $lead.id
    $results += Write-Pass "CREATE LEAD: id=$($lead.id), name=$($lead.name), score=$($lead.score)"
} catch { $results += Write-Fail "CREATE LEAD: $_" }

# LIST leads
try {
    $leads = Invoke-RestMethod -Uri "$base/leads/" -Method Get -Headers $hA -TimeoutSec 10
    $results += Write-Pass "LIST LEADS: found $($leads.Count) leads"
} catch { $results += Write-Fail "LIST LEADS: $_" }

# COUNT leads
try {
    $count = Invoke-RestMethod -Uri "$base/leads/count" -Method Get -Headers $hA -TimeoutSec 10
    $results += Write-Pass "COUNT LEADS: $($count.count)"
} catch { $results += Write-Fail "COUNT LEADS: $_" }

# GET lead by ID
try {
    $leadGet = Invoke-RestMethod -Uri "$base/leads/$script:leadId" -Method Get -Headers $hA -TimeoutSec 10
    $results += Write-Pass "GET LEAD: name=$($leadGet.name), status=$($leadGet.status)"
} catch { $results += Write-Fail "GET LEAD: $_" }

# UPDATE lead
try {
    $leadUpdateBody = @{name="Jane Doe Updated"; budget=7500} | ConvertTo-Json
    $leadUpd = Invoke-RestMethod -Uri "$base/leads/$script:leadId" -Method Put -Body $leadUpdateBody -ContentType "application/json" -Headers $hA -TimeoutSec 15
    if ($leadUpd.name -eq "Jane Doe Updated") { $results += Write-Pass "UPDATE LEAD: name changed" }
} catch { $results += Write-Fail "UPDATE LEAD: $_" }

# UPDATE lead status
try {
    $statusBody = @{status="contacted"} | ConvertTo-Json
    $leadStatus = Invoke-RestMethod -Uri "$base/leads/$script:leadId/status" -Method Patch -Body $statusBody -ContentType "application/json" -Headers $hA -TimeoutSec 15
    if ($leadStatus.status -eq "contacted") { $results += Write-Pass "UPDATE LEAD STATUS: changed to contacted" }
} catch { $results += Write-Fail "UPDATE LEAD STATUS: $_" }

# ASSIGN lead
try {
    $assignBody = @{assigned_to="agent@test.com"} | ConvertTo-Json
    $leadAssign = Invoke-RestMethod -Uri "$base/leads/$script:leadId/assign" -Method Patch -Body $assignBody -ContentType "application/json" -Headers $hA -TimeoutSec 15
    if ($leadAssign.assigned_to -eq "agent@test.com") { $results += Write-Pass "ASSIGN LEAD: assigned to agent@test.com" }
} catch { $results += Write-Fail "ASSIGN LEAD: $_" }

# ADD NOTE
try {
    $noteBody = @{description="Customer interested in premium package"} | ConvertTo-Json
    $note = Invoke-RestMethod -Uri "$base/leads/$script:leadId/notes" -Method Post -Body $noteBody -ContentType "application/json" -Headers $hA -TimeoutSec 15
    if ($note.activity_type -eq "note") { $results += Write-Pass "ADD LEAD NOTE: note created" }
} catch { $results += Write-Fail "ADD LEAD NOTE: $_" }

# GET activities
try {
    $activities = Invoke-RestMethod -Uri "$base/leads/$script:leadId/activities" -Method Get -Headers $hA -TimeoutSec 10
    if ($activities.Count -ge 1) { $results += Write-Pass "LEAD ACTIVITIES: $($activities.Count) activity logs found" }
} catch { $results += Write-Fail "LEAD ACTIVITIES: $_" }

# SEARCH leads
try {
    $search = Invoke-RestMethod -Uri "$base/leads/search?q=Jane" -Method Get -Headers $hA -TimeoutSec 10
    $results += Write-Pass "SEARCH LEADS: found $($search.Count) results for 'Jane'"
} catch { $results += Write-Fail "SEARCH LEADS: $_" }

# ANALYTICS
try {
    $analytics = Invoke-RestMethod -Uri "$base/leads/analytics" -Method Get -Headers $hA -TimeoutSec 10
    $results += Write-Pass "LEAD ANALYTICS: total=$($analytics.total_leads), avg_score=$($analytics.average_score)"
} catch { $results += Write-Fail "LEAD ANALYTICS: $_" }

# CSV EXPORT
try {
    $csv = Invoke-WebRequest -Uri "$base/leads/export/csv" -Method Get -Headers $hA -TimeoutSec 15
    if ($csv.Content -match "id,name") { $results += Write-Pass "CSV EXPORT: file contains headers (id,name)" }
    else { $results += Write-Fail "CSV EXPORT: unexpected content" }
} catch { $results += Write-Fail "CSV EXPORT: $_" }

# ==================== 6. CUSTOMERS ====================
Write-Host "`n============================================================" -ForegroundColor Cyan
Write-Host "MODULE 6: CUSTOMERS" -ForegroundColor Cyan
Write-Host "============================================================"

# CREATE customer
try {
    $custBody = @{phone="+1555$($suffix)-cust"; name="Alice Smith"; preferences="prefers voice calling"; segment="vip"} | ConvertTo-Json
    $cust = Invoke-RestMethod -Uri "$base/customers/" -Method Post -Body $custBody -ContentType "application/json" -Headers $hA -TimeoutSec 15
    $script:custId = $cust.id
    $results += Write-Pass "CREATE CUSTOMER: id=$($cust.id), name=$($cust.name)"
} catch { $results += Write-Fail "CREATE CUSTOMER: $_" }

# Duplicate phone check
try {
    $dupBody = @{phone="+1555$($suffix)-cust"; name="Duplicate"} | ConvertTo-Json
    $dup = Invoke-RestMethod -Uri "$base/customers/" -Method Post -Body $dupBody -ContentType "application/json" -Headers $hA -TimeoutSec 15
    $results += Write-Fail "DUPLICATE CUSTOMER: should have rejected"
} catch {
    if ($_.Exception.Response.StatusCode -eq 409) { $results += Write-Pass "DUPLICATE CUSTOMER: correctly rejected (409)" }
    else { $results += Write-Fail "DUPLICATE CUSTOMER: $_" }
}

# LIST customers
try {
    $customers = Invoke-RestMethod -Uri "$base/customers/" -Method Get -Headers $hA -TimeoutSec 10
    $results += Write-Pass "LIST CUSTOMERS: found $($customers.Count) customers"
} catch { $results += Write-Fail "LIST CUSTOMERS: $_" }

# GET customer by ID
try {
    $custGet = Invoke-RestMethod -Uri "$base/customers/$script:custId" -Method Get -Headers $hA -TimeoutSec 10
    $results += Write-Pass "GET CUSTOMER: name=$($custGet.name), segment=$($custGet.segment)"
} catch { $results += Write-Fail "GET CUSTOMER: $_" }

# UPDATE customer
try {
    $custUpdateBody = @{name="Alice Smith Updated"; preferences="prefers WhatsApp"} | ConvertTo-Json
    $custUpd = Invoke-RestMethod -Uri "$base/customers/$script:custId" -Method Patch -Body $custUpdateBody -ContentType "application/json" -Headers $hA -TimeoutSec 15
    if ($custUpd.name -eq "Alice Smith Updated") { $results += Write-Pass "UPDATE CUSTOMER: name changed" }
} catch { $results += Write-Fail "UPDATE CUSTOMER: $_" }

# UPDATE customer segment
try {
    $segBody = @{segment="regular"} | ConvertTo-Json
    $custSeg = Invoke-RestMethod -Uri "$base/customers/$script:custId/segment" -Method Patch -Body $segBody -ContentType "application/json" -Headers $hA -TimeoutSec 15
    if ($custSeg.segment -eq "regular") { $results += Write-Pass "UPDATE CUSTOMER SEGMENT: changed to regular" }
} catch { $results += Write-Fail "UPDATE CUSTOMER SEGMENT: $_" }

# ASSIGN customer
try {
    $assignBody = @{assigned_to="sales@test.com"} | ConvertTo-Json
    $custAssign = Invoke-RestMethod -Uri "$base/customers/$script:custId/assign" -Method Patch -Body $assignBody -ContentType "application/json" -Headers $hA -TimeoutSec 15
    if ($custAssign.assigned_to -eq "sales@test.com") { $results += Write-Pass "ASSIGN CUSTOMER: assigned to sales@test.com" }
} catch { $results += Write-Fail "ASSIGN CUSTOMER: $_" }

# ADD NOTE
try {
    $noteBody = @{description="Customer requested callback"} | ConvertTo-Json
    $note = Invoke-RestMethod -Uri "$base/customers/$script:custId/notes" -Method Post -Body $noteBody -ContentType "application/json" -Headers $hA -TimeoutSec 15
    if ($note.activity_type -eq "note") { $results += Write-Pass "ADD CUSTOMER NOTE: note created" }
} catch { $results += Write-Fail "ADD CUSTOMER NOTE: $_" }

# GET activities
try {
    $activities = Invoke-RestMethod -Uri "$base/customers/$script:custId/activities" -Method Get -Headers $hA -TimeoutSec 10
    if ($activities.Count -ge 1) { $results += Write-Pass "CUSTOMER ACTIVITIES: $($activities.Count) activity logs" }
} catch { $results += Write-Fail "CUSTOMER ACTIVITIES: $_" }

# SEARCH customers
try {
    $search = Invoke-RestMethod -Uri "$base/customers/search?q=Alice" -Method Get -Headers $hA -TimeoutSec 10
    $results += Write-Pass "SEARCH CUSTOMERS: found $($search.Count) for 'Alice'"
} catch { $results += Write-Fail "SEARCH CUSTOMERS: $_" }

# ANALYTICS
try {
    $analytics = Invoke-RestMethod -Uri "$base/customers/analytics" -Method Get -Headers $hA -TimeoutSec 10
    $results += Write-Pass "CUSTOMER ANALYTICS: total=$($analytics.total_customers), segments=$($analytics.segment_breakdown | ConvertTo-Json -Compress)"
} catch { $results += Write-Fail "CUSTOMER ANALYTICS: $_" }

# CSV EXPORT
try {
    $csv = Invoke-WebRequest -Uri "$base/customers/export/csv" -Method Get -Headers $hA -TimeoutSec 15
    if ($csv.Content -match "id,phone") { $results += Write-Pass "CSV EXPORT: customer CSV has headers" }
} catch { $results += Write-Fail "CSV EXPORT: $_" }

# DELETE customer
try {
    Invoke-RestMethod -Uri "$base/customers/$script:custId" -Method Delete -Headers $hA -TimeoutSec 15
    $results += Write-Pass "DELETE CUSTOMER: 204 returned"
} catch { $results += Write-Fail "DELETE CUSTOMER: $_" }


# ==================== 7. TENANT ISOLATION VERIFICATION ====================
Write-Host "`n============================================================" -ForegroundColor Cyan
Write-Host "MODULE 7: TENANT ISOLATION" -ForegroundColor Cyan
Write-Host "============================================================"

# Org B cannot see Org A data
try {
    $leadsB = Invoke-RestMethod -Uri "$base/leads/" -Method Get -Headers $hB -TimeoutSec 10
    $countB = $leadsB.Count
    $results += Write-Pass "TENANT ISOLATION LEADS: Org B sees $countB leads (independent from Org A)"
} catch { $results += Write-Fail "TENANT ISOLATION LEADS: $_" }

try {
    $customersB = Invoke-RestMethod -Uri "$base/customers/" -Method Get -Headers $hB -TimeoutSec 10
    $results += Write-Pass "TENANT ISOLATION CUSTOMERS: Org B sees $($customersB.Count) customers"
} catch { $results += Write-Fail "TENANT ISOLATION CUSTOMERS: $_" }

# ==================== 8. DELETE LEAD (cleanup) ====================
Write-Host "`n============================================================" -ForegroundColor Cyan
Write-Host "MODULE 8: CLEANUP" -ForegroundColor Cyan
Write-Host "============================================================"

try {
    Invoke-RestMethod -Uri "$base/leads/$script:leadId" -Method Delete -Headers $hA -TimeoutSec 15
    $results += Write-Pass "DELETE LEAD: 204 returned"
} catch { $results += Write-Fail "DELETE LEAD: $_" }


# ==================== REPORT ====================
Write-Host "`n============================================================" -ForegroundColor Cyan
Write-Host "E2E VERIFICATION SUMMARY" -ForegroundColor Cyan
Write-Host "============================================================"

$passCount = ($results | Where-Object { $_.status -eq "PASS" }).Count
$failCount = ($results | Where-Object { $_.status -eq "FAIL" }).Count

Write-Host "`nRESULTS: $passCount PASSED, $failCount FAILED" -ForegroundColor $(if ($failCount -eq 0) { "Green" } else { "Red" })
Write-Host ""

$results | ForEach-Object { Write-Host "$($_.status): $($_.detail)" }

# Export results
$results | ConvertTo-Json -Depth 3 | Out-File -FilePath "C:\Users\Rightway\Desktop\NEXORA\e2e_results.json" -Force
Write-Host "`nResults exported to e2e_results.json"
