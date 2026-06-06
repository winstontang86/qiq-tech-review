# qiq-tech-review

> 互联网后台技术方案的多维度系统化评审 Skill。

> 版本号以 [SKILL.md](./SKILL.md) frontmatter 的 `version` 字段为**单一来源**，同时也是报告头部记录的版本号。

## 它能做什么

面向后台 / 分布式 / 微服务 / 数据系统 / 高并发系统的技术方案评审场景，按统一流程做 9 大维度系统化检查，并产出可仲裁的严重程度与上线门禁结论，避免"只看到自己关心的那一面"。

- **覆盖 9 大维度**：正确性 / 完整功能实现、容错 / 可用性、性能、安全、关键存储与数据结构、关键逻辑详细度、运维、简洁性、API 兼容性、仓库规则与禁用项。
- **两种执行模式**：
  - 正式评审模式（默认）：缺关键上下文必须追问，输出"是否可上线"门禁结论。
  - 初步扫描模式：允许带假设快速过一遍，仅输出风险清单，不下门禁结论。
- **统一严重程度与冲突仲裁**：跨维度发现按统一标准定级（Blocker / High / Medium / Low / Info），冲突项给出仲裁建议。
- **5 类强制对账矩阵**：功能完整性 / NFR 满足度 / 关键存储与数据结构齐备度 / 关键逻辑详细度 / 仓库规则违反清单。
- **结构化产出**：基于 [templates/review-report.md](./templates/review-report.md) 输出最终报告。

## 何时使用 / 不适用

启用条件（任一即可）：

- 给出后台 / 分布式 / 微服务 / 数据系统 / 高并发系统的方案 / 设计文档 / RFC，希望"评审 / review / 挑刺 / 找漏洞 / 上线前检查"。
- 出现关键词：技术方案评审 / 架构评审 / 设计评审 / design review / RFC review / 上线前评审 / 技术方案校验。
- 希望对方案做**多维度系统化检查**，而非只问单点（如只问性能）。

不适用：单点技术问题（如"Redis 为什么慢"）；前端 / 移动端 / 算法模型方案；业务需求 / PRD 评审。

## 评审产物（重要）

每次评审的**所有产物**（最终报告 + 备份 + 中间产物）统一落盘到 **`TECH_DESIGN_DIR = <ROOT>/.qiqskills/<PLAN_DIR_NAME>/`**，其中 `<ROOT>` 为仓库根目录，无仓库根时为当前工作目录。详细解析规则见 [SKILL.md §7.1.0](./SKILL.md)。

```
<REPO_ROOT>/
├── <方案路径>/<原方案文件>.md                      # 方案可在仓库任意子目录
└── .qiqskills/
    └── <方案目录名>/                               # 方案级产物根目录（= TECH_DESIGN_DIR）
        ├── requirements.md                         # 由 spec skill 产出；本 skill 只读不写
        ├── <原文件名>-review.md                    # 最终评审报告（稳定路径，重跑覆盖写）
        ├── <原文件名>-review.bak.YYYYMMDD-HHmmss.md # 上一版备份（重跑前重命名而来）
        └── intermediates/                          # Step 1 / 1.5 / 1.6 中间产物
```

### 重跑策略：先备份、再覆盖

当对**同一个方案**重新跑评审、目标 review 文件已存在时：

1. 先把旧报告**重命名**为 `<原文件名>-review.bak.YYYYMMDD-HHmmss.md`，保留在同一目录作为备份。
2. 再用本次结果**覆盖写**到稳定路径 `<原文件名>-review.md`。
3. 新报告头部会写出 `上一版备份路径` 字段，便于 diff 与回滚。

> 设计动机：让"最新一次评审结果"始终位于一个**稳定路径**（便于在 PR / Wiki 上长期引用），同时不丢历史。仅当用户**明确表达"不需要备份"**时跳过第 1 步。

### 报告头部元信息

