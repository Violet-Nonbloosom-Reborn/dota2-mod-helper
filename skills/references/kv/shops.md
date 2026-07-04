# 商店配置

Dota 2 自定义游戏可以通过商店配置文件自定义商店内容。

## 文件位置

有两种商店配置文件：

| 文件 | 位置 | 作用 |
|------|------|------|
| `shops.txt` | `scripts/shops.txt` | 覆写赛前商店（`pregame` 系列） |
| `<map_name>_shops.txt` | `scripts/shops/<map_name>_shops.txt` | 定义自定义商店（custom 块） |

**重要**：赛前商店类别（`pregame`、`pregame_consumables`、`pregame_attributes`、`pregame_accessories`）只能通过根目录的 `shops.txt` 覆写，不会被地图专属商店文件覆写。

## 官方商店类别

### 基础物品类别

| 类别 | 说明 | 典型物品 |
|------|------|----------|
| `consumables` | 消耗品 | 回城卷轴、治疗药膏、净化药水、侦查守卫 |
| `attributes` | 基础属性物品 | 树枝、力量手套、敏捷便鞋、智力斗篷 |
| `weapons_armor` | 武器和护甲 | 补刀斧、守护指环、攻击之爪、锁子甲 |
| `misc` | 杂项物品 | 回复戒指、贤者面具、风灵之纹、魔杖 |

### 配方类别（按等级）

| 类别 | 等级 | 颜色 | 说明 |
|------|------|------|------|
| `basics` | 1 | 绿色 | 基础配方（魔杖、力量手套、相位鞋） |
| `support` | 2 | 蓝色 | 辅助配方（奥术鞋、梅肯斯姆、卫士胫甲） |
| `magics` | 2 | 蓝色 | 法器（Eul的神圣法杖、达贡之神力） |
| `defense` | 3 | 紫色 | 防具（刃甲、清莲宝珠、黑皇杖） |
| `weapons` | 3 | 紫色 | 兵刃（暗灭、金箍棒、蝴蝶） |
| `artifacts` | 4 | 橙色 | 圣物（散华、夜叉、冰眼） |

### 特殊商店

| 类别 | 说明 | 覆写方式 |
|------|------|----------|
| `sideshop1` | 边路商店 1 | 待定 |
| `sideshop2` | 边路商店 2 | 待定 |
| `secretshop` | 神秘商店 | 待定 |
| `pregame` | 赛前商店（已废弃） | **仅** `shops.txt` |
| `pregame_consumables` | 赛前消耗品 | **仅** `shops.txt` |
| `pregame_attributes` | 赛前属性物品 | **仅** `shops.txt` |
| `pregame_accessories` | 赛前饰品 | **仅** `shops.txt` |

## 覆写赛前商店

在 `scripts/shops.txt` 中定义赛前商店类别：

```kv
"dota_shops"
{    
    "pregame_consumables"
    {
        "item"  "item_tango"
        "item"  "item_flask"
        // 只列出允许赛前购买的物品
    }
}
```

**注意**：只需定义要修改的类别，未定义的类别保持默认。

## 常见物品标记

使用 `common_items` 标记常见物品：

```kv
"common_items"
{
    "item_tpscroll"             "1"
    "item_tome_of_knowledge"    "1"
    "item_clarity"              "1"
    "item_faerie_fire"          "1"
    "item_enchanted_mango"      "1"
}
```

## 配置示例

### 简化赛前商店

```kv
// scripts/shops.txt
"dota_shops"
{
    "pregame"
    {
        "item"  "item_clarity"
        "item"  "item_faerie_fire"
        "item"  "item_branches"
        "item"  "item_ring_of_protection"
        // 只保留基础物品
    }
}
```

### 添加自定义物品到赛前商店

```kv
// scripts/shops.txt
"dota_shops"
{
    "pregame"
    {
        "item"  "item_clarity"
        "item"  "item_custom_potion"  // 自定义物品
    }
}
```

## 注意事项

1. **赛前商店**（`pregame` 系列）只能通过 `scripts/shops.txt` 覆写
2. 自定义商店（custom 块）定义在 `scripts/shops/<map_name>_shops.txt`，详见 `custom-shops.md`
3. 物品必须先在 `npc_items_custom.txt` 中定义才能添加到商店
4. 未定义的官方类别保持默认配置

## 相关文件

| 文件 | 内容 |
|------|------|
| `item.md` | 物品系统定义 |
| `ability.md` | 技能系统定义（物品共用部分字段） |
| `custom-shops.md` | 自定义商店配置 |
