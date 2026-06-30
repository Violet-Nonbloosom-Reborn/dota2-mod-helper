# 脚本过滤器（Script Filters）

## 目录

- [概述](#概述)
- [过滤器函数](#过滤器函数)
- [使用模式](#使用模式)
- [常用过滤器示例](#常用过滤器示例)
  - [伤害过滤器](#伤害过滤器)
  - [金币过滤器](#金币过滤器)
  - [修饰器过滤器](#修饰器过滤器)
- [清除过滤器](#清除过滤器)
- [注意事项](#注意事项)

---

## 概述

脚本过滤器允许拦截和修改即将发生的游戏行为。每个过滤器会传递一个包含事件信息的表，修改表中的值会改变行为的结果。返回 `true` 继续执行，返回 `false` 取消事件。

过滤器在 `GameModeEntity` 上设置，仅在服务器端运行。

---

## 过滤器函数

| 函数 | 说明 | 事件类型 |
|------|------|----------|
| `SetAbilityTuningValueFilter` | 控制技能调优值 | `AbilityTuningValueFilterEvent` |
| `SetBountyRunePickupFilter` | 控制赏金符拾取 | `BountyRunePickupFilterEvent` |
| `SetDamageFilter` | 控制单位受伤 | `DamageFilterEvent` |
| `SetExecuteOrderFilter` | 控制执行命令 | `ExecuteOrderFilterEvent` |
| `SetHealingFilter` | 控制单位治疗 | `HealingFilterEvent` |
| `SetItemAddedToInventoryFilter` | 控制物品添加到库存 | `ItemAddedToInventoryFilterEvent` |
| `SetModifierGainedFilter` | 控制修饰器获得 | `ModifierGainedFilterEvent` |
| `SetModifyExperienceFilter` | 控制经验变化 | `ModifyExperienceFilterEvent` |
| `SetModifyGoldFilter` | 控制金币变化 | `ModifyGoldFilterEvent` |
| `SetRuneSpawnFilter` | 控制神符生成 | `RuneSpawnFilterEvent` |
| `SetTrackingProjectileFilter` | 控制追踪弹道发射 | `TrackingProjectileFilterEvent` |

所有过滤器函数签名相同：
```lua
GameRules:GetGameModeEntity():Set*Filter(filterFunc, context)
```

- `filterFunc`: 回调函数，接收事件表，返回布尔值
- `context`: 传递给回调函数的上下文对象（可为 `nil`）

---

## 使用模式

所有过滤器遵循相同模式：

```lua
function MyFilter(event)
    -- 1. 检查事件信息
    -- 2. 根据需要修改 event 表中的值
    -- 3. 返回 true 继续执行，false 取消事件
    return true
end

GameRules:GetGameModeEntity():Set*Filter(MyFilter, nil)
```

**调试技巧**：使用 `DeepPrintTable(event)` 查看事件表的所有字段。

```lua
function DebugFilter(event)
    print("=== Filter Event ===")
    DeepPrintTable(event)
    return true
end
```

---

## 常用过滤器示例

### 伤害过滤器

```lua
function DamageFilter(event)
    -- event.damage: 伤害值
    -- event.entindex_attacker: 攻击者实体索引
    -- event.entindex_victim: 受害者实体索引
    -- event.entindex_inflictor: 伤害来源实体索引
    -- event.damage_type: 伤害类型
    -- event.damage_category: 伤害类别
    
    local attacker = EntIndexToHScript(event.entindex_attacker)
    local victim = EntIndexToHScript(event.entindex_victim)
    
    -- 示例 1：所有伤害减半
    event.damage = event.damage * 0.5
    
    -- 示例 2：英雄对小兵伤害翻倍
    if attacker and victim then
        if attacker:IsHero() and victim:IsCreep() then
            event.damage = event.damage * 2
        end
    end
    
    -- 示例 3：取消魔法伤害
    if event.damage_type == DAMAGE_TYPE_MAGICAL then
        return false  -- 取消事件
    end
    
    return true  -- 继续执行
end

GameRules:GetGameModeEntity():SetDamageFilter(DamageFilter, nil)
```
由于结算优先级偏低，实践中建议通过修饰器等方法实现伤害调整。
### 金币过滤器

```lua
function ModifyGoldFilter(event)
    -- event.gold: 金币变化量（正数增加，负数减少）
    -- event.entindex_victim: 玩家实体索引
    -- event.reason_const: 金币变化原因
    
    local player = EntIndexToHScript(event.entindex_victim)
    
    -- 示例 1：金币获取翻倍
    if event.gold > 0 then
        event.gold = event.gold * 2
    end
    
    -- 示例 2：禁止死亡掉金
    if event.reason_const == DOTA_ModifyGold_Death then
        event.gold = 0
    end
    
    -- 示例 3：记录金币变化
    print(player:GetName() .. " gold changed by " .. event.gold)
    
    return true
end

GameRules:GetGameModeEntity():SetModifyGoldFilter(ModifyGoldFilter, nil)
```

### 修饰器过滤器

```lua
function ModifierGainedFilter(event)
    -- event.entindex_caster: 施法者实体索引
    -- event.entindex_parent: 修饰器父实体索引
    -- event.entindex_ability: 技能实体索引
    -- event.name: 修饰器名称
    -- event.duration: 持续时间
    
    local caster = EntIndexToHScript(event.entindex_caster)
    local parent = EntIndexToHScript(event.entindex_parent)
    
    -- 示例 1：禁止特定修饰器
    if event.name == "modifier_stunned" then
        return false  -- 取消修饰器
    end
    
    -- 示例 2：延长所有增益效果
    if event.duration > 0 and event.name:find("buff") then
        event.duration = event.duration * 1.5
    end
    
    -- 示例 3：记录修饰器
    print(parent:GetName() .. " gained " .. event.name)
    
    return true
end

GameRules:GetGameModeEntity():SetModifierGainedFilter(ModifierGainedFilter, nil)
```

---

## 清除过滤器

使用对应的 `Clear*Filter` 函数移除已设置的过滤器：

```lua
GameRules:GetGameModeEntity():ClearDamageFilter()
GameRules:GetGameModeEntity():ClearHealingFilter()
GameRules:GetGameModeEntity():ClearModifyGoldFilter()
GameRules:GetGameModeEntity():ClearModifyExperienceFilter()
GameRules:GetGameModeEntity():ClearModifierGainedFilter()
GameRules:GetGameModeEntity():ClearBountyRunePickupFilter()
GameRules:GetGameModeEntity():ClearExecuteOrderFilter()
GameRules:GetGameModeEntity():ClearItemAddedToInventoryFilter()
GameRules:GetGameModeEntity():ClearRuneSpawnFilter()
GameRules:GetGameModeEntity():ClearTrackingProjectileFilter()
```

---

## 注意事项

1. **性能影响**：过滤器在每次相关事件发生时都会调用，避免在过滤器中执行耗时操作
2. **返回值**：必须返回布尔值，否则可能导致未定义行为
3. **事件表修改**：修改事件表中的值会影响最终结果，但不是所有字段都可修改
4. **调试**：使用 `DeepPrintTable(event)` 查看事件表结构，了解可用字段
5. **多个过滤器**：同一类型只能设置一个过滤器，需要多重逻辑时在单个函数中处理
6. **上下文对象**：使用 `context` 参数可以在过滤器中访问外部变量，避免使用全局变量

```lua
-- 使用上下文对象
local myData = { multiplier = 2 }

function GoldFilter(event)
    event.gold = event.gold * self.multiplier
    return true
end

GameRules:GetGameModeEntity():SetModifyGoldFilter(GoldFilter, myData)
```

---

来源: https://developer.valvesoftware.com/wiki/Dota_2_Workshop_Tools/Script_Filters
