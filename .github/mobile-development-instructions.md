# Copilot Instructions for PatrolShield Flutter Mobile App Development

This file guides Copilot (and all contributors) to strictly follow the 
**PatrolShield Flutter Mobile Development Plan**. in 'flutter-mobile-development-roadmap.md' 
**No changes, omissions, or reinterpretations are permitted**—every detail, step, and dependency must be preserved and executed in the intended order.  
Use this checklist to track progress and ensure no task is missed or completed out of sequence.

## 📋 Required Reading

**IMPORTANT:** Before starting any Flutter mobile development work, you MUST read and understand the complete backend API capabilities documented in:

**`backend/docs/comprehensive-api-documentation.md`**

This comprehensive documentation covers:
- All 293+ backend API endpoints and their capabilities
- **Mobile API (v1)** - specifically optimized for Flutter mobile apps with:
  - Mobile-optimized authentication with extended 24-hour tokens
  - Lightweight response schemas (≤15 fields per object)
  - Flutter patrol management with GPS integration using geolocator
  - Flutter incident reporting with media capture using image_picker
  - Emergency/panic alert system with real-time broadcasting via web_socket_channel
  - Offline sync capabilities using sqflite and conflict resolution
  - Flutter performance monitoring with device performance metrics
- Real-time communication via WebSocket for live updates
- File management for evidence and media handling
- GPS tracking and location services with background processing
- Authentication and security mechanisms with flutter_secure_storage

Understanding these backend capabilities is essential for proper Flutter mobile app integration and optimal feature implementation.

## 🎯 Flutter Choice Rationale

**Why Flutter for Mobile:**
- **Superior Real-time Performance**: Flutter's widget tree rebuilds efficiently with WebSocket updates using StreamBuilder
- **Unified Codebase**: Share models, services, and widgets between web admin and mobile apps
- **Excellent Native Integration**: Direct access to platform APIs (GPS, Camera, NFC) through platform channels
- **Outstanding Animation**: Flutter's animation system perfect for real-time location tracking and emergency alerts
- **Offline-First Architecture**: Built-in support for local databases and sync with sqflite and hive

---

## 📱 Essential Flutter Packages for PatrolShield Mobile

### Core Flutter Packages
- **dio**: HTTP client for API communication with interceptors
- **riverpod**: State management with dependency injection
- **go_router**: Declarative routing with type-safe navigation
- **flutter_secure_storage**: Secure storage for tokens and credentials
- **hive**: Lightweight local database for caching and preferences
- **sqflite**: SQLite database for complex offline data storage

### Security & Authentication Packages
- **local_auth**: Biometric authentication (fingerprint, face ID)
- **crypto**: Encryption and hashing utilities
- **dio_certificate_pinning**: SSL certificate pinning for API security
- **flutter_jailbreak_detection**: Anti-tampering and security checks

### Location & Maps Packages
- **geolocator**: GPS location services and background tracking
- **flutter_map**: Interactive maps with custom markers and routes
- **connectivity_plus**: Network connectivity monitoring
- **workmanager**: Background task scheduling for location tracking

### Real-Time & Communication Packages
- **web_socket_channel**: WebSocket connections for real-time updates
- **firebase_messaging**: Push notifications and FCM integration
- **flutter_local_notifications**: Local notifications and alerts
- **stream_chat_flutter**: Real-time chat and communication features

### Media & Scanning Packages
- **camera**: Camera control and photo/video capture
- **image_picker**: Gallery and camera image selection
- **qr_code_scanner**: QR code and barcode scanning
- **nfc_manager**: NFC tag reading and writing
- **document_scanner_flutter**: Document scanning and OCR

### Utility & Performance Packages
- **cached_network_image**: Image caching and optimization
- **photo_manager**: Photo gallery management and metadata
- **battery_plus**: Battery status monitoring
- **firebase_performance**: Performance monitoring and analytics
- **excel**: Excel file generation for reports

---

