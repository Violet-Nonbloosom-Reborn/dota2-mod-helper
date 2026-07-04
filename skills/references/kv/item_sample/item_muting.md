# 物品初始化与自定义锁闭

## 概述

Lua 物品的生命周期包含两个关键控制点：

| 函数 | 作用 | 调用时机 |
|------|------|----------|
| `Spawn()` | 物品初始化 | 物品创建时 |
| `IsMuted()` | 自定义锁闭 | 引擎检查物品是否生效时 |

这两个函数提供了物品行为的完全控制权，可用于实现等级限制、修饰器依赖、游戏状态条件等机制。

## Spawn() - 物品初始化

### 调用时机

`Spawn()` 在物品实例创建后立即调用，早于装备到英雄。

### 常见用途

- 读取 KV 配置值
- 初始化内部状态
- 设置视觉效果
- 注册事件监听

### 实现模式

```lua
function item_example:Spawn()
    -- 读取 KV 中的配置
    self.required_level = self:GetSpecialValueFor("required_level")
    self.bonus_damage = self:GetSpecialValueFor("bonus_damage")
    
    -- 初始化状态
    self.bActive = false
end
```

### 注意事项

- `Spawn()` 只调用一次，后续装备/卸下不会再次调用
- 使用 `self:GetSpecialValueFor()` 读取 `AbilitySpecial` 中的值
- 避免在此函数中执行耗时操作

## IsMuted() - 自定义锁闭

### 返回值含义

| 返回值 | 效果 |
|--------|------|
| `true` | 物品被锁闭，所有效果失效 |
| `false` | 物品正常生效 |

### 调用时机

引擎在以下情况调用 `IsMuted()`：
- 检查物品属性是否生效
- 检查技能是否可用
- 更新 UI 显示

### 实现模式

```lua
function item_example:IsMuted()
    -- 条件 1：等级检查
    if self.required_level > self:GetCaster():GetLevel() then
        return true
    end
    
    -- 条件 2：修饰器检查
    if not self:GetCaster():HasModifier("modifier_required_buff") then
        return true
    end
    
    -- 条件 3：游戏状态检查
    if GameRules:IsDaytime() then
        return true
    end
    
    -- 调用基类实现
    return self.BaseClass.IsMuted(self)
end
```

### 注意事项

- 必须调用 `self.BaseClass.IsMuted(self)` 作为默认处理
- 锁闭状态会实时生效，无需手动刷新
- 频繁调用时应避免复杂计算

## 完整案例：等级限制装备

### 场景

装备在英雄达到指定等级前处于锁闭状态，达到等级后自动激活。

### KV 定义

```kv
"item_level_gated_example"
{
    "BaseClass"             "item_lua"
    "AbilityTextureName"    "item_example_texture"
    "ScriptFile"            "items/item_level_gated_example"
    
    "AbilityBehavior"       "DOTA_ABILITY_BEHAVIOR_PASSIVE"
    
    "ItemCost"              "0"
    "ItemPurchasable"       "0"
    "ItemSellable"          "0"
    
    "AbilitySpecial"
    {
        "01"
        {
            "var_type"          "FIELD_INTEGER"
            "required_level"    "10"
        }
        "02"
        {
            "var_type"          "FIELD_INTEGER"
            "bonus_damage"      "50"
        }
    }
}
```

### 装备 Lua

```lua
item_level_gated_example = class({})
LinkLuaModifier("modifier_item_level_gated_example", 
    "modifiers/modifier_item_level_gated_example", 
    LUA_MODIFIER_MOTION_NONE)

function item_level_gated_example:GetIntrinsicModifierName()
    return "modifier_item_level_gated_example"
end

-- 初始化：读取等级要求
function item_level_gated_example:Spawn()
    self.required_level = self:GetSpecialValueFor("required_level")
end

-- 等级提升时：达到要求后重新装备以激活效果
function item_level_gated_example:OnHeroLevelUp()
    if IsServer() then
        if self:GetCaster():GetLevel() == self.required_level 
           and self:IsInBackpack() == false then
            self:OnUnequip()
            self:OnEquip()
        end
    end
end

-- 锁闭检查：等级不足时锁闭
function item_level_gated_example:IsMuted()
    if self.required_level > self:GetCaster():GetLevel() then
        return true
    end
    if not self:GetCaster():IsHero() then
        return true
    end
    return self.BaseClass.IsMuted(self)
end
```

### 修饰器 Lua

```lua
modifier_item_level_gated_example = class({})

function modifier_item_level_gated_example:IsHidden()
    return true
end

function modifier_item_level_gated_example:IsPurgable()
    return false
end

function modifier_item_level_gated_example:OnCreated(kv)
    self.bonus_damage = self:GetAbility():GetSpecialValueFor("bonus_damage")
end

function modifier_item_level_gated_example:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
    }
end

function modifier_item_level_gated_example:GetModifierPreAttack_BonusDamage(params)
    return self.bonus_damage
end
```

### 工作流程

```
物品创建
    ↓
Spawn() 读取 required_level = 10
    ↓
英雄等级 5，IsMuted() 返回 true，效果锁闭
    ↓
英雄升级到 10
    ↓
OnHeroLevelUp() 触发，重新装备
    ↓
IsMuted() 返回 false，效果激活
```

## 扩展应用

### 修饰器依赖

```lua
function item_example:IsMuted()
    if not self:GetCaster():HasModifier("modifier_rage") then
        return true
    end
    return self.BaseClass.IsMuted(self)
end
```

### 时间限制

```lua
function item_example:IsMuted()
    if GameRules:GetGameTime() < 600 then  -- 前 10 分钟锁闭
        return true
    end
    return self.BaseClass.IsMuted(self)
end
```

### 组合条件

```lua
function item_example:IsMuted()
    if self.required_level > self:GetCaster():GetLevel() then
        return true
    end
    if not self:GetCaster():HasModifier("modifier_blessing") then
        return true
    end
    return self.BaseClass.IsMuted(self)
end
```
