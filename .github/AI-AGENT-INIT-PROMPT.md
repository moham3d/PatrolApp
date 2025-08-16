🚀 PatrolShield Frontend Build – Sequential Agent  
**MANDATORY:**  

Before coding, read these files carefully:  
- `docs/comprehensive-api-documentation.md` (all backend endpoints)  
- `.github/frontend-development-instructions.md` (rules/checklist)  
- `.github/copilot-instructions.md` (detailed specs)  

**Checklist Discipline:**  
1. Open `.github/frontend-development-instructions.md`  
2. Find the first `[ ]` unchecked item in the checklist  (MANDATORY)
3. Read the related section in `.copilot-instructions.md` for details  

**Implement Sequentially:**  
- Build the feature using real backend integration—never mock data  
- API-first: Write the API service layer before UI  
- Use only real backend endpoints and live JWT authentication  

**Quality Gates:**  
- This is flutter app, You can't install flutter except by downloading flutter via GitHub releases.
- Every feature must connect to the backend and use real data  
- Authentication must use real JWT tokens (`/auth/login`)  
- WebSocket features: use real backend WebSocket  
- Real error handling with actual backend errors  
- Add component documentation and unit tests  


**Completion:**  
- Test each feature with the real backend  
- The agent MUST mark the corresponding checklist item as `[x]` immediately after finishing each task, to prevent repeated work in new sessions.  
- Update the checklist immediately  
- Move to the next unchecked item—never skip or re-order  
**Commits:**  
- Commit messages:  
  `[FRONTEND-PHASE-X] Component: Description`  
  Example:  
  `[FRONTEND-PHASE-1] Auth: Implement JWT authentication with backend`  

**Reviews:**  
**Critical Rules**  
- NO mock data: Only real database/API  
- NO skipping: Complete items in order  
- NO shortcuts: Follow every step  
- ALWAYS reference the instruction and roadmap files  
- REAL API/WSS integration required for all features  

Success = Every feature uses real backend, real data, JWT auth, error handling, TypeScript interfaces, and passes live tests.

**Start:**  
Open the checklist and begin with the first unchecked item. Follow these steps for every feature.

**Finish:**
Mark checklist item `[x]` only after real integration and testing

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

Flutter & Dart CI/Ubuntu Install (Stable, Minimal)
Ready for Development:
# 1. Clone Flutter (stable, minimal)
git clone https://github.com/flutter/flutter.git -b stable --depth 1 /tmp/flutter
sudo mv /tmp/flutter /opt/

# 2. Install Dart SDK (manual fallback)
cd /tmp
curl -o dart-sdk.zip https://storage.googleapis.com/dart-archive/channels/stable/release/latest/sdk/dartsdk-linux-x64-release.zip
unzip dart-sdk.zip
sudo cp -r dart-sdk /opt/flutter/bin/cache/

# 3. Permissions & PATH
sudo chown -R $USER:$USER /opt/flutter
echo 'export PATH="$PATH:/opt/flutter/bin"' >> ~/.bashrc
source ~/.bashrc

# 4. Verify
dart --version      # Should show Dart 3.9.0 (stable)
flutter doctor      # Ignore CDN warnings if web works