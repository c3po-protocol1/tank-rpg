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
