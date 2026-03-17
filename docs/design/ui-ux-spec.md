# UI/UX Specification

## Screen Flow
```
Main Menu → Battle → Victory → Upgrade → Battle → ...
                                              ↓
                                         Game Over → Main Menu
```

## Touch Controls (Mobile-First)
- Left panel: Move buttons (L/R), Aim buttons (Up/Down)
- Right panel: FIRE button, SKILL button
- All buttons: minimum 44×44px touch target
- Visual feedback on press (darken/scale)

## HUD Layout
```
┌─────────────────────────────────────┐
│  [HP Bar] [SP Bar]  Stage X  Lv.Y  │
│                                     │
│                                     │
│           GAME AREA                 │
│                                     │
│                                     │
│  [←][→]  [↑][↓]        [SKILL][FIRE]│
└─────────────────────────────────────┘
```

## Color Theme
- Background: brown gradient
- Panels: dark brown with rounded corners
- HP bar: olive green → red
- SP bar: muted teal
- Buttons: tan with dark brown text
- Text: cream/off-white on dark backgrounds

## Transitions
- Fade in/out between stages
- Damage numbers: float up, fade out
- Death: flash white → shrink → explode
- Enemies enter from right with staggered delay
