# KeyValues3（KV3）文件格式

当用户需要创建或编辑带 KV3 文本头的 Dota 2 数据文件时使用本指南。KV3 是 Valve 的数据格式，结构接近 JSON，但支持二进制编码、版本标识和数据注解。

KV3 与 KV1 是不同格式。不要在 KV3 中使用 KV1 的 `"Key" "Value"` 写法、`#include` 或 `#base`。

## 文本头

文本 KV3 文件第一行必须是格式头。它通过 GUID 标识编码与格式版本：

```kv3
<!-- kv3 encoding:text:version{e21c7f3c-8a33-41c5-9977-a76d3a32aa0d} format:generic:version{7412167c-06e9-4698-aff2-e63eb59037e7} -->
```

对于通用文本 KV3，保留该行及其中的 GUID；不要随意改写 GUID。文件主体紧随文本头，以一个对象开始。

## 基本结构

KV3 对象使用花括号，键和值使用 `=` 连接。数组使用方括号。键在常见写法中不加引号；字符串必须使用双引号。

```kv3
<!-- kv3 encoding:text:version{e21c7f3c-8a33-41c5-9977-a76d3a32aa0d} format:generic:version{7412167c-06e9-4698-aff2-e63eb59037e7} -->
{
    enabled = true
    max_players = 10
    display_name = "Example"

    maps =
    [
        "map_a",
        "map_b",
    ]

    options =
    {
        allow_respawn = false
    }
}
```

数组元素可以用逗号分隔，并允许尾随逗号。对象字段通常按行书写，不需要逗号。

## 值与注解

KV3 会保留值的类型。常用值包括：

```kv3
{
    bool_value = false
    int_value = 128
    double_value = 64.000000
    string_value = "hello world"
    particle = resource:"particles/items3_fx/star_emblem.vpcf"
}
```

KV3 可在值前使用注解标记。官方列出的注解包括：

```kv3
resource:"path/to/file"
resourcename:"resource_name"
panorama:"path/to/panel"
soundevent:"event.name"
subclass:"class_name"
```

注解与冒号之间没有空格。只有字段要求特定资源或系统引用时才添加相应注解。

## 注释与多行字符串

KV3 支持单行与块注释：

```kv3
// 单行注释
/*
多行注释
*/
```

多行字符串使用三个未转义双引号。起始引号后和结束引号前必须立即换行；两行之间的内容按字面量保留，普通转义规则不生效。

```kv3
description = """
First line.
Second line.
"""
```

## 编写约束

- 保留文件已有的 KV3 文本头，除非目标文件明确要求另一种格式或编码。
- 使用 `=` 赋值，数组使用 `[]`，对象使用 `{}`；不要混入 KV1 语法。
- 为路径、Panorama 引用或音效事件使用项目要求的注解；普通字符串不要添加注解。
- 保持数组元素之间的逗号，尾随逗号可保留。
- 修改已有文件时遵循其缩进、字段顺序和格式头，不将 KV3 改写为 JSON。

---

来源：项目根目录 `kv3.txt`，Valve Developer Community 的 KeyValues3 格式说明。
