# Developing Editors and Tools with ImGui

## 1. Introduction

In the game development process, an intuitive and efficient user interface (UI) is essential for editors and debugging tools. However, Dora SSR, as a code-focused engine, currently does not provide built-in editors or debugging tools. Therefore, developers need to quickly develop and customize these tools according to their game projects' needs. Fortunately, Dora SSR provides the **ImGui** library, which makes it easy to create such auxiliary UIs.

**ImGui** (Immediate Mode GUI) is an immediate mode graphical user interface library widely used for its simplicity and efficiency. This tutorial will introduce how to use the **ImGui** library provided by **Dora SSR** to develop UIs for game editors or debugging tools.

## 2. Philosophy, Advantages, and Disadvantages of ImGui Framework

### 2.1 Philosophy

The core philosophy of ImGui is **immediate mode**, which means that the UI is redrawn every frame. This differs from traditional retained mode, which maintains a UI state tree; immediate mode directly draws the UI based on the current program state.

### 2.2 Advantages

- **Easy to Use**: No need to manage complex UI states; UI elements can be described directly in code.
- **Rapid Iteration**: Suitable for quick prototyping and developing debugging tools.
- **Lightweight**: No need to integrate large UI frameworks, reducing resource consumption.
- **Highly Flexible**: Can be easily embedded into the existing game engine rendering loop.

### 2.3 Disadvantages

- **Not Suitable for Complex UIs**: It may not be ideal for applications requiring highly interactive and complex layouts.
- **Limited Styling**: The default visual style is relatively simple, and customization requires extra work, which may not meet the visual demands of game projects.
- **Performance Overhead**: In very complex UI scenarios, redrawing every frame may lead to performance issues.

## 4. Basic Usage

### 4.1 Creating a Simple Window

The following example demonstrates how to create a simple ImGui window:

```yue
_ENV = Dora Dora.ImGui

threadLoop ->
	Begin "Example Window", ->
		Text "Welcome to ImGui with Dora SSR!"
		Separator!
		TextWrapped "This is a simple example window showcasing basic text and a separator."
```

**Explanation**:

- The `threadLoop` function is used to repeatedly execute operations in the main thread.
- The `ImGui.Begin` function is used to create a window and specify the window's title.
- The `ImGui.Text` function is used to draw text.
- The `ImGui.Separator` function is used to draw a separator line.
- The `ImGui.TextWrapped` function is used to draw a block of text with automatic line wrapping.

### 4.2 Adding Interactive Elements

You can add interactive elements such as buttons and input fields in the window:

```yue
_ENV = Dora Dora.ImGui

inputText = with Buffer 200
	.text = "Default Text"
threadLoop ->
	Begin "Interaction Example", ->
		if Button "Click Me"
			print "Button Clicked!"
		if InputText "Input Field", inputText
			print "Input Content：" .. inputText.text
```

**Explanation**:

- The `ImGui.Button` function is used to create a button and specify the button's label.
- The `ImGui.InputText` function is used to create an input field and specify the field's label and buffer.

## 5. Example of Creating a Game Editor

### 5.1 Object Property Editor

The object property editor is a core component of the game editor, used to view and modify the properties of game objects.

```yue
_ENV = Dora Dora.ImGui

gameObject =
	name: "Player"
	position:
		x: 0.0
		y: 0.0
	rotation: 0.0,
	scale:
		x: 1.0
		y: 1.0
	isActive: true

nameBuffer = with Buffer 100
	.text = gameObject.name

threadLoop ->
	SetNextWindowSize Vec2(300, 400), "FirstUseEver"
	Begin "Object Property Editor", ->
		-- Edit object name
		if InputText "Name", nameBuffer
			gameObject.name = nameBuffer.text

		-- Edit position
		if changed, x, y := InputFloat2 "Position", gameObject.position.x, gameObject.position.y
			gameObject.position.x = x
			gameObject.position.y = y

		-- Edit rotation
		if changed, rotation := DragFloat "Rotation", gameObject.rotation, 1.0, 0.0, 360.0, "%.1f°"
			gameObject.rotation = rotation

		-- Edit scale
		if changed, sx, sy := InputFloat2 "Scale", gameObject.scale.x, gameObject.scale.y
			gameObject.scale.x = sx
			gameObject.scale.y = sy

		-- Edit active state
		if changed, isActive := Checkbox "Is Active", gameObject.isActive
			gameObject.isActive = isActive

		-- Output the current state of the object
		if Button "Output State"
			print "Current Object State:"
			p gameObject
```

