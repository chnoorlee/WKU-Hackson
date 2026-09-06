# 使用 ImGui 开发编辑器和调试工具

## 1. 引言

&emsp;&emsp;在游戏开发过程中，一个直观、高效的用户界面（UI）对于编辑器和调试工具至关重要。然而 Dora SSR 作为一个聚焦于代码的引擎，暂时没有提供内置的编辑器或是调试工具。因此，需要开发者根据自己游戏作品的需求，自行进行快速开发和定制。但是，Dora SSR 提供了 **ImGui** 库，可以极为方便地开发这类辅助 UI。

&emsp;&emsp;**ImGui**（Immediate Mode GUI）是一种即时模式的图形用户界面库，以其简洁、高效的特点被广泛应用。接下来本教程将介绍如何使用 **Dora SSR** 提供的 **ImGui** 库开发游戏编辑器或调试工具的 UI。

## 2. ImGui 框架的理念、优势和劣势

### 2.1 理念

&emsp;&emsp;ImGui 的核心理念是**即时模式**，这意味着 UI 是在每一帧都被重新绘制的。这与传统的保留模式（Retained Mode）不同，后者维护着一个 UI 状态树，而即时模式则是根据当前的程序状态直接绘制 UI。

### 2.2 优势

- **易于使用**：无需管理复杂的 UI 状态，直接在代码中描述 UI 元素。
- **快速迭代**：适合快速原型设计和调试工具的开发。
- **轻量级**：无需整合大型的 UI 框架，减少了资源消耗。
- **高度灵活**：可以轻松地嵌入到现有的游戏引擎渲染循环中。

### 2.3 劣势

- **不适合复杂的 UI**：对于需要高度交互和复杂布局的应用，可能不太适用。
- **样式有限**：默认的视觉风格较为简单，定制化需要额外的工作。可能无法满足游戏作品的视觉要求。
- **性能开销**：在非常复杂的 UI 场景下，每帧重绘可能会带来性能问题。

## 4. 基本使用方法

### 4.1 创建一个简单的窗口

&emsp;&emsp;以下示例展示了如何创建一个简单的 ImGui 窗口：

```yue
_ENV = Dora Dora.ImGui

threadLoop ->
	Begin "示例窗口", ->
		Text "欢迎使用 Dora SSR 的 ImGui！"
		Separator!
		TextWrapped "这是一个简单的示例窗口，展示了基本的文本和分隔线。"
```

&emsp;&emsp;**说明**：

- `threadLoop` 函数用于在主线程中循环执行操作。
- `ImGui.Begin` 函数用于创建一个窗口，并指定窗口的标题。
- `ImGui.Text` 函数用于绘制文本。
- `ImGui.Separator` 函数用于绘制一个分隔线。
- `ImGui.TextWrapped` 函数用于绘制一段带有自动换行的文本。

### 4.2 添加交互元素

&emsp;&emsp;您可以在窗口中添加按钮、输入框等交互元素：

```yue
_ENV = Dora Dora.ImGui

inputText = with Buffer 200
	.text = "默认文本"
threadLoop ->
	Begin "交互示例", ->
		if Button "点击我"
			print "按钮被点击！"
		if InputText "输入框", inputText
			print "输入内容：" .. inputText.text
```

&emsp;&emsp;**说明**：

- `ImGui.Button` 函数用于创建一个按钮，并指定按钮的标签。
- `ImGui.InputText` 函数用于创建一个输入框，并指定输入框的标签和缓冲区。

## 5. 创建游戏编辑器的使用示例

### 5.1 对象属性编辑器

&emsp;&emsp;对象属性编辑器是游戏编辑器中的核心组件，用于查看和修改游戏对象的属性。

```yue
_ENV = Dora Dora.ImGui

gameObject =
	name: "Player"
	position:
		x: 0.0, y: 0.0
	rotation: 0.0,
	scale:
		x: 1.0, y: 1.0
	isActive: true

nameBuffer = with Buffer 100
	.text = gameObject.name

threadLoop ->
	SetNextWindowSize Vec2(300, 400), "FirstUseEver"
	Begin "对象属性编辑器", ->
		-- 编辑对象名称
		if InputText "名称", nameBuffer
			gameObject.name = nameBuffer.text

		-- 编辑位置
		if changed, x, y := InputFloat2 "位置", gameObject.position.x, gameObject.position.y
			gameObject.position.x = x
			gameObject.position.y = y

		-- 编辑旋转
		if changed, rotation := DragFloat "旋转", gameObject.rotation, 1.0, 0.0, 360.0, "%.1f°"
			gameObject.rotation = rotation

		-- 编辑缩放
		if changed, sx, sy := InputFloat2 "缩放", gameObject.scale.x, gameObject.scale.y
			gameObject.scale.x = sx
			gameObject.scale.y = sy

		-- 编辑激活状态
		if changed, isActive := Checkbox "是否激活", gameObject.isActive
			gameObject.isActive = isActive

		-- 输出当前对象的状态
		if Button "输出状态"
			print "当前对象状态："
			p gameObject
```

