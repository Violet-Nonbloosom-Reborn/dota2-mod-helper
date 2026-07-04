# 物品案例：生命护符（物品上限溢出机制）

当玩家持有的某类物品达到上限时，新获得的物品会自动弹出到地面。

## KV 定义

```kv
"item_life_rune"
{
    "BaseClass"             "item_lua"
    "AbilityTextureName"    "item_life_rune"
    "ScriptFile"            "items/item_life_rune"
    
    "AbilityBehavior"       "DOTA_ABILITY_BEHAVIOR_IMMEDIATE | DOTA_ABILITY_BEHAVIOR_IGNORE_CHANNEL"
    "Model"                 "models/gameplay/1up.vmdl"
    
    "ItemCost"              "99999"
    "ItemPurchasable"       "0"
    "ItemStackable"         "1"
    "ItemShareability"      "ITEM_FULLY_SHAREABLE"
    "ItemPermanent"         "0"
    "ItemInitialCharges"    "1"
    "ItemCastOnPickup"      "0"
}
```

## Lua 实现

```lua
function item_life_rune:OnSpellStart()
    if IsServer() then
        if self:GetCaster() ~= nil and self:GetCaster():IsRealHero() then
            if self:GetCaster().nRespawnsRemaining >= nMAX_RESPAWNS then
                local newItem = CreateItem("item_life_rune", nil, nil)
                newItem:SetPurchaseTime(0)
                local drop = CreateItemOnPositionSync(self:GetCaster():GetAbsOrigin(), newItem)
                local dropTarget = self:GetCaster():GetAbsOrigin() + RandomVector(RandomFloat(50, 150))
                newItem:LaunchLoot(false, 150, 0.75, dropTarget)
                self:SpendCharge()
                return
            end
            
            self:GetCaster().nRespawnsRemaining = math.min(
                self:GetCaster().nRespawnsRemaining + 1, 
                nMAX_RESPAWNS
            )
        end
        self:SpendCharge()
    end
end
```

## 关键 API

| API | 说明 |
|-----|------|
| `CreateItem(itemName, owner, ability)` | 创建物品实例 |
| `CreateItemOnPositionSync(origin, item)` | 在指定位置创建物品掉落 |
| `item:LaunchLoot(unknown, height, duration, target)` | 将物品弹出到目标位置 |
| `item:SetPurchaseTime(time)` | 设置购买时间（0 表示免费） |

## 应用场景

- 复活次数上限（如生命护符）
- 资源收集上限（如金币袋、经验书）
- 任务物品上限（如钥匙、符文）
