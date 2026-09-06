# Screen Adaptation for Scenes and UI

In game development, screen adaptation is a crucial feature. No matter what device or window size the player uses, they want to have the best visual experience. This tutorial will guide you step by step on how to implement screen adaptation for game scenes and UI in the Dora SSR engine.

## 1. Understanding Screen Adaptation

On different devices, screen sizes and resolutions vary. Without adaptation, the game may not display properly on certain devices, or the elements may be misaligned. The goal of screen adaptation is to ensure the game content displays correctly across various screens while maintaining a good user experience.

## 2. Implementing Screen Adaptation for Game Scenes

Screen adaptation for game scenes primarily involves adjusting the camera's view based on the window size, ensuring that the scene's content is fully displayed on the screen.

### 2.1 Define Design Dimensions

Define the game's **design dimensions** as an important reference for game scene and interface design.

The example code below defines the height and width for scene design:

```lua
local DesignSceneHeight <const> = 1080
local DesignSceneWidth <const> = 1920
```

Here we've set the design height to `1080` and the design width to `1920`, together forming a typical `1920x1080` reference resolution (16:9 aspect ratio). This dimension can be used to standardize scene layout, UI design, and the size and position of visual elements.

#### Scene Size Adaptation Methods

When a game runs on devices with different screen sizes, there are three common adaptation strategies:

1. **Height-Based Adaptation**

	Scale the scene size based on the actual screen height:

	```lua
	View.size.height / DesignSceneHeight
	```

	This method ensures that vertical content is fully displayed. However, on narrower screens, horizontal content may be cropped or extend beyond the screen boundaries.

2. **Width-Based Adaptation**

	Scale the scene size based on the actual screen width:

	```lua
	View.size.width / DesignSceneWidth
	```

	This approach ensures that horizontal content is fully displayed, but on shorter screens, vertical content may be cropped or extend beyond the screen boundaries.

3. **Adapting to Both Width and Height**

	Use the minimum value of width and height scaling factors:

	```lua
	math.min(View.size.width / DesignSceneWidth, View.size.height / DesignSceneHeight)
	```

	This method ensures all scene content is fully visible and not cropped, but when the screen aspect ratio differs from the design dimensions, it creates empty areas at the edges, resulting in a letterboxing effect.

Each adaptation method has its own characteristics, and the specific choice depends on your game type and design requirements. For most games, height-based adaptation is more common because it ensures that important game elements at the top and bottom remain visible, while horizontal areas can be appropriately cropped or freely extended.

### 2.2 Adjust Camera Zoom

Next, adjust the camera's zoom based on the current window size.

```lua
local Director <const> = require("Director")
local View <const> = require("View")

local function updateViewSize()
	Director.currentCamera.zoom = View.size.height / DesignSceneHeight -- Height-Based Adaptation
end
```

**Explanation:**

- `Director.currentCamera`: The current scene's camera object.
- `zoom`: The camera's zoom property, which affects the field of view.
- `View.size.height`: The actual height of the current window.
- By calculating `View.size.height / DesignSceneHeight`, we get the ratio of the actual height to the design height and set it as the camera's zoom value.

### 2.3 Listen for Window Size Changes

To update the camera's zoom whenever the window size changes (e.g., when the user resizes the window or rotates the device), we need to listen for the application's size change events.

```lua
updateViewSize()  -- Call once during initialization

Director.entry:onAppChange(function(settingName)
	if settingName == "Size" then
		updateViewSize() -- Update whenever a size change occurs
	end
end)
```

**Explanation:**

- `Director.entry:onAppChange`: Registers a listener that triggers when the application's settings change.
- `settingName`: The name of the setting that changed.
- When `settingName` is `"Size"`, it indicates that the window size has changed, and we call `updateViewSize()` to update the camera's zoom.

### 2.4 Complete Code

```lua
-- Example of game scene adaptation

-- Import modules
local DrawNode <const> = require("DrawNode")
local Director <const> = require("Director")
local View <const> = require("View")
local Vec2 <const> = require("Vec2")

-- Define design dimensions
local DesignSceneHeight <const> = 1080

-- Create the scene
local node = DrawNode()
node:drawDot(Vec2.zero, DesignSceneHeight / 2)
node:addTo(Director.entry)

-- Handle window size changes
local function updateViewSize()
	Director.currentCamera.zoom = View.size.height / DesignSceneHeight -- Height-Based Adaptation
end

-- Call once during initialization
updateViewSize()

-- Register event callback for window size changes
Director.entry:onAppChange(function(settingName)
	if settingName == "Size" then
		updateViewSize()
	end
end)
```

