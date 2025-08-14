# PatrolShield AI Coding Agent Instructions
dio.interceptors.add(CertificatePinningInterceptor());

# PatrolShield Minimal Frontend AI Coding Agent Instructions

## Minimal Project Overview

Start with the essential modules for the PatrolShield Flutter Web Admin Dashboard:
- **Users**: User management (create, list, update, delete)
- **Sites**: Site management (create, list, update)
- **Patrols**: Patrol scheduling and assignment
- **Checkpoints**: Checkpoint creation and assignment to sites/patrols

All other modules (incidents, evidence, analytics, emergency, media, etc.) are excluded from initial implementation.

## Architecture & Tech Stack

- **Flutter Web** (Admin only)
  - State Management: Riverpod
  - HTTP Client: Dio with interceptors
  - UI: Material Design 3, NavigationRail/Drawer
  - Maps: flutter_map (for site/patrol visualization)

## Backend API Integration

Integrate only the following endpoints from `docs/comprehensive-api-documentation.md`:
- `/users/` (GET, POST, PUT, DELETE)
- `/sites/` (GET, POST, PUT)
- `/patrols/` and `/tasks/` (GET, POST, PUT)
- `/checkpoints/` (GET, POST, PUT)

Authentication is required for all endpoints (JWT Bearer).

## Shared Code Structure

Create a shared package for:
- `models/`: User, Site, Patrol, Checkpoint
- `services/`: API service for each module
- `widgets/`: Reusable UI components (forms, tables, lists)

## Development Rules

- Strictly follow the checklist in `frontend-development-instructions.md` for only the above modules
- No skipping, reordering, or omitting required steps
- All API calls must use schemas and error handling from `comprehensive-api-documentation.md`
- Use environment config for API URLs
- Implement unit and widget tests for each module

## Example API Usage

```dart
// User Service Example
class UserService {
  Future<List<User>> getUsers() async {
    final response = await dio.get('$baseUrl/users/');
    // ...parse response...
  }
  // ...other CRUD methods...
}

// Site Service Example
class SiteService {
  Future<List<Site>> getSites() async {
    final response = await dio.get('$baseUrl/sites/');
    // ...parse response...
  }
}

// Patrol Service Example
class PatrolService {
  Future<List<Patrol>> getPatrols() async {
    final response = await dio.get('$baseUrl/patrols/');
    // ...parse response...
  }
}

// Checkpoint Service Example
class CheckpointService {
  Future<List<Checkpoint>> getCheckpoints() async {
    final response = await dio.get('$baseUrl/checkpoints/');
    // ...parse response...
  }
}
```

## Success Criteria

- Users, Sites, Patrols, and Checkpoints modules are fully functional in the web dashboard
- All API integration, error handling, and UI/UX for these modules are complete
- All required tests pass

---

*Expand to additional modules only after these are production-ready and validated.*
