# Combat System

## Damage Formula
```
damage = ATK * (100 / (100 + target.DEF))
```
- Minimum damage: 1
- Critical hits: not implemented yet (future feature)

## Projectile Physics
- Follows parabolic arc using gravity (980 px/s²)
- Initial velocity based on barrel angle + RNG stat
- Barrel angle range: -80° (near vertical) to +10° (below horizontal)

## Destructible Terrain
- Terrain is Polygon2D-based
- On projectile impact: create crater (circle subtraction from polygon)
- Crater radius scales with ATK
- Visual: darker brown marks at crater sites

## Reload System
- After firing, `can_fire = false` for `rld` seconds
- RLD stat determines reload time (lower = faster)
- No ammo limit

## SP (Skill Points)
- Resource for skills (like mana)
- Regenerates 1 SP/sec passively
- Max SP determined by SP stat
- Each skill has fixed SP cost


## Bullet Types
Each class has 2 bullet types. Press D to switch.

| Type | Damage | Gauge Speed | Effect |
|------|--------|-------------|--------|
| Standard | 1.0x | Normal (1.0x) | Easy to aim |
| Heavy | 1.8x | Fast (2.5x) | Harder to aim accurately |

## Power Gauge System
- Press F once → gauge starts oscillating (0% → 100% → 0% → ...)
- Press F again → fires at current power level
- Power affects RANGE only (0.3x to 1.0x of max speed)
- Heavy bullets: gauge oscillates 2.5x faster → harder to time
- No penalty for low/high power — just shorter/longer range

## Controls
| Action | Key |
|--------|-----|
| Move | ← → |
| Aim | ↑ ↓ |
| Fire (charge/shoot) | F |
| Switch bullet | D |
| Special skill | S |