**Explanation**:

- Use `InputText` to edit string properties.
- Use `InputFloat2` and `DragFloat` to edit numerical properties.
- Use `Checkbox` to edit boolean properties.

### 5.2 Scene Hierarchy View

The Scene Hierarchy View displays all game objects in the scene, presented in a tree structure.

```yue
_ENV = Dora Dora.ImGui

-- Assume we have a list of scene objects with parent-child relationships
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

-- Recursive function to draw the scene tree
drawSceneTree = (sceneObjects) ->
	for node in *sceneObjects
		if #node.children > 0
			TreeNode node.name, ->
				drawSceneTree node.children
		else
			TreeNodeEx node.name, node.name, leafFlags, empty

threadLoop ->
	Begin "Scene Hierarchy View", ->
		drawSceneTree sceneObjects
```

**Note**:

- Use `TreeNode` and `TreePop` to create a tree structure.
- Recursively draw each node and its children.

### 5.3 Resource Browser

The Resource Browser is used to view and select resources in the project, such as textures, models, and audio files.

```yue
_ENV = Dora Dora.ImGui

-- Resource list
resources =
	textures: ["texture1.png", "texture2.png", "texture3.png"]
	models: ["model1.obj", "model2.obj"]
	sounds: ["sound1.wav", "sound2.wav"]

threadLoop ->
	Begin "Resource Browser", ->
		if CollapsingHeader "Textures"
			for _, texture in ipairs resources.textures
				if Selectable texture
					print "Selected Texture: " .. texture

		if CollapsingHeader "Models"
			for _, model in ipairs resources.models
				if Selectable model
					print "Selected Model: " .. model

		if CollapsingHeader "Audio"
			for _, sound in ipairs resources.sounds
				if Selectable sound
					print "Selected Audio: " .. sound
```

**Note**:

- Use `CollapsingHeader` to group resource types.
- Use `Selectable` for list items to allow users to select resources.

### 5.4 Material Editor

The Material Editor allows users to adjust material properties such as color, texture, and shader parameters.

```yue
_ENV = Dora Dora.ImGui

-- Material object
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
	Begin "Material Editor", ->
		if InputText "Name", nameBuffer
			material.name = nameBuffer.text

		-- Edit color
		color = Color3 material.color.r, material.color.g, material.color.b
		if ColorEdit3 "Color", color
			material.color.r, material.color.g, material.color.b = color.r, color.g, color.b

		-- Select texture
		changed, currentTextureIndex = Combo "Texture", currentTextureIndex, textures
		if changed
			material.texture = textures[currentTextureIndex]

		-- Edit shininess
		changed, shininess = DragFloat "Shininess", material.shininess, 1.0, 0.0, 128.0, "%.0f"
		if changed
			material.shininess = shininess

		-- Output current material status
		if Button "Output Status"
			print "Current Material Status:"
			p material
```

**Note**:

- Use `ColorEdit3` for color selection.
- Use `Combo` to create a dropdown menu for selecting textures.
- Use `DragFloat` to adjust numerical parameters.

### 5.5 Console Window

Implement a simple console window for inputting commands and displaying logs.

```yue
_ENV = Dora Dora.ImGui

-- Log list
logs = {}

inputBuffer = Buffer 200

threadLoop ->
	Begin "Console", ->
		-- Display log area
		BeginChild "LogArea", Vec2(0, -25), ->
			for log in *logs
				TextWrapped log
			if GetScrollY! >= GetScrollMaxY!
				SetScrollHereY 1.0
		-- Input area
		if InputText "Enter Command", inputBuffer, ["EnterReturnsTrue",]
			command = inputBuffer.text
			table.insert logs, "> " .. command
			table.insert logs, "Execution Result: Command [" .. command .. "] has been executed."
			inputBuffer.text = ""
```

**Explanation**：

- Use `BeginChild` to create a log display area.
- Use `InputText` to accept user input and handle commands upon pressing Enter.
- Use `SetScrollHereY` to keep the scrollbar at the bottom.

### 5.6 Status Bar and Toolbar

Add a status bar and toolbar to the editor window, providing quick access to commonly used functions.

