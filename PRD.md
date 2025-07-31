# ProsperShield Patrol Management System

A comprehensive security patrol management system with role-based dashboards for guards, supervisors, and administrators, featuring real-time GPS tracking, incident reporting, and shift management.

**Experience Qualities**: 
1. **Professional** - Clean, authoritative interface that instills confidence in security operations
2. **Immediate** - Quick access to critical functions like SOS alerts and incident reporting
3. **Reliable** - Consistent performance with clear status indicators and error handling

**Complexity Level**: Complex Application (advanced functionality, accounts)
- Requires sophisticated role-based access control, real-time location tracking, and multi-level data management across sites, shifts, and incidents.

## Essential Features

### Authentication System
- **Functionality**: Secure login with JWT token management and role identification
- **Purpose**: Ensures proper access control and personalized experience based on user role
- **Trigger**: App launch or session expiry
- **Progression**: Login form → credential validation → role detection → dashboard redirect
- **Success criteria**: User successfully authenticated and redirected to appropriate role-based dashboard

### Role-Based Dashboard
- **Functionality**: Dynamic interface that adapts based on user role (guard/supervisor/admin)
- **Purpose**: Provides relevant tools and information for each user type
- **Trigger**: Successful login or navigation to home
- **Progression**: Role detection → feature set determination → dashboard assembly → data loading
- **Success criteria**: Appropriate features visible and functional for authenticated user role

### Emergency SOS System
- **Functionality**: Large, prominent SOS button that triggers emergency alerts with GPS location
- **Purpose**: Provides immediate emergency response capability for field personnel
- **Trigger**: SOS button press
- **Progression**: Button press → location capture → alert transmission → confirmation display
- **Success criteria**: Alert successfully sent with accurate location data within 2 seconds

### Shift Management
- **Functionality**: Start/end shifts, view current status, and log checkpoint visits
- **Purpose**: Tracks work periods and ensures patrol routes are completed
- **Trigger**: Shift start/end or checkpoint scan
- **Progression**: Shift action → validation → API update → status refresh → confirmation
- **Success criteria**: Shift status accurately recorded and checkpoint logs properly timestamped

### Live GPS Tracking
- **Functionality**: Continuous location monitoring and transmission during active shifts
- **Purpose**: Enables real-time oversight and emergency response coordination
- **Trigger**: Shift start or manual activation
- **Progression**: Location permission → continuous tracking → periodic transmission → map display
- **Success criteria**: Location updates transmitted every 30 seconds with <10m accuracy

### Incident Reporting
- **Functionality**: Structured incident forms with photo upload and severity classification
- **Purpose**: Documents security events for analysis and compliance
- **Trigger**: Incident occurrence or supervisor review
- **Progression**: Incident detection → form completion → photo/evidence attachment → submission → notification
- **Success criteria**: Incident properly categorized, documented, and routed to appropriate personnel

### Site and User Management (Supervisor+)
- **Functionality**: Assign guards to sites, manage user permissions, and oversee operations
- **Purpose**: Provides operational control and resource allocation for supervisors
- **Trigger**: Administrative action required
- **Progression**: Management panel access → user/site selection → assignment configuration → confirmation
- **Success criteria**: Assignments properly saved and reflected in guard dashboards immediately

## Edge Case Handling
- **Network Connectivity Loss**: Offline mode with local storage sync when connection restored
- **GPS Permission Denied**: Graceful fallback with manual location entry option
- **Session Expiry**: Automatic re-authentication with session restoration
- **Emergency During Offline**: Local emergency protocol display with contact information
- **Invalid QR/NFC Codes**: Clear error messaging with manual checkpoint entry option
- **Simultaneous Logins**: Session management with device registration and conflict resolution

## Design Direction
The interface should feel authoritative and mission-critical, like professional security and emergency response systems, with a minimal yet comprehensive layout that prioritizes speed and clarity over decorative elements.

## Color Selection
Custom palette - A professional security theme using deep blues and safety oranges to convey trust, authority, and emergency readiness.

- **Primary Color**: Deep Security Blue (oklch(0.25 0.08 240)) - Communicates authority, trust, and professionalism
- **Secondary Colors**: Steel Gray (oklch(0.45 0.02 240)) for secondary actions and neutral backgrounds
- **Accent Color**: Emergency Orange (oklch(0.65 0.15 45)) - High-visibility color for critical actions like SOS and alerts
- **Foreground/Background Pairings**: 
  - Background (White #FFFFFF): Dark Blue text (oklch(0.25 0.08 240)) - Ratio 8.2:1 ✓
  - Card (Light Gray oklch(0.97 0.01 240)): Dark Blue text (oklch(0.25 0.08 240)) - Ratio 7.8:1 ✓
  - Primary (Deep Blue oklch(0.25 0.08 240)): White text (#FFFFFF) - Ratio 8.2:1 ✓
  - Secondary (Steel Gray oklch(0.45 0.02 240)): White text (#FFFFFF) - Ratio 4.8:1 ✓
  - Accent (Emergency Orange oklch(0.65 0.15 45)): White text (#FFFFFF) - Ratio 4.9:1 ✓
  - Muted (Light Steel oklch(0.92 0.01 240)): Dark text (oklch(0.25 0.08 240)) - Ratio 7.1:1 ✓

## Font Selection
Inter typeface for its excellent readability in emergency situations and professional appearance across all device sizes, with clear distinction between regular and bold weights.

- **Typographic Hierarchy**:
  - H1 (Dashboard Title): Inter Bold/32px/tight letter spacing
  - H2 (Section Headers): Inter SemiBold/24px/normal spacing  
  - H3 (Card Titles): Inter Medium/18px/normal spacing
  - Body Text: Inter Regular/16px/relaxed line height (1.6)
  - Button Text: Inter Medium/16px/normal spacing
  - Caption/Labels: Inter Regular/14px/normal spacing

## Animations
Subtle, functional animations that reinforce system reliability and provide clear feedback for critical actions, avoiding unnecessary motion that could distract during emergency situations.

- **Purposeful Meaning**: Smooth transitions communicate system responsiveness, while pulse animations on the SOS button indicate its critical nature
- **Hierarchy of Movement**: Emergency actions (SOS) get priority animation treatment, followed by navigation transitions, then subtle hover states

## Component Selection
- **Components**: 
  - Buttons (primary for critical actions, secondary for navigation)
  - Cards for information display and action groupings
  - Badges for status indicators and alerts
  - Tabs for role-based navigation
  - Forms with validation for incident reporting
  - Dialogs for confirmations and detailed views
  - Progress indicators for loading states
  - Alerts for system notifications and errors

- **Customizations**: 
  - Large touch-friendly SOS button component
  - GPS status indicator widget
  - Real-time location map integration
  - Role-based navigation wrapper
  - Offline status banner

- **States**: All interactive elements have clear hover, active, loading, and disabled states with immediate visual feedback
- **Icon Selection**: Phosphor icons focusing on security, location, and communication symbols
- **Spacing**: Consistent 8px base unit scaling (8, 16, 24, 32px) for touch-friendly layouts
- **Mobile**: Mobile-first responsive design with progressive enhancement, larger touch targets (minimum 44px), and collapsible navigation for smaller screens