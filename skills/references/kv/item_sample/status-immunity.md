# 状态免疫装备

实现免疫特定状态效果（缠绕、缴械、沉默等）的装备。

## 核心机制

### 1. CheckState() 函数

通过 `CheckState()` 返回状态表，覆盖其他修饰器设置的状态：

```lua
function modifier:CheckState()
    local state = 
    {
        [MODIFIER_STATE_ROOTED] = false,  -- 免疫缠绕
        [MODIFIER_STATE_DISARMED] = false, -- 免疫缴械
    }
    return state
end
```

### 2. 优先级设置

使用 `GetPriority()` 确保免疫修饰器优先级高于施加状态的修饰器：

```lua
function modifier:GetPriority()
    return MODIFIER_PRIORITY_HIGH
end
```

### 3. 常见状态常量

| 状态常量 | 效果 |
|---------|------|
| `MODIFIER_STATE_ROOTED` | 缠绕（无法移动） |
| `MODIFIER_STATE_DISARMED` | 缴械（无法攻击） |
| `MODIFIER_STATE_SILENCED` | 沉默（无法施法） |
| `MODIFIER_STATE_STUNNED` | 眩晕 |
| `MODIFIER_STATE_HEXED` | 妖术 |
| `MODIFIER_STATE_BREAK` | 破坏（禁用被动） |
| `MODIFIER_STATE_MUTED` | 禁用物品 |
| `MODIFIER_STATE_NO_ATTACK` | 禁止攻击 |

---

## 完整案例：卫士之壳

### 物品 Lua

```lua
item_guardian_shell = class({})
LinkLuaModifier( "modifier_item_guardian_shell", "modifiers/modifier_item_guardian_shell", LUA_MODIFIER_MOTION_NONE )

function item_guardian_shell:GetIntrinsicModifierName()
    return "modifier_item_guardian_shell"
end
```

### 修饰器 Lua

```lua
modifier_item_guardian_shell = class({})

function modifier_item_guardian_shell:IsHidden() 
    return true
end

function modifier_item_guardian_shell:IsPurgable()
    return false
end

-- 免疫缠绕
function modifier_item_guardian_shell:CheckState()
    local state = 
    {
        [MODIFIER_STATE_ROOTED] = false,
    }
    return state
end

-- 高优先级确保覆盖其他修饰器
function modifier_item_guardian_shell:GetPriority()
    return MODIFIER_PRIORITY_HIGH
end

function modifier_item_guardian_shell:OnCreated( kv )
    self.bonus_armor = self:GetAbility():GetSpecialValueFor( "bonus_armor" )
    self.magic_resistance = self:GetAbility():GetSpecialValueFor( "magic_resistance" )
    -- 记录当前移速作为最低移速保护
    self.flMoveSpeed = self:GetParent():GetIdealSpeedNoSlows()
    self:StartIntervalThink( 0.5 )
end

function modifier_item_guardian_shell:OnIntervalThink()
    self.flMoveSpeed = self:GetParent():GetIdealSpeedNoSlows()
end

function modifier_item_guardian_shell:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
        MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE_MIN,
    }
    return funcs
end

function modifier_item_guardian_shell:GetModifierPhysicalArmorBonus( params )
    return self.bonus_armor
end

function modifier_item_guardian_shell:GetModifierMagicalResistanceBonus( params )
    return self.magic_resistance
end

-- 最低移速保护
function modifier_item_guardian_shell:GetModifierMoveSpeed_AbsoluteMin( params )
    return self.flMoveSpeed
end
```

---

## 扩展应用

### 多重状态免疫

同时免疫多种状态效果：

```lua
function modifier:CheckState()
    local state = 
    {
        [MODIFIER_STATE_ROOTED] = false,      -- 免疫缠绕
        [MODIFIER_STATE_DISARMED] = false,    -- 免疫缴械
        [MODIFIER_STATE_SILENCED] = false,    -- 免疫沉默
        [MODIFIER_STATE_BREAK] = false,       -- 免疫破坏
    }
    return state
end
```

### 条件免疫

仅在特定条件下免疫（如生命值低于阈值）：

```lua
function modifier:CheckState()
    local parent = self:GetParent()
    local hp_pct = parent:GetHealth() / parent:GetMaxHealth()
    
    local state = {}
    
    -- 仅在生命值低于 30% 时免疫控制
    if hp_pct < 0.3 then
        state[MODIFIER_STATE_ROOTED] = false
        state[MODIFIER_STATE_DISARMED] = false
        state[MODIFIER_STATE_STUNNED] = false
    end
    
    return state
end
```

### 限时免疫

配合计时器实现限时免疫效果：

```lua
function modifier:OnCreated( kv )
    self.immunity_duration = kv.duration or 5
    self:StartIntervalThink( 0.1 )
end

function modifier:CheckState()
    -- 在持续时间内免疫
    if self:GetElapsedTime() < self.immunity_duration then
        return {
            [MODIFIER_STATE_ROOTED] = false,
            [MODIFIER_STATE_DISARMED] = false,
        }
    end
    return {}
end
```

### 免疫特定来源

仅免疫来自特定类型伤害的状态：

```lua
function modifier:CheckState()
    local state = {}
    
    -- 检查最近的伤害来源
    local last_damage = self:GetParent().last_damage_info
    if last_damage and last_damage.attacker then
        -- 仅免疫来自英雄的控制效果
        if last_damage.attacker:IsHero() then
            state[MODIFIER_STATE_ROOTED] = false
            state[MODIFIER_STATE_DISARMED] = false
        end
    end
    
    return state
end
```

---

## 注意事项

- **优先级至关重要**：`MODIFIER_PRIORITY_HIGH` 确保免疫修饰器覆盖施加状态的修饰器
- **状态覆盖顺序**：多个修饰器设置同一状态时，优先级高的覆盖低的
- **性能考虑**：`CheckState()` 每帧调用，避免复杂计算
- **与其他免疫机制的区别**：
  - `CheckState()` 返回 `false`：强制免疫该状态
  - `MODIFIER_STATE_NO_ATTACK`：完全禁止攻击（不同于缴械）
  - `IsStunDebuff()`：判断是否为眩晕减益（用于计算抗性）

---

## 优先级常量

| 优先级 | 值 | 用途 |
|-------|---|------|
| `MODIFIER_PRIORITY_LOW` | 0 | 默认优先级 |
| `MODIFIER_PRIORITY_NORMAL` | 1 | 普通优先级 |
| `MODIFIER_PRIORITY_HIGH` | 2 | 高优先级（免疫修饰器常用） |
| `MODIFIER_PRIORITY_SUPER_ULTRA` | 3 | 最高优先级 |
