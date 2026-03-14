<div align="center">

# PT SkyWalker541

## Please note, the Pro version of the GLSL shader is not ready for release, and will be coming at a later date. The slang version is available now.

### Pixel Transparency Shader for GB · GBC · GBA Emulation

**by SkyWalker541**

![Version](https://img.shields.io/badge/version-1.5.2-brightgreen?style=flat-square)
![RetroArch](https://img.shields.io/badge/RetroArch-GLSL%20%7C%20Slang-blue?style=flat-square)
![NextUI](https://img.shields.io/badge/NextUI-minarch-orange?style=flat-square)
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

| Variant | Platform | Files | Best For |
|---|---|---|---|
| **Standard** | RetroArch | `.glsl` + `.glslp` / `.slang` + `.slangp` | Mid-range to modest hardware |
| **Pro** | RetroArch | `.glsl` + `.glslp` / `.slang` + `.slangp` | Powerful hardware, maximum effects |
| **NextUI** | NextUI / minarch | Aspect / Integer | Any device running NextUI |

All three share the same core transparency engine. The GLSL and Slang builds of Standard and Pro are functionally identical — choose based on your RetroArch video driver. The NextUI variant has detection thresholds pre-compensated for NextUI's post-processing pipeline and comes in two builds: **Aspect** for any scale mode, **Integer** for native/integer scaling only.

---

## RetroArch Standard — `PT_SkyWalker541`

```
PT_SkyWalker541.glsl   +   PT_SkyWalker541.glslp    →   gl, glcore drivers
PT_SkyWalker541.slang  +   PT_SkyWalker541.slangp   →   Vulkan, glcore, D3D11, D3D12, Metal
```

Single-pass shader. White detection runs against the raw unprocessed game frame via RetroArch's built-in `OrigTexture` uniform / `Original` semantic — no passthrough pass required.

### Features

- **Pixel transparency restoration** — detects white and near-white pixels and blends them toward a procedurally generated backing texture. Detection runs on the raw pre-correction frame for accurate thresholds. Three modes: white-only, brightness-proportional, or all pixels.
- **Procedural backing texture** — noise grain tinted to match the original hardware's backing material. Four palette options: off (neutral grain), Pocket grey (warm green-grey, DMG/Pocket), grey (neutral, GBC/GBA Original), white (clean, GBA SP). Adjustable tint intensity.
- **Drop shadow** — cast by all solid non-white pixels onto the backing behind them. Gated on the source pixel being non-white rather than the current pixel being transparent, so it correctly appears at all sprite and tile edges regardless of surrounding content.
- **Pixel border** — simulates the thin physical gap between individual LCD dots. Sine-wave method works correctly at any scale mode. Four strengths: off, subtle (~17%), moderate (~41%), strong (~76%).
- **Colour harshness filter** — softens overly vivid dark colours. Most useful for GBC games with aggressive colour palettes.
- **Vignette** — edge darkening simulating uneven light distribution on original handheld screens.
- **Chromatic shift** *(hidden, default off)* — radial RGB channel separation from the screen centre. Edit `PT_CHROMA_STRENGTH` in the shader file to enable.

> See `README_Slang.md` or `README_GLSL.md` for full documentation and per-system settings.

---

## RetroArch Pro — `PT_SkyWalker541_Pro`

```
PT_SkyWalker541_Pro.glsl   +   PT_SkyWalker541_Pro.glslp    →   gl, glcore drivers
PT_SkyWalker541_Pro.slang  +   PT_SkyWalker541_Pro.slangp   →   Vulkan, glcore, D3D11, D3D12, Metal
```

The full-featured version. Same core transparency engine as Standard, expanded with a suite of hardware-accurate display effects for more powerful hardware.

### Features

Everything in Standard, plus:

- **Improved detection edge** — soft smoothstep gradient replaces the hard threshold, eliminating fringing at the detection boundary.
- **Directional shadow blur** — 15-tap gaussian blur spread along the shadow direction vector. Gives a natural soft falloff. Hard shadow mode (blur = 0) still available and matches Standard's performance.
- **LCD halation** — 8-tap radial glow simulating backlight bleed through the front-light diffuser. Adjustable radius and colour temperature. GBA SP only — leave off for reflective screens.
- **Tight bloom** — 4-tap close-range pixel bleed between adjacent bright pixels through the diffuser. Distinct from halation (wide area glow) — this is the immediate bleed into direct neighbours. Use both together for the most authentic GBA SP front-light look. GBA SP only.
- **Bayer dithering** — ordered dither pattern at the transparency blend boundary, replicating the slow pixel response of original LCD panels. 2×2, 4×4, or 8×8 matrix.
- **Adjustable grain** — independent intensity and scale controls for the backing texture grain. Standard uses fixed values.
- **Screen warp** — barrel distortion simulating the curvature of the physical screen glass. Applied to the sampling UV so the full image warps consistently.
- **Subpixel layout** — simulates the RGB vertical stripe subpixel structure of the original LCD panels. Leave off for the monochrome GB.
- **Reflective sheen** — inverse radial gradient brightening the screen edges to simulate ambient light on reflective LCD glass. GB, GBC, and GBA Original only — leave off for GBA SP.
- **Green-grey palette** — additional backing tint option (value 4) matching the original GBA's yellowish polariser tint.

### Hidden parameters

Several Pro parameters are not in the RetroArch shader menu due to the 15-parameter menu limit. They live in the **Advanced Defaults** `#define` block near the top of the shader file and can be edited in any text editor.

| Parameter | What it controls |
|---|---|
| `PT_BRIGHTNESS_MODE_DEFAULT` | Simple vs perceptual brightness calculation |
| `PT_PALETTE_INTENSITY_DEFAULT` | Backing tint strength |
| `PT_GRAIN_INTENSITY_DEFAULT` | Backing grain visibility |
| `PT_GRAIN_SCALE_DEFAULT` | Backing grain size |
| `PT_SHADOW_BLUR_RADIUS_DEFAULT` | How far the shadow blur spreads in texels |
| `PT_HALATION_RADIUS_DEFAULT` | Radius of the halation glow |
| `PT_HALATION_WARMTH_DEFAULT` | Colour temperature of the halation glow |
| `PT_DITHER_STRENGTH_DEFAULT` | How strongly dithering offsets the blend alpha |
| `PT_DITHER_MATRIX_DEFAULT` | Dither matrix size (0 = 2×2, 1 = 4×4, 2 = 8×8) |
| `PT_SUBPIXEL_STRENGTH_DEFAULT` | Subpixel layout intensity |
| `PT_TIGHT_BLOOM_DEFAULT` | Tight bloom strength |
| `PT_TIGHT_BLOOM_RADIUS_DEFAULT` | Tight bloom tap radius in texels |
| `PT_WARP_STRENGTH_DEFAULT` | Screen warp / barrel distortion strength |
| `PT_SHEEN_STRENGTH_DEFAULT` | Reflective sheen strength |
| `PT_CHROMA_STRENGTH` | Chromatic shift intensity |

> See `README_Pro_Slang.md` or `README_Pro_GLSL.md` for full documentation, per-system settings, and recommended hidden parameter values for each system.

---

## NextUI — `PT_SkyWalker541_Aspect` / `PT_SkyWalker541_Integer`

```
PT_SkyWalker541_Aspect.glsl   +   PT_SkyWalker541_Aspect.cfg
PT_SkyWalker541_Integer.glsl  +   PT_SkyWalker541_Integer.cfg
```

Purpose-built for NextUI / minarch. Single-pass, single-texture, fully standalone — no additional passes or files required beyond the `.glsl` and `.cfg` pair.

**Aspect** uses a sine-wave pixel border that works at any scale mode. **Integer** uses a distance-from-centre method for a sharper, cleaner grid at exact integer scale multiples. If you are unsure which to use, choose Aspect.

### Features

- **Pixel transparency restoration** — same core detection as Standard, with thresholds pre-compensated for NextUI's post-processing pipeline. Thresholds differ from the RetroArch version by design.
- **Two pixel border methods** — Aspect uses sine-wave (any scale mode); Integer uses distance-from-centre (integer scale only, sharper grid).
- **Procedural backing texture, drop shadow, colour harshness filter, and vignette** — same feature set as Standard.

> See `README_NextUI.md` for full documentation and per-system settings.

---

## System Presets

All variants use `PT_SYSTEM` to select a pre-tuned white detection threshold for each system's display characteristics. Getting this right is the single most impactful thing you can do — the wrong preset will either miss most of the transparency effect or start making non-white pixels transparent.

| PT_SYSTEM | System | Detection threshold |
|:---:|---|---|
| 0 | Manual — set your own via `PT_SENSITIVITY` | — |
| 1 | Game Boy / Pocket | 0.90 (RetroArch) / 0.58 (NextUI) |
| 2 | Game Boy Color | 0.85 (RetroArch) / 0.65 (NextUI) |
| 3 | GBA SP (front-lit) | 0.80 (RetroArch) / 0.42 (NextUI) |
| 4 | GBA Original | 0.75 (RetroArch) / 0.38 (NextUI) |

NextUI thresholds differ because detection runs on the post-processed frame rather than the raw pre-correction frame.

---

## Installation

**RetroArch (Standard or Pro)**
1. Place the shader file and its matching preset in your RetroArch shaders folder
2. Load the `.glslp` or `.slangp` preset from **Quick Menu → Shaders → Load Shader Preset**
3. Open **Shader Parameters** and set `PT_SYSTEM` to match your target system
4. Apply the recommended settings from the relevant README

**NextUI**
1. Place the `.cfg` files in your NextUI shaders folder
2. Place the `.glsl` files in the glsl subfolder inside your NextUI shaders folder
3. Load the `.cfg` from the in-game shader menu
4. Set `PT_SYSTEM` to match your target system
5. Apply the recommended settings from `README_NextUI.md`

---

## A Note on Settings

Original hardware varied — screens aged, lighting differed, no two units looked quite the same. The recommended settings aim for accuracy, but tuning to your own taste is entirely in the spirit of what the shader is trying to do. Adjust freely until it looks right.

---

## Parameters

**Standard and NextUI** expose these 14 parameters from the shader menu:

| Parameter | Description |
|---|---|
| `PT_SYSTEM` | System preset — sets the white detection threshold |
| `PT_SENSITIVITY` | Detection threshold when using Manual mode (PT_SYSTEM = 0) |
| `PT_PIXEL_MODE` | White only / Bright / All pixels |
| `PT_BASE_ALPHA` | How transparent detected pixels become |
| `PT_WHITE_TRANSPARENCY` | Minimum transparency boost for confirmed white pixels |
| `PT_BRIGHTNESS_MODE` | Simple (equal RGB average) or Perceptual (ITU-R BT.709) |
| `PT_PALETTE` | Backing tint — Off / Pocket grey / Grey / White |
| `PT_PALETTE_INTENSITY` | Tint strength |
| `PT_DARK_FILTER_LEVEL` | Softens overly vivid dark colours |
| `PT_PIXEL_BORDER` | LCD dot gap — Off / Subtle / Moderate / Strong |
| `PT_SHADOW_OFFSET_X` | Drop shadow horizontal offset in texels |
| `PT_SHADOW_OFFSET_Y` | Drop shadow vertical offset in texels |
| `PT_SHADOW_OPACITY` | Drop shadow strength (0 = off) |
| `PT_VIGNETTE` | Edge darkening (0 = off) |

**Pro** exposes these 15 parameters. `PT_BRIGHTNESS_MODE` and `PT_PALETTE_INTENSITY` move to hidden defaults to make room:

| Parameter | Description |
|---|---|
| `PT_SYSTEM` | System preset — sets the white detection threshold |
| `PT_SENSITIVITY` | Detection threshold when using Manual mode (PT_SYSTEM = 0) |
| `PT_PIXEL_MODE` | White only / Bright / All pixels |
| `PT_BASE_ALPHA` | How transparent detected pixels become |
| `PT_WHITE_TRANSPARENCY` | Minimum transparency boost for confirmed white pixels |
| `PT_PALETTE` | Backing tint — Off / Pocket grey / Cool grey / White / Green-grey |
| `PT_DARK_FILTER_LEVEL` | Softens overly vivid dark colours |
| `PT_PIXEL_BORDER` | LCD dot gap — Off / Subtle / Moderate / Strong |
| `PT_SHADOW_OFFSET_X` | Drop shadow horizontal offset in texels |
| `PT_SHADOW_OFFSET_Y` | Drop shadow vertical offset in texels |
| `PT_SHADOW_OPACITY` | Drop shadow strength (0 = off) |
| `PT_SHADOW_BLUR` | Directional gaussian blur on the shadow (0 = hard edge) |
| `PT_HALATION` | LCD halation glow strength (0 = off) |
| `PT_DITHER` | Bayer dithering at the blend boundary (0 = off, 1 = on) |
| `PT_VIGNETTE` | Edge darkening (0 = off) |

---

<div align="center">

*PT SkyWalker541 by SkyWalker541 | v1.5.2*

</div>
