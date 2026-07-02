---
name: dota2mod-helper
description: Dota 2 自定义游戏开发辅助。适用于使用 Dota 2 Workshop Tools 开发自定义技能（DataDriven KV）、Lua 脚本（vscripts）、Panorama UI（XML、JavaScript、CSS），以及单位、物品、修饰器 KeyValue 文件。包含代码模式、约定和自定义游戏开发工作流指引。
---

# Dota 2 Modding Helper

## 概述

覆盖 Dota 2 自定义游戏开发的三个领域：

- **KeyValue (KV)** — 技能、单位、物品、修饰器的数据定义
- **Lua (VScript)** — 服务端游戏逻辑
- **Panorama** — 客户端 UI（XML 布局、JavaScript、CSS）

## 架构

Dota 2 自定义游戏采用前后端分离架构：

```
后端 (Server)              前端 (Client)
├── KV 文件                ├── XML 布局
│   ├── 技能 (abilities)   ├── JavaScript 面板
│   ├── 单位 (units)       └── CSS 样式
│   ├── 物品 (items)       └── (Panorama)
│   └── 修饰器 (modifiers)
└── Lua 脚本 (vscripts)
```

## 入门

**何时阅读**：初次接触 Dota 2 自定义游戏开发，或需要了解项目整体结构时。

参阅 `references/get-started.md`：
- addon 目录结构总览
- 核心文件说明（addoninfo.txt、addon_game_mode.lua）
- KV 数据定义与 Lua 脚本的关系

## 跨端功能

### 网络表

**何时阅读**：需要在服务器和客户端之间同步持久化数据时。

参阅 `references/nettables.md`：
- 表注册（custom_net_tables.txt）
- 服务器端写入（Lua）
- 客户端读取和订阅（JavaScript）
- 网络表 vs 自定义事件

## 领域参考文档

根据任务加载对应的参考文档：

### KV（KeyValue 数据定义）
**何时阅读**：创建或编辑 `.txt` KV 格式的技能、单位、物品、修饰器定义时。

参阅 `references/kv/`：
- `kv-format.md` — KV 文件格式规范（语法、注释、文件包含）
- `localization.md` — 本地化文本文件（addon_*.txt 结构与键名约定）
- `ability.md` — 技能系统概述（基础字段、行为标志、AbilityValues）
- `ability-datadriven.md` — 数据驱动技能（事件、动作、修饰器）
- `item.md` — 物品系统（物品特有字段、配方、商店配置）
- `unit.md` — 单位系统（必需字段、攻击、移动、状态属性、示例）
- `hero.md` — 英雄系统（必需字段、战斗属性、技能与天赋、英雄标识）

### Lua (VScript)
**何时阅读**：编写服务端游戏逻辑、技能处理器、游戏模式规则时。

参阅 `references/lua/`：
- `ability-lua.md` — Lua 技能与修饰器（事件、属性、状态、Thinker）
- `events.md` — 游戏事件系统（内置事件监听、自定义事件通信）
- `filters.md` — 脚本过滤器（伤害、金币、经验、修饰器等拦截与修改）
- `utils.md` — Valve 工具函数（vlua 库、类系统、数学向量、调试工具）
- Dota 2 Lua 脚本约定（待补充）
- 常用模式（创建单位、伤害、修饰器）（待补充）
- 游戏模式与技能 Lua 模式（待补充）

### Panorama（UI）
**何时阅读**：编写或修改 Panorama UI 文件（XML/CSS/JS）时。

参阅 `references/panorama/`：
- `overview.md` — 文件结构、核心约束、调试命令
- `custom-ui-manifest.md` — UI 入口文件（CustomUIElement 类型、禁用默认 UI）
- `game-objects.md` — 通过索引访问游戏对象（标识方式、只读查询、写操作指令）
- `localization.md` — 本地化文本（token 语法、对话框变量）
- `mouse-callback.md` — GameUI.SetMouseCallback 模式（鼠标回调、事件处理）

## API 参考

Dota 2 API（函数、常量、枚举）维护在独立的 Skill 中：`dota2-script-ref`

以下查询请使用上述 Skill：
- API 函数签名
- 常量与枚举
- 类方法

## 快速参考

### KV 技能骨架

```kv
"ability_example"
{
    "BaseClass"             "ability_datadriven"
    "AbilityBehavior"       "DOTA_ABILITY_BEHAVIOR_UNIT_TARGET"
    "AbilityUnitTargetTeam" "DOTA_UNIT_TARGET_TEAM_ENEMY"
    "AbilityUnitTargetType" "DOTA_UNIT_TARGET_HERO"
    "AbilityTextureName"    "example_texture"
    "MaxLevel"              "3"
    
    "AbilityValues"
    {
        "damage"        "100 150 200"
    }
    
    "OnSpellStart"
    {
        "Damage"
        {
            "Target"    "TARGET"
            "Type"      "DAMAGE_TYPE_MAGICAL"
            "Damage"    "%damage"
        }
    }
}
```

### Lua 常用模式

```lua
-- 查找范围内的单位
local units = FindUnitsInRadius(
    caster:GetTeamNumber(),
    caster:GetAbsOrigin(),
    nil,
    radius,
    DOTA_UNIT_TARGET_TEAM_ENEMY,
    DOTA_UNIT_TARGET_HERO,
    DOTA_UNIT_TARGET_FLAG_NONE,
    FIND_ANY_ORDER,
    false
)

-- 施加伤害
ApplyDamage({
    victim = target,
    attacker = caster,
    damage = damage_amount,
    damage_type = DAMAGE_TYPE_MAGICAL,
    ability = ability
})

-- 施加修饰器
ApplyModifier({
    caster = caster,
    target = target,
    modifier_name = "modifier_example"
})
```

## 工作流

1. 确定领域：KV 数据定义、Lua 逻辑或 Panorama UI
2. 从 `references/` 加载对应的参考文档
3. 查询 API 时使用 Skill `dota2-script-ref`
4. 遵循领域特定约定（参见参考文档）