## 🚦 Strict Execution Rules

- **NO changes or shortcuts:** Implement each step as written.
- **NO skipping:** Do not move to the next step until the current one is complete and checked off.
- **NO reordering:** Respect all dependencies and task order.
- **NO context loss:** Always refer back to the full plan for rationale and detail.
- **Checklist discipline:** Update the checklist below immediately after completing or merging each task/PR.
- **Documentation:** Every code change must reference the exact step(s) from the plan in commit messages and PR descriptions.

---

## 📋 Flutter Mobile Development Plan Checklist

> **Mark each box `[x]` only when the corresponding task is complete, reviewed, and merged. Use `[ ]` for incomplete tasks.  
> All tasks must be checked before project completion.**

### Phase 1: Flutter Mobile Foundation & Core Architecture (Weeks 1-3)

#### Week 1: Development Environment & Project Setup

- [ ] **Day 1–2: Flutter Technology Stack & Project Initialization**
    - [ ] Initialize Flutter project with proper folder structure
    - [ ] Configure development environment (Android Studio, Xcode, VS Code)
    - [ ] Set up version control and CI/CD pipeline with codemagic/github_actions
    - [ ] Configure essential Flutter packages (dio, riverpod, go_router)
    - [ ] Deliverables: Flutter project initialized, dev environment, CI/CD setup

- [ ] **Day 3–5: Core Architecture & Navigation**
    - [ ] Implement navigation structure with go_router
    - [ ] Set up state management with Riverpod/Bloc
    - [ ] Create API service layer with Dio HTTP client
    - [ ] Implement error handling with custom exceptions
    - [ ] Deliverables: Navigation, state management, API layer, error handling

#### Week 2: Authentication & Offline Capabilities

- [ ] **Day 1–3: Flutter Authentication System**
    - [ ] Implement login/logout with local_auth biometric authentication
    - [ ] Create secure token storage with flutter_secure_storage
    - [ ] Build automatic token refresh mechanism
    - [ ] Implement device registration and firebase_messaging push notifications
    - [ ] Deliverables: Complete auth system, biometric login, push setup

- [ ] **Day 4–5: Offline Data Storage & Sync**
    - [ ] Set up local database with sqflite/drift
    - [ ] Create offline data caching with hive for preferences
    - [ ] Implement data synchronization service
    - [ ] Build conflict resolution system for offline data
    - [ ] Deliverables: Offline storage, sync service, conflict resolution

#### Week 3: Location Services & Emergency Features

- [ ] **Day 1–3: GPS & Location Tracking**
    - [ ] Implement location services with geolocator package
    - [ ] Create geofencing with geolocator for site boundaries
    - [ ] Build location tracking background service
    - [ ] Implement location accuracy validation
    - [ ] Deliverables: GPS tracking, geofencing, background location, accuracy validation

- [ ] **Day 4–5: Emergency & Panic Alert System**
    - [ ] Build panic button with emergency_dialer functionality
    - [ ] Implement emergency escalation workflow
    - [ ] Create real-time alert broadcasting with web_socket_channel
    - [ ] Add emergency contact management
    - [ ] Deliverables: Panic system, escalation, real-time alerts, emergency contacts

---

### Phase 2: Core Security Features & Real-Time Communication (Weeks 4-6)

#### Week 4: Incident Management & Reporting

- [ ] **Day 1–3: Incident Creation & Documentation**
    - [ ] Build incident creation form with form validation
    - [ ] Implement multimedia evidence capture (camera, image_picker)
    - [ ] Create incident categorization and severity levels
    - [ ] Build incident workflow management
    - [ ] Deliverables: Incident forms, multimedia capture, categorization, workflow

- [ ] **Day 4–5: Incident Tracking & Updates**
    - [ ] Implement incident status tracking
    - [ ] Create incident update notifications
    - [ ] Build incident search and filtering
    - [ ] Add incident reporting and analytics
    - [ ] Deliverables: Status tracking, notifications, search/filter, reporting

