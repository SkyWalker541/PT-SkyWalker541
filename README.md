<div align="center">

# PT SkyWalker541
### Pixel Transparency Shader for GB · GBC · GBA Emulation

**Performance-focused GLSL shader for low-power handhelds.**

[![Version](https://img.shields.io/badge/version-v2.1.0-brightgreen?style=flat-square)](#)
[![RetroArch](https://img.shields.io/badge/RetroArch-gl%20%2F%20glcore-blue?style=flat-square)](#)
[![NextUI](https://img.shields.io/badge/NextUI-v6.11.0%2B-blue?style=flat-square)](#)
[![License](https://img.shields.io/badge/license-MIT-lightgrey?style=flat-square)](#)

[What It Does](#what-it-does) • [Latest Update](#v210-update) • [Installation](#installation) • [Recommended Settings](#recommended-settings)

[![Shader Showcase](docs/showcase_banner.svg)](https://skywalker541.github.io/PT-SkyWalker541)

</div>

---

> [!IMPORTANT]
> ### v2.1.0 Update
> A feature release. It adds one new, **optional** feature: **Glare and sheen**. It is **Off by default**, so with its default settings the picture is identical to v2.0.1, and settings saved with v2.0.x keep working. No parameter was renamed, removed or changed. Just replace the shader file.
>
> * **Glare and sheen** puts a soft hotspot of light (glare) and a faint rainbow tint (sheen) on the screen's backing material, like sunlight catching a Game Boy screen. It only shows where the backing shows: the transparent areas, and the grid lines or dot gaps when *Gap color* is Backing.
> * **It is a matter of taste.** Set the **== Glare and sheen ==** switch to 1 to try it, then adjust the settings to your liking. You can turn it off completely at any time by setting that switch back to 0. It is not part of the Recommended Settings below.
> * **11 new parameters** (31 in total), listed under **Glare and sheen (optional)** below and in full in **[README_GLSL.md](Standard%20RetroArch/README_GLSL.md)**.
> * With Glare and sheen Off, the extra cost is one cheap check per pixel. The light is moved in the vertex shader, which adds one varying (4 in total). The cost with it On has not been measured on specific devices, so on a low-power handheld, compare with it On and Off and turn it off if you see slowdown.
>
> ---
>
> ### v2.0.1 Update
> A fix release. It changes no parameter names, ranges or defaults, so settings saved with v2.0.0 keep working. Just replace the shader file.
>
> * **Parameters missing on some Android RetroArch builds:** the *Shadow direction* menu label was longer than RetroArch's 63-character limit for parameter labels. On builds that enforce the limit, the shader's parameters did not appear at all. The label is now shorter.
> * **GLES3 fix:** the fragment shader declared its output before the precision statement, which GLSL ES 3.00 (GLES3) rejects. The order is fixed, and the shader now compiles under both GLSL ES 1.00 and 3.00.
>
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

## Screenshots

**Glare and sheen, on top of the full pixel-transparency stack.**

Grid, pixel transparency, and drop shadow with the new optional light and rainbow sheen — captured on a Retroid Pocket Classic.

<div align="center">

|  |  |
| :---: | :---: |
| ![Glare and sheen on Grid, pixel transparency and drop shadow (Retroid Pocket Classic)](docs/glare_sheen_retroid_pocket_classic_1.png) | ![Glare and sheen on Grid, pixel transparency and drop shadow (Retroid Pocket Classic)](docs/glare_sheen_retroid_pocket_classic_2.png) |

</div>

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
* **Glare and Sheen (optional, Off by default):** A soft hotspot of light and a faint rainbow tint on the backing material, with adjustable light position, drift, color and unevenness. Entirely to taste; turn it off with one switch.

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

## Glare and Sheen (optional)

An optional effect that is **Off by default**. It adds the look of sunlight catching a Game Boy screen: a soft hotspot of light (**glare**) and a faint, colored rainbow tint in bands (**sheen**) around a light point that sits, or slowly drifts, over the picture.

It is drawn on the screen's **backing material** only: the transparent areas, and the grid lines or dot gaps when **Gap color** is Backing. Pixels that stay solid are not touched. If you cannot see it, raise **Transparency amount** or use Gap color = Backing so more of the backing shows.

> [!NOTE]
> **This feature is purely a matter of taste.** Turn on **== Glare and sheen ==** (set it to 1) and adjust the settings below until it looks right to you, or leave it Off. With the switch at 0 the shader behaves exactly as in v2.0.1. There is no tilt-sensor input: the light is moved by the shader itself over time (or held still).

| Menu row | Default | Range | What it does |
| :--- | :---: | :---: | :--- |
| **== Glare and sheen ==** (0=Off, 1=On) | **0 (Off)** | 0 – 1 | Master switch for everything in this group. 0 = completely off. |
| Glare strength | 0.15 | 0 – 1 | How bright the white hotspot is. 0 turns glare off. |
| Glare spread | 0.35 | 0.05 – 1 | How large the hotspot is, relative to the picture height. |
| Sheen strength | 0.12 | 0 – 0.5 | How strong the rainbow tint is. 0 turns sheen off. It shifts color without making the backing brighter or darker overall. |
| Sheen band density | 2.0 | 0.5 – 6 | How many color bands appear. Higher = more, narrower bands. |
| Sheen hue turn | 0 | 0 – 1 | Shifts the rainbow colors. 1.0 is one full color cycle, so 0 and 1 look the same. |
| Sheen ripple (0=smooth bands) | 0 | 0 – 1 | Makes the bands uneven, like uneven film, instead of smooth rings. 0 = smooth and skips the extra work. |
| Sheen ripple size | 0.6 | 0.1 – 3 | Size of the uneven patches when ripple is above 0. Larger = bigger patches. |
| Light home, left to right | 0.5 | -0.5 – 1.5 | Where the light sits across the picture. 0 = left edge, 0.5 = middle, 1 = right edge. Values outside 0 – 1 put it off the edge. |
| Light home, top to bottom | 0.45 | -0.5 – 1.5 | Where the light sits down the picture. 0 = top edge, 1 = bottom edge. |
| Light drift speed (0=stay at home) | 0.5 | 0 – 4 | How fast the light wanders around its home position. 0 = the light stays exactly at home. |

See **[README_GLSL.md](Standard%20RetroArch/README_GLSL.md)** for a longer description of each setting.

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
> This is a good starting point for each system when **Game system** and **Backing color** are set for that system as shown above. All parameters can be adjusted to suit your preference and screen. **Glare and sheen** is optional, Off by default, and not part of these recommended settings. See **[README_GLSL.md](Standard%20RetroArch/README_GLSL.md)**, found in the Standard RetroArch folder, for full documentation.
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

*PT SkyWalker541 by SkyWalker541 | v2.1.0 | RetroArch and NextUI | AI assisted development*

</div>
