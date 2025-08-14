# 🚨 MANDATORY AI AGENT WORKFLOW - NO EXCEPTIONS

**⚠️ THIS IS A STRICT, STEP-BY-STEP PROTOCOL. FOLLOW EVERY STEP IN EXACT ORDER.**

## 🔒 BEFORE YOU START - MANDATORY VALIDATION

### Step 1: READ THESE FILES FIRST (NO EXCEPTIONS)
```
MANDATORY READING ORDER:
1. docs/comprehensive-api-documentation.md
2. docs/access_matrix.csv  
3. web_admin/pubspec.yaml
4. web_admin/lib/shared/models/ (all model files)
5. web_admin/lib/shared/services/ (all service files)
```

**❌ STOP**: If you haven't read ALL files above, you MUST stop and read them now.

### Step 2: VALIDATE PROJECT STRUCTURE
```
MANDATORY CHECKS:
✓ Confirm web_admin/ folder exists
✓ Confirm lib/shared/models/ contains existing models
✓ Confirm lib/shared/services/ contains existing services
✓ Confirm pubspec.yaml has required dependencies
```

**❌ STOP**: If any check fails, ask user to fix project structure first.

## 🎯 MANDATORY WORKFLOW FOR ANY TASK

### PHASE 1: PLANNING (MANDATORY)
1. **Read Task Requirements** - Understand exactly what needs to be done
2. **Check Existing Code** - Look at existing models, services, widgets
3. **Identify API Endpoints** - From comprehensive-api-documentation.md
4. **Plan Implementation** - Write step-by-step plan
5. **Update Checklist** - Mark relevant items as "in_progress" in frontend-development-instructions.md

### PHASE 2: IMPLEMENTATION (MANDATORY ORDER)
1. **Models First** - Update/create data models matching API schemas
2. **Services Second** - Update/create API services with proper error handling
3. **Providers Third** - Update/create Riverpod providers for state management
4. **UI Last** - Create/update widgets and pages

### PHASE 3: VALIDATION (MANDATORY)
1. **Code Review** - Check against existing code patterns
2. **Error Handling** - Ensure all API calls have try-catch blocks
3. **Model Validation** - Ensure models match API schemas exactly
4. **Update Checklist** - Mark items as "completed" in frontend-development-instructions.md

## 🚫 FORBIDDEN ACTIONS

**NEVER DO THESE:**
- ❌ Skip reading documentation files
- ❌ Create code without checking existing patterns
- ❌ Hardcode API URLs or endpoints (ONLY use `https://api.millio.space` via AppConfig)
- ❌ Use any API endpoint other than `https://api.millio.space`
- ❌ Forget error handling in API calls
- ❌ Create models that don't match API schemas
- ❌ Forget to update the checklist
- ❌ Write code without proper imports
- ❌ Use deprecated or non-existent packages

## ✅ MANDATORY CODE PATTERNS

### API Service Pattern (REQUIRED)
```dart
class SomeService {
  final Dio _dio;
  SomeService(this._dio);

  Future<List<SomeModel>> getSomeItems() async {
    try {
      // ALWAYS use AppConfig.apiBaseUrl - NEVER hardcode URLs
      final response = await _dio.get('${AppConfig.apiBaseUrl}/api/endpoint/');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['results'] ?? response.data;
        return data.map((json) => SomeModel.fromJson(json)).toList();
      }
      throw ApiException('Failed to fetch data');
    } on DioException catch (e) {
      throw ApiException('Network error: ${e.message}');
    } catch (e) {
      throw ApiException('Unexpected error: $e');
    }
  }
}
```

**🚨 API RESTRICTIONS:**
- **ONLY ALLOWED API**: `https://api.millio.space`
- **Access via**: `AppConfig.apiBaseUrl` 
- **NEVER hardcode**: API URLs in code
- **FORBIDDEN**: Using any other API endpoints

### Provider Pattern (REQUIRED)
```dart
@riverpod
class SomeNotifier extends _$SomeNotifier {
  @override
  Future<List<SomeModel>> build() async {
    final service = ref.read(someServiceProvider);
    return service.getSomeItems();
  }

  Future<void> createItem(SomeModel item) async {
    state = const AsyncValue.loading();
    try {
      final service = ref.read(someServiceProvider);
      await service.createSomeItem(item);
      state = await AsyncValue.guard(() => service.getSomeItems());
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}
```

## 🎯 CHECKLIST UPDATE PROTOCOL

**MANDATORY**: After completing ANY task, you MUST:

1. Open `frontend-development-instructions.md`
2. Find the relevant checklist item
3. Change `[ ]` to `[x]` for completed items
4. Change `[ ]` to `[⏳]` for in-progress items
5. Save the file

**Example:**
```
- [x] ✅ Task completed successfully
- [⏳] Task currently in progress  
- [ ] Task not started
```

## 🚨 ERROR PREVENTION CHECKLIST

Before submitting ANY code, verify:

**✅ MANDATORY CHECKS:**
- [ ] Read all required documentation files
- [ ] Checked existing code patterns
- [ ] Used proper error handling
- [ ] Models match API schemas exactly
- [ ] No hardcoded values
- [ ] Proper imports added
- [ ] Updated the checklist in frontend-development-instructions.md
- [ ] Code follows existing project structure

**❌ If ANY check fails, fix it before proceeding.**

## 🎯 SUCCESS CRITERIA

**Code is only acceptable when:**
1. ✅ Follows existing project patterns exactly
2. ✅ Has proper error handling for all API calls
3. ✅ Models match API documentation schemas
4. ✅ Uses environment variables for configuration
5. ✅ Updates the checklist in frontend-development-instructions.md
6. ✅ No compilation errors
7. ✅ Follows Dart/Flutter best practices

---

**🚨 REMEMBER: This is a MANDATORY protocol. No exceptions, shortcuts, or variations allowed.**