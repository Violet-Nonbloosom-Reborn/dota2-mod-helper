# 中立装备打造池

当用户需要配置中立装备、狂石（Madstone）、分级打造、饰品（artifact / trinket）或附魔（enhancement）时使用本指南。

Dota 2 自定义游戏中的英雄覆写通过 `npc_neutral_items_custom.txt` 文件定义。
## 数据模型

典型结构如下。键名和字段应与项目现有的中立装备实现保持一致。

```kv
"neutral_items"
{
    "madstone_limits"
    {
        // 控制狂石限制的时间阈值；按游戏模式规则设置。
        "madstone_no_limit_time"    "70:00"
    }

    "neutral_tiers"
    {
        "1"
        {
            // 开放时间。使用 MM:SS，且各档开放时间必须递增。
            "start_time"            "7:00"
            // 装备选项数。不能超过 items 中的有效候选数。
            "trinket_options"       "5"
            // 附魔选项数。每种主属性下，global 与属性池的有效候选数均不得少于此值。
            "enhancement_options"   "5"
            // 首次打造的狂石消耗。
            "craft_cost"            "4"
            // 未实现对应逻辑时保持 0。
            "xp_bonus"              "0"

            // 启用重铸时配置，通常仅用于顶级档。
            "recraft_cost"        "5"

            "items" { }
            "enhancements"
            {
                "global" { }
                "strength" { }
                "agility" { }
                "intelligence" { }
                "universal" { }
            }
        }
    }
}
```

## 装备与附魔

`items` 是该档的装备候选池，键名是物品 ID，值固定为 1。

候选池中的物品必须按类型在其 `item_*` 定义中标记：中立装备使用 `"ItemIsNeutralActiveDrop" "1"`，中立装备附魔使用 `"ItemIsNeutralPassiveDrop" "1"`。

`enhancements` 将候选附魔分为：

- `global`：所有英雄可获得的通用附魔。
- `strength`、`agility`、`intelligence`、`universal`：仅对相应主属性英雄追加的附魔。

附魔的值表示附魔等级。例如同一附魔在二档使用 `"2"`、三档使用 `"3"`，表达其数值随档位成长。

## 示例

完整的五档 KV 示例位于 [neutral-items-example.txt](neutral-items-example.txt)。其中包含：

- 五个 `neutral_tiers` 档位。
- 各档的时间、候选数、狂石消耗与五级重铸字段。
- `items` 候选池和按英雄主属性分组的 `enhancements`。

示例仅用于说明 KV 结构与字段写法。
