# Design System Audit

## Colors (AppColors)
| Token | Value | Usage |
|-------|-------|-------|
| `background` | `#0A0A0B` | Page/scaffold backgrounds |
| `surface` | `#111113` | Cards, dialogs, containers |
| `surfaceHover` | `#1A1A1E` | Hover state for cards/list items |
| `surfaceBorder` | `#232329` | Default borders |
| `surfaceBorderLight` | `#2E2E36` | Hover/focus borders |
| `textPrimary` | `#F5F5F7` | Primary text |
| `textSecondary` | `#8E8E93` | Secondary/body text |
| `textTertiary` | `#636366` | Placeholder/disabled text |
| `textInverse` | `#0A0A0B` | Text on colored backgrounds |
| `accent` | `#6366F1` | Primary actions, links |
| `accentHover` | `#818CF8` | Button hover state |
| `accentMuted` | `#336366F1` | Selected/focused backgrounds |
| `success` | `#22C55E` | Active/success states |
| `warning` | `#F59E0B` | Idle/warning states |
| `error` | `#EF4444` | Error/destructive states |
| `info` | `#3B82F6` | Informational states |
| `sidebarBackground` | `#0D0D0F` | Sidebar panel |
| `sidebarActive` | `#1A1A2E` | Selected sidebar item |
| `sidebarHover` | `#141418` | Hovered sidebar item |

## Typography (AppTypography)
| Token | Size | Weight | Usage |
|-------|------|--------|-------|
| `h1` | 30px | 600 | Page titles (rare) |
| `h2` | 24px | 600 | Section headers |
| `h3` | 20px | 500 | Card titles |
| `h4` | 16px | 500 | Sub-section headers |
| `bodyLarge` | 16px | 400 | Large body text |
| `bodyMedium` | 14px | 400 | Default body text |
| `bodySmall` | 12px | 400 | Captions, meta text |
| `labelLarge` | 14px | 500 | Form labels |
| `labelMedium` | 12px | 500 | Table headers, chips |
| `labelSmall` | 11px | 500 | Small badges, timestamps |
| `headlineSmall` | 18px | 600 | Feature titles |

## Spacing (AppSpacing)
| Token | Value | Usage |
|-------|-------|-------|
| `xs` | 4px | Inner padding, icon gaps |
| `sm` | 8px | Tight spacing, chip padding |
| `md` | 12px | Default widget spacing |
| `lg` | 16px | Grid gaps, section spacing |
| `xl` | 24px | Section padding |
| `xxl` | 32px | Major section padding |
| `xxxl` | 48px | Page-top padding |
| `pageHorizontal` | 32px | Screen edge padding |
| `pageVertical` | 24px | Screen vertical padding |
| `cardPadding` | 20px | Card inner padding |
| `sidebarWidth` | 240px | Expanded sidebar width |
| `sidebarCollapsedWidth` | 64px | Collapsed sidebar width |
| `topbarHeight` | 56px | Top bar height |

## Shadows (AppShadows)
| Token | Blur | Offset | Usage |
|-------|------|--------|-------|
| `sm` | 2px | (0,1) | Hover elevation |
| `md` | 4px | (0,2) | Card elevation |
| `lg` | 8px | (0,4) | Elevated cards |
| `xl` | 16px | (0,8) | Modals, dialogs |
| `elevation` | 4+8px | (0,2)+(0,4) | Button elevation |
| `none` | - | - | Flat elements |

## Audit Findings
- **Coverage**: All tokens are used consistently across all 22+ screens
- **No drift**: No hardcoded color/size values found outside theme files
- **No orphan tokens**: Every token is referenced in at least one widget
- **Consistency**: All border radii use 8px (cards), 12px (containers), or 16px (dialogs)
- **Recommendation**: Add `borderRadiusSm: 6px` and `borderRadiusLg: 16px` tokens
