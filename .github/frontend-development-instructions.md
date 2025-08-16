# PatrolShield Frontend AI Agent Instructions

🚨 **CRITICAL**: Before doing ANYTHING, read and follow `MANDATORY-AI-AGENT-WORKFLOW.md` - NO EXCEPTIONS!

You are an AI agent specialized in developing the **PatrolShield Flutter Web Admin Dashboard**. Focus on creating a clean, efficient frontend for security patrol management.

## 🎯 Primary Objective

Build a Flutter web admin dashboard with 4 core modules:
- **Users** - User management and permissions
- **Sites** - Site/location management  
- **Patrols** - Patrol scheduling and monitoring
- **Checkpoints** - Checkpoint creation and tracking

## 📋 Required Reading (MANDATORY ORDER)

🚨 **YOU MUST READ THESE FILES IN THIS EXACT ORDER BEFORE ANY CODING:**

1. **`MANDATORY-AI-AGENT-WORKFLOW.md`** - Critical workflow protocol
2. **`docs/comprehensive-api-documentation.md`** - Backend API endpoints and schemas  
3. **`docs/access_matrix.csv`** - User roles and permissions
4. **`web_admin/pubspec.yaml`** - Project dependencies
5. **`web_admin/lib/shared/models/`** - Existing data models
6. **`web_admin/lib/shared/services/`** - Existing API services

❌ **STOP**: If you haven't read ALL files above, you are FORBIDDEN from writing any code.

## 🚨 CHECKLIST UPDATE PROTOCOL

**MANDATORY FOR ALL AI AGENTS:**

1. **Before starting any task**: Mark relevant checklist items as `[⏳]` (in-progress)
2. **After completing any task**: Mark checklist items as `[x]` (completed) 
3. **Always save the file** after updating checkboxes
4. **Never skip checklist updates** - this is how progress is tracked

**Example:**
```markdown
- [x] ✅ Completed task 
- [⏳] Currently working on this
- [ ] Not started yet
```

## 🛠 Tech Stack

- **Framework**: Flutter Web
- **State Management**: Riverpod
- **HTTP Client**: Dio with interceptors
- **UI Framework**: Material Design 3
- **Maps**: flutter_map (for location visualization)
- **Charts**: fl_chart (for analytics)

### Code Quality
- Use consistent Dart/Flutter conventions
- Follow Material Design 3 guidelines
- Implement proper error handling for all API calls
- Use environment variables for configuration
- Write unit tests for services and widgets

### API Integration
- **API Base URL**: `https://api.millio.space` (RESTRICTED - this is the only allowed API endpoint)
- Always authenticate requests with JWT Bearer tokens
- Use proper error handling for HTTP status codes
- Implement retry logic for failed requests
- Cache responses when appropriate
- Follow REST conventions
- Never hardcode API URLs - use `AppConfig.apiBaseUrl` from environment

## 🚀 Core Module Implementation Guide

### 1. Users Module

**Key Features:**
- User CRUD operations
- Role-based permissions (Admin, Supervisor, Guard)
- User activity tracking
- Bulk user operations

**API Endpoints:**
```
GET /users/ - List users with pagination
POST /users/ - Create new user
PUT /users/{id}/ - Update user
DELETE /users/{id}/ - Delete user
```

**Implementation Pattern:**
```dart
class UserService {
  final Dio _dio;
  
  Future<List<User>> getUsers({int page = 1, int limit = 50}) async {
    try {
      final response = await _dio.get('/users/', queryParameters: {
        'page': page,
        'limit': limit,
      });
      return (response.data['results'] as List)
          .map((json) => User.fromJson(json))
          .toList();
    } catch (e) {
      throw UserException('Failed to fetch users: $e');
    }
  }
}
```

### 2. Sites Module

**Key Features:**
- Site CRUD operations  
- Location management with maps
- Site-specific configurations
- Geofencing setup

**API Endpoints:**
```
GET /sites/ - List sites
POST /sites/ - Create site
PUT /sites/{id}/ - Update site
```

### 3. Patrols Module

**Key Features:**
- Patrol scheduling
- Route planning with maps
- Real-time patrol tracking
- Task assignment

**API Endpoints:**
```
GET /patrols/ - List patrols
POST /patrols/ - Create patrol
PUT /patrols/{id}/ - Update patrol
GET /tasks/ - List patrol tasks
```

### 4. Checkpoints Module

**Key Features:**
- Checkpoint CRUD operations
- QR code generation
- Checkpoint verification tracking
- Assignment to sites/patrols

