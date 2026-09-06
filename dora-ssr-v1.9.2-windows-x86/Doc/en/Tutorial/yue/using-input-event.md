# Basic Game Input Handling

In game development, handling player input is a critical component. The Dora SSR engine provides us with a rich API to manage various input methods, including touch/click, keyboard, input methods, mouse, and game controllers. This tutorial will guide you on how to handle these inputs using **event callbacks** and **per-frame polling**. The main differences between event callbacks and per-frame polling in input handling lie in their triggering mechanisms and applicable scenarios:

* **Event Callback**: Automatically triggered by the system when a specific input event occurs, providing timely responses and higher performance. It is suitable for handling instantaneous, discrete input events like clicks and key presses, resulting in more modular code.

* **Per-Frame Polling**: Requires actively checking the status of input devices within the game’s update loop. It is suitable for situations that need continuous monitoring of input states, such as character movement or sustained key presses. This method offers greater flexibility but may impact performance. Overall, event callbacks are more suitable for immediate input handling, while per-frame polling is better for scenarios requiring ongoing detection and complex input logic.

## 1. Touch/Click Input

### 1.1 Event Callback Method

Dora SSR provides a series of methods to listen for touch/click events on nodes. Touch events refer to operations on a touchscreen, while click events refer to operations using a mouse device. Generally, these two have similar handling methods. We can use `onTapBegan`, `onTapMoved`, `onTapEnded`, and `onTapped` methods to listen for these events. These methods need to be called through the creation of a scene node object.

```yue
_ENV = Dora

with Node!
	.size = Size 100, 100
	.showDebug = true

	\onTapBegan (touch) ->
		-- touch is an object containing touch information
		-- touch.location gives the touch position relative to the button node
		print "Tap began at", touch.location

	\onTapMoved (touch) ->
		print "Tap moved to", touch.location

	\onTapEnded (touch) ->
		print "Tap ended at", touch.location

	\onTapped (touch) ->
		print "Completed tap at", touch.location
```

**Note:**

- `onTapBegan`: Triggered when a touch begins.
- `onTapMoved`: Triggered when the touch moves on the screen.
- `onTapEnded`: Triggered when the touch ends.
- `onTapped`: Triggered when a complete tap (touch and release) is finished.

#### Touch/Click Event Filter

We can also set up a touch/click event filter by registering the `onTapFilter` method, where only events passing through the filter will trigger the callback. The `onTapFilter` callback will be triggered before `onTapBegan`.

```yue
button\onTapFilter (touch) ->
	-- For multi-touch situations, only handle the first touch point
	unless touch.first
		-- Set the touch event's enabled property to false
		-- This prevents the touch event from triggering subsequent onTapBegan callbacks
		touch.enabled = false
```

#### Multi-Touch Events

Dora SSR also supports multi-touch events, which can be listened to using the `onGesture` method.

```yue
button\onGesture (center, numTouches, deltaDist, angle) ->
	-- center: The center of all touch positions
	-- numTouches: The number of touch points
	-- deltaDist: The change in motion ratio (relative to the screen size)
	-- angle: The angle rotated around the touch center, in radians
	print "center:", center, "numTouches:", numTouches, "deltaDist:", delta, "angle:", angle
```

#### `swallowTouches` Property

Typically, touch/click events propagate from the root node down the scene node tree and are processed by each relevant node. If we want to stop the event from being passed down to child nodes after handling it on a certain node, we can set the `swallowTouches` property to `true`. Nodes with the `swallowTouches` property are typically used as masks to intercept touch events.

```yue
button.swallowTouches = true
```

#### Touch Event Toggle

If you need to pause or resume listening for events at a certain moment, such as disabling click events after a button press, you can use the `node.touchEnabled` property.

```yue
button.touchEnabled = false
```

### 1.2 Per-Frame Polling Method

Since touch events are instantaneous, they are not suitable for per-frame polling. However, we can simulate this method by recording the touch state in the variable scope of the parent level.

```yue
_ENV = Dora

with Node!
	isTouching = false

	\onTapBegan (touch) ->
		isTouching = true

	\onTapEnded (touch) ->
		isTouching = false

	-- In the game's update function
	\onUpdate ->
		if isTouching
			print "Currently touching"
```

**Note:**

- We use a boolean variable `isTouching` to record whether there is currently a touch.
- In the `update` function, we check the state of `isTouching` each frame.

## 2. Keyboard Input

### 2.1 Event Callback Method

You can use the `onKeyDown`, `onKeyUp`, and `onKeyPressed` methods to listen for keyboard events.

```yue
_ENV = Dora

with Node!
	\onKeyDown (keyName) ->
		print "Key pressed:", keyName

	\onKeyUp (keyName) ->
		print "Key released:", keyName

	\onKeyPressed (keyName) ->
		print "Key held down:", keyName
```

**Note:**

- `onKeyDown`: Triggered when a key is pressed.
- `onKeyUp`: Triggered when a key is released.
- `onKeyPressed`: Triggered every frame while the key is held down.

#### Keyboard Event Toggle

