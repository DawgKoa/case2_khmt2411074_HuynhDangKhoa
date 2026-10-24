---
name: nivora-brutalist-ui
description: Design guidelines, color palette, and component rules for Nivora Brutalist UI (Mobile Neo-Brutalism & Warm Retro-Industrial).
---

# Nivora Brutalist UI System

Nivora Brutalist is a high-contrast, tactile design system combining **Mobile Neo-Brutalism** with **Warm Retro-Industrial** aesthetics. It rejects modern homogenous glassmorphism, soft gradient blurs, and floating cards in favor of tangible physical paper-and-ink aesthetics, hard geometric drop shadows, bold ink borders, and sharp utilitarian typography.

---

## 🎨 1. Core Color Palette

| Role | Color Name | Hex Code | Flutter Value | Usage |
| :--- | :--- | :--- | :--- | :--- |
| **Scaffold Background** | Warm Paper Cream | `#EFEDE0` | `Color(0xFFEFEDE0)` | Global app background, paper canvas |
| **Primary Ink / Dark** | Pure Black Ink | `#050504` | `Color(0xFF050504)` | Thick borders (1.5-2px), hard shadows, primary text, dark cards |
| **Primary Accent** | Turmeric Yellow | `#F6B400` | `Color(0xFFF6B400)` | Primary action buttons, active tabs, progress indicators, highlight chips |
| **Danger / Urgent** | Industrial Orange-Red | `#F61F01` | `Color(0xFFF61F01)` | High priority badges, destructive actions, error banners, overdue deadlines |
| **Secondary Surface** | Warm Stone Grey | `#B5B4AC` | `Color(0xFFB5B4AC)` | Secondary cards, inactive containers, input fills |
| **Secondary Text** | Deep Brownish Grey | `#5E584C` | `Color(0xFF5E584C)` | Timestamps, subtitles, secondary metadata, inactive icons |
| **Divider / Outline** | Light Moss Grey | `#7E817B` | `Color(0xFF7E817B)` | Subtle section dividers, disabled borders |
| **Pure White Surface** | Stark Card White | `#FFFFFF` | `Color(0xFFFFFFFF)` | Standard content cards, text field interior surfaces |

---

## 📐 2. Physicality Rules (Borders & Hard Shadows)

1. **NO SOFT BLUR SHADOWS**: Any `BoxShadow` with `blurRadius > 0` is strictly forbidden.
2. **Hard Cast Shadows**:
   - Default Card/Button Shadow:
     ```dart
     boxShadow: const [
       BoxShadow(
         color: Color(0xFF050504),
         offset: Offset(3, 3),
         blurRadius: 0,
       ),
     ]
     ```
   - Heavy Hero/Modal Shadow:
     ```dart
     boxShadow: const [
       BoxShadow(
         color: Color(0xFF050504),
         offset: Offset(5, 5),
         blurRadius: 0,
       ),
     ]
     ```
3. **Ink Borders**:
   - Every interactive element (Button, Input, Card, Modal, Chip) must have an explicit border:
     ```dart
     border: Border.all(color: const Color(0xFF050504), width: 2.0),
     ```
4. **Border Radius**:
   - Keep corners subtly softened but distinctly geometric: `BorderRadius.circular(8)` to `12`. Never use pill shapes for cards.

---

## 🔤 3. Typography Architecture

- **Headings & Hero Titles**: Bold, assertive geometric sans (`Space Grotesk` or `Plus Jakarta Sans`, fallback to bold system sans). Weight: `FontWeight.w800` or `FontWeight.w900`. Letter spacing: `-0.5` to `-1.0`.
- **Metadata, Status Labels, IDs, Deadlines**: Utilitarian monospace (`JetBrains Mono` or system monospace). Styled in **ALL CAPS** with letter spacing: `1.0` to `1.5`, `FontWeight.w700`.
- **Body & Form Inputs**: Readable clean grotesque (`Inter` or `DM Sans`). Weight: `FontWeight.w500` - `w600`.

---

## 🧱 4. Component Standards

### A. Action Button (Brutalist Button)
- Background: `#F6B400` (Accent Yellow) or `#050504` (Black)
- Border: `2px solid #050504`
- Hard shadow: `Offset(3, 3)`
- Text: Bold Uppercase with tactile tap animation (pressing pushes offset to `Offset(0, 0)`).

### B. Input Field (Brutalist TextField)
- Fill: White `#FFFFFF` or Stone `#EFEDE0`
- Border: `2px solid #050504`
- Hard shadow: `Offset(3, 3)`
- Focused border: `2px solid #050504` with accent indicator.
- Label: Monospace or bold sans with sharp contrast.

### C. Cards & Containers
- Fill: `#FFFFFF` or `#EFEDE0`
- Border: `2px solid #050504`
- Shadow: `Offset(4, 4)`
- Internal padding: `16px` to `20px`

### D. Badges & Chips
- Status Badges:
  - `TODO`: Grey/Stone `#B5B4AC`, Black text, `1.5px` border.
  - `IN_PROGRESS`: Yellow `#F6B400`, Black text, `1.5px` border.
  - `COMPLETED`: Mint / Greenish Stone or Black `#050504` with Yellow text.
  - `URGENT / HIGH`: Red `#F61F01`, White text, `1.5px` border.
