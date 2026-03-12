# PT SkyWalker541
### Pixel Transparency Shader for NextUI / minarch
**by SkyWalker541 | v1.5.0 | TrimUI Brick — NextUI custom firmware**

---

On original Game Boy, Game Boy Color, and Game Boy Advance hardware, pixels that were fully off didn't show as white. Because those screens had no backlight driving those areas, the physical backing material showed through instead — a subtle grey-green translucency rather than solid white. Game developers of that era designed around this, using "white" areas as intentional transparent zones for backgrounds, windows, and UI overlays.

On modern displays and emulators, those same pixels render as bright white, which was never the intended look. **PT SkyWalker541** restores the original appearance by detecting bright and white pixels and blending them toward a procedurally generated backing texture — putting the transparency back where it belongs.

Both shaders are standalone. No additional passes or files are required beyond the `.glsl` and `.cfg` pair for your chosen variant.

> **Using RetroArch?** **PT_SkyWalker541** (standard) and **PT_SkyWalker541_Pro** (feature-rich) are RetroArch versions of this shader supporting GLSL and Slang, with dedicated presets for gl, glcore, Vulkan, D3D11, and Metal drivers. Both are in the PT_SkyWalker541 repository.

---

```
╔══════════════════════════════════════════════════════════════════╗
║  WHICH VARIANT SHOULD I USE?                                     ║
╚══════════════════════════════════════════════════════════════════╝
```

| File | Use when |
|---|---|
| `PT_SkyWalker541_Aspect.glsl` | Aspect ratio scaling or any non-integer scale mode |
| `PT_SkyWalker541_Integer.glsl` | Native / integer scaling only |

The difference is entirely in how the **pixel border** effect works. Both variants are otherwise identical — same parameters, same detection logic, same transparency blending, shadows, and all other effects.

> **Aspect variant** — pixel border uses a sine-wave grid method. Works correctly at any scale mode including aspect ratio and non-integer scaling.

> **Integer variant** — pixel border uses a distance-from-center method (based on the zfast_lcd equation). Produces a sharper, cleaner grid but only looks correct at exact integer scale multiples. At native integer scale the grid is particularly crisp — consider pushing to mode 2 or 3.

**If you are unsure, use the Aspect variant** — it works correctly at any scale mode.

---

```
╔══════════════════════════════════════════════════════════════════╗
║  INSTALLATION                                                    ║
╚══════════════════════════════════════════════════════════════════╝
```

Each variant is two files — a `.glsl` shader and a `.cfg` preset that loads it.

```
PT_SkyWalker541_Aspect.glsl
PT_SkyWalker541_Aspect.cfg

PT_SkyWalker541_Integer.glsl
PT_SkyWalker541_Integer.cfg
```

1. Place all four files in your NextUI shaders folder
2. Launch a game and open the in-game shader menu
3. Load the `.cfg` for your chosen variant — **not** the `.glsl` file directly
4. Open shader settings and set **PT_SYSTEM** to match your target system
5. Apply the recommended settings for that system from the tables below

---

```
╔══════════════════════════════════════════════════════════════════╗
║  RECOMMENDED SETTINGS PER SYSTEM                                 ║
╚══════════════════════════════════════════════════════════════════╝
```

Set **PT_SYSTEM** first, then apply the device and shader settings for your system below. These are the settings used for the sample screenshots and verified on TrimUI Brick.

> **Important — Dark Filter Level:** Always set the device Dark Filter Level to **0** and use the shader's own **PT_DARK_FILTER_LEVEL** parameter instead. Running both at once doubles the effect.

---

```
┌──────────────────────────────────────────────────────────────────┐
│  Game Boy DMG / Game Boy Pocket  —  PT_SYSTEM = 1                │
└──────────────────────────────────────────────────────────────────┘
```

The original DMG and Pocket both used a slow, ghosting LCD with no backlight — ambient light only. The physical backing was a distinctive matte green-grey, visible as a translucent tint through unlit pixels.