&emsp;&emsp;**说明**：

- 使用 `InputText` 编辑字符串属性。
- 使用 `InputFloat2` 和 `DragFloat` 编辑数值属性。
- 使用 `Checkbox` 编辑布尔值属性。

### 5.2 场景层级视图

&emsp;&emsp;场景层级视图用于显示场景中所有的游戏对象，以树形结构呈现。

```yue
_ENV = Dora Dora.ImGui

-- 假设我们有一个场景对象列表，包含父子关系
sceneObjects =
	* name: "Root"
		children:
			* name: "Player"
				children: []
			* name: "Enemy"
				children:
					* name: "Enemy1"
						children: []
					* name: "Enemy2"
						children: []

leafFlags = {"Leaf"}
empty = ->

-- 递归函数，用于绘制场景树
drawSceneTree = (sceneObjects) ->
	for node in *sceneObjects
		if #node.children > 0
			TreeNode node.name, ->
				drawSceneTree node.children
		else
			TreeNodeEx node.name, node.name, leafFlags, empty

threadLoop ->
	Begin "场景层级视图", ->
		drawSceneTree sceneObjects
```

&emsp;&emsp;**说明**：

- 使用 `TreeNode` 和 `TreePop` 创建树形结构。
- 递归地绘制每个节点和其子节点。

### 5.3 资源浏览器

&emsp;&emsp;资源浏览器用于查看和选择项目中的资源，例如纹理、模型和音频文件。

```yue
_ENV = Dora Dora.ImGui

-- 资源列表
resources =
	textures: ["texture1.png", "texture2.png", "texture3.png"]
	models: ["model1.obj", "model2.obj"]
	sounds: ["sound1.wav", "sound2.wav"]

threadLoop ->
	Begin "资源浏览器", ->
		if CollapsingHeader "纹理"
			for _, texture in ipairs resources.textures
				if Selectable texture
					print "选中了纹理：" .. texture

		if CollapsingHeader "模型"
			for _, model in ipairs resources.models
				if Selectable model
					print "选中了模型：" .. model

		if CollapsingHeader "音频"
			for _, sound in ipairs resources.sounds
				if Selectable sound
					print "选中了音频：" .. sound
```

&emsp;&emsp;**说明**：

- 使用 `CollapsingHeader` 分组展示资源类型。
- 使用 `Selectable` 列表项，允许用户选择资源。

### 5.4 材质编辑器

&emsp;&emsp;材质编辑器允许用户调整材质的属性，例如颜色、纹理和着色器参数。

```yue
_ENV = Dora Dora.ImGui

-- 材质对象
material =
	name: "BasicMaterial"
	color: { r: 255, g: 255, b: 255 }
	texture: "default.png"
	shininess: 32.0

textures = ["default.png", "texture1.png", "texture2.png"]
currentTextureIndex = 1

nameBuffer = with Buffer 100
	.text = material.name

threadLoop ->
	Begin "材质编辑器", ->
		if InputText "名称", nameBuffer
			material.name = nameBuffer.text

		-- 编辑颜色
		color = Color3 material.color.r, material.color.g, material.color.b
		if ColorEdit3 "颜色", color
			material.color.r, material.color.g, material.color.b = color.r, color.g, color.b

		-- 选择纹理
		changed, currentTextureIndex = Combo "纹理", currentTextureIndex, textures
		if changed
			material.texture = textures[currentTextureIndex]

		-- 编辑光泽度
		changed, shininess = DragFloat "光泽度", material.shininess, 1.0, 0.0, 128.0, "%.0f"
		if changed
			material.shininess = shininess

		-- 输出当前材质的状态
		if Button "输出状态"
			print "当前材质状态："
			p material
```

&emsp;&emsp;**说明**：

- 使用 `ColorEdit3` 进行颜色选择。
- 使用 `Combo` 创建下拉菜单供用户选择纹理。
- 使用 `DragFloat` 调整数值参数。

### 5.5 控制台窗口

&emsp;&emsp;实现一个简单的控制台窗口，用于输入命令和显示日志。

```yue
_ENV = Dora Dora.ImGui

-- 日志列表
logs = {}

inputBuffer = Buffer 200

threadLoop ->
	Begin "控制台", ->
		-- 显示日志区域
		BeginChild "LogArea", Vec2(0, -25), ->
			for log in *logs
				TextWrapped log
			if GetScrollY! >= GetScrollMaxY!
				SetScrollHereY 1.0
		-- 输入区域
		if InputText "输入命令", inputBuffer, ["EnterReturnsTrue",]
			command = inputBuffer.text
			table.insert logs, "> " .. command
			table.insert logs, "执行结果：命令 [" .. command .. "] 已执行。"
			inputBuffer.text = ""
```

&emsp;&emsp;**说明**：

