# 基础的游戏输入处理

&emsp;&emsp;在游戏开发中，处理玩家的输入是非常关键的一环。Dora SSR 引擎为我们提供了丰富的 API 来处理各种输入方式，包括触摸/点击、键盘、输入法、鼠标和游戏控制器。本教程将带你了解如何以**事件回调**和**每帧轮询**两种方式来处理这些输入。事件回调和每帧轮询在输入处理上的主要区别在于触发机制和适用场景：

* **事件回调**：是由系统在特定输入事件发生时自动触发的，响应及时，性能更高，适合处理瞬时、离散的输入事件，如点击、按键等，代码更模块化；

* **每帧轮询**：需要在游戏的更新循环中主动检查输入设备的状态，适用于需要持续监控输入状态的情况，如角色移动、持续按键等，提供了更大的灵活性，但可能对性能有一定影响。综合而言，事件回调更适合即时响应的输入处理，每帧轮询则更适合需要持续检测和复杂输入逻辑的场景。

## 1. 触摸/点击输入

### 1.1 事件回调方式

&emsp;&emsp;Dora SSR 提供了一系列方法来监听节点的触摸/点击事件，触摸事件是指在触摸屏上的操作，点击事件是指通过鼠标设备的操作，通常这两者会有相似的处理方式。我们可以使用 `onTapBegan`、`onTapMoved`、`onTapEnded` 和 `onTapped` 方法来监听这些事件。需要通过创建一个场景节点对象进行调用。

```lua
local Node <const> = require("Node")
local Size <const> = require("Size")

local button = Node()
button.size = Size(100, 100)
button.showDebug = true

button:onTapBegan(function(touch)
	-- touch 是一个包含触摸信息的对象
	-- 可以通过 touch.location 获取相对于 button 节点的触摸位置
	print("点击开始于", touch.location)
end)

button:onTapMoved(function(touch)
	print("点击移动到", touch.location)
end)

button:onTapEnded(function(touch)
	print("点击结束于", touch.location)
end)

button:onTapped(function(touch)
	print("完成一次点击于", touch.location)
end)
```

&emsp;&emsp;**说明：**

- `onTapBegan`：当触摸开始时触发。
- `onTapMoved`：当触摸在屏幕上移动时触发。
- `onTapEnded`：当触摸结束时触发。
- `onTapped`：当一次完整的点击（点击并抬起）完成时触发。

#### 触摸/点击事件过滤器

&emsp;&emsp;我们还可以通过注册 `onTapFilter` 方法来设置触摸/点击事件的过滤器，只有通过过滤器的事件才会触发回调。`onTapFilter` 回调会在 `onTapBegan` 之前触发。

```lua
button:onTapFilter(function(touch)
	-- 如果为多点触摸的情况，只处理第一个触摸点
	if not touch.first then
		-- 将触摸事件的 enabled 属性设置为 false
		-- 使得该触摸事件不会触发后续的 onTapBegan 等回调
		touch.enabled = false
	end
end)
```

#### 多点触摸事件

&emsp;&emsp;Dora SSR 还支持多点触摸事件，可以通过 `onGesture` 方法来监听。

```lua
button:onGesture(function(center, numTouches, deltaDist, angle)
	-- center: 所有触摸位置的中心
	-- numTouches: 触摸点的数量
	-- deltaDist: 变化的运动比例（相对于屏幕尺寸）
	-- angle: 沿着触摸中心旋转的角度，单位为弧度
	print("center:", center, "numTouches:", numTouches, "deltaDist:", delta, "angle:", angle)
end)
```

#### `swallowTouches` 属性

&emsp;&emsp;通常触摸/点击事件会沿着场景节点树从根节点向下传递，并被每一个相关的节点处理。如果我们希望在某个节点上处理完触摸/点击事件后，不再继续往下传递给其子节点，可以设置 `swallowTouches` 属性为 `true`。加上了 `swallowTouches` 属性的节点通常会被用作拦截触摸事件的遮罩层。

```lua
button.swallowTouches = true
```

#### 触摸事件的开关

&emsp;&emsp;如果需要在某个时刻暂停或恢复监听事件，如实现按钮按下后禁用点击事件，可以使用 `node.touchEnabled` 属性。

```lua
button.touchEnabled = false
```

### 1.2 每帧轮询方式

&emsp;&emsp;由于触摸事件是即时的，不适合用每帧轮询的方式处理。然而，我们可以通过在上一级变量域范围内记录触摸状态来模拟这种方式。