```yue
_ENV = Dora Dora.ImGui

threadLoop ->
	Begin "Editor Main Window", ["MenuBar", "AlwaysAutoResize"], ->
		-- Toolbar
		BeginMenuBar ->
			BeginMenu "File", ->
				if MenuItem "New"
					print "New File"
				if MenuItem "Save"
					print "

Save File"
			BeginMenu "Edit", ->
				if MenuItem "Undo"
					print "Undo Operation"

		-- Main content area
		Text "This is the main content area"
		Dummy Vec2 0, 100

		-- Status bar
		BeginChild "StatusBar", Vec2(0, 20), ->
			Text "Status: Ready"
```

**Explanation**：

- Use `BeginMenuBar` to create a menu bar or toolbar.
- Add a `BeginChild` in the main window to simulate the status bar.

## 6. Optimization Tips: Extracting Anonymous Functions to Reduce Memory Allocation

### 6.1 Problem Analysis

When developing with the **ImGui** library, a significant number of anonymous functions (closures) may be created each frame, leading to frequent memory allocation and garbage collection, which can negatively impact performance.

### 6.2 Solution

**Extract Anonymous Functions**: Extract anonymous functions into local functions to avoid creating new function objects every frame.

### 6.3 Optimization Methods

#### 6.3.1 Extracting Anonymous Functions as Local Functions

**Example**:

* Before Optimization:

```yue
threadLoop ->
	Begin "Example Window", ->
		Text "This is an example window"
```

* After Optimization:

```yue
drawExampleWindow = ->
	Text "This is an example window"

threadLoop ->
	Begin "Example Window", drawExampleWindow
```

#### 6.3.2 Using Function Caching Mechanism

**Example**:

* Before Optimization:

```yue
objects =
	* name: "Object1", id: 1
	* name: "Object2", id: 2
	* name: "Object3", id: 3

threadLoop ->
	Begin "Object List", ->
		for obj in *objects
			TreeNode obj.name, ->
				Text "Object ID: " .. obj.id
```

* After Optimization:

```yue
objects =
	* name: "Object1", id: 1
	* name: "Object2", id: 2
	* name: "Object3", id: 3

getTreeNodeFunction = (obj) ->
	if not obj.nodeFunction
		obj.nodeFunction = ->
			ImGui.Text "Object ID: " .. obj.id
	obj.nodeFunction

drawObjectList = ->
	for obj in *objects
		TreeNode obj.name, getTreeNodeFunction obj

threadLoop ->
	Begin "Object List", drawObjectList
```

#### 6.3.3 Extracting Reused Variables Outside the Closure

**Example**:

* Before Optimization:

```yue
threadLoop ->
	Begin "Example Window", [ "AlwaysAutoResize" ], ->
		Text "This is an example window"
```

* After Optimization:

```yue
windowFlags = [ "AlwaysAutoResize" ]
drawFunction = ->
	Text "This is an example window"

threadLoop ->
	Begin "Example Window", windowFlags, drawFunction
```

### 6.4 Summary

By extracting anonymous functions to the outer layer of closures, you can:

- **Reduce Memory Allocation Each Frame**: Avoid frequent creation of new functions and objects, reducing garbage collection pressure.
- **Improve Performance**: Minimize unnecessary overhead, allowing your game editor to run more smoothly.
- **Enhance Code Structure**: Clearly separate logic, improving code readability and maintainability.

## 7. Development Recommendations

- **Fully Utilize Immediate Mode**: Since ImGui is immediate mode, you can dynamically update the UI based on real-time program states.
- **Pay Attention to Performance**: In complex UIs, minimize unnecessary drawing and use conditional statements to control UI element updates when necessary.
- **Organize Code Structure**: Encapsulate reusable UI components into functions to enhance code readability and maintainability.
- **Monitor Performance**: Use profiling tools to monitor memory allocation and CPU usage to identify performance bottlenecks in a timely manner.
- **Code Review**: Regularly review code to identify potential optimization points and avoid unnecessary resource wastage.
- **Learn Best Practices**: For more ImGui usage methods, refer to official documentation and community experiences to learn and apply the best coding practices.

## 8. Conclusion

Through this tutorial, you should have a comprehensive understanding of how to use the ImGui library in Dora SSR to develop UIs for game editors or debugging tools. With its simplicity and efficiency, ImGui is particularly suitable for tool development and rapid prototyping. I hope you can fully leverage its advantages in your actual projects.