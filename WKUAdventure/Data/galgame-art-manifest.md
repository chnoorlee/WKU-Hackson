# Galgame 美术来源清单

核验日期：2026-09-05

## 校园背景

`Image/Scenes/` 下的九张 PNG 来自用户在本任务中提供的温州肯恩大学场景像素图。文件被逐一复制到项目目录，未裁切、重绘或覆盖原附件；验证脚本会检查每张图的原始尺寸。

- `outdoor-garden-bridge.png`、`outdoor-lakeside-flowers.png`、`outdoor-lake-path.png`：校园室外
- `slac-interior.png`：SLAC 湖景中庭
- `ghk-interior.png`：葛和凯楼中庭大阶梯
- `gh-interior.png`：GH English Language Center
- `gymnasium-interior.png`：体育馆体能训练区
- `swimming-pool-interior.png`：游泳馆主池
- `library-interior.png`：图书馆阅览室

这些图片仅作为虚构校园故事的章节背景。项目不依据画面识别、命名或描写其中可能出现的真实个人。

## 角色立绘

本剧本使用 `Image/Characters/` 下的四位可选角色立绘：黄一澈、张开送、寒予水和李童牧。它们是由 `tools/generate-galgame-characters.ps1` 以确定性几何绘制生成的原创占位成品，均为 360x500 PNG，保留透明通道，并通过发型、服装色与职业道具区分角色。宋知夏和韩序的旧立绘仍保留在素材目录，但已不再接入角色表或剧情。

这些角色并非由 Image 2 在线生成，本次匿名墙剧本重写也没有改动四位在用角色文件。若之后重绘，应保留相同文件名、画布尺寸、透明背景、脚底安全区和角色身份特征，以便无需修改剧情代码即可替换。

## 界面字体

`Font/sarasa-mono-sc-regular.ttf` 原样复制自本项目配套的 Dora SSR v1.9.2 Windows 发行包，用于离线显示中文界面与对白。项目验证脚本会检查其 SHA-256，防止字体文件缺失或被意外替换。

## 剧情信号

新剧本定义四张 1024x1024 PNG，目标目录为 `Image/Signals/`：

- `wall-screenshot.png`：匿名墙截图
- `mint-receipt.png`：四人订单加两杯教师代取的小票
- `seat-card.png`：图书馆 3C 座位维修卡
- `paper-star.png`：用废主持稿折成的纸星

四张图由 InfMind 网页端的 `GPT Image 2` 生成，不使用确定性占位图冒充。生成设置为 1:1、每次 1 张、关闭科研风格、开启去水印；网页输出的方形原图经逐张人工验收后统一缩放为 1024x1024 PNG。去薄荷小票的五杯首稿已淘汰，项目采用重新生成并确认恰好六杯的版本。具体提示词、统一风格约束和验收结果记录在 `Data/signal-art-prompts.md`。

## 内容边界

- 黄一澈、张开送、寒予水和李童牧均为虚构角色。
- 不使用真实学生、教师或工作人员的姓名、肖像或可识别经历。
- 四个剧情节点、四件剧情信号及九个场景结局均为项目原创虚构内容。
