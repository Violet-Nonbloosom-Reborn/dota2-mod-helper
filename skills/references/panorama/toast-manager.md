# ToastManager

`ToastManager` 是用于维护短暂消息队列的 Panorama 专用 Panel。先创建一个以 `ToastManager` 为父级的 Panel，设置该 Panel 的内容和样式，再调用 `QueueToast` 将其作为 Toast 显示。

## 基本用法

在 XML 中声明管理器，并为其设置布局样式：

```xml
<ToastManager id="NotificationToasts" />
```

```css
#NotificationToasts
{
    flow-children: down;
}

#NotificationToasts > .ToastPanel
{
    opacity: 0.0;
    transition-property: opacity;
    transition-duration: 0.2s;
}

#NotificationToasts > .ToastPanel.ToastVisible
{
    opacity: 1.0;
}
```

在 JavaScript 中创建 Toast。新 Panel 的父级必须是目标 `ToastManager`：

```javascript
"use strict";

function ShowNotification(text) {
    var toastManager = $("#NotificationToasts");
    if (!toastManager) {
        return;
    }

    var toast = $.CreatePanel("Panel", toastManager, "");
    toast.AddClass("ToastPanel");
    toast.SetAttributeString("toast_duration_override", "10s");

    var label = $.CreatePanel("Label", toast, "");
    label.text = text;

    toastManager.QueueToast(toast);
}
```

`QueueToast(toast)` 将指定 Panel 交由管理器显示和维护。Toast 的入场、淡出和折叠状态可用 CSS 类选择器定义；原生战斗事件 HUD 使用 `.ToastPanel`、`.ToastVisible` 和 `.Collapse`。

## 覆盖单条 Toast 时长

在子 Panel 上设置 `toast_duration_override` 属性，可覆盖该条 Toast 的默认存在时长。例如：

```xml
<Panel toast_duration_override="10s" />
```

也可以在入队前通过 `SetAttributeString` 设置该属性，如基本示例所示。该属性属于 Toast 内容 Panel，不属于 `ToastManager` 的定义。

## 移除 Toast

若需要在其生命周期结束前移除一条消息，向同一管理器传入该 Toast Panel：

```javascript
toastManager.RemoveToast(toast);
```

`toast` 必须是此前创建并交由该 `toastManager` 管理的 Panel。

## 原生战斗事件实例

解包的 `panorama/layout/hud/dota_hud_combat_events.xml` 将原生 `DOTACombatEvents` 中的 `ToastManager` 配置为：

```xml
<ToastManager
    id="ToastManager"
    hittest="false"
    toastduration="10s"
    maxtoastsvisible="50"
    maxtoastbehavior="deleteoldest"
    preservefadedtoasts="true"
    delaytime="0"
    addtoaststohead="false" />
```

其中 `toastduration`、`maxtoastsvisible`、`maxtoastbehavior`、`preservefadedtoasts`、`delaytime` 和 `addtoaststohead` 是该战斗事件 HUD 的具体配置，不是使用 `ToastManager` 的必填属性，也不应据此推断所有 `ToastManager` 实例都需要相同取值。

原生 HUD 由引擎创建 `DOTACombatEventRow` 作为 Toast 内容；自定义 UI 通常创建普通 `Panel` 并自行添加子 Panel、文本和样式。战斗事件的双重垂直翻转、历史消息展开、HUD 镜像布局及击杀音效，均定义在 `panorama/styles/hud/dota_hud_combat_events.css`，属于该原生 HUD 的行为而非 `ToastManager` 的通用要求。

## 注意事项

- Toast 内容 Panel 必须以对应的 `ToastManager` 为父级后再调用 `QueueToast`。
- 为每条 Toast 使用 CSS 类，避免依赖重复的 Panel ID。
- 通过 `RemoveToast` 主动移除仍需持有的 Toast 引用；不要用普通 Panel 删除流程替代管理器操作。
