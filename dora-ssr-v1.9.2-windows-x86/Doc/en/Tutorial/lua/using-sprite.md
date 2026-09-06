# Using Sprite Node

In this tutorial, we will learn how to use the Sprite node class in the Dora SSR game engine to create and render graphical elements in the game. The Sprite node is a basic building block in the game scene, used to render textures (such as images or patterns) onto the screen.

## 1. What is a Sprite?

Sprite is a class that inherits from `Node` and represents graphical elements in the game scene. It can load an image file as a texture and display it in the game scene. Through the Sprite class, you can control how textures are drawn, their position, wrap mode, blend mode, and more.

### 1.1 Key properties and functionalities of Sprite:

- **texture**: The texture object being rendered (such as an image file).
- **textureRect**: Defines the rectangular area of the texture to be rendered, defaulting to rendering the entire texture.
- **blendFunc**: Controls the blend mode of the texture, used for controlling the transparency effect when rendering the texture.
- **effect**: Sets the shader effect used when rendering.
- **uwrap/vwrap**: Controls the U and V axis wrap modes for the texture.
- **filter**: Controls the texture filtering mode, used to manage how the texture is sampled when scaled up or down.

## 2. Preparations

Before we begin, make sure you have correctly imported the Sprite class into your project. Here is a code example:

```lua
local Sprite <const> = require("Sprite")
```

## 3. Creating a Basic Sprite

First, let's create a simple Sprite to render an image. Suppose we have an image file `"Image/hero.png"`, and we want to load it like this:

```lua
-- Create a new Sprite object and load "Image/hero.png" as the texture
local heroSprite = Sprite("Image/hero.png")

-- Add the Sprite to the scene
scene:addChild(heroSprite)
```

In this example, `heroSprite` is created using `Sprite("Image/hero.png")`, and the `"Image/hero.png"` image file is loaded as a texture. Then, we add this Sprite to the scene for rendering.

In actual development, loading images may take some time. You can use the `Cache:loadAsync()` method to load images asynchronously to avoid blocking the main thread.

```lua
local Sprite <const> = require("Sprite")
local thread <const> = require("thread")

-- Asynchronously load the image
local imagePath = "Image/hero.png"
thread(function()
	if Cache:loadAsync(imagePath) then
		local character = Sprite(imagePath)
		character.position = Vec2(100, 200)
		stage:addChild(character)
	else
		print("Failed to load image asynchronously!")
	end
end)
```

If your game uses many small images, you can pack them into a `.clip` atlas first and then load the atlas with `Sprite`. See [Packing Sprite Images with TexturePacker](./12.using-texture-packer.mdx) for the full workflow from a `.clips` folder to generated `.png` and `.clip` files.

## 4. Setting the Texture Rect of a Sprite

Sometimes we only want to render part of a texture. In such cases, we can use the `textureRect` property to specify the rendering area of the texture. For example, if we want to render only the top-left corner of the image, we can do it like this:

```lua
-- Define a rectangular area of the texture, representing the top-left region (assuming the image size is 256x256)
local textureRect = Rect(0, 0, 128, 128)

-- Load the texture and set the rendering area
local heroSprite = Sprite("Image/hero.png")
heroSprite.textureRect = textureRect
```

In this example, we define a `Rect` object representing the top-left 128x128 region of the texture and apply it to the `textureRect` property of `heroSprite`.

## 5. Adjusting Texture Wrap and Filter Modes

The Sprite class provides control over texture wrap modes (`uwrap` and `vwrap`) and filter modes (`filter`). By adjusting these modes, you can control how textures repeat or how they are handled when scaled on the Sprite.

### 5.1 Wrap Modes:

- `None`: No wrap, texture does not repeat.
- `Mirror`: Mirror repeat.
- `Clamp`: Clamp to the edge.

### 5.2 Filter Modes:

- `Point`: Uses the nearest pixel for sampling, suitable for pixel-art games.
- `Anisotropic`: Anisotropic filtering for better detail handling.

Here is the sample code:

```lua
-- Create a Sprite and set texture wrap modes
local heroSprite = Sprite("Image/hero.png")
heroSprite.uwrap = "Mirror"
heroSprite.vwrap = "Clamp"

-- Set the texture filter mode to point sampling (ideal for pixel-art style)
heroSprite.filter = "Point"
```

## 6. Applying Custom Shader Effects

The Sprite class allows you to apply shader effects to the rendered graphics. You can set an effect using the `effect` property. For example:

```lua
local SpriteEffect <const> = require("SpriteEffect")
-- Load a built-in sprite shader and apply it
local spriteEffect = SpriteEffect("builtin:vs_sprite", "builtin:fs_sprite")
heroSprite.effect = spriteEffect
```

Here, we load a built-in vertex and fragment shader for the Sprite and apply it to `heroSprite`, enhancing the rendering effect.

## 7. Conclusion

In this tutorial, we introduced how to use the Sprite node class in the Dora SSR engine to render textures and demonstrated how to create Sprites, control texture areas, set wrap and filter modes, and apply custom shader effects. These basic functionalities will help you build complex graphical elements in your game.

We hope this tutorial helps you get started quickly with the Sprite class!