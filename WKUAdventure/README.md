# 温肯：这条表白全校已读

一部使用 Dora SSR 制作的校园情景喜剧视觉小说。开放日收尾时，一条原定晚上八点发布的匿名表白被误发到中庭大屏。四个人只想撤回，却依次把它变成紧急置顶、饮料认领、临时恋情、图书馆直播和实名答复。

## 当前可玩内容

- 四位固定身份的可选视角角色：黄一澈负责校媒发稿，张开送负责匿名墙，寒予水负责主持，李童牧负责活动执行
- 选角页、剧情舞台与随时可打开的人物册均显示姓名、职责和当晚任务
- 一条完整路线由误发现场、一个分支事故和湖边终章构成；每次补救都会制造更公开的麻烦
- 四个剧情节点、四次二选一决定、六个章节小结和三个最终结局
- 终章在所有路线中明确揭晓：寒予水写帖、黄一澈误发、李童牧收件
- 四件剧情信号首次出现时单独展示一次，同时解释物证指向，之后永久进入信号图鉴
- Dora 内实现的 Ren'Py 风格脚本层：`label`、`say`、`signal`、`menu`、`jump`、`condition`、`minigame`、`end`
- 四人同台、固定角色说话、打字机对白、角色焦点、回看、自动播放和已读快进
- 三档存档、剧情断点续读、键盘、鼠标、触屏和手柄输入

## 直接运行

从 `D:\WKU-Hackson` 启动 Dora SSR：

```powershell
.\dora-ssr-v1.9.2-windows-x86\Dora.exe
```

要直接运行游戏，可在项目目录执行：

```powershell
..\dora-ssr-v1.9.2-windows-x86\Dora.exe --asset .
```

也可以在浏览器打开 `http://localhost:8866/`，在 Dora Web IDE 中选择 `WKUAdventure` 并运行。Dora 服务已连接时，可在项目目录执行：

```powershell
..\dora-ssr-v1.9.2-windows-x86\Dora.exe cli buildrun -p .
```

Dora 开启“访问验证”时，按桌面窗口显示的 PIN 完成浏览器连接。

## 操作

- 鼠标 / 触屏：选角、推进对白、选择分支
- Enter / E / Space：显示完整台词或推进；最终结局页返回剧集
- 数字键 1 / 2：选择分支；存档页使用 1 / 2 / 3
- Esc：收下当前信号、关闭人物册 / 图鉴 / 回看，或返回剧集页
- 手柄 A：确认；手柄 B / Back：返回

## 代码结构

- `init.ts`：Dora 启动入口
- `Game/app.ts`：界面、人物册、信号图鉴、存档、输入和四人舞台
- `Game/content.ts`：四位角色、四件剧情信号和完整情景喜剧脚本
- `Game/renpy.ts`：Ren'Py 风格声明式脚本解释器
- `Data/story-assets.md`：控制思想、人物压力点、因果升级链和道具地雷
- `Font/sarasa-mono-sc-regular.ttf`：随 Dora SSR 分发的中文界面字体
- `lualib_bundle.lua`：独立运行 TypeScript 编译产物所需的 Lua 运行库
- `tools/validate-project.ps1`：素材、结构、真相闭环和编译产物检查

## 验证

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\validate-project.ps1
```

背景、角色与剧情信号的素材状态记录在 `Data/galgame-art-manifest.md`，生成提示词记录在 `Data/signal-art-prompts.md`。角色、对白和事件均为虚构，不使用真实师生姓名或肖像。
