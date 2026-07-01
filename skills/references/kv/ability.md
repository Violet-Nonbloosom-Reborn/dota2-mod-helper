# 技能系统

Dota 2 自定义游戏支持两种技能实现方式：数据驱动型和 Lua 型。两种方式都使用 KV 文件定义技能属性。

## 目录

- [技能类型对比](#技能类型对比)
- [基础字段](#基础字段)
- [行为标签](#行为标签)
- [通用属性](#通用属性)
- [AbilityValues](#abilityvalues)
- [相关文件](#相关文件)

## 技能类型对比

| 特性        | 数据驱动型                | Lua 型         |
| --------- | -------------------- | ------------- |
| BaseClass | `ability_datadriven` | `ability_lua` |
| 行为定义      | KV 事件-动作系统           | Lua 脚本        |
| 修饰器定义     | 内联在技能 KV 中           | 单独的 Lua 文件    |
| 适用场景      | 简单技能、被动效果、光环         | 复杂逻辑、自定义算法    |
| 学习曲线      | 低（纯 KV）              | 高（需 Lua 编程）   |
| 灵活性       | 中（受限于事件-动作）          | 高（完全自定义）      |
## 基础字段

所有自定义技能都必须包含以下字段：

| 字段                   | 类型      | 必需  | 说明                                        |
| -------------------- | ------- | --- | ----------------------------------------- |
| `BaseClass`          | String  | 是   | 技能基类：`ability_datadriven` 或 `ability_lua` |
| `AbilityBehavior`    | Flags   | 是   | 行为标签，空格和 `\|` 分隔                          |
| `AbilityTextureName` | String  | 是   | UI 图标，可借用其他技能图标                           |
| `MaxLevel`           | Integer | 否   | 最大等级                              |
| `AbilityType`        | Enum    | 否   | 技能类型：`ABILITY_TYPE_BASIC`、`ABILITY_TYPE_ULTIMATE`、`ABILITY_TYPE_ATTRIBUTES` |

## 行为标签

`AbilityBehavior` 使用标签组合，用空格和 `|` 分隔。

### 常用标签

| 标签 | 说明 |
|------|------|
| `DOTA_ABILITY_BEHAVIOR_PASSIVE` | 被动技能 |
| `DOTA_ABILITY_BEHAVIOR_NO_TARGET` | 无需目标，按键即释放 |
| `DOTA_ABILITY_BEHAVIOR_UNIT_TARGET` | 需要单位目标 |
| `DOTA_ABILITY_BEHAVIOR_POINT` | 点击地面释放 |
| `DOTA_ABILITY_BEHAVIOR_AOE` | 显示范围指示器 |
| `DOTA_ABILITY_BEHAVIOR_CHANNELLED` | 持续施法技能 |
| `DOTA_ABILITY_BEHAVIOR_TOGGLE` | 开关技能 |
| `DOTA_ABILITY_BEHAVIOR_HIDDEN` | 隐藏，不可施放 |
| `DOTA_ABILITY_BEHAVIOR_IMMEDIATE` | 立即执行，没有前后摇 |
| `DOTA_ABILITY_BEHAVIOR_ALT_CASTABLE` | 可多样施法 |

> **注意**：更多行为标签可在 `dota2-script-ref` skill 中查询（如 `AUTOCAST`、`DIRECTIONAL`、`NOT_LEARNABLE` 等）。

### 组合示例

```kv
"AbilityBehavior"    "DOTA_ABILITY_BEHAVIOR_UNIT_TARGET | DOTA_ABILITY_BEHAVIOR_AUTOCAST"
"AbilityBehavior"    "DOTA_ABILITY_BEHAVIOR_AOE | DOTA_ABILITY_BEHAVIOR_PASSIVE"
"AbilityBehavior"    "DOTA_ABILITY_BEHAVIOR_NO_TARGET | DOTA_ABILITY_BEHAVIOR_CHANNELLED"
```

## 通用属性

以下属性适用于所有技能类型：

| 属性                       | 类型      | 默认值 | 说明              |
| ------------------------ | ------- | --- | --------------- |
| `AbilityCastPoint`       | Float   | 0.0 | 施法前摇（秒）         |
| `AbilityCastRange`       | Integer | 0   | 施法距离            |
| `AbilityCooldown`        | Float   | 0   | 冷却时间，空格分隔各等级值   |
| `AbilityManaCost`        | Float   | 0   | 魔法消耗，空格分隔各等级值   |
| `AbilityChannelTime`     | Float   | 0   | 持续施法时间，空格分隔各等级值 |
| `AbilityDamage`          | Float   | 0   | 技能伤害，空格分隔各等级值   |
| `AbilityUnitTargetTeam`  | Flag    | -   | 目标队伍筛选          |
| `AbilityUnitTargetType`  | Flag    | -   | 目标类型筛选          |
| `AbilityUnitTargetFlags` | Flag    | -   | 目标标签筛选          |
| `AbilityUnitDamageType`  | Enum    | -   | 伤害类型            |
| `AbilitySound`           | String  | -   | 技能音效名称          |
| `AbilityCastAnimation`   | String  | -   | 施法动画（如 `ACT_DOTA_CAST_ABILITY_1`） |
| `AbilityChannelAnimation`| String  | -   | 持续施法动画（如 `ACT_DOTA_CHANNEL_ABILITY_4`） |
| `SpellImmunityType`      | Enum    | -   | 技能免疫类型（如 `SPELL_IMMUNITY_ENEMIES_NO`、`SPELL_IMMUNITY_ALLIES_YES`） |
| `SpellDispellableType`   | Enum    | -   | 可驱散类型（如 `SPELL_DISPELLABLE_YES`、`SPELL_DISPELLABLE_NO`） |

### 可内嵌于 AbilityValues 的键

以下键既可作为技能顶层属性，也可在 `AbilityValues` 内部定义（支持天赋加成）：

- `AbilityCooldown`
- `AbilityManaCost`
- `AbilityCharges`
- `AbilityChargeRestoreTime`
- `AbilityCastRange`

**优先级**：当同一键同时出现在顶层和 `AbilityValues` 中时，`AbilityValues` 内的定义优先级更高。

### 目标筛选值

**AbilityUnitTargetTeam：**
- `DOTA_UNIT_TARGET_TEAM_ENEMY`
- `DOTA_UNIT_TARGET_TEAM_FRIENDLY`
- `DOTA_UNIT_TARGET_TEAM_BOTH`
- `DOTA_UNIT_TARGET_TEAM_NONE`

**AbilityUnitTargetType：**
- `DOTA_UNIT_TARGET_HERO`
- `DOTA_UNIT_TARGET_BASIC`
- `DOTA_UNIT_TARGET_CREEP`
- `DOTA_UNIT_TARGET_BUILDING`
- `DOTA_UNIT_TARGET_ALL`
- `DOTA_UNIT_TARGET_NONE`
- `DOTA_UNIT_TARGET_CREEP_HERO`

**AbilityUnitTargetFlags：**
- `DOTA_UNIT_TARGET_FLAG_NOT_MAGIC_IMMUNE_ALLIES`

**AbilityUnitDamageType：**
- `DAMAGE_TYPE_PHYSICAL`
- `DAMAGE_TYPE_MAGICAL`
- `DAMAGE_TYPE_PURE`

## 其他字段

| 字段 | 类型 | 说明 |
|------|------|------|
| `HasShardUpgrade` | Boolean | 是否有魔晶升级（`1` 表示是） |
| `HasScepterUpgrade` | Boolean | 是否有神杖升级（`1` 表示是） |
| `IsGrantedByShard` | Boolean | 是否由魔晶授予（`1` 表示是） |
| `IsGrantedByScepter` | Boolean | 是否由神杖授予（`1` 表示是） |
| `AbilityDuration` | Float | 技能持续时间，空格分隔各等级值 |
| `AbilityCharges` | Integer | 技能充能数 |
| `AbilityChargeRestoreTime` | Float | 充能恢复时间（秒） |
| `Innate`            | Boolean | 是否为先天技能（`1` 表示是） |
| `IsBreakable`       | Boolean | 是否可被破坏（被动技能失效）（`1` 表示是） |
| `AnimationPlaybackRate` | Float | 动画播放速率 |
| `RestrictValuesToMaxLevel` | Boolean | 限制值为最大等级（`1` 表示是） |
| `DependentOnAbility` | String | 跟随哪个技能升级 |
| `RequiredLevel` | Integer | 技能所需等级 |
| `AbilityHealthCost` | Integer | 生命消耗，空格分隔各等级值 |
| `ScepterUpgradeID` | Integer | 神杖升级标识符（如祈求者的 1/2/3 对应三个球） |
| `ShardUpgradeID` | Integer | 魔晶升级标识符（如祈求者的 1/2/3） |
| `HotKeyOverride` | String | 快捷键覆盖（如 `Y`、`V`、`X` 等） |
| `LevelsBetweenUpgrades` | Integer | 升级间隔等级 |
| `ShowCooldownInTooltips` | Boolean | 是否在提示中显示冷却（`0` 表示不显示） |
| `DisplayAdditionalHeroes` | Boolean | 显示额外英雄（召唤单位）（`1` 表示是） |
| `AbilitySharedCooldown` | String | 共享冷却组名称（多个技能共用冷却） |
| `AbilityCastRangeBuffer` | Integer | 施法距离缓冲（允许超出标称施法距离的范围） |
| `InitialAbilityCharges` | Integer | 初始充能数（技能开始时的充能数量） |

## AbilityValues

定义技能参数，可在修饰器中通过 `%name` 引用，数值随技能等级变化。

> **注意**：旧版使用 `AbilitySpecial`（带索引和 `var_type`），现已废弃。新代码应使用 `AbilityValues`。

### 基本结构

```kv
"AbilityValues"
{
    "radius"
    {
        "value"    "315"
    }
    "duration"
    {
        "value"    "2.1 2.4 2.7 3.0"
    }
    "damage"
    {
        "value"    "118 128 138 158"
    }
}
```

### 简写语法

单个固定值可使用简写：

```kv
"AbilityValues"
{
    "blade_dance_crit_chance"    "35"
    "duration"                   "5.0"
}
```

### 天赋加成

通过 `special_bonus_*` 键添加天赋加成：

```kv
"radius"
{
    "value"                         "315"
    "special_bonus_unique_axe_2"    "+85"
}
"bonus_armor"
{
    "value"                         "12 13 14 15"
    "special_bonus_unique_axe_7"    "+10"
}
```

常用天赋键：

| 键                                 | 说明       |
| --------------------------------- | -------- |
| `special_bonus_shard`             | 魔晶升级加成   |
| `special_bonus_scepter`           | 神杖升级加成   |
| `special_bonus_shard_<n>`         | 带编号的魔晶升级加成（如祈求者的 1/2/3） |
| `special_bonus_scepter_<n>`       | 带编号的神杖升级加成（如祈求者的 1/2/3） |
| `special_bonus_unique_<hero>_<n>` | 英雄专属天赋加成 |
| `special_bonus_facet_<facet>`     | 命石特性加成（已废弃） |

加成值格式：`"+85"` 表示加 85，`"-3"` 表示减 3。也可用`x`表示乘，`=`表示“改为指定值”
### 等级成长

通过 `hero_levelup` 和 `levelup_interval` 实现随英雄等级成长：

```kv
"str_reduction"
{
    "value"                "0.2"
    "hero_levelup"         "0.1"
    "levelup_interval"     "3"
}
```

| 键 | 说明 |
|----|------|
| `hero_levelup` | 每次成长增加的值 |
| `levelup_interval` | 成长间隔（每 N 级触发一次） |

示例：基础值 0.2，每 3 级增加 0.1。

### 显示控制

| 键                             | 说明                                |
| ----------------------------- | --------------------------------- |
| `display_type`                | 显示类型，如 `kDebuffPercentage` 显示为百分比 |
| `CalculateSpellDamageTooltip` | `"1"` 表示计算技能伤害加成显示                |
| `affected_by_aoe_increase`    | `"1"` 表示受 AOE 增加效果影响              |
| `DamageTypeTooltip`           | 伤害类型提示（如 `DAMAGE_TYPE_PURE`、`DAMAGE_TYPE_NONE`） |
| `levelkey`                    | 指定由哪个属性决定当前数值（如祈求者的 `quaslevel`、`wexlevel`、`exortlevel`） |
### 引用语法

在修饰器属性中使用 `%name` 引用：

```kv
"Duration"      "%duration"
"Damage"        "%damage"
"Radius"        "%radius"
```

百分比显示使用 `%%`：`"%slow%%%"` 显示为 `"-20%"`
## 相关文件

| 文件                      | 内容                     |
| ----------------------- | ---------------------- |
| `ability-datadriven.md` | 数据驱动技能：事件、动作、修饰器       |
| `ability-lua.md`        | (预留) Lua 技能：脚本结构、修饰器引用 |
| `item.md`               | 物品系统：物品特有字段、配方、商店配置   |

---

来源: https://developer.valvesoftware.com/wiki/Dota_2_Workshop_Tools/Scripting/Abilities_Data_Driven
