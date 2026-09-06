# Using Playable Node

In game development, animations are crucial for bringing characters and scenes to life. Dora SSR engine provides a powerful animation handling node class—**Playable**. It serves as the base class for three animation systems:

- **Model**:
	- A skeletal animation system implemented by the Dora SSR engine.
	- Animation models are usually composed of a `.model` file, a `.clip` file, and a `.png` file.
- **DragonBone**:
	- The open-source DragonBones animation system.
	- Animation models typically consist of a file ending with `_ske.json`, a file ending with `_tex.json`, and an image file ending with `_tex.png`.
- **Spine**:
	- The animation system of the well-known commercial software Spine2D.
	- Animation models are generally composed of a `.json` (or `.skel`) file, an `.atlas` file, and a `.png` file.

This tutorial will guide you on how to use various nodes in your program, covering everything from loading animations to controlling playback.

## 1. Creating an Animation Node Instance

### 1.1 Creating a Model Animation Node

```tl
local Model <const> = require("Model")
local character = Model("assets/character")
```

### 1.2 Creating a DragonBone Animation Node

```tl
local DragonBone <const> = require("DragonBone")
local dragon = DragonBone("assets/dragon")
```

### 1.3 Creating a Spine Animation Node

```tl
local Spine <const> = require("Spine")
local monster = Spine("assets/monster")
```

## 2. Creating a Playable Instance

Playable is a node that provides a unified animation interface. To use the Playable node, you first need to create an instance. Playable supports loading three animation systems, and the typical loading methods are as follows:

- **Model files**: `"model:"` prefix + the model file path without the suffix.
- **Spine files**: `"spine:"` prefix + the Spine file path without the suffix.
- **DragonBones files**: `"bone:"` prefix + the DragonBones file path without the suffix.

### 2.1 Example: Loading a Model Animation

```tl
local Playable <const> = require("Playable")

-- Load Model animation
local modelPath = "model:assets/character"
local character = Playable(modelPath)

if not character is nil then
	character.position = Vec2(100, 200)
else
	print("Failed to load Model animation!")
end
```

### 2.2 Example: Loading a Spine Animation

```tl
local Playable <const> = require("Playable")

-- Load Spine animation
local spinePath = "spine:assets/monster"
local monster = Playable(spinePath)

if not monster is nil then
	monster.position = Vec2(300, 200)
else
	print("Failed to load Spine animation!")
end
```

### 2.3 Example: Loading DragonBones Animation

```tl
local Playable <const> = require("Playable")

-- Load DragonBones animation
local dragonBonePath = "bone:assets/dragon"
local dragon = Playable(dragonBonePath)

if not dragon is nil then
	dragon.position = Vec2(500, 200)
else
	print("Failed to load DragonBones animation!")
end
```

### 2.4 Example: Asynchronous Animation Loading

In real-world development, loading animations may take some time. You can use the `Cache:loadAsync()` method to load animations asynchronously, executing a callback function upon completion.

```tl
local Playable <const> = require("Playable")
local thread <const> = require("thread")

-- Asynchronously load Model animation
local modelPath = "model:assets/character"
thread(function()
	if Cache:loadAsync(modelPath) then
		local character = Playable(modelPath)
		if not character is nil then
			character.position = Vec2(100, 200)
		end
	else
		print("Failed to load Model animation asynchronously!")
	end
end)
```

## 3. Playing Animations

Once you have created an instance, you can play a specific animation using the `play` method.

```tl
-- Play the "run" animation in a loop
local duration = character:play("run", true)
```

- **Parameters**:
    - `name`: The name of the animation to play.
    - `loop` (optional): Whether to loop the animation, default is `false`.
- **Return Value**: The duration of the animation (in seconds).

## 4. Stopping Animations

Use the `stop` method to stop the currently playing animation.

```tl
-- Stop the animation
character:stop()
```

## 5. Setting Playback Speed

You can change the animation playback speed by adjusting the `speed` property.

```tl
-- Double the playback speed
character.speed = 2.0
```

- **Note**: The default value of `speed` is `1.0`.

## 6. Flipping Animations

You can flip the animation horizontally by using the `fliped` property, which is often used for character direction changes.

```tl
-- Flip horizontally
character.fliped = true
```

- **`fliped`**: `true` means flipped, `false` means normal.

## 7. Getting Keypoint Coordinates

The `getKey` method is used to get the coordinates of keypoints on the model, such as the character's hand or foot positions. In the Model animation system, keypoints are specific points set on the model. In DragonBone, keypoints are bone positions. In Spine2D, keypoints are vertex attachment positions.

```tl
-- Get the coordinates of the character's right hand
local handPosition = character:getKey("right_hand")
print("Right hand coordinates:", handPosition.x, handPosition.y)
```

- **Parameters**: The name of the keypoint (string).
- **Return Value**: `Vec2`, representing the coordinates of the keypoint.

## 8. Adding Child Nodes to Slots

The `setSlot` method allows you to add child nodes to specific slots on the model, such as adding a weapon or equipment to a character.

```tl
-- Create a sword sprite
local sword = Sprite("assets/sword.png")

-- Add the sword to the character's "right_hand" slot
character:setSlot("right_hand", sword)
```

- **Parameters**:
    - `name`: The name of the slot.
    - `item`: The node object to be added.

## 9. Getting Child Nodes from Slots

You can retrieve the child node from a specific slot using the `getSlot` method.

```tl
-- Get the node in the "right_hand" slot
local equippedItem = character:getSlot("right_hand")
if not equippedItem is nil then
	print("Equipped item:", equippedItem)
else
	print("Slot is empty")
end
```

- **Return Value**: A `Node` object or `nil`.

## 10. Listening for Animation End Events

You can register a callback function using the `onAnimationEnd` method, which triggers when the animation playback ends.

```tl
-- Register an animation end callback
character:onAnimationEnd(function(animationName: string, target: Playable.Type)
	print("Animation ended:", animationName)
	-- Perform subsequent actions here, such as switching animations
end)
```

- **Parameters**:
	- `callback`: A callback function that accepts two parameters: `animationName` and `target`.

## 11. Comprehensive Example

The following is a comprehensive example that demonstrates how to create a character, play animations, equip items, and handle animation end events.

```tl
local Playable <const> = require("Playable")
local Sprite <const> = require("Sprite")
local Vec2 <const> = require("Vec2")
local sleep <const> = require("sleep")

-- Create a character
local character = Playable("model:assets/hero.model")
if not character is nil then
	character.position = Vec2(200, 300)

	-- Set properties
	character.speed = 1.0
	character.fliped = false

	-- Play idle animation
	character:play("idle", true)

	-- Create a sword and equip it
	local sword = Sprite("assets/sword.png")
	character:setSlot("right_hand", sword)

	-- Register an animation end event
	character:onAnimationEnd(function(animationName: string, target: Playable.Type)
		if animationName == "attack" then
			-- Return to idle state after attack ends
			target:play("idle", true)
		end
	end)

	-- Perform an attack every 3 seconds
	character:loop(function(): boolean
		-- Play attack animation
		character:play("attack")
		sleep(3)
		return false
	end)
end
```

## 12. Conclusion

Through this tutorial, you have learned how to use the Playable node class in Dora SSR to load and control various animation models. Playable offers a rich set of interfaces, supporting multiple animation systems, making it easy to add complex animation effects to your game.

:::warning Spine2D is commercial software
Since Spine2D is commercial software, using its animations requires adhering to the corresponding license agreement. Please refer to the [official Spine website](https://esotericsoftware.com/) for more details.
:::

We hope this tutorial helps you in your game development journey, and we wish you success!