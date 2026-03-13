# PT SkyWalker541
### Pixel Transparency Shader for RetroArch — Slang Version
**by SkyWalker541 | v1.5.0 | Slang (.slangp) — works on Vulkan / glcore / D3D11 / Metal**

---

On original Game Boy, Game Boy Color, and Game Boy Advance hardware, pixels that were fully off didn't show as white. Because those screens had no backlight driving those areas, the physical backing material showed through instead — a subtle grey-green translucency rather than solid white. Game developers of that era designed around this, using "white" areas as intentional transparent zones for backgrounds, windows, and UI overlays.

On modern displays and emulators, those same pixels render as bright white, which was never the intended look. **PT SkyWalker541** restores the original appearance by detecting bright and white pixels and blending them toward a procedurally generated backing texture — putting the transparency back where it belongs.

This version uses a `.slangp` preset and runs on any RetroArch video driver that supports Slang shaders, including **Vulkan**, **glcore**, **D3D11**, **D3D12**, and **Metal**. White detection runs against the raw unprocessed game frame via RetroArch's built-in `Original` texture semantic, giving cleaner and more accurate results than would otherwise be possible.

> **Looking for the GLSL version?** If you're on a driver that doesn't support Slang (older `gl` driver on some platforms), use `PT_SkyWalker541.glslp` instead. Both versions produce identical output.

> **Looking for more effects?** **PT_SkyWalker541_Pro** adds adjustable grain, LCD halation glow, Bayer dithering, screen curvature, and chromatic fringe — designed for more powerful hardware. Both versions are in the PT_SkyWalker541 repository.

> **On NextUI / minarch?** **PT_SkyWalker541_Aspect** and **PT_SkyWalker541_Integer** are purpose-built versions for NextUI / minarch, with thresholds pre-compensated for NextUI's post-processing pipeline. Both are in the PT_SkyWalker541 repository.

---

```
╔══════════════════════════════════════════════════════════════════╗
║  INSTALLATION                                                    ║
╚══════════════════════════════════════════════════════════════════╝
```

The shader uses two files. Place them in your RetroArch shaders folder:

```
PT_SkyWalker541.slangp
PT_SkyWalker541.slang
```

1. Launch a game
2. Open the RetroArch menu and go to **Quick Menu → Shaders → Load Shader Preset**
3. Select `PT_SkyWalker541.slangp` — **not** the `.slang` file directly
4. Open **Shader Parameters** and set **PT_SYSTEM** to match your target system
5. Apply the recommended settings for that system from the tables below
6. Optionally save via **Save Shader Preset As** for automatic loading on future sessions

---

```
╔══════════════════════════════════════════════════════════════════╗
║  RECOMMENDED SETTINGS PER SYSTEM                                 ║
╚══════════════════════════════════════════════════════════════════╝
```

Set **PT_SYSTEM** first, then apply the core and shader settings for your system below. Each system had meaningfully different display hardware and the right settings make a real difference.

---

```
┌──────────────────────────────────────────────────────────────────┐
│  Game Boy DMG / Game Boy Pocket  —  PT_SYSTEM = 1                │
└──────────────────────────────────────────────────────────────────┘
```

The original DMG and Pocket both used a slow, ghosting LCD with no backlight — ambient light only. The physical backing was a distinctive matte green-grey, visible as a translucent tint through unlit pixels. Pixel response was slow enough that moving sprites produced visible trails, and the boundary between transparent and opaque areas was naturally soft.

> **DMG vs Pocket:** Shader settings are identical for both. The Pocket is slightly cleaner and less green in person, but the difference is minor enough that PT_SYSTEM = 1 covers both accurately. If you prefer a more neutral backing for the Pocket, try PT_PALETTE = 2 (Grey).

**Core settings (Gambatte / SameBoy):**

| Setting | Value |
|---|---|
| Color correction | Disabled |
| Interframe blending | Disabled |
| GB Colorization | Disabled *(see note)* |

> **GB Colorization:** Any colorization palette — Auto, GBC, SGB, Internal, or Custom — shifts pixel values including whites. If you want to use colorization, set **PT_SYSTEM = 0 (Manual)** and lower **PT_SENSITIVITY** until backgrounds go transparent as expected.

**Shader settings:**

