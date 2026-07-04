# 概率暴击装备

实现带有概率触发暴击效果的攻击物品。

## 核心机制

### 1. 修饰器事件声明

在 `DeclareFunctions()` 中声明需要响应的事件：

| 事件 | 作用 |
|------|------|
| `MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE` | 提供基础攻击力加成 |
| `MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE` | 判定暴击并返回倍率 |
| `MODIFIER_EVENT_ON_ATTACK_LANDED` | 攻击命中后播放音效 |

### 2. 暴击判定流程

```
攻击前 → GetModifierPreAttack_CriticalStrike() 判定暴击
    ↓
返回倍率（如 2.0）或 0（不暴击）
    ↓
攻击命中 → OnAttackLanded() 播放暴击音效
```

### 3. 关键实现要点

- **暴击判定**：在 `GetModifierPreAttack_CriticalStrike` 中使用 `RandomFloat` 判定
- **状态标记**：用 `self.bIsCrit` 标记本次攻击是否暴击
- **音效同步**：在 `OnAttackLanded` 中根据标记播放音效，确保音效与视觉同步
- **目标过滤**：排除建筑和友军单位

---

## 完整案例：破泞之主的疏浚三叉戟

### 物品 Lua

```lua
item_dredged_trident = class({})
LinkLuaModifier( "modifier_item_dredged_trident", "modifiers/modifier_item_dredged_trident", LUA_MODIFIER_MOTION_NONE )

function item_dredged_trident:GetIntrinsicModifierName()
    return "modifier_item_dredged_trident"
end
```

### 修饰器 Lua

```lua
modifier_item_dredged_trident = class({})

function modifier_item_dredged_trident:IsHidden()
    return true
end

function modifier_item_dredged_trident:IsPurgable()
    return false
end

function modifier_item_dredged_trident:OnCreated( kv )
    self.bonus_damage = self:GetAbility():GetSpecialValueFor( "bonus_damage" )
    self.crit_chance = self:GetAbility():GetSpecialValueFor( "crit_chance" )
    self.crit_multiplier = self:GetAbility():GetSpecialValueFor( "crit_multiplier" )

    self.bIsCrit = false
end

function modifier_item_dredged_trident:DeclareFunctions()
    local funcs =
    {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }
    return funcs
end

function modifier_item_dredged_trident:GetModifierPreAttack_BonusDamage( params )
    return self.bonus_damage
end

function modifier_item_dredged_trident:GetModifierPreAttack_CriticalStrike( params )
    if IsServer() then
        local hTarget = params.target
        local hAttacker = params.attacker

        -- 排除建筑、友军和非英雄单位
        if hTarget and ( hTarget:IsBuilding() == false ) and ( hTarget:IsOther() == false ) and hAttacker and ( hAttacker:GetTeamNumber() ~= hTarget:GetTeamNumber() ) then
            if RandomFloat( 0, 100 ) > self.crit_chance then
                self.bIsCrit = true
                return self.crit_multiplier
            end
        end
    end

    return 0.0
end

function modifier_item_dredged_trident:OnAttackLanded( params )
    if IsServer() then
        if self:GetParent() == params.attacker then
            local hTarget = params.target
            if hTarget ~= nil and self.bIsCrit then
                EmitSoundOn( "DOTA_Item.Daedalus.Crit", self:GetParent() )
                self.bIsCrit = false
            end
        end
    end

    return 0.0
end
```

---

## 扩展应用

### 自定义暴击效果

在 `OnAttackLanded` 中添加视觉特效：

```lua
function modifier_item_dredged_trident:OnAttackLanded( params )
    if IsServer() then
        if self:GetParent() == params.attacker then
            local hTarget = params.target
            if hTarget ~= nil and self.bIsCrit then
                -- 播放音效
                EmitSoundOn( "DOTA_Item.Daedalus.Crit", self:GetParent() )
                
                -- 添加视觉特效
                local particle = ParticleManager:CreateParticle( "particles/items2_fx/daedalus_crit.pcf", PATTACH_ABSORIGIN_FOLLOW, hTarget )
                ParticleManager:ReleaseParticleIndex( particle )
                
                self.bIsCrit = false
            end
        end
    end

    return 0.0
end
```

### 伪随机分布（PRD）

Dota 2 使用伪随机分布提高暴击的公平性。可通过 `RollPseudoRandomPercentage` 实现：

```lua
-- 需要暴露伪随机函数
if RollPseudoRandomPercentage( self.crit_chance, self:GetAbility():GetAbilityIndex(), self:GetParent() ) then
    self.bIsCrit = true
    return self.crit_multiplier
end
```

### 多重暴击叠加

多个暴击物品时，使用 `MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE` 会叠加倍率。如需独立判定，需使用 `MODIFIER_EVENT_ON_ATTACK` 手动处理伤害。