## 3. Implementing Screen Adaptation for Game UI

Screen adaptation for game UI involves ensuring that interface elements are properly arranged on screens of different sizes. We will use the Dora SSR integrated [**Yoga Layout Engine**](https://github.com/facebook/yoga), which defines element layout relationships using CSS-like Flexbox layout syntax.

### 3.1 Import Yoga Layout Engine

**Yoga** is a cross-platform layout engine that supports Flexbox-based layouts. It allows us to define layouts using familiar CSS syntax.

```lua
local AlignNode <const> = require("AlignNode")
```

`AlignNode` is the layout node type in Dora SSR that supports layout functions.

### 3.2 Using CSS Flex Layout

:::tip A recommended game to learn CSS Flex Layout
To quickly learn Flex layout, you can try **Flexbox Froggy**, an online game: https://flexboxfroggy.com/
:::

First, create a root node and set its layout properties.

```lua
local root = AlignNode(true)
root:css("justify-content: center; align-items: center")
root:addTo(Director.ui)
```

**Explanation:**

- `AlignNode(true)`: Creates a layout-supporting node. `true` indicates this node is the layout container for the window's root.
- `css(...)`: Applies CSS layout styles to the node.
	- `justify-content: center`: Horizontally center the child nodes.
	- `align-items: center`: Vertically center the child nodes.
- `root:addTo(Director.ui)`: Adds the root node to the built-in UI layer of the engine.

Next, create a child node and set its size relative to the parent node's percentage.

```lua
local centerNode = AlignNode()
centerNode:css("width: 60%; height: 60%")
centerNode:addTo(root)
```

**Explanation:**

- `width: 60%`: Sets the width to 60% of the parent node's width.
- `height: 60%`: Sets the height to 60% of the parent node's height.

### 3.3 Adjust Elements to Fit the Layout

Add actual UI elements (e.g., sprite objects displaying images) to the layout node and adjust their properties after the layout is complete.

```lua
local sprite = Sprite("Image/logo.png")
sprite:addTo(centerNode)
```

To update the sprite's position and size after the layout adjusts for screen adaptation, we need to listen for the layout completion event.

```lua
centerNode:onAlignLayout(function(width, height)
	-- Adjust sprite display parameters to match the adapted result
	sprite.position = Vec2(width / 2, height / 2)
	sprite.size = Size(width, height)
end)
```

**Explanation:**

- `onAlignLayout`: Callback triggered when layout calculation is completed.
- `width` and `height`: The calculated width and height of the layout node.
- In the callback, we set the sprite's `position` to the center of the node and its `size` to match the node's size, ensuring the sprite displays in line with the layout result.

### 3.3 Complete Code

```lua
-- Adaptive Game UI

-- Import modules
local AlignNode <const> = require("AlignNode")
local Director <const> = require("Director")
local Sprite <const> = require("Sprite")
local Vec2 <const> = require("Vec2")
local Size <const> = require("Size")

-- Create root node for screen adaptation
local root = AlignNode(true)
root:css("justify-content: center; align-items: center")
root:addTo(Director.ui)

-- Create child node for centered layout
local centerNode = AlignNode()
centerNode:css("width: 60%; height: 60%")
centerNode:addTo(root)

-- Create sprite object for display on the child node
local sprite = Sprite("Image/logo.png")
sprite:addTo(centerNode)

-- Register adaptation callback to update the display object's parameters to match the layout result
centerNode:onAlignLayout(function(width, height)
	sprite.position = Vec2(width / 2, height / 2)
	sprite.size = Size(width, height)
end)
```

## 4. Conclusion

In this tutorial, you learned how to implement screen adaptation for game scenes and UI in Dora SSR:

- **Scene adaptation**: By setting design dimensions and adjusting the camera's zoom, you ensure the scene content is fully displayed.
- **UI adaptation**: Using the Yoga layout engine and CSS Flexbox layout syntax, you define element layout relationships and update their properties after layout adjustments.

These methods help you create games that adapt to different screen sizes, providing players with a consistent and enjoyable experience.

**Next steps**, you can try:

- Delving into more features of the **Yoga Layout Engine**, such as `flex-direction` and `flex-wrap`.
- Adding adaptive layouts to more UI elements, such as buttons and text boxes.
- Exploring other modules in Dora SSR to enhance your game development knowledge.

I hope this tutorial was helpful and wish you success on your game development journey!