> **GB Colorization:** Any colorization palette — Auto, GBC, SGB, Internal, or Custom — shifts pixel values including whites. If you want to use colorization, set **PT_SYSTEM = 0 (Manual)** and lower **PT_SENSITIVITY** gradually until backgrounds go transparent as expected.

**Device settings:**

| Setting | Value |
|---|---|
| Scale mode | Aspect or Integer |
| Screen effect | None |
| Color correction | Disabled |
| Frontlight position | Central |
| Dark filter level | 0 |
| Interframe blending | Disabled |
| GB Colorization | Disabled *(see note above)* |

**Shader settings:**

| Parameter | Value |
|---|---|
| PT_SYSTEM | 1 (GB) |
| PT_SENSITIVITY | 0.85 *(default — only active when PT_SYSTEM = 0)* |
| PT_PIXEL_MODE | 0 (White only) |
| PT_BASE_ALPHA | 0.20 |
| PT_WHITE_TRANSPARENCY | 0.50 |
| PT_BRIGHTNESS_MODE | 0 (Simple) |
| PT_PALETTE | 1 (Pocket grey) |
| PT_PALETTE_INTENSITY | 1.00 |
| PT_DARK_FILTER_LEVEL | 10 |
| PT_PIXEL_BORDER | 1 (Subtle) |
| PT_SHADOW_OFFSET_X | 1.0 |
| PT_SHADOW_OFFSET_Y | 1.0 |
| PT_SHADOW_OPACITY | 0.30 |
| PT_CHROMA | 0.20 |
| PT_VIGNETTE | 0.08 |

---

```
┌──────────────────────────────────────────────────────────────────┐
│  Game Boy Color  —  PT_SYSTEM = 2                                │
└──────────────────────────────────────────────────────────────────┘
```

Similar LCD construction to the original GB but with improved colour response and slightly faster pixel transitions. Still fully reflective with no backlight. The backing material was cleaner and more neutral than the DMG.

**Device settings:**

| Setting | Value |
|---|---|
| Scale mode | Aspect or Integer |
| Screen effect | None |
| Color correction | GBC Only |
| Frontlight position | Central |
| Dark filter level | 0 |
| Interframe blending | Disabled |

**Shader settings:**

| Parameter | Value |
|---|---|
| PT_SYSTEM | 2 (GBC) |
| PT_SENSITIVITY | 0.85 *(default — only active when PT_SYSTEM = 0)* |
| PT_PIXEL_MODE | 0 (White only) |
| PT_BASE_ALPHA | 0.20 |
| PT_WHITE_TRANSPARENCY | 0.50 |
| PT_BRIGHTNESS_MODE | 0 (Simple) |
| PT_PALETTE | 1 (Pocket grey) |
| PT_PALETTE_INTENSITY | 1.00 |
| PT_DARK_FILTER_LEVEL | 10 *(softens aggressive GBC colour palettes)* |
| PT_PIXEL_BORDER | 1 (Subtle) |
| PT_SHADOW_OFFSET_X | 1.0 |
| PT_SHADOW_OFFSET_Y | 1.0 |
| PT_SHADOW_OPACITY | 0.30 |
| PT_CHROMA | 0.20 |
| PT_VIGNETTE | 0.08 |

---

```
┌──────────────────────────────────────────────────────────────────┐
│  Game Boy Advance SP (front-lit)  —  PT_SYSTEM = 3               │
└──────────────────────────────────────────────────────────────────┘
```

The GBA SP used a front-lit screen — dramatically brighter and more vivid than any earlier Game Boy. Whites are genuinely bright, and the transparency effect is subtler here.

**Device settings:**

| Setting | Value |
|---|---|
| Scale mode | Aspect or Integer |
| Screen effect | None |
| Color correction | Enabled |
| Interframe blending | Enabled |

**Shader settings:**

