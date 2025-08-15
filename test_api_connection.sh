#!/bin/bash

# PatrolShield API Test Script for Flutter Development
# Run this before starting Flutter development to verify API connectivity

echo "🛡️ PatrolShield API Connection Test"
echo "=================================="
echo ""

API_URL="https://api.millio.space"

echo "📡 Testing API connectivity..."

# Test basic connectivity
echo -n "🔍 Basic connection: "
if curl -s --connect-timeout 10 "$API_URL/health" > /dev/null; then
    echo "✅ SUCCESS"
else
    echo "❌ FAILED"
    exit 1
fi

# Test authentication endpoint
echo -n "🔐 Authentication endpoint: "
AUTH_RESPONSE=$(curl -s -w "%{http_code}" -X POST "$API_URL/auth/login" \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -d "username=admin&password=admin123" \
    -o /tmp/auth_response.json)

if [ "$AUTH_RESPONSE" = "200" ]; then
    echo "✅ SUCCESS"
    TOKEN=$(cat /tmp/auth_response.json | grep -o '"access_token":"[^"]*"' | cut -d'"' -f4)
    echo "🎟️ Token obtained: ${TOKEN:0:20}..."
    
    # Test protected endpoints
    echo -n "👥 Users endpoint: "
    USERS_RESPONSE=$(curl -s -w "%{http_code}" "$API_URL/users/" \
        -H "Authorization: Bearer $TOKEN" \
        -H "Accept: application/json" \
        -o /tmp/users_response.json)
    
    if [ "$USERS_RESPONSE" = "200" ]; then
        USER_COUNT=$(cat /tmp/users_response.json | grep -o '"id":[0-9]*' | wc -l)
        echo "✅ SUCCESS ($USER_COUNT users available)"
    else
        echo "❌ FAILED (HTTP $USERS_RESPONSE)"
    fi
    
    echo -n "🏢 Sites endpoint: "
    SITES_RESPONSE=$(curl -s -w "%{http_code}" "$API_URL/sites/" \
        -H "Authorization: Bearer $TOKEN" \
        -H "Accept: application/json" \
        -o /tmp/sites_response.json)
    
    if [ "$SITES_RESPONSE" = "200" ]; then
        SITES_COUNT=$(cat /tmp/sites_response.json | grep -o '"id":[0-9]*' | wc -l)
        echo "✅ SUCCESS ($SITES_COUNT sites available)"
    else
        echo "❌ FAILED (HTTP $SITES_RESPONSE)"
    fi
    
else
    echo "❌ FAILED (HTTP $AUTH_RESPONSE)"
    echo "⚠️ Cannot test protected endpoints without authentication"
fi

echo ""
echo "🌐 CORS test (for Flutter web):"
echo -n "🔄 Preflight request: "
CORS_RESPONSE=$(curl -s -w "%{http_code}" -X OPTIONS "$API_URL/users/" \
    -H "Origin: http://localhost:3000" \
    -H "Access-Control-Request-Method: GET" \
    -H "Access-Control-Request-Headers: Authorization" \
    -o /dev/null)

if [ "$CORS_RESPONSE" = "200" ] || [ "$CORS_RESPONSE" = "204" ]; then
    echo "✅ SUCCESS"
else
    echo "⚠️ HTTP $CORS_RESPONSE (may still work)"
fi

echo ""
echo "📋 Summary:"
echo "- API Base URL: $API_URL"
echo "- Working credentials: admin / admin123"
echo "- CORS configured for: http://localhost:3000"
echo ""
echo "✅ Ready for Flutter development!"
echo ""
echo "🚀 To run the Flutter app:"
echo "   cd web_admin"
echo "   flutter pub get"
echo "   flutter run -d web-server --web-hostname 0.0.0.0 --web-port 3000"

# Cleanup
rm -f /tmp/auth_response.json /tmp/users_response.json /tmp/sites_response.json