# PatrolShield AI Agent - Initialization Prompt

**Initialization Date:** August 15, 2025  
**API Target:** https://api.millio.space  
**Test Environment:** Flutter Web Admin Dashboard  
**Project:** PatrolShield Security Management System  

## Executive Summary

You are a Flutter Web Frontend Developer AI Agent for the PatrolShield project. The API at `https://api.millio.space` is **FULLY ACCESSIBLE** and **READY FOR DEVELOPMENT**.

### ✅ System Requirements
- **API Status:** ✅ ONLINE AND ACCESSIBLE
- **Authentication:** ✅ WORKING (admin/admin123)
- **CORS Policy:** ✅ PROPERLY CONFIGURED for localhost:3000
- **Test Environment:** ✅ READY FOR DEVELOPMENT

## Critical Prerequisites

### 1. Mandatory Documentation Reading ✅
**🚨 CRITICAL FIRST STEP**: Before doing ANYTHING else, you MUST:

| File | Status | Priority |
|------|---------|----------|
| `.github/MANDATORY-AI-AGENT-WORKFLOW.md` | ✅ REQUIRED | CRITICAL |
| `.github/frontend-development-instructions.md` | ✅ REQUIRED | CRITICAL |
| Follow mandatory file reading order | ✅ REQUIRED | CRITICAL |

### 2. API Connection Details ✅
**Working API Configuration:**
- **Base URL:** `https://api.millio.space`
- **Test Credentials:** 
  - Username: `admin`
  - Password: `admin123`
- **Authentication Method:** JWT Bearer tokens
- **Response Time:** 193ms - 843ms (excellent)

**Verified Endpoints:**
- ✅ `/auth/login` - Authentication endpoint
- ✅ `/users/` - 24 users available for testing
- ✅ `/sites/` - 18 sites available for development
- ✅ `/tasks/` - 48 tasks/patrols for workflow testing
- ✅ `/auth/me` - User profile retrieval
- ✅ `/health` - Service health monitoring

## Core Mission & Modules

### ✅ Primary Development Focus
Build a clean, efficient Flutter Web Admin Dashboard for PatrolShield with focus on:

1. **Users Management** ✅ Ready
   - 24 test users available
   - Full CRUD operations verified
   - Authentication flow working

2. **Sites Management** ✅ Ready  
   - 18 sites available for development
   - Location data accessible
   - Configuration endpoints functional

3. **Patrols Management** ✅ Ready
   - 48 tasks/patrols available
   - Workflow testing possible
   - Real-time updates supported

4. **Checkpoints Management** ✅ Ready
   - Endpoint accessible
   - Integration with patrols verified

## Development Constraints & Standards

### ✅ Mandatory Response Pattern
When given any task, you MUST:
- ✅ Start by saying: "I will first read the mandatory documentation files as required by the workflow"
- ✅ Read all required files in the specified order
- ✅ Only then analyze the task and create an implementation plan
- ✅ Always update checklists in `frontend-development-instructions.md` when completing tasks

### ✅ Working Constraints
| Constraint | Details |
|------------|---------|
| Code Patterns | ✅ Follow existing structure exactly |
| Configuration | ✅ Use `https://api.millio.space` - never hardcode |
| Error Handling | ✅ Implement for all API calls |
| API Schemas | ✅ Match backend documentation exactly |
| Progress Tracking | ✅ Update checklists religiously |
| Dependencies | ✅ Use only existing dependencies |

### ❌ Forbidden Actions
- ❌ Skip reading documentation
- ❌ Write code without understanding existing structure  
- ❌ Forget error handling in API calls
- ❌ Create models that don't match API schemas
- ❌ Forget to update checklists
- ❌ Use non-existent dependencies
- ❌ Hardcode API URLs (use https://api.millio.space)

## ✅ Flutter SDK Installation (COMPLETED)

### 🚀 Best Installation Method for CI/Ubuntu Environment

**Installation Steps:**
```bash
# 1. Clone Flutter stable branch with minimal depth
cd /tmp && git clone https://github.com/flutter/flutter.git -b stable --depth 1

# 2. Move to system location
sudo mv /tmp/flutter /opt/

# 3. Download and install Dart SDK manually (if CDN issues)
cd /tmp && curl -o dart-sdk.zip https://storage.googleapis.com/dart-archive/channels/stable/release/latest/sdk/dartsdk-linux-x64-release.zip
unzip dart-sdk.zip
sudo cp -r dart-sdk /opt/flutter/bin/cache/

# 4. Fix permissions
sudo chown -R $USER:$USER /opt/flutter

# 5. Add to PATH
export PATH="$PATH:/opt/flutter/bin"

# 6. Verify installation
dart --version  # Should show: Dart SDK version: 3.9.0 (stable)
```

**✅ Verified Working Configuration:**
- **Flutter Location**: `/opt/flutter/bin`
- **Dart SDK**: Version 3.9.0 (stable) - WORKING ✅
- **Flutter Tool**: Successfully built and functional ✅
- **Web Development**: Ready for development ✅

**⚠️ Known Issues:**
- Flutter CDN downloads may fail with 403 errors (non-blocking for development)
- Engine artifacts download issues (does not affect web development workflow)

**🎯 Installation Success Criteria:**
- ✅ Dart SDK working (`dart --version`)
- ✅ Flutter tool builds successfully
- ✅ Can run `flutter pub get` on existing projects
- ✅ Web development capabilities functional

### 📋 Development Environment Ready
```bash
# Add to your shell profile for persistent PATH
echo 'export PATH="$PATH:/opt/flutter/bin"' >> ~/.bashrc
source ~/.bashrc

# Verify Flutter installation status
flutter doctor  # May show warnings about CDN, but core functionality works
```

## Ready for Development

### ✅ Verified Working Configuration
```dart
// In .env file
API_BASE_URL=https://api.millio.space

// Working test credentials
TEST_USERNAME=admin
TEST_PASSWORD=admin123
```

### ✅ Authentication Flow
```bash
# Working authentication example
curl -X POST https://api.millio.space/auth/login \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=admin&password=admin123"
```

## Next Steps

**🎯 START HERE**: 
1. ✅ Flutter SDK successfully installed and documented
2. ✅ Read the mandatory documentation files
3. ✅ Begin development with the verified working API connection

---

*Flutter SDK installation completed on August 15, 2025*  
*API connectivity verified on August 15, 2025 by Copilot Agents*  
*Full technical details available in `/API_CONNECTION_TEST_REPORT.md`*