# 英雄系统

Dota 2 自定义游戏中的英雄覆写通过 `npc_heroes_custom.txt` 文件定义。

注意：Dota 2 目前不允许创建全新的自定义英雄（无法出现在选英雄界面），只能覆写现有英雄的属性。

## 目录

- [必需字段](#必需字段)
- [战斗属性](#战斗属性)
- [状态属性](#状态属性)
- [移动与视野](#移动与视野)
- [技能与天赋](#技能与天赋)
- [英雄标识](#英雄标识)
- [示例](#示例)

## 必需字段

覆写英雄时必须定义以下字段：

| 字段 | 类型 | 说明 |
|------|------|------|
| `Model` | String | 模型路径 |
| `Enabled` | Boolean | 是否启用（`1` 表示启用） |
| `Ability1` - `Ability6` | String | 技能名称（最多6个主动技能） |
| `AttributePrimary` | Enum | 主属性 |
| `AttributeBaseStrength` | Float | 基础力量 |
| `AttributeStrengthGain` | Float | 力量成长 |
| `AttributeBaseAgility` | Float | 基础敏捷 |
| `AttributeAgilityGain` | Float | 敏捷成长 |
| `AttributeBaseIntelligence` | Float | 基础智力 |
| `AttributeIntelligenceGain` | Float | 智力成长 |
| `AttackCapabilities` | Enum | 攻击类型 |
| `MovementCapabilities` | Enum | 移动类型 |

### 主属性枚举

| 值 | 说明 |
|----|------|
| `DOTA_ATTRIBUTE_STRENGTH` | 力量 |
| `DOTA_ATTRIBUTE_AGILITY` | 敏捷 |
| `DOTA_ATTRIBUTE_INTELLECT` | 智力 |
| `DOTA_ATTRIBUTE_ALL` | 全属性 |

### 攻击类型枚举

| 值 | 说明 |
|----|------|
| `DOTA_UNIT_CAP_MELEE_ATTACK` | 近战攻击 |
| `DOTA_UNIT_CAP_RANGED_ATTACK` | 远程攻击 |
| `DOTA_UNIT_CAP_NO_ATTACK` | 无法攻击 |

### 移动类型枚举

| 值 | 说明 |
|----|------|
| `DOTA_UNIT_CAP_MOVE_GROUND` | 地面移动 |
| `DOTA_UNIT_CAP_MOVE_FLY` | 飞行移动 |
| `DOTA_UNIT_CAP_MOVE_NONE` | 无法移动 |

## 战斗属性

| 字段 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `ArmorPhysical` | Float | -1 | 物理护甲 |
| `MagicalResistance` | Integer | 25 | 魔法抗性 |
| `AttackDamageMin` | Integer | 1 | 最小攻击力 |
| `AttackDamageMax` | Integer | 1 | 最大攻击力 |
| `AttackRate` | Float | 1.7 | 攻击间隔（秒） |
| `AttackAnimationPoint` | Float | 0.75 | 攻击前摇（归一化时间） |
| `AttackRange` | Integer | 600 | 攻击范围（近战150，远程600） |
| `AttackAcquisitionRange` | Integer | 800 | 攻击获取范围 |
| `BaseAttackSpeed` | Integer | 100 | 基础攻击速度 |
| `ProjectileModel` | String | - | 远程投射物模型 |
| `ProjectileSpeed` | Integer | 900 | 投射物速度 |

## 状态属性

| 字段 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `StatusHealth` | Integer | 120 | 基础生命值 |
| `StatusHealthRegen` | Float | 0.25 | 生命回复速率 |
| `StatusMana` | Integer | 75 | 基础魔法值 |
| `StatusManaRegen` | Float | 0 | 魔法回复速率 |

## 移动与视野

| 字段 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `MovementSpeed` | Integer | 300 | 移动速度 |
| `MovementTurnRate` | Float | 0.6 | 转向速率 |
| `VisionDaytimeRange` | Integer | 1800 | 白天视野范围 |
| `VisionNighttimeRange` | Integer | 800 | 夜间视野范围 |

## 技能与天赋

### 技能槽位

| 字段 | 说明 |
|------|------|
| `Ability1` - `Ability3` | 基础技能 |
| `Ability4` - `Ability5` | 隐藏技能（通常设为 `generic_hidden`） |
| `Ability6` | 终极技能 |
| `Ability7` - `Ability9` | 额外技能（如技能变体） |

### 天赋系统

| 字段 | 说明 |
|------|------|
| `Ability10` - `Ability17` | 8个天赋技能（左侧4个，右侧4个） |
| `AbilityTalentStart` | 天赋开始等级（默认10） |
| `Ability25` | 属性加成技能（默认 `special_bonus_attributes`） |

### 技能征召

| 字段 | 说明 |
|------|------|
| `AbilityDraftAbilities` | 技能征召可用技能列表 |

### 命石/天赋分支

| 字段 | 说明 |
|------|------|
| `Facets` | 命石定义块（包含 Icon、Color、GradientID 等） |

## 英雄标识

| 字段 | 类型 | 说明 |
|------|------|------|
| `HeroID` | Integer | 英雄唯一ID |
| `Role` | String | 角色定位（逗号分隔，如 `Carry,Support,Nuker`） |
| `Rolelevels` | String | 角色等级（逗号分隔，如 `3,2,1`） |
| `Complexity` | Integer | 复杂度（1-3，1为简单） |
| `Team` | String | 队伍（`Good` 或 `Bad`） |
| `NameAliases` | String | 名称别名（分号分隔） |

### 角色定位枚举

| 值 | 说明 |
|----|------|
| `Carry` | 核心 |
| `Support` | 辅助 |
| `Nuker` | 爆发 |
| `Disabler` | 控制 |
| `Initiator` | 先手 |
| `Durable` | 肉盾 |
| `Escape` | 逃生 |
| `Pusher` | 推进 |
| `Jungler` | 打野 |

## 示例

### 覆写现有英雄属性

```kv
"npc_dota_hero_axe"
{
    "Model"                     "models/heroes/axe/axe.vmdl"
    "Enabled"                   "1"
    "HeroID"                    "2"
    
    // 技能
    "Ability1"                  "axe_berserkers_call"
    "Ability2"                  "axe_battle_hunger"
    "Ability3"                  "axe_counter_helix"
    "Ability4"                  "generic_hidden"
    "Ability5"                  "generic_hidden"
    "Ability6"                  "axe_culling_blade"
    
    // 天赋
    "Ability10"                 "special_bonus_unique_axe_8"
    "Ability11"                 "special_bonus_unique_axe_culling_blade_speed_duration"
    "Ability12"                 "special_bonus_unique_axe"
    "Ability13"                 "special_bonus_unique_axe_7"
    "Ability14"                 "special_bonus_strength_15"
    "Ability15"                 "special_bonus_unique_axe_4"
    "Ability16"                 "special_bonus_unique_axe_2"
    "Ability17"                 "special_bonus_unique_axe_5"
    
    // 战斗属性
    "ArmorPhysical"             "0"
    "AttackCapabilities"        "DOTA_UNIT_CAP_MELEE_ATTACK"
    "AttackDamageMin"           "31"
    "AttackDamageMax"           "35"
    "AttackRate"                "1.7"
    "AttackAnimationPoint"      "0.4"
    "AttackRange"               "150"
    
    // 属性
    "AttributePrimary"          "DOTA_ATTRIBUTE_STRENGTH"
    "AttributeBaseStrength"     "25"
    "AttributeStrengthGain"     "2.7"
    "AttributeBaseAgility"      "20"
    "AttributeAgilityGain"      "1.7"
    "AttributeBaseIntelligence" "18"
    "AttributeIntelligenceGain" "1.6"
    
    // 移动
    "MovementSpeed"             "315"
    "MovementCapabilities"      "DOTA_UNIT_CAP_MOVE_GROUND"
    
    // 状态
    "StatusHealthRegen"         "2.0"
    
    // 视野
    "VisionDaytimeRange"        "1800"
    "VisionNighttimeRange"      "800"
    
    // 标识
    "Role"                      "Initiator,Durable,Disabler,Carry"
    "Rolelevels"                "3,3,2,1"
    "Complexity"                "1"
    "Team"                      "Bad"
}
```

## 相关文件

| 文件 | 内容 |
|------|------|
| `ability.md` | 技能系统定义 |
| `unit.md` | 单位系统定义 |

---

来源：`npc_heroes.txt` 官方文件分析
