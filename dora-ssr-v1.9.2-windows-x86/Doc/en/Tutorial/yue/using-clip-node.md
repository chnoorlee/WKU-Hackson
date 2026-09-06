# Using ClipNode for Masking Effects

In game development and graphics rendering, masking is a common technique used to control the visible area of an image or scene. In Dora SSR, we can easily implement various masking effects using the `ClipNode` class. This tutorial will guide you through using `ClipNode` to achieve shape-based and image-based masking effects with sample code.

## 1. What is ClipNode?

`ClipNode` is a scene node class in Dora SSR that allows you to set up a clipping mask to control the visible area of its child nodes. By specifying a mask node (`stencil`), `ClipNode` clips the rendering content of its child nodes based on the mask's shape or transparency.

### 1.1 Main Properties of ClipNode

- **stencil**: Defines the mask node that determines the clipping shape.
- **alphaThreshold**: The alpha threshold (ranging from 0 to 1) that determines which mask pixels participate in clipping. Clipping only applies when the mask pixel's alpha value exceeds this threshold.
- **inverted**: Inverts the clipping area. When set to `true`, the clipped and unclipped areas are swapped.

## 2. Example A: Using Any Shape as a Mask

In this first example, we will use a star-shaped mask to clip the visible area of an animated model.

### 2.1 Step-by-step Explanation

1. **Create the Vertex Data for a Star Shape**

```yue
StarVertices = (radius, line) ->
	-- Calculate the vertex coordinates of a star
	a = math.rad 36
	c = math.rad 72
	f = math.sin(a) * math.tan(c) + math.cos a
	R = radius
	r = R / f
	vecs = []
	for i = 9, line and -1 or 0, -1
		angle = i * a
		cr = i % 2 == 1 and r or R
		vecs[] = Vec2 cr * math.sin(angle), cr * math.cos angle
	-- Return the vertex array
	vecs
```

2. **Draw the Mask Shape**

```yue
maskA = DrawNode()
maskA.drawPolygon StarVertices(160, false)
```

Here, we use `DrawNode` to draw a star shape as the mask node.

3. **Create an Animated Model**

```yue
targetA = with Model "Model/xiaoli.model"
	.look = "happy"
	.fliped = true
	-- Set model's animation and movement path
	.play "walk", true
	\runAction Sequence(
		X 1.5, -200, 200, Event "Turn",
		X 1.5, 200, -200, Event "Turn"
	), true
	\slot "Turn", ->
		targetA.fliped = not targetA.fliped
```

4. **Create a ClipNode and Add Child Nodes**

```yue
clipNodeA = with ClipNode maskA
	\addChild targetA
	.inverted = true
```

We pass the mask node `maskA` to `ClipNode`, and add the animated model `targetA` as its child node.

5. **Add to the Scene**

```yue
exampleA = with Node!
	\addChild clipNodeA
```

### Result

After running the above code, you will see the model visible only within the star shape, with the parts outside the star clipped away.

## 3. Example B: Using an Image with alphaThreshold for Masking

In the second example, we will use a model with transparency as the mask and utilize the `alphaThreshold` property to control the clipping effect.

### 3.1 Step-by-step Explanation

1. **Create the Mask Model**

```yue
maskB = with Model "Model/xiaoli.model"
	.look = "happy"
	.fliped = true
	.play "walk", true
```

Here, we use a model as the mask node.

2. **Create the Target Shape**

```yue
targetB = with DrawNode!
	\drawPolygon StarVertices 160, false
	-- Set the movement path for the target shape
	\runAction Sequence(
		X 1.5, -200, 200,
		X 1.5, 200, -200
	), true
```

3. **Create a ClipNode and Set alphaThreshold**

```yue
clipNodeB = with ClipNode maskB
	\addChild targetB
	.inverted = true
	.alphaThreshold = 0.3
```

By setting `alphaThreshold = 0.3`, clipping will only apply when the mask model's pixel alpha value is greater than 0.3.

4. **Add to the Scene**

```yue
exampleB = with Node!
	\addChild clipNodeB
```

### 3.2 Result

After running the code, you will notice that the target shape is visible only in the non-transparent parts of the mask model, creating a transparency-based masking effect.

## 4. Conclusion

Through these two examples, we've learned how to use `ClipNode` in Dora SSR to implement different masking effects:

- **Example A** showed how to use any drawn shape as a mask to clip the display area of child nodes.
- **Example B** demonstrated how to use the `alphaThreshold` property to clip using an image or model with transparency.

### 4.1 Tips

- **Using alphaThreshold**: When the mask node contains semi-transparent areas, `alphaThreshold` is useful. It allows you to finely control which pixels participate in clipping.
- **Inverted Property**: By toggling `inverted`, you can easily reverse the clipping area to achieve different visual effects.

We hope this tutorial helps you better understand and apply `ClipNode` in Dora SSR to create diverse masking effects. For any questions, feel free to consult the official documentation or join community discussions.