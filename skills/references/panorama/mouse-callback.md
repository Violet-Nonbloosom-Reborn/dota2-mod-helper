# GameUI.SetMouseCallback 模式

注册鼠标回调函数，在主游戏代码处理鼠标之前执行。

## 函数签名

```javascript
GameUI.SetMouseCallback(function(eventName, arg) {
    // 返回 true 消费事件，false 继续处理
});
```

## 回调参数

| eventName | arg | 含义 |
|-----------|-----|------|
| `"pressed"` | `0` | 左键按下 |
| `"pressed"` | `1` | 右键按下 |
| `"wheeled"` | `< 0` | 滚轮向下 |
| `"wheeled"` | `> 0` | 滚轮向上 |

## 返回值

- `true`：消费事件，阻止后续处理
- `false`：继续处理事件

## 约束

- 通过 `GameUI.GetClickBehaviors()` 检查当前点击行为，非 `DOTA_CLICK_BEHAVIOR_NONE` 时应返回 `false`
- 通过 `GameUI.GetCursorPosition()` 获取屏幕坐标
- 通过 `GameUI.GetScreenWorldPosition(screenPos)` 转换为世界坐标
- 通过 `Game.PrepareUnitOrders(order)` 发送单位指令

## 模式：自定义鼠标控制

```javascript
GameUI.SetMouseCallback(function(eventName, arg) {
    var CONSUME = true;
    var CONTINUE = false;

    if (GameUI.GetClickBehaviors() !== CLICK_BEHAVIORS.DOTA_CLICK_BEHAVIOR_NONE)
        return CONTINUE;

    if (eventName === "pressed") {
        if (arg === 0) {
            // 左键：移动到光标位置
            Game.PrepareUnitOrders({
                OrderType: dotaunitorder_t.DOTA_UNIT_ORDER_MOVE_TO_POSITION,
                Position: GameUI.GetScreenWorldPosition(GameUI.GetCursorPosition()),
                Queue: false,
                ShowEffects: false
            });
            return CONSUME;
        }
        if (arg === 1) {
            // 右键：禁用默认行为
            return CONSUME;
        }
    }
    else if (eventName === "wheeled") {
        if (arg < 0) {
            // 滚轮向下：移动
            Game.PrepareUnitOrders({
                OrderType: dotaunitorder_t.DOTA_UNIT_ORDER_MOVE_TO_POSITION,
                Position: GameUI.GetScreenWorldPosition(GameUI.GetCursorPosition()),
                Queue: false,
                ShowEffects: false
            });
            return CONSUME;
        }
        if (arg > 0) {
            // 滚轮向上：攻击移动
            Game.PrepareUnitOrders({
                OrderType: dotaunitorder_t.DOTA_UNIT_ORDER_ATTACK_MOVE,
                Position: GameUI.GetScreenWorldPosition(GameUI.GetCursorPosition()),
                Queue: false,
                ShowEffects: false
            });
            return CONSUME;
        }
    }
    return CONTINUE;
});
```