- 使用 `BeginChild` 创建日志显示区域。
- 使用 `InputText` 接受用户输入，并在按下回车时处理命令。
- 使用 `SetScrollHereY` 保持滚动条在底部。

### 5.6 状态栏和工具栏

&emsp;&emsp;在编辑器窗口中添加状态栏和工具栏，提供常用功能的快捷入口。

```yue
_ENV = Dora Dora.ImGui

threadLoop ->
	Begin "编辑器主窗口", ["MenuBar", "AlwaysAutoResize"], ->
		-- 工具栏
		BeginMenuBar ->
			BeginMenu "文件", ->
				if MenuItem "新建"
					print "新建文件"
				if MenuItem "保存"
					print "保存文件"
			BeginMenu "编辑", ->
				if MenuItem "撤销"
					print "撤销操作"

		-- 主内容区域
		Text "这里是主内容区域"
		Dummy Vec2 0, 100

		-- 状态栏
		BeginChild "StatusBar", Vec2(0, 20), ->
			Text "状态：就绪"
```

&emsp;&emsp;**说明**：

- 使用 `BeginMenuBar` 创建菜单栏或工具栏。
- 在主窗口中添加一个 `BeginChild`，用于模拟状态栏。

## 6. 优化技巧：提取匿名函数以减少内存分配

### 6.1 问题分析

&emsp;&emsp;在使用 **ImGui** 库进行开发时，每一帧可能会创建大量的匿名函数（闭包），这会导致频繁的内存分配和垃圾回收，进而影响性能。

### 6.2 解决方案

&emsp;&emsp;**提取匿名函数**：将匿名函数提取为局部函数，避免每帧创建新的函数对象。

### 6.3 优化方法

#### 6.3.1 将匿名函数提取为局部函数

&emsp;&emsp;**示例**：

* 优化前：

```yue
threadLoop ->
	Begin "示例窗口", ->
		Text "这是一个示例窗口"
```

* 优化后：

```yue
drawExampleWindow = ->
	Text "这是一个示例窗口"

threadLoop ->
	Begin "示例窗口", drawExampleWindow
```

#### 6.3.2 使用函数缓存机制

&emsp;&emsp;**示例**：

* 优化前：

```yue
objects =
	* name: "Object1", id: 1
	* name: "Object2", id: 2
	* name: "Object3", id: 3

threadLoop ->
	Begin "对象列表", ->
		for obj in *objects
			TreeNode obj.name, ->
				Text "对象 ID：" .. obj.id
```

* 优化后：

```yue
objects =
	* name: "Object1", id: 1
	* name: "Object2", id: 2
	* name: "Object3", id: 3

getTreeNodeFunction = (obj) ->
	if not obj.nodeFunction
		obj.nodeFunction = ->
			ImGui.Text "对象 ID：" .. obj.id
	obj.nodeFunction

drawObjectList = ->
	for obj in *objects
		TreeNode obj.name, getTreeNodeFunction obj

threadLoop ->
	Begin "对象列表", drawObjectList
```

#### 6.3.3 将复用的变量提取到闭包外

&emsp;&emsp;**示例**：

* 优化前：

```yue
threadLoop ->
	Begin "示例窗口", [ "AlwaysAutoResize" ], ->
		Text "这是一个示例窗口"
```

* 优化后：

```yue
windowFlags = [ "AlwaysAutoResize" ]
drawFunction = ->
	Text "这是一个示例窗口"

threadLoop ->
	Begin "示例窗口", windowFlags, drawFunction
```

### 6.4 总结

&emsp;&emsp;通过将匿名函数提取到闭包的外层，您可以：

- **减少每帧的内存分配**：避免频繁创建新的函数和对象，降低垃圾回收的压力。
- **提高性能**：减少不必要的开销，使您的游戏编辑器运行得更流畅。
- **改善代码结构**：将逻辑清晰地分离，提高代码的可读性和可维护性。

## 7. 开发建议

- **充分利用即时模式**：由于 ImGui 是即时模式的，您可以根据实时的程序状态动态更新 UI。
- **注意性能**：在复杂的 UI 中，尽量减少不必要的绘制，必要时可以使用条件判断来控制 UI 元素的更新。
- **组织代码结构**：将重复使用的 UI 组件封装成函数，提升代码的可读性和可维护性。
- **监控性能**：使用性能分析工具，监测内存分配和 CPU 占用，及时发现性能瓶颈。
- **代码审查**：定期审查代码，寻找可能的优化点，避免不必要的资源浪费。
- **学习最佳实践**：更多的 ImGui 使用方法，请参考官方文档和社区经验，学习并应用最佳的编码实践。

## 8. 结论

&emsp;&emsp;通过本教程，您应该对如何使用 Dora SSR 的 ImGui 库开发游戏编辑器或调试工具的 UI 有了全面的了解。ImGui 以其简洁、高效的特点，非常适合用于工具开发和快速原型设计。希望您能在实际项目中充分发挥其优势。