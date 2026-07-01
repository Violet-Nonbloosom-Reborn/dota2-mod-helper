# Panorama 访问游戏内对象的方法

Panorama 运行在独立的 JavaScript 引擎中，无法持有游戏对象指针。通过**编号（Index）和字符串（Name）**表示对象，通过 `CScriptBindingPR_*` 绑定函数查询或发送指令。

## 对象标识方式

Panorama 中有以下几种标识游戏对象的方式：

### Entity Index（实体编号）

最通用的标识方式。每个游戏实体（英雄、单位、建筑、技能、物品）在创建时被分配一个唯一的整数编号。

```javascript
var heroIndex = Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer());
var health = Entities.GetHealth(heroIndex);
var unitName = Entities.GetUnitName(heroIndex);
```

### Player ID（玩家编号）

每个玩家有一个从 0 开始的整数 ID。通过 Player ID 可以查询玩家信息、统计数据、关联英雄等。

```javascript
var localPlayer = Players.GetLocalPlayer();
var gold = Players.GetGold(localPlayer);
var heroIndex = Players.GetPlayerHeroEntityIndex(localPlayer);
```

### Buff Serial（修饰器编号）

修饰器（Modifier/Buff）通过 `(entityIndex, buffSerial)` 二元组定位。`buffSerial` 是修饰器在其承载实体上的序列号。

```javascript
var entityIndex = Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer());
var buffCount = Entities.GetNumBuffs(entityIndex);

for (var i = 0; i < buffCount; i++) {
    var buffSerial = Entities.GetBuff(entityIndex, i);
    var name = Buffs.GetName(entityIndex, buffSerial);
    var remaining = Buffs.GetRemainingTime(entityIndex, buffSerial);
}
```

### 字符串名称

部分场景使用字符串作为对象标识，如单位名称（`"npc_dota_hero_pudge"`）、技能名称（`"pudge_hook"`）等。字符串通常作为备用寻址方式，配合 Entity Index 使用。

```javascript
var abilityIndex = Entities.GetAbilityByName(heroIndex, "pudge_hook");
var hasItem = Entities.HasItemInInventory(heroIndex, "item_blink");
```

## 绑定函数与命名空间

所有 C++ 绑定函数通过以下命名空间暴露给 JavaScript：

| 命名空间 | 绑定类名 | 职责 |
|---------|---------|------|
| `Entities` | `CScriptBindingPR_Entities` | 实体属性查询（生命、魔法、护甲、状态判断等） |
| `Players` | `CScriptBindingPR_Players` | 玩家信息查询（统计、英雄关联、观战控制） |
| `Buffs` | `CScriptBindingPR_Buffs` | 修饰器信息查询（名称、层数、剩余时间） |
| `Abilities` | `CScriptBindingPR_Abilities` | 技能属性查询（伤害、冷却、等级、状态） |
| `Items` | `CScriptBindingPR_Items` | 物品属性查询（价格、充数、可否出售/拆分） |
| `Game` | `CScriptBindingPR_Game` | 全局状态与操作（时间、阶段、队伍管理、指令） |

## 只读查询：通过编号获取属性

绝大多数绑定函数是只读的——它们从游戏引擎读取数据并返回给 JavaScript，不产生任何副作用。

### 查询模式

所有只读查询遵循统一模式：**第一个参数为对象编号**。

```javascript
// 实体属性查询
Entities.GetHealth(entityIndex)
Entities.GetMaxHealth(entityIndex)
Entities.GetMana(entityIndex)

// 状态判断
Entities.IsAlive(entityIndex)
Entities.IsStunned(entityIndex)

// 玩家统计
Players.GetGold(playerID)
Players.GetKills(playerID)

// 修饰器信息
Buffs.GetName(entityIndex, buffSerial)
Buffs.GetRemainingTime(entityIndex, buffSerial)

// 技能属性
Abilities.GetManaCost(abilityIndex)
Abilities.GetCooldownTimeRemaining(abilityIndex)

// 物品属性
Items.GetCost(itemIndex)
Items.IsSellable(itemIndex)
```

### 索引验证

实体被销毁后，其 Entity Index 变为无效。调用查询函数不会抛出异常，而是返回默认值（0、false、空字符串）。因此，在使用索引前必须验证有效性：

```javascript
if (Entities.IsValidEntity(targetIndex)) {
    var health = Entities.GetHealth(targetIndex);
    // ...
}
```

这与 Lua VScript 中的检查逻辑本质不同：Lua 持有对象引用，通过 `unit:IsNull()` 检查对象是否已失效；Panorama 始终操作编号，通过 `IsValidEntity(index)` 检查编号是否有效。

## 写操作：通过编号发送指令

部分函数会发送指令或修改状态。这些函数可分为两类：

### 客户端操作

仅影响本地客户端，不发送网络消息：

```javascript
Entities.SetMinimapIcon(entityIndex, "minimap_tower");
Game.EmitSound("General.ClickSound");
```

### 服务端指令

发送指令到服务端，可能改变游戏状态：

```javascript
// 技能操作
Abilities.ExecuteAbility(abilityIndex, casterIndex, false);

// 物品操作
Items.LocalPlayerSellItem(itemIndex);
Items.LocalPlayerMoveItemToStash(itemIndex);

// 单位指令
Game.PrepareUnitOrders({
    OrderType: dotaunitorder_t.DOTA_UNIT_ORDER_ATTACK_TARGET,
    TargetIndex: targetIndex,
    UnitIndex: attackerIndex
});

// 队伍管理
Game.PlayerJoinTeam(teamID);
```

### UI 事件触发

部分函数模拟用户交互，触发 UI 事件：

```javascript
Players.PlayerPortraitClicked(playerID, false, false);
Players.BuffClicked(entityIndex, buffSerial, true);
```

## 设计要点

1. **面向索引编程**：Panorama 中不存在 `unit` 对象。你始终在操作一个 `number`。 这意味着实体被销毁后，编号变为无效但不会抛异常。若持久存储序号，应当在每次使用前验证 `IsValidEntity`。

2. **读写分离**：大部分绑定函数是只读的查询函数。写操作（发送指令、修改状态）数量较少，且通常带有明确的动词前缀（`Execute`、`Attempt`、`LocalPlayer*`、`Prepare`）。

3. **命名空间即模块**：每个 `CScriptBindingPR_*` 类对应一个 JavaScript 命名空间，按职责划分。查询实体用 `Entities`，查询玩家用 `Players`，查询修饰器用 `Buffs`，以此类推。
