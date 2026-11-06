# Ghostctl

### A collection of GLSL fragment shaders, themes and configurations optimized for the [Ghostty](https://ghostty.org/) terminal.

These shaders have been written to enforce GLSL type safety, resolve `iChannel0` initialization races, and play nicely with strict Mesa drivers and Ghostty engine changes without tanking your framerate.

A unique collection curated to show style and shader efficiency to the community.


enjoy what's displayed here!!!
And thank you for checking out the repo!
While it's still a work in progress, I hope you enjoy and look forward to watching the project grow.

Below are **Installation** instructions.(will change when custom build configuration pipeline is built. However if it is displayed on the main readme it will work.)

---

## Installation

Clone the repository:

```bash
git clone https://github.com/GrandBIRDLizard/Ghostctl.git
```
Make Ghostctl's shader config dir via:

```bash
mkdir -p ~/.config/ghostty/shaders
```

Copy a single shader into the shader dir:

```bash
cp ~/ghostctl/shaders/Master-TV.glsl \
   ~/.config/ghostty/shaders/
```

Or just move the whole lot:

```bash
cp ~/ghostctl/shaders/ \
   ~/.config/ghostty/shaders
```

---

Where ever you put it, point Ghostty at it. the config file uses `custom-shader = path/to/shader/dir/shader.glsl` for syntax:

```ini
custom-shader = ~/.config/ghostty/shaders/Mire.glsl 
```

## **Custom ZigConfig Coming Soon**

---

### Performance & Latency:
Will maintain a steady 60/120 FPS on high-refresh displays:
(NOTE Layering shaders compounds the workload but any semi-modern GPU should handle it most shaders include comptime configuration "switches" and directions at the top of the file so you can easily change properties of the shader some like `Ramanujans-Pen.glsl` are highly configurable and dynamic, so tweak things to your heart's content).

* Using `custom-shader-animation = true` in your ghostty config to pause rendering when the window is inactive(setting it to always does the opposite) it may help if you
have a large number of shaders active or older hardware.(you can layer shaders and pictures to make some interesting custom configs)

* I Keep the math inside `mainImage` as lean as possible, avoiding complex loops, and redundant logic,
and make use of more advanced mathematics such as `Smoothstepping` and `branchless` pipelines.

## Progress
This project is a work in progress, I've been tooling with in my spare time. will tag a pre-release/proper release when things are all set up.
Feel I've made significant progress, or I've come to a final direction for project.

---
