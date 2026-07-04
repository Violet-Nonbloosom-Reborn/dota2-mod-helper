# 状态持续时间减少装备

实现减少特定状态效果（眩晕、缠绕等）持续时间的装备。

## 核心机制

### 1. 状态变化监听

使用 `MODIFIER_EVENT_ON_STATE_CHANGED` 监听修饰器状态变化：

```lua
function modifier:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_STATE_CHANGED,
    }
end
```

### 2. 持续时间修改流程

```
状态变化 → OnStateChanged() 触发
    ↓
遍历所有修饰器 FindAllModifiers()
    ↓
筛选目标修饰器（如 IsStunDebuff()）
    ↓
检查是否已处理（避免重复）
    ↓
SetDuration() 修改持续时间
```

### 3. 关键函数

| 函数 | 作用 |
|------|------|
| `FindAllModifiers()` | 获取单位所有修饰器 |
| `IsStunDebuff()` | 判断是否为眩晕减益 |
| `GetDuration()` | 获取修饰器总持续时间 |
| `SetDuration(duration, update)` | 设置持续时间并刷新 |

### 4. 关键实现要点

- **标记防重复**：用自定义字段（如 `bBaldricApplied`）标记已处理的修饰器
- **来源验证**：排除自身施加的减益（`buff:GetCaster() ~= self:GetParent()`）
- **百分比计算**：`new_duration = old_duration * resist_pct / 100`

---

## 完整案例：波格达斯的肩带

### 物品 Lua

```lua
item_bogduggs_baldric = class({})
LinkLuaModifier( "modifier_item_bogduggs_baldric", "modifiers/modifier_item_bogduggs_baldric", LUA_MODIFIER_MOTION_NONE )

function item_bogduggs_baldric:GetIntrinsicModifierName()
    return "modifier_item_bogduggs_baldric"
end
```

### 修饰器 Lua

```lua
modifier_item_bogduggs_baldric = class({})

function modifier_item_bogduggs_baldric:IsHidden() 
    return true
end

function modifier_item_bogduggs_baldric:IsPurgable()
    return false
end

function modifier_item_bogduggs_baldric:OnCreated( kv )
    self.bonus_armor = self:GetAbility():GetSpecialValueFor( "bonus_armor" )
    self.disable_resist_pct = self:GetAbility():GetSpecialValueFor( "disable_resist_pct" )
    self.move_speed_penalty = self:GetAbility():GetSpecialValueFor( "move_speed_penalty" )
end

function modifier_item_bogduggs_baldric:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_EVENT_ON_STATE_CHANGED,
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
    }
    return funcs
end

function modifier_item_bogduggs_baldric:GetModifierPhysicalArmorBonus( params )
    return self.bonus_armor
end

function modifier_item_bogduggs_baldric:GetModifierMoveSpeedBonus_Constant( params )
    return -self.move_speed_penalty
end

function modifier_item_bogduggs_baldric:OnStateChanged( params )
    if IsServer() then
        if params.unit == self:GetParent() then
            local buffs = self:GetParent():FindAllModifiers()
            for _,buff in pairs( buffs ) do
                -- 筛选眩晕减益且未处理且来自敌方
                if buff ~= nil and buff:IsStunDebuff() and buff.bBaldricApplied == nil and buff:GetCaster() ~= self:GetParent() then
                    buff.bBaldricApplied = true
                    -- 减少持续时间
                    buff:SetDuration( buff:GetDuration() * self.disable_resist_pct / 100, true )
                end
            end 
        end
    end
end
```

---

## 扩展应用

### 多种状态类型减少

同时减少多种状态的持续时间：