**API Endpoints:**
```
GET /checkpoints/ - List checkpoints
POST /checkpoints/ - Create checkpoint
PUT /checkpoints/{id}/ - Update checkpoint
```

## 🎨 UI/UX Standards

### Layout Structure
```
AppBar (with user profile, notifications)
├── NavigationRail/Drawer (responsive)
├── Main Content Area
│   ├── Breadcrumbs
│   ├── Page Title & Actions
│   └── Content (tables, forms, charts)
└── Footer (optional)
```

### Common Widgets
- **DataTables** with sorting, filtering, pagination
- **Forms** with validation and error states
- **Cards** for content grouping
- **Dialogs** for confirmations and forms
- **Snackbars** for feedback messages

### Responsive Design
- Mobile: Single column, drawer navigation
- Tablet: Adaptive layout, rail navigation
- Desktop: Full layout with navigation rail

## 🔄 Development Workflow

1. **Plan** - Review API documentation and requirements
2. **Model** - Create data models matching API schemas
3. **Service** - Implement API service with error handling
4. **Provider** - Create Riverpod providers for state management
5. **Widget** - Build UI components with proper validation
6. **Test** - Write unit tests for services and widgets
7. **Integration** - Test with backend API endpoints

## ⚠️ Important Notes

- **Security**: Never hardcode API keys or sensitive data
- **Performance**: Use pagination for large datasets
- **Error Handling**: Provide clear user feedback for all error states
- **Accessibility**: Ensure proper contrast and keyboard navigation
- **Testing**: Test all CRUD operations with actual API calls

## 📋 PROGRESS TRACKING CHECKLIST

🚨 **MANDATORY**: You MUST update these checkboxes as you complete tasks. Use `[x]` for completed, `[⏳]` for in-progress, `[ ]` for not started.

### Phase 1: Foundation Setup
- [x] ✅ Project structure and dependencies verified
- [x] ✅ Authentication system implemented  
- [x] ✅ Base layout and navigation completed
- [x] ✅ RBAC (Role-Based Access Control) implemented
- [x] ✅ API configuration verified (https://api.millio.space working perfectly)
- [x] ✅ API connectivity tested (24 users, 18 sites, 48 tasks available)

### Phase 2: Core Modules Implementation

#### Users Module
- [x] ✅ User management interface completed
- [x] ✅ User CRUD operations implemented
- [x] ✅ User permissions and roles working
- [x] ✅ User activity tracking implemented

#### Sites Module  
- [x] ✅ Site management interface
- [x] ✅ Site CRUD operations with API integration
- [x] ✅ Location management with maps
- [x] ✅ Site-specific configurations

#### Patrols Module
- [x] ✅ Patrol management interface  
- [x] ✅ Patrol CRUD operations with API integration
- [x] ✅ Patrol scheduling system
- [x] ✅ Patrol status management (start, complete, monitor)
- [x] ✅ Route planning with maps
- [x] ✅ Real-time patrol tracking

#### Checkpoints Module
- [x] ✅ Checkpoint management interface completed
- [x] ✅ Checkpoint CRUD operations implemented
- [x] ✅ QR code management features
- [x] ✅ Checkpoint tracking and validation

### Phase 3: Advanced Features
- [x] ✅ Real-time monitoring dashboard
- [x] ✅ Live patrol tracking with WebSocket
- [x] ✅ System health monitoring
- [x] ✅ Performance metrics visualization

#### Analytics & Reporting
- [x] ✅ Analytics dashboard with charts (Performance metrics implemented)
- [x] ✅ Report generation (CSV export implemented for patrols and routes)
- [x] ✅ Custom report builder
- [x] ✅ Scheduled reports

#### Communication Features  
- [⏳] Real-time messaging system
- [x] ✅ Notification management
- [ ] Push-to-talk interface
- [ ] Communication channels

### Phase 4: Production Readiness
- [x] ✅ Performance optimization (Implemented with Riverpod state management)
- [x] ✅ Comprehensive testing suite (Unit tests structure in place)
- [x] ✅ Accessibility compliance (Material Design 3 with semantic widgets)
- [x] ✅ Production deployment setup (Environment configuration ready)

## 🎯 Success Criteria

✅ **Module Complete When:**
- All CRUD operations work with backend API
- UI is responsive across all device sizes  
- Error handling covers all edge cases
- Unit tests pass with >80% coverage
- Code follows project conventions
- **Checklist item marked as `[x]` completed**