#### Week 5: Patrol Management & Checkpoint System

- [ ] **Day 1–3: Patrol Route & Task Management**
    - [ ] Create patrol route navigation with flutter_map
    - [ ] Implement task assignment and completion
    - [ ] Build patrol progress tracking
    - [ ] Add patrol route optimization
    - [ ] Deliverables: Route navigation, task management, progress tracking, optimization

- [ ] **Day 4–5: Checkpoint Verification System**
    - [ ] Implement QR/NFC checkpoint scanning with qr_code_scanner
    - [ ] Create checkpoint verification workflow
    - [ ] Build checkpoint status reporting
    - [ ] Add checkpoint analytics and reporting
    - [ ] Deliverables: Checkpoint scanning, verification, status reporting, analytics

#### Week 6: Communication & Real-Time Features

- [ ] **Day 1–3: Real-Time Communication with WebSocket**
    - [ ] Implement WebSocket connection with web_socket_channel
    - [ ] Create real-time data synchronization
    - [ ] Build live location sharing with geolocator
    - [ ] Implement real-time notifications with flutter_local_notifications
    - [ ] Deliverables: WebSocket integration, real-time sync, live updates, notifications

- [ ] **Day 4–5: Push-to-Talk & Emergency Communication**
    - [ ] Implement push-to-talk functionality with flutter_sound
    - [ ] Create voice communication channels
    - [ ] Build encrypted messaging with crypto package
    - [ ] Implement emergency broadcasting system
    - [ ] Deliverables: PTT system, voice channels, secure messaging, emergency broadcast
    - [ ] Create evidence chain of custody tracking
    - [ ] Build document scanning and PDF generation
    - [ ] Implement evidence encryption and secure storage
    - [ ] Deliverables: Evidence management, document scanning, secure storage

#### Week 6: Emergency Features & Communication

- [ ] **Day 1–3: Panic Alert & Emergency System**
    - [ ] Implement panic button with one-touch activation
    - [ ] Create emergency alert broadcasting
    - [ ] Build automatic location sharing during emergencies
    - [ ] Implement emergency contact integration
    - [ ] Deliverables: Panic system, emergency broadcasting, auto-location

- [ ] **Day 4–5: Communication & Walkie-Talkie**
    - [ ] Implement push-to-talk (PTT) functionality
    - [ ] Create voice communication channels
    - [ ] Build text messaging with encryption
    - [ ] Implement group communication features
    - [ ] Deliverables: PTT system, voice channels, secure messaging

---

### Phase 3: Advanced Flutter Features & Media Management (Weeks 7-9)

#### Week 7: Advanced Camera & Media Features

- [ ] **Day 1–3: Enhanced Media Capture with Flutter**
    - [ ] Implement advanced camera controls with camera package
    - [ ] Create image editing and annotation with photo_manager
    - [ ] Build video recording with camera and video_player
    - [ ] Implement automatic image enhancement and compression
    - [ ] Deliverables: Advanced camera, image editing, video recording, compression

- [ ] **Day 4–5: Media Management & Evidence Chain**
    - [ ] Create evidence photo management with metadata
    - [ ] Build evidence chain of custody tracking
    - [ ] Implement document scanning with cunning_document_scanner
    - [ ] Add PDF generation with pdf package
    - [ ] Deliverables: Evidence management, document scanning, PDF generation

#### Week 8: Offline Capabilities & Data Optimization

- [ ] **Day 1–3: Enhanced Offline Support**
    - [ ] Implement complete offline mode with connectivity_plus
    - [ ] Create offline patrol capability with local storage
    - [ ] Build offline incident reporting with sync queue
    - [ ] Implement offline map caching with cached_network_image
    - [ ] Deliverables: Full offline mode, offline patrols, cached maps, sync queue

