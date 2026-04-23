# LIS - Zig 版本使用说明

## 简介

LIS 是一个轻量级的 Windows 目录列表工具，使用 Zig 语言编写。支持颜色输出、长格式显示、配置文件自定义等功能。

## 功能特性

- ✅ 列出当前目录文件和文件夹
- ✅ 彩色输出（文件夹、可执行文件、压缩包等）
- ✅ 支持 `-a` 参数显示隐藏文件
- ✅ 支持 `-l` 参数显示长格式（文件大小、修改时间）
- ✅ 支持 `LIS.cfg` 配置文件自定义颜色
- ✅ 横向/纵向输出模式自动切换

## 编译方法

### 环境要求

- Windows 操作系统
- Zig 编译器（已包含在 `.\zig` 目录中）

### 编译命令

在命令行中执行：

```batch
cd d:\Cobject\vin\lis\ls\lis
.\zig\zig.exe build-exe -O ReleaseSmall -target x86_64-windows-gnu -femit-bin=lis.exe lis.zig
```

### 编译选项说明

| 选项 | 说明 |
|------|------|
| `-O ReleaseSmall` | 优化体积（推荐） |
| `-O ReleaseFast` | 优化速度 |
| `-O ReleaseSafe` | 安全模式（体积较大） |
| `-target x86_64-windows-gnu` | 目标平台为 Windows 64位 |
| `-femit-bin=lis.exe` | 输出文件名 |

### 进一步优化体积

编译完成后，可以使用 UPX 压缩：

```batch
upx --best lis.exe
```

## 使用方法

### 基本用法

```batch
# 横向列出文件（不分行）
lis.exe

# 显示所有文件（包括隐藏文件）
lis.exe -a

# 长格式显示（每个文件一行，显示大小和时间）
lis.exe -l

# 长格式显示所有文件
lis.exe -la
```

### 输出模式说明

| 命令 | 输出模式 |
|------|---------|
| `lis.exe` | 横向输出，文件之间用两个空格分隔 |
| `lis.exe -a` | 横向输出，包含隐藏文件 |
| `lis.exe -l` | 纵向输出，每个文件一行，显示详细信息 |
| `lis.exe -la` | 纵向输出，显示所有文件的详细信息 |

### 颜色说明

默认颜色配置：

- **蓝色** - 文件夹
- **绿色** - 可执行文件（.exe, .com）
- **黄色** - 压缩文件（.zip, .rar, .7z, .tar, .gz）
- **白色** - 其他文件

## 配置文件

### 创建 LIS.cfg

在同一目录下创建 `LIS.cfg` 文件，可以自定义颜色：

```cfg
# 文件夹颜色
folder: blue

# 可执行文件颜色
exe: green
com: green

# 压缩文件颜色
zip: yellow
rar: yellow
7z: yellow
tar: yellow
gz: yellow

# 其他文件类型
txt: cyan
md: brightmagenta
c: brightblue
cpp: brightblue
h: brightblue
py: green
js: yellow
html: brightred
css: magenta
png: brightwhite
jpg: brightwhite
pdf: red
```

### 支持的颜色

#### 基础颜色
- `black` - 黑色
- `red` - 红色
- `green` - 绿色
- `yellow` - 黄色
- `blue` - 蓝色
- `magenta` - 品红
- `cyan` - 青色
- `white` - 白色

#### 亮色
- `brightblack` / `gray` - 亮黑/灰色
- `brightred` - 亮红
- `brightgreen` - 亮绿
- `brightyellow` - 亮黄
- `brightblue` - 亮蓝
- `brightmagenta` - 亮品红
- `brightcyan` - 亮青
- `brightwhite` - 亮白

## 文件结构

```
d:\Cobject\vin\lis\ls\lis\
├── lis.zig              # Zig 源代码
├── lis.exe          # 编译后的可执行文件
├── LIS.cfg              # 颜色配置文件（可选）
├── zig\                 # Zig 编译器目录
│   └── zig.exe
└── README_ZIG.md        # 本说明文档
```

## 示例输出

### 横向输出（默认）

```
folder1/  file1.txt  file2.exe  archive.zip  folder2/
```

### 长格式输出（-l）

```
        0B 2024-01-15 10:30 folder1/
    1.5K 2024-01-14 09:20 file1.txt
   45.2K 2024-01-13 15:45 file2.exe
    2.3M 2024-01-12 08:00 archive.zip
```

## 注意事项

1. **编码支持**: 程序使用 Unicode (UTF-16) 处理文件名，支持中文等特殊字符
2. **Windows 版本**: 需要 Windows 7 或更高版本
3. **终端支持**: 颜色输出需要支持 ANSI 转义序列的终端（Windows 10 及以上默认支持）
4. **文件大小**: 编译后的程序体积约为 20-50 KB（取决于优化选项）

## 故障排除

### 编译错误

如果遇到编译错误，请检查：
- Zig 编译器路径是否正确
- 命令行参数是否正确
- 源代码文件是否完整

### 运行时问题

- **无颜色输出**: 检查终端是否支持 ANSI 颜色，或尝试在 Windows Terminal 中运行
- **中文显示乱码**: 确保使用支持 UTF-8 的终端，或设置代码页 `chcp 65001`
- **配置文件不生效**: 检查 `LIS.cfg` 文件编码是否为 UTF-8，格式是否正确

## 许可证

本程序为开源项目，可自由使用和修改。

## 更新日志

### v1.0
- 初始版本发布
- 支持基本目录列表功能
- 支持颜色输出和配置文件
- 支持长格式显示
