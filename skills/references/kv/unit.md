# 单位系统

Dota 2 自定义游戏中的单位通过 `npc_units.txt` 文件定义。单位可以是小兵、召唤物、建筑或自定义实体。

## 目录

- [必需字段](#必需字段)
- [攻击相关](#攻击相关)
- [移动相关](#移动相关)
- [状态属性](#状态属性)
- [经济与奖励](#经济与奖励)
- [视觉与碰撞](#视觉与碰撞)
- [技能槽位](#技能槽位)
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

| 字段 | 类型 | 说明 |
|------|------|------|
| `Level` | Integer | 单位等级 |
| `TeamName` | Enum | 队伍名称（如 `DOTA_TEAM_GOODGUYS`、`DOTA_TEAM_BADGUYS`） |
| `IsAncient` | Boolean | 是否为远古单位 |
| `IsNeutralUnitType` | Boolean | 是否为中立单位 |
| `CanBeDominated` | Boolean | 是否可被支配 |
| `HasInventory` | Boolean | 是否有物品栏 |
| `UnitRelationshipClass` | Enum | 单位关系类型 |
| `precache` | Block | 预加载资源（粒子、模型等） |

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

## 相关文件

| 文件 | 内容 |
|------|------|
| `ability.md` | 技能系统定义 |
| `item.md` | 物品系统定义 |

---

来源：`npc_units.txt` 官方文件分析
