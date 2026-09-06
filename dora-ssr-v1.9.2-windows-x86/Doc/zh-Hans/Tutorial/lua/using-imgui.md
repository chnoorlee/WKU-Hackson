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

```lua
local ImGui <const> = require("ImGui")
local threadLoop <const> = require("threadLoop")

threadLoop(function()
	ImGui.Begin("示例窗口", function()
		ImGui.Text("欢迎使用 Dora SSR 的 ImGui！")
		ImGui.Separator()
		ImGui.TextWrapped("这是一个简单的示例窗口，展示了基本的文本和分隔线。")
	end)
end)
```

&emsp;&emsp;**说明**：

- `threadLoop` 函数用于在主线程中循环执行操作。
- `ImGui.Begin` 函数用于创建一个窗口，并指定窗口的标题。
- `ImGui.Text` 函数用于绘制文本。
- `ImGui.Separator` 函数用于绘制一个分隔线。
- `ImGui.TextWrapped` 函数用于绘制一段带有自动换行的文本。

### 4.2 添加交互元素

&emsp;&emsp;您可以在窗口中添加按钮、输入框等交互元素：

```lua
local ImGui <const> = require("ImGui")
local threadLoop <const> = require("threadLoop")
local Buffer <const> = require("Buffer")

local inputText = Buffer(200)
inputText.text = "默认文本"
threadLoop(function()
	ImGui.Begin("交互示例", function()
		if ImGui.Button("点击我") then
			print("按钮被点击！")
		end
		if ImGui.InputText("输入框", inputText) then
			print("输入内容：" .. inputText.text)
		end
	end)
end)
```

&emsp;&emsp;**说明**：

- `ImGui.Button` 函数用于创建一个按钮，并指定按钮的标签。
- `ImGui.InputText` 函数用于创建一个输入框，并指定输入框的标签和缓冲区。

## 5. 创建游戏编辑器的使用示例

### 5.1 对象属性编辑器

&emsp;&emsp;对象属性编辑器是游戏编辑器中的核心组件，用于查看和修改游戏对象的属性。

```lua
local ImGui <const> = require("ImGui")
local threadLoop <const> = require("threadLoop")
local Buffer <const> = require("Buffer")
local Vec2 <const> = require("Vec2")

-- 假设我们有一个游戏对象，其属性如下
local gameObject = {
	name = "Player",
	position = { x = 0.0, y = 0.0 },
	rotation = 0.0,
	scale = { x = 1.0, y = 1.0 },
	isActive = true
}

local nameBuffer = Buffer(100)
nameBuffer.text = gameObject.name

threadLoop(function()
	ImGui.SetNextWindowSize(Vec2(300, 400), "FirstUseEver")
	ImGui.Begin("对象属性编辑器", function()
		-- 编辑对象名称
		if ImGui.InputText("名称", nameBuffer) then
			gameObject.name = nameBuffer.text
		end

		-- 编辑位置
		local changed, x, y = ImGui.InputFloat2("位置", gameObject.position.x, gameObject.position.y)
		if changed then
			gameObject.position.x = x
			gameObject.position.y = y
		end

		-- 编辑旋转
		local changed, rotation = ImGui.DragFloat("旋转", gameObject.rotation, 1.0, 0.0, 360.0, "%.1f°")
		if changed then
			gameObject.rotation = rotation
		end

		-- 编辑缩放
		local changed, sx, sy = ImGui.InputFloat2("缩放", gameObject.scale.x, gameObject.scale.y)
		if changed then
			gameObject.scale.x = sx
			gameObject.scale.y = sy
		end

		-- 编辑激活状态
		local changed, isActive = ImGui.Checkbox("是否激活", gameObject.isActive)
		if changed then
			gameObject.isActive = isActive
		end

		-- 输出当前对象的状态
		if ImGui.Button("输出状态") then
			print("当前对象状态：")
			p(gameObject)
		end
	end)
end)
```

&emsp;&emsp;**说明**：

- 使用 `InputText` 编辑字符串属性。
- 使用 `InputFloat2` 和 `DragFloat` 编辑数值属性。
- 使用 `Checkbox` 编辑布尔值属性。

### 5.2 场景层级视图

&emsp;&emsp;场景层级视图用于显示场景中所有的游戏对象，以树形结构呈现。

