<div align="center">

# PT SkyWalker541
### Pixel Transparency Shader for GB · GBC · GBA Emulation

**Performance-focused GLSL shader for low-power handhelds.**

[![RetroArch Version](https://img.shields.io/badge/RetroArch-v1.8.0-brightgreen?style=flat-square)](#)
[![NextUI Version](https://img.shields.io/badge/NextUI-v1.8.0-brightgreen?style=flat-square)](#)
[![License](https://img.shields.io/badge/license-MIT-lightgrey?style=flat-square)](#)

[What It Does](#what-it-does) • [Latest Update](#-v180-update) • [Installation](#installation) • [Recommended Settings](#recommended-settings)

</div>

---

> [!IMPORTANT]
> ### v1.8.0 Update
> Both the RetroArch and NextUI versions have been upgraded to **v1.8.0**.
> * **Unified Pixel Effect System:** Replaces the previous pixel border parameter with distinct simulation modes: **Grid, LCD Dot, and CRT Phosphor**.
> * **Optimized Performance:** Each mode is tuned to run at minimum cost when not selected. Parameters for inactive modes have no effect on the image.
> * **Enhanced Control:** Adds dedicated parameters for dot size, dot sharpness, phosphor bloom, scanlines, and subpixel layout (RGB/BGR).
> * **Black Level Threshold:** A parameter for LCD Dot and CRT Phosphor modes that controls where the dot effect fades in relative to black. The RetroArch version uses the raw input frame so color correction cannot cause unlit pixels to appear lit.
> * **Gap / Grid Color:** New parameter for Grid, LCD Dot, and CRT Phosphor modes. Sets the color for gaps between pixels and grid lines. Choose between Backing Texture, Black, or White. Backing Texture uses the existing background parameters at zero extra cost.
> * **Gap / Grid Color Intensity:** Controls how strongly the selected gap / grid color appears. Works across all three Pixel Effect modes.
> * **Parameter Naming:** All parameter code names have been updated to closely match their menu label names, making it much easier to edit defaults directly in the shader file.
> * **NextUI Update:** The NextUI version has been upgraded to **v1.8.0**, adding Gap / Grid Color, Gap / Grid Color Intensity, Grid width rename, removal of Dot brightness compensation, and parameter naming updates to match the RetroArch version.
> * Note: some parameters default to 0 and will need adjusted to suit your device and preference.

---

## What It Does

On original Game Boy, GBC, and GBA hardware, pixels that were fully off didn't show as white—the physical backing material showed through instead, creating a subtle grey-green translucency. Game developers designed around this, using white areas as intentional transparent zones for backgrounds and UI.

**PT SkyWalker541** restores this original appearance by detecting white and bright pixels and blending them toward a procedurally generated backing texture.

Inspired by mattakins' pixel transparency work.
Pixel Effect dot and phosphor modes inspired by Themaister's dot shader (public domain).


---

## Features

* **Pixel Transparency Restoration:** Detects white and near-white pixels to blend them toward a procedural backing texture. Includes modes for White-only, Bright, or All pixels.
* **Procedural Backing Texture:** Grainy noise tinted to match original hardware (Pocket grey, GBC/GBA grey, or GBA SP white).
* **Unified Pixel Effects (v1.8.0):**
    * **Grid:** Classic gap simulation between pixels. Available in both RetroArch and NextUI versions.
    * **LCD Dot:** Circular Gaussian dots with adjustable size, sharpness, and black level threshold. Available in both versions. The RetroArch version uses the raw input frame for black detection so color correction does not affect unlit pixels.
    * **CRT Phosphor:** 9-sample neighbourhood simulation with RGB/BGR subpixel stripes, bloom spread, dot gamma, and scanline roll-off. RetroArch version only — excluded from NextUI to maintain performance on low-power hardware.
* **Black Level Threshold (v1.7.1):** Controls where the dot effect fades in above black. Hard gate on truly black pixels ensures zero cost and clean blacks regardless of setting.
* **Gap / Grid Color (v1.8.0):** Sets the color that appears in pixel gaps and grid lines for Grid, LCD Dot, and CRT Phosphor modes. Backing Texture uses the existing background parameters at zero extra cost. Black and White options include a Gap / Grid Color Intensity slider for opacity control. Dot and Phosphor brightness compensation parameters have been removed — Gap / Grid Color solves brightness at the source, making them redundant.
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

### NextUI (v1.8.0)
1. Place `PT_SkyWalker541_NextUI.cfg` in your `Shaders/` folder.
2. Place `PT_SkyWalker541_NextUI.glsl` in the `Shaders/glsl/` subfolder.
3. Load the `.cfg` from the in-game shader menu.
4. Open Shader Parameters and set System to match your target system.
5. Refer to **README_NextUI.md** for full documentation and recommended settings per system.

---

## System Presets

The System parameter selects a pre-tuned white detection threshold and bezel width for each system's characteristics.

| PT_SYSTEM | Target System | RA Threshold | NextUI Threshold |
| :---: | :--- | :---: | :---: |
| **0** | **Manual** (Use Sensitivity) | — | — |
| **1** | **Game Boy / Pocket** | 0.90 | 0.62 |
| **2** | **Game Boy Color** | 0.85 | 0.68 |
| **3** | **GBA SP** (Front-lit) | 0.80 | 0.45 |
| **4** | **GBA Original** | 0.75 | 0.42 |

---

## Recommended Settings

> [!NOTE]
> These are recommended starting points. All parameters can be adjusted to suit your preference and screen. See **README_GLSL.md**, found in the Standard Retroarch folder, for full documentation.
>
> **Low-power devices (e.g. TrimUI Brick):** The pixel transparency system uses the majority of the GPU budget on constrained hardware. **Grid** is recommended over LCD Dot as the Pixel Effect mode — LCD Dot adds additional per-pixel cost that can cause slowdown. Grid remains nearly free at any setting.

---

### Game Boy DMG

**Core Settings — Gambatte / SameBoy**

| Setting | Value |
| :--- | :--- |
| Color correction | Disabled |
| Interframe blending | Disabled |
| GB Colorization | Disabled |

**Shader Parameters**

| Parameter | Value |
| :--- | :--- |
| System | 1 |
| Pixel mode | 0 (White only) |
| Base transparency amount | 0.20 |
| White pixel min transparency | 0.20 |
| Background tint | 1 (Pocket) |
| Tint intensity | 1.00 |
| Dark color filter | 0 |
| Pixel Effect | 2 (LCD Dot) |
| Dot size | 0.60 |
| Dot sharpness | 0.20 |
| Black level threshold | 0.15 |
| Gap / Grid color | 0 (Backing Texture) |
| Gap / Grid color intensity | 0.30 |
| Shadow offset | 1.0 |
| Shadow direction | 0 (Down Right) |
| Shadow opacity | 0.30 |
| Bezel shadow strength | 0.30 |

---

### Game Boy Color

**Core Settings — Gambatte / SameBoy**

| Setting | Value |
| :--- | :--- |
| Color correction | GBC Only |
| Interframe blending | Disabled |

**Shader Parameters**

| Parameter | Value |
| :--- | :--- |
| System | 2 |
| Pixel mode | 0 (White only) |
| Base transparency amount | 0.20 |
| White pixel min transparency | 0.20 |
| Background tint | 1 (Pocket) |
| Tint intensity | 1.00 |
| Dark color filter | 10 |
| Pixel Effect | 2 (LCD Dot) |
| Dot size | 0.60 |
| Dot sharpness | 0.20 |
| Black level threshold | 0.15 |
| Gap / Grid color | 0 (Backing Texture) |
| Gap / Grid color intensity | 0.30 |
| Shadow offset | 1.0 |
| Shadow direction | 0 (Down Right) |
| Shadow opacity | 0.30 |
| Bezel shadow strength | 0.30 |

---

### Game Boy Advance Original

**Core Settings — mGBA**

| Setting | Value |
| :--- | :--- |
| Color correction | Enabled |
| Interframe blending | LCD ghosting (accurate) |

**Shader Parameters**

| Parameter | Value |
| :--- | :--- |
| System | 4 |
| Pixel mode | 0 (White only) |
| Base transparency amount | 0.25 |
| White pixel min transparency | 0.55 |
| Background tint | 2 (Grey) |
| Tint intensity | 1.00 |
| Dark color filter | 0 |
| Pixel Effect | 2 (LCD Dot) |
| Dot size | 0.60 |
| Dot sharpness | 0.20 |
| Black level threshold | 0.15 |
| Gap / Grid color | 0 (Backing Texture) |
| Gap / Grid color intensity | 0.30 |
| Shadow offset | 1.0 |
| Shadow direction | 0 (Down Right) |
| Shadow opacity | 0.20 |
| Bezel shadow strength | 0.30 |

---

### Game Boy Advance SP

**Core Settings — mGBA**

| Setting | Value |
| :--- | :--- |
| Color correction | Enabled |
| Interframe blending | Smart |

**Shader Parameters**

| Parameter | Value |
| :--- | :--- |
| System | 3 |
| Pixel mode | 0 (White only) |
| Base transparency amount | 0.15 |
| White pixel min transparency | 0.45 |
| Background tint | 3 (White) |
| Tint intensity | 1.00 |
| Dark color filter | 0 |
| Pixel Effect | 2 (LCD Dot) |
| Dot size | 0.65 |
| Dot sharpness | 0.20 |
| Black level threshold | 0.15 |
| Gap / Grid color | 0 (Backing Texture) |
| Gap / Grid color intensity | 0.30 |
| Shadow offset | 1.0 |
| Shadow direction | 0 (Down Right) |
| Shadow opacity | 0.20 |
| Bezel shadow strength | 0.30 |

---

## Why GLSL Only?
This shader specifically targets low-power emulation devices — handhelds and budget hardware limited to `gl` or `glcore` drivers. By focusing on a highly optimized GLSL build, it provides high-quality transparency and display simulation where Slang-based shaders would cause performance issues on cost-effective hardware.

---

<div align="center">

*PT SkyWalker541 by SkyWalker541 | RetroArch v1.8.0 | NextUI v1.8.0 | AI assisted development*

</div>
