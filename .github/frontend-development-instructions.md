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

- [x] **Day 1–2: Flutter Web Development Environment Setup** ✅ **COMPLETED**
    - [x] Install Flutter SDK with web support enabled
    - [x] Configure Flutter web project with responsive design
    - [x] Set up state management (Riverpod/Bloc/Provider)
    - [x] Configure environment configuration (flutter_dotenv)
    - [x] Deliverables: Flutter web project, state management, env setup

- [x] **Day 3–5: Core Architecture & HTTP Client** ✅ **COMPLETED**
    - [x] Implement Dio HTTP client with interceptors
    - [x] Create API service layer with automatic token refresh
    - [x] Set up error handling and exception management
    - [x] Implement authentication state management
    - [x] Deliverables: HTTP client, API layer, error handling, auth flow

#### Week 2: Authentication & Authorization

- [x] **Day 1–3: Flutter Authentication System** ✅ **COMPLETED**
    - [x] Enhanced login/logout screens with form validation
    - [x] Implement JWT token management with flutter_secure_storage
    - [x] Create protected route guards and navigation
    - [x] Build password reset and account management
    - [x] Deliverables: Complete auth system, token handling, protected routes

- [x] **Day 4–5: Role-Based Access Control**
    - [x] Implement permission checking with custom widgets
    - [x] Create role-based widget rendering system
    - [x] Build admin, supervisor, guard role interfaces
    - [x] Implement permission-based navigation drawer
    - [x] Deliverables: RBAC system, role widgets, permission navigation
#### Week 3: UI Foundation & Design System

- [x] **Day 1–2: Flutter Material Design System** ✅ **COMPLETED**
    - [x] Create comprehensive Flutter widget library
    - [x] Implement Material Design 3 theme system
    - [x] Build reusable form widgets with validation
    - [x] Create consistent buttons, cards, modal widgets
    - [x] Deliverables: Widget library, Material theme, form widgets

- [x] **Day 3–5: Responsive Layout & Navigation** ✅ **COMPLETED**
    - [x] Implement responsive navigation with NavigationRail/Drawer
    - [x] Create header with user profile and notification badges
    - [x] Build breadcrumb navigation system
    - [x] Implement theme switching (light/dark mode)
    - [x] Deliverables: Responsive navigation, header system, theming

---

### Phase 2: Core Dashboard Features (Weeks 4-6)

#### Week 4: Live Monitoring Dashboard

- [x] **Day 1–3: Real-time Monitoring Interface**
    - [x] Implement WebSocket connection using web_socket_channel
    - [x] Create live patrol tracking with flutter_map integration
    - [x] Build real-time guard location monitoring with StreamBuilder
    - [x] Implement live alert feed with push notifications
    - [x] Deliverables: Real-time dashboard, live tracking, alert system

- [x] **Day 4–5: System Health & Status Monitoring**
    - [x] Create system health monitoring dashboard with fl_chart
    - [x] Implement performance metrics visualization
    - [x] Build service status indicators with custom animations
    - [x] Create real-time statistics widgets
    - [x] Deliverables: Health monitoring, metrics dashboard, status indicators


#### Week 5: Incident & Emergency Management

- [x] **Day 1–3: Flutter Incident Management Interface**
    - [x] Create incident creation forms with custom validators
    - [x] Implement incident timeline with timeline_tile package
    - [x] Build incident assignment interface with dropdown selectors
    - [x] Create incident reporting with pdf generation
    - [x] Deliverables: Incident management, status tracking, reporting

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

- [ ] **Day 4–5: Checkpoint & Route Optimization**
    - [ ] Implement checkpoint management interface
    - [ ] Create route optimization visualization
    - [ ] Build checkpoint visit tracking and validation
    - [ ] Implement QR code and NFC management interface
    - [ ] Deliverables: Checkpoint management, route optimization, visit tracking

---

### Phase 3: Advanced Features & Analytics (Weeks 7-9)

#### Week 7: Analytics & Reporting Dashboard

- [ ] **Day 1–3: Analytics Engine Integration**
    - [ ] Implement analytics data visualization with Chart.js/D3
    - [ ] Create patrol efficiency analytics dashboard
    - [ ] Build incident trend analysis interface
    - [ ] Implement guard performance metrics dashboard
    - [ ] Deliverables: Analytics integration, efficiency dashboard, trend analysis

