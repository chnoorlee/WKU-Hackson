# 如何使用 ECS 框架

## 1. 框架介绍

&emsp;&emsp;Dora SSR 的 ECS 框架是受 [Entitas](https://github.com/sschmid/Entitas) 启发而来，并做了功能上的略微改动，其基本概念可以借助 Entitas 的原理图进行理解。

```text
Entitas ECS

+-----------------+
|     Context     |
|-----------------|
|    e       e    |      +-----------+
|       e      e--|----> |  Entity   |
|  e        e     |      |-----------|
|     e  e     e  |      | Component |
| e          e    |      |           |      +-----------+
|    e     e      |      | Component-|----> | Component |
|  e    e    e    |      |           |      |-----------|
|    e    e     e |      | Component |      |   Data    |
+-----------------+      +-----------+      +-----------+
  |
  |
  |     +-------------+  Groups:
  |     |      e      |  实体组是全体游戏实体对象下，通过所包含的组件区分的一组子集
  |     |   e     e   |  用于快速遍历和查询有特定组件的对象
  +---> |        +------------+
        |     e  |    |       |
        |  e     | e  |  e    |
        +--------|----+    e  |
                 |     e      |
                 |  e     e   |
                 +------------+
```

&emsp;&emsp;与Entitas不同的是，在 Dora SSR 的 ECS 框架中，我们以实体对象上的一个字段就作为一个系统组件进行管理。这样会导致一些额外的性能损耗，但是能大幅简化逻辑代码的编写。

## 2. 代码示例

&emsp;&emsp;在这个教程中，我们会通过一个代码示例，展示如何使用 Dora SSR 的 ECS（Entity Component System）框架进行游戏逻辑的编写。

&emsp;&emsp;在编写实际的代码之前，我们先为 TypeScript 语言引入这篇教程中要用到的功能模块。

```ts
import {
	Group, Observer,
	Entity, Node,
	Director, Touch,
	Sprite, Scale,
	Ease, Vec2, Roll,
	EntityEvent
} from "Dora";
```

&emsp;&emsp;首先，我们创建两个实体组 `sceneGroup` 和 `positionGroup`，分别用于访问和管理所有具有 "scene" 和 "position" 组件名称的实体。

```ts
const sceneGroup = Group(["scene"]);
const positionGroup = Group(["position"]);
```

&emsp;&emsp;接下来，我们使用观察器（Observer）来监听实体的变化。当你在使用ECS框架开发游戏时，有时你需要在实体添加特定组件时触发一些操作。这时，你可以使用观察器（Observer）来监听实体的添加事件，并在添加事件发生时执行相应的逻辑。接下来是关于如何使用观察器监听实体添加事件的示例代码段：

```ts
Observer(EntityEvent.Add, ["scene"])
	.watch((_entity, scene: Node.Type) => {
		Director.entry.addChild(scene);
		scene.onTapEnded(touch => {
			const {location} = touch;
			positionGroup.each(entity => {
				entity.target = location;
				return false;
			})
		});
		return false;
	});
```

&emsp;&emsp;首先，使用 `Observer` 类创建一个观察器对象，并指定观察器监测的事件类型为 "Add"，表示监听实体的添加事件。同时，通过传入一个包含字符串 "scene" 的列表作为参数，指定观察器要监测的组件类型包括 "scene"。

```ts
Observer(EntityEvent.Add, ["scene"])
```

&emsp;&emsp;接下来，在观察器对象的 `watch` 方法中，定义了一个回调函数 `(_entity, scene) =>`。这个回调函数在实体添加事件发生时被触发。它接收的第一个参数为触发事件的实体对象，后面的参数与监测的组件列表相对应。

```ts
.watch((_entity, scene: Node.Type) => {
```

&emsp;&emsp;在回调函数内部，我们执行了一系列操作。首先，通过 `Director.entry` 将 `scene` 添加到游戏场景中。

```ts
Director.entry.addChild(scene);
```

&emsp;&emsp;然后，我们给 `scene` 添加了一个 "onTapEnded" 的事件处理函数，当触摸结束事件发生时，这个处理函数会被调用。

```ts
scene.onTapEnded(touch => {
```

&emsp;&emsp;在事件处理函数内部，我们先获取了触摸点的位置赋值给 `location` 变量。

```ts
const {location} = touch;
```

&emsp;&emsp;最后，通过 `positionGroup.each()` 遍历了 `positionGroup` 实体组中的所有实体，并为每个实体设置了 `target` 属性为 触摸点的位置 `location`。

```ts
positionGroup.each(entity => {
	entity.target = location;
	return false;
});
```

&emsp;&emsp;这样，当有新的实体添加了 "scene" 组件时，该观察器会触发并执行以上操作，并将场景节点添加到游戏中，并完成一系列的初始化操作。

&emsp;&emsp;接下来，我们还要再创建一些观察器，分别处理其它 "Add" 和 "Remove" 类型的实体变化，并指定要监测的组件为 `image` 和 `sprite`。

```ts
Observer(EntityEvent.Add, ["image"]).watch((entity, image: string) => {
	sceneGroup.each(e => {
		const scene = e.scene as Node.Type;
		const sprite = Sprite(image);
		if (sprite) {
			sprite.runAction(Scale(0.5, 0, 0.5, Ease.OutBack));
			sprite.addTo(scene);
			entity.sprite = sprite;
		}
		return true;
	});
	return false;
});

Observer(EntityEvent.Remove, ["sprite"]).watch(self => {
	const sprite = self.oldValues.sprite as Node.Type;
	sprite.removeFromParent();
});
```

&emsp;&emsp;然后，我们创建一个具有 "position", "direction", "speed", "target" 组件的实体组，并定义了观察器来处理实体组内组件的变化，并在每一帧游戏更新时对一组特定的实体进行遍历，并根据实体的速度. 更新时间等信息来更新实体的旋转角度和位置属性。

```ts
Group(["position", "direction", "speed", "target"]).watch(
	(entity, position: Vec2.Type, _direction: number, speed: number, target: Vec2.Type) => {
	if (target.equals(position)) {
		return;
	}
	const dir = target.sub(position).normalize();
	const newPos = position.add(dir.mul(speed));
	entity.position = newPos.clamp(position, target);
	if (newPos.equals(target)) {
		entity.target = nil;
	}
	const angle = math.deg(math.atan(dir.x, dir.y));
	entity.direction = angle;
});
```

&emsp;&emsp;在这段代码中，首先，我们使用 `Group` 类创建了一个实体组对象，并指定了组中包含的组件类型为 "position". "direction". "speed" 和 "target"。

```ts
Group(["position", "direction", "speed", "target"])
```

&emsp;&emsp;然后，我们使用了实体组的 `watch` 方法来每帧遍历所有组内的实体，执行我们定义的回调函数来处理实体上的组件。

```ts
.watch(
	(entity, position: Vec2.Type, _direction: number, speed: number, target: Vec2.Type) => {
```

&emsp;&emsp;在回调函数内部，我们首先进行了一些条件判断。通过 `if (target.equals(position))` 判断实体的目标位置和当前位置是否相等，如果相等则直接返回，不进行后续的更新操作。

&emsp;&emsp;接下来，我们计算了实体的方向向量 `dir`，它等于目标位置减去当前位置，并进行了归一化操作。

```ts
const dir = target.sub(position).normalize();
```

&emsp;&emsp;然后，我们根据实体的速度和方向向量，计算实体在当前帧更新时的新位置 `newPos`。通过将方向向量 `dir` 乘以速度 `speed`，然后将其加上当前位置 `position`，即可得到新的位置。

```ts
const newPos = position.add(dir.mul(speed));
```

&emsp;&emsp;接着，我们使用 `newPos` 和实体的目标位置 `target` 来进行位置的修正。通过 `.clamp(position, target)`，我们确保新位置在当前位置和目标位置之间，并将修正后的最终位置赋值回实体的 `position` 组件。

```ts
entity.position = newPos.clamp(position, target);
```

&emsp;&emsp;接下来，如果新位置等于目标位置的话，我们就清空实体的目标位置 `target`。

```ts
if (newPos.equals(target)) {
	entity.target = nil;
}
```

&emsp;&emsp;最后，我们计算了实体的旋转角度 `angle`，通过使用 `math.atan` 函数来计算方向向量 `dir` 的弧度，并将其转换为角度，更新实体的旋转角度组件 `direction` 为计算得到的角度值。

```ts
const angle = math.deg(math.atan(dir.x, dir.y));
entity.direction = angle;
```

&emsp;&emsp;这样，当每一帧游戏更新时，实体组内的就会触发这段代码对每个实体做逻辑处理，并对实体当前的 "position". "direction". "speed" 或 "target" 组件做更新操作。

&emsp;&emsp;在完成数据计算和更新后，我们还需要把数据结果更新到渲染图形上。

```ts
Observer(EntityEvent.AddOrChange, ["position", "direction", "sprite"])
	.watch((entity, position: Vec2.Type, direction: number, sprite: Sprite.Type) => {
		// 更新图片的显示位置
		sprite.position = position;
		const lastDirection = entity.oldValues.direction as number ?? sprite.angle;
		// 当图片的旋转角度变化时，我们就播放一个旋转的动画
		if (math.abs(direction - lastDirection) > 1) {
			sprite.runAction(Roll(0.3, lastDirection, direction));
		}
	});
```

&emsp;&emsp;最后，我们创建三个实体，并为它们添加不同的组件。这时游戏系统将开始正式运行。

```ts
Entity({ scene: Node() });

Entity({
	image: "Image/logo.png",
	position: Vec2.zero,
	direction: 45.0,
	speed: 4.0
});

Entity({
	image: "Image/logo.png",
	position: Vec2(-100, 200),
	direction: 90.0,
	speed: 10.0
});
```

&emsp;&emsp;这个代码示例演示了使用ECS框架开发游戏的基本流程。你可以根据自己的游戏需求，使用框架提供的实体. 组. 观察器等接口来构建游戏逻辑。在代码中，你可以根据实体的组件变化来触发相应的操作，对实体进行增删改查等操作，并利用实体组进行分组管理。通过使用观察器，你可以监听实体的变化事件，例如添加. 修改或删除实体的特定组件。在观察器的处理函数中，你可以根据实体的变化执行相应的逻辑操作，例如更新场景中的节点. 处理用户输入或打印调试信息等。

&emsp;&emsp;通过合理组织实体和组件的关系，以及利用观察器的监听和处理能力，你可以构建出复杂的游戏逻辑和行为。在实际开发中，你可以根据游戏的需求设计和定义自己的组件类型，并利用ECS框架提供的接口来实现游戏中的各种功能和行为。

## 3. 总结

&emsp;&emsp;总结起来，使用ECS框架开发游戏的基本流程包括：

1. 定义实体的组件类型，并根据实际需求创建实体对象。
2. 创建实体组并将实体添加到相应的组中，用于分组管理实体。
3. 使用观察器监听实体的变化事件，例如添加. 修改或删除特定组件。
4. 在实体组观察器的处理函数中每帧根据实体的变化执行相应的逻辑操作。
5. 根据游戏需求设计和实现其他的组件. 系统等功能。

&emsp;&emsp;通过按照上述流程使用 Dora SSR 的 ECS 框架，你可以更好地组织和管理游戏逻辑，提高代码的可维护性和扩展性，实现复杂的游戏功能和行为。