| Parameter | Value |
|---|---|
| PT_SYSTEM | 3 (GBA SP) |
| PT_SENSITIVITY | 0.85 *(default — only active when PT_SYSTEM = 0)* |
| PT_PIXEL_MODE | 0 (White only) |
| PT_BASE_ALPHA | 0.15 |
| PT_WHITE_TRANSPARENCY | 0.45 |
| PT_BRIGHTNESS_MODE | 1 (Perceptual) |
| PT_PALETTE | 3 (White) |
| PT_PALETTE_INTENSITY | 1.00 |
| PT_DARK_FILTER_LEVEL | 0 |
| PT_PIXEL_BORDER | 0 (Off) |
| PT_SHADOW_OFFSET_X | 1.0 |
| PT_SHADOW_OFFSET_Y | 1.0 |
| PT_SHADOW_OPACITY | 0.20 |
| PT_CHROMA | 0.10 |
| PT_VIGNETTE | 0.05 |

---

```
┌──────────────────────────────────────────────────────────────────┐
│  Game Boy Advance Original (no backlight)  —  PT_SYSTEM = 4      │
└──────────────────────────────────────────────────────────────────┘
```

The original GBA had a dim, washed-out reflective screen with no backlight. Colours were desaturated and whites appeared creamy or yellowish due to the LCD polariser and backing material. The transparency effect is more pronounced here than on any other system.

> **Threshold note:** PT_SYSTEM = 4 uses a threshold of 0.38, estimated from the established NextUI post-processing offset pattern. If too many near-white pixels are being missed, switch to **PT_SYSTEM = 0 (Manual)** and lower **PT_SENSITIVITY** gradually until backgrounds go transparent as expected.

**Device settings:**

| Setting | Value |
|---|---|
| Scale mode | Aspect or Integer |
| Screen effect | None |
| Color correction | Enabled |
| Interframe blending | Enabled |

**Shader settings:**

| Parameter | Value |
|---|---|
| PT_SYSTEM | 4 (GBA Orig) |
| PT_SENSITIVITY | 0.85 *(default — only active when PT_SYSTEM = 0)* |
| PT_PIXEL_MODE | 0 (White only) |
| PT_BASE_ALPHA | 0.25 |
| PT_WHITE_TRANSPARENCY | 0.55 |
| PT_BRIGHTNESS_MODE | 1 (Perceptual) |
| PT_PALETTE | 2 (Grey) *(original GBA backing was more neutral than the DMG green-grey)* |
| PT_PALETTE_INTENSITY | 1.00 |
| PT_DARK_FILTER_LEVEL | 0 |
| PT_PIXEL_BORDER | 0 (Off) |
| PT_SHADOW_OFFSET_X | 1.0 |
| PT_SHADOW_OFFSET_Y | 1.0 |
| PT_SHADOW_OPACITY | 0.20 |
| PT_CHROMA | 0.10 |
| PT_VIGNETTE | 0.12 |

---

```
╔══════════════════════════════════════════════════════════════════╗
║  SHADER PARAMETERS                                               ║
╚══════════════════════════════════════════════════════════════════╝
```

All parameters are the same between both shader variants. They are accessible from the in-game shader settings menu after loading the preset. Changes apply live.

---

### System Preset — `PT_SYSTEM`
**Default: 1 (GB)**

The most important setting. Set this first. Configures the white detection threshold tuned for each system's display characteristics. Thresholds are pre-compensated for post-processing on NextUI.

| Value | System | Threshold |
|---|---|---|
| 0 | Manual | Use PT_SENSITIVITY to set your own threshold |
| 1 | GB / Pocket | 0.58 — no backlight, aggressive detection |
| 2 | GBC | 0.65 — no backlight, moderate |
| 3 | GBA SP (front-lit) | 0.42 — front-lit, conservative |
| 4 | GBA Original | 0.38 — no backlight, catches creamy/yellowish whites |

---

### Detection Sensitivity — `PT_SENSITIVITY`
**Default: 0.85 | Range: 0.10 – 1.00 | Manual mode only**

Only active when PT_SYSTEM = 0. Has no effect when using a system preset.