```lua
function modifier:OnStateChanged( params )
    if IsServer() and params.unit == self:GetParent() then
        local buffs = self:GetParent():FindAllModifiers()
        for _,buff in pairs( buffs ) do
            if buff ~= nil and buff.bBaldricApplied == nil and buff:GetCaster() ~= self:GetParent() then
                -- 使用 CheckStateToTable() 检查状态
                local stateTable = buff:CheckStateToTable()
                if stateTable[MODIFIER_STATE_STUNNED] or stateTable[MODIFIER_STATE_ROOTED] or stateTable[MODIFIER_STATE_SILENCED] then
                    buff.bBaldricApplied = true
                    buff:SetDuration( buff:GetDuration() * self.disable_resist_pct / 100, true )
                end
            end
        end
    end
end
```

### 按状态名称筛选

针对特定修饰器名称进行处理：

```lua
function modifier:OnStateChanged( params )
    if IsServer() and params.unit == self:GetParent() then
        local buffs = self:GetParent():FindAllModifiers()
        for _,buff in pairs( buffs ) do
            if buff ~= nil and buff.bBaldricApplied == nil then
                local name = buff:GetName()
                -- 仅对特定修饰器生效
                if name == "modifier_stun" or name == "modifier_rooted" then
                    buff.bBaldricApplied = true
                    buff:SetDuration( buff:GetDuration() * self.disable_resist_pct / 100, true )
                end
            end
        end
    end
end
```

### 固定时间减少

减少固定秒数而非百分比：

```lua
function modifier:OnStateChanged( params )
    if IsServer() and params.unit == self:GetParent() then
        local buffs = self:GetParent():FindAllModifiers()
        for _,buff in pairs( buffs ) do
            if buff ~= nil and buff:IsStunDebuff() and buff.bBaldricApplied == nil and buff:GetCaster() ~= self:GetParent() then
                buff.bBaldricApplied = true
                local new_duration = math.max( 0, buff:GetDuration() - self.fixed_reduction )
                buff:SetDuration( new_duration, true )
            end
        end
    end
end
```

### 条件触发减少

仅在特定条件下减少持续时间：

```lua
function modifier:OnStateChanged( params )
    if IsServer() and params.unit == self:GetParent() then
        local parent = self:GetParent()
        local hp_pct = parent:GetHealth() / parent:GetMaxHealth()
        
        -- 仅在生命值低于 50% 时生效
        if hp_pct < 0.5 then
            local buffs = parent:FindAllModifiers()
            for _,buff in pairs( buffs ) do
                if buff ~= nil and buff:IsStunDebuff() and buff.bBaldricApplied == nil and buff:GetCaster() ~= parent then
                    buff.bBaldricApplied = true
                    buff:SetDuration( buff:GetDuration() * self.disable_resist_pct / 100, true )
                end
            end
        end
    end
end
```

---

## 注意事项

- **标记字段命名**：使用唯一前缀避免与其他修饰器冲突（如 `bBaldricApplied`）
- **SetDuration 第二个参数**：设为 `true` 表示立即刷新剩余时间
- **性能考虑**：`FindAllModifiers()` 遍历所有修饰器，避免频繁调用
- **与状态免疫的区别**：
  - 状态免疫（`CheckState()`）：完全阻止状态生效
  - 持续时间减少：状态仍生效，但时间缩短

---

## 相关状态判断函数

| 函数 | 作用 |
|------|------|
| `IsStunDebuff()` | 判断是否为眩晕减益 |
| `IsDebuff()` | 判断是否为减益 |
| `IsHidden()` | 判断是否隐藏 |
| `IsPurgable()` | 判断是否可驱散 |
| `CheckStateToTable()` | 返回修饰器设置的状态表，可检查特定状态常量 |

**使用 CheckStateToTable() 检查状态**：

```lua
local stateTable = buff:CheckStateToTable()
if stateTable[MODIFIER_STATE_STUNNED] then
    -- 修饰器设置了眩晕状态
end
if stateTable[MODIFIER_STATE_ROOTED] then
    -- 修饰器设置了缠绕状态
end
if stateTable[MODIFIER_STATE_SILENCED] then
    -- 修饰器设置了沉默状态
end
```
