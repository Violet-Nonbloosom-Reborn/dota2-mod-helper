# Custom UI Manifest

UI 入口文件，声明需要加载的自定义 UI 元素和脚本。

**路径**：`content/dota_addons/ADDON_NAME/panorama/layout/custom_game/custom_ui_manifest.xml`

## 结构

```xml
<root>
    <scripts>
        <include src="file://{resources}/scripts/custom_game/main.js" />
    </scripts>

    <Panel>
        <CustomUIElement type="HudTopBar" layoutfile="file://{resources}/layout/custom_game/scoreboard.xml" />
    </Panel>
</root>
```

## 约束

- `<root>` 内只能有一个无 ID 的 `<Panel>`
- 同一 `type` 可注册多个 `<CustomUIElement>`，按声明顺序层叠
- 加载界面（`custom_loading_screen.xml`）不走 manifest，独立加载

## CustomUIElement 属性

| 属性 | 类型 | 说明 |
|------|------|------|
| `type` | string | UI 类型，见下表 |
| `layoutfile` | string | XML 文件路径，使用 `file://{resources}/` 前缀 |

## CustomUIElement 类型

| type | 说明 | 可见时机 |
|------|------|----------|
| `Hud` | 游戏 HUD | 英雄选择后 |
| `HudTopBar` | 类似 Hud，但结算界面也可见 | 英雄选择后至结算 |
| `HeroSelection` | 英雄选择界面 | 游戏设置后、开始前 |
| `GameInfo` | 自定义游戏信息面板（"i" 键） | 游戏设置起至游戏结束 |
| `GameSetup` | 游戏设置界面（队伍选择、投票等） | 游戏开始前 |
| `FlyoutScoreboard` | 弹出式记分板 | `+showscores` 触发时 |
| `EndScreen` | 结算界面 | 游戏结束后 |

## 禁用默认 UI

通过 `GameUI.SetDefaultUIEnabled` 在独立 JS 文件中控制：

```javascript
GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_TOP_TIMEOFDAY, false);
```

### 可禁用的默认 UI 元素

| 枚举值 | 说明 |
|--------|------|
| `DOTA_DEFAULT_UI_ACTION_MINIMAP` | 小地图 |
| `DOTA_DEFAULT_UI_ACTION_PANEL` | 技能操作面板 |
| `DOTA_DEFAULT_UI_ENDGAME` | 结算记分板 |
| `DOTA_DEFAULT_UI_FLYOUT_SCOREBOARD` | 左侧弹出记分板 |
| `DOTA_DEFAULT_UI_HERO_SELECTION_CLOCK` | 英雄选择倒计时 |
| `DOTA_DEFAULT_UI_HERO_SELECTION_GAME_NAME` | 英雄选择模式名称 |
| `DOTA_DEFAULT_UI_HERO_SELECTION_TEAMS` | 英雄选择队伍列表 |
| `DOTA_DEFAULT_UI_INVENTORY_COURIER` | 信使控制 |
| `DOTA_DEFAULT_UI_INVENTORY_GOLD` | 金币显示 |
| `DOTA_DEFAULT_UI_INVENTORY_ITEMS` | 物品栏 |
| `DOTA_DEFAULT_UI_INVENTORY_PANEL` | 整个物品栏 UI |
| `DOTA_DEFAULT_UI_INVENTORY_PROTECT` | 守卫按钮 |
| `DOTA_DEFAULT_UI_INVENTORY_QUICKBUY` | 快速购买 |
| `DOTA_DEFAULT_UI_INVENTORY_SHOP` | 商店区域 |
| `DOTA_DEFAULT_UI_QUICK_STATS` | 左上角 K/D/A 和补刀统计 |
| `DOTA_DEFAULT_UI_SHOP_SUGGESTEDITEMS` | 推荐物品面板 |
| `DOTA_DEFAULT_UI_TOP_BAR` | 顶部栏 |
| `DOTA_DEFAULT_UI_TOP_BAR_BACKGROUND` | 顶部栏背景 |
| `DOTA_DEFAULT_UI_TOP_BAR_DIRE_TEAM` | 顶部栏夜魇队伍 |
| `DOTA_DEFAULT_UI_TOP_BAR_RADIANT_TEAM` | 顶部栏天辉队伍 |
| `DOTA_DEFAULT_UI_TOP_BAR_SCORE` | 顶部栏比分 |
| `DOTA_DEFAULT_UI_TOP_HEROES` | 顶部英雄和比分 |
| `DOTA_DEFAULT_UI_TOP_MENU_BUTTONS` | 左上角菜单按钮 |
| `DOTA_DEFAULT_UI_TOP_TIMEOFDAY` | 昼夜时钟 |