- **Higher values** — only very obvious, clearly white pixels go transparent
- **Lower values** — more pixels are treated as white and go transparent

---

### Transparency Mode — `PT_PIXEL_MODE`
**Default: 0 (White only)**

| Value | Mode | Description |
|---|---|---|
| 0 | White only | Only white and near-white pixels go transparent — most authentic |
| 1 | Bright | Brighter pixels become proportionally more transparent |
| 2 | All | Every pixel blends toward the backing texture |

Mode 0 is recommended for the most accurate look.

---

### Base Transparency — `PT_BASE_ALPHA`
**Default: 0.20 | Range: 0.00 – 1.00**

Controls how transparent detected pixels become. Lower = more opaque, higher = more see-through.

---

### White Pixel Transparency Boost — `PT_WHITE_TRANSPARENCY`
**Default: 0.50 | Range: 0.00 – 1.00**

Sets a minimum transparency level specifically for confirmed white pixels. Ensures clearly white pixels are always at least this transparent, regardless of PT_BASE_ALPHA.

---

### Brightness Mode — `PT_BRIGHTNESS_MODE`
**Default: 0 (Simple)**

| Value | Mode | Best for |
|---|---|---|
| 0 | Simple | Equal average of R, G, B — good for GB/GBC |
| 1 | Perceptual | Human vision weighted (ITU-R BT.709) — good for GBA and colour content |

---

### Background Tint — `PT_PALETTE`
**Default: 1 (Pocket)**

Tints the procedural backing texture visible through transparent pixels.

| Value | Tint | Description |
|---|---|---|
| 0 | Off | Neutral grey grain |
| 1 | Pocket grey | Warm green-grey — approximates the original DMG/Pocket screen backing |
| 2 | Grey | Neutral grey — good for GBC |
| 3 | White | Clean white — recommended for GBA |

---

### Background Tint Intensity — `PT_PALETTE_INTENSITY`
**Default: 1.00 | Range: 0.00 – 2.00**

Controls how strongly the tint colour is applied. 0 = no tint regardless of PT_PALETTE setting.

---

### Color Harshness Filter — `PT_DARK_FILTER_LEVEL`
**Default: 10 | Range: 0 – 100**

Softens overly vivid or harsh dark colours. Most useful for GBC games with aggressive colour palettes. Runs on the colour-corrected frame — bright pixels are largely unaffected. Set to 0 to disable.

> Set the device's own Dark Filter Level to 0 and use this parameter instead — running both simultaneously doubles the effect.

---

### Pixel Border — `PT_PIXEL_BORDER`
**Default: 1 (Subtle)**

Simulates the thin physical gap between individual LCD dots on original hardware. The Aspect and Integer variants use different methods internally, each optimised for their respective scale mode.

| Value | Style | Description |
|---|---|---|
| 0 | Off | No pixel border |
| 1 | Subtle | ~17% border darkening — closest to original hardware appearance |
| 2 | Moderate | ~41% border darkening |
| 3 | Strong | ~76% border darkening — clearly defined pixel grid |

> **Integer variant tip:** At native/integer scaling the pixel grid is particularly sharp. Consider mode 2 or 3 for a more visible grid effect.

---

### Shadow X Offset — `PT_SHADOW_OFFSET_X`
**Default: 1.0 | Range: -30.0 – 30.0**

Horizontal position of the drop shadow. Shadows appear behind solid pixels and are visible through transparent areas, adding subtle depth at sprite and text edges. Default of 1.0 is the smallest visible diagonal shift.

---

### Shadow Y Offset — `PT_SHADOW_OFFSET_Y`
**Default: 1.0 | Range: -30.0 – 30.0**

Vertical position of the drop shadow. Positive = down, negative = up.

---

### Shadow Opacity — `PT_SHADOW_OPACITY`
**Default: 0.30 | Range: 0.00 – 1.00**

How dark the drop shadow is. Set to 0 to disable shadows entirely.

---

