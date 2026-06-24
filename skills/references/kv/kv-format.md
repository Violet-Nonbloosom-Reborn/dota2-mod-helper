# KeyValue (KV) 文件格式

KV 格式用于 Source 引擎中存储资源元数据、脚本、材质等数据。Dota 2 自定义游戏中用于定义技能、单位、物品、修饰符等。

## 语法结构

KV 采用递归的键值对结构：

```kv
"ParentKey"
{
    "ValueKey"    "1"
    "ChildKey"
    {
        ...
    }
}
```

### 基本规则

- 控制字符：`{`、`}`、`"`
- 键名和值可以加引号或不加引号
- 引号 `"` 必须成对使用，不能出现在键名或值内部（需使用转义序列 `\"`）
- 未加引号的 token 以空白字符、`{`、`}` 或 `"` 结尾
- 加引号的 token 内可使用 `{` 和 `}`
- 每个 token 最长 1024 字符（含引号，实际内容约 1021 字符）
- 部分函数对超过 256 字符的字符串处理不正确

### 空白字符

包括空格、回车、换行、制表符。

### 转义序列

`\n`、`\t`、`\\`、`\"`（需启用 `UsesEscapeSequences`，默认关闭）

## 值类型

KV 值类型自动推断，包括：

- `TYPE_NONE`
- `TYPE_STRING`
- `TYPE_INT`
- `TYPE_FLOAT`
- `TYPE_PTR`
- `TYPE_WSTRING`
- `TYPE_COLOR`

## 注释

支持 C++ 风格单行注释：

```kv
// 这是注释，直到行尾
"Key"    "Value"    // 行尾注释
```

不支持块注释 `/* ... */`。

## 文件包含

### #include

将目标文件的所有键追加到当前文件末尾（包括重复键）：

```kv
// main.txt
#include "extras.txt"

"Key1"    "Value1"
```

```kv
// extras.txt
"Key1"    "Extra1"
"Key2"    "Extra2"
```

加载后 `main.txt` 内容：

```kv
"Key1"    "Value1"
"Key1"    "Extra1"
"Key2"    "Extra2"
```

注意：`#include` 的内容在解析完当前文件后追加，因此即使写在开头，实际内容在末尾。

Dota 2 自定义游戏中 KV 文件使用 `.txt` 后缀（而非 `.vdf`）。

### #base

将目标文件的键与当前文件合并（不覆盖已存在的键）：

```kv
// main.txt
#base "extras.txt"

"Key1"    "Value1"
"List"
{
    "InnerKey1"    "InnerValue1"
}
```

```kv
// extras.txt
"Key1"    "Extra1"
"Key2"    "Extra2"
"List"
{
    "InnerKey1"    "InnerExtra1"
    "InnerKey2"    "InnerExtra2"
}
```

加载后 `main.txt` 内容：

```kv
"Key1"    "Value1"        // 未覆盖
"List"
{
    "InnerKey1"    "InnerValue1"    // 未覆盖
    "InnerKey2"    "InnerExtra2"    // 新增
}
"Key2"    "Extra2"        // 新增
```

## 注意事项

- `#` 字符用于宏指令（如 `#include`、`#base`），不要作为键名的首字符
- 部分函数对超过 256 字符的键名处理不正确
- 使用 `FindKey` 查找包含 `/` 的长键名可能导致缓冲区溢出

---

来源: https://developer.valvesoftware.com/wiki/KeyValues
