# How to Use the ECS Framework

## 1. Framework Introduction

The ECS framework in Dora SSR is inspired by [Entitas](https://github.com/sschmid/Entitas), with slight functional adjustments. Its basic concepts can be understood using Entitas's schematic diagram.

```text
Entitas ECS

+-----------------+
|     Context     |
|-----------------|
|    e       e    |      +-----------+
|       e      e--|----> |  Entity   |
|  e        e     |      |-----------|
|     e  e     e  |      | Component |
| e          e    |      |           |      +-----------+
|    e     e      |      | Component-|----> | Component |
|  e    e    e    |      |           |      |-----------|
|    e    e     e |      | Component |      |   Data    |
+-----------------+      +-----------+      +-----------+
  |
  |
  |     +-------------+  Groups:
  |     |      e      |  Entity groups are subsets of all game entities,
  |     |   e     e   |  categorized by their components, for fast traversal
  +---> |        +------------+ and querying of entities with specific components.
        |     e  |    |       |
        |  e     | e  |  e    |
        +--------|----+    e  |
                 |     e      |
                 |  e     e   |
                 +------------+
```

Unlike Entitas, in Dora SSR's ECS framework, a system component is managed as a single field on the entity object. This introduces some performance overhead but significantly simplifies writing logical code.

## 2. Code Example

In this tutorial, we will demonstrate how to write game logic using Dora SSR’s ECS (Entity Component System) framework through a code example.

Before writing the actual code, let’s first import the functional modules required for this YueScript tutorial.

```yue
_ENV = Dora
```

First, we create two entity groups `sceneGroup` and `positionGroup`, used to access and manage all entities with the component names "scene" and "position."

```yue
sceneGroup = Group ["scene",]
positionGroup = Group ["position",]
```

Next, we use an observer to listen for changes to entities. When developing a game using the ECS framework, you may need to trigger some actions when an entity adds a specific component. In such cases, you can use an observer to listen for entity addition events and perform the corresponding logic when they occur. Here's an example code snippet on how to use an observer to listen for entity addition events:

```yue
with Observer "Add", ["scene",]
	\watch (_entity, scene): false ->
		Director.entry\addChild with scene
			\onTapEnded (touch) ->
				:location = touch
				positionGroup\each (entity) ->
					entity.target = location
```

First, create an observer object using the `Observer` class and specify that it monitors the "Add" event, which listens for the addition of an entity. We also pass a list containing the string "scene" as a parameter, indicating that the observer should monitor entities containing the "scene" component.

```yue
with Observer "Add", ["scene",]
```

Next, in the observer object's `watch` method, we define a callback function `(_entity, scene)->`. This function is triggered when an entity addition event occurs. The first parameter is the entity that triggered the event, and subsequent parameters correspond to the monitored component list.

```yue
\watch (_entity, scene) ->
```

Inside the callback function, we perform a series of actions. First, we add `scene` to the game scene through `Director.entry`.

```yue
Director.entry\addChild with scene
```

Next, we add an "onTapEnded" event handler to the `scene`, which gets called when a touch end event occurs.

```yue
\onTapEnded (touch) ->
```

Inside the event handler, we assign the touch point's location to the `location` variable.

```yue
:location = touch
```

Finally, we iterate over all entities in `positionGroup` and set each entity's `target` property to the touch point's location.

```yue
positionGroup\each (entity) ->
	entity.target = location
```

Thus, whenever a new entity adds the "scene" component, this observer is triggered, executing the above actions, adding the scene node to the game, and completing a series of initialization steps.

Next, we will create additional observers to handle other "Add" and "Remove" types of entity changes, specifying the monitored components as `image` and `sprite`.

```yue
with Observer "Add", ["image",]
	\watch (image): false => sceneGroup\each (e) ->
		with @sprite = Sprite image
			\addTo e.scene
			\runAction Scale 0.5, 0, 0.5, Ease.OutBack
		true

with Observer "Remove", ["sprite",]
	\watch (): false => @oldValues.sprite\removeFromParent!
```

Then, we create an entity group with "position", "direction", "speed", and "target" components and define an observer to handle component changes within the group. On each game update frame, it iterates over a specific set of entities, updating the rotation angle and position properties based on their speed and time elapsed.

```yue
with Group ["position", "direction", "speed", "target"]
	\watch (entity, position, direction, speed, target): false ->
		return if target == position
		dir = target - position
		dir = dir\normalize!
		newPos = position + dir * speed
		newPos = newPos\clamp position, target
		entity.position = newPos
		entity.target = nil if newPos == target
		angle = math.deg math.atan dir.x, dir.y
		entity.direction = angle
```

In this code, first, we use the `Group` class to create an entity group object, specifying that the group contains entities with "position", "direction", "speed", and "target" components.

```yue
with Group ["position", "direction", "speed", "target"]
```

Then, we use the entity group's `watch` method to iterate through all entities in the group each frame, executing the callback function to handle component logic.

```yue
\watch (entity, position, direction, speed, target): false ->
```

Inside the callback function, we perform a conditional check using `return if target == position` to see if the entity's target position matches its current position. If they are the same, the function returns, and no further updates are performed.

```yue
return if target == position
```

Next, we calculate the entity's direction vector `dir`, which is equal to the target position minus the current position, and normalize it.

```yue
dir = target - position
dir = dir\normalize!
```

Then, based on the entity's speed and direction vector, we calculate the entity’s new position `newPos` for the current frame. We multiply the direction vector `dir` by the speed `speed`, then add it to the current position `position`.

```yue
newPos = position + dir * speed
```

Next, we adjust the position using `newPos` and the target position `target`. By clamping `newPos` between the current and target positions, we ensure the new position remains within this range. The final corrected position is assigned back to the entity's `position` component.

```yue
newPos = newPos\clamp position, target
entity.position = newPos
```

Next, if the new position equals the target position, we clear the entity's target.

```yue
entity.target = nil if newPos == target
```

Finally, we calculate the entity's rotation angle `angle` using the `math.atan` function to find the angle of the direction vector `dir` in radians and convert it to degrees. The entity's rotation angle component `direction` is then updated with the calculated value.

```yue
angle = math.deg math.atan dir.x, dir.y
entity.direction = angle
```

Thus, on each game update, this code is triggered for each entity in the group, updating their current "position", "direction", "speed", or "target" components.

After the data calculation and updates are completed, we need to update the rendered graphics based on these results.

```yue
with Observer "AddOrChange", ["position", "direction", "sprite"]
	\watch (position, direction, sprite): false =>
		-- Update the display position of the sprite
		sprite.position = position
		lastDirection = @oldValues.direction or sprite.angle
		-- If the sprite’s rotation angle changes, play a rotation animation
		if math.abs(direction - lastDirection) > 1
			sprite\runAction Roll 0.3, lastDirection, direction
```

Finally, we create three entities and assign different components to them. The game system will now officially start running.

```yue
Entity
	scene: Node!

Entity
	image: "Image/logo.png"
	position: Vec2.zero
	direction: 45.0
	speed: 4.0

Entity
	image: "Image/logo.png"
	position: Vec2 -100, 200
	direction: 90.0
	speed: 10.0
```

This code example demonstrates the basic workflow for developing a game using the ECS framework. Depending on your game’s needs, you can use the framework’s provided entity, group, and observer interfaces to build game logic. In the code, you can trigger appropriate actions in response to entity component changes, add, remove, or modify entities, and manage them in groups using entity groups. By using observers, you can monitor entity change events, such as adding, modifying, or deleting specific components. In the observer’s handler function, you can perform corresponding logic operations based on entity changes, such as updating scene nodes, handling user input, or printing debug information.

By properly organizing the relationship between entities and components, and leveraging the monitoring and processing capabilities of observers, you can build complex game logic and behaviors. In practice, you can design and define your own component types based on the game’s requirements and implement various functions and behaviors using the ECS framework’s interfaces.

## 3. Summary

In summary, the basic workflow for developing a game using the ECS framework includes:

1. Defining the entity’s component types and creating entity objects as needed.
2. Creating entity groups and adding entities to their corresponding groups for group management.
3. Using observers to monitor entity change events, such as adding, modifying, or deleting specific components.
4. Performing corresponding logic operations based on entity changes in the entity group observer’s handler function, updated on each frame.
5. Designing and implementing other components, systems, and functions based on game requirements.

By following this workflow, using Dora SSR's ECS framework allows you to better organize and manage your game logic, improving the maintainability and scalability of your code, and enabling the implementation of complex game functions and behaviors.