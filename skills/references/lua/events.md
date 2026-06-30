# 游戏事件系统

## 目录

- [内置游戏事件](#内置游戏事件)
  - [ListenToGameEvent](#listentogameevent)
  - [回调函数](#回调函数)
  - [类方法处理](#类方法处理)
- [自定义游戏事件](#自定义游戏事件)
  - [服务器到客户端](#服务器到客户端)
  - [客户端到服务器](#客户端到服务器)
  - [客户端监听](#客户端监听)
- [常用事件](#常用事件)

---

## 内置游戏事件

### ListenToGameEvent

```lua
ListenToGameEvent(eventName, functionToCall, context)
```

参数说明：
- `eventName`: 事件名称（如 `"dota_player_gained_level"`）
- `functionToCall`: 回调函数
- `context`: 传递给回调函数的上下文对象（可为 `nil`）

### 回调函数

回调函数接收一个包含事件数据的表：

```lua
function OnPlayerLeveled(event)
    local playerID = event.player_id
    local level = event.level
    local hero = EntIndexToHScript(event.hero_entindex)
end

ListenToGameEvent("dota_player_gained_level", OnPlayerLeveled, nil)
```

### 类方法处理

当回调函数是类方法时，需要传递实例作为 context：

```lua
MyGameMode = class({})

function MyGameMode:Init()
    self.killCount = 0
    ListenToGameEvent("entity_killed", MyGameMode.OnEntityKilled, self)
end

function MyGameMode:OnEntityKilled(event)
    self.killCount = self.killCount + 1
    print("Total kills: " .. self.killCount)
end
```

可使用 `Dynamic_Wrap` 支持热重载：

```lua
ListenToGameEvent("entity_killed", Dynamic_Wrap(MyGameMode, "OnEntityKilled"), self)
```

> **注意**：`Dynamic_Wrap` 使得每次事件触发时会重新查找函数引用，支持 `script_reload` 控制台命令。

---

## 自定义游戏事件

### 服务器到客户端

```lua
-- 发送给所有客户端
CustomGameEventManager:Send_ServerToAllClients("my_event", {
    key1 = "value1",
    key2 = 42
})

-- 发送给特定队伍
CustomGameEventManager:Send_ServerToTeam(teamNumber, "my_event", data)

-- 发送给特定玩家
CustomGameEventManager:Send_ServerToPlayer(playerEntity, "my_event", data)
```
### 客户端到服务器

```javascript
// 客户端 JavaScript
GameEvents.sendCustomGameEventToServer("my_event", {
    key1: "value1",
    key2: 42
});
```

```lua
-- 服务器 Lua
function OnClientEvent(eventSourceIndex, args)
    local player = EntIndexToHScript(eventSourceIndex)
    print("Event from " .. player:GetName() .. ": " .. args.key1)
end

CustomGameEventManager:RegisterListener("my_event", OnClientEvent)
```
### 客户端监听

```javascript
// JavaScript
function OnMyEvent(event) {
    $.Msg("Received: " + event.key1);
}

GameEvents.Subscribe("my_event", OnMyEvent);
```

---

## 常用事件

| 事件名称                       | 触发时机   | 关键字段                                                         |
| -------------------------- | ------ | ------------------------------------------------------------ |
| `dota_player_gained_level` | 玩家升级   | `player_id`, `level`, `hero_entindex`                        |
| `entity_killed`            | 实体死亡   | `entindex_killed`, `entindex_attacker`, `entindex_inflictor` |
| `dota_player_pick_hero`    | 玩家选择英雄 | `player`, `heroindex`, `hero`                                |
| `npc_spawned`              | NPC 生成 | `entindex`                                                   |

> **提示**：使用 `pairs(event)` 遍历事件表查看所有可用字段。

---

来源: 
- https://developer.valvesoftware.com/wiki/Dota_2_Workshop_Tools/Scripting/Listening_to_game_events
- https://developer.valvesoftware.com/wiki/Dota_2_Workshop_Tools/Custom_Game_Events
