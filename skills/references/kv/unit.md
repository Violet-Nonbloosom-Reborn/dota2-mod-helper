# 单位系统

Dota 2 自定义游戏中的单位通过 `npc_units_custom.txt` 文件定义。单位可以是小兵、召唤物、建筑或自定义实体。

## 目录

- [必需字段](#必需字段)
- [攻击相关](#攻击相关)
- [移动相关](#移动相关)
- [状态属性](#状态属性)
- [经济与奖励](#经济与奖励)
- [视觉与碰撞](#视觉与碰撞)
- [技能槽位](#技能槽位)
- [其他字段](#其他字段)
- [Creature 块（AI 配置）](#creature-块ai-配置)
- [示例](#示例)

## 必需字段

所有自定义单位都必须包含以下字段：

| 字段 | 类型 | 说明 |
|------|------|------|
| `BaseClass` | String | 单位基类（如 `npc_dota_base`、`npc_dota_creep_lane`） |
| `Model` | String | 模型路径（如 `models/creeps/lane_creeps/creep_bad_melee/creep_bad_melee.vmdl`） |
| `AttackCapabilities` | Enum | 攻击能力 |
| `MovementCapabilities` | Enum | 移动能力 |
| `StatusHealth` | Integer | 基础生命值 |
| `VisionDaytimeRange` | Integer | 白天视野范围 |
| `VisionNighttimeRange` | Integer | 夜间视野范围 |

### 攻击能力枚举

| 值 | 说明 |
|----|------|
| `DOTA_UNIT_CAP_NO_ATTACK` | 无法攻击 |
| `DOTA_UNIT_CAP_MELEE_ATTACK` | 近战攻击 |
| `DOTA_UNIT_CAP_RANGED_ATTACK` | 远程攻击 |

### 移动能力枚举

| 值 | 说明 |
|----|------|
| `DOTA_UNIT_CAP_MOVE_NONE` | 无法移动 |
| `DOTA_UNIT_CAP_MOVE_GROUND` | 地面移动 |
| `DOTA_UNIT_CAP_MOVE_FLY` | 飞行移动 |

## 攻击相关

有攻击能力的单位需要以下字段：

| 字段 | 类型 | 必需 | 说明 |
|------|------|------|------|
| `AttackDamageMin` | Integer | 是 | 最小攻击力 |
| `AttackDamageMax` | Integer | 是 | 最大攻击力 |
| `AttackRate` | Float | 是 | 攻击间隔（秒） |
| `AttackAnimationPoint` | Float | 是 | 攻击前摇（归一化时间） |
| `AttackRange` | Integer | 是 | 攻击范围 |
| `AttackAcquisitionRange` | Integer | 是 | 目标获取范围 |
| `AttackDamageType` | Enum | 否 | 伤害类型（默认 `DAMAGE_TYPE_ArmorPhysical`） |
| `ProjectileModel` | String | 远程必需 | 投射物特效路径 |
| `ProjectileSpeed` | Integer | 远程必需 | 投射物速度 |
| `BaseAttackSpeed` | Integer | 否 | 基础攻击速度（默认 100） |
| `AttackRangeBuffer` | Integer | 否 | 额外攻击范围缓冲 |

## 移动相关

| 字段 | 类型 | 必需 | 说明 |
|------|------|------|------|
| `MovementSpeed` | Integer | 否 | 移动速度 |
| `MovementTurnRate` | Float | 否 | 转向速率 |
| `FollowRange` | Integer | 否 | 跟随距离 |
| `HasAggressiveStance` | Boolean | 否 | 是否有攻击姿态动画 |

## 状态属性

| 字段 | 类型 | 必需 | 说明 |
|------|------|------|------|
| `StatusHealth` | Integer | 是 | 基础生命值 |
| `StatusHealthRegen` | Float | 否 | 生命回复速率 |
| `StatusMana` | Integer | 否 | 基础魔法值 |
| `StatusManaRegen` | Float | 否 | 魔法回复速率 |
| `StatusStartingMana` | Integer | 否 | 初始魔法值（-1 表示满蓝） |

## 防御属性

| 字段 | 类型 | 说明 |
|------|------|------|
| `ArmorPhysical` | Float | 物理护甲 |
| `MagicalResistance` | Integer | 魔法抗性 |

## 经济与奖励

| 字段 | 类型 | 说明 |
|------|------|------|
| `BountyXP` | Integer | 击杀获得的经验值 |
| `BountyGoldMin` | Integer | 击杀获得的最小金币 |
| `BountyGoldMax` | Integer | 击杀获得的最大金币 |

## 视觉与碰撞

| 字段 | 类型 | 说明 |
|------|------|------|
| `BoundsHullName` | Enum | 碰撞体大小 |
| `RingRadius` | Integer | 选择环半径 |
| `HealthBarOffset` | Integer | 血条高度偏移（-1 表示使用模型默认） |
| `ModelScale` | Float | 模型缩放 |
| `SoundSet` | String | 音效集名称 |
| `IdleSoundLoop` | String | 空闲循环音效 |

### 碰撞体大小枚举

| 值 | 说明 |
|----|------|
| `DOTA_HULL_SIZE_SMALL` | 小型（小兵） |
| `DOTA_HULL_SIZE_REGULAR` | 常规（近战兵） |
| `DOTA_HULL_SIZE_HERO` | 英雄大小 |
| `DOTA_HULL_SIZE_SIEGE` | 攻城车 |

## 技能槽位

单位最多可拥有 8 个技能：

| 字段 | 说明 |
|------|------|
| `Ability1` | 技能 1 |
| `Ability2` | 技能 2 |
| `Ability3` | 技能 3 |
| `Ability4` | 技能 4 |
| `Ability5` | 技能 5 |
| `Ability6` | 技能 6 |
| `Ability7` | 技能 7 |
| `Ability8` | 技能 8 |

## 其他字段

| 字段                            | 类型      | 说明                                                           |
| ----------------------------- | ------- | ------------------------------------------------------------ |
| `vscripts`                    | String  | AI 脚本路径（相对于 `scripts/vscripts/`），无此字段则无 AI 行为。详见 `npc-ai.md` |
| `Level`                       | Integer | 单位等级                                                         |
| `TeamName`                    | Enum    | 队伍名称（如 `DOTA_TEAM_GOODGUYS`、`DOTA_TEAM_BADGUYS`）             |
| `IsAncient`                   | Boolean | 是否为远古单位                                                      |
| `IsNeutralUnitType`           | Boolean | 是否为中立单位                                                      |
| `IsBossMonster`               | Boolean | 是否为 Boss 怪物                                                  |
| `ConsideredHero`              | Boolean | 是否被视为英雄（影响某些技能目标选择）                                          |
| `CanBeDominated`              | Boolean | 是否可被支配                                                       |
| `HasInventory`                | Boolean | 是否有物品栏                                                       |
| `UnitRelationshipClass`       | Enum    | 单位关系类型                                                       |
| `MinimapIcon`                 | String  | 小地图图标名称（如 `minimap_enemyicon`、`minimap_roshancamp`）          |
| `MinimapIconSize`             | Integer | 小地图图标大小                                                      |
| `PathfindingSearchDepthScale` | Float   | 寻路搜索深度缩放（0.1 表示更精确的寻路）                                       |
| `GameSoundsFile`              | String  | 游戏音效文件路径（如 `soundevents/game_sounds_creeps.vsndevts`）        |
| `precache`                    | Block   | 预加载资源（粒子、模型等）                                                |

## 示例

### 最小自定义单位

```kv
"my_custom_unit"
{
    "BaseClass"                 "npc_dota_base"
    "Model"                     "models/creeps/lane_creeps/creep_bad_melee/creep_bad_melee.vmdl"
    
    "AttackCapabilities"        "DOTA_UNIT_CAP_MELEE_ATTACK"
    "AttackDamageMin"           "20"
    "AttackDamageMax"           "25"
    "AttackRate"                "1.0"
    "AttackAnimationPoint"      "0.5"
    "AttackRange"               "100"
    "AttackAcquisitionRange"    "500"
    
    "MovementCapabilities"      "DOTA_UNIT_CAP_MOVE_GROUND"
    "MovementSpeed"             "300"
    
    "StatusHealth"              "500"
    "StatusHealthRegen"         "1"
    
    "VisionDaytimeRange"        "500"
    "VisionNighttimeRange"      "500"
    
    "ArmorPhysical"             "2"
    "BountyXP"                  "50"
    "BountyGoldMin"             "30"
    "BountyGoldMax"             "40"
}
```

### 远程攻击单位

```kv
"my_ranged_unit"
{
    "BaseClass"                 "npc_dota_base"
    "Model"                     "models/creeps/lane_creeps/creep_bad_ranged/lane_dire_ranged.vmdl"
    
    "AttackCapabilities"        "DOTA_UNIT_CAP_RANGED_ATTACK"
    "AttackDamageMin"           "30"
    "AttackDamageMax"           "35"
    "AttackRate"                "1.5"
    "AttackAnimationPoint"      "0.4"
    "AttackRange"               "500"
    "AttackAcquisitionRange"    "600"
    "ProjectileModel"           "particles/base_attacks/ranged_badguy.vpcf"
    "ProjectileSpeed"           "900"
    
    "MovementCapabilities"      "DOTA_UNIT_CAP_MOVE_GROUND"
    "MovementSpeed"             "325"
    
    "StatusHealth"              "300"
    "StatusHealthRegen"         "2"
    "StatusMana"                "500"
    "StatusManaRegen"           "0.75"
    
    "VisionDaytimeRange"        "750"
    "VisionNighttimeRange"      "750"
    
    "BoundsHullName"            "DOTA_HULL_SIZE_SMALL"
    "BountyXP"                  "69"
    "BountyGoldMin"             "43"
    "BountyGoldMax"             "52"
}
```

### 静态建筑

```kv
"my_building"
{
    "BaseClass"                 "npc_dota_base"
    "Model"                     "models/buildings/building_default.vmdl"
    
    "AttackCapabilities"        "DOTA_UNIT_CAP_NO_ATTACK"
    "MovementCapabilities"      "DOTA_UNIT_CAP_MOVE_NONE"
    
    "StatusHealth"              "2000"
    "StatusHealthRegen"         "5"
    
    "VisionDaytimeRange"        "800"
    "VisionNighttimeRange"      "800"
    
    "ArmorPhysical"             "10"
    "BoundsHullName"            "DOTA_HULL_SIZE_BUILDING"
}
```

### Boss 单位（带物品掉落）

```kv
"npc_dota_boss_custom"
{
    "BaseClass"                 "npc_dota_creature"
    "Model"                     "models/heroes/lycan/lycan.vmdl"
    "Level"                     "5"
    "ModelScale"                "1.6"
    "ConsideredHero"            "1"
    "IsAncient"                 "1"
    "IsBossMonster"             "1"
    
    "MinimapIcon"               "minimap_roshancamp"
    "MinimapIconSize"           "250"
    
    "Ability1"                  "boss_summon_minions"
    "Ability2"                  "boss_special_attack"
    
    "ArmorPhysical"             "28"
    "MagicalResistance"         "30"
    
    "AttackCapabilities"        "DOTA_UNIT_CAP_MELEE_ATTACK"
    "AttackDamageMin"           "300"
    "AttackDamageMax"           "320"
    "AttackRate"                "1.45"
    "AttackAnimationPoint"      "0.55"
    "AttackAcquisitionRange"    "600"
    "AttackRange"               "200"
    
    "MovementCapabilities"      "DOTA_UNIT_CAP_MOVE_GROUND"
    "MovementSpeed"             "300"
    
    "StatusHealth"              "8500"
    "StatusHealthRegen"         "10"
    "StatusMana"                "2500"
    "StatusManaRegen"           "5"
    
    "VisionDaytimeRange"        "800"
    "VisionNighttimeRange"      "800"
    
    "BountyXP"                  "900"
    "BountyGoldMin"             "500"
    "BountyGoldMax"             "600"
    
    "Creature"
    {
        "DisableResistance"     "80.0"
        
        "HPGain"                "800"
        "DamageGain"            "30"
        "ArmorGain"             "1"
        
        "ItemDrops"
        {
            "Consumables"
            {
                "Item"
                {
                    "1"    "item_health_potion"
                    "2"    "item_mana_potion"
                }
                "Chance"   "50"
            }
            "Relics"
            {
                "Item"
                {
                    "1"    "item_boss_relic"
                }
                "Chance"   "100"
            }
        }
        
        "AttachWearables"
        {
            "Wearable1"
            {
                "ItemDef"    "7851"
            }
        }
    }
}
```

## Creature 块（AI 配置）

`Creature` 块用于配置单位的 AI 行为参数。

### AI 状态配置

```kv
"Creature"
{
    "DefaultState"    "Invade"
    
    "States"
    {
        "Invade"
        {
            "Name"          "Invade"
            "Aggression"    "100.0"
            "Avoidance"     "0.0"
            "Support"       "0.0"
            "RoamDistance"  "150.0"
        }
    }
    
    "DisableClumpingBehavior"    "1"
}
```

| 字段 | 类型 | 说明 |
|------|------|------|
| `DefaultState` | String | 默认 AI 状态名称 |
| `States` | Block | AI 状态定义 |
| `DisableClumpingBehavior` | Boolean | 禁用单位聚集行为 |
| `DisableResistance` | Float | 控制效果抗性百分比（如 `80.0` 表示 80% 抗性） |

### States 参数

| 参数 | 范围 | 说明 |
|------|------|------|
| `Name` | String | 状态名称 |
| `Aggression` | 0-100 | 攻击性，越高越主动攻击 |
| `Avoidance` | 0-100 | 回避性，越高越倾向躲避 |
| `Support` | 0-100 | 支援性，越高越倾向帮助队友 |
| `RoamDistance` | Float | 游荡距离（像素） |

### 等级成长参数

```kv
"Creature"
{
    "HPGain"          "800"
    "DamageGain"      "30"
    "ArmorGain"       "1"
    "MagicResistGain" "5"
    "MoveSpeedGain"   "0"
    "BountyGain"      "0"
    "XPGain"          "20"
}
```

| 字段 | 类型 | 说明 |
|------|------|------|
| `HPGain` | Integer | 每级生命值成长 |
| `DamageGain` | Integer | 每级攻击力成长 |
| `ArmorGain` | Integer | 每级护甲成长 |
| `MagicResistGain` | Integer | 每级魔抗成长 |
| `MoveSpeedGain` | Integer | 每级移动速度成长 |
| `BountyGain` | Integer | 每级赏金成长 |
| `XPGain` | Integer | 每级经验成长 |

### 物品掉落系统

```kv
"Creature"
{
    "ItemDrops"
    {
        "Consumables"
        {
            "Item"
            {
                "1"    "item_health_potion"
                "2"    "item_mana_potion"
            }
            "Chance"   "12"
        }
        "StatTomes"
        {
            "Item"
            {
                "1"    "item_book_of_strength"
                "2"    "item_book_of_agility"
            }
            "Chance"   "1"
        }
        "Trinkets"
        {
            "Item"
            {
                "1"    "item_slippers"
                "2"    "item_gauntlets"
            }
            "Chance"   "8"
        }
        "Relics"
        {
            "Item"
            {
                "1"    "item_custom_relic"
            }
            "Chance"   "0.25"
        }
        "LifeRune"
        {
            "Item"     "item_life_rune"
            "Chance"   "100"
        }
    }
}
```

| 掉落类别 | 说明 |
|----------|------|
| `Consumables` | 消耗品（药水、芒果等） |
| `StatTomes` | 属性书（力量/敏捷/智力书） |
| `Trinkets` | 小饰品（基础属性装备） |
| `Relics` | 遗物（特殊物品） |
| `LifeRune` | 生命符文 |

每个类别包含：
- `Item`：物品列表，键为编号，值为物品名
- `Chance`：掉落概率（百分比，如 `12` 表示 12%）

### 初始装备

```kv
"Creature"
{
    "EquippedItems"
    {
        "TPScroll"
        {
            "Item"    "item_tpscroll"
        }
    }
}
```

### 饰品

```kv
"Creature"
{
    "AttachWearables"
    {
        "Wearable1"
        {
            "ItemDef"    "7851"
        }
        "Wearable2"
        {
            "ItemDef"    "7852"
        }
    }
}
```

| 字段        | 说明      |
| --------- | ------- |
| `ItemDef` | 饰品定义 ID |

### 防御性技能

```kv
"Creature"
{
    "DefensiveAbilities"
    {
        "Ability1"
        {
            "Name"           "werewolf_howl"
            "AOE"            "1"
            "Heal"           "1"
            "Radius"         "300"
            "MinimumTargets" "2"
        }
    }
}
```

| 字段 | 类型 | 说明 |
|------|------|------|
| `Name` | String | 技能名称 |
| `AOE` | Boolean | 是否为范围技能 |
| `Heal` | Boolean | 是否为治疗技能 |
| `Radius` | Integer | 技能范围 |
| `MinimumTargets` | Integer | 最小目标数（达到此数量才会释放） |

详细 AI 实现参见 `npc-ai.md`。

## 相关文件

| 文件 | 内容 |
|------|------|
| `ability.md` | 技能系统定义 |
| `item.md` | 物品系统定义 |
| `npc-ai.md` | NPC AI 系统（Lua 脚本实现） |

---

来源：`npc_units.txt` 官方文件分析