```lua
local ImGui = require("ImGui")
local threadLoop = require("threadLoop")

-- 假设我们有一个场景对象列表，包含父子关系
local sceneObjects = {
	{
		name = "Root",
		children = {
			{
				name = "Player",
				children = {}
			},
			{
				name = "Enemy",
				children = {
					{ name = "Enemy1", children = {} },
					{ name = "Enemy2", children = {} },
				}
			},
		}
	}
}

local leafFlags = {"Leaf"}
local empty = function() end

-- 递归函数，用于绘制场景树
local function drawSceneTree(nodes)
	for _, node in ipairs(nodes) do
		if #node.children > 0 then
			ImGui.TreeNode(node.name, function()
				drawSceneTree(node.children)
			end)
		else
			ImGui.TreeNodeEx(node.name, node.name, leafFlags, empty)
		end
	end
end

threadLoop(function()
	ImGui.Begin("场景层级视图", function()
		drawSceneTree(sceneObjects)
	end)
end)
```

&emsp;&emsp;**说明**：

- 使用 `TreeNode` 和 `TreePop` 创建树形结构。
- 递归地绘制每个节点和其子节点。

### 5.3 资源浏览器

&emsp;&emsp;资源浏览器用于查看和选择项目中的资源，例如纹理、模型和音频文件。

```lua
local ImGui <const> = require("ImGui")
local threadLoop <const> = require("threadLoop")

-- 资源列表
local resources = {
	textures = { "texture1.png", "texture2.png", "texture3.png" },
	models = { "model1.obj", "model2.obj" },
	sounds = { "sound1.wav", "sound2.wav" }
}

threadLoop(function()
	ImGui.Begin("资源浏览器", function()
		if ImGui.CollapsingHeader("纹理") then
			for _, texture in ipairs(resources.textures) do
				if ImGui.Selectable(texture) then
					print("选中了纹理：" .. texture)
				end
			end
		end

		if ImGui.CollapsingHeader("模型") then
			for _, model in ipairs(resources.models) do
				if ImGui.Selectable(model) then
					print("选中了模型：" .. model)
				end
			end
		end

		if ImGui.CollapsingHeader("音频") then
			for _, sound in ipairs(resources.sounds) do
				if ImGui.Selectable(sound) then
					print("选中了音频：" .. sound)
				end
			end
		end
	end)
end)
```

&emsp;&emsp;**说明**：

- 使用 `CollapsingHeader` 分组展示资源类型。
- 使用 `Selectable` 列表项，允许用户选择资源。

### 5.4 材质编辑器

&emsp;&emsp;材质编辑器允许用户调整材质的属性，例如颜色、纹理和着色器参数。

```lua
local ImGui <const> = require("ImGui")
local threadLoop <const> = require("threadLoop")
local Buffer <const> = require("Buffer")
local Color3 <const> = require("Color3")

-- 材质对象
local material = {
	name = "BasicMaterial",
	color = { r = 255, g = 255, b = 255 },
	texture = "default.png",
	shininess = 32.0
}

-- 可用纹理列表
local textures = { "default.png", "texture1.png", "texture2.png" }
local currentTextureIndex = 1

local nameBuffer = Buffer(100)
nameBuffer.text = material.name

threadLoop(function()
	ImGui.Begin("材质编辑器", function()
		-- 编辑材质名称
		if ImGui.InputText("名称", nameBuffer) then
			material.name = nameBuffer.text
		end

		-- 编辑颜色
		local color = Color3(material.color.r, material.color.g, material.color.b)
		if ImGui.ColorEdit3("颜色", color) then
			material.color.r, material.color.g, material.color.b = color.r, color.g, color.b
		end

		local changed = false
		changed, currentTextureIndex = ImGui.Combo("纹理", currentTextureIndex, textures)
		if changed then
			material.texture = textures[currentTextureIndex]
		end

		-- 编辑光泽度
		local changed, shininess = ImGui.DragFloat("光泽度", material.shininess, 1.0, 0.0, 128.0, "%.0f")
		if changed then
			material.shininess = shininess
		end

		-- 输出当前材质的状态
		if ImGui.Button("输出状态") then
			print("当前材质状态：")
			p(material)
		end
	end)
end)
```

&emsp;&emsp;**说明**：

- 使用 `ColorEdit3` 进行颜色选择。
- 使用 `Combo` 创建下拉菜单供用户选择纹理。
- 使用 `DragFloat` 调整数值参数。

### 5.5 控制台窗口

&emsp;&emsp;实现一个简单的控制台窗口，用于输入命令和显示日志。