| Parameter | Menu label | Value |
|---|---|---|
| PT_SYSTEM | System (0=Manual, 1=GB, 2=GBC, 3=GBA) | 1 (GB) |
| PT_SENSITIVITY |   Manual sensitivity threshold | 0.85 *(default — only active when PT_SYSTEM = 0)* |
| PT_PIXEL_MODE | Pixel mode (0=White, 1=Bright, 2=All) | 0 (White only) |
| PT_BASE_ALPHA |   Base transparency amount | 0.20 |
| PT_WHITE_TRANSPARENCY |   White pixel min transparency | 0.20 |
| PT_BRIGHTNESS_MODE | Brightness mode (0=Simple, 1=Percept.) | 0 (Simple) |
| PT_PALETTE | Background tint (0=Off, 1=Pocket, 2=Grey, 3=White) | 1 (Pocket grey) |
| PT_PALETTE_INTENSITY |   Tint intensity | 1.00 |
| PT_DARK_FILTER_LEVEL | Dark color filter (0=off) | 0 *(off — leave at default for this system)* |
| PT_PIXEL_BORDER | Pixel border (0=Off, 1=Subtle, 2=Med, 3=Strong) | 1 (Subtle) |
| PT_SHADOW_OFFSET_X | Shadow X offset | 2.0 |
| PT_SHADOW_OFFSET_Y | Shadow Y offset | 2.0 |
| PT_SHADOW_OPACITY | Shadow opacity (0=off) | 0.30 |
| PT_CHROMA | Chromatic shift (0=off) | 0.0 |
| PT_VIGNETTE | Vignette strength (0=off) | 0.10 |

---

```
┌──────────────────────────────────────────────────────────────────┐
│  Game Boy Color  —  PT_SYSTEM = 2                                │
└──────────────────────────────────────────────────────────────────┘
```

Similar LCD construction to the original GB but with improved colour response and slightly faster pixel transitions. Still fully reflective with no backlight. The backing material was cleaner and more neutral than the original DMG — Pocket grey still works well but the effect is subtler.

**Core settings (Gambatte / SameBoy):**

| Setting | Value |
|---|---|
| Color correction | GBC Only |
| Interframe blending | Disabled |

**Shader settings:**

| Parameter | Menu label | Value |
|---|---|---|
| PT_SYSTEM | System (0=Manual, 1=GB, 2=GBC, 3=GBA) | 2 (GBC) |
| PT_SENSITIVITY |   Manual sensitivity threshold | 0.85 *(default — only active when PT_SYSTEM = 0)* |
| PT_PIXEL_MODE | Pixel mode (0=White, 1=Bright, 2=All) | 0 (White only) |
| PT_BASE_ALPHA |   Base transparency amount | 0.20 |
| PT_WHITE_TRANSPARENCY |   White pixel min transparency | 0.20 |
| PT_BRIGHTNESS_MODE | Brightness mode (0=Simple, 1=Percept.) | 0 (Simple) |
| PT_PALETTE | Background tint (0=Off, 1=Pocket, 2=Grey, 3=White) | 1 (Pocket grey) |
| PT_PALETTE_INTENSITY |   Tint intensity | 1.00 |
| PT_DARK_FILTER_LEVEL | Dark color filter (0=off) | 10 *(optional — softens aggressive GBC colour palettes)* |
| PT_PIXEL_BORDER | Pixel border (0=Off, 1=Subtle, 2=Med, 3=Strong) | 1 (Subtle) |
| PT_SHADOW_OFFSET_X | Shadow X offset | 2.0 |
| PT_SHADOW_OFFSET_Y | Shadow Y offset | 2.0 |
| PT_SHADOW_OPACITY | Shadow opacity (0=off) | 0.25 |
| PT_CHROMA | Chromatic shift (0=off) | 0.0 |
| PT_VIGNETTE | Vignette strength (0=off) | 0.08 |

---

```
┌──────────────────────────────────────────────────────────────────┐
│  Game Boy Advance SP (front-lit)  —  PT_SYSTEM = 3               │
└──────────────────────────────────────────────────────────────────┘
```

The GBA SP used a front-lit screen — dramatically brighter and more vivid than any earlier Game Boy. Whites are genuinely bright. The transparency effect is subtler here, and the clean white backing makes see-through areas look more like polished glass than the DMG's matte grey.

**Core settings (mGBA):**

