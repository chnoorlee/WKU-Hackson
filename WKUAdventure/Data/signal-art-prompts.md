# 剧情信号生成规格

状态：四张剧情信号图已于 2026-09-05 通过 InfMind 网页端的 `GPT Image 2` 生成，并完成逐张人工验图。网页参数为 1:1、每次 1 张、关闭科研风格、开启去水印；原始方图统一以 Lanczos 缩放为游戏所需的 1024x1024 PNG。四人版重写继续使用这组已验收素材，并由游戏 UI 单独排版新的物证解释，不把抽象图中文字当作证据。

生成方式：逐张提交并检查硬约束。去薄荷小票首稿只生成五杯，未被采用；第二次在提示词中明确“两排、每排三杯”，通过六杯数量检查后才写入项目。其余三张首稿通过检查。

## 统一风格前缀

> Square collectible prop illustration for a Chinese campus visual novel sitcom. Clean 2D hand-painted pixel-art hybrid, top-down three-quarter view, one isolated story object centered on a deep charcoal tabletop, crisp silhouette, subtle paper and screen texture, teal, coral and warm gold accent colors, soft studio lighting, no gradient background, no people, no hands, no real brand, no logo, no watermark, no decorative text, no UI frame, no mockup border. The object must remain fully visible with generous safe margins and read clearly at thumbnail size.

## 01 匿名墙截图

文件：`Image/Signals/wall-screenshot.png`

> A modern smartphone lying slightly crooked, showing an anonymous campus confession-wall post with a small heart avatar and stacked comment bubbles. The interface content is intentionally abstract and unreadable; convey an accidentally published scheduled post through a tiny clock icon and a highlighted notification badge. Add one folded rain-umbrella claim slip partly under the phone. No legible words or letters.

## 02 去薄荷小票

文件：`Image/Signals/mint-receipt.png`

> A long crumpled drink receipt curling beside six transparent takeaway cups in a tight cluster. Each cup has ice and a different colored straw; a fresh mint sprig sits outside the cups with a small coral-red crossed circle beside it. Receipt lines are abstract marks only, with six clearly separated order rows and no legible words, letters or numbers.

## 03 3C 座位维修卡

文件：`Image/Signals/seat-card.png`

> A worn library seat maintenance card tied to a bent chair tag, with the large simple identifier "3C" as the only readable text. Include a black gel pen, a faint water-ring stain and several old fold creases. The back corner is turned up as if someone wrote a private reply underneath. No other legible text.

## 04 主持稿纸星

文件：`Image/Signals/paper-star.png`

> A hand-folded paper star opened flat after being pressed under a bench. Six distinct handwritten lines radiate from the folds but all writing is abstract and unreadable. Include a small dried leaf and one dark crease from the bench slat. The paper should feel handled, sincere and slightly funny rather than romantic or sentimental. No legible words, letters or names.

## 生成后检查

- 四张文件均为 1024x1024 PNG，能够被 Dora `Sprite` 读取。
- 不出现真实品牌、校徽、人物肖像、水印或可识别个人信息。
- 除 `seat-card.png` 中的 `3C` 外，不依赖模型生成可读文字；剧情文字由游戏 UI 单独排版。
- 缩小到约 144x144 时，核心物品轮廓仍可识别。

## 实际验收结果

- `wall-screenshot.png`：手机、匿名墙帖子、评论气泡、通知角标和伞票根均可辨识。
- `mint-receipt.png`：恰好六杯，按 3x2 排列；当前剧情解释为四人订单加两杯替老师代取，具体“不加薄荷”备注由 UI 呈现。
- `seat-card.png`：`3C` 只出现一次；笔、水渍、折痕和掀角完整。
- `paper-star.png`：六种颜色的抽象墨迹、干叶和长凳压痕完整；当前剧情解释为六版被删掉的表白开场。