```lua
local ImGui <const> = require("ImGui")
local threadLoop <const> = require("threadLoop")
local Buffer <const> = require("Buffer")
local Vec2 <const> = require("Vec2")

local logs = {}
local inputBuffer = Buffer(200)

threadLoop(function()
	ImGui.SetNextWindowSize(Vec2(300, 200), "FirstUseEver")
	ImGui.Begin("控制台", function()
		-- 显示日志区域
		ImGui.BeginChild("LogArea", Vec2(0, -25), function()
			for _, log in ipairs(logs) do
				ImGui.TextWrapped(log)
			end
			if ImGui.GetScrollY() >= ImGui.GetScrollMaxY() then
				ImGui.SetScrollHereY(1.0)
			end
		end)
		-- 输入区域
		if ImGui.InputText("输入命令", inputBuffer, { "EnterReturnsTrue" }) then
			local command = inputBuffer.text
			table.insert(logs, "> " .. command)
			-- 执行命令（这里简单地回显）
			table.insert(logs, "执行结果：命令 [" .. command .. "] 已执行。")
			inputBuffer.text = ""
		end
	end)
end)
```

&emsp;&emsp;**说明**：

- 使用 `BeginChild` 创建日志显示区域。
- 使用 `InputText` 接受用户输入，并在按下回车时处理命令。
- 使用 `SetScrollHereY` 保持滚动条在底部。

### 5.6 状态栏和工具栏

&emsp;&emsp;在编辑器窗口中添加状态栏和工具栏，提供常用功能的快捷入口。

```lua
local ImGui <const> = require("ImGui")
local threadLoop <const> = require("threadLoop")
local Vec2 <const> = require("Vec2")

threadLoop(function()
	ImGui.Begin("编辑器主窗口", { "MenuBar", "AlwaysAutoResize" }, function()
		-- 工具栏
		ImGui.BeginMenuBar(function()
			ImGui.BeginMenu("文件", function()
				if ImGui.MenuItem("新建") then
					print("新建文件")
				end
				if ImGui.MenuItem("保存") then
					print("保存文件")
				end
			end)
			ImGui.BeginMenu("编辑", function()
				if ImGui.MenuItem("撤销") then
					print("撤销操作")
				end
			end)
		end)

		-- 主内容区域
		ImGui.Text("这里是主内容区域")
		ImGui.Dummy(Vec2(0, 100))

		-- 状态栏
		ImGui.BeginChild("StatusBar", Vec2(0, 20), function()
			ImGui.Text("状态：就绪")
		end)
	end)
end)
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

```lua
threadLoop(function()
	ImGui.Begin("示例窗口", function()
		ImGui.Text("这是一个示例窗口")
	end)
end)
```

* 优化后：

```lua
local function drawExampleWindow()
	ImGui.Text("这是一个示例窗口")
end

threadLoop(function()
	ImGui.Begin("示例窗口", drawExampleWindow)
end)
```

#### 6.3.2 使用函数缓存机制

&emsp;&emsp;**示例**：

* 优化前：

```lua
local objects = {
	{ name = "Object1", id = 1 },
	{ name = "Object2", id = 2 },
	{ name = "Object3", id = 3 },
}

threadLoop(function()
	ImGui.Begin("对象列表", function()
		for i, obj in ipairs(objects) do
			ImGui.TreeNode(obj.name, function()
				ImGui.Text("对象 ID：" .. obj.id)
			end)
		end
	end)
end)
```

* 优化后：

```lua
local objects = {
	{ name = "Object1", id = 1 },
	{ name = "Object2", id = 2 },
	{ name = "Object3", id = 3 },
}

local function getTreeNodeFunction(obj)
	if not obj.nodeFunction then
		obj.nodeFunction = function()
			ImGui.Text("对象 ID：" .. obj.id)
		end
	end
	return obj.nodeFunction
end

local function drawObjectList()
	for _, obj in ipairs(objects) do
		ImGui.TreeNode(obj.name, getTreeNodeFunction(obj))
	end
end

threadLoop(function(): boolean
	ImGui.Begin("对象列表", drawObjectList)
	return false
end)
```

#### 6.3.3 将复用的变量提取到闭包外

&emsp;&emsp;**示例**：

* 优化前：

```lua
threadLoop(function()
	ImGui.Begin("示例窗口", { "AlwaysAutoResize" }, function()
		ImGui.Text("这是一个示例窗口")
	end)
end)
```

* 优化后：

```lua
local windowFlags = { "AlwaysAutoResize" }
local drawFunction = function()
	ImGui.Text("这是一个示例窗口")
end
threadLoop(function()
	ImGui.Begin("示例窗口", windowFlags, drawFunction)
end)
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