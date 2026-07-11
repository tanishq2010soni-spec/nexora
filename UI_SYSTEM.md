# UI_SYSTEM.md

**Project:** Nexora Control Center
**Date:** 2026-06-19 (Architecture Improvement Phase)
**Version:** 3.0
**Design Inspiration:** Linear, Stripe Dashboard, OpenAI Platform, Vercel, Notion

---

## 1. Design Principles

1. **Dark Theme First** — Dark mode is the primary experience. Light mode is optional.
2. **Minimal** — Every element must earn its space. No decorative UI.
3. **Fast** — Instant visual feedback. Skeleton loaders over spinners.
4. **Data Dense** — Maximize information density without clutter.
5. **Professional** — Enterprise SaaS quality. No toy UI.

---

## 2. Color System (Dark Theme)

`dart
class AppColors {
  // Background
  static const background = Color(0xFF0A0A0B);
  static const surface = Color(0xFF111113);
  static const surfaceHover = Color(0xFF1A1A1E);
  static const surfaceBorder = Color(0xFF232329);
  static const surfaceBorderLight = Color(0xFF2E2E36);

  // Text
  static const textPrimary = Color(0xFFF5F5F7);
  static const textSecondary = Color(0xFF8E8E93);
  static const textTertiary = Color(0xFF636366);
  static const textInverse = Color(0xFF0A0A0B);

  // Accent
  static const accent = Color(0xFF6366F1);
  static const accentHover = Color(0xFF818CF8);
  static const accentMuted = Color(0x336366F1);

  // Status
  static const success = Color(0xFF22C55E);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);
  static const info = Color(0xFF3B82F6);

  // Sidebar
  static const sidebarBackground = Color(0xFF0D0D0F);
  static const sidebarActive = Color(0xFF1A1A2E);
  static const sidebarHover = Color(0xFF141418);

  // Notification
  static const notificationDot = Color(0xFFEF4444);
  static const notificationBg = Color(0xFF1A1A2E);
}
`

---

## 3. Typography

**Primary:** Inter (Google Fonts)
**Monospace:** JetBrains Mono

`dart
class AppTypography {
  static const h1 = TextStyle(fontSize: 30, fontWeight: FontWeight.w600, letterSpacing: -0.02);
  static const h2 = TextStyle(fontSize: 24, fontWeight: FontWeight.w600, letterSpacing: -0.01);
  static const h3 = TextStyle(fontSize: 20, fontWeight: FontWeight.w500);
  static const h4 = TextStyle(fontSize: 16, fontWeight: FontWeight.w500);
  static const bodyLarge = TextStyle(fontSize: 16, fontWeight: FontWeight.w400);
  static const bodyMedium = TextStyle(fontSize: 14, fontWeight: FontWeight.w400);
  static const bodySmall = TextStyle(fontSize: 12, fontWeight: FontWeight.w400);
  static const labelLarge = TextStyle(fontSize: 14, fontWeight: FontWeight.w500);
  static const labelMedium = TextStyle(fontSize: 12, fontWeight: FontWeight.w500);
  static const labelSmall = TextStyle(fontSize: 11, fontWeight: FontWeight.w500);
  static const code = TextStyle(fontSize: 13, fontFamily: 'JetBrains Mono');
}
`

---

## 4. Spacing

Base unit: 4px

`dart
class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;
  static const double pageHorizontal = 32;
  static const double pageVertical = 24;
  static const double cardPadding = 20;
  static const double sidebarWidth = 240;
  static const double sidebarCollapsedWidth = 64;
  static const double topbarHeight = 56;
  static const double commandPaletteWidth = 560;
}
`

---

## 5. Component Specifications

### 5.1 Sidebar Navigation

- Width: 240px (expanded), 64px (collapsed)
- Background: sidebarBackground
- Item height: 40px
- Active: sidebarActive + accent dot
- Hover: sidebarHover
- Modules: Dashboard, Agent Center, AI Models, Knowledge Base, Leads, Customers, Conversations, Analytics, System Health, Audit Logs, Billing, Settings

### 5.2 Top Bar

- Height: 56px
- Background: surface
- Border bottom: 1px surfaceBorder
- Search trigger: Cmd+K hint
- Notification bell with badge
- User avatar

### 5.3 Command Palette

- Width: 560px, max height: 400px
- Background: surface, border: 1px surfaceBorder
- Border radius: 16px
- Overlay: Colors.black54
- Search input: 48px height
- Results: grouped by module, 40px rows
- Shortcut: Cmd+K / Ctrl+K

### 5.4 Agent Cards

- Background: surface, border: 1px surfaceBorder
- Border radius: 12px, padding: 20px
- Status dot: 8px (success/warning/error/textTertiary)
- Actions: ghost buttons, 32px height

