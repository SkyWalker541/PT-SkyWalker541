<div align="center">

# PT SkyWalker541
### Pixel Transparency Shader for GB · GBC · GBA Emulation

**Performance-focused GLSL shader for low-power handhelds.**

[![Version](https://img.shields.io/badge/version-v2.0.0-brightgreen?style=flat-square)](#)
[![RetroArch](https://img.shields.io/badge/RetroArch-gl%20%2F%20glcore-blue?style=flat-square)](#)
[![NextUI](https://img.shields.io/badge/NextUI-v6.11.0%2B-blue?style=flat-square)](#)
[![License](https://img.shields.io/badge/license-MIT-lightgrey?style=flat-square)](#)

[What It Does](#what-it-does) • [Latest Update](#-v200-update) • [Installation](#installation) • [Recommended Settings](#recommended-settings)

[![Shader Showcase](docs/showcase_banner.svg)](https://skywalker541.github.io/PT-SkyWalker541)

</div>

---

> [!IMPORTANT]
> ### v2.0.0 Update
> A major release. One shader file now serves both RetroArch and NextUI (there is no longer a separate NextUI build or NextUI readme).
>
> **Upgrading from 1.x:** parameter code names changed, so saved shader presets and parameter overrides from 1.x fall back to the default values. Re-save your settings after updating. The old-to-new name table is in **[README_GLSL.md](Standard%20RetroArch/README_GLSL.md)**.
>
> * **CRT Phosphor removed:** it does not apply to the reflective LCD systems this shader targets. Pixel Effect now has three modes: **Off, Grid, and LCD Dot**.
> * **New menu layout:** every group has a `== Name ==` main row with its settings indented beneath it. Effect-specific rows are tagged **[Grid]**, **[LCD Dot]** or **[Grid+Dot]**, so it is obvious what each parameter affects.
> * **Plain-language names:** every menu label now says what the setting does, and the code names match the labels.
> * **Grid reworked:** *Grid line width* is now a real line thickness (a fraction of one game pixel), and Grid has its own *Grid line opacity*.
> * **LCD Dot reworked:** *Dot edge softness* sets how soft the edge of each dot is (0 = hard, 1 = soft), and LCD Dot has its own *Dot gap opacity*. The old shared *Gap / Grid color intensity* setting is gone.
> * **Backing gap fix:** with *Gap color* set to Backing, the gaps around non-white pixels in White mode used to render black. They now use the real backing color.
> * **Better low-end compatibility:** the vertex shader passes 3 varyings instead of 8, the source is pure ASCII, a zero-width `smoothstep` was guarded, and the fallback defaults now match the parameter defaults. This targets devices where the shader previously appeared in the pass list but showed no parameters and had no effect.
> * **New defaults** (tuned on a GBC): Game system GBC, Transparent pixels All, Transparency amount 0.10, Backing color strength 2.00, Grid line width 0.25, Grid line opacity 0.50, Dot size 0.90, Dot gap opacity 0.50.

---

## What It Does

On original Game Boy, GBC, and GBA hardware, pixels that were fully off didn't show as white—the physical backing material showed through instead, creating a subtle grey-green translucency. Game developers designed around this, using white areas as intentional transparent zones for backgrounds and UI.

**PT SkyWalker541** restores this original appearance by detecting white and bright pixels and blending them toward a procedurally generated backing texture.

Inspired by mattakins' pixel transparency work.
Pixel Effect LCD Dot mode inspired by Themaister's dot shader (public domain).


---

## Features

* **Pixel Transparency Restoration:** Detects white and near-white pixels to blend them toward a procedural backing texture. Includes modes for White-only, Bright, or All pixels.
* **Procedural Backing Texture:** Grainy noise tinted to match original hardware (Pocket grey, GBC/GBA grey, or GBA SP white).
* **Pixel Effects:**
    * **Grid:** Classic gap simulation between pixels, with a real line width and its own opacity.
    * **LCD Dot:** Round dots with adjustable size, edge softness, gap opacity, and minimum brightness. Black detection uses the raw input frame, so color correction cannot make unlit pixels appear lit.
* **Gap color:** Sets the color that appears in the grid lines and between the dots. *Backing* uses the existing backing texture at zero extra cost; *Black* and *White* are also available.
* **Drop Shadow:** Casts a subtle shadow from solid pixels onto the backing material at all sprite and tile edges, with four directions.
* **Bezel Edge Shadow:** Darkens screen edges to simulate the shadow cast by the physical bezel; width is set automatically per system.
* **Darken Picture:** Softens overly vivid dark colors, most useful for aggressive GBC palettes.

---

## Installation

### RetroArch
1. Place `PT_SkyWalker541.glslp` in your `shaders_glsl/handheld/` folder.
2. Place `PT_SkyWalker541.glsl` in the `shaders_glsl/handheld/shaders/` subfolder.
3. Load the `.glslp` from **Quick Menu > Shaders > Load Shader Preset**.
4. Open Shader Parameters and set **Game system** to match your target hardware.
5. Refer to **[README_GLSL.md](Standard%20RetroArch/README_GLSL.md)** for full documentation and recommended settings per system.

### NextUI (v6.11.0 and later)
1. Place `PT_SkyWalker541.cfg` in your `Shaders/` folder.
2. Place `PT_SkyWalker541.glsl` in the `Shaders/glsl/` subfolder.
3. Load the `.cfg` from the in-game shader menu.
4. Open Shader Parameters and set **Game system** to match your target system.
5. Refer to **[README_GLSL.md](Standard%20RetroArch/README_GLSL.md)** for full documentation and recommended settings per system.

---

## System Presets

**Game system** selects a pre-tuned white detection level and bezel shadow width for each system's characteristics.

| PT_GAME_SYSTEM | Target System | White detection level |
| :---: | :--- | :---: |
| **0** | **Manual** (use *Manual white detection level*) | — |
| **1** | **Game Boy / Pocket** | 0.90 |
| **2** | **Game Boy Color** (default) | 0.85 |
| **3** | **GBA SP** (Front-lit) | 0.80 |
| **4** | **GBA Original** | 0.75 |

---

## Recommended Settings

One set of settings works as a good starting point for every system. The shader's built-in defaults were tuned and tested on a Game Boy Color, so all you need to change per system is **Game system** and **Backing color**.

**1. Set these two for your system:**

| System | Game system | Backing color |
| :--- | :---: | :---: |
| Game Boy / Pocket | 1 | 1 (Pocket) |
| Game Boy Color | 2 | 1 (Pocket) |
| GBA SP | 3 | 3 (White) |
| GBA Original | 4 | 2 (Grey) |

**2. Leave everything else at the defaults:**

| Parameter | Value |
| :--- | :--- |
| Transparent pixels | 2 (All) |
| Transparency amount | 0.10 |
| Minimum white transparency | 0.20 |
| Backing color strength | 2.00 |
| Darken picture | 0 |
| Pixel Effect | 1 (Grid) |
| Gap color | 0 (Backing) |
| Grid line width | 0.25 |
| Grid line opacity | 0.50 |
| Drop shadow opacity | 0.30 |
| Shadow distance | 1.0 |
| Shadow direction | 0 (Down Right) |
| Bezel edge shadow | 0.40 |

**LCD Dot alternative:** to use LCD Dot instead of Grid, set **Pixel Effect** to 2 and use these:

| Parameter | Value |
| :--- | :--- |
| Pixel Effect | 2 (LCD Dot) |
| Gap color | 0 (Backing) |
| Dot size | 0.90 |
| Dot edge softness | 1.00 |
| Dot gap opacity | 0.50 |
| Min brightness for dots | 0.15 |

> [!NOTE]
> This is a good starting point for each system when **Game system** and **Backing color** are set for that system as shown above. All parameters can be adjusted to suit your preference and screen. See **[README_GLSL.md](Standard%20RetroArch/README_GLSL.md)**, found in the Standard RetroArch folder, for full documentation.
>
> **Low-power devices (e.g. TrimUI Brick):** The pixel transparency system uses the majority of the GPU budget on constrained hardware. **Grid** is recommended over LCD Dot as the Pixel Effect mode — LCD Dot adds additional per-pixel cost that can cause slowdown. Grid remains nearly free at any setting.
>
> **Grid line width and your screen:** the width is a fraction of one game pixel, and a screen can only draw whole pixels. With integer scaling at N times, one screen pixel is 1/N of a game pixel, so widths below about 1/N fade out or do not show. See **Grid line width and screen resolution** in README_GLSL.md.

### Emulator core settings

These are settings in the emulator core, not the shader.

| System | Core | Color correction | Interframe blending |
| :--- | :--- | :--- | :--- |
| Game Boy / Pocket | Gambatte / SameBoy | Disabled | Disabled |
| Game Boy Color | Gambatte / SameBoy | GBC Only | Disabled |
| GBA SP | mGBA | Enabled | Smart |
| GBA Original | mGBA | Enabled | LCD ghosting (accurate) |

For Game Boy / Pocket, also disable GB Colorization.

---

## Why GLSL Only?
This shader specifically targets low-power emulation devices — handhelds and budget hardware limited to `gl` or `glcore` drivers. By focusing on a highly optimized GLSL build, it provides high-quality transparency and display simulation where Slang-based shaders would cause performance issues on cost-effective hardware.

---

<div align="center">

*PT SkyWalker541 by SkyWalker541 | v2.0.0 | RetroArch and NextUI | AI assisted development*

</div>
