# ProsperShield API Documentation
**Version 1.0.0** | **For Flutter Frontend & Mobile App Development**

✅ **MOBILE API READY**: All Mobile API v1 endpoints (`/mobile/v1/*`) are fully implemented and ready for frontend integration.

## Table of Contents
1. [Authentication](#authentication)
2. [Mobile API v1](#mobile-api-v1)
3. [Core Endpoints](#core-endpoints)
4. [Real-time Features](#real-time-features)
5. [Response Schemas](#response-schemas)
6. [Error Handling](#error-handling)
7. [Flutter Integration Examples](#flutter-integration-examples)

---

## Authentication

### Base URL
- **Production**: `https://api.millio.space`
- **Development**: `http://localhost:8000`

### Authentication Methods
1. **JWT Bearer Token** (Primary)
2. **OAuth2 Password Flow** (Login)

### Headers Required
```http
Authorization: Bearer <access_token>
Content-Type: application/json
Accept: application/json
```

---

## Authentication Endpoints

### POST `/auth/login`
**Description**: Authenticate user and receive access token

**Request Body**:
```json
{
  "username": "string",
  "password": "string"
}
```

**Response**:
```json
{
  "access_token": "string",
  "token_type": "bearer"
}
```

**Flutter Example**:
```dart
Future<AuthToken> login(String username, String password) async {
  final response = await http.post(
    Uri.parse('$baseUrl/auth/login'),
    headers: {'Content-Type': 'application/x-www-form-urlencoded'},
    body: {
      'username': username,
      'password': password,
    },
  );
  
  if (response.statusCode == 200) {
    return AuthToken.fromJson(json.decode(response.body));
  } else {
    throw Exception('Login failed');
  }
}
```

### GET `/auth/me`
**Description**: Get current user profile

**Headers**: `Authorization: Bearer <token>`

**Response**:
```json
{
  "id": 1,
  "username": "string",
  "email": "string",
  "first_name": "string",
  "last_name": "string",
  "is_active": true,
  "roles": ["guard", "supervisor"]
}
```

---

## Mobile API v1

### Base Path: `/mobile/v1`

The Mobile API v1 provides optimized endpoints specifically designed for mobile applications with:
- Lightweight response payloads
- Offline sync capabilities  
- Mobile-optimized authentication
- Version compatibility checks

---

### Mobile Authentication

#### POST `/mobile/v1/auth/login`
**Description**: Mobile-optimized login with extended token expiry

**Headers**:
```http
X-Mobile-Version: 1.0.0
X-Platform: android|ios
X-Device-ID: unique-device-identifier
```

**Request Body**:
```json
{
  "username": "string",
  "password": "string",
  "device_info": {
    "device_id": "string",
    "platform": "android|ios",
    "app_version": "1.0.0",
    "os_version": "string"
  }
}
```

**Response**:
```json
{
  "access_token": "string",
  "refresh_token": "string",
  "token_type": "bearer",
  "expires_in": 86400,
  "user_profile": {
    "id": 1,
    "username": "string",
    "display_name": "string",
    "roles": ["guard"],
    "permissions": ["patrol:read", "incident:create"],
    "site_assignments": [1, 2, 3]
  },
  "app_config": {
    "features": {
      "offline_mode": true,
      "gps_tracking": true,
      "emergency_button": true
    },
    "sync_interval": 300,
    "max_offline_duration": 3600
  }
}
```

**Flutter Example**:
```dart
class MobileAuthService {
  Future<MobileLoginResponse> login(MobileLoginRequest request) async {
    final response = await http.post(
      Uri.parse('$baseUrl/mobile/v1/auth/login'),
      headers: {
        'Content-Type': 'application/json',
        'X-Mobile-Version': '1.0.0',
        'X-Platform': Platform.isAndroid ? 'android' : 'ios',
        'X-Device-ID': await getDeviceId(),
      },
      body: json.encode(request.toJson()),
    );
    
    if (response.statusCode == 200) {
      return MobileLoginResponse.fromJson(json.decode(response.body));
    } else {
      throw AuthException.fromResponse(response);
    }
  }
}
```

#### POST `/mobile/v1/auth/refresh`
**Description**: Refresh access token using refresh token

**Request Body**:
```json
{
  "refresh_token": "string"
}
```

**Response**:
```json
{
  "access_token": "string",
  "token_type": "bearer",
  "expires_in": 86400
}
```

---

### Mobile Patrols

#### GET `/mobile/v1/patrols/assigned`
**Description**: Get patrols assigned to current user (mobile optimized with versioning)

**Query Parameters**:
- `status` (optional): `assigned|active|completed`
- `date` (optional): `YYYY-MM-DD`
- `limit` (optional): `integer` (default: 20)

**Response**:
```json
{
  "patrols": [
    {
      "id": 1,
      "title": "Morning Patrol - Building A",
      "status": "assigned",
      "site": {
        "id": 1,
        "name": "Main Campus",
        "address": "123 Main St"
      },
      "scheduled_start": "2025-08-14T08:00:00Z",
      "scheduled_end": "2025-08-14T16:00:00Z",
      "checkpoints_count": 5,
      "checkpoints_completed": 0,
      "priority": "normal",
      "estimated_duration": 480
    }
  ],
  "total": 1,
  "has_more": false
}
```

**Flutter Example**:
```dart
class PatrolService {
  Future<List<MobilePatrol>> getAssignedPatrols({
    String? status,
    DateTime? date,
    int limit = 20,
  }) async {
    final queryParams = <String, String>{
      'limit': limit.toString(),
    };
    
    if (status != null) queryParams['status'] = status;
    if (date != null) queryParams['date'] = DateFormat('yyyy-MM-dd').format(date);
    
    final uri = Uri.parse('$baseUrl/mobile/v1/patrols/assigned')
        .replace(queryParameters: queryParams);
    
    final response = await authenticatedGet(uri);
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['patrols'] as List)
          .map((patrol) => MobilePatrol.fromJson(patrol))
          .toList();
    } else {
      throw PatrolException.fromResponse(response);
    }
  }
}
```

#### GET `/mobile/v1/patrols/{patrol_id}/optimized`
**Description**: Get detailed patrol information optimized for mobile

**Response**:
```json
{
  "id": 1,
  "title": "Morning Patrol - Building A",
  "description": "Standard security patrol of main building",
  "status": "assigned",
  "site": {
    "id": 1,
    "name": "Main Campus",
    "coordinates": {
      "latitude": 40.7128,
      "longitude": -74.0060
    }
  },
  "route": {
    "checkpoints": [
      {
        "id": 1,
        "name": "Main Entrance",
        "order": 1,
        "location": {
          "latitude": 40.7128,
          "longitude": -74.0060
        },
        "qr_code": "string",
        "nfc_tag": "string",
        "instructions": "Check main entrance security",
        "estimated_time": 5,
        "is_mandatory": true
      }
    ],
    "total_distance": 1200.5,
    "estimated_duration": 45
  },
  "schedule": {
    "start_time": "2025-08-14T08:00:00Z",
    "end_time": "2025-08-14T16:00:00Z",
    "break_time": 30
  },
  "equipment": [
    {
      "name": "Flashlight",
      "required": true
    },
    {
      "name": "Radio",
      "required": true
    }
  ]
}
```

#### POST `/mobile/v1/patrols/{patrol_id}/start`
**Description**: Start a patrol

**Request Body**:
```json
{
  "location": {
    "latitude": 40.7128,
    "longitude": -74.0060,
    "accuracy": 5.0
  },
  "notes": "Starting patrol on time",
  "equipment_checked": true
}
```

**Response**:
```json
{
  "patrol_id": 1,
  "status": "active",
  "started_at": "2025-08-14T08:00:00Z",
  "session_id": "string"
}
```

#### POST `/mobile/v1/patrols/{patrol_id}/checkpoints/visit`
**Description**: Record checkpoint visit

**Request Body**:
```json
{
  "checkpoint_id": 1,
  "visited_at": "2025-08-14T08:15:00Z",
  "location": {
    "latitude": 40.7128,
    "longitude": -74.0060,
    "accuracy": 3.0
  },
  "verification": {
    "method": "qr_code|nfc|manual",
    "code": "string"
  },
  "status": "normal|issue|skipped",
  "notes": "All clear",
  "photos": ["photo_url_1", "photo_url_2"],
  "duration": 5
}
```

**Response**:
```json
{
  "visit_id": 1,
  "checkpoint_id": 1,
  "status": "completed",
  "next_checkpoint": {
    "id": 2,
    "name": "Parking Lot",
    "distance": 150.5
  }
}
```

---

### Mobile Incidents

#### GET `/mobile/v1/incidents/`
**Description**: Get incidents for mobile app (filtered by user access)

**Query Parameters**:
- `status`: `open|in_progress|resolved`
- `priority`: `low|medium|high|critical`
- `assigned_to_me`: `boolean`
- `limit`: `integer`

**Response**:
```json
[
  {
    "id": 1,
    "title": "Suspicious Activity",
    "description": "Unknown person in restricted area",
    "status": "open",
    "priority": "high",
    "location": {
      "site_name": "Main Campus",
      "area": "Building A - Floor 3",
      "coordinates": {
        "latitude": 40.7128,
        "longitude": -74.0060
      }
    },
    "reported_by": "John Doe",
    "assigned_to": "Jane Smith",
    "created_at": "2025-08-14T10:30:00Z",
    "updated_at": "2025-08-14T10:35:00Z",
    "photos_count": 2,
    "notes_count": 1
  }
]
```

#### POST `/mobile/v1/incidents/`
**Description**: Create new incident

**Request Body**:
```json
{
  "title": "string",
  "description": "string",
  "priority": "low|medium|high|critical",
  "category": "security|maintenance|safety|other",
  "location": {
    "site_id": 1,
    "area": "string",
    "coordinates": {
      "latitude": 40.7128,
      "longitude": -74.0060,
      "accuracy": 5.0
    }
  },
  "photos": ["base64_encoded_image_1"],
  "occurred_at": "2025-08-14T10:30:00Z"
}
```

**Response**:
```json
{
  "id": 1,
  "status": "open",
  "reference_number": "INC-2025-001",
  "created_at": "2025-08-14T10:30:00Z"
}
```

---

### Mobile Emergency

#### POST `/mobile/v1/emergency/trigger`
**Description**: Trigger an emergency alert from mobile app

**Request Body**:
```json
{
  "type": "panic|sos|medical|fire|security",
  "location": {
    "latitude": 40.7128,
    "longitude": -74.0060,
    "accuracy": 5.0
  },
  "message": "Emergency situation",
  "silent": false
}
```

**Response**:
```json
{
  "alert_id": 1,
  "status": "triggered",
  "emergency_contacts": [
    {
      "name": "Security Control",
      "phone": "+1-555-0123",
      "type": "primary"
    }
  ],
  "estimated_response_time": 300
}
```

#### GET `/mobile/v1/emergency/status/{alert_id}`
**Description**: Get emergency alert status

**Response**:
```json
{
  "alert_id": 1,
  "status": "acknowledged",
  "triggered_at": "2025-08-14T11:00:00Z",
  "acknowledged_at": "2025-08-14T11:01:00Z",
  "responder": "Control Room Operator",
  "eta": "2025-08-14T11:05:00Z",
  "instructions": "Stay in place, help is on the way"
}
```

---

### Mobile Sync

#### POST `/mobile/v1/sync/upload`
**Description**: Upload offline data from mobile app

**Request Body**:
```json
{
  "checkpoint_visits": [
    {
      "local_id": "temp_1",
      "checkpoint_id": 1,
      "visited_at": "2025-08-14T08:15:00Z",
      "location": {
        "latitude": 40.7128,
        "longitude": -74.0060
      },
      "status": "normal",
      "notes": "All clear"
    }
  ],
  "incidents": [
    {
      "local_id": "temp_2",
      "title": "Broken window",
      "description": "Window in lobby area is cracked",
      "priority": "medium",
      "created_at": "2025-08-14T09:00:00Z"
    }
  ]
}
```

**Response**:
```json
{
  "success": true,
  "uploaded": {
    "checkpoint_visits": 1,
    "incidents": 1
  },
  "conflicts": [],
  "mapping": {
    "temp_1": 101,
    "temp_2": 201
  }
}
```

#### POST `/mobile/v1/sync/download`
**Description**: Download updates since last sync

**Request Body**:
```json
{
  "last_sync": "2025-08-14T08:00:00Z",
  "data_types": ["patrols", "incidents", "checkpoints"]
}
```

**Response**:
```json
{
  "updates": {
    "patrols": [
      {
        "id": 1,
        "action": "updated",
        "data": { /* patrol object */ }
      }
    ],
    "incidents": [
      {
        "id": 2,
        "action": "created",
        "data": { /* incident object */ }
      }
    ]
  },
  "sync_timestamp": "2025-08-14T12:00:00Z",
  "has_more": false
}
```

---

## Core Endpoints

### Users Management

#### GET `/users/`
**Description**: Get list of users

**Query Parameters**:
- `role`: Filter by role
- `active`: Filter by active status
- `limit`: Number of results (default: 20)
- `offset`: Pagination offset

**Response** (Array format):
```json
[
  {
    "id": 1,
    "username": "john.doe",
    "email": "john@example.com",
    "first_name": "John",
    "last_name": "Doe",
    "is_active": true,
    "roles": ["guard"],
    "created_at": "2025-01-01T00:00:00Z"
  }
]
```

#### POST `/users/`
**Description**: Create new user

**Request Body**:
```json
{
  "username": "string",
  "email": "string",
  "password": "string",
  "first_name": "string",
  "last_name": "string",
  "phone": "string",
  "role_ids": [1, 2]
}
```

#### GET `/users/{user_id}`
**Description**: Get user by ID

#### PUT `/users/{user_id}`
**Description**: Update user

#### DELETE `/users/{user_id}`
**Description**: Delete user

---

### Sites Management

#### GET `/sites/`
**Description**: Get list of sites

**Response**:
```json
[
  {
    "id": 1,
    "name": "Main Campus",
    "address": "123 Main St, City, State",
    "coordinates": {
      "latitude": 40.7128,
      "longitude": -74.0060
    },
    "contact_info": {
      "phone": "+1-555-0123",
      "email": "security@site.com"
    },
    "is_active": true,
    "checkpoints_count": 10
  }
]
```

#### POST `/sites/`
**Description**: Create new site

#### GET `/sites/{site_id}`
**Description**: Get site details

#### PUT `/sites/{site_id}`
**Description**: Update site

---

### Checkpoints Management

#### GET `/checkpoints/`
**Description**: Get checkpoints

**Query Parameters**:
- `site_id`: Filter by site
- `active`: Filter by active status

**Response**:
```json
[
  {
    "id": 1,
    "name": "Main Entrance",
    "description": "Primary building entrance",
    "site_id": 1,
    "location": {
      "latitude": 40.7128,
      "longitude": -74.0060
    },
    "qr_code": "string",
    "nfc_tag": "string",
    "is_active": true,
    "visit_duration": 5
  }
]
```

#### POST `/checkpoints/`
**Description**: Create checkpoint

#### GET `/checkpoints/{checkpoint_id}/visits`
**Description**: Get checkpoint visit history

---

### Tasks Management

#### GET `/tasks/`
**Description**: Get tasks/patrols

**Query Parameters**:
- `assigned_to`: Filter by assignee
- `status`: Filter by status
- `task_type`: Filter by type
- `date_from`: Start date filter
- `date_to`: End date filter

**Response**:
```json
[
  {
    "id": 1,
    "title": "Morning Patrol",
    "description": "Regular morning security patrol",
    "task_type": "patrol",
    "status": "assigned",
    "priority": "normal",
    "assigned_to": {
      "id": 1,
      "name": "John Doe"
    },
    "site": {
      "id": 1,
      "name": "Main Campus"
    },
    "scheduled_start": "2025-08-14T08:00:00Z",
    "scheduled_end": "2025-08-14T16:00:00Z",
    "created_at": "2025-08-13T00:00:00Z"
  }
]
```

#### POST `/tasks/`
**Description**: Create new task

#### GET `/tasks/{task_id}`
**Description**: Get task details

#### PUT `/tasks/{task_id}`
**Description**: Update task

---

### Issues Management

#### GET `/issues/`
**Description**: Get issues/incidents

**Response**:
```json
[
  {
    "id": 1,
    "title": "Security Breach",
    "description": "Unauthorized access detected",
    "status": "open",
    "priority": "high",
    "category": "security",
    "site": {
      "id": 1,
      "name": "Main Campus"
    },
    "reporter": {
      "id": 1,
      "name": "John Doe"
    },
    "assignee": {
      "id": 2,
      "name": "Jane Smith"
    },
    "created_at": "2025-08-14T10:00:00Z",
    "occurred_at": "2025-08-14T09:55:00Z"
  }
]
```

#### POST `/issues/`
**Description**: Create new issue

#### GET `/issues/{issue_id}`
**Description**: Get issue details

#### PUT `/issues/{issue_id}`
**Description**: Update issue

---

### GPS Tracking

#### POST `/gps/location`
**Description**: Record a new GPS location for a guard

**Request Body**:
```json
{
  "latitude": 40.7128,
  "longitude": -74.0060,
  "accuracy": 5.0,
  "timestamp": "2025-08-14T12:00:00Z",
  "speed": 0.0,
  "heading": 0.0
}
```

#### GET `/gps/location/current`
**Description**: Get current location of user

#### GET `/gps/locations/{user_id}`
**Description**: Get location history for user

---

### Notifications

#### GET `/notifications/`
**Description**: Get user notifications

**Response**:
```json
[
  {
    "id": 1,
    "title": "New Patrol Assigned",
    "message": "You have been assigned to Morning Patrol",
    "type": "task_assignment",
    "priority": "normal",
    "is_read": false,
    "created_at": "2025-08-14T08:00:00Z",
    "data": {
      "task_id": 1
    }
  }
]
```

#### PUT `/notifications/{notification_id}/read`
**Description**: Mark notification as read

#### POST `/notifications/mark-all-read`
**Description**: Mark all notifications as read

---

## Real-time Features

### WebSocket Connection

**URL**: `ws://localhost:8000/ws/{user_id}`

**Authentication**: Include token in query parameter
```
ws://localhost:8000/ws/123?token=your_jwt_token
```

**Message Types**:
```json
{
  "type": "notification",
  "data": {
    "title": "New Assignment",
    "message": "You have a new patrol assignment"
  }
}

{
  "type": "emergency_alert",
  "data": {
    "alert_id": 1,
    "type": "panic",
    "location": {
      "latitude": 40.7128,
      "longitude": -74.0060
    },
    "user": "John Doe"
  }
}
```

### Live Monitoring

#### GET `/live/patrols/active`
**Description**: Get active patrols in real-time

#### GET `/live/guards/locations`
**Description**: Get current guard locations

#### GET `/live/system/health`
**Description**: Get system health status

---

## Response Schemas

### Common Response Structure
**Note**: Most endpoints return data directly without wrapping objects.

Standard response format:
```json
{
  /* Response data directly */
}
```

### Error Response Structure
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Validation failed",
    "details": [
      {
        "field": "username",
        "message": "Username is required"
      }
    ]
  },
  "timestamp": "2025-08-14T12:00:00Z"
}
```

### Pagination Response
**Note**: Current API uses simple query parameters (skip/limit) without pagination metadata in response.

```json
[ /* Array of items directly */ ]
```

Use query parameters:
- `skip`: Number of items to skip (default: 0)
- `limit`: Number of items to return (default: 100)

---

## Error Handling

### HTTP Status Codes
- `200 OK` - Success
- `201 Created` - Resource created
- `400 Bad Request` - Validation error
- `401 Unauthorized` - Authentication required
- `403 Forbidden` - Insufficient permissions
- `404 Not Found` - Resource not found
- `422 Unprocessable Entity` - Validation error
- `500 Internal Server Error` - Server error

### Error Codes
- `AUTHENTICATION_REQUIRED` - User must authenticate
- `INVALID_CREDENTIALS` - Login credentials invalid
- `TOKEN_EXPIRED` - Access token has expired
- `INSUFFICIENT_PERMISSIONS` - User lacks required permissions
- `VALIDATION_ERROR` - Request validation failed
- `RESOURCE_NOT_FOUND` - Requested resource not found
- `DUPLICATE_RESOURCE` - Resource already exists
- `EXTERNAL_SERVICE_ERROR` - External service failure

---

## Flutter Integration Examples

### Authentication Service
```dart
class AuthService {
  final String baseUrl;
  final Dio dio;
  
  AuthService({required this.baseUrl}) : dio = Dio() {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = getStoredToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        if (error.response?.statusCode == 401) {
          // Handle token expiry
          logout();
        }
        handler.next(error);
      },
    ));
  }
  
  Future<AuthResponse> login(String username, String password) async {
    try {
      final response = await dio.post(
        '$baseUrl/mobile/v1/auth/login',
        data: {
          'username': username,
          'password': password,
          'device_info': await getDeviceInfo(),
        },
      );
      
      final authResponse = AuthResponse.fromJson(response.data);
      await storeToken(authResponse.accessToken);
      return authResponse;
    } on DioError catch (e) {
      throw AuthException.fromDioError(e);
    }
  }
}
```

### Patrol Service
```dart
class PatrolService {
  final String baseUrl;
  final Dio dio;
  
  Future<List<MobilePatrol>> getAssignedPatrols() async {
    try {
      final response = await dio.get('$baseUrl/mobile/v1/patrols/assigned');
      final data = response.data as Map<String, dynamic>;
      
      return (data['patrols'] as List)
          .map((patrol) => MobilePatrol.fromJson(patrol))
          .toList();
    } on DioError catch (e) {
      throw PatrolException.fromDioError(e);
    }
  }
  
  Future<void> startPatrol(int patrolId, LatLng location) async {
    try {
      await dio.post(
        '$baseUrl/mobile/v1/patrols/$patrolId/start',
        data: {
          'location': {
            'latitude': location.latitude,
            'longitude': location.longitude,
            'accuracy': 5.0,
          },
          'equipment_checked': true,
        },
      );
    } on DioError catch (e) {
      throw PatrolException.fromDioError(e);
    }
  }
}
```

### WebSocket Service
```dart
class WebSocketService {
  WebSocketChannel? _channel;
  final StreamController<dynamic> _messageController = 
      StreamController.broadcast();
  
  Stream<dynamic> get messages => _messageController.stream;
  
  Future<void> connect(String userId, String token) async {
    final uri = Uri.parse('ws://localhost:8000/ws/$userId?token=$token');
    _channel = WebSocketChannel.connect(uri);
    
    _channel!.stream.listen(
      (message) {
        final data = json.decode(message);
        _messageController.add(data);
      },
      onError: (error) {
        print('WebSocket error: $error');
      },
      onDone: () {
        print('WebSocket connection closed');
      },
    );
  }
  
  void sendMessage(Map<String, dynamic> message) {
    if (_channel != null) {
      _channel!.sink.add(json.encode(message));
    }
  }
  
  void disconnect() {
    _channel?.sink.close();
    _messageController.close();
  }
}
```

### Error Handling
```dart
class ApiException implements Exception {
  final String code;
  final String message;
  final List<ValidationError>? details;
  
  ApiException({
    required this.code,
    required this.message,
    this.details,
  });
  
  factory ApiException.fromDioError(DioError error) {
    if (error.response != null) {
      final data = error.response!.data;
      return ApiException(
        code: data['error']['code'] ?? 'UNKNOWN_ERROR',
        message: data['error']['message'] ?? 'An error occurred',
        details: data['error']['details']?.map<ValidationError>(
          (detail) => ValidationError.fromJson(detail),
        ).toList(),
      );
    } else {
      return ApiException(
        code: 'NETWORK_ERROR',
        message: 'Network error occurred',
      );
    }
  }
}
```

---

## Rate Limiting

### Limits per Endpoint Type
- **Authentication**: 5 requests per minute
- **Data retrieval**: 100 requests per minute
- **Data modification**: 50 requests per minute
- **Emergency endpoints**: No limit

### Headers
Response includes rate limit headers:
```http
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1634567890
```

---

## Development Notes

### Testing
- Use `http://localhost:8000` for local development
- API documentation available at `/docs` (Swagger UI)
- Interactive API testing at `/redoc`

### Mobile Optimization
- Mobile API endpoints return optimized payloads
- Support for offline operation with sync
- GPS location tracking integrated
- Push notification support via WebSocket

### Security
- All endpoints require authentication except `/auth/login`
- JWT tokens expire after 24 hours for mobile, 30 minutes for web
- Rate limiting applied per user
- CORS configured for allowed origins

This comprehensive documentation provides all necessary information for Flutter frontend and mobile app development with the PatrolShield API.
