# 使用游戏特效系统

## 1. 引言

&emsp;&emsp;在游戏开发中，特效是提升游戏视觉体验的重要元素。它们可以增强游戏的氛围、突出关键事件，并提供即时的视觉反馈。本教程将介绍如何在 Dora SSR 引擎中使用 Effekseer 特效系统，以及如何使用引擎自带的 Particle 粒子系统。

## 2. 什么是 Effekseer？

&emsp;&emsp;[Effekseer](https://effekseer.github.io) 是一个免费、开源的特效编辑器，支持 Windows、macOS 和 Linux 等多个平台。它允许美术人员和开发者创建各种粒子效果，如爆炸、火焰、光束等。Effekseer 支持多种渲染模式和高级特性，如：

- **粒子发射与控制**：支持从点、线、面等多种形状发射粒子，并可对粒子的生命周期进行精细控制。
- **渲染特性**：支持混合模式、纹理贴图、光照和阴影等。
- **多平台支持**：可导出特效到多种游戏引擎和平台，包括 Dora SSR 等。

## 3. 使用 Effekseer

&emsp;&emsp;Dora SSR 引擎已经集成了 Effekseer 特效系统，开发者可以直接在游戏中加载和播放 Effekseer 编辑器生成的特效文件（通常以 `.efk` 或 `.efkefc` 为扩展名）。

### 3.1 EffekNode 类的使用

&emsp;&emsp;在 Dora SSR 中，可以使用 `EffekNode` 类来管理 Effekseer 特效的播放，并作为一个场景节点管理特效的几何位置、旋转和缩放等属性。以下是 `EffekNode` 类的主要方法和用法：

- **创建 EffekNode 对象**

	```ts
	import { EffekNode } from "Dora";
	const effekNode = EffekNode();
	```

- **播放特效**

	```ts
	const handle = effekNode.play("Particle/effek/Laser01.efk", Vec2(100, 200), 0);
	```

	`play` 方法接收的参数如下：

	- `filename`：特效文件的路径。
	- `pos`（可选）：播放特效的二维坐标，默认为 `(0, 0)`。
	- `z`（可选）：播放特效的 Z 轴坐标，默认为 `0`。

- **停止特效**

	```ts
	effekNode.stop(handle);
	```

	- `handle`：`play` 方法返回的特效句柄。

- **监听特效结束事件**

	```ts
	effekNode.onEffekEnd(handle => {
		print("特效已结束，句柄：" + handle);
	});
	```

### 3.2 实战示例：播放一个激光特效

&emsp;&emsp;以下是一个完整的示例，展示如何在 Dora SSR 中播放一个名为 `Laser01.efk` 的激光特效，并在特效结束时进行回调处理。

```ts
// 引入必要的模块
import { EffekNode } from "Dora";

// 创建 EffekNode 对象
const effekNode = EffekNode();

// 设置特效节点整体的 3D 旋转角度
effekNode.angleY = -90;

// 在坐标 (100, 200) 处播放激光特效
const laserHandle = effekNode.play("Particle/effek/Laser01.efk", Vec2(100, 200));

// 注册特效结束回调
effekNode.onEffekEnd(handle => {
	if (handle === laserHandle) {
		print("激光特效已结束");
	}
});
```

### 3.3 控制特效的播放与停止

&emsp;&emsp;有时候，我们需要根据游戏逻辑来控制特效的播放和停止。例如，在玩家释放技能时播放特效，技能被打断时停止特效。

```ts
// 假设技能被打断，需要停止特效
effekNode.stop(laserHandle);
```

### 3.4 多个特效的管理

&emsp;&emsp;如果需要同时播放多个特效，可以分别保存每个特效的句柄，并在回调中进行区分。

```ts
// 播放多个特效
const handle1 = effekNode.play("Explosion.efk", Vec2(150, 250));
const handle2 = effekNode.play("Sparkle.efk", Vec2(200, 300));

// 回调处理
effekNode.onEffekEnd(handle => {
	if (handle === handle1) {
		print("爆炸特效已结束");
	} else if (handle === handle2) {
		print("闪光特效已结束");
	}
});
```

## 4. 使用 Particle 类

&emsp;&emsp;在 Effekseer 集成之前，Dora SSR 提供了 `Particle` 类来处理 2D 粒子特效。

:::note 注意
然而，`Particle` 系统功能较为有限，主要依赖 CPU 进行计算，性能和效果都不如 Effekseer。因此，除非是只希望创建比较简单的粒子特效的场景，否则不推荐使用 `Particle` 类。
:::

### 4.1 Particle 类的使用

- **创建 Particle 对象**

	```ts
	import { Particle } from "Dora";
	const particle = Particle("effect.par");
	```

	`Particle` 构造函数接收一个参数：

	- `filename`：粒子系统定义文件的路径。

- **开始和停止粒子发射**

	```ts
	particle.start(); // 开始发射粒子
	particle.stop();  // 停止发射粒子
	```

- **监听粒子系统结束事件**

	```ts
	particle.onFinished(() => {
		print("粒子系统已结束");
	});
	```

### 4.2 使用示例

```ts
// 引入 Particle 类
import { Particle } from "Dora";

// 创建粒子系统对象
const particle = Particle("effect.par");

// 注册粒子系统结束回调
particle.onFinished(() => {
	print("粒子系统已结束");
});

// 启动粒子发射
particle.start();
```

### 4.3 自定义粒子效果

&emsp;&emsp;由于 `Particle` 类功能有限，如果需要使用它，可能需要自行修改引擎中基于 ImGui 框架编写的粒子系统的编辑器示例（名为“Particle”）来定制自己的粒子编辑器，以满足美术制作的需求。Dora SSR 的粒子系统加载使用的 `.par` 文件，本质是一个 XML 格式的文本文件，可以参考编辑器代码如何进行生成和导出。

## 5. 总结

&emsp;&emsp;本文介绍了如何在 Dora SSR 引擎中使用 Effekseer 特效系统。通过 `EffekNode` 类，开发者可以方便地在游戏中加载和控制各种复杂的特效。同时，我们也提到了历史遗留的 `Particle` 类。

&emsp;&emsp;Effekseer 为游戏特效的制作和管理提供了强大的支持，比较建议新项目采用 Effekseer 来处理特效。希望本教程能帮助您快速上手 Dora SSR 的特效系统，创造出令人惊艳的游戏效果。