---
layout: post
category: coding 
---

I've been working with Godot since last year (2024). I've used in the past and I find it really nice, with awesome documentation and lot's of resources. The latest major version, Godot 4.X, received a lot of new features and before it came out I was particularly interested in the State Machine improvements.

So far I acomplished setting up some retro psx visuals, physics-based interactions with objects and some basic text descriptions. Very simple stuff but I'm happy with the results.

![godot-adventures][godot-adventures]

I was developing a system that plays a sound based on a material metadata for each object [`CollisionShape3D`][docs-collider-shape-3d]. This way I could play different sounds for each material collision and even have the same object emit different sounds depending on which part of the object was hit.

I was using a [`Dictionary`][docs-dictionary] to map the material to a [`Array`][docs-array] of sounds and then play it. It was working but it was a bit hard to maintain and to add new sounds. Then, I've started using a [`Resource`][docs-resource] which basically wraps the [`Dictionary`][docs-dictionary] and allow me to create and edit in the editor. But it's far from ideal. As you have to scroll through a crazy amount of resources to find the one you want to add:

![crazy-amount-of-resources][crazy-amount-of-resources]

Dictionary is a great data structure but resources are much more powerful because they are referenced by unique ids and can be edited in the editor. So I was thinking about how to make it easier to add and edit sounds for each material.

So it came to me I could use a interface just like [`SpriteFrames`][docs-sprite-frames] panel that appear when you use the [`AnimatedSprites2D`][docs-animated-sprites-2d] node.
You can add animation names and some frames to each animation and then play it as simple as `animation.play("name-of-the-animation")`.

I needed that but for sounds so I coded several hours straight, digging the original code of godot (Thankfully it's Open Source!), using AI Chat to finally reach the perfect plugin for my case:

![the-perfect-plugin][the-perfect-plugin]

Still not perfect, as you may see there are a few strange buttons that need to be tweaked and a few bugs here and there, but the sound is working and I can easily manage a collection of sounds for each material now.

[godot-adventures]: {{ page.assets }}/imgs/godot-adventures.png
[crazy-amount-of-resources]: {{ page.assets }}/imgs/crazy-amount-of-resources.png
[the-perfect-plugin]: {{ page.assets }}/imgs/the-perfect-plugin.png
[docs-resource]: https://docs.godotengine.org/en/stable/classes/class_resource.html
[docs-collider-shape-3d]: https://docs.godotengine.org/en/stable/classes/class_collisionshape3d.html
[docs-sprite-frames]: https://docs.godotengine.org/en/stable/classes/class_spriteframes.html
[docs-animated-sprites-2d]: https://docs.godotengine.org/en/stable/classes/class_animatedsprite2d.html
[docs-dictionary]: https://docs.godotengine.org/en/stable/classes/class_dictionary.html
[docs-array]: https://docs.godotengine.org/en/stable/classes/class_array.html
