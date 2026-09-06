# Using Post-Processing for Nodes

In game development, post-processing effects can add unique visual touches to a scene, such as blur, outlining, color adjustments, and more. Dora SSR provides a convenient way to apply post-processing to scene nodes. This guide will explain how to use the post-processing feature in Dora SSR and provide an example.

## 1. What is Post-Processing with Scene Nodes?

Post-processing with scene nodes refers to rendering a specific scene node onto a texture, and then applying shader effects to that texture. This allows you to apply special visual effects to certain parts of the scene without affecting other nodes.

## 2. Steps to Implement

To apply post-processing to a scene node, follow these steps:

1. **Set the node size**: Define the `size` property of the node you want to apply post-processing to. This property will be used as the screen size for post-processing.
2. **Get a Grabber**: Use the `node:grab()` method to obtain a grabber for the node.
3. **Apply shader effects**: Set the grabber’s `effect` property to apply the desired shader effect to the grabbed screen.

## 3. Code Example

Here is a complete code example that demonstrates how to apply post-processing to a scene node in Dora SSR.

```yue
-- Import necessary modules
_ENV = Dora

-- Load Spine animation resources
spineStr = "Spine/moling"
animations = Spine\getAnimations spineStr
looks = Spine\getLooks spineStr

-- Create a playable Spine object
playable = with Spine spineStr
	.x = 200
	.y = 190
	.look = looks[1]
	\play animations[1], true

-- Create a shader effect (using the built-in outline effect)
effect = SpriteEffect "builtin::vs_sprite", "builtin::fs_spriteoutlinecolor"
pass = effect\get 1
pass\set "u_linecolor", Color 0xff00ffff -- Set outline color
pass\set "u_lineoffset", 5, 5, 0.1 -- Set outline parameters: line width, line alpha sample level, edge alpha threshold

-- Create a node and set its size
node = with Node!
	-- Set the post-processing size
	.size = Size 400, 600

-- Get the grabber and apply the effect
grabber = node\grab!
	.effect = effect

-- Add the playable object to the node
node\addChild playable
```

### 3.1 Code Explanation

1. **Import modules**: First, we need to import the necessary modules.
2. **Load Spine animations**: Use the `Spine` module to load animation resources and retrieve animation and look lists.
3. **Create a playable object**: Instantiate a Spine object, set its position, look, and start the animation.
4. **Define post-processing size**: Specify the width and height for the post-processing screen.
5. **Create a shader effect**: We create an outline shader effect and set the outline color and parameters.
6. **Create a node and set the size**: Instantiate a `Node` object and set its `size` property to the previously defined dimensions. This step is crucial, as the node must have a size to apply post-processing.
7. **Get the grabber and apply effects**: Use the `node:grab()` method to get the grabber, and then assign the previously created shader effect to `grabber.effect`.
8. **Add child node**: Finally, add the playable Spine object to the node. It will be rendered onto a texture, with the outline effect applied.

## 4. Output and Conclusion

After running the code, you will see:

- A node with a width of 400 pixels and a height of 600 pixels, containing our Spine animation.
- The node’s content will be rendered onto a texture, and the outline shader effect we set will be applied.
- The final result is that the animated character will have the outline effect in the color we specified.

With this example, you now understand how to apply post-processing to scene nodes in Dora SSR. This method allows you to achieve various unique visual effects, adding more fun to your game.

## 5. Further Reading

- **Custom Shaders**: You can write your own shaders to achieve unique effects by specifying your shader files when creating a `SpriteEffect`.
- **Dynamic Parameter Adjustments**: By modifying shader parameters, you can dynamically adjust effects at runtime, such as changing the outline color, thickness, and more.

I hope this tutorial helps you understand post-processing with scene nodes in Dora SSR. Happy developing!