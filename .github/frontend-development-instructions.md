# Copilot Instructions for PatrolShield Flutter Web Admin Dashboard Development

This file guides Copilot (and all contributors) to strictly follow the 
**PatrolShield Flutter Web Dashboard Development Plan**. in 'flutter-web-development-roadmap.md' 
**No changes, omissions, or reinterpretations are permitted**—every detail, step, and dependency must be preserved and executed in the intended order.  
Use this checklist to track progress and ensure no task is missed or completed out of sequence.

## 📋 Required Reading

**IMPORTANT:** Before starting any Flutter web development work, you MUST read and understand the complete backend API capabilities documented in:

**`docs/comprehensive-api-documentation.md`**

This comprehensive documentation covers:
- All 293+ backend API endpoints and their capabilities
- Authentication and authorization mechanisms
- Request/response schemas and data structures
- Mobile API (v1) optimized endpoints (compatible with Flutter)
- Real-time communication via WebSocket (Flutter web_socket_channel)
- File management and media handling
- Error handling and rate limiting
- Integration capabilities and webhooks

Understanding these backend capabilities is essential for proper Flutter web integration and real-time feature implementation.

## 🎯 Flutter Choice Rationale

**Why Flutter for Frontend:**
- **Superior Real-time UI Performance**: Flutter's declarative UI rebuilds efficiently with WebSocket updates
- **Unified Codebase**: Share widgets, models, and business logic between web admin and mobile apps
- **Excellent WebSocket Support**: Native `web_socket_channel` package with automatic reconnection
- **Real-time Animation**: Flutter's animation system perfect for live monitoring dashboards
- **Cross-platform Consistency**: Same UI behavior across web, iOS, and Android

---

## 🚦 Strict Execution Rules

- **NO changes or shortcuts:** Implement each step as written.
- **NO skipping:** Do not move to the next step until the current one is complete and checked off.
- **NO reordering:** Respect all dependencies and task order.
- **NO context loss:** Always refer back to the full plan for rationale and detail.
- **Checklist discipline:** Update the checklist below immediately after completing or merging each task/PR.
- **Documentation:** Every code change must reference the exact step(s) from the plan in commit messages and PR descriptions.
- **No Hardcoded Values:** Always use backend API endpoints, environment variables, or configuration files for dynamic values. Hardcoded values are not allowed.
---

## 📋 Flutter Web Development Plan Checklist

> **Mark each box `[x]` only when the corresponding task is complete, reviewed, and merged. Use `[ ]` for incomplete tasks.  
> All tasks must be checked before project completion.**

### Phase 1: Flutter Web Foundation & Architecture (Weeks 1-3)

#### Week 1: Development Environment & Core Architecture

- [ ] **Day 1–2: Flutter Web Development Environment Setup**
    - [ ] Install Flutter SDK with web support enabled
    - [ ] Configure Flutter web project with responsive design
    - [ ] Set up state management (Riverpod/Bloc/Provider)
    - [ ] Configure environment configuration (flutter_dotenv)
    - [ ] Deliverables: Flutter web project, state management, env setup

- [ ] **Day 3–5: Core Architecture & HTTP Client**
    - [ ] Implement Dio HTTP client with interceptors
    - [ ] Create API service layer with automatic token refresh
    - [ ] Set up error handling and exception management
    - [ ] Implement authentication state management
    - [ ] Deliverables: HTTP client, API layer, error handling, auth flow

#### Week 2: Authentication & Authorization

- [ ] **Day 1–3: Flutter Authentication System**
    - [ ] Enhanced login/logout screens with form validation
    - [ ] Implement JWT token management with flutter_secure_storage
    - [ ] Create protected route guards and navigation
    - [ ] Build password reset and account management
    - [ ] Deliverables: Complete auth system, token handling, protected routes

- [ ] **Day 4–5: Role-Based Access Control**
    - [ ] Implement permission checking with custom widgets
    - [ ] Create role-based widget rendering system
    - [ ] Build admin, supervisor, guard role interfaces
    - [ ] Implement permission-based navigation drawer
    - [ ] Deliverables: RBAC system, role widgets, permission navigation
