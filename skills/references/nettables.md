# 网络表（Custom Nettables）

## 目录

- [概述](#概述)
- [表注册](#表注册)
- [服务器端（Lua）](#服务器端lua)
  - [写入数据](#写入数据)
  - [注意事项](#注意事项)
- [客户端（JavaScript）](#客户端javascript)
  - [读取数据](#读取数据)
  - [订阅变化](#订阅变化)
- [使用场景](#使用场景)

---

## 概述

网络表是服务器和客户端之间的共享数据结构。与一次性消息传递不同，网络表中的数据是**持久化**的，客户端可以随时查询当前值，断线重连后数据会自动重建。

---

## 表注册

在 `scripts/custom_net_tables.txt` 中声明表名。该文件使用 KV3 格式：

```kv3
<!-- kv3 encoding:text:version{e21c7f3c-8a33-41c5-9977-a76d3a32aa0d} format:generic:version{7412167c-06e9-4698-aff2-e63eb59037e7} -->
{
    custom_net_tables =
    [
        "game_state",
        "player_stats"
    ]
}
```

> **注意**：未在此文件中声明的表名无法使用。

---

## 服务器端（Lua）

### 写入数据

```lua
-- 设置整个表
CustomNetTables:SetTableValue("game_state", "score", {
    radiant = 10,
    dire = 5
})

-- 设置单个玩家数据
CustomNetTables:SetTableValue("player_stats", "player_123", {
    kills = 5,
    deaths = 2,
    assists = 8
})
```

### 注意事项

- **单次更新限制**：最大 16384 字节，超过会导致引擎报错崩溃
- **同步粒度**：当某个 key 的值变化时，**整个 key 的值**会被同步到所有客户端（同表的其他 key 不受影响）
- **频繁变化的值**：应分开存储在不同的 key 中，减少不必要的网络流量

```lua
-- 不好：每次更新都会同步整个大表
CustomNetTables:SetTableValue("game", "data", {
    time = GameRules:GetGameTime(),
    score = score,
    -- ... 很多其他字段
})

-- 好：只同步变化的部分
CustomNetTables:SetTableValue("game", "time", { value = GameRules:GetGameTime() })
CustomNetTables:SetTableValue("game", "score", { value = score })
```

---

## 客户端（JavaScript）

### 读取数据

```javascript
// 获取整个表的所有 key
let allValues = CustomNetTables.GetAllTableValues("game_state");
$.Msg(allValues);
// 输出: { score: { radiant: 10, dire: 5 }, time: { value: 123.45 } }

// 获取特定 key 的值
let score = CustomNetTables.GetTableValue("game_state", "score");
$.Msg(score);
// 输出: { radiant: 10, dire: 5 }
```

### 订阅变化

```javascript
// 监听表变化
function OnGameStateChanged(tableName, key, data) {
    $.Msg("表 " + tableName + " 的 " + key + " 已更新:");
    $.Msg(data);
}

CustomNetTables.SubscribeNetTableListener("game_state", OnGameStateChanged);
```

> **注意**：由于网络延迟，客户端发送事件后服务器修改网络表，客户端看到更新可能有一定延迟。

---

## 使用场景

| 场景 | 说明 |
|------|------|
| **游戏状态同步** | 分数、倒计时、波次信息 |
| **玩家自定义数据** | 击杀数、死亡数、助攻数 |
| **UI 状态共享** | 当前选中的目标、技能冷却状态 |
| **配置数据** | 游戏模式参数、难度设置 |

---

## 网络表 vs 自定义事件

| 特性 | 网络表 | 自定义事件 |
|------|--------|-----------|
| **数据持久性** | 持久化存储 | 一次性消息 |
| **查询方式** | 可随时查询当前值 | 需订阅监听 |
| **适用场景** | 状态同步 | 消息通知 |
| **断线重连** | 自动重建 | 丢失历史消息 |
| **数据方向** | 服务器 → 客户端 | 双向 |

**选择建议**：
- 需要**持续跟踪**的状态 → 使用网络表
- 需要**即时通知**的事件 → 使用自定义事件

---

来源: https://developer.valvesoftware.com/wiki/Dota_2_Workshop_Tools/Custom_Nettables
