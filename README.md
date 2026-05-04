<div align="center">

# PT SkyWalker541
### Pixel Transparency Shader for GB · GBC · GBA Emulation

**Performance-focused GLSL shader for low-power handhelds.**

[![RetroArch Version](https://img.shields.io/badge/RetroArch-v1.7.1-brightgreen?style=flat-square)](#)
[![NextUI Version](https://img.shields.io/badge/NextUI-v1.7.1-brightgreen?style=flat-square)](#)
[![License](https://img.shields.io/badge/license-MIT-lightgrey?style=flat-square)](#)

[What It Does](#what-it-does) • [Latest Update](#-v171-update) • [Installation](#installation) • [Parameters](#parameters)

</div>

---

> [!IMPORTANT]
> ### v1.7.1 Update
> Both the RetroArch and NextUI versions have been upgraded to **v1.7.1**.
> * **Unified Pixel Effect System:** Replaces the previous pixel border parameter with distinct simulation modes: **Grid, LCD Dot, and CRT Phosphor**.
> * **Optimized Performance:** Each mode is tuned to run at minimum cost when not selected. Parameters for inactive modes have no effect on the image.
> * **Enhanced Control:** Adds dedicated parameters for dot size, dot sharpness, phosphor bloom, scanlines, and subpixel layout (RGB/BGR).
> * **Black Level Threshold:** A parameter for LCD Dot and CRT Phosphor modes that controls where the dot effect fades in relative to black. The RetroArch version uses the raw input frame so color correction cannot cause unlit pixels to appear lit.
> * **NextUI Note:** The NextUI version includes Grid and LCD Dot modes. CRT Phosphor is not included in the NextUI version to keep performance optimal for TrimUI Brick users.
> * Note: some parameters default to 0 and will need adjusted to suit your device and preference.

---

## What It Does

On original Game Boy, GBC, and GBA hardware, pixels that were fully off didn't show as white—the physical backing material showed through instead, creating a subtle grey-green translucency. Game developers designed around this, using white areas as intentional transparent zones for backgrounds and UI.

**PT SkyWalker541** restores this original appearance by detecting white and bright pixels and blending them toward a procedurally generated backing texture.

Inspired by mattakins' pixel transparency work.
Pixel Effect dot and phosphor modes inspired by Themaister's dot shader (public domain).

---

## Two Variants

| Variant | Version | Platform | Primary Focus |
| :--- | :---: | :--- | :--- |
| **Standard** | **v1.7.1** | RetroArch (`gl` / `glcore`) | Optimized for low-power devices, with optional advanced display simulation (Grid / LCD Dot / CRT Phosphor). |
| **NextUI** | **v1.7.1** | NextUI / minarch | Optimized for TrimUI Brick and similar low-power handhelds (Grid and LCD Dot). CRT Phosphor excluded for performance. |

---

## Features

* **Pixel Transparency Restoration:** Detects white and near-white pixels to blend them toward a procedural backing texture. Includes modes for White-only, Bright, or All pixels.
* **Procedural Backing Texture:** Grainy noise tinted to match original hardware (Pocket grey, GBC/GBA grey, or GBA SP white).
* **Unified Pixel Effects (v1.7.1):**
    * **Grid:** Classic gap simulation between pixels. Available in both RetroArch and NextUI versions.
    * **LCD Dot:** Circular Gaussian dots with adjustable size, sharpness, brightness compensation, and black level threshold. Available in both versions. The RetroArch version uses the raw input frame for black detection so color correction does not affect unlit pixels.
    * **CRT Phosphor:** 9-sample neighbourhood simulation with RGB/BGR subpixel stripes, bloom spread, dot gamma, scanline roll-off, and brightness compensation. RetroArch version only — excluded from NextUI to maintain performance on low-power hardware.
* **Black Level Threshold (v1.7.1):** Controls where the dot effect fades in above black. Hard gate on truly black pixels ensures zero cost and clean blacks regardless of setting.
* **Drop Shadow:** Casts a subtle shadow from solid pixels onto the backing material at all sprite and tile edges.
* **Bezel Shadow:** Darkens screen edges to simulate the shadow cast by the physical bezel; width is set automatically per system.
* **Color Harshness Filter:** Softens overly vivid dark colors, most useful for aggressive GBC palettes.

---

## Installation

### RetroArch (v1.7.1)
1. Place `PT_SkyWalker541.glslp` in your `shaders_glsl/handheld/` folder.
2. Place `PT_SkyWalker541.glsl` in the `shaders_glsl/handheld/shaders/` subfolder.
3. Load the `.glslp` from **Quick Menu > Shaders > Load Shader Preset**.
4. Set `PT_SYSTEM` to match your target hardware in the Shader Parameters.
5. Refer to **README_GLSL.md** for full documentation and recommended settings per system.

### NextUI (v1.7.1)
1. Place `PT_SkyWalker541_NextUI.cfg` in your `Shaders/` folder.
2. Place `PT_SkyWalker541_NextUI.glsl` in the `Shaders/glsl/` subfolder.
3. Load the `.cfg` from the in-game shader menu.
4. Set `PT_SYSTEM` to match your target system.
5. Refer to **README_NextUI.md** for full documentation and recommended settings per system.

---

## System Presets

`PT_SYSTEM` selects a pre-tuned white detection threshold and bezel width for each system's characteristics.

| PT_SYSTEM | Target System | RA Threshold | NextUI Threshold |
| :---: | :--- | :---: | :---: |
| **0** | **Manual** (Use Sensitivity) | — | — |
| **1** | **Game Boy / Pocket** | 0.90 | 0.62 |
| **2** | **Game Boy Color** | 0.85 | 0.68 |
| **3** | **GBA SP** (Front-lit) | 0.80 | 0.45 |
| **4** | **GBA Original** | 0.75 | 0.42 |

---

## Parameters

Full parameter documentation, recommended settings per system, and editing defaults are covered in **README_GLSL.md** for the RetroArch version and **README_NextUI.md** for the NextUI version, both included with the shader files.

---

## Why GLSL Only?
This shader specifically targets low-power emulation devices—handhelds and budget hardware limited to `gl` or `glcore` drivers. By focusing on a highly optimized GLSL build, it provides high-quality transparency and display simulation where Slang-based shaders would cause performance issues on cost-effective hardware.

---

<div align="center">

*PT SkyWalker541 by SkyWalker541 | RetroArch v1.7.1 | NextUI v1.7.1 | AI assisted development*

</div>