| Setting | Value |
|---|---|
| Color correction | Enabled |
| Interframe blending | Enabled |

**Shader settings:**

| Parameter | Menu label | Value |
|---|---|---|
| PT_SYSTEM | System (0=Manual, 1=GB, 2=GBC, 3=GBA SP, 4=GBA Orig) | 3 (GBA SP) |
| PT_SENSITIVITY |   Manual sensitivity threshold | 0.85 *(default — only active when PT_SYSTEM = 0)* |
| PT_PIXEL_MODE | Pixel mode (0=White, 1=Bright, 2=All) | 0 (White only) |
| PT_BASE_ALPHA |   Base transparency amount | 0.15 |
| PT_WHITE_TRANSPARENCY |   White pixel min transparency | 0.45 |
| PT_BRIGHTNESS_MODE | Brightness mode (0=Simple, 1=Percept.) | 1 (Perceptual) |
| PT_PALETTE | Background tint (0=Off, 1=Pocket, 2=Grey, 3=White) | 3 (White) |
| PT_PALETTE_INTENSITY |   Tint intensity | 1.00 |
| PT_DARK_FILTER_LEVEL | Dark color filter (0=off) | 0 *(off — leave at default for this system)* |
| PT_PIXEL_BORDER | Pixel border (0=Off, 1=Subtle, 2=Med, 3=Strong) | 0 (Off) |
| PT_SHADOW_OFFSET_X | Shadow X offset | 2.0 |
| PT_SHADOW_OFFSET_Y | Shadow Y offset | 2.0 |
| PT_SHADOW_OPACITY | Shadow opacity (0=off) | 0.20 |
| PT_CHROMA | Chromatic shift (0=off) | 0.0 |
| PT_VIGNETTE | Vignette strength (0=off) | 0.05 |

---

```
┌──────────────────────────────────────────────────────────────────┐
│  Game Boy Advance Original (no backlight)  —  PT_SYSTEM = 4      │
└──────────────────────────────────────────────────────────────────┘
```

The original GBA had a dim, washed-out reflective screen with no backlight — notoriously difficult to read in poor lighting. Colours were desaturated and whites appeared creamy or yellowish due to the LCD polariser and backing material. The transparency effect is more pronounced here than on any other system.

**Core settings (mGBA):**

| Setting | Value |
|---|---|
| Color correction | Enabled |
| Interframe blending | Enabled |

**Shader settings:**

| Parameter | Menu label | Value |
|---|---|---|
| PT_SYSTEM | System (0=Manual, 1=GB, 2=GBC, 3=GBA SP, 4=GBA Orig) | 4 (GBA Orig) |
| PT_SENSITIVITY |   Manual sensitivity threshold | 0.85 *(default — only active when PT_SYSTEM = 0)* |
| PT_PIXEL_MODE | Pixel mode (0=White, 1=Bright, 2=All) | 0 (White only) |
| PT_BASE_ALPHA |   Base transparency amount | 0.25 |
| PT_WHITE_TRANSPARENCY |   White pixel min transparency | 0.55 |
| PT_BRIGHTNESS_MODE | Brightness mode (0=Simple, 1=Percept.) | 1 (Perceptual) |
| PT_PALETTE | Background tint (0=Off, 1=Pocket, 2=Grey, 3=White) | 2 (Grey) *(original GBA backing was more neutral than the DMG green-grey)* |
| PT_PALETTE_INTENSITY |   Tint intensity | 1.00 |
| PT_DARK_FILTER_LEVEL | Dark color filter (0=off) | 0 *(off — leave at default for this system)* |
| PT_PIXEL_BORDER | Pixel border (0=Off, 1=Subtle, 2=Med, 3=Strong) | 0 (Off) |
| PT_SHADOW_OFFSET_X | Shadow X offset | 2.0 |
| PT_SHADOW_OFFSET_Y | Shadow Y offset | 2.0 |
| PT_SHADOW_OPACITY | Shadow opacity (0=off) | 0.20 |
| PT_CHROMA | Chromatic shift (0=off) | 0.0 |
| PT_VIGNETTE | Vignette strength (0=off) | 0.12 |

---

```
╔══════════════════════════════════════════════════════════════════╗
║  HOW IT WORKS                                                    ║
╚══════════════════════════════════════════════════════════════════╝
```

