# 自定义商店

如果需要在普通商店、边路商店和神秘商店外设置第四种商店，或者需要动态控制商店售卖品，可以创建自定义商店。

## 地图设置

在地图编辑器中：

1. 选定商店单位，将 `Shop Type` 属性改为 `Custom`，`Name` 属性改为自定义商店 ID
2. 选定商店 Trigger，将 `Shop Type` 属性改为 `Custom`，`Name` 属性改为相同的 ID

## 商店文件

在 `scripts/shops/<map_name>_shops.txt` 的 `custom` 块中定义：

```kv
"dota_shops"
{
    "custom"
    {
        "TestShop"
        {
            "1" // 子商店键
            {
                "item"  "item_clarity"
                "item"  "item_faerie_fire"
                "item"  "item_enchanted_mango"
                "item"  "item_flask"
            }

            "timer"
            {
                "item"  "item_branches"
                "item"  "item_circlet"
            }
        }
    }
}
```

## 子商店

每个自定义商店可划分为多个**子商店**，子商店的键可以是数字或字符串：

- 子商店在商店界面中显示为独立的标签页
- 不同子商店的物品仍在同一个自定义商店下
- 子商店键用于本地化和动态操作

## 本地化

在本地化文件（如 `addon_english.txt`）中添加商店名称和子商店名称：

```kv
"TestShop"          "测试商店"
"DOTA_Subshop_1"      "补给品"
"DOTA_Subshop_timer"  "计时"
```

- 商店名称直接使用商店 ID 作为键
- 子商店名称使用 `DOTA_Subshop_<子商店键>` 格式

## 物品属性 RequiresCustomShop

物品 KV 中可设置 `RequiresCustomShop` 属性，限制该物品只能在自定义商店中购买：

```kv
"item_my_custom_item"
{
    "RequiresCustomShop"    "1"
}
```

在非自定义商店中购买此类物品会报错。

## 动态自定义商店

通过 Lua 函数在运行时动态调整商店物品：

| 函数 | 说明 |
|------|------|
| `AddItemToCustomShop(itemName, shopName, category)` | 向自定义商店添加物品 |
| `RemoveItemFromCustomShop(itemName, shopName)` | 从自定义商店移除物品 |

- `shopName`：自定义商店 ID
- `category`：子商店键
- `itemName`：物品名（如 `"item_clarity"`）

```lua
-- 向 TesterShop 的 "1" 子商店添加物品
AddItemToCustomShop("item_custom_potion", "TesterShop", "1")

-- 从 TesterShop 移除物品
RemoveItemFromCustomShop("item_clarity", "TesterShop")
```