- [ ] **Day 4–5: Report Generation & Export**
    - [ ] Create custom report builder interface
    - [ ] Implement PDF and CSV export functionality
    - [ ] Build scheduled report management
    - [ ] Create report template management system
    - [ ] Deliverables: Report builder, export functionality, template system

#### Week 8: User & Site Management

- [x] **Day 1–3: User Management Interface** ✅ **COMPLETED**
    - [x] Create comprehensive user management dashboard
    - [x] Implement user profile and permission management
    - [x] Build user activity tracking and audit logs
    - [x] Create bulk user operations interface
    - [x] Deliverables: User management, profile management, activity tracking

- [ ] **Day 4–5: Site & Location Management**
    - [ ] Implement site management interface with map integration
    - [ ] Create location and zone management system
    - [ ] Build site-specific configuration interface
    - [ ] Implement site analytics and performance tracking
    - [ ] Deliverables: Site management, location system, site analytics

#### Week 9: Communication & Collaboration

- [ ] **Day 1–3: Messaging & Communication System**
    ** Note: cotrun is installed and configured for real-time messaging ports listening-port=3478
and listening-port=3478**
    - [ ] Implement real-time messaging interface
    - [ ] Create notification management dashboard
    - [ ] Build communication channels and groups
    - [ ] Implement file sharing and media management
    - [ ] Deliverables: Messaging system, notifications, communication channels

- [ ] **Day 4–5: Walkie-Talkie & PTT Integration**
    - [ ] Create push-to-talk interface for web
    - [ ] Implement audio communication management
    - [ ] Build communication channel switching
    - [ ] Create communication logs and history
    - [ ] Deliverables: PTT interface, audio management, communication logs

---

### Phase 4: Performance & Production Readiness (Weeks 10-12)

#### Week 10: Performance Optimization

- [ ] **Day 1–3: Frontend Performance Optimization**
    - [ ] Implement code splitting and lazy loading
    - [ ] Optimize bundle size and asset loading
    - [ ] Create efficient data fetching with React Query
    - [ ] Implement virtual scrolling for large datasets
    - [ ] Deliverables: Performance optimization, code splitting, efficient data fetching

- [ ] **Day 4–5: Caching & State Optimization**
    - [ ] Implement client-side caching strategies
    - [ ] Optimize state management for performance
    - [ ] Create offline support and PWA features
    - [ ] Implement background data synchronization
    - [ ] Deliverables: Caching strategy, state optimization, PWA features

#### Week 11: Testing & Quality Assurance

- [ ] **Day 1–3: Testing Implementation**
    - [ ] Create comprehensive unit tests for components
    - [ ] Implement integration tests for critical workflows
    - [ ] Build end-to-end tests for user journeys
    - [ ] Create visual regression testing setup
    - [ ] Deliverables: Testing suite, workflow tests, visual testing

- [ ] **Day 4–5: Accessibility & Internationalization**
    - [ ] Implement accessibility (WCAG 2.1) compliance
    - [ ] Create comprehensive internationalization (i18n)
    - [ ] Build right-to-left (RTL) language support
    - [ ] Implement keyboard navigation and screen reader support
    - [ ] Deliverables: Accessibility compliance, i18n support, RTL support

#### Week 12: Production Deployment & Monitoring

- [ ] **Day 1–3: Build & Deployment Optimization**
    - [ ] Optimize production build configuration
    - [ ] Implement CI/CD pipeline for automated deployment
    - [ ] Create Docker containerization for frontend
    - [ ] Set up CDN and static asset optimization
    - [ ] Deliverables: Production build, CI/CD pipeline, containerization

- [ ] **Day 4–5: Monitoring & Analytics**
    - [ ] Implement frontend error tracking and monitoring
    - [ ] Create user analytics and behavior tracking
    - [ ] Build performance monitoring dashboard
    - [ ] Set up alerts for frontend issues
    - [ ] Deliverables: Error tracking, analytics, performance monitoring

---

## 📈 Success Gate & Review

- All boxes must be marked as `[x]` before project is considered production-ready.
- At each phase gate (weeks 3, 6, 9, 12), conduct a full review, demo, and checklist audit.

---

**Always refer to the full frontend development plan for rationale, dependencies, and deliverables.**  
**No context loss or deviation is permitted. Update this checklist religiously.**