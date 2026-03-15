$ErrorActionPreference = "Stop"

Write-Host "============================"
Write-Host "CREATOR BRIDGE cURL SCENARIO"
Write-Host "============================"

# Helper function to run curl and parse json
function Run-Curl {
    param (
        [string]$Name,
        [string]$Command
    )
    Write-Host "`n>>> $Name" -ForegroundColor Cyan
    Write-Host "> $Command" -ForegroundColor DarkGray
    $output = Invoke-Expression $Command
    if ($output) {
        $json = $output | ConvertFrom-Json -ErrorAction SilentlyContinue
        if ($json) {
            $json | ConvertTo-Json -Depth 5 
            return $json
        } else {
            Write-Host $output
            return $output
        }
    }
}

$BASE_URL = "http://localhost:8000/api/v1"
$BRAND_EMAIL = "brand_$(Get-Random)@test.com"
$CREATOR_EMAIL = "creator_$(Get-Random)@test.com"

# 1. Signup Brand
$cmd = "curl.exe -s -X POST $BASE_URL/auth/signup -H `"Content-Type: application/json`" -d `"{`"email`": `"$BRAND_EMAIL`", `"password`": `"test123`", `"role`": `"brand`", `"name`": `"Test Brand`"}`""
$res = Run-Curl "Signup Brand" $cmd
$BRAND_ID = $res._id

# 2. Login Brand
$cmd = "curl.exe -s -X POST $BASE_URL/auth/login -H `"Content-Type: application/x-www-form-urlencoded`" -d `"username=$BRAND_EMAIL&password=test123`""
$res = Run-Curl "Login Brand" $cmd
$BRAND_TOKEN = $res.access_token

# 3. Signup Creator
$cmd = "curl.exe -s -X POST $BASE_URL/auth/signup -H `"Content-Type: application/json`" -d `"{`"email`": `"$CREATOR_EMAIL`", `"password`": `"test123`", `"role`": `"creator`", `"name`": `"Test Creator`"}`""
$res = Run-Curl "Signup Creator" $cmd
$CREATOR_ID = $res._id

# 4. Login Creator
$cmd = "curl.exe -s -X POST $BASE_URL/auth/login -H `"Content-Type: application/x-www-form-urlencoded`" -d `"username=$CREATOR_EMAIL&password=test123`""
$res = Run-Curl "Login Creator" $cmd
$CREATOR_TOKEN = $res.access_token

# 5. Brand creates Campaign
$cmd = "curl.exe -s -X POST $BASE_URL/campaigns -H `"Authorization: Bearer $BRAND_TOKEN`" -H `"Content-Type: application/json`" -d `"{`"title`": `"Curl Campaign`", `"description`": `"Awesome campaign`", `"niche`": `"Tech`", `"budget`": 500, `"required_followers`": 1000}`""
$res = Run-Curl "Brand Creates Campaign" $cmd
$CAMPAIGN_ID = $res._id

# 6. Creator views Campaigns
$cmd = "curl.exe -s -X GET $BASE_URL/campaigns"
Run-Curl "List Campaigns" $cmd

# 7. Creator applies to Campaign
$cmd = "curl.exe -s -X POST $BASE_URL/applications -H `"Authorization: Bearer $CREATOR_TOKEN`" -H `"Content-Type: application/json`" -d `"{`"campaign_id`": `"$CAMPAIGN_ID`", `"proposal`": `"I will make an awesome video for you!`"}`""
$res = Run-Curl "Creator Applies to Campaign" $cmd
$APP_ID = $res._id

# 8. Brand accepts Application
$cmd = "curl.exe -s -X PUT $BASE_URL/applications/$APP_ID/status -H `"Authorization: Bearer $BRAND_TOKEN`" -H `"Content-Type: application/json`" -d `"{`"status`": `"accepted`"}`""
Run-Curl "Brand Accepts Application" $cmd

# 9. Brand creates Agreement
$cmd = "curl.exe -s -X POST $BASE_URL/agreements -H `"Authorization: Bearer $BRAND_TOKEN`" -H `"Content-Type: application/json`" -d `"{`"campaign_id`": `"$CAMPAIGN_ID`", `"creator_id`": `"$CREATOR_ID`", `"deliverables`": `"1x TikTok video`", `"payment_amount`": 500}`""
$res = Run-Curl "Brand Creates Agreement" $cmd
$AGREEMENT_ID = $res._id

# 10. Creator accepts Agreement
$cmd = "curl.exe -s -X PUT $BASE_URL/agreements/$AGREEMENT_ID -H `"Authorization: Bearer $CREATOR_TOKEN`" -H `"Content-Type: application/json`" -d `"{`"status`": `"accepted`"}`""
Run-Curl "Creator Accepts Agreement" $cmd

# 11. Add a Review (Brand reviews Creator)
$cmd = "curl.exe -s -X POST $BASE_URL/reviews -H `"Authorization: Bearer $BRAND_TOKEN`" -H `"Content-Type: application/json`" -d `"{`"reviewee_id`": `"$CREATOR_ID`", `"reviewee_role`": `"creator`", `"rating`": 5.0, `"comment`": `"Super professional!`", `"campaign_id`": `"$CAMPAIGN_ID`"}`""
Run-Curl "Brand Reviews Creator" $cmd

# 12. Cleanup - Delete Brand (Cascades)
$cmd = "curl.exe -s -X DELETE $BASE_URL/auth/account -H `"Authorization: Bearer $BRAND_TOKEN`""
Run-Curl "Delete Brand Account" $cmd

# 13. Cleanup - Delete Creator
$cmd = "curl.exe -s -X DELETE $BASE_URL/auth/account -H `"Authorization: Bearer $CREATOR_TOKEN`""
Run-Curl "Delete Creator Account" $cmd

Write-Host "`nAll cURL tests completed successfully!" -ForegroundColor Green