```lua
local Node <const> = require("Node")

local button = Node()
local isTouching = false

button:onTapBegan(function(touch)
	isTouching = true
end)

button:onTapEnded(function(touch)
	isTouching = false
end)

-- 在游戏的更新函数中
button:onUpdate(function()
	if isTouching then
		print("正在触摸")
	end
end)
```

&emsp;&emsp;**说明：**

- 我们使用一个布尔变量 `isTouching` 来记录当前是否有触摸。
- 在 `update` 函数中，每帧检查 `isTouching` 的状态。

## 2. 键盘输入

### 2.1 事件回调方式

&emsp;&emsp;可以使用 `onKeyDown`、`onKeyUp` 和 `onKeyPressed` 方法来监听键盘事件。

```lua
local Node <const> = require("Node")

local node = Node()

node:onKeyDown(function(keyName)
	print("按下键：", keyName)
end)

node:onKeyUp(function(keyName)
	print("释放键：", keyName)
end)

node:onKeyPressed(function(keyName)
	print("持续按键：", keyName)
end)
```

&emsp;&emsp;**说明：**

- `onKeyDown`：当按键被按下时触发。
- `onKeyUp`：当按键被释放时触发。
- `onKeyPressed`：当按键处于按下状态时每帧触发。

#### 键盘事件的开关

&emsp;&emsp;如果需要在某个时刻暂停或恢复监听事件，可以使用 `node.keyboardEnabled` 属性。

```lua
node.keyboardEnabled = false
```

### 2.2 每帧轮询方式

&emsp;&emsp;使用 `Keyboard` 类的 `isKeyDown`、`isKeyUp` 和 `isKeyPressed` 方法。

**示例代码：**

```lua
local Keyboard <const> = require("Keyboard")
local Node <const> = require("Node")

local node = Node()

node:onUpdate(function()
	if Keyboard:isKeyDown("A") then
		print("本帧按下了键 A")
	end

	if Keyboard:isKeyUp("D") then
		print("本帧释放了键 D")
	end

	if Keyboard:isKeyPressed("Space") then
		print("空格键正在被按住")
	end
end)
```

**解释：**