This is a single-pass shader. It uses RetroArch's built-in `Original` texture semantic, which provides the raw unprocessed input frame directly — no passthrough pass required.

The shader has access to two textures at all times:

- `Source` — the colour-corrected processed frame, used for display output and shadow sampling
- `Original` — the raw pre-correction input frame, used exclusively for white pixel detection and transparency gating

Running detection on pre-correction pixels means thresholds can be accurate values rather than compensated guesses. A white pixel on original hardware is very close to 1.0 before any processing — the shader detects that directly.

---

```
╔══════════════════════════════════════════════════════════════════╗
║  SHADER PARAMETERS                                               ║
╚══════════════════════════════════════════════════════════════════╝
```

All parameters are accessible from **Quick Menu → Shaders → Shader Parameters** after loading the preset. Changes preview live.

---

### System Preset — `PT_SYSTEM`
**Default: 1 (GB)**

The most important setting. Set this first. Configures the white detection threshold tuned for each system's display characteristics.

| Value | System | Threshold |
|---|---|---|
| 0 | Manual | Use PT_SENSITIVITY to set your own threshold |
| 1 | GB / Pocket | 0.90 — no backlight, aggressive detection |
| 2 | GBC | 0.85 — no backlight, moderate |
| 3 | GBA SP (front-lit) | 0.80 — front-lit, conservative |
| 4 | GBA Original | 0.75 — no backlight, catches creamy/yellowish whites |

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
**Default: 0.20 | Range: 0.00 – 1.00**

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
| 2 | Grey | Neutral grey — good for GBC or original GBA |
| 3 | White | Clean white — recommended for GBA SP |

---

### Background Tint Intensity — `PT_PALETTE_INTENSITY`
**Default: 1.00 | Range: 0.00 – 2.00**

Controls how strongly the tint colour is applied. 0 = no tint regardless of PT_PALETTE setting.

---

### Color Harshness Filter — `PT_DARK_FILTER_LEVEL`
**Default: 0 | Range: 0 – 100**

Softens overly vivid or harsh dark colours. Most useful for GBC games with aggressive colour palettes. Runs on the colour-corrected frame — bright pixels are largely unaffected. Set to 0 to disable.

---

### Pixel Border — `PT_PIXEL_BORDER`
**Default: 1 (Subtle)**

Simulates the thin physical gap between individual LCD dots on original hardware. Uses a sine-wave method that works correctly at any scale mode — aspect ratio, integer, or custom.

| Value | Style | Description |
|---|---|---|
| 0 | Off | No pixel border |
| 1 | Subtle | ~17% border darkening — closest to original hardware appearance |
| 2 | Moderate | ~41% border darkening |
| 3 | Strong | ~76% border darkening — clearly defined pixel grid |

---

### Shadow X Offset — `PT_SHADOW_OFFSET_X`
**Default: 2.0 | Range: -10.0 – 10.0**

Horizontal position of the drop shadow. Shadows appear behind solid pixels and are visible through transparent areas, adding subtle depth at sprite and text edges. Default of 1.0 is the smallest visible diagonal shift.

---

### Shadow Y Offset — `PT_SHADOW_OFFSET_Y`
**Default: 2.0 | Range: -10.0 – 10.0**

Vertical position of the drop shadow. Positive = down, negative = up.

---

### Shadow Opacity — `PT_SHADOW_OPACITY`
**Default: 0.30 | Range: 0.00 – 1.00**

How dark the drop shadow is. Set to 0 to disable shadows entirely.

---

### Chromatic Shift — `PT_CHROMA`
**Default: 0.0 | Range: 0.00 – 1.00**

Simulates the slight colour channel misalignment characteristic of original GB/GBC/GBA LCD panels. Pure UV math — zero extra texture samples. Set to 0 to disable.

---

### Vignette — `PT_VIGNETTE`
**Default: 0.08 | Range: 0.00 – 1.00**

Darkens the screen toward the edges and corners, simulating the uneven light distribution of original handheld screens. Pure math — no extra texture samples. Default of 0.08 sits below the threshold of conscious perception. Set to 0 to disable.

---

```
╔══════════════════════════════════════════════════════════════════╗
║  EDITING DEFAULT VALUES                                          ║
╚══════════════════════════════════════════════════════════════════╝
```

