<div align="center">

# PT SkyWalker541

### Pixel Transparency Shader for GB · GBC · GBA Emulation

**by SkyWalker541**

![Version](https://img.shields.io/badge/version-1.5.0-brightgreen?style=flat-square)
![RetroArch](https://img.shields.io/badge/RetroArch-GLSL%20%7C%20Slang-blue?style=flat-square)
![NextUI](https://img.shields.io/badge/NextUI-TrimUI%20Brick-orange?style=flat-square)
![License](https://img.shields.io/badge/license-MIT-lightgrey?style=flat-square)

</div>

---

<div align="center">

*On original Game Boy hardware, pixels that were fully off didn't show as white.*
*The physical backing material showed through — a subtle grey-green translucency.*
*Game developers designed around this. Your emulator doesn't know that.*

**PT SkyWalker541 puts the transparency back where it belongs.**

</div>

---

## What It Does

Unlit LCD pixels on original GB, GBC, and GBA screens revealed the backing material beneath — a translucent grey-green layer rather than solid white. Developers treated these "white" areas as intentional transparent zones for backgrounds, windows, and UI overlays. On modern emulators they render as flat, solid white, losing that layered depth entirely.

This shader detects bright and near-white pixels and blends them toward a procedurally generated backing texture, restoring the original appearance without relying on any pre-made assets or additional passes.

---

## Three Variants, One Engine

<div align="center">

| Variant | Platform | Best For |
|---|---|---|
| **PT_SkyWalker541** | RetroArch | Mid-range to modest hardware |
| **PT_SkyWalker541_Pro** | RetroArch | Powerful hardware, maximum effects |
| **PT_SkyWalker541_Aspect** | NextUI / TrimUI Brick | Aspect ratio or any non-integer scale |
| **PT_SkyWalker541_Integer** | NextUI / TrimUI Brick | Native / integer scale only |

</div>

All four share the same core transparency engine and the same 15 parameters. The Pro version adds an extended effect suite. The NextUI versions have detection thresholds pre-compensated for NextUI's post-processing pipeline.

---

## RetroArch Standard — `PT_SkyWalker541`

```
PT_SkyWalker541.glsl   +   PT_SkyWalker541.glslp    →   gl, glcore drivers
PT_SkyWalker541.slang  +   PT_SkyWalker541.slangp   →   Vulkan, glcore, D3D11, D3D12, Metal
```

Single-pass shader. White detection runs against the raw unprocessed game frame via RetroArch's built-in `OrigTexture` uniform — no passthrough pass required. Designed for clean, accurate results at low GPU cost.

**Features:** System presets · pixel border · drop shadow · background palette & tint · chromatic shift · vignette · dark filter · brightness mode

> See `README_GLSL.md` or `README_Slang.md` for full documentation.

---

## RetroArch Pro — `PT_SkyWalker541_Pro`

```
PT_SkyWalker541_Pro.glsl   +   PT_SkyWalker541_Pro.glslp    →   gl, glcore drivers
PT_SkyWalker541_Pro.slang  +   PT_SkyWalker541_Pro.slangp   →   Vulkan, glcore, D3D11, D3D12, Metal
```

The full-featured version. Same core transparency engine as Standard, expanded with a suite of hardware-accurate display effects for more powerful hardware.

**Everything in Standard, plus:**

- Directional gaussian shadow blur — 15-tap, spread along the shadow direction vector with gaussian weights
- LCD halation glow — adjustable radius and warmth, simulates backlight bleed on lit screens
- Bayer subpixel dithering — 2×2, 4×4, or 8×8 matrix at the transparency blend boundary
- Screen curvature — with edge chromatic fringing
- Adjustable grain — independent intensity and scale controls
- Green-grey palette option — additional backing tint for GB authenticity

> See `README_Pro_GLSL.md` or `README_Pro_Slang.md` for full documentation.

---

## NextUI — `PT_SkyWalker541_Aspect` / `PT_SkyWalker541_Integer`

```
PT_SkyWalker541_Aspect.glsl   +   PT_SkyWalker541_Aspect.cfg
PT_SkyWalker541_Integer.glsl  +   PT_SkyWalker541_Integer.cfg
```

Purpose-built for NextUI on the TrimUI Brick. Single-pass, single-texture. Both shaders are fully standalone — no additional passes or files required beyond the `.glsl` and `.cfg` pair.

**Aspect** uses a sine-wave pixel border method that works correctly at any scale mode. **Integer** uses a distance-from-center method that produces a sharper, cleaner grid at exact integer scale multiples. If you are unsure which to use, choose Aspect — it works at any scale including native.

> See `README_NextUI.md` for full documentation.

---

## System Presets

All variants support the same four system presets via `PT_SYSTEM`.

<div align="center">

| PT_SYSTEM | System | Notes |
|:---:|---|---|
| 0 | Manual | Set your own threshold via `PT_SENSITIVITY` |
| 1 | Game Boy / Pocket | No backlight — aggressive detection |
| 2 | Game Boy Color | No backlight — moderate detection |
| 3 | GBA SP | Front-lit screen — conservative detection |
| 4 | GBA Original | No backlight — catches creamy/dim whites |

</div>

---

## Installation

**RetroArch (Standard or Pro)**
1. Place the `.glsl` / `.slang` shader file and its matching `.glslp` / `.slangp` preset in your RetroArch shaders folder
2. Load the preset from the RetroArch shader menu
3. Set `PT_SYSTEM` to match your target system

**NextUI**
1. Place the `.glsl` and `.cfg` files in your NextUI shaders folder
2. Load the `.cfg` from the in-game shader menu
3. Set `PT_SYSTEM` to match your target system

---

## Parameters

All variants share the same 15 parameters, adjustable from the in-game shader menu.

<div align="center">

| Parameter | Description |
|---|---|
| `PT_SYSTEM` | System preset — GB / GBC / GBA SP / GBA Original / Manual |
| `PT_SENSITIVITY` | Detection threshold when using Manual mode |
| `PT_PIXEL_MODE` | White only / Bright / All pixels |
| `PT_BASE_ALPHA` | How transparent detected pixels become |
| `PT_WHITE_TRANSPARENCY` | Minimum transparency boost for clearly white pixels |
| `PT_BRIGHTNESS_MODE` | Simple (equal RGB) or Perceptual (vision-weighted) |
| `PT_PALETTE` | Background tint — Off / Pocket / Grey / White |
| `PT_PALETTE_INTENSITY` | Tint strength |
| `PT_DARK_FILTER_LEVEL` | Softens overly vivid dark colours |
| `PT_PIXEL_BORDER` | LCD dot gap simulation — Off / Subtle / Moderate / Strong |
| `PT_SHADOW_OFFSET_X` | Drop shadow horizontal offset |
| `PT_SHADOW_OFFSET_Y` | Drop shadow vertical offset |
| `PT_SHADOW_OPACITY` | Drop shadow strength |
| `PT_CHROMA` | Chromatic shift — simulates LCD channel misalignment |
| `PT_VIGNETTE` | Edge darkening — simulates uneven backlight distribution |

</div>

The Pro variant adds a further 13 parameters for shadow blur, halation, dithering, curvature, grain, and fringe. See the Pro README for details.

---

<div align="center">

*PT SkyWalker541 by SkyWalker541*

</div>
