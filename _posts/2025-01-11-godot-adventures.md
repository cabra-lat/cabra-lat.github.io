---
layout: post
category: coding 
---

I've been working with Godot since last year (2024). I had used it in the past and found it really enjoyable, with excellent documentation and plenty of resources. The latest major version, Godot 4.X, introduced many new features. Before its release, I was particularly excited about the improvements to the State Machine.

So far, I've managed to set up retro PSX-style visuals, physics-based interactions with objects, and some basic text descriptions. It's pretty simple stuff, but I'm happy with the results.

![godot-adventures][godot-adventures]

Recently, I was developing a system to play sounds based on the material metadata of each object’s [`CollisionShape3D`][docs-collider-shape-3d]. This allows me to assign different collision sounds for each material—and even let the same object emit different sounds depending on which part of it is hit.

Initially, I used a [`Dictionary`][docs-dictionary] to map materials to an [`Array`][docs-array] of sounds and then played the appropriate sound. While it worked, the system was difficult to maintain and adding new sounds was cumbersome. To address this, I switched to using a [`Resource`][docs-resource], which essentially wraps the [`Dictionary`][docs-dictionary] and allows for easier editing within the Godot editor. However, this approach introduced its own challenge: scrolling through an overwhelming number of resources to find the one I wanted to add.

![crazy-amount-of-resources][crazy-amount-of-resources]

While dictionaries are a great data structure, resources are much more powerful because they can be referenced by unique IDs and edited directly in the editor. Still, I wanted to find a way to make adding and editing sounds for each material more streamlined.

That’s when I thought about creating an interface similar to the [`SpriteFrames`][docs-sprite-frames] panel, which appears when you use the [`AnimatedSprite2D`][docs-animated-sprites-2d] node. With SpriteFrames, you can add animation names and frames for each animation and then play them with a simple call like `animation.play("animation-name")`.

I needed something similar but designed for sounds. After coding for several hours, digging into Godot's open-source code, and leveraging AI chat tools, I finally created the perfect plugin for my needs:

![the-perfect-plugin][the-perfect-plugin]

While it’s not entirely perfect yet—you might notice a few odd buttons and minor bugs—the sound system works, and I can now easily manage collections of sounds for each material.

[godot-adventures]: {{ page.assets }}/imgs/godot-adventures.png
[crazy-amount-of-resources]: {{ page.assets }}/imgs/crazy-amount-of-resources.png
[the-perfect-plugin]: {{ page.assets }}/imgs/the-perfect-plugin.png
[docs-resource]: https://docs.godotengine.org/en/stable/classes/class_resource.html
[docs-collider-shape-3d]: https://docs.godotengine.org/en/stable/classes/class_collisionshape3d.html
[docs-sprite-frames]: https://docs.godotengine.org/en/stable/classes/class_spriteframes.html
[docs-animated-sprites-2d]: https://docs.godotengine.org/en/stable/classes/class_animatedsprite2d.html
[docs-dictionary]: https://docs.godotengine.org/en/stable/classes/class_dictionary.html
[docs-array]: https://docs.godotengine.org/en/stable/classes/class_array.html
