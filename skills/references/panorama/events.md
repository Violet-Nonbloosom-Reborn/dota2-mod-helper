# Panorama 事件系统

事件是面板间通信的机制。大多数接受 JS 函数的位置也可接受事件。

## 事件语法

### 基本用法

```xml
<Button class="DemoButton" onactivate="ToggleStyle( Toggled )" />
```

### 多事件（分号分隔）

```xml
<Button onactivate="ToggleStyle( Toggled ); AddStyle( HasBeenActivated )" />
```

### 事件嵌套

事件可接受其他事件作为参数：

```xml
<!-- 0.5 秒后切换样式 -->
<Button onactivate="AsyncEvent( 0.5, ToggleStyle( Toggled ) )" />
```

## 事件路由

事件在特定面板上触发，但未必由该面板处理。路由算法：

1. 触发事件的面板首先尝试处理
2. 未处理则沿父级链向上传递，每级父面板依次尝试
3. 若所有父级均未处理，调用已注册的"未处理事件处理器"

**用途**：子面板触发的事件可由父面板统一处理。例如子按钮触发 `ScrollToTop()`，实际由父级滚动面板处理。

## Panel 事件

Panel 事件的第一个参数可选地指定目标面板 ID：

```xml
<Panel id="Controls">
    <!-- 无第一参数：作用于触发事件的面板自身 -->
    <Button id="Control1" onactivate="AddStyle( Clicked )" />

    <!-- 第一参数指定目标：作用于 #Controls -->
    <Button id="Control2" onactivate="AddStyle( Controls, Clicked )" />

    <!-- 可跨层级引用同文件内的面板 -->
    <Button id="Control3" onactivate="AddStyle( SomeOtherPanel, Clicked )" />
</Panel>
<Panel id="SomeOtherPanel" />
```

**约束**：Panel 事件只能通过 ID 查找**同一 XML 文件内**的面板。

### JS 中触发事件

```javascript
myPanel.SetPanelEvent("onmouseover", function() {
    $.DispatchEvent("DOTAShowTextTooltip", myPanel, "This is my tooltip!");
});
```

## 默认事件属性

| 属性 | 触发条件 |
|------|----------|
| `onload` | 面板加载完成 |
| `onactivate` | 面板被激活（鼠标、键盘或手柄） |
| `onmouseactivate` | 鼠标激活 |
| `oncontextmenu` | 右键点击 |
| `onfocus` | 获得键盘焦点 |
| `onblur` | 失去键盘焦点 |
| `ondescendantfocus` | 子面板获得键盘焦点 |
| `ondescendantblur` | 子面板失去键盘焦点 |
| `oncancel` | 按下 ESC |
| `onmouseover` | 鼠标悬停进入 |
| `onmouseout` | 鼠标悬停离开 |
| `ondblclick` | 双击 |
| `onmoveup` / `onmovedown` / `onmoveleft` / `onmoveright` | 方向键导航 |
| `ontabforward` / `ontabbackward` | Tab / Shift+Tab 导航 |
| `onselect` / `ondeselect` | 获得/失去 `:selected` 伪类 |
| `onscrolledtobottom` | 滚动到底部 |
| `onscrolledtorightedge` | 滚动到右边缘 |
| `ontextentrysubmit` | 文本输入提交 |
| `ontextentrychange` | 文本输入变化 |
| `oninputsubmit` | 输入提交 |
| `onvaluechanged` | 值变化 |
| `onpopupsdismissed` | 弹窗关闭 |
| `onmousemove` | 鼠标移动 |

## 常用内置事件

### 样式操作（Panel 事件）

| 事件 | 说明 |
|------|------|
| `AddStyle( class )` | 添加 CSS 类 |
| `RemoveStyle( class )` | 移除 CSS 类 |
| `ToggleStyle( class )` | 切换 CSS 类 |
| `TriggerStyle( class )` | 移除后立即重新添加（用于重触发动画/音效） |
| `SwitchStyle( slot, class )` | 切换属性槽位的类 |
| `AddStyleAfterDelay( class, delay )` | 延迟后添加类 |
| `RemoveStyleAfterDelay( class, delay )` | 延迟后移除类 |
| `AddTimedStyle( class, duration, pre-delay )` | 限时添加类 |
| `AddStyleToEachChild( class )` | 为所有子面板添加类 |
| `RemoveStyleFromEachChild( class )` | 从所有子面板移除类 |

### 条件事件（Panel 事件）

| 事件 | 说明 |
|------|------|
| `IfHasClassEvent( class, event )` | 面板有指定类时触发事件 |
| `IfNotHasClassEvent( class, event )` | 面板无指定类时触发事件 |
| `IfHoverOtherEvent( panelID, event )` | 悬停在指定面板上时触发事件 |
| `IfNotHoverOtherEvent( panelID, event )` | 未悬停在指定面板上时触发事件 |

### 控制（Panel 事件）

| 事件 | 说明 |
|------|------|
| `SetPanelSelected( bool )` | 设置 `:selected` 状态 |
| `TogglePanelSelected()` | 切换 `:selected` 状态 |
| `SetChildPanelsSelected( bool )` | 设置子面板 `:selected` 状态 |
| `SetPanelEnabled( bool )` | 设置面板是否启用 |
| `SetInputFocus()` | 设置输入焦点 |
| `DropInputFocus()` | 释放输入焦点 |

### 滚动（Panel 事件 / 全局事件）

| 事件 | Panel 事件 | 说明 |
|------|-----------|------|
| `ScrollToTop()` | 是 | 滚动到顶部 |
| `ScrollToBottom()` | 是 | 滚动到底部 |
| `ScrollPanelDown()` / `Up()` / `Left()` / `Right()` | 是 | 滚动一行 |
| `PagePanelDown()` / `Up()` / `Left()` / `Right()` | 是 | 滚动一页 |
| `ScrollDown()` / `Up()` / `Left()` / `Right()` | 否 | 滚动一行（非 Panel 事件） |
| `PageDown()` / `Up()` / `Left()` / `Right()` | 否 | 滚动一页（非 Panel 事件） |

### 延迟

| 事件 | 说明 |
|------|------|
| `AsyncEvent( delay, event )` | 延迟（秒）后触发指定事件 |

### 工具提示

| 事件 | 说明 |
|------|------|
| `DOTAShowTextTooltip( text )` | 显示文本工具提示 |
| `DOTAShowTextTooltipStyled( text, style )` | 显示带 CSS 类的文本工具提示 |
| `DOTAShowTitleTextTooltip( title, text )` | 显示标题+文本工具提示 |
| `DOTAShowTitleImageTextTooltip( title, imagePath, text )` | 显示标题+图片+文本工具提示 |
| `DOTAShowAbilityTooltip( abilityName )` | 显示技能工具提示 |
| `DOTAShowBuffTooltip( entityIndex, buffSerial, bOnEnemy )` | 显示修饰器工具提示 |
| `DOTAHideTextTooltip()` | 隐藏文本工具提示 |
| `DOTAHideAbilityTooltip()` | 隐藏技能工具提示 |
| `DOTAHideBuffTooltip()` | 隐藏修饰器工具提示 |

完整事件列表通过 `dump_panorama_events` 控制台命令获取。
