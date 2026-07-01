# 物品系统

物品是技能的派生类，共用技能的基础字段（`BaseClass`、`AbilityBehavior`、`AbilityValues` 等）。物品特有键以 `Item` 前缀为主。

物品的 ID 必须以 `item_` 开头。

> **注意**：物品共用字段详见 `ability.md`。

## 目录

- [物品特有字段](#物品特有字段)
- [商店与经济](#商店与经济)
- [配方系统](#配方系统)
- [物品行为](#物品行为)
- [库存系统](#库存系统)
- [共享与丢弃](#共享与丢弃)
- [中立物品](#中立物品)
- [示例](#示例)

## 物品特有字段

### 商店与经济

| 字段 | 类型 | 说明 |
|------|------|------|
| `ItemCost` | Integer | 物品价格 |
| `ItemShopTags` | String | 商店标签，分号分隔（如 `damage;mobility`） |
| `ItemQuality` | Enum | 物品品质：`component`、`consumable`、`secret_shop`、`common`、`rare`、`epic`、`artifact` |
| `ItemDeclarations` | Flags | 购买声明：`DECLARE_PURCHASES_TO_TEAMMATES`、`DECLARE_PURCHASES_IN_SPEECH`、`DECLARE_PURCHASES_TO_SPECTATORS` |
| `SideShop` | Boolean | 是否可在边路商店购买 |
| `SecretShop` | Boolean | 是否可在神秘商店购买 |

### 配方系统

| 字段 | 类型 | 说明 |
|------|------|------|
| `ItemRecipe` | Boolean | 标记为配方物品 |
| `ItemResult` | String | 配方合成结果（物品名） |
| `ItemRequirements` | Block | 合成所需物品，按编号分组 |
| `ItemRecipeConsumesCharges` | Boolean | 合成时是否消耗充能 |

配方示例：
```kv
"item_recipe_arcane_blink"
{
    "Model"             "models/props_gameplay/recipe.vmdl"
    "ItemCost"          "1750"
    "ItemShopTags"      ""
    
    "ItemRecipe"        "1"
    "ItemResult"        "item_arcane_blink"
    "ItemRequirements"
    {
        "01"            "item_blink*;item_mystic_staff"
    }
}
```

`*` 后缀表示允许使用已消耗充能的物品。

### 物品行为

| 字段 | 类型 | 说明 |
|------|------|------|
| `ItemPermanent` | Boolean | 是否为永久物品（非消耗品） |
| `ItemStackable` | Boolean | 是否可堆叠 |
| `ItemStackableMax` | Integer | 最大堆叠数 |
| `ItemInitialCharges` | Integer | 初始充能数 |
| `ItemHideCharges` | Boolean | 是否隐藏充能显示 |
| `ItemDisplayCharges` | Boolean | 是否显示充能 |
| `ItemCastOnPickup` | Boolean | 拾取时自动施放 |
| `ItemCanBeConsumed` | Boolean | 是否可被消耗 |
| `ItemCanBeUsedWithoutInventory` | Boolean | 是否在背包内可用 |
| `ItemRequiresCharges` | Boolean | 是否需要充能才能使用 |
| `AssociatedConsumable` | String | 关联的消耗品 |
| `ItemCanBeConsumed` | Boolean | 是否可被消耗 |
| `ItemCanBeUsedWithoutInventory` | Boolean | 是否在背包内可用 |
| `ItemRequiresCharges` | Boolean | 是否需要充能才能使用 |
| `ItemSupport` | Boolean | 是否为辅助物品 |
| `IsObsolete` | Boolean | 是否已废弃 |
| `IsTempestDoubleClonable` | Boolean | 是否可被风暴双雄克隆 |
| `SpeciallyBannedFromNeutralSlot` | Boolean | 禁止放入中立物品栏 |
| `SpeciallyAllowedInNeutralSlot` | Boolean | 允许放入中立物品栏 |
| `AllowedInBackpack` | Boolean | 允许放入背包 |
| `AutoPickup` | Boolean | 自动拾取 |
| `CooldownPausedOutOfInventory` | Boolean | 不在背包时暂停冷却 |
| `PlayerSpecificCooldown` | Boolean | 玩家独立冷却 |
| `BonusDelayedStockCount` | Integer | 延迟补货数量 |

### 库存系统

| 字段 | 类型 | 说明 |
|------|------|------|
| `ItemStockTime` | Float | 补货间隔（秒） |
| `ItemStockMax` | Integer | 最大库存数 |
| `ItemStockInitial` | Integer | 初始库存数 |
| `ItemInitialStockTime` | Float | 初始补货等待时间（秒） |
| `ItemInitialStockTimeTurbo` | Float | 快速模式初始补货等待时间（秒） |

示例（治疗药膏）：
```kv
"ItemStockTime"               "1"
"ItemStockInitial"            "0"
"ItemStockMax"                "1"
"ItemInitialStockTime"        "270.0"
"ItemInitialStockTimeTurbo"   "150.0"
```

### 共享与丢弃

| 字段 | 类型 | 说明 |
|------|------|------|
| `ItemShareability` | Enum | 共享性：`ITEM_NOT_SHAREABLE`、`ITEM_SHAREABLE`、`ITEM_FULLY_SHAREABLE` |
| `ItemDroppable` | Boolean | 是否可丢弃 |
| `ItemKillable` | Boolean | 是否可被摧毁 |
| `ItemSellable` | Boolean | 是否可出售 |
| `ItemInitiallySellable` | Boolean | 初始是否可出售 |
| `ItemAlertable` | Boolean | 是否可提醒队友（“快来，我要使用 xxx 了”） |
| `ItemAllowCombineFromGround` | Boolean | 是否允许从地面合并 |
| `ItemContributesToNetWorthWhenDropped` | Boolean | 丢弃时是否计入财产总和 |
| `ItemDisassembleRule` | Enum | 拆解规则 |

### 中立物品

| 字段 | 类型 | 说明 |
|------|------|------|
| `ItemIsNeutralActiveDrop` | Boolean | 是否为中立装备 |
| `ItemIsNeutralPassiveDrop` | Boolean | 是否为中立装备附魔 |

### 视觉与音效

| 字段 | 类型 | 说明 |
|------|------|------|
| `Effect` | String | 粒子特效路径 |
| `ModelAlternate` | String | 替代模型路径 |
| `ModelScale` | Float | 模型缩放 |
| `UIPickupSound` | String | UI 拾取音效 |
| `UIDropSound` | String | UI 放下音效 |
| `WorldDropSound` | String | 世界掉落音效 |

### UI 提示

| 字段 | 类型 | 说明 |
|------|------|------|
| `DisplayOverheadAlertOnReceived` | Boolean | 收到时显示头顶提示 |
| `ShowDroppedItemTooltip` | Boolean | 显示掉落物品提示 |
| `ShowGiveIndicatorOnTargetCast` | Boolean | 对目标施放时显示给予指示 |
| `PingOverrideText` | String | Ping 覆盖文本 |
| `ActiveDescriptionLine` | String | 主动描述行 |

### 其他

| 字段 | 类型 | 说明 |
|------|------|------|
| `ItemPurchasable` | Boolean | 是否可购买（设为 0 则不出现在商店） |
| `ItemBaseLevel` | Integer | 基础等级 |
| `Model` | String | 物品模型路径 |

## 示例

### 被动物品（基础属性）

```kv
"item_blades_of_attack"
{
    "AbilityBehavior"       "DOTA_ABILITY_BEHAVIOR_PASSIVE"
    
    "ItemCost"              "450"
    "ItemShopTags"          "damage;tutorial"
    "ItemQuality"           "component"
    
    "AbilityValues"
    {
        "bonus_damage"      "9"
    }
}
```

### 消耗品（带充能）

```kv
"item_tango"
{
    "AbilityBehavior"       "DOTA_ABILITY_BEHAVIOR_UNIT_TARGET"
    "AbilityUnitTargetTeam" "DOTA_UNIT_TARGET_TEAM_FRIENDLY"
    "AbilityUnitTargetType" "DOTA_UNIT_TARGET_TREE"
    
    "ItemCost"              "90"
    "ItemShopTags"          "consumable"
    "ItemQuality"           "consumable"
    "ItemStackable"         "0"
    "ItemPermanent"         "0"
    "ItemInitialCharges"    "3"
    
    "AbilityValues"
    {
        "heal_amount"       "115"
        "duration"          "16.0"
    }
}
```

### 主动物品（带冷却）

```kv
"item_blink"
{
    "AbilityBehavior"       "DOTA_ABILITY_BEHAVIOR_POINT | DOTA_ABILITY_BEHAVIOR_DIRECTIONAL"
    
    "AbilityCastRange"      "1200"
    "AbilityCastPoint"      "0.0"
    "AbilityCooldown"       "15.0"
    "AbilitySharedCooldown" "blink"
    
    "ItemCost"              "2250"
    "ItemShopTags"          "teleport;mobility;escape"
    "ItemQuality"           "component"
    "ItemDeclarations"      "DECLARE_PURCHASES_TO_TEAMMATES | DECLARE_PURCHASES_IN_SPEECH"
    
    "AbilityValues"
    {
        "blink_range"       "1200"
        "blink_damage_cooldown" "3.0"
    }
}
```

### 数据驱动物品（带修饰器）

```kv
"item_custom_lifesteal_sword"
{
    "BaseClass"             "item_datadriven"
    "AbilityBehavior"       "DOTA_ABILITY_BEHAVIOR_PASSIVE"
    "AbilityTextureName"    "item_morbidity_mask"
    
    "ItemCost"              "2000"
    "ItemShopTags"          "damage;lifesteal"
    "ItemQuality"           "epic"
    
    "Modifiers"
    {
        "modifier_custom_lifesteal"
        {
            "Passive"       "1"
            "Properties"
            {
                "MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE"      "%bonus_damage"
                "MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT"       "%bonus_regen"
            }
        }
    }
    
    "AbilityValues"
    {
        "bonus_damage"      "40"
        "bonus_regen"       "5"
        "lifesteal_percent" "15"
    }
}
```

## 商店配置

物品在商店中的布局由 `scripts/shops.txt` 定义，使用 KV 格式指定各商店的物品列表。