### 5.5 Prompt Editor

- Font: JetBrains Mono 13px
- Background: background (darkest)
- Line numbers: textTertiary
- Token counter: labelSmall, textSecondary

### 5.6 Stat Cards

- Background: surface, border: 1px surfaceBorder
- Border radius: 12px, padding: 20px
- Value: h2, textPrimary
- Label: labelMedium, textSecondary
- Trend: success/error

### 5.7 Data Tables

- Header: labelMedium, textSecondary, uppercase
- Body: bodyMedium, textPrimary
- Row height: 48px
- Hover: surfaceHover
- Right-click: context menu
- Multi-select: checkbox column

### 5.8 Forms

- Background: surface
- Border: 1px surfaceBorder
- Focus border: accent
- Content padding: 12h, 10v

### 5.9 Buttons

| Type | Background | Text | Border |
|------|-----------|------|--------|
| Primary | accent | textInverse | none |
| Secondary | surface | textPrimary | surfaceBorder |
| Ghost | transparent | textSecondary | none |
| Danger | error | textInverse | none |

Height: 36px, border radius: 8px

### 5.10 Dialogs

- Background: surface
- Border: 1px surfaceBorder
- Border radius: 16px
- Max width: 440px
- Overlay: Colors.black54

### 5.11 Notification Bell + Panel

- Badge: 16px circle, notificationDot
- Panel: 360px wide, max 400px height
- Unread: left accent border
- Read: no accent border

### 5.12 Workspace Switcher

- Trigger: sidebar item
- Dropdown: surface background
- Active: accent dot + textPrimary

### 5.13 Service Health Cards

- Status dot: 10px circle
- Healthy: success, Degraded: warning, Unhealthy: error

### 5.14 Alert Banner

- Background: warning with 10% opacity
- Border left: 3px warning

### 5.15 Resource Gauges (NEW)

- Circular gauge for CPU/RAM/Disk
- Color transitions: success -> warning -> critical
- Numeric percentage in center

---

## 6. Layout System

### Desktop (>1200px)

`
+----------+----------------------------------+
|          |  Top Bar                         |
| Sidebar  +----------------------------------+
| 240px    |  Main Content (multi-panel)      |
+----------+----------------------------------+
`

### Tablet (768-1200px)

`
+--------+-----------------------------------+
|Sidebar |  Top Bar                          |
| 64px   +-----------------------------------+
| icons  |  Main Content                     |
+--------+-----------------------------------+
`

### Mobile (<768px)

`
+-------------------------------------------+
|  Top Bar + Hamburger                       |
+-------------------------------------------+
|  Main Content (full width)                 |
+-------------------------------------------+
|  Bottom Nav (optional)                     |
+-------------------------------------------+
`

---

## 7. Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| Cmd/Ctrl + K | Command palette |
| Cmd/Ctrl + N | Create new |
| Cmd/Ctrl + S | Save |
| Cmd/Ctrl + Shift + S | Save and close |
| Escape | Close / Cancel |
| Cmd/Ctrl + 1-9 | Jump to module |
| Cmd/Ctrl + , | Settings |
| Delete | Delete selected |
| Space | Multi-select toggle |
| Ctrl+A | Select all |

---

## 8. Right-Click Context Menus

### Agent Card: Edit, Duplicate, Disable, Delete
### Table Row: View, Edit, Copy ID, Delete
### Nav Item: Open, Open in New Panel

---

## 9. Iconography

**Package:** Lucide Icons

| Module | Icon |
|--------|------|
| Dashboard | LayoutDashboard |
| Agent Center | Bot |
| AI Models | Brain |
| Knowledge Base | BookOpen |
| Leads | UserPlus |
| Customers | Users |
| Conversations | MessageSquare |
| Analytics | BarChart3 |
| System Health | HeartPulse |
| Audit Logs | FileText |
| Settings | Settings |
| Billing | CreditCard |
| Notifications | Bell |
| Search | Search |
| Workspace | Layers |

---

## 10. Animation Guidelines

- Duration: 150ms (micro), 200ms (standard), 300ms (page transitions)
- Curve: Curves.easeInOut
- Allowed: Page transitions, dialog open/close, hover states, skeleton shimmer
- Forbidden: Loading spinners as decoration, parallax, bounce, elastic

---

## 11. Responsive Breakpoints

| Breakpoint | Width | Layout |
|------------|-------|--------|
| Desktop XL | >1440px | Full sidebar, multi-panel |
| Desktop | 1200-1440px | Full sidebar, single panel |
| Tablet | 768-1200px | Collapsed sidebar |
| Mobile | <768px | Hidden sidebar, hamburger |

---

**Awaiting approval before proceeding to implementation.**