### Chromatic Shift — `PT_CHROMA`
**Default: 0.20 | Range: 0.00 – 1.00**

Simulates the slight colour channel misalignment characteristic of original GB/GBC/GBA LCD panels. Pure UV math — zero extra texture samples. Set to 0 to disable.

---

### Vignette — `PT_VIGNETTE`
**Default: 0.08 | Range: 0.00 – 1.00**

Darkens the screen toward the edges and corners, simulating the uneven light distribution of original handheld screens. Pure math — no extra texture samples. Default of 0.08 sits below the threshold of conscious perception. Set to 0 to disable.

---

```
╔══════════════════════════════════════════════════════════════════╗
║  HOW IT WORKS                                                    ║
╚══════════════════════════════════════════════════════════════════╝
```

Both shaders are single-pass. White detection and transparency blending run on the same frame — no passthrough pass required.

White detection uses a dual-channel ratio method: a pixel must be both bright (above the system threshold) and neutral (low variation across R, G, B channels). This naturally rejects pixels that appear bright only due to color correction processing, which tends to shift channel values unevenly.

Detection runs against the post-processed texture. Thresholds are pre-compensated to account for this — a raw white pixel on original hardware would be near 1.0, but after color correction it lands lower. Per-system thresholds are tuned to that post-correction range: GB 0.58, GBC 0.65, GBA SP 0.42, GBA Original 0.38.

When NextUI adds OrigTexture support, these shaders will be updated to run detection on the raw pre-correction frame — matching the RetroArch version's architecture. This is a planned architectural change: the per-system threshold compensation logic will be replaced wholesale with the RetroArch approach, and thresholds will be retuned to raw pixel values. It is not a minor patch.

---

```
╔══════════════════════════════════════════════════════════════════╗
║  EDITING DEFAULT VALUES                                          ║
╚══════════════════════════════════════════════════════════════════╝
```

To change a default value, open either `.glsl` file in any text editor and find this block:

```glsl
#define PT_SYSTEM             1.0
#define PT_SENSITIVITY        0.85
#define PT_PIXEL_MODE         0.0
#define PT_BASE_ALPHA         0.20
#define PT_WHITE_TRANSPARENCY 0.50
#define PT_BRIGHTNESS_MODE    0.0
#define PT_PALETTE            1.0
#define PT_PALETTE_INTENSITY  1.0
#define PT_DARK_FILTER_LEVEL  10.0
#define PT_PIXEL_BORDER       1.0
#define PT_SHADOW_OFFSET_X    1.0
#define PT_SHADOW_OFFSET_Y    1.0
#define PT_SHADOW_OPACITY     0.30
#define PT_CHROMA             0.20
#define PT_VIGNETTE           0.08
```

Change the number on the right of any line to set a new default. These values load when the preset is first applied and can still be adjusted live from the shader settings menu at any time.

---

```
╔══════════════════════════════════════════════════════════════════╗
║  COMPATIBILITY                                                   ║
╚══════════════════════════════════════════════════════════════════╝
```

Both shaders are written for **NextUI / minarch** on the **TrimUI Brick**. Shadow offsets and pixel borders are calculated using coordinate methods proven on NextUI — they work correctly at any device resolution and scale mode.

The shaders use only `Texture` / `Source` as input. They do not require `OrigTexture` or multipass support.

---

```
╔══════════════════════════════════════════════════════════════════╗
║  BEFORE & AFTER                                                  ║
╚══════════════════════════════════════════════════════════════════╝
```

> All screenshots taken on TrimUI Brick running NextUI with `PT_SkyWalker541_Aspect.glsl` using aspect ratio scaling.

---

### Game Boy — Gargoyle's Quest *(Capcom, 1990)*