- `isKeyDown`：检查在当前帧是否按下了指定按键。
- `isKeyUp`：检查在当前帧是否释放了指定按键。
- `isKeyPressed`：检查指定按键是否处于按下状态。
- `A`、`D`、`Space`: 等参数为按键的名称。具体的按键名称可以参考[键盘按键名称](../../api/Class/Keyboard#keyboardkeyname)。

## 3. 输入法输入

### 3.1 事件回调方式

&emsp;&emsp;使用 `onAttachIME`、`onDetachIME`、`onTextInput` 和 `onTextEditing` 方法处理输入法事件。

```lua
local Node <const> = require("Node")

local inputField = Node()

inputField:onAttachIME(function()
	print("输入法监听已打开")
end)

inputField:onDetachIME(function()
	print("输入法监听已关闭")
end)

inputField:onTextInput(function(text)
	-- 在输入法确认输入后触发
	print("输入了文本：", text)
end)

inputField:onTextEditing(function(text, startPos)
	-- 输入法正在编辑文本时触发
	print("输入法正在编辑文本：", text, "起始位置：", startPos)
end)

-- 在节点上激活输入法，并开始监听输入法事件
-- 同时只有一个节点可以激活输入法
-- 激活后其他节点的输入法，当前节点的监听会被停止
inputField:attachIME()
```

&emsp;&emsp;**说明：**

- `onAttachIME`：当输入法被激活时触发。
- `onDetachIME`：当输入法被关闭时触发。
- `onTextInput`：当有文本被确认输入时触发。
- `onTextEditing`：当正在编辑文本时触发，通常是显示候选词的编辑阶段。

### 3.2 设置输入法位置提示

&emsp;&emsp;在一些小屏幕的设备上，输入法可能会遮挡输入框，或是我们希望输入法的位置跟随我们的输入框。这时可以通过设置 `Keyboard.updateIMEPosHint` 方法来设置输入法的位置提示。

```lua
local Keyboard <const> = require("Keyboard")
local Label <const> = require("Label")
local Vec2 <const> = require("Vec2")

local label = Label("sarasa-mono-sc-regular", 40)
label.text = "请输入文本"

local function updateIMEPos(after)
	-- 将输入框的右下角转换为窗口坐标
	label:convertToWindowSpace(Vec2(label.width, 0), function(pos)
		Keyboard:updateIMEPosHint(pos)
		if after then after() end
	end)
end

label:onTextInput(function(text)
	label.text = label.text .. text
	updateIMEPos()
end)

label:onTapped(function()
	label.text = "输入中"
	-- 更新输入法位置提示
	updateIMEPos(function()
		label:detachIME()
		label:attachIME()
		-- 为移动平台再次更新输入法位置
		updateIMEPos()
	end)
end)
```

&emsp;&emsp;**说明：**

&emsp;&emsp;上述代码中，我们创建了一个输入框，当输入框被点击时，输入框会被激活输入法，同时输入法的位置会跟随输入框。当输入框输入文本时，输入法的位置也会被更新。

- `Keyboard.updateIMEPosHint`：设置输入法位置提示，输入法会尽量避免遮挡这个位置。
- `label.convertToWindowSpace`：将节点坐标转换为窗口坐标，会通过回调函数返回转换后的坐标，用于设置输入法位置提示。

## 4. 鼠标输入

### 4.1 事件回调方式

&emsp;&emsp;使用 `onMouseMove` 获取经过当前摄像机和节点变换自动转换后的鼠标位置，使用 `onMouseWheel` 监听鼠标滚轮事件。`onMouseMove` 仅响应鼠标移动；如需同时处理触摸和鼠标输入，请使用 `onTapBegan`、`onTapMoved` 和 `onTapEnded`。鼠标按键事件通常与触摸事件重叠，可以使用触摸事件的方法来处理鼠标点击。

```lua
local Node <const> = require("Node")

local node = Node()

node:onMouseMove(function(touch)
	print("鼠标在节点局部空间中的位置：", touch.location)
end)

node:onMouseWheel(function(delta)
	print("鼠标滚轮滚动：", delta.x, delta.y)
end)
```

&emsp;&emsp;**说明：**

- `onMouseMove`：鼠标移动时触发，无需按下鼠标按键。该事件不会响应触摸输入；如需同时兼容触摸和鼠标，请使用 `onTapBegan`、`onTapMoved` 和 `onTapEnded`。`touch.location` 是鼠标在节点局部空间中的位置，转换过程会自动处理当前摄像机的位置、旋转、缩放和投影，以及节点的 2D 或 3D 变换。如需当前视区逻辑坐标系中的位置，可使用 `touch.viewLocation`。
- `onMouseWheel`：当鼠标滚轮滚动时触发，`delta` 包含滚动的距离信息，包含 `x` 和 `y` 两个方向的滚动值。

#### 鼠标事件的开关

&emsp;&emsp;鼠标移动和滚轮事件都受到 `node.touchEnabled` 属性的控制。调用 `onMouseMove` 或 `onMouseWheel` 时会自动启用该属性；将 `node.touchEnabled` 设置为 `false` 会禁用这两类事件。

### 4.2 每帧轮询方式

&emsp;&emsp;使用 `Mouse` 类的属性来获取鼠标状态。

```lua
local App <const> = require("App")
local Director <const> = require("Director")
local Mouse <const> = require("Mouse")
local Node <const> = require("Node")
local Vec2 <const> = require("Vec2")
local View <const> = require("View")

local node = Node()

local function getMousePositionInNode(target)
	local camera = Director.currentCamera
	local mouse = Mouse.position
	local visualSize = App.visualSize
	local viewSize = View.size
	local viewPos = Vec2(
		mouse.x * viewSize.width / visualSize.width - viewSize.width / 2,
		viewSize.height / 2 - mouse.y * viewSize.height / visualSize.height
	) / camera.zoom
	local angle = math.rad(camera.rotation)
	local worldPos = Vec2(
		viewPos.x * math.cos(angle) - viewPos.y * math.sin(angle),
		viewPos.x * math.sin(angle) + viewPos.y * math.cos(angle)
	) + camera.position
	return target:convertToNodeSpace(worldPos)
end

node:onUpdate(function()
	print("鼠标在节点局部空间中的位置：", getMousePositionInNode(node))

	if Mouse.leftButtonPressed then
		print("鼠标左键被按下")
	end

	if Mouse.rightButtonPressed then
		print("鼠标右键被按下")
	end

	if Mouse.middleButtonPressed then
		print("鼠标中键被按下")
	end

	if Mouse.wheel ~= Vec2.zero then
		print("鼠标滚轮值：", Mouse.wheel)
	end
end)
```

&emsp;&emsp;**说明：**

- `Mouse.position`：获取鼠标在可视窗口逻辑坐标系中的位置，原点位于左上角。
- `getMousePositionInNode`：在 Camera2D 场景中将 `Mouse.position` 转换为节点局部坐标。摄像机缩放需要做除法而不是乘法，并在从世界坐标转换到节点坐标前处理摄像机旋转和位置。
- 对于节点 3D 变换或自定义摄像机投影，建议使用 `node.onMouseMove()` 和 `touch.location`，由内部完成逆视图投影和射线平面求交计算。
- `leftButtonPressed` 等属性：判断鼠标按键的按下状态。
- `Mouse.wheel`：获取鼠标滚轮的滚动值。

## 5. 游戏控制器输入

### 5.1 事件回调方式

&emsp;&emsp;使用 `onButtonDown`、`onButtonUp`、`onButtonPressed` 和 `onAxis` 方法来监听控制器事件。

```lua
local Node <const> = require("Node")

local node = Node()

node:onButtonDown(function(controllerId, buttonName)
	print("控制器", controllerId, "按下按钮：", buttonName)
end)

node:onButtonUp(function(controllerId, buttonName)
	print("控制器", controllerId, "释放按钮：", buttonName)
end)

node:onButtonPressed(function(controllerId, buttonName)
	print("控制器", controllerId, "持续按住按钮：", buttonName)
end)

node:onAxis(function(controllerId, axisName, value)
	print("控制器", controllerId, "轴", axisName, "的值：", value)
end)
```

&emsp;&emsp;**说明：**

- `onButtonDown`：当控制器按钮被按下时触发。
- `onButtonUp`：当控制器按钮被释放时触发。
- `onButtonPressed`：当控制器按钮被按住时每帧触发。
- `buttonName`：按钮的名称，如 `a`、`b`、`x`、`y` 等。具体的按钮名称可以参考[控制器按钮名称](../../api/Class/Controller#controllerbuttonname)。
- `onAxis`：当控制器的轴（如摇杆、扳机）发生变化时触发。
- `axisName`：轴的名称，如 `leftx`、`lefty`、`rightx`、`righty` 等。具体的轴名称可以参考[控制器轴名称](../../api/Class/Controller#controlleraxisname)。

#### 控制器事件的开关

&emsp;&emsp;如果需要在某个时刻暂停或恢复监听事件，可以使用 `node.controllerEnabled` 属性。

```lua
node.controllerEnabled = false
```

### 5.2 每帧轮询方式

&emsp;&emsp;使用 `Controller` 类的方法来获取控制器的状态。

**示例代码：**

```lua
local Controller <const> = require("Controller")
local Node <const> = require("Node")

local node = Node()

node:onUpdate(function()
	-- 假设只连接了一个控制器，控制器编号会从 0 开始递增
	local controllerId = 0

	-- 检查按钮状态
	if Controller:isButtonDown(controllerId, "a") then
		print("控制器", controllerId, "本帧按下了按钮 A")
	end

	if Controller:isButtonUp(controllerId, "a") then
		print("控制器", controllerId, "本帧释放了按钮 A")
	end

	if Controller:isButtonPressed(controllerId, "a") then
		print("控制器", controllerId, "按钮 A 正在被按住")
	end

	-- 获取轴的值
	local leftX = Controller:getAxis(controllerId, "leftx")
	local leftY = Controller:getAxis(controllerId, "lefty")
	if leftX ~= 0 or leftY ~= 0 then
		print("左摇杆位置：", leftX, leftY)
	end
end)
```

&emsp;&emsp;**说明：**

- `isButtonDown`：检查在当前帧是否按下了指定按钮。
- `isButtonUp`：检查在当前帧是否释放了指定按钮。
- `isButtonPressed`：检查指定按钮是否处于按下状态。
- `getAxis`：获取指定轴的当前值，范围为 -1.0 到 1.0。

## 6. 总结

&emsp;&emsp;在本教程中，我们学习了如何使用 Dora SSR 引擎的 API 来处理各种输入方式。通过**事件回调**，我们可以在输入事件发生时立即响应；通过**每帧轮询**，我们可以在游戏的更新循环中持续检查输入状态。根据游戏的需求，可以选择合适的方式或结合两者来实现最佳的输入处理效果。在下一篇教程中，我们将学习如何使用 Dora SSR 的`增强输入功能模块`来简化输入处理的代码，并处理更复杂的输入逻辑。

&emsp;&emsp;希望本教程能帮助你更好地理解和使用 Dora SSR 引擎的输入处理功能，祝你开发愉快！