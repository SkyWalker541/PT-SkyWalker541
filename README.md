<div align="center">

# PT SkyWalker541
### Pixel Transparency Shader for GB · GBC · GBA Emulation

**Performance-focused GLSL shader for low-power handhelds.**

[![RetroArch Version](https://img.shields.io/badge/RetroArch-v1.8.0-brightgreen?style=flat-square)](#)
[![NextUI](https://img.shields.io/badge/NextUI-Retired-lightgrey?style=flat-square)](#)
[![License](https://img.shields.io/badge/license-MIT-lightgrey?style=flat-square)](#)

[What It Does](#what-it-does) • [Latest Update](#-v180-update) • [Installation](#installation) • [Parameters](#parameters)

</div>

---

> [!IMPORTANT]
> ### v1.8.0 Update
> The RetroArch version has been upgraded to **v1.8.0**.
> * **Unified Pixel Effect System:** Replaces the previous pixel border parameter with distinct simulation modes: **Grid, LCD Dot, and CRT Phosphor**.
> * **Optimized Performance:** Each mode is tuned to run at minimum cost when not selected. Parameters for inactive modes have no effect on the image.
> * **Enhanced Control:** Adds dedicated parameters for dot size, dot sharpness, phosphor bloom, scanlines, and subpixel layout (RGB/BGR).
> * **Black Level Threshold:** A parameter for LCD Dot and CRT Phosphor modes that controls where the dot effect fades in relative to black. The RetroArch version uses the raw input frame so color correction cannot cause unlit pixels to appear lit.
> * **Gap / Grid Color:** New parameter for Grid, LCD Dot, and CRT Phosphor modes. Sets the color for gaps between pixels and grid lines. Choose between Backing Texture, Black, or White. Backing Texture uses the existing background parameters at zero extra cost.
> * **Gap / Grid Color Intensity:** Controls how strongly the selected gap / grid color appears. Works across all three Pixel Effect modes.
> * **Parameter Naming:** All parameter code names have been updated to closely match their menu label names, making it much easier to edit defaults directly in the shader file.
> * **Shadow Direction:** New parameter lets the user choose from four drop shadow directions — Down Right, Down Left, Up Right, or Up Left. Default is Down Right. Shadow offset direction has also been corrected to cast down and to the right by default.
> * **NextUI:** The separate NextUI variant has been retired as of [NextUI v6.11.0](https://github.com/LoveRetro/NextUI/releases/tag/v6.11.0). The standard RetroArch shader now works natively on NextUI.
> * Note: some parameters default to 0 and will need adjusted to suit your device and preference.

---

## What It Does

On original Game Boy, GBC, and GBA hardware, pixels that were fully off didn't show as white — the physical backing material showed through instead, creating a subtle grey-green translucency. Game developers designed around this intentionally, using white areas as transparent zones for backgrounds, UI, and sky. On modern displays those same pixels render as solid bright white, losing that original quality entirely.

**PT SkyWalker541** restores this appearance by detecting white and bright pixels and blending them toward a procedurally generated backing texture that simulates the original screen material — complete with grain, palette tint matched to each system, and drop shadow at sprite edges.

On top of the transparency system, the shader offers three display simulation modes — **Grid**, **LCD Dot**, and **CRT Phosphor** — that recreate the physical pixel structure of the original screens. Each mode is independently tunable and runs at minimum cost when not selected. Gap / Grid Color lets you choose what appears in the gaps between pixels, from the backing texture itself to black or white, with adjustable intensity.

All features are designed to run efficiently on low-power hardware, targeting the `gl` and `glcore` drivers common on budget handhelds and low-cost emulation devices.

*Inspired by mattakins' pixel transparency work. Pixel Effect dot and phosphor modes inspired by Themaister's dot shader (public domain).*

---

## Two Variants

| Variant | Version | Platform | Primary Focus |
| :--- | :---: | :--- | :--- |
| **Standard** | **v1.8.0** | RetroArch (`gl` / `glcore`) | Optimized for low-power devices, with optional advanced display simulation (Grid / LCD Dot / CRT Phosphor). |
| **NextUI** *(retired)* | **v1.8.0** | NextUI / minarch | Retired as of NextUI v6.11.0. The standard RetroArch shader now works natively on NextUI. See the note below. |

---

> [!NOTE]
> **NextUI Official Release:** As of [NextUI v6.11.0](https://github.com/LoveRetro/NextUI/releases/tag/v6.11.0), the standard RetroArch shader (`PT_SkyWalker541.glsl`) now works natively on NextUI. The separate NextUI variant has been retired — it was only necessary prior to NextUI adding `OrigTexture` support. NextUI uses a `.cfg` file instead of a `.glslp` — a `.cfg` file is provided in the `NextUI/` folder of this repository. The `.glsl` file from the RetroArch files is still required.

---

## Features

* **Pixel Transparency:** Detects white and near-white pixels and blends them toward a procedurally generated backing texture. Three modes — White-only, Bright, or All pixels — let you control which pixels are affected.
* **Backing Texture:** Grainy procedural noise tinted to match each system's screen backing material — Pocket warm green-grey, GBC/GBA neutral grey, or GBA SP white.
* **Unified Pixel Effects (v1.8.0):**
    * **Grid:** Classic gap simulation between pixels.
    * **LCD Dot:** Circular Gaussian dots with adjustable size, sharpness, and black level threshold. Uses the raw input frame for black detection so color correction does not affect unlit pixels.
    * **CRT Phosphor:** 9-sample neighbourhood simulation with RGB/BGR subpixel stripes, bloom spread, dot gamma, and scanline roll-off. RetroArch version only — excluded from NextUI to maintain performance on low-power hardware. *Due to its 9-sample design, CRT Phosphor is the most GPU-intensive mode. On low-power devices it may reduce performance — Grid or LCD Dot are recommended for constrained hardware.*
* **Black Level Threshold:** Controls where the LCD Dot and CRT Phosphor effect fades in above black. A hard gate on truly black pixels ensures clean blacks at zero processing cost regardless of the threshold value.
* **Gap / Grid Color:** Sets the color that appears in pixel gaps and grid lines for Grid, LCD Dot, and CRT Phosphor modes. Choose between Backing Texture, Black, or White. Gap / Grid Color Intensity controls opacity across all three options.
* **Drop Shadow:** Casts a subtle shadow from solid pixels onto the backing material at all sprite and tile edges.
* **Bezel Shadow:** Darkens screen edges to simulate the shadow cast by the physical bezel; width is set automatically per system.
* **Color Harshness Filter:** Softens overly vivid dark colors, most useful for aggressive GBC palettes.

---

## Installation

### RetroArch (v1.8.0)
1. Place `PT_SkyWalker541.glslp` in your `shaders_glsl/handheld/` folder.
2. Place `PT_SkyWalker541.glsl` in the `shaders_glsl/handheld/shaders/` subfolder.
3. Load the `.glslp` from **Quick Menu > Shaders > Load Shader Preset**.
4. Open Shader Parameters and set System to match your target hardware.
5. Refer to **README_GLSL.md** for full documentation and recommended settings per system.

### NextUI (as of v6.11.0)
The separate NextUI variant has been retired. As of [NextUI v6.11.0](https://github.com/LoveRetro/NextUI/releases/tag/v6.11.0) the standard RetroArch shader works natively on NextUI. Use the RetroArch `.glsl` file with the `.cfg` file provided in the `NextUI/` folder of this repository.

1. Place `PT_SkyWalker541.glsl` from the RetroArch files in your `Shaders/glsl/` folder.
2. Place `PT_SkyWalker541.cfg` from the `NextUI/` folder in your `Shaders/` folder.
3. Load the `.cfg` from the in-game shader menu.
4. Open Shader Parameters and set System to match your target system.
5. Refer to **README_GLSL.md** for full documentation and recommended settings per system.

---

## System Presets

The System parameter selects a pre-tuned white detection threshold and bezel width for each system's characteristics.

| System | Target System | Threshold |
| :---: | :--- | :---: |
| **0** | **Manual** (Use Sensitivity) | — |
| **1** | **Game Boy / Pocket** | 0.90 |
| **2** | **Game Boy Color** | 0.85 |
| **3** | **GBA SP** (Front-lit) | 0.80 |
| **4** | **GBA Original** | 0.75 |

---

## Parameters

Full parameter documentation, recommended settings per system, and editing defaults are covered in **README_GLSL.md** included with the shader files.

---

<div align="center">

*PT SkyWalker541 by SkyWalker541 | RetroArch v1.8.0 | AI assisted development*

</div>
