# Progression System

## XP & Leveling
- XP gained from killing enemies
- Boss enemies give more XP
- Formula: `xp_for_level(n) = 100 * n * (1 + n * 0.1)`
- Level up → gain stat points to distribute

## Stat Points
- 3 stat points per level up
- Each stat has an upgrade cost (usually 1 point)
- Stats: HP, ATK, DEF, SPD, RLD, RNG, SP

## Stats

| Stat | Description | Base (Basic) |
|------|-------------|-------------|
| HP | Health Points | 100 |
| ATK | Attack damage | 15 |
| DEF | Damage reduction | 10 |
| SPD | Movement speed | 80 |
| RLD | Reload time (seconds) | 1.5 |
| RNG | Projectile range | 300 |
| SP | Skill resource | 50 |

## Class Change
- Available at level 10, 25, 50
- Each class has evolution options (see game-design-document.md)
- Stats recalculate with new class growth rates

## Save System
- Auto-save after stage clear
- JSON at `user://save_data.json`
- Saves: class, level, XP, stat_points, bonus_stats, current_stage