#### Week 3: UI Foundation & Design System

- [ ] **Day 1–2: Flutter Material Design System**
    - [ ] Create comprehensive Flutter widget library
    - [ ] Implement Material Design 3 theme system
    - [ ] Build reusable form widgets with validation
    - [ ] Create consistent buttons, cards, modal widgets
    - [ ] Deliverables: Widget library, Material theme, form widgets

- [ ] **Day 3–5: Responsive Layout & Navigation**
    - [ ] Implement responsive navigation with NavigationRail/Drawer
    - [ ] Create header with user profile and notification badges
    - [ ] Build breadcrumb navigation system
    - [ ] Implement theme switching (light/dark mode)
    - [ ] Deliverables: Responsive navigation, header system, theming

---

### Phase 2: Core Dashboard Features (Weeks 4-6)

#### Week 4: Live Monitoring Dashboard

- [ ] **Day 1–3: Real-time Monitoring Interface**
    - [ ] Implement WebSocket connection using web_socket_channel
    - [ ] Create live patrol tracking with flutter_map integration
    - [ ] Build real-time guard location monitoring with StreamBuilder
    - [ ] Implement live alert feed with push notifications
    - [ ] Deliverables: Real-time dashboard, live tracking, alert system

- [ ] **Day 4–5: System Health & Status Monitoring**
    - [ ] Create system health monitoring dashboard with fl_chart
    - [ ] Implement performance metrics visualization
    - [ ] Build service status indicators with custom animations
    - [ ] Create real-time statistics widgets
    - [ ] Deliverables: Health monitoring, metrics dashboard, status indicators

#### Week 5: Incident & Emergency Management

- [ ] **Day 1–3: Flutter Incident Management Interface**
    - [ ] Create incident creation forms with custom validators
    - [ ] Implement incident timeline with timeline_tile package
    - [ ] Build incident assignment interface with dropdown selectors
    - [ ] Create incident reporting with pdf generation
    - [ ] Deliverables: Incident management, status tracking, reporting

- [ ] **Day 4–5: Emergency & Panic Alert System**
    - [ ] Implement panic alert monitoring with real-time updates
    - [ ] Create emergency response workflow with stepper widgets
    - [ ] Build alert acknowledgment with confirmation dialogs
    - [ ] Implement emergency contact management interface
    - [ ] Deliverables: Emergency dashboard, response workflow, alert tracking

#### Week 6: Patrol & Checkpoint Management

- [ ] **Day 1–3: Flutter Patrol Management Interface**
    - [ ] Create patrol scheduling with calendar widgets
    - [ ] Implement patrol route planning with interactive maps
    - [ ] Build patrol status monitoring with live tiles
    - [ ] Create patrol report generation with data tables
    - [ ] Deliverables: Patrol management, route planning, status monitoring

- [x] **Day 4–5: Checkpoint & Route Optimization**
    - [x] Implement checkpoint management interface
    - [x] Create route optimization visualization
    - [x] Build checkpoint visit tracking and validation
    - [x] Implement QR code and NFC management interface
    - [x] Deliverables: Checkpoint management, route optimization, visit tracking

---

### Phase 3: Advanced Features & Analytics (Weeks 7-9)

#### Week 7: Analytics & Reporting Dashboard

- [x] **Day 1–3: Analytics Engine Integration** ✅ **COMPLETED**
    - [x] Implement analytics data visualization with Chart.js/D3
    - [x] Create patrol efficiency analytics dashboard
    - [x] Build incident trend analysis interface
    - [x] Implement guard performance metrics dashboard
    - [x] Deliverables: Analytics integration, efficiency dashboard, trend analysis

- [x] **Day 4–5: Report Generation & Export** ✅ **COMPLETED**
    - [x] Create custom report builder interface
    - [x] Implement PDF and CSV export functionality
    - [x] Build scheduled report management
    - [x] Create report template management system
    - [x] Deliverables: Report builder, export functionality, template system

