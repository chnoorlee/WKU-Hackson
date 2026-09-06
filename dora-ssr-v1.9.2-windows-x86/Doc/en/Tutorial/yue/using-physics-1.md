# Using Physics Nodes I

In this tutorial, we will learn how to create physics rigid body node objects in the Dora SSR game engine and set up groups and collision relationships between different physics objects. By following the steps below, you'll be able to implement basic gravity movements, shape setups, and collision detection in the physics world.

## 1. Creating the Physics World with Gravity

First, we need to define a physics world and set its gravity direction and magnitude. In this example, gravity is defined as vertical downward, with a magnitude of `-10`.

```yue
_ENV = Dora

const gravity = Vec2 0, -10 -- Define gravity direction and magnitude
world = PhysicsWorld! -- Create the physics world
world.y = -200 -- Adjust the y-axis position of the world
```

## 2. Defining Physics Rigid Bodies

Physics rigid bodies can be static, dynamic, or kinematic. Static bodies are used for immovable objects (e.g., ground), dynamic bodies for movable objects (e.g., characters or obstacles), and kinematic bodies for objects with infinite mass that can be controlled to move.

### 2.1 Defining Static Terrain Bodies

Static bodies are commonly used for ground or walls and are typically unaffected by gravity. In the example below, we create a static terrain body with an 800x10 polygon shape.

```yue
terrainDef = with BodyDef!
	.type = "Static" -- Set as a static body
	\attachPolygon 800, 10, 1, 0.8, 0.2 -- Attach a polygon with width 800 and height 10
	-- Note: The parameters 1, 0.8, 0.2 are density, friction coefficient, and elasticity coefficient, respectively
```

### 2.2 Defining Dynamic Polygon Bodies

Dynamic bodies are affected by gravity and move according to the forces in the physics world. We can define a polygon body, and in the example below, we define a hexagon.

```yue
polygonDef = with BodyDef!
	.type = "Dynamic" -- Set as a dynamic body
	.linearAcceleration = gravity -- Apply gravity
	\attachPolygon [
		Vec2 60, 0,
		Vec2 30, -30,
		Vec2 -30, -30,
		Vec2 -60, 0,
		Vec2 -30, 30,
		Vec2 30, 30
	], 1, 0.4, 0.4 -- Define a hexagon
```

### 2.3 Defining Dynamic Circular Bodies

Circular bodies are similar to polygons, but with a circular shape, and are also affected by gravity.

```yue
diskDef = with BodyDef!
	.type = "Dynamic" -- Set as a dynamic body
	.linearAcceleration = gravity -- Apply gravity
	\attachDisk 60, 1, 0.4, 0.4 -- Attach a disk with a radius of 60
```

## 3. Setting Groups and Collision Relationships

We can define collision rules between objects by setting groups. In this example, we create three groups and use the `setShouldContact` method to establish collision rules between the groups.

```yue
groupZero = 0
groupOne = 1
groupTwo = 2

with world
	\setShouldContact groupZero, groupOne, false -- No collision between group 0 and group 1
	\setShouldContact groupZero, groupTwo, true -- Collision between group 0 and group 2
	\setShouldContact groupOne, groupTwo, true -- Collision between group 1 and group 2
	.showDebug = true -- Show debug information
```

:::tip Best Practices for Physics Grouping
In actual game development, setting physics groups properly can greatly enhance performance and reduce unnecessary calculations. It's recommended to assign different groups to static elements, dynamic objects, and player characters, adjusting collision relationships as needed.
:::

## 4. Creating and Adding Bodies to the Physics World

Finally, we instantiate the defined physics body objects and add them to the physics world. Each body can be assigned to a different group and have its initial position set within the world.

```yue
-- Create and add static terrain body
with Body terrainDef, world, Vec2.zero
	.group = groupTwo -- Set group 2 for this body
	\addTo world

-- Create and add dynamic polygon body
with Body polygonDef, world, Vec2 0, 500, 15
	.group = groupOne -- Set group 1 for this body
	\addTo world

-- Create and add dynamic circular body
with Body diskDef, world, Vec2 50, 800
	.group = groupZero -- Set group 0 for this body
	.angularRate = 90 -- Set rotation speed
	\addTo world
```

## 5. Conclusion

In this tutorial, you've learned how to create physics rigid bodies in the Dora SSR game engine and control collisions between objects through grouping. By flexibly setting body properties, shapes, and groups, you can achieve complex physical effects and add more fun to your game.

We hope this tutorial helps you better understand the physics system of Dora SSR. Happy developing!