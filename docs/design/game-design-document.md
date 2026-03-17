# Game Design Document — Tank RPG

## Core Concept
- 2D side-scrolling tank RPG
- Stage-based progression (Stage 1, 2, 3...)
- Kill enemy tanks → gain XP → upgrade stats → change tank class
- Art: cartoon/comic, brown/muted tones, minimal color palette

## Game Flow
1. Main Menu → Start / Continue
2. Battle Stage → destroy all enemy tanks
3. Victory Screen → XP gained, stats
4. Upgrade Screen → spend stat points, class change
5. Next Stage → repeat from 2
6. Game Over → stats, retry/menu

## Stage System
- Enemies scale with stage number (Stage 1: 1 enemy, gradually more)
- Sub-boss every 5 stages (1.8x stats, dark red tint)
- Boss every 10 stages (3x stats, crown indicator, special attacks)
- Terrain varies: hills + flat, destructible (craters on hit)

## Tank Classes (RPG-style)

| Class | Role | Strengths | Weakness |
|-------|------|-----------|----------|
| Basic | Starter | Balanced | No specialization |
| Dealer | DPS | High ATK, fast reload | Low HP |
| Tanker | Tank | High HP/DEF | Slow, low ATK |
| Support | Healer | Repair + buff | Low damage |
| Artillery | Siege | Long range, high arc | Slow reload |
| Scout | Flanker | Fast, evasive | Low armor |

## Class Evolution Tree
- Level 10: Basic → choose Dealer / Tanker / Support
- Level 25: Tier 2 evolution (Dealer → Sniper or Gunner, etc.)
- Level 50: Tier 3 final evolution

## Combat
- Move: left/right (forward/backward)
- Aim: adjust barrel angle up/down
- Fire: projectile follows physics arc
- Skill: class-specific ability (costs SP)
- SP regenerates 1/sec

## Skills

| Class | Skill | SP Cost | Effect |
|-------|-------|---------|--------|
| Basic | Power Shot | 20 | 2x damage |
| Dealer | Rapid Fire | 30 | 3 quick shots |
| Tanker | Shield | 25 | 50% dmg reduction 5s |
| Support | Repair | 35 | Heal 30% max HP |
| Artillery | Barrage | 40 | 3 raining shots |
| Scout | Dash | 15 | Teleport + invincible |

## Visual Style
- Cartoon/chunky tank silhouettes (Polygon2D)
- Brown palette: tan, khaki, olive, dark brown
- Orange/red explosions against brown backdrop
- Damage numbers float up and fade
- Screen shake on big hits
- Muzzle flash on fire