每份报告头部包含可追溯的元信息：原方案路径 / 原仓库根目录（`REPO_ROOT`）/ 方案目录名（`PLAN_DIR_NAME`）/ 原始需求记录路径（`<TECH_DESIGN_DIR>/requirements.md`，不存在填"无"）/ 产物根目录（`TECH_DESIGN_DIR`）/ 报告输出路径 / 上一版备份路径（首次跑填"无"）/ 中间产物清单 / 评审时间（到秒）/ skill 版本号（取自 [SKILL.md](./SKILL.md) frontmatter）。

## 目录结构

```
.
├── SKILL.md                       # Skill 入口，frontmatter 含 version
├── README.md                      # 本文件
├── references/                    # 各维度 checklist 与判定规则
│   ├── 00-context-template.md
│   ├── 01-consistency-completeness.md
│   ├── 02-fault-tolerance-ha.md
│   ├── 03-performance-scalability.md
│   ├── 04-security.md
│   ├── 05-data-storage.md
│   ├── 06-operability.md
│   ├── 07-simplicity.md
│   ├── 08-orchestration.md
│   ├── 09-severity-and-gate.md
│   ├── 10-api-contract-compatibility.md
│   └── 11-repo-rules-and-bans.md
├── templates/
│   └── review-report.md           # 评审报告模板（决定落盘内容结构）
├── build.sh                       # 打包脚本：产出可分发的 zip（带版本号）
└── LICENSE
```

入口为 [SKILL.md](./SKILL.md)；具体校验规则按需加载 [references/](./references/) 下对应文件，避免一次性灌入全部上下文。

## 使用方式

### 1. 在支持 Skills 的 Agent 平台

将本仓库（或下面打包出的 zip）作为 Skill 导入即可。Agent 命中 [SKILL.md](./SKILL.md) 中的 "When to use" 后会自动按流程执行：确认模式 → 收集上下文 → 预读 `requirements.md` / 仓库禁用清单 → 分维度评审 → 仲裁定级 → 按产物规则落盘最终报告。

### 2. 本地直接当作 Prompt 资料

不依赖 Skill 平台时，也可以把 [SKILL.md](./SKILL.md) 作为系统提示，结合 `references/` 中的 checklist 做人工或 LLM 评审。

## 打包分发

仓库自带打包脚本，默认产物文件名带版本号：

```bash
# 打包到 dist/qiq-tech-review-v<version>.zip
# 版本号自动取自 SKILL.md frontmatter（单一来源）
./build.sh

# 自定义输出路径
./build.sh -o /tmp/my-skill.zip
```

打包内容**只包含 skill 运行所需的 3 项**：`SKILL.md` / `references/` / `templates/`（白名单方式）。其他根目录文件（README、LICENSE、build.sh 自身、`dist/`、`.git/`、IDE 配置等）天然不会进入产物。

依赖：`bash` + `zip`（macOS / 主流 Linux 默认自带）。

## 版本号管理

- **版本号唯一来源**：[SKILL.md](./SKILL.md) frontmatter 的 `version` 字段。
- **采用语义化版本（SemVer）**：`MAJOR.MINOR.PATCH`：
  - MAJOR：不兼容的清单 / 流程结构变更（例如新增 / 删除维度、Output Format 重构）。
  - MINOR：向后兼容的清单条目新增、判例库扩充、模板字段新增。
  - PATCH：措辞修订、文案优化、错别字修复。
- **变更流程**：修改后请同步更新 `version`；`build.sh` 与报告头部会自动读取，无需手动改第二处。

## 维护说明

- 修改流程 / 触发条件：编辑 [SKILL.md](./SKILL.md)（同步 bump version）。
- 新增 / 调整某维度 checklist：编辑 [references/](./references/) 中对应文件；维度间协同与冲突仲裁规则在 `08-orchestration.md`，定级与门禁在 `09-severity-and-gate.md`，仓库规则与禁用项预扫描在 `11-repo-rules-and-bans.md`。
- 调整最终报告结构：编辑 [templates/review-report.md](./templates/review-report.md)。
- 调整打包内容 / 排除规则：编辑 [build.sh](./build.sh) 中的 `REQUIRED` 与 `EXCLUDES`。

## License

见 [LICENSE](./LICENSE)。
