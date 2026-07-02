# Lua 技能与修饰器

Lua 技能通过 `ability_lua` 基类实现，提供比数据驱动更灵活的逻辑控制。

## 目录

- [设置](#设置)
- [Lua 技能](#lua-技能)
- [Lua 修饰器](#lua-修饰器)
- [完整示例](#完整示例)

---

## 设置

### KV 文件

在 `scripts/npc/npc_abilities_custom.txt` 中定义技能：

```kv
"test_lua_ability"
{
    "BaseClass"         "ability_lua"
    "ScriptFile"        "heroes/hero_name/test_lua_ability"
}
```

其他属性（`AbilityBehavior`、`AbilityCastRange`、`AbilityCooldown`、`AbilityManaCost`、`AbilityValues` 等）在 `ability.md` 中说明。

### Lua 文件

在 `scripts/vscripts/` 下创建对应文件（如 `heroes/hero_name/test_lua_ability.lua`）：

```lua
test_lua_ability = class({})
```

### 函数定义风格

**内联定义**：将函数直接写在 `class({...})` 的参数表中。适用于：
- 返回固定值、self 属性、或简单的 self 方法调用
- 函数体只有一行

```lua
modifier_my_buff = class({
    IsHidden = function() return false end,
    IsDebuff = function() return false end,
    IsPurgable = function() return true end,
    GetEffectName = function() return "particles/generic_gameplay/generic_stunned.vpcf" end,
    GetModifierMoveSpeedBonus_Percentage = function(self) return self.bonus_movespeed end,
})
```

**外部定义**：使用 `function class_name:method_name()` 语法在类外部定义。适用于：
- 包含条件分支、循环、多个 API 调用
- 需要修改状态或执行复杂计算

```lua
function modifier_my_buff:OnCreated(kv)
    if IsServer() then
        self.bonus_movespeed = self:GetAbility():GetSpecialValueFor("movespeed")
    end
end
```

需要注意的是，内联定义返回 self 的属性时，如果它们是通过 `GetSpecialValueFor()` 设置的，则不会在技能升级时自动更新。你需要在 `OnSpellStart` 或者其他时机进行更新。

---

## Lua 技能

### 事件函数

引擎在技能生命周期中调用这些函数：

| 函数 | 说明 | 返回值 |
|------|------|--------|
| `OnSpellStart()` | 施法完成，资源已消耗 | 无 |
| `OnAbilityPhaseStart()` | 施法前摇开始，资源未消耗 | `true` 成功 / `false` 失败 |
| `OnProjectileHit(hTarget, vLocation)` | 弹道命中或到达终点 | `true` 销毁 / `false` 继续 |
| `GetIntrinsicModifierName()` | 返回被动修饰器名称 | 字符串 |
| `OnChannelFinish(bInterrupted)` | 持续施法结束 | 无 |

### 施法行为

**优先使用 KV 设置**：施法行为、冷却时间、施法距离等属性应在 KV 文件中静态定义。仅当需要根据运行时条件（如神杖状态、等级、修饰器层数）动态调整时，才覆盖以下函数。

可覆盖默认行为函数：

| 函数 | 说明 | 返回值 |
|------|------|--------|
| `GetBehavior()` | 施法行为类型 | `DOTA_ABILITY_BEHAVIOR_*` |
| `GetCooldown(nLevel)` | 冷却时间 | 浮点数 |
| `GetCastRange(vLocation, hTarget)` | 施法距离 | 整数 |
| `GetChannelTime()` | 持续施法时间 | 浮点数 |

调用基类默认行为：

```lua
function my_ability:GetBehavior()
    if self:GetCaster():HasModifier("modifier_my_buff") then
        return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
    end
    return self.BaseClass.GetBehavior(self)
end
```

### CastFilter

自定义施法过滤，根据施法类型选择对应函数对：

| 施法类型 | 过滤函数 | 错误函数 |
|----------|----------|----------|
| 单位目标 | `CastFilterResultTarget(hTarget)` | `GetCustomCastErrorTarget(hTarget)` |
| 点目标 | `CastFilterResultLocation(vLocation)` | `GetCustomCastErrorLocation(vLocation)` |
| 无目标 | `CastFilterResult()` | `GetCustomCastError()` |

过滤函数返回 `UnitFilterResult` 枚举（`UF_SUCCESS` / `UF_FAIL_*`），错误函数返回本地化字符串键。

---

## Lua 修饰器

### 设置

1. 创建修饰器文件（如 `modifier_my_buff.lua`）
2. 在关联技能中注册（必须在创建实例前调用）：

```lua
my_ability = class({})
LinkLuaModifier("modifier_my_buff", "heroes/hero_name/my_ability", LUA_MODIFIER_MOTION_NONE)
```

不依赖技能的修饰器（如全局修饰器、系统修饰器）需在 `addon_game_mode.lua` 中集中调用 `LinkLuaModifier()`。

### 运动控制器类型

| 类型 | 说明 |
|------|------|
| `LUA_MODIFIER_MOTION_NONE` | 无运动控制 |
| `LUA_MODIFIER_MOTION_HORIZONTAL` | 水平运动控制 |
| `LUA_MODIFIER_MOTION_VERTICAL` | 垂直运动控制 |
| `LUA_MODIFIER_MOTION_BOTH` | 水平+垂直运动控制 |

### 基础函数

| 函数                | 说明     | 返回值 |
| ----------------- | ------ | --- |
| `OnCreated(kv)`   | 修饰器创建时 | 无   |
| `IsHidden()`      | 是否隐藏   | 布尔值 |
| `IsDebuff()`      | 是否为减益  | 布尔值 |
| `IsPurgable()`    | 是否可驱散  | 布尔值 |
| `GetEffectName()` | 粒子特效名称 | 字符串 |

### 继承限制

通过 `class({}, nil, BaseClass)` 继承的方法，只有不涉及 C++ 内核的部分才能生效。引擎对技能和修饰器的回调函数使用直接查表而非元表链查找，继承的方法在纯 Lua 中可调用，但引擎不会识别。

**受影响**：修饰器（`modifier_*`）、技能（`ability_*`）、物品（`item_*`）的所有引擎回调函数。

**不受影响**：纯 Lua 逻辑（自定义方法、辅助函数等不直接被引擎调用的部分）。

**解决方案**：使用 `Merge()` 或 `vlua.tableadd()` 组合。

**区别**：
- `Merge(t1, t2)`：以第一个表的内容优先
- `vlua.tableadd(t1, t2)`：以第二个表的内容优先

```lua
-- 定义可复用方法
HiddenDebuff = {
    IsHidden = function() return true end,
    IsDebuff = function() return true end,
}

-- 方式一：Merge()（第一个表优先）
modifier_my_debuff = class(Merge({
    GetEffectName = function() return "particles/..." end,
}, HiddenDebuff))

-- 方式二：vlua.tableadd()（第二个表优先）
modifier_my_debuff = class(vlua.tableadd(HiddenDebuff, {
    GetEffectName = function() return "particles/..." end,
}))
```

### DeclareFunctions

声明修饰器影响的属性和事件：

```lua
function modifier_my_buff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }
end
```

属性函数命名规则：`MODIFIER_PROPERTY_*` 对应 `GetModifier*` 函数。

```lua
function modifier_my_buff:GetModifierMoveSpeedBonus_Percentage(params)
    return self.bonus_movespeed
end
```

### OnIntervalThink

定时执行逻辑：

```lua
function modifier_my_buff:OnCreated(kv)
    if IsServer() then
        self:StartIntervalThink(1.0)  -- 每秒触发
    end
end

function modifier_my_buff:OnIntervalThink()
    if IsServer() then
        -- 定时逻辑
        self:IncrementStackCount()
    end
end
```

停止 Think：`self:StartIntervalThink(-1)`

### Thinker

在位置而非单位上应用修饰器效果。使用 `CreateModifierThinker` 创建：

```lua
function my_ability:OnSpellStart()
    CreateModifierThinker(
        self:GetCaster(),           -- 创建者
        self,                       -- 技能
        "modifier_thinker_name",    -- 修饰器名称
        kv,                         -- 参数表
        self:GetCursorPosition(),   -- 位置
        self:GetCaster():GetTeamNumber(),  -- 队伍
        false                       -- 是否 phased
    )
end
```

Thinker 修饰器实现与普通修饰器相同，不过修饰器结束时应使用 `UTIL_Remove(self:GetParent())` 移除 Thinker。

### CheckState

应用修饰器状态（眩晕、隐身等）：

```lua
function modifier_stun:CheckState()
    return {
        [MODIFIER_STATE_STUNNED] = true,
    }
end
```

### 事件函数

在 `DeclareFunctions` 中声明 `MODIFIER_EVENT_*` 后，实现对应函数：

```lua
function modifier_my_buff:OnAttackLanded(params)
    if IsServer() then
        if params.attacker == self:GetParent() then
            -- 攻击命中逻辑
        end
    end
    return 0
end
```

---

## 完整示例

### 技能：位置交换

```lua
-- npc_abilities_custom.txt
-- "BaseClass" "ability_lua"
-- "ScriptFile" "heroes/vengefulspirit/vengefulspirit_nether_swap"

vengefulspirit_nether_swap = class({
    GetAOERadius = function(self) return self:GetSpecialValueFor("radius") end,
})

LinkLuaModifier("modifier_nether_swap_cooldown", "heroes/vengefulspirit/vengefulspirit_nether_swap", LUA_MODIFIER_MOTION_NONE)

function vengefulspirit_nether_swap:CastFilterResultTarget(hTarget)
    if self:GetCaster() == hTarget then
        return UF_FAIL_CUSTOM
    end
    
    if (hTarget:IsCreep() and not self:GetCaster():HasScepter()) or hTarget:IsAncient() then
        return UF_FAIL_CUSTOM
    end
    
    local nResult = UnitFilter(hTarget, DOTA_UNIT_TARGET_TEAM_BOTH, 
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP, 
        DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 
        self:GetCaster():GetTeamNumber())
    
    if nResult ~= UF_SUCCESS then
        return nResult
    end
    
    return UF_SUCCESS
end

function vengefulspirit_nether_swap:GetCustomCastErrorTarget(hTarget)
    if self:GetCaster() == hTarget then
        return "#dota_hud_error_cant_cast_on_self"
    end
    if hTarget:IsAncient() then
        return "#dota_hud_error_cant_cast_on_ancient"
    end
    if hTarget:IsCreep() and not self:GetCaster():HasScepter() then
        return "#dota_hud_error_cant_cast_on_creep"
    end
    return ""
end

function vengefulspirit_nether_swap:OnSpellStart()
    local hCaster = self:GetCaster()
    local hTarget = self:GetCursorTarget()
    
    if hCaster == nil or hTarget == nil or hTarget:TriggerSpellAbsorb(self) then
        return
    end
    
    local vPos1 = hCaster:GetOrigin()
    local vPos2 = hTarget:GetOrigin()
    
    GridNav:DestroyTreesAroundPoint(vPos1, 300, false)
    GridNav:DestroyTreesAroundPoint(vPos2, 300, false)
    
    hCaster:SetOrigin(vPos2)
    hTarget:SetOrigin(vPos1)
    
    FindClearSpaceForUnit(hCaster, vPos2, true)
    FindClearSpaceForUnit(hTarget, vPos1, true)
    
    hTarget:Interrupt()
    
    local nCasterFX = ParticleManager:CreateParticle(
        "particles/units/heroes/hero_vengeful/vengeful_nether_swap.vpcf",
        PATTACH_ABSORIGIN_FOLLOW, hCaster)
    ParticleManager:SetParticleControlEnt(nCasterFX, 1, hTarget, 
        PATTACH_ABSORIGIN_FOLLOW, nil, hTarget:GetOrigin(), false)
    ParticleManager:ReleaseParticleIndex(nCasterFX)
    
    EmitSoundOn("Hero_VengefulSpirit.NetherSwap", hCaster)
    EmitSoundOn("Hero_VengefulSpirit.NetherSwap", hTarget)
end
```

### 修饰器：属性加成

```lua
-- modifier_sven_warcry.lua

modifier_sven_warcry = class({
    IsHidden = function() return false end,
    IsDebuff = function() return false end,
    IsPurgable = function() return true end,
    GetModifierMoveSpeedBonus_Percentage = function(self) return self.bonus_movespeed end,
    GetModifierPhysicalArmorBonus = function(self) return self.bonus_armor end,
})

function modifier_sven_warcry:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
    }
end

function modifier_sven_warcry:OnCreated(kv)
    self.bonus_movespeed = self:GetAbility():GetSpecialValueFor("warcry_movespeed")
    self.bonus_armor = self:GetAbility():GetSpecialValueFor("warcry_armor")
end

function modifier_sven_warcry:OnRefresh(kv)
    self:OnCreated(kv)
end
```

### 修饰器：眩晕状态

```lua
modifier_stun = class({
    IsDebuff = function() return true end,
    IsStunDebuff = function() return true end,
    GetEffectName = function() return "particles/generic_gameplay/generic_stunned.vpcf" end,
    GetEffectAttachType = function() return PATTACH_OVERHEAD_FOLLOW end,
    GetOverrideAnimation = function() return ACT_DOTA_DISABLED end,
})

function modifier_stun:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
    }
end

function modifier_stun:CheckState()
    return {
        [MODIFIER_STATE_STUNNED] = true,
    }
end
```

---

来源: https://developer.valvesoftware.com/wiki/Dota_2_Workshop_Tools/Lua_Abilities_and_Modifiers