- [ ] **Day 4–5: Performance & Battery Optimization**
    - [ ] Implement data compression and optimization
    - [ ] Create intelligent sync scheduling with workmanager
    - [ ] Build battery optimization with battery_plus monitoring
    - [ ] Implement performance monitoring with firebase_performance
    - [ ] Deliverables: Data optimization, sync scheduling, battery efficiency, monitoring

#### Week 9: Advanced Scanning & Real-Time Features

- [ ] **Day 1–3: Multi-Format Scanning with Flutter**
    - [ ] Implement QR/barcode scanning with qr_code_scanner
    - [ ] Create NFC tag reading/writing with nfc_manager
    - [ ] Build document scanning with document_scanner_flutter
    - [ ] Implement scanning history and validation
    - [ ] Deliverables: Multi-format scanning, NFC support, document scanning, validation

- [ ] **Day 4–5: Real-Time Monitoring & Live Updates**
    - [ ] Create live patrol status broadcasting
    - [ ] Implement checkpoint visit notifications
    - [ ] Build incident update broadcasting with stream_chat_flutter
    - [ ] Create supervisor notification system
    - [ ] Deliverables: Live monitoring, status broadcasting, chat integration, notifications

---

### Phase 4: Flutter Production Features & Platform Integration (Weeks 10-12)

#### Week 10: Platform-Specific Flutter Features

- [ ] **Day 1–3: iOS-Specific Flutter Implementation**
    - [ ] Implement iOS widgets with home_widget
    - [ ] Create Apple Watch companion with flutter_apple_watch
    - [ ] Build iOS-specific security with local_auth
    - [ ] Implement Siri integration with speech_to_text
    - [ ] Deliverables: iOS widgets, Watch app, iOS security, Siri integration

- [ ] **Day 4–5: Android-Specific Flutter Implementation**
    - [ ] Create Android widgets with home_widget
    - [ ] Implement Android Auto integration with android_intent_plus
    - [ ] Build notification management with flutter_local_notifications
    - [ ] Create Android-specific security features
    - [ ] Deliverables: Android widgets, Auto integration, notification management, security

#### Week 11: Flutter Security & Compliance

- [ ] **Day 1–3: Security Hardening with Flutter**
    - [ ] Implement app-level encryption with crypto package
    - [ ] Create certificate pinning with dio_certificate_pinning
    - [ ] Build anti-tampering with flutter_jailbreak_detection
    - [ ] Implement secure backup with flutter_secure_storage
    - [ ] Deliverables: App encryption, certificate pinning, anti-tampering, secure backup

- [ ] **Day 4–5: Compliance & Audit Features**
    - [ ] Implement audit logging for all actions
    - [ ] Create compliance reporting with excel package
    - [ ] Build data retention and deletion policies
    - [ ] Implement privacy controls and GDPR compliance
    - [ ] Deliverables: Audit logging, compliance features, privacy controls, GDPR

#### Week 12: Flutter Testing & Production Deployment

- [ ] **Day 1–3: Flutter Testing & Quality Assurance**
    - [ ] Implement comprehensive unit testing with flutter_test
    - [ ] Create integration testing with integration_test
    - [ ] Build widget testing and golden testing
    - [ ] Implement performance testing with flutter_driver
    - [ ] Deliverables: Testing suite, widget tests, performance testing, golden tests

- [ ] **Day 4–5: Flutter App Store Deployment**
    - [ ] Prepare app store listings and metadata
    - [ ] Implement app store optimization (ASO)
    - [ ] Create beta testing with Firebase App Distribution
    - [ ] Submit for app store review and approval
    - [ ] Deliverables: App store submission, beta testing, Firebase distribution, ASO

---

## 📈 Success Gate & Review

- All boxes must be marked as `[x]` before project is considered production-ready.
- At each phase gate (weeks 3, 6, 9, 12), conduct a full review, demo, and checklist audit.

---

**Always refer to the full mobile development plan for rationale, dependencies, and deliverables.**  
**No context loss or deviation is permitted. Update this checklist religiously.**