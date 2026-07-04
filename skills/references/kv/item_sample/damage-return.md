# 反弹伤害装备

实现受到伤害时反弹部分伤害给攻击者的装备。

## 核心机制

### 1. 事件监听

使用 `MODIFIER_EVENT_ON_TAKEDAMAGE` 监听受伤事件：

```lua
function modifier:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_TAKEDAMAGE,
    }
end
```

### 2. 反弹伤害流程

```
单位受伤 → OnTakeDamage() 触发
    ↓
验证攻击者有效性（非自身、非友军）
    ↓
计算反弹伤害（原伤害 × 反弹比例）
    ↓
ApplyDamage() 对攻击者造成伤害
```

### 3. 关键实现要点

- **伤害计算**：`params.damage * damage_return_pct / 100`
- **伤害标志**：
  - `DOTA_DAMAGE_FLAG_REFLECTION`：标记为反弹伤害
  - `DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL`：禁止触发技能吸血
- **伤害类型**：继承原始伤害类型（物理/魔法/纯粹）
- **来源验证**：确保反弹给原始攻击者，而非自身或友军

---

## 完整案例：卡尔丁甲壳

### 物品 Lua

```lua
item_carapace_of_qaldin = class({})
LinkLuaModifier( "modifier_item_carapace_of_qaldin", "modifiers/modifier_item_carapace_of_qaldin", LUA_MODIFIER_MOTION_NONE )

function item_carapace_of_qaldin:GetIntrinsicModifierName()
    return "modifier_item_carapace_of_qaldin"
end
```

### 修饰器 Lua

```lua
modifier_item_carapace_of_qaldin = class({})

function modifier_item_carapace_of_qaldin:IsHidden()
    return true
end

function modifier_item_carapace_of_qaldin:IsPurgable()
    return false
end

function modifier_item_carapace_of_qaldin:OnCreated( kv )
    self.bonus_hp = self:GetAbility():GetSpecialValueFor( "bonus_hp" )
    self.bonus_mana = self:GetAbility():GetSpecialValueFor( "bonus_mana" )
    self.bonus_restore_pct = self:GetAbility():GetSpecialValueFor( "bonus_restore_pct" )
    self.damage_return_pct = self:GetAbility():GetSpecialValueFor( "damage_return_pct" )
end

function modifier_item_carapace_of_qaldin:DeclareFunctions()
    local funcs =
    {
        MODIFIER_PROPERTY_HEALTH_BONUS,
        MODIFIER_PROPERTY_MANA_BONUS,
        MODIFIER_PROPERTY_HEAL_AMPLIFY_PERCENTAGE,
        MODIFIER_EVENT_ON_TAKEDAMAGE,
    }
    return funcs
end

function modifier_item_carapace_of_qaldin:GetModifierHealthBonus( params )
    return self.bonus_hp
end

function modifier_item_carapace_of_qaldin:GetModifierManaBonus( params )
    return self.bonus_mana
end

function modifier_item_carapace_of_qaldin:GetModifierHealAmplify_Percentage( params )
    return self.bonus_restore_pct
end

function modifier_item_carapace_of_qaldin:OnTakeDamage( params )
    if IsServer() then
        -- 确保是自身受伤
        if params.unit ~= self:GetParent() then
            return
        end

        local Attacker = params.attacker
        -- 验证攻击者有效且为敌方
        if Attacker ~= nil and Attacker ~= self:GetParent() and Attacker:GetTeamNumber() ~= self:GetParent():GetTeamNumber() then
            local damageInfo = 
            {
                victim = Attacker,
                attacker = self:GetParent(),
                damage = params.damage * self.damage_return_pct / 100,
                damage_type = params.damage_type,
                damage_flags = DOTA_DAMAGE_FLAG_REFLECTION + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL,
                ability = self:GetAbility(), 
            }
            ApplyDamage( damageInfo )
        end
    end
    return 0
end
```

---

## 扩展应用

### 固定伤害反弹

反弹固定数值而非百分比：

```lua
function modifier:OnTakeDamage( params )
    if IsServer() and params.unit == self:GetParent() then
        local Attacker = params.attacker
        if Attacker and Attacker ~= self:GetParent() and Attacker:GetTeamNumber() ~= self:GetParent():GetTeamNumber() then
            ApplyDamage({
                victim = Attacker,
                attacker = self:GetParent(),
                damage = self.fixed_return_damage,
                damage_type = DAMAGE_TYPE_PHYSICAL,
                damage_flags = DOTA_DAMAGE_FLAG_REFLECTION,
                ability = self:GetAbility(),
            })
        end
    end
    return 0
end
```

### 条件触发反弹

仅在特定条件下反弹（如生命值低于阈值）：

```lua
function modifier:OnTakeDamage( params )
    if IsServer() and params.unit == self:GetParent() then
        local parent = self:GetParent()
        local hp_pct = parent:GetHealth() / parent:GetMaxHealth()
        
        -- 仅在生命值低于 30% 时反弹
        if hp_pct < 0.3 then
            local Attacker = params.attacker
            if Attacker and Attacker:GetTeamNumber() ~= parent:GetTeamNumber() then
                ApplyDamage({
                    victim = Attacker,
                    attacker = parent,
                    damage = params.damage * self.damage_return_pct / 100,
                    damage_type = params.damage_type,
                    damage_flags = DOTA_DAMAGE_FLAG_REFLECTION,
                    ability = self:GetAbility(),
                })
            end
        end
    end
    return 0
end
```

### 反弹伤害类型转换

将反弹伤害转换为特定类型：

```lua
local damageInfo = {
    victim = Attacker,
    attacker = self:GetParent(),
    damage = params.damage * self.damage_return_pct / 100,
    damage_type = DAMAGE_TYPE_PURE,  -- 强制为纯粹伤害
    damage_flags = DOTA_DAMAGE_FLAG_REFLECTION + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL,
    ability = self:GetAbility(),
}
ApplyDamage( damageInfo )
```

### 反弹上限限制

限制单次反弹的最大伤害：

```lua
function modifier:OnTakeDamage( params )
    if IsServer() and params.unit == self:GetParent() then
        local Attacker = params.attacker
        if Attacker and Attacker:GetTeamNumber() ~= self:GetParent():GetTeamNumber() then
            local return_damage = params.damage * self.damage_return_pct / 100
            -- 限制最大反弹伤害
            return_damage = math.min(return_damage, self.max_return_damage)
            
            ApplyDamage({
                victim = Attacker,
                attacker = self:GetParent(),
                damage = return_damage,
                damage_type = params.damage_type,
                damage_flags = DOTA_DAMAGE_FLAG_REFLECTION,
                ability = self:GetAbility(),
            })
        end
    end
    return 0
end
```

---

## 注意事项

- **避免无限反弹**：确保反弹伤害不会触发连锁反弹（使用 `DOTA_DAMAGE_FLAG_REFLECTION` 标志）
- **性能考虑**：频繁的伤害计算可能影响性能，必要时添加冷却机制
- **伤害标志组合**：
  - `DOTA_DAMAGE_FLAG_REFLECTION`：标记为反弹，防止触发某些特效
  - `DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL`：禁止技能吸血
  - `DOTA_DAMAGE_FLAG_NO_SPELL_ARMOR`：无视魔法抗性（如需物理反弹）
