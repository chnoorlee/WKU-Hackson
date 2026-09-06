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

```yue
_ENV = Dora
character = Model "assets/character"
```

### 1.2 Creating a DragonBone Animation Node

```yue
_ENV = Dora
dragon = DragonBone "assets/dragon"
```

### 1.3 Creating a Spine Animation Node

```yue
_ENV = Dora
monster = Spine "assets/monster"
```

## 2. Creating a Playable Instance

Playable is a node that provides a unified animation interface. To use the Playable node, you first need to create an instance. Playable supports loading three animation systems, and the typical loading methods are as follows:

- **Model files**: `"model:"` prefix + the model file path without the suffix.
- **Spine files**: `"spine:"` prefix + the Spine file path without the suffix.
- **DragonBones files**: `"bone:"` prefix + the DragonBones file path without the suffix.

### 2.1 Example: Loading a Model Animation

```yue
_ENV = Dora

-- Load Model animation
modelPath = "model:assets/character"
character = Playable modelPath

if character
	character.position = Vec2 100, 200
else
	print "Failed to load Model animation!"
```

### 2.2 Example: Loading a Spine Animation

```yue
_ENV = Dora

-- Load Spine animation
spinePath = "spine:assets/monster"
monster = Playable spinePath

if monster
	monster.position = Vec2 300, 200
else
	print "Failed to load Spine animation!"
```

### 2.3 Example: Loading DragonBones Animation

```yue
_ENV = Dora

-- Load DragonBones animation
dragonBonePath = "bone:assets/dragon"
dragon = Playable dragonBonePath

if dragon
	dragon.position = Vec2 500, 200
else
	print "Failed to load DragonBones animation!"
```

### 2.4 Example: Asynchronous Animation Loading

In real-world development, loading animations may take some time. You can use the `Cache:loadAsync()` method to load animations asynchronously, executing a callback function upon completion.

```yue
_ENV = Dora

-- Asynchronously load Model animation
modelPath = "model:assets/character"
thread ->
	if Cache\loadAsync modelPath
		with Playable modelPath
			.position = Vec2 100, 200
	else
		print "Failed to load Model animation asynchronously!"
```

## 3. Playing Animations

Once you have created an instance, you can play a specific animation using the `play` method.

```yue
-- Play the "run" animation in a loop
duration = character\play "run", true
```

- **Parameters**:
    - `name`: The name of the animation to play.
    - `loop` (optional): Whether to loop the animation, default is `false`.
- **Return Value**: The duration of the animation (in seconds).

## 4. Stopping Animations

Use the `stop` method to stop the currently playing animation.

```yue
-- Stop the animation
character\stop()
```

## 5. Setting Playback Speed

You can change the animation playback speed by adjusting the `speed` property.

```yue
-- Double the playback speed
character.speed = 2.0
```

- **Note**: The default value of `speed` is `1.0`.

## 6. Flipping Animations

You can flip the animation horizontally by using the `fliped` property, which is often used for character direction changes.

```yue
-- Flip horizontally
character.fliped = true
```

- **`fliped`**: `true` means flipped, `false` means normal.

## 7. Getting Keypoint Coordinates

The `getKey` method is used to get the coordinates of keypoints on the model, such as the character's hand or foot positions. In the Model animation system, keypoints are specific points set on the model. In DragonBone, keypoints are bone positions. In Spine2D, keypoints are vertex attachment positions.

```yue
-- Get the coordinates of the character's right hand
handPosition = character\getKey "right_hand"
print "Right hand coordinates:", handPosition.x, handPosition.y
```

- **Parameters**: The name of the keypoint (string).
- **Return Value**: `Vec2`, representing the coordinates of the keypoint.

## 8. Adding Child Nodes to Slots

The `setSlot` method allows you to add child nodes to specific slots on the model, such as adding a weapon or equipment to a character.

```yue
-- Create a sword sprite
sword = Sprite "assets/sword.png"

-- Add the sword to the character's "right_hand" slot
character\setSlot "right_hand", sword
```

- **Parameters**:
    - `name`: The name of the slot.
    - `item`: The node object to be added.

## 9. Getting Child Nodes from Slots

You can retrieve the child node from a specific slot using the `getSlot` method.

```yue
-- Get the node in the "right_hand" slot
equippedItem = character\getSlot "right_hand"
if equippedItem
	print "Equipped item:", equippedItem
else
	print "Slot is empty"
```

- **Return Value**: A `Node` object or `nil`.

## 10. Listening for Animation End Events

You can register a callback function using the `onAnimationEnd` method, which triggers when the animation playback ends.

```yue
-- Register an animation end callback
character\onAnimationEnd (animationName, target) ->
	print "Animation ended:", animationName
	-- Perform subsequent actions here, such as switching animations
```

- **Parameters**:
	- `callback`: A callback function that accepts two parameters: `animationName` and `target`.

## 11. Comprehensive Example

The following is a comprehensive example that demonstrates how to create a character, play animations, equip items, and handle animation end events.

```yue
_ENV = Dora

-- Create a character
with Playable "model:assets/hero.model"
	.position = Vec2 200, 300

	-- Set properties
	.speed = 1.0
	.fliped = false

	-- Play idle animation
	\play "idle", true

	-- Create a sword and equip it
	sword = Sprite "assets/sword.png"
	\setSlot "right_hand", sword

	-- Register an animation end event
	\onAnimationEnd (animationName, target) ->
		if animationName == "attack"
			-- Return to idle state after attack ends
			target\play "idle", true

	-- Perform an attack every 3 seconds
	\loop ->
		-- Play attack animation, no looping
		\play "attack"
		sleep 3
```

## 12. Conclusion

Through this tutorial, you have learned how to use the Playable node class in Dora SSR to load and control various animation models. Playable offers a rich set of interfaces, supporting multiple animation systems, making it easy to add complex animation effects to your game.

:::warning Spine2D is commercial software
Since Spine2D is commercial software, using its animations requires adhering to the corresponding license agreement. Please refer to the [official Spine website](https://esotericsoftware.com/) for more details.
:::

We hope this tutorial helps you in your game development journey, and we wish you success!