#### Week 8: User & Site Management

- [x] **Day 1–3: User Management Interface** ✅ **COMPLETED**
    - [x] Create comprehensive user management dashboard
    - [x] Implement user profile and permission management
    - [x] Build user activity tracking and audit logs
    - [x] Create bulk user operations interface
    - [x] Deliverables: User management, profile management, activity tracking

- [x] **Day 4–5: Site & Location Management**
    - [x] Implement site management interface with map integration
    - [x] Create location and zone management system
    - [x] Build site-specific configuration interface
    - [x] Implement site analytics and performance tracking
    - [x] Deliverables: Site management, location system, site analytics

#### Week 9: Communication & Collaboration

- [x] **Day 1–3: Messaging & Communication System** ✅ **COMPLETED**
    ** Note: cotrun is installed and configured for real-time messaging ports listening-port=3478
and listening-port=3478**
    - [x] Implement real-time messaging interface
    - [x] Create notification management dashboard
    - [x] Build communication channels and groups
    - [x] Implement file sharing and media management
    - [x] Deliverables: Messaging system, notifications, communication channels

- [x] **Day 4–5: Walkie-Talkie & PTT Integration** ✅ **COMPLETED**
    - [x] Create push-to-talk interface for web
    - [x] Implement audio communication management
    - [x] Build communication channel switching
    - [x] Create communication logs and history
    - [x] Deliverables: PTT interface, audio management, communication logs

---

### Phase 4: Performance & Production Readiness (Weeks 10-12)

#### Week 10: Performance Optimization

- [x] **Day 1–3: Frontend Performance Optimization** ✅ **COMPLETED**
    - [x] Implement code splitting and lazy loading
    - [x] Optimize bundle size and asset loading
    - [x] Create efficient data fetching with React Query
    - [x] Implement virtual scrolling for large datasets
    - [x] Deliverables: Performance optimization, code splitting, efficient data fetching

- [x] **Day 4–5: Caching & State Optimization**
    - [x] Implement client-side caching strategies
    - [x] Optimize state management for performance
    - [x] Create offline support and PWA features
    - [x] Implement background data synchronization
    - [x] Deliverables: Caching strategy, state optimization, PWA features

#### Week 11: Testing & Quality Assurance

- [x] **Day 1–3: Testing Implementation**
    - [x] Create comprehensive unit tests for components
    - [x] Implement integration tests for critical workflows
    - [x] Build end-to-end tests for user journeys
    - [x] Create visual regression testing setup
    - [x] Deliverables: Testing suite, workflow tests, visual testing

- [x] **Day 4–5: Accessibility & Internationalization**
    - [x] Implement accessibility (WCAG 2.1) compliance
    - [x] Create comprehensive internationalization (i18n)
    - [x] Build right-to-left (RTL) language support
    - [x] Implement keyboard navigation and screen reader support
    - [x] Deliverables: Accessibility compliance, i18n support, RTL support

#### Week 12: Production Deployment & Monitoring

- [x] **Day 1–3: Build & Deployment Optimization** ✅ **COMPLETED**
    - [x] Optimize production build configuration
    - [x] Implement CI/CD pipeline for automated deployment
    - [x] Create Docker containerization for frontend
    - [x] Set up CDN and static asset optimization
    - [x] Deliverables: Production build, CI/CD pipeline, containerization

- [x] **Day 4–5: Monitoring & Analytics** ✅ **COMPLETED**
    - [x] Implement frontend error tracking and monitoring
    - [x] Create user analytics and behavior tracking
    - [x] Build performance monitoring dashboard
    - [x] Set up alerts for frontend issues
    - [x] Deliverables: Error tracking, analytics, performance monitoring

---

## 📈 Success Gate & Review

- All boxes must be marked as `[x]` before project is considered production-ready.
- At each phase gate (weeks 3, 6, 9, 12), conduct a full review, demo, and checklist audit.

---

**Always refer to the full frontend development plan for rationale, dependencies, and deliverables.**  
**No context loss or deviation is permitted. Update this checklist religiously.**