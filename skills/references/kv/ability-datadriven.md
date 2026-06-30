# 数据驱动技能

数据驱动技能通过 KV 事件-动作系统定义技能行为，无需 Lua 脚本。

## 目录

- [基本结构](#基本结构)
- [事件](#事件)
- [动作](#动作)
- [目标值](#目标值)
- [修饰器](#修饰器)
- [预缓存](#预缓存)
- [完整示例](#完整示例)

> **注意**：技能基础字段、行为标志、AbilityValues 等共用属性详见 `ability.md`。

## 基本结构

```kv
"ability_name"
{
    "BaseClass"             "ability_datadriven"
    "AbilityBehavior"       "DOTA_ABILITY_BEHAVIOR_PASSIVE"
    "AbilityTextureName"    "axe_battle_hunger"

    "Modifiers"
    {
        "modifier_name"
        {
            "Passive"   "1"
            "OnCreated"
            {
                // 动作
            }
        }
    }
}
```

数据驱动技能特有 `Modifiers` 块，内联定义技能关联的修饰器。

## 事件

事件是动作的触发条件，每个事件块内可包含一个或多个动作。

### 技能事件

| 事件                           | 触发时机          |
| ---------------------------- | ------------- |
| `OnSpellStart`               | 技能开始施放        |
| `OnAbilityPhaseStart`        | 技能前摇开始（转向目标前） |
| `OnAbilityStart`             | 技能开始          |
| `OnAbilityEndChannel`        | 持续施法结束       |
| `OnChannelFinish`            | 持续施法完成       |
| `OnChannelInterrupted`       | 持续施法被打断     |
| `OnChannelSucceeded`         | 持续施法成功       |
| `OnUpgrade`                  | 技能升级时         |
| `OnToggleOn` / `OnToggleOff` | 开关切换          |

### 单位事件

| 事件                               | 触发时机   |
| -------------------------------- | ------ |
| `OnCreated`                      | 修饰器创建时 |
| `OnEquip`                        | 装备时    |
| `OnOwnerSpawned`                 | 拥有者生成时 |
| `OnOwnerDied`                    | 拥有者死亡时 |
| `OnRespawn`                      | 拥有者复活时 |
| `OnAttack`                       | 发起攻击   |
| `OnAttackAllied`                 | 攻击友方   |
| `OnAttackFailed`                 | 攻击未命中  |
| `OnHealReceived`                 | 受到治疗   |
| `OnHealthGained`                 | 生命值变化  |
| `OnManaGained`                   | 魔法值变化  |
| `OnSpentMana`                    | 消耗魔法   |
| `OnHeroKilled`                   | 击杀英雄   |
| `OnOrder`                        | 收到命令   |
| `OnUnitMoved`                    | 单位移动   |
| `OnTeleported` / `OnTeleporting` | 传送     |
| `OnStateChanged`                 | 状态变化   |

### 弹道事件

| 事件 | 触发时机 |
|------|----------|
| `OnProjectileDodge` | 弹道被闪避 |
| `OnProjectileFinish` | 弹道结束 |
| `OnProjectileHitUnit` | 弹道命中单位（添加 `"DeleteOnHit" "0"` 可阻止弹道消失） |

## 动作

每个事件块内可包含一个或多个动作：

| 动作 | 参数 | 说明 |
|------|------|------|
| `Damage` | Target, Type, Damage, MinDamage, MaxDamage, CurrentHealthPercentBasedDamage, MaxHealthPercentBasedDamage | 造成伤害 |
| `Heal` | HealAmount, Target | 治疗 |
| `Stun` | Target, Duration | 眩晕 |
| `ApplyModifier` | Target, ModifierName | 施加修饰器 |
| `RemoveModifier` | Target, ModifierName | 移除修饰器 |
| `AttachEffect` | EffectName, EffectAttachType, Target, ControlPoints, EffectRadius, EffectDurationScale, EffectLifeDurationScale, EffectColorA, EffectColorB, EffectAlphaScale | 附加粒子特效 |
| `FireEffect` | 同 AttachEffect | 发射粒子特效 |
| `FireSound` | EffectName, Target | 播放音效 |
| `Blink` | Target | 闪烁 |
| `Knockback` | Target, Center, Duration, Distance, Height, IsFixedDistance, ShouldStun | 击退 |
| `SpawnUnit` | UnitName, UnitCount, UnitLimit, SpawnRadius, Duration, Target, GrantsGold, GrantsXP, OnSpawn | 生成单位 |
| `CreateThinker` | Target, ModifierName | 创建 Thinker（地面区域效果） |
| `LinearProjectile` | Target, EffectName, MoveSpeed, StartRadius, EndRadius, FixedDistance, StartPosition, TargetTeams, TargetTypes, TargetFlags, HasFrontalCone, ProvidesVision, VisionRadius | 直线弹道 |
| `TrackingProjectile` | Target, EffectName, Dodgeable, ProvidesVision, VisionRadius, MoveSpeed, SourceAttachment | 追踪弹道 |
| `CleaveAttack` | CleavePercent, CleaveRadius, CleaveEffect | 溅射攻击 |
| `Lifesteal` | Target, LifestealPercent | 吸血 |
| `AddAbility` | Target, AbilityName | 添加技能（等级 0） |
| `RemoveAbility` | Target, AbilityName | 移除技能 |
| `LevelUpAbility` | Target, AbilityName | 技能升级 |
| `DestroyTrees` | Target, Radius | 摧毁树木 |
| `DelayedAction` | Delay, Action | 延迟执行动作 |
| `Random` | Chance, PseudoRandom（可选）, OnSuccess, OnFailure | 概率触发指定事件 |
| `PseudoRandom` | Enum | 伪随机分布键（如 `DOTA_PSEUDO_RANDOM_JUGG_CRIT`） |
| `ActOnTargets` | Target, Action | 对目标执行动作 |
| `RunScript` | Target, ScriptFile, Function | 执行 Lua 脚本 |
| `SpendMana` | Mana | 消耗魔法 |
| `ApplyMotionController` | Caster, Target, ScriptFile, HorizontalControlFunction, VerticalControlFunction | 通过 Lua 脚本控制单位运动轨迹 |
| `CreateBonusAttack` | Target | 创建额外攻击 |
| `CreateThinkerWall` | ModifierName, Width, Length, Rotation, Target | 创建墙形 Thinker |
| `IsCasterAlive` | OnSuccess, OnFailure | 条件检查：施法者是否存活 |
| `MoveUnit` | Target, MoveToTarget | 移动单位到目标点 |
| `ReplaceUnit` | UnitName, Target | 替换单位 |
| `SpendCharge` | （无参数） | 消耗物品充能 |

### 事件-动作示例

```kv
"OnSpellStart"
{
    "FireSound"
    {
        "EffectName"    "SoundEventName"
        "Target"        "CASTER"
    }
}
```

## 目标值

### 单目标

| 值 | 说明 |
|----|------|
| `CASTER` | 施法者 |
| `TARGET` | 当前目标 |
| `POINT` | 点击位置 |
| `ATTACKER` | 攻击者 |
| `UNIT` | 关联单位 |

> **注意**：这些名称在不同事件中含义可能不同，需要实验验证。

### 多目标

使用块结构选择范围内多个目标：

```kv
"Target"
{
    "Center"        "CASTER" // 范围中心：CASTER, TARGET, POINT, PROJECTILE, UNIT, ATTACKER
    "Radius"        "300"  // 搜索半径
    "Teams"         "DOTA_UNIT_TARGET_TEAM_ENEMY" // 队伍筛选
    "Types"         "DOTA_UNIT_TARGET_HERO | DOTA_UNIT_TARGET_CREEP" // 类型筛选
    "Flags"         "DOTA_UNIT_TARGET_FLAG_NOT_MAGIC_IMMUNE_ALLIES" // 标签筛选
    "MaxTargets"    "3" // 最大目标数
}
```

**Teams 可选值：**
- `DOTA_UNIT_TARGET_TEAM_ENEMY`
- `DOTA_UNIT_TARGET_TEAM_FRIENDLY`
- `DOTA_UNIT_TARGET_TEAM_BOTH`
- `DOTA_UNIT_TARGET_TEAM_CUSTOM`
- `DOTA_UNIT_TARGET_TEAM_NONE`

**Types 可选值：**
- `DOTA_UNIT_TARGET_ALL`
- `DOTA_UNIT_TARGET_HERO`
- `DOTA_UNIT_TARGET_BASIC`
- `DOTA_UNIT_TARGET_CREEP`
- `DOTA_UNIT_TARGET_BUILDING`
- `DOTA_UNIT_TARGET_MECHANICAL`
- `DOTA_UNIT_TARGET_COURIER`
- `DOTA_UNIT_TARGET_OTHER`
- `DOTA_UNIT_TARGET_TREE`
- `DOTA_UNIT_TARGET_CUSTOM`
- `DOTA_UNIT_TARGET_NONE`

**Flags 可选值：**
- `DOTA_UNIT_TARGET_FLAG_NONE`
- `DOTA_UNIT_TARGET_FLAG_DEAD`
- `DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE`
- `DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES`
- `DOTA_UNIT_TARGET_FLAG_NOT_MAGIC_IMMUNE_ALLIES`
- `DOTA_UNIT_TARGET_FLAG_INVULNERABLE`
- `DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE`
- `DOTA_UNIT_TARGET_FLAG_NO_INVIS`
- `DOTA_UNIT_TARGET_FLAG_NOT_ANCIENTS`
- `DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS`
- `DOTA_UNIT_TARGET_FLAG_NOT_SUMMONED`
- `DOTA_UNIT_TARGET_FLAG_NOT_DOMINATED`
- `DOTA_UNIT_TARGET_FLAG_NOT_CREEP_HERO`
- `DOTA_UNIT_TARGET_FLAG_NOT_NIGHTMARED`
- `DOTA_UNIT_TARGET_FLAG_MELEE_ONLY`
- `DOTA_UNIT_TARGET_FLAG_RANGED_ONLY`
- `DOTA_UNIT_TARGET_FLAG_PLAYER_CONTROLLED`
- `DOTA_UNIT_TARGET_FLAG_MANA_ONLY`
- `DOTA_UNIT_TARGET_FLAG_CHECK_DISABLE_HELP`
- `DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD`

### 线形目标

使用 `Line` 子键选择线形范围内的目标：

```kv
"Target"
{
    "Center"    "TARGET"
    "Line"
    {
        "Length"    "1000" // 线段长度
        "Thickness" "200" // 线段宽度
    }
    "Teams"     "DOTA_UNIT_TARGET_TEAM_ENEMY"
    "Types"     "DOTA_UNIT_TARGET_HERO | DOTA_UNIT_TARGET_BASIC"
}
```

## 修饰器

修饰器是数据驱动技能的核心，定义技能的效果。

### 修饰器属性

| 属性 | 值类型 | 说明 |
|------|--------|------|
| `Passive` | Boolean | 自动施加给拥有者 |
| `IsHidden` | Boolean | 隐藏不显示 |
| `IsBuff` / `IsDebuff` | Boolean | 增益/减益标记 |
| `IsPurgable` | Boolean | 可被驱散 |
| `IsStunDebuff` | Boolean | 标记为眩晕类减益 |
| `IsHexDebuff` | Boolean | 标记为变形类减益 |
| `Duration` | Float | 持续时间 |
| `ThinkInterval` | Float | OnThink 触发间隔（秒） |
| `Attributes` | Enum | 修饰器属性（见下） |
| `EffectName` | String | 粒子特效路径 |
| `EffectAttachType` | Enum | 特效附着方式 |
| `TextureName` | String | 自定义图标 |
| `OverrideAnimation` | Enum | 覆盖动画 |
| `AllowIllusionDuplicate` | Boolean | 允许幻象复制该修饰器 |
| `StatusEffectName` | String | 状态特效粒子路径 |
| `StatusEffectPriority` | Integer | 状态特效优先级 |

**Attributes 可选值：**
- `MODIFIER_ATTRIBUTE_NONE`
- `MODIFIER_ATTRIBUTE_MULTIPLE` — 可叠加
- `MODIFIER_ATTRIBUTE_PERMANENT` — 永久
- `MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE`

**EffectAttachType 可选值：**
- `follow_origin`
- `follow_overhead`
- `start_at_customorigin`
- `world_origin`

**OverrideAnimation 可选值：**
- `ACT_DOTA_ATTACK`
- `ACT_DOTA_CAST_ABILITY_1` ~ `ACT_DOTA_CAST_ABILITY_6`
- `ACT_DOTA_DISABLED`
- `ACT_DOTA_RUN`
- `ACT_DOTA_SPAWN`
- `ACT_DOTA_TELEPORT`
- `ACT_DOTA_VICTORY`

### 修饰器属性 (Properties)

通过 `Properties` 块修改单位的数值属性：

```kv
"Properties"
{
    "MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE"    "-20"
    "MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT"    "-20"
}
```

数值可使用 `%name` 语法引用 `AbilityValues` 中的值，随技能等级变化。

**常用 Properties：**

| 属性 | 说明 |
|------|------|
| **移动** | |
| `MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE` | 移动速度百分比加成 |
| `MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT` | 移动速度固定加成 |
| `MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE` | 绝对移动速度 |
| `MODIFIER_PROPERTY_MOVESPEED_BASE_OVERRIDE` | 覆盖基础移动速度 |
| **攻击** | |
| `MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT` | 攻击速度加成 |
| `MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT` | 基础攻击间隔设定 |
| `MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE` | 基础攻击力加成 |
| `MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE` | 攻击前伤害加成 |
| `MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE` | 暴击倍率 |
| `MODIFIER_PROPERTY_ATTACK_RANGE_BONUS` | 攻击距离加成 |
| **防御** | |
| `MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS` | 护甲加成 |
| `MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS` | 魔法抗性加成 |
| `MODIFIER_PROPERTY_EVASION_CONSTANT` | 闪避概率 |
| `MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK` | 固定伤害格挡 |
| **生命与魔法** | |
| `MODIFIER_PROPERTY_HEALTH_BONUS` | 生命值加成 |
| `MODIFIER_PROPERTY_MANA_BONUS` | 魔法值加成 |
| `MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT` | 生命回复固定值 |
| `MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE` | 生命回复百分比 |
| `MODIFIER_PROPERTY_MANA_REGEN_CONSTANT` | 魔法回复固定值 |
| `MODIFIER_PROPERTY_MANA_REGEN_PERCENTAGE` | 魔法回复百分比 |
| **视野** | |
| `MODIFIER_PROPERTY_BONUS_DAY_VISION` | 白天视野加成 |
| `MODIFIER_PROPERTY_BONUS_NIGHT_VISION` | 夜晚视野加成 |
| **伤害** | |
| `MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE` | 造成伤害百分比 |
| `MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE` | 受到伤害百分比 |
| `MODIFIER_PROPERTY_INCOMING_PHYSICAL_DAMAGE_PERCENTAGE` | 受到物理伤害百分比 |
| **冷却与消耗** | |
| `MODIFIER_PROPERTY_COOLDOWN_REDUCTION_CONSTANT` | 冷却时间减少 |
| `MODIFIER_PROPERTY_DEATHGOLDCOST` | 死亡金钱损失 |
| `MODIFIER_PROPERTY_RESPAWNTIME` | 复活时间 |
| **属性** | |
| `MODIFIER_PROPERTY_STATS_STRENGTH_BONUS` | 力量加成 |
| `MODIFIER_PROPERTY_STATS_AGILITY_BONUS` | 敏捷加成 |
| `MODIFIER_PROPERTY_STATS_INTELLECT_BONUS` | 智力加成 |
| **特殊** | |
| `MODIFIER_PROPERTY_DISABLE_HEALING` | 禁用治疗 |
| `MODIFIER_PROPERTY_MODEL_CHANGE` | 模型改变 |

### 修饰器状态 (States)

状态是三值类型：`MODIFIER_STATE_VALUE_NO_ACTION`、`MODIFIER_STATE_VALUE_ENABLED`、`MODIFIER_STATE_VALUE_DISABLED`。

`MODIFIER_STATE_VALUE_ENABLED` 可以简化为 1 。

```kv
"States"
{
    "MODIFIER_STATE_STUNNED"    "MODIFIER_STATE_VALUE_ENABLED"
}
```

**可用状态：**

| 状态 | 说明 |
|------|------|
| **控制** | |
| `MODIFIER_STATE_STUNNED` | 眩晕 |
| `MODIFIER_STATE_SILENCED` | 沉默 |
| `MODIFIER_STATE_MUTED` | 默写（无法使用物品） |
| `MODIFIER_STATE_ROOTED` | 束缚 |
| `MODIFIER_STATE_DISARMED` | 缴械 |
| `MODIFIER_STATE_HEXED` | 妖术 |
| `MODIFIER_STATE_FROZEN` | 冰冻 |
| `MODIFIER_STATE_NIGHTMARED` | 噩梦 |
| `MODIFIER_STATE_DOMINATED` | 被控制 |
| **免疫** | |
| `MODIFIER_STATE_INVULNERABLE` | 无敌 |
| `MODIFIER_STATE_MAGIC_IMMUNE` | 魔免 |
| `MODIFIER_STATE_ATTACK_IMMUNE` | 攻击免疫 |
| **隐身与视野** | |
| `MODIFIER_STATE_INVISIBLE` | 隐身 |
| `MODIFIER_STATE_NOT_ON_MINIMAP` | 小地图不可见 |
| `MODIFIER_STATE_NOT_ON_MINIMAP_FOR_ENEMIES` | 敌方小地图不可见 |
| `MODIFIER_STATE_NO_HEALTH_BAR` | 不显示血条 |
| `MODIFIER_STATE_PROVIDES_VISION` | 提供视野 |
| **其他** | |
| `MODIFIER_STATE_UNSELECTABLE` | 不可选中 |
| `MODIFIER_STATE_OUT_OF_GAME` | 离开游戏 |
| `MODIFIER_STATE_NO_UNIT_COLLISION` | 无单位碰撞（相位移动） |
| `MODIFIER_STATE_FLYING` | 飞行 |
| `MODIFIER_STATE_PASSIVES_DISABLED` | 被动禁用 |
| `MODIFIER_STATE_COMMAND_RESTRICTED` | 命令受限 |
| `MODIFIER_STATE_BLIND` | 致盲 |
| `MODIFIER_STATE_CANNOT_MISS` | 不会丢失 |
| `MODIFIER_STATE_EVADE_DISABLED` | 闪避禁用 |
| `MODIFIER_STATE_BLOCK_DISABLED` | 格挡禁用 |
| `MODIFIER_STATE_LOW_ATTACK_PRIORITY` | 低攻击优先级 |
| `MODIFIER_STATE_SOFT_DISARMED` | 软缴械 |
| `MODIFIER_STATE_SPECIALLY_DENIABLE` | 特殊可否定 |
| `MODIFIER_STATE_NO_TEAM_MOVE_TO` | 队友不可移动 |
| `MODIFIER_STATE_NO_TEAM_SELECT` | 队友不可选中 |
| `MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY` | 仅用于寻路的飞行 |

### 光环 (Aura)

修饰器可作为光环影响范围内目标：

```kv
"modifier_aura"
{
    "Aura"               "modifier_aura_effect"
    "Aura_Radius"        "%radius"
    "Aura_Teams"         "DOTA_UNIT_TARGET_TEAM_ENEMY"
    "Aura_Types"         "DOTA_UNIT_TARGET_HERO | DOTA_UNIT_TARGET_CREEP"
    "Aura_Flags"         "DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES"
    "Aura_ApplyToCaster" "1"
}

"modifier_aura_effect"
{
    "IsDebuff"      "1"
    "Properties"
    {
        "MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS"    "%armor_reduction"
    }
}
```

### 修饰器事件

修饰器也可以响应事件：

| 事件 | 说明 |
|------|------|
| `OnCreated` | 修饰器创建时 |
| `OnDestroy` | 修饰器移除时 |
| `OnIntervalThink` | 思考间隔触发（需设置 ThinkInterval） |
| `OnAttacked` | 拥有者被攻击 |
| `OnAttackLanded` | 拥有者攻击命中（`%attack_damage` 为减免前伤害） |
| `OnAttackStart` | 拥有者开始攻击（动画开始时） |
| `OnDealDamage` | 拥有者造成伤害（`%attack_damage` 为减免后伤害） |
| `OnTakeDamage` | 拥有者受到伤害（`%attack_damage` 为减免后伤害） |
| `OnKill` | 击杀时 |
| `OnDeath` | 死亡时 |
| `OnAbilityExecuted` | 技能执行 |
| `OnUnequip` | 物品卸下时 |

## 预缓存

数据驱动技能可通过 `precache` 块进行预缓存。

注意事项：
- 粒子特效需要完整路径和扩展名，如 `particles/units/heroes/hero_alchemist/alchemist_acid_spray.vpcf`（不需要 `_c` 后缀）
- 音效只需事件名称

## 完整示例

### 被动视觉特效

```kv
"fx_test_ability"
{
    "BaseClass"             "ability_datadriven"
    "AbilityBehavior"       "DOTA_ABILITY_BEHAVIOR_PASSIVE"
    "AbilityTextureName"    "axe_battle_hunger"

    "Modifiers"
    {
        "fx_test_modifier"
        {
            "Passive"   "1"
            "OnCreated"
            {
                "AttachEffect"
                {
                    "Target"                "CASTER"
                    "EffectName"            "particles/econ/generic/generic_buff_1/generic_buff_1.vpcf"
                    "EffectAttachType"      "follow_overhead"
                    "EffectLifeDurationScale" "1"
                    "EffectColorA"          "255 255 0"
                }
            }
        }
    }
}
```

### AOE 持续伤害（酸雾）

死亡后创建酸雾区域，降低护甲并造成持续伤害：

```kv
"creature_acid_spray"
{
    "BaseClass"             "ability_datadriven"
    "AbilityBehavior"       "DOTA_ABILITY_BEHAVIOR_AOE | DOTA_ABILITY_BEHAVIOR_PASSIVE"
    "AbilityUnitDamageType" "DAMAGE_TYPE_PHYSICAL"
    "AbilityTextureName"    "alchemist_acid_spray"
    "AbilityCastPoint"      "0.2"
    "AbilityCastRange"      "900"

    "OnOwnerDied"
    {
        "CreateThinker"
        {
            "ModifierName"  "creature_acid_spray_thinker"
            "Target"        "CASTER"
        }
    }

    "Modifiers"
    {
        "creature_acid_spray_thinker"
        {
            "Aura"          "create_acid_spray_armor_reduction_aura"
            "Aura_Radius"   "%radius"
            "Aura_Teams"    "DOTA_UNIT_TARGET_TEAM_ENEMY"
            "Aura_Types"    "DOTA_UNIT_TARGET_HERO | DOTA_UNIT_TARGET_CREEP | DOTA_UNIT_TARGET_MECHANICAL"
            "Aura_Flags"    "DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES"
            "Duration"      "%duration"
            "OnCreated"
            {
                "AttachEffect"
                {
                    "EffectName"        "particles/units/heroes/hero_alchemist/alchemist_acid_spray.vpcf"
                    "EffectAttachType"  "follow_origin"
                    "Target"            "TARGET"
                    "ControlPoints"
                    {
                        "00"    "0 0 0"
                        "01"    "%radius 1 1"
                    }
                }
            }
        }

        "create_acid_spray_armor_reduction_aura"
        {
            "IsDebuff"        "1"
            "IsPurgable"      "0"
            "EffectName"      "particles/units/heroes/hero_alchemist/alchemist_acid_spray_debuff.vpcf"
            "ThinkInterval"   "%tick_rate"
            "OnIntervalThink"
            {
                "Damage"
                {
                    "Type"    "DAMAGE_TYPE_PHYSICAL"
                    "Damage"  "%damage"
                    "Target"  "TARGET"
                }
            }
            "Properties"
            {
                "MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS"    "%armor_reduction"
            }
        }
    }

    "AbilityValues"
    {
        "radius"
        {
            "value"    "250"
        }
        "duration"
        {
            "value"    "16.0"
        }
        "damage"
        {
            "value"    "118 128 138 158"
        }
        "armor_reduction"
        {
            "value"    "-3 -4 -5 -6"
        }
        "tick_rate"
        {
            "value"    "1.0"
        }
    }
}
```

### 系统光环

使用 `Aura` 属性的标准光环：

```kv
"TestSysAura"
{
    "BaseClass"             "ability_datadriven"
    "AbilityBehavior"       "DOTA_ABILITY_BEHAVIOR_AURA | DOTA_ABILITY_BEHAVIOR_PASSIVE"
    "AbilityUnitTargetTeam" "DOTA_UNIT_TARGET_TEAM_ENEMY"
    "AbilityUnitTargetType" "DOTA_UNIT_TARGET_ALL"
    "AbilityTextureName"    "alchemist_acid_spray"
    "MaxLevel"              "1"
    "AbilityCastPoint"      "0.0"
    "AbilityCastRange"      "500"
    "AbilityCooldown"       "0"
    "AbilityManaCost"       "0"

    "AbilityValues"
    {
        "Range"
        {
            "value"    "500"
        }
    }

    "Modifiers"
    {
        "TestSysAura_Modifier"
        {
            "Passive"       "1"
            "IsHidden"      "1"
            "Aura"          "TestSysAura_FixAttackPercent"
            "Aura_Radius"   "%Range"
            "Aura_Teams"    "DOTA_UNIT_TARGET_TEAM_ENEMY"
            "Aura_Types"    "DOTA_UNIT_TARGET_ALL"
        }

        "TestSysAura_FixAttackPercent"
        {
            "IsDebuff"      "1"
            "IsPurgable"    "0"
            "Properties"
            {
                "MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE"   "-50"
            }
        }
    }
}
```

### 自定义光环（Lua 可访问）

通过 `ThinkInterval` + `ApplyModifier` 实现，可在 Lua 中获取光环拥有者和受影响单位：

```kv
"TestCustomAura"
{
    "BaseClass"             "ability_datadriven"
    "AbilityBehavior"       "DOTA_ABILITY_BEHAVIOR_AURA | DOTA_ABILITY_BEHAVIOR_PASSIVE"
    "AbilityUnitTargetTeam" "DOTA_UNIT_TARGET_TEAM_ENEMY"
    "AbilityUnitTargetType" "DOTA_UNIT_TARGET_ALL"
    "AbilityTextureName"    "alchemist_acid_spray"
    "MaxLevel"              "1"
    "AbilityCastPoint"      "0.0"
    "AbilityCastRange"      "500"
    "AbilityCooldown"       "0"
    "AbilityManaCost"       "0"

    "AbilityValues"
    {
        "Range"
        {
            "value"    "500"
        }
    }

    "Modifiers"
    {
        "TestCustomAura_Modifier"
        {
            "Passive"       "1"
            "IsHidden"      "1"
            "ThinkInterval" "0.5"
            "OnIntervalThink"
            {
                "ApplyModifier"
                {
                    "ModifierName"  "TestCustomAura_FixAttackPercentIcon"
                    "Target"
                    {
                        "Teams"   "DOTA_UNIT_TARGET_TEAM_ENEMY"
                        "Types"   "DOTA_UNIT_TARGET_ALL"
                        "Center"  "CASTER"
                        "Radius"  "%Range"
                    }
                }
                "ApplyModifier"
                {
                    "ModifierName"  "TestCustomAura_FixAttackPercentTimer"
                    "Target"
                    {
                        "Teams"   "DOTA_UNIT_TARGET_TEAM_ENEMY"
                        "Types"   "DOTA_UNIT_TARGET_ALL"
                        "Center"  "CASTER"
                        "Radius"  "%Range"
                    }
                }
            }
        }

        "TestCustomAura_FixAttackPercentIcon"
        {
            "IsDebuff"      "1"
            "IsPurgable"    "0"
            "TextureName"   "alchemist_acid_spray"
            "Properties"
            {
                "MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE"   "-50"
            }
        }

        "TestCustomAura_FixAttackPercentTimer"
        {
            "IsDebuff"      "1"
            "IsPurgable"    "0"
            "IsHidden"      "1"
            "Duration"      "0.6"
            "OnDestroy"
            {
                "RemoveModifier"
                {
                    "ModifierName"  "TestCustomAura_FixAttackPercentIcon"
                    "Target"        "TARGET"
                }
            }
        }
    }
}
```

在 Lua 中获取实体：
- 光环拥有者：`keys.caster`
- 受影响单位：`keys.target`

### 补充动作示例

#### ApplyMotionController（运动控制）

```kv
"ApplyMotionController"
{
    "Caster"                  "CASTER"
    "Target"                  "TARGET"
    "ScriptFile"              "heroes/hero_name/ability_name.lua"
    "HorizontalControlFunction" "MotionControllerHorizontal"
    "VerticalControlFunction"   "MotionControllerVertical"
}
```

#### CreateBonusAttack（额外攻击）

```kv
"CreateBonusAttack"
{
    "Target"    "TARGET"
}
```

#### CreateThinkerWall（墙形 Thinker）

```kv
"CreateThinkerWall"
{
    "ModifierName"  "modifier_wall"
    "Width"         "%width"
    "Length"        "%length"
    "Rotation"      "0 0 0"
    "Target"        "CASTER"
}
```

#### IsCasterAlive（条件检查）

```kv
"IsCasterAlive"
{
    "OnSuccess"
    {
        "Damage"
        {
            "Target"    "TARGET"
            "Type"      "DAMAGE_TYPE_MAGICAL"
            "Damage"    "%damage"
        }
    }
    "OnFailure"
    {
        "FireSound"
        {
            "EffectName"    "Ability.Failed"
            "Target"        "CASTER"
        }
    }
}
```

#### SpawnUnit 带 OnSpawn（生成单位并施加修饰器）

```kv
"SpawnUnit"
{
    "UnitName"      "npc_dota_summon"
    "Target"        "CASTER"
    "Duration"      "%duration"
    "UnitCount"     "2"
    "GrantsGold"    "0"
    "GrantsXP"      "0"
    "SpawnRadius"   "100"
    "OnSpawn"
    {
        "ApplyModifier"
        {
            "ModifierName"  "modifier_summon_buff"
            "Target"        "TARGET"
        }
    }
}
```

#### CleaveAttack 带 CleaveEffect（溅射攻击带特效）

```kv
"CleaveAttack"
{
    "CleavePercent" "%cleave_damage_pct"
    "CleaveRadius"  "%cleave_radius"
    "CleaveEffect"  "particles/units/heroes/hero_sven/sven_spell_great_cleave.vpcf"
}
```

#### Random（概率触发）

```kv
"Random"
{
    "Chance"        "%crit_chance"
    "PseudoRandom"  "DOTA_PSEUDO_RANDOM_JUGG_CRIT"
    "OnSuccess"
    {
        "Damage"
        {
            "Target"    "TARGET"
            "Type"      "DAMAGE_TYPE_PHYSICAL"
            "Damage"    "%crit_damage"
        }
    }
    "OnFailure"
    {
        "Damage"
        {
            "Target"    "TARGET"
            "Type"      "DAMAGE_TYPE_PHYSICAL"
            "Damage"    "%normal_damage"
        }
    }
}
```

---

来源:
- https://developer.valvesoftware.com/wiki/Dota_2_Workshop_Tools/Scripting/Abilities_Data_Driven
- https://developer.valvesoftware.com/wiki/Dota_2_Workshop_Tools/Scripting/Abilities_Data_Driven_Examples