To change a default value, open `PT_SkyWalker541.slang` in any text editor and find the `#pragma parameter` block near the top of the file. Each line has this format:

```
#pragma parameter NAME  "Menu label"  default  min  max  step
```

Edit the **default** value (the first number after the label string) on the relevant line. For example, to change the default system preset from GB to GBC:

```glsl
// Before:
#pragma parameter PT_SYSTEM  "System (0=Manual, 1=GB, 2=GBC, 3=GBA SP, 4=GBA Orig)"  1.0  0.0  4.0  1.0

// After (GBC default):
#pragma parameter PT_SYSTEM  "System (0=Manual, 1=GB, 2=GBC, 3=GBA SP, 4=GBA Orig)"  2.0  0.0  4.0  1.0
```

These values load when the preset is first applied and can still be adjusted live from the shader parameters menu at any time.

---

```
╔══════════════════════════════════════════════════════════════════╗
║  COMPATIBILITY                                                   ║
╚══════════════════════════════════════════════════════════════════╝
```

Works on any RetroArch-supported platform and display resolution. The shader works at any scale mode — aspect ratio, integer, or custom — no separate variants required.

Works on any RetroArch video driver that supports Slang shaders: **Vulkan**, **glcore**, **D3D11**, **D3D12**, and **Metal**. Does not work with the legacy **gl** driver — use `PT_SkyWalker541.glslp` for that.

---

```
╔══════════════════════════════════════════════════════════════════╗
║  CHANGELOG                                                       ║
╚══════════════════════════════════════════════════════════════════╝
```

> **Version note:** All PT_SkyWalker541 variants — Standard, Pro, and NextUI — share a unified version number. v1.5.0 represents the same release generation across all three.

| Version | Notes |
|---|---|
| v1.4.0 | Rebuilt as single-pass shader. Passthrough pass removed. RawFrame alias replaced with RetroArch built-in `Original` semantic natively. Resolves "failed to load preset" on Android/Retroid devices. All shader logic, parameters, and visual output identical to v1.3.0 |
| v1.5.0 | Added PT_SYSTEM = 4 (GBA Original) with threshold 0.75, tuned for the original GBA's dim, creamy whites |
| v1.3.0 | Merged Aspect and Integer variants into a single shader. Ported to standard RetroArch GLSL (.glslp). White detection and transparency gating run against raw pre-correction frame for clean accurate thresholds. Thresholds retuned: GB 0.58→0.88, GBC 0.65→0.85, GBA 0.42→0.80 |
| v1.2.2 | Replaced noiseHash with reference shader's cheaper single-pass hash — no visible change to grain quality, lower arithmetic cost per fragment |
| v1.2.1 | Updated defaults to period-authentic values — shadow offset 1.5→1.0, shadow opacity 0.50→0.30, vignette 0.12→0.08 |
| v1.1.6 | Removed shadow blur — single texture tap. At GB/GBC/GBA pixel scales, blur is imperceptible at any typical display resolution |
| v1.1.5 | Replaced 4-tap cross shadow blur with 2-tap diagonal blur |
| v1.1.4 | Fixed Aspect pixel border — wfactor multipliers were inverted |
| v1.1.3 | Fixed shadow performance — removed redundant texel re-snapping |
| v1.1.2 | Fixed pixel border precision on mediump hardware. Fixed shadows in large white fills |
| v1.1.1 | Fixed shadow texel snapping. Fixed pixel border sine-wave values |
| v1.1.0 | Split into Aspect and Integer variants. Shadow formula rewritten |
| v1.0.9 | Fixed PT_PIXEL_BORDER modes 2 and 3 |
| v1.0.8 | Replaced sin()-based noise hash — significant speedup |
| v1.0.7 | Chromatic shift rewritten as pure math |
| v1.0.6 | Replaced subpixel fringing with chromatic shift |
| v1.0.5 | Added chromatic shift and vignette |
| v1.0.4 | Shadow blur upgraded to weighted 4-tap |
| v1.0.3 | Removed all ON/OFF toggle parameters |
| v1.0.2 | Added PT_PIXEL_BORDER |
| v1.0.1 | Replaced adaptive white detection with dual-channel method |
| v1.0.0 | Initial release |

---

*PT SkyWalker541 by SkyWalker541 | Written for RetroArch*