If you need to pause or resume listening for events at a certain moment, you can use the `node.keyboardEnabled` property.

```yue
node.keyboardEnabled = false
```

### 2.2 Per-Frame Polling Method

Use the `Keyboard` class's `isKeyDown`, `isKeyUp`, and `isKeyPressed` methods.

**Example Code:**

```yue
_ENV = Dora

with Node!
	\onUpdate ->
		if Keyboard\isKeyDown "A"
			print "Key A pressed this frame"

		if Keyboard\isKeyUp "D"
			print "Key D released this frame"

		if Keyboard\isKeyPressed "Space"
			print "Space key is being held down"
```

**Explanation:**

- `isKeyDown`: Checks if the specified key was pressed in the current frame.
- `isKeyUp`: Checks if the specified key was released in the current frame.
- `isKeyPressed`: Checks if the specified key is currently held down.
- `A`, `D`, `Space`: These parameters represent the key names. For specific key names, refer to the [Keyboard Key Names](../../api/Class/Keyboard#keyboardkeyname).

## 3. Input Method Input

### 3.1 Event Callback Method

Use the `onAttachIME`, `onDetachIME`, `onTextInput`, and `onTextEditing` methods to handle input method events.

```yue
_ENV = Dora

with Node!
	\onAttachIME ->
		print "Input method listener activated"

	\onDetachIME ->
		print "Input method listener deactivated"

	\onTextInput (text) ->
		-- Triggered after the input method confirms the input
		print "Text inputted:", text

	\onTextEditing (text, startPos) ->
		-- Triggered while editing text in the input method
		print "Input method is editing text:", text, "Start position:", startPos

	-- Activate the input method on the node and start listening for input method events
	-- Only one node can activate the input method at a time
	-- Activating it stops the listener on other nodes' input methods
	\attachIME!
```

**Note:**

- `onAttachIME`: Triggered when the input method is activated.
- `onDetachIME`: Triggered when the input method is closed.
- `onTextInput`: Triggered when text is confirmed to be inputted.
- `onTextEditing`: Triggered when editing text, usually during the candidate word display phase.

### 3.2 Position Hint for Input Method

On some small-screen devices, the input method may cover the input box, or we may want the input method's position to follow our input box. In this case, we can set the input method's position hint using the `Keyboard.updateIMEPosHint` method.

```yue
_ENV = Dora

with Label "sarasa-mono-sc-regular", 40
	.text = "Enter text"

	updateIMEPos = (after) ->
		-- Convert the lower right corner of the input box to window coordinates
		\convertToWindowSpace Vec2(.width, 0), (pos) ->
			Keyboard\updateIMEPosHint pos
			after! if after

	\onTextInput (text) ->
		.text ..= text
		updateIMEPos!

	\onTapped ->
		.text = "Inputting"
		-- Update the input method position hint
		updateIMEPos ->
			\detachIME!
			\attachIME!
			-- Update the input method position hint again for mobile platforms
			updateIMEPos!
```

**Explanation:**

In the above code, we create an input box. When the input box is clicked, the input method is activated, and the input method's position follows the input box. When text is input into the input box, the input method's position is also updated.

- `Keyboard.updateIMEPosHint`: Sets the input method position hint, and the input method will try to avoid covering this position.
- `label.convertToWindowSpace`: Converts node coordinates to window coordinates, returning the converted coordinates through a callback function for setting the input method position hint.

## 4. Mouse Input

### 4.1 Event Callback Method

Use `onMouseMove` to receive mouse pointer positions automatically converted through the current camera and the node's transform, and use `onMouseWheel` to listen for mouse wheel events. `onMouseMove` only responds to mouse movement; to handle both touch and mouse input, use `onTapBegan`, `onTapMoved`, and `onTapEnded`. Mouse button events generally overlap with touch events, and mouse clicks can be handled using touch event methods.

```yue
_ENV = Dora

with Node!
	\onMouseMove (touch) ->
		print "Mouse position in node space:", touch.location

	\onMouseWheel (delta) ->
		print "Mouse wheel scrolled:", delta.x, delta.y
```

**Note:**

- `onMouseMove`: Triggered when the mouse moves, even when no button is pressed. It does not respond to touch input; use `onTapBegan`, `onTapMoved`, and `onTapEnded` when both touch and mouse must be supported. `touch.location` is the pointer position in the node's local space. The conversion automatically accounts for the current camera's position, rotation, zoom and projection, as well as the node's 2D or 3D transform. Use `touch.viewLocation` when the position in the current view's logical coordinate system is needed.
- `onMouseWheel`: Triggered when the mouse wheel is scrolled. The `delta` contains the scrolling distance information, including values for both the `x` and `y` directions.

#### Mouse Event Toggle

Mouse move and wheel events are controlled by the `node.touchEnabled` property. Calling `onMouseMove` or `onMouseWheel` enables it automatically. Setting `node.touchEnabled` to `false` disables both events.

### 4.2 Per-Frame Polling Method

Use properties of the `Mouse` class to get the mouse status.

```yue
_ENV = Dora

getMousePositionInNode = (target) ->
	camera = Director.currentCamera
	mouse = Mouse.position
	visualSize = App.visualSize
	viewSize = View.size
	viewPos = Vec2(
		mouse.x * viewSize.width / visualSize.width - viewSize.width / 2
		viewSize.height / 2 - mouse.y * viewSize.height / visualSize.height
	) / camera.zoom
	angle = math.rad camera.rotation
	worldPos = Vec2(
		viewPos.x * math.cos(angle) - viewPos.y * math.sin(angle)
		viewPos.x * math.sin(angle) + viewPos.y * math.cos(angle)
	) + camera.position
	target\convertToNodeSpace worldPos

node = Node!
node\onUpdate ->
	print "Mouse position in node space:", getMousePositionInNode node

	if Mouse.leftButtonPressed
		print "Mouse left button pressed"

	if Mouse.rightButtonPressed
		print "Mouse right button pressed"

	if Mouse.middleButtonPressed
		print "Mouse middle button pressed"

	if Mouse.wheel != Vec2.zero
		print "Mouse wheel value:", Mouse.wheel
```

**Note:**

- `Mouse.position`: Retrieves the mouse position in the visible window's logical coordinate system, with the origin at the top-left.
- `getMousePositionInNode`: Converts `Mouse.position` to node-local coordinates for a Camera2D scene. Zoom is divided rather than multiplied; camera rotation and position are also applied before converting from world space to node space.
- For 3D node transforms or custom camera projections, prefer `node.onMouseMove()` and `touch.location`, which use inverse view-projection calculation and ray-plane intersection.
- `leftButtonPressed` and similar properties: Check the pressed state of mouse buttons.
- `Mouse.wheel`: Gets the scrolling value of the mouse wheel.

## 5. Game Controller Input

### 5.1 Event Callback Method

Use the `onButtonDown`, `onButtonUp`, `onButtonPressed`, and `onAxis` methods to listen for controller events.

```yue
_ENV = Dora

with Node!
	\onButtonDown (controllerId, buttonName) ->
		print "Controller", controllerId, "button pressed:", buttonName

	\onButtonUp (controllerId, buttonName) ->
		print "Controller", controllerId, "button released:", buttonName

	\onButtonPressed (controllerId, buttonName) ->
		print "Controller", controllerId, "button held down:", buttonName

	\onAxis (controllerId, axisName, value) ->
		print "Controller", controllerId, "axis", axisName, "value:", value
```

**Note:**

- `onButtonDown`: Triggered when a controller button is pressed.
- `onButtonUp`: Triggered when a controller button is released.
- `onButtonPressed`: Triggered every frame while the controller button is held down.
- `buttonName`: The name of the button, such as `a`, `b`, `x`, `y`, etc. Specific button names can be found in the [Controller Button Names](../../api/Class/Controller#controllerbuttonname).
- `onAxis`: Triggered when a controller axis (such as a joystick or trigger) changes.
- `axisName`: The name of the axis, such as `leftx`, `lefty`, `rightx`, `righty`, etc. Specific axis names can be found in the [Controller Axis Names](../../api/Class/Controller#controlleraxisname).

#### Controller Event Toggle

If you need to pause or resume listening for events at a certain moment, you can use the `node.controllerEnabled` property.

```yue
node.controllerEnabled = false
```

### 5.2 Per-Frame Polling Method

Use methods from the `Controller` class to obtain the status of the controller.

**Example Code:**

```yue
_ENV = Dora

with Node!
	\onUpdate ->
		-- Assume only one controller is connected, controller ID starts from 0
		controllerId = 0

		-- Check button status
		if Controller\isButtonDown controllerId, "a"
			print "Controller", controllerId, "button A pressed this frame"

		if Controller\isButtonUp controllerId, "a"
			print "Controller", controllerId, "button A released this frame"

		if Controller\isButtonPressed controllerId, "a"
			print "Controller", controllerId, "button A is being held down"

		-- Get axis values
		leftX = Controller\getAxis controllerId, "leftx"
		leftY = Controller\getAxis controllerId, "lefty"
		if leftX != 0 or leftY != 0
			print "Left joystick position:", leftX, leftY
```

**Note:**

- `isButtonDown`: Checks if the specified button is pressed in the current frame.
- `isButtonUp`: Checks if the specified button is released in the current frame.
- `isButtonPressed`: Checks if the specified button is currently held down.
- `getAxis`: Retrieves the current value of the specified axis, ranging from -1.0 to 1.0.

## 6. Summary

In this tutorial, we learned how to use the API of the Dora SSR engine to handle various input methods. Through **event callbacks**, we can respond immediately when input events occur; through **

per-frame polling**, we can continuously check input states within the game’s update loop. Depending on the game's needs, you can choose the appropriate method or combine both to achieve optimal input handling effects. In the next tutorial, we will learn how to use the `Enhanced Input Function Module` of Dora SSR to simplify input handling code and manage more complex input logic.

I hope this tutorial helps you better understand and utilize the input handling capabilities of the Dora SSR engine. Happy developing!