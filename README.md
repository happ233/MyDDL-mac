# MyDDL

一个简洁的 macOS 原生任务排期管理工具，使用 SwiftUI 构建。

## 功能特性

### 日历视图
- **月视图**：概览整月任务分布
- **周视图**：查看一周任务安排
- **日视图**：专注单日任务详情
- 支持拖拽任务调整日期
- 多日任务拖拽自动拆分

### 任务管理
- 创建/编辑/删除任务
- 设置任务开始和结束日期
- 按项目分类管理
- 任务颜色根据名称自动分配

### 需求管理
- 需求状态追踪：开发中、测试中、已上线、已废弃
- 任务与需求自动关联
- 需求优先级（P0-P3）

### 项目管理
- 多项目支持
- 自定义项目颜色
- 按项目筛选任务

## 系统要求

- macOS 14.0+
- Xcode 15.0+ (开发)

## 构建运行

```bash
# 克隆项目
git clone <repository-url>
cd MyDDL

# 构建
swift build

# 运行
.build/debug/MyDDL

# 或者安装到本地
cp .build/debug/MyDDL ~/Applications/MyDDL.app/Contents/MacOS/
```

## 项目结构

```
MyDDL/
├── Package.swift           # Swift Package 配置
├── MyDDL/
│   ├── MyDDLApp.swift     # 应用入口
│   ├── ContentView.swift  # 主视图
│   ├── Models/            # 数据模型
│   │   ├── Task.swift
│   │   ├── Project.swift
│   │   ├── Requirement.swift
│   │   └── DataStore.swift
│   ├── Views/
│   │   ├── CalendarViews/  # 日历相关视图
│   │   ├── TaskViews/      # 任务相关视图
│   │   ├── ProjectViews/   # 项目相关视图
│   │   ├── RequirementViews/
│   │   └── Components/     # 通用组件
│   └── Utils/
│       ├── DesignSystem.swift  # 设计系统
│       ├── DateExtensions.swift
│       └── AppSettings.swift
└── Resources/
    └── Assets.xcassets
```

## 数据存储

应用数据存储在 UserDefaults 中：
- 位置：`~/Library/Preferences/MyDDL.plist`
- 清除数据：`defaults delete MyDDL`

## 快捷操作

- **双击日期**：快速创建任务
- **Option + 点击**：选择日期范围创建任务
- **拖拽任务**：调整任务日期
- **右键任务**：快速修改状态

## 技术栈

- SwiftUI
- Swift Package Manager
- UserDefaults (数据持久化)

## License

MIT