| Without Shader | With Shader |
|:---:|:---:|
| ![Gargoyle's Quest without shader](https://github.com/SkyWalker541/PT-SkyWalker541-Low-GPU-Cost-Pixel-Transparency-Shader/blob/main/Sample%20Screenshots/Gargoyle's%20Quest.2026-03-07-12-05-31.png) | ![Gargoyle's Quest with shader](https://github.com/SkyWalker541/PT-SkyWalker541-Low-GPU-Cost-Pixel-Transparency-Shader/blob/main/Sample%20Screenshots/Gargoyle's%20Quest.2026-03-07-12-05-19.png) |

<details>
<summary>Settings used</summary>

**Device settings**
| Setting | Value |
|---|---|
| Scale mode | Aspect |
| Screen effect | None |
| Color correction | Disabled |
| Frontlight position | Central |
| Dark filter level | 0 |
| Interframe blending | Disabled |
| GB Colorization | Disabled |

**Shader settings**
| Parameter | Value |
|---|---|
| PT_SYSTEM | 1 (GB) |
| PT_PIXEL_MODE | 0 (White only) |
| PT_PALETTE | 1 (Pocket) |
| PT_PIXEL_BORDER | 1 (Subtle) |
| PT_DARK_FILTER_LEVEL | 10 |
| PT_SHADOW_OFFSET_X | 1.0 |
| PT_SHADOW_OFFSET_Y | 1.0 |
| PT_SHADOW_OPACITY | 0.30 |
| PT_VIGNETTE | 0.08 |
| All others | Default |

</details>

---

### Game Boy Color — Dragon Warrior Monsters *(Enix, 1998)*

