# PatrolShield Production Deployment Guide

## Current Issues & Fixes

### 🔧 Apache Configuration Problems Fixed

#### Backend API (api.millio.space) Issues:
1. **❌ Missing CORS Headers**: The `Access-Control-Allow-Origin "*"` was commented out
2. **❌ Incomplete WebSocket Proxy**: Missing WebSocket upgrade headers
3. **❌ Missing Preflight Handling**: No OPTIONS request handling

#### Frontend App (app.millio.space) Issues:
1. **❌ Incorrect WebSocket Proxy**: Frontend was trying to proxy WebSockets to itself instead of backend
2. **❌ CSP Mismatch**: Apache CSP didn't match Flutter app CSP
3. **❌ Wrong WebSocket Reference**: CSP mentioned `ws://app.millio.space` instead of `wss://api.millio.space`

### ✅ Corrected Configuration

#### Backend API Configuration (`apache-api-corrected.conf`):
- ✅ Fixed WebSocket proxy with proper upgrade headers
- ✅ Enabled CORS with specific origin (`https://app.millio.space`)
- ✅ Added OPTIONS preflight request handling
- ✅ Added security headers

#### Frontend App Configuration (`apache-frontend-corrected.conf`):
- ✅ Removed incorrect WebSocket proxy (WebSockets go directly to API)
- ✅ Fixed CSP to match Flutter app requirements
- ✅ Corrected WebSocket connection to point to `wss://api.millio.space`
- ✅ Added proper security headers

## 🚀 Deployment Steps

### 1. Update Apache Configurations
```bash
# On your server, replace the existing configurations:

# Backend API
sudo cp apache-api-corrected.conf /etc/apache2/sites-available/api.millio.space.conf

# Frontend App  
sudo cp apache-frontend-corrected.conf /etc/apache2/sites-available/app.millio.space.conf

# Reload Apache
sudo systemctl reload apache2
```

### 2. Deploy Flutter Web App
```bash
# Build production Flutter app
flutter build web --release

# Deploy to server (copy build/web contents to your server's /var/www/app.millio.space/)
rsync -avz build/web/ user@your-server:/var/www/app.millio.space/

# Or run locally on port 3000 for testing
cd build/web
python -m http.server 3000
```

### 3. Start Backend API
```bash
# Ensure your FastAPI backend is running on port 8000
# Example:
uvicorn main:app --host 127.0.0.1 --port 8000
```

## 🔍 Testing WebSocket Connection

### Test from Browser Console:
```javascript
// Test WebSocket connection directly
const ws = new WebSocket('wss://api.millio.space/ws/1?token=YOUR_JWT_TOKEN');
ws.onopen = () => console.log('✅ WebSocket connected');
ws.onerror = (error) => console.log('❌ WebSocket error:', error);
ws.onclose = (event) => console.log('WebSocket closed:', event);
```

## 🛠️ Environment Configuration

### Update `.env` for Production:
```env
API_BASE_URL=https://api.millio.space
WS_BASE_URL=wss://api.millio.space
APP_NAME=PatrolShield Admin
APP_VERSION=1.0.0
```

## 🔐 Security Checklist

### Backend (api.millio.space):
- ✅ HTTPS enforced
- ✅ CORS properly configured with specific origin
- ✅ WebSocket upgrade headers configured  
- ✅ Security headers (HSTS, X-Frame-Options, etc.)
- ✅ CSP allows Swagger UI

### Frontend (app.millio.space):
- ✅ HTTPS enforced
- ✅ CSP allows necessary resources (maps, fonts, API calls)
- ✅ WebSocket connections to API domain only
- ✅ Security headers configured
- ✅ No WebSocket proxy conflicts

## 🧪 Testing Commands

### Test API Endpoints:
```bash
# Test HTTPS API
curl -H "Authorization: Bearer YOUR_TOKEN" https://api.millio.space/users/

# Test CORS
curl -H "Origin: https://app.millio.space" \
     -H "Access-Control-Request-Method: GET" \
     -H "Access-Control-Request-Headers: authorization" \
     -X OPTIONS https://api.millio.space/users/
```

### Test Frontend:
```bash
# Check if app loads
curl -I https://app.millio.space/

# Check CSP headers
curl -I https://app.millio.space/ | grep -i content-security-policy
```

## 🚨 Common Issues & Solutions

### WebSocket Still Failing?
1. Check if backend WebSocket endpoint is running: `ws://127.0.0.1:8000/ws/`
2. Verify JWT token is valid and not expired
3. Check Apache error logs: `tail -f /var/log/apache2/api.millio.space-error.log`
4. Ensure mod_proxy_wstunnel is enabled: `sudo a2enmod proxy_wstunnel`

### API CORS Issues?
1. Verify Origin header matches exactly: `https://app.millio.space`
2. Check preflight OPTIONS requests are handled
3. Ensure backend FastAPI has CORS middleware configured

### CSP Violations?
1. Check browser console for specific violations
2. Update CSP headers in Apache config to allow required resources
3. Ensure Flutter app CSP matches Apache CSP