# 技能吸血装备

实现技能伤害转化为生命值的装备（老式实现方式）。

## 核心机制

### 1. 事件监听

使用 `MODIFIER_EVENT_ON_TAKEDAMAGE` 监听伤害事件：

```lua
function modifier:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_TAKEDAMAGE,
    }
end
```

### 2. 技能吸血流程

```
造成伤害 → OnTakeDamage() 触发
    ↓
验证攻击者、技能、目标有效性
    ↓
排除反射伤害和禁止吸血标记
    ↓
计算吸血量（伤害 × 吸血比例）
    ↓
Attacker:Heal() 治疗攻击者
```

### 3. 关键实现要点

- **来源验证**：确保 `Attacker == self:GetParent()`（自身造成的伤害）
- **技能验证**：确保 `Ability ~= nil`（技能造成的伤害，非普攻）
- **标记排除**：
  - `DOTA_DAMAGE_FLAG_REFLECTION`：反射伤害不触发吸血
  - `DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL`：禁止技能吸血的伤害
- **治疗函数**：`Attacker:Heal(amount, ability)` 进行治疗

---

## 完整案例：长爪护符

### 物品 Lua

```lua
item_longclaws_amulet = class({})
LinkLuaModifier( "modifier_item_longclaws_amulet", "modifiers/modifier_item_longclaws_amulet", LUA_MODIFIER_MOTION_NONE )

function item_longclaws_amulet:GetIntrinsicModifierName()
    return "modifier_item_longclaws_amulet"
end
```

### 修饰器 Lua

```lua
modifier_item_longclaws_amulet = class({})

function modifier_item_longclaws_amulet:IsHidden()
    return true
end

function modifier_item_longclaws_amulet:IsPurgable()
    return false
end

function modifier_item_longclaws_amulet:OnCreated( kv )
    self.spell_lifesteal_pct = self:GetAbility():GetSpecialValueFor( "spell_lifesteal_pct" )
    self.cooldown_reduction_pct = self:GetAbility():GetSpecialValueFor( "cooldown_reduction_pct" )
    self.mana_cost_reduction_pct = self:GetAbility():GetSpecialValueFor( "mana_cost_reduction_pct" )
end

function modifier_item_longclaws_amulet:DeclareFunctions()
    local funcs =
    {
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE_STACKING,
        MODIFIER_PROPERTY_MANACOST_PERCENTAGE,
        MODIFIER_PROPERTY_UNIT_STATS_NEEDS_REFRESH,
        MODIFIER_EVENT_ON_TAKEDAMAGE,
    }
    return funcs
end

function modifier_item_longclaws_amulet:GetModifierPercentageCooldownStacking( params )
    return self.cooldown_reduction_pct
end

function modifier_item_longclaws_amulet:GetModifierPercentageManacost( params )
    return self.mana_cost_reduction_pct
end

function modifier_item_longclaws_amulet:GetModifierUnitStatsNeedsRefresh( params )
    return 1
end

function modifier_item_longclaws_amulet:OnTakeDamage( params )
    if IsServer() then
        local Attacker = params.attacker
        local Target = params.unit
        local Ability = params.inflictor
        local flDamage = params.damage

        -- 验证攻击者、技能、目标有效性
        if Attacker ~= self:GetParent() or Ability == nil or Target == nil then
            return 0
        end

        -- 排除反射伤害
        if bit.band( params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION ) == DOTA_DAMAGE_FLAG_REFLECTION then
            return 0
        end
        
        -- 排除禁止技能吸血的伤害
        if bit.band( params.damage_flags, DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL ) == DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL then
            return 0
        end

        -- 播放吸血特效
        local nFXIndex = ParticleManager:CreateParticle( "particles/items3_fx/octarine_core_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, Attacker )
        ParticleManager:ReleaseParticleIndex( nFXIndex )

        -- 计算并应用治疗
        local flLifesteal = flDamage * self.spell_lifesteal_pct / 100
        -- 参数：治疗量, 来源技能, 攻击吸血, 治疗增幅, 来源单位, 技能吸血
        Attacker:HealWithParams( flLifesteal, self:GetAbility(), false, true, Attacker, true )
    end
    return 0
end
```

---

## 扩展应用

### 条件吸血

仅在特定条件下触发吸血（如生命值低于阈值）：

```lua
function modifier:OnTakeDamage( params )
    if IsServer() then
        local Attacker = params.attacker
        local Target = params.unit
        local Ability = params.inflictor
        local flDamage = params.damage

        if Attacker ~= self:GetParent() or Ability == nil or Target == nil then
            return 0
        end

        -- 仅在生命值低于 50% 时触发吸血
        local hp_pct = Attacker:GetHealth() / Attacker:GetMaxHealth()
        if hp_pct >= 0.5 then
            return 0
        end

        local flLifesteal = flDamage * self.spell_lifesteal_pct / 100
        Attacker:HealWithParams( flLifesteal, self:GetAbility(), false, true, Attacker, true )
    end
    return 0
end
```

### 对特定伤害类型吸血

仅对特定类型的伤害触发吸血：

```lua
function modifier:OnTakeDamage( params )
    if IsServer() then
        local Attacker = params.attacker
        local Target = params.unit
        local Ability = params.inflictor
        local flDamage = params.damage

        if Attacker ~= self:GetParent() or Ability == nil or Target == nil then
            return 0
        end

        -- 仅对魔法伤害吸血
        if params.damage_type ~= DAMAGE_TYPE_MAGICAL then
            return 0
        end

        local flLifesteal = flDamage * self.spell_lifesteal_pct / 100
        Attacker:HealWithParams( flLifesteal, self:GetAbility(), false, true, Attacker, true )
    end
    return 0
end
```

### 吸血上限限制

限制单次吸血的最大值：

```lua
function modifier:OnTakeDamage( params )
    if IsServer() then
        local Attacker = params.attacker
        local Target = params.unit
        local Ability = params.inflictor
        local flDamage = params.damage

        if Attacker ~= self:GetParent() or Ability == nil or Target == nil then
            return 0
        end

        local flLifesteal = flDamage * self.spell_lifesteal_pct / 100
        
        -- 限制最大吸血量
        flLifesteal = math.min( flLifesteal, self.max_lifesteal )
        
        Attacker:HealWithParams( flLifesteal, self:GetAbility(), false, true, Attacker, true )
    end
    return 0
end
```

### 对特定单位类型吸血

仅对特定类型的单位造成伤害时触发吸血：

```lua
function modifier:OnTakeDamage( params )
    if IsServer() then
        local Attacker = params.attacker
        local Target = params.unit
        local Ability = params.inflictor
        local flDamage = params.damage

        if Attacker ~= self:GetParent() or Ability == nil or Target == nil then
            return 0
        end

        -- 仅对英雄造成伤害时吸血
        if not Target:IsHero() then
            return 0
        end

        local flLifesteal = flDamage * self.spell_lifesteal_pct / 100
        Attacker:HealWithParams( flLifesteal, self:GetAbility(), false, true, Attacker, true )
    end
    return 0
end
```

---

## 注意事项

- **老式实现**：此方法通过监听伤害事件手动计算吸血，是早期的实现方式
- **现代替代**：可使用 `MODIFIER_PROPERTY_SPELL_LIFESTEAL_AMPLIFY_PERCENTAGE` 属性实现更简洁的技能吸血
- **性能考虑**：每次伤害都会触发回调，避免复杂计算
- **HealWithParams 参数**：
  - `amount`：治疗量
  - `inflictor`：来源技能/物品
  - `lifesteal`：是否视为攻击吸血（false）
  - `amplify`：是否受治疗增幅影响（true）
  - `source`：来源单位
  - `spellLifesteal`：是否视为技能吸血（true）
- **标记组合**：
  - `DOTA_DAMAGE_FLAG_REFLECTION`：反射伤害
  - `DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL`：禁止技能吸血
  - `DOTA_DAMAGE_FLAG_HP_LOSS`：生命值损失（不触发吸血）

---

## 相关伤害标记

| 标记 | 作用 |
|------|------|
| `DOTA_DAMAGE_FLAG_NONE` | 无特殊标记 |
| `DOTA_DAMAGE_FLAG_IGNORES_MAGIC_IMMUNITY` | 无视魔法免疫 |
| `DOTA_DAMAGE_FLAG_IGNORES_ARMOR` | 无视护甲 |
| `DOTA_DAMAGE_FLAG_REFLECTION` | 反射伤害（不触发技能吸血） |
| `DOTA_DAMAGE_FLAG_HP_LOSS` | 生命值损失（不触发吸血） |
| `DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL` | 禁止技能吸血 |
| `DOTA_DAMAGE_FLAG_NON_MAGICAL` | 非魔法伤害（受魔法免疫影响） |
