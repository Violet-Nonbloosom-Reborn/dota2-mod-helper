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

### 基础行为

| 标签 | 说明 |
|------|------|
| `DOTA_ABILITY_BEHAVIOR_HIDDEN` | 隐藏，不可施放 |
| `DOTA_ABILITY_BEHAVIOR_PASSIVE` | 被动技能 |
| `DOTA_ABILITY_BEHAVIOR_NO_TARGET` | 无需目标，按键即释放 |
| `DOTA_ABILITY_BEHAVIOR_UNIT_TARGET` | 需要单位目标 |
| `DOTA_ABILITY_BEHAVIOR_POINT` | 点击地面释放 |
| `DOTA_ABILITY_BEHAVIOR_AOE` | 显示范围指示器 |
| `DOTA_ABILITY_BEHAVIOR_CHANNELLED` | 持续施法技能 |
| `DOTA_ABILITY_BEHAVIOR_TOGGLE` | 开关技能 |
| `DOTA_ABILITY_BEHAVIOR_DIRECTIONAL` | 方向性技能 |
| `DOTA_ABILITY_BEHAVIOR_AUTOCAST` | 可自动施放 |
| `DOTA_ABILITY_BEHAVIOR_ATTACK` | 攻击类技能 |
| `DOTA_ABILITY_BEHAVIOR_AURA` | 光环技能 |
| `DOTA_ABILITY_BEHAVIOR_ITEM` | 物品技能 |

### 施放条件

| 标签 | 说明 |
|------|------|
| `DOTA_ABILITY_BEHAVIOR_NOT_LEARNABLE` | 不可学习 |
| `DOTA_ABILITY_BEHAVIOR_IMMEDIATE` | 立即执行，没有前后摇 |
| `DOTA_ABILITY_BEHAVIOR_ROOT_DISABLES` | 被缠绕时不可用 |
| `DOTA_ABILITY_BEHAVIOR_UNRESTRICTED` | 命令受限时仍可使用 |
| `DOTA_ABILITY_BEHAVIOR_IGNORE_CHANNEL` | 不中断持续施法 |
| `DOTA_ABILITY_BEHAVIOR_IGNORE_PSEUDO_QUEUE` | 被眩晕时可施放 |
| `DOTA_ABILITY_BEHAVIOR_IGNORE_BACKSWING` | 忽略后摇 |

### 目标与效果

| 标签 | 说明 |
|------|------|
| `DOTA_ABILITY_BEHAVIOR_DONT_ALERT_TARGET` | 不警告目标敌人 |
| `DOTA_ABILITY_BEHAVIOR_DONT_CANCEL_MOVEMENT` | 不取消移动 |
| `DOTA_ABILITY_BEHAVIOR_DONT_RESUME_MOVEMENT` | 完成后不恢复移动 |
| `DOTA_ABILITY_BEHAVIOR_DONT_RESUME_ATTACK` | 完成后不恢复攻击 |
| `DOTA_ABILITY_BEHAVIOR_RUNE_TARGET` | 目标为神符 |

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
| `SpellImmunityType`      | Enum    | -   | 技能免疫类型（如 `SPELL_IMMUNITY_ENEMIES_NO`、`SPELL_IMMUNITY_ALLIES_YES`） |
| `SpellDispellableType`   | Enum    | -   | 可驱散类型（如 `SPELL_DISPELLABLE_YES`、`SPELL_DISPELLABLE_NO`） |

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

**AbilityUnitDamageType：**
- `DAMAGE_TYPE_PHYSICAL`
- `DAMAGE_TYPE_MAGICAL`
- `DAMAGE_TYPE_PURE`

## 其他字段

| 字段 | 类型 | 说明 |
|------|------|------|
| `HasShardUpgrade` | Boolean | 是否有魔晶升级（`1` 表示是） |
| `HasScepterUpgrade` | Boolean | 是否有神杖升级（`1` 表示是） |
| `Innate`            | Boolean | 是否为先天技能（`1` 表示是） |
| `IsBreakable`       | Boolean | 是否可被破坏（被动技能失效）（`1` 表示是）|

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
| `special_bonus_unique_<hero>_<n>` | 英雄专属天赋加成 |

加成值格式：`"+85"` 表示加 85，`"-3"` 表示减 3。也可用`x`表示乘，`=`表示“改为指定值”
### 显示控制

| 键                             | 说明                                |
| ----------------------------- | --------------------------------- |
| `display_type`                | 显示类型，如 `kDebuffPercentage` 显示为百分比 |
| `CalculateSpellDamageTooltip` | `"1"` 表示计算技能伤害加成显示                |
| `affected_by_aoe_increase`    | `"1"` 表示受 AOE 增加效果影响              |
| `DamageTypeTooltip`           | 伤害类型提示（如 `DAMAGE_TYPE_PURE`、`DAMAGE_TYPE_NONE`） |
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