| Without Shader | With Shader |
|:---:|:---:|
| ![Dragon Warrior Monsters without shader](https://github.com/SkyWalker541/PT-SkyWalker541-Low-GPU-Cost-Pixel-Transparency-Shader/blob/main/Sample%20Screenshots/Dragon%20Warrior%20Monsters.2026-03-07-12-09-02.png) | ![Dragon Warrior Monsters with shader](https://github.com/SkyWalker541/PT-SkyWalker541-Low-GPU-Cost-Pixel-Transparency-Shader/blob/main/Sample%20Screenshots/Dragon%20Warrior%20Monsters.2026-03-07-12-08-55.png) |

<details>
<summary>Settings used</summary>

**Device settings**
| Setting | Value |
|---|---|
| Scale mode | Aspect |
| Screen effect | None |
| Color correction | GBC Only |
| Frontlight position | Central |
| Dark filter level | 0 |
| Interframe blending | Disabled |

**Shader settings**
| Parameter | Value |
|---|---|
| PT_SYSTEM | 2 (GBC) |
| PT_PIXEL_MODE | 0 (White only) |
| PT_PALETTE | 1 (Pocket) |
| PT_PIXEL_BORDER | 1 (Subtle) |
| PT_DARK_FILTER_LEVEL | 10 |
| PT_SHADOW_OFFSET_X | 1.0 |
| PT_SHADOW_OFFSET_Y | 1.0 |
| PT_SHADOW_OPACITY | 0.30 |
| PT_VIGNETTE | 0.08 |
| All others | Default |

</details>

---

### Game Boy Advance — Castlevania: Aria of Sorrow *(Konami, 2003)*

| Without Shader | With Shader |
|:---:|:---:|
| ![Aria of Sorrow without shader](https://github.com/SkyWalker541/PT-SkyWalker541-Low-GPU-Cost-Pixel-Transparency-Shader/blob/main/Sample%20Screenshots/Castlevania%20-%20Aria%20of%20Sorrow.2026-03-07-12-12-12.png) | ![Aria of Sorrow with shader](https://github.com/SkyWalker541/PT-SkyWalker541-Low-GPU-Cost-Pixel-Transparency-Shader/blob/main/Sample%20Screenshots/Castlevania%20-%20Aria%20of%20Sorrow.2026-03-07-12-12-02.png) |

<details>
<summary>Settings used</summary>

**Device settings**
| Setting | Value |
|---|---|
| Scale mode | Aspect |
| Screen effect | None |
| Color correction | Enabled |
| Interframe blending | Enabled |

**Shader settings**
| Parameter | Value |
|---|---|
| PT_SYSTEM | 3 (GBA SP) |
| PT_PIXEL_MODE | 0 (White only) |
| PT_PALETTE | 3 (White) |
| PT_PIXEL_BORDER | 0 (Off) |
| PT_DARK_FILTER_LEVEL | 0 |
| PT_BRIGHTNESS_MODE | 1 (Perceptual) |
| PT_SHADOW_OFFSET_X | 1.0 |
| PT_SHADOW_OFFSET_Y | 1.0 |
| PT_SHADOW_OPACITY | 0.20 |
| PT_VIGNETTE | 0.05 |
| All others | Default |

</details>

---

```
╔══════════════════════════════════════════════════════════════════╗
║  CHANGELOG                                                       ║
╚══════════════════════════════════════════════════════════════════╝
```

> **Version note:** All PT_SkyWalker541 variants — Standard, Pro, and NextUI — share a unified version number. v1.5.0 represents the same release generation across all three.

| Version | Notes |
|---|---|
| v1.5.0 | Unified version number across all PT_SkyWalker541 variants (Standard, Pro, NextUI). Added cross-references between variant READMEs. Strengthened OrigTexture forward-reference to clarify planned architectural scope |
| v1.3.0 | Added PT_SYSTEM = 4 (GBA Original, threshold 0.38) tuned for the original GBA's dim, creamy whites on NextUI. PT_BRIGHTNESS_MODE default changed from Perceptual (1) to Simple (0) — cheaper on PowerVR, correct for GB/GBC out of the box. Fixed pixel border alignment — `pixelBorderFactor` now receives the snapped texel-centre coordinate, removing half-texel misalignment across both variants |
| v1.2.2 | Replaced noiseHash with reference shader's cheaper single-pass hash — no visible change to grain quality, lower arithmetic cost per fragment |
| v1.2.1 | Updated defaults to period-authentic values — shadow offset 1.5→1.0, shadow opacity 0.50→0.30, vignette 0.12→0.08 |
| v1.1.6 | Removed shadow blur entirely — single texture tap. At GB/GBC/GBA pixel scales, blur is imperceptible at any typical display resolution |
| v1.1.5 | Replaced 4-tap cross shadow blur with 2-tap diagonal blur |
| v1.1.4 | Fixed Aspect pixel border — wfactor multipliers were inverted, producing near-invisible borders. Subtle/Moderate/Strong now produce 17%/41%/76% darkening |
| v1.1.3 | Fixed shadow performance — blur tap re-snapping removed, replaced with direct texel-step offsets |
| v1.1.2 | Fixed Aspect pixel border — fract() applied before sine argument to prevent mediump precision loss on PowerVR. Fixed shadows — removed white-pixel gate that blocked shadows inside large white fills |
| v1.1.1 | Fixed drop shadows — all shadow taps now snap to texel centre. Fixed Aspect pixel border — sine-wave wfactor values corrected |
| v1.1.0 | Split into Aspect and Integer variants. Pixel border and shadow methods rewritten using proven NextUI coordinate approach |
| v1.0.9 | Fixed PT_PIXEL_BORDER modes 2 and 3. PT_VIGNETTE default lowered to 0.12 |
| v1.0.8 | Replaced sin()-based noise hash — significant speedup on PowerVR |
| v1.0.7 | Chromatic shift rewritten as pure math — fixes pink tint, eliminates slowdown |
| v1.0.6 | Replaced subpixel fringing with chromatic shift |
| v1.0.5 | Added chromatic shift and vignette |
| v1.0.4 | Shadow blur upgraded to weighted 4-tap with exponential falloff |
| v1.0.3 | Removed all ON/OFF toggle parameters |
| v1.0.2 | Added PT_PIXEL_BORDER |
| v1.0.1 | Replaced adaptive white detection with lightweight dual-channel method |
| v1.0.0 | Initial release |

---

*PT SkyWalker541 by SkyWalker541 | Written for NextUI*
