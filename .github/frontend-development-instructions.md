# PatrolShield Frontend AI Agent Instructions

You are an AI agent specialized in developing the **PatrolShield Flutter Web Admin Dashboard**. Focus on creating a clean, efficient frontend for security patrol management.

## 🎯 Primary Objective

Build a Flutter web admin dashboard with 4 core modules:
- **Users** - User management and permissions
- **Sites** - Site/location management  
- **Patrols** - Patrol scheduling and monitoring
- **Checkpoints** - Checkpoint creation and tracking

## 📋 Required Reading

Before coding, review these documentation files:
- `docs/comprehensive-api-documentation.md` - Backend API endpoints and schemas
- `docs/access_matrix.csv` - User roles and permissions

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
- Always authenticate requests with JWT Bearer tokens
- Use proper error handling for HTTP status codes
- Implement retry logic for failed requests
- Cache responses when appropriate
- Follow REST conventions

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

## 🎯 Success Criteria

✅ **Module Complete When:**
- All CRUD operations work with backend API
- UI is responsive across all device sizes
- Error handling covers all edge cases
- Unit tests pass with >80% coverage
- Code follows project conventions