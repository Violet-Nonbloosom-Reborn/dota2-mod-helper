# 项目结构入门

Dota 2 自定义游戏（Custom Game）以 addon 为单位组织。

自定义游戏一般在 content 和 game 文件夹下各有一个目录。前者放置地图文件、资源文件、Panorama 相关文件等，而后者放置编译后的地图包、资源文件、Panorama 文件，以及本地化文本、脚本等内容。
## 目录总览

```
content/dota_addons/<addon_name>/
├── maps/                               # 地图文件
├── materials/                          # 材质文件
├── models/                             # 模型文件
├── panorama/                           # Panorama UI 文件
├── particles/                          # 粒子效果文件
├── soundevents/
│   └── custom_sounds.vsndevts          # 自定义音效事件
└── sounds/                             # 音频文件

game/dota_addons/<addon_name>/
├── addoninfo.txt                       # 必需 - addon 元配置
├── maps/                               # 编译后的地图包
├── resource/                           # 本地化文本、其他资源文件
├── panorama/
│   └── localization/                   # Panorama UI 本地化
└── scripts/
    ├── npc/
    │   ├── herolist.txt                # 英雄选择列表
    │   ├── npc_abilities_custom.txt    # 自定义技能定义
    │   ├── npc_abilities_override.txt  # 覆盖原有技能
    │   ├── npc_heroes_custom.txt       # 自定义英雄定义
    │   ├── npc_items_custom.txt        # 自定义物品定义
    │   └── npc_units_custom.txt        # 自定义单位定义
    ├── vscripts/
    │   ├── addon_game_mode.lua         # 必需 - 游戏模式入口
    ├── custom_net_tables.txt           # 可选 - 自定义网络表（KV3）
    ├── custom.gameevents               # 可选 - 自定义游戏事件定义
    └── shops.txt                       # 商店物品布局
```

## 核心文件说明

### addoninfo.txt

addon 的主配置文件，定义地图、玩家数、键位等。支持两种格式：

**KV1 格式（传统）：**

```kv
"AddonInfo"
{
    "TeamCount"     "2"
    "maps"          "my_map"
    "IsPlayable"    "1"

    "my_map"
    {
        "MaxPlayers"    "10"
    }

    "Default_Keys"
    {
        "01"
        {
            "Key"       "S"
            "Command"   "CustomGameExecuteAbility1"
            "Name"      "Execute Ability 1"
        }
    }
}
```

**KV3 格式（新版）：**

```kv3
<!-- kv3 encoding:text:version{e21c7f3c-8a33-41c5-9977-a76d3a32aa0d} format:generic:version{7412167c-06e9-4698-aff2-e63eb59037e7} -->
{
    map_options =
    [
        {
            MaxPlayers = 5
            map = "my_map"
        },
    ]
}
```

### addon_game_mode.lua

游戏模式入口脚本，每个 addon 必须包含。基本结构：

```lua
if CAddonGameMode == nil then
    CAddonGameMode = class({})
end

function CAddonGameMode:Precache(context)
    -- 预加载资源（模型、粒子、音效等）
end

function CAddonGameMode:Activate()
    -- addon 激活时调用，创建游戏模式实例
    GameMode = CAddonGameMode()
    GameMode:InitGameMode()
end

function CAddonGameMode:InitGameMode()
    local gameModeEntity = GameRules:GetGameModeEntity()
    -- 配置游戏模式参数
end

function CAddonGameMode:OnThink()
    -- 全局定时回调（可选）
    return 2.0  -- 返回间隔秒数
end
```

## 数据定义与脚本的关系

```
KV 数据定义 (scripts/npc/)          Lua 脚本 (scripts/vscripts/)
┌─────────────────────────┐         ┌─────────────────────────┐
│ npc_abilities_custom.txt │────────▶│ abilities/*.lua          │
│ npc_heroes_custom.txt    │         │ modifiers/*.lua          │
│ npc_items_custom.txt     │────────▶│ items/*.lua              │
│ npc_units_custom.txt     │         │ ai/*.lua                 │
└─────────────────────────┘         └─────────────────────────┘
         ↓ 数据                                  ↓ 逻辑
         └──────────────▶ 运行时 ◀───────────────┘
```

- KV 文件定义静态数据（技能参数、单位属性、物品数值）
- Lua 脚本实现动态逻辑（技能行为、修饰符效果、AI 决策）
- 两者通过名称关联（如 KV 中 `"BaseClass" "ability_lua"` + `"ScriptFile" "abilities/my_ability.lua"`）
