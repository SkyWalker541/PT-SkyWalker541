# PT SkyWalker541 Pro
### Pixel Transparency Shader for RetroArch — Slang Pro Version
**by SkyWalker541 | v1.5.1 | Slang (.slangp) — works on Vulkan / glcore / D3D11 / Metal**

---

On original Game Boy, Game Boy Color, and Game Boy Advance hardware, pixels that were fully off didn't show as white. Because those screens had no backlight driving those areas, the physical backing material showed through instead — a subtle grey-green translucency rather than solid white. Game developers of that era designed around this, using "white" areas as intentional transparent zones for backgrounds, windows, and UI overlays.

On modern displays and emulators, those same pixels render as bright white, which was never the intended look. **PT SkyWalker541 Pro** restores the original appearance with a full suite of hardware-accurate effects, targeting powerful handhelds and PC.

> **Looking for the lighter version?** `PT_SkyWalker541.slangp` is a simpler shader without shadow blur, halation, dithering, or curvature — better suited to modest hardware. Both versions are in the PT_SkyWalker541 repository.

> **On NextUI / minarch?** **PT_SkyWalker541_Aspect** and **PT_SkyWalker541_Integer** are purpose-built versions for NextUI / minarch. Both are in the PT_SkyWalker541 repository.

> **Looking for the GLSL version?** Use `PT_SkyWalker541_Pro.glslp` if your RetroArch video driver is set to gl. Both versions produce identical output.

---

```
╔══════════════════════════════════════════════════════════════════╗
║  INSTALLATION                                                    ║
╚══════════════════════════════════════════════════════════════════╝
```

Place both files in the same folder inside your RetroArch shaders directory:

```
PT_SkyWalker541_Pro.slangp
PT_SkyWalker541_Pro.slang
```

1. Launch a game
2. Open the RetroArch menu and go to **Quick Menu → Shaders → Load Shader Preset**
3. Select `PT_SkyWalker541_Pro.slangp` — **not** the `.slang` file directly
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

The original DMG and Pocket both used a very slow, ghosting LCD with no backlight — ambient light only. The physical backing was a distinctive matte green-grey, visible as a translucent tint through unlit pixels. Pixel response was slow enough that moving sprites produced visible trails, and the boundary between transparent and opaque areas was naturally dithered by the panel's response time.

> **DMG vs Pocket:** Shader settings are identical for both. The Pocket is slightly cleaner and less green in person, but the difference is minor enough that PT_SYSTEM = 1 covers both accurately. If you prefer a more neutral backing for the Pocket, try PT_PALETTE = 2 (Grey) and reduce PT_GRAIN_INTENSITY slightly to ~0.07.

**Core settings (Gambatte / SameBoy):**

| Setting | Value |
|---|---|
| Color correction | Disabled |
| Interframe blending | Disabled |
| GB Colorization | Disabled *(see note)* |

> **GB Colorization:** Any colorization palette — Auto, GBC, SGB, Internal, or Custom — shifts pixel values including whites. If you want to use colorization, set **PT_SYSTEM = 0 (Manual)** and lower **PT_SENSITIVITY** until backgrounds go transparent as expected.

**Shader settings:**

> Parameters marked are in the **Advanced Defaults** `#define` block near the top of the `.slang` file — not in the RetroArch menu.

| Parameter | Menu label | Value |
|---|---|---|
| PT_SYSTEM | System (0=Manual, 1=GB, 2=GBC, 3=GBA SP, 4=GBA Orig) | 1 (GB) |
| PT_SENSITIVITY |   Manual threshold (PT_SYSTEM=0 only) | 0.85 *(default — only active when PT_SYSTEM = 0)* |
| PT_PIXEL_MODE | Pixel mode (0=White only, 1=Bright, 2=All) | 0 (White only) |
| PT_BASE_ALPHA |   Base transparency amount | 0.20 |
| PT_WHITE_TRANSPARENCY |   White pixel min transparency | 0.50 |
| PT_BRIGHTNESS_MODE | Brightness mode (0=Simple, 1=Perceptual) | 0 (Simple) |
| PT_PALETTE | Background tint (0=Off, 1=Pocket, 2=Grey, 3=White, 4=Green-grey) | 1 (Pocket grey) |
| PT_PALETTE_INTENSITY |   Tint intensity | 1.00 |
| PT_DARK_FILTER_LEVEL | Dark color filter (0=off) | 0 *(off — leave at default for this system)* |
| PT_GRAIN_INTENSITY |   Grain intensity (0=flat) | 0.10 |
| PT_GRAIN_SCALE |   Grain scale (lower=finer) | 0.30 |
| PT_PIXEL_BORDER | Pixel border (0=Off, 1=Subtle, 2=Med, 3=Strong) | 1 (Subtle) |
| PT_SHADOW_OFFSET_X | Shadow X offset (texels) | 1.0 |
| PT_SHADOW_OFFSET_Y | Shadow Y offset (texels) | 1.0 |
| PT_SHADOW_OPACITY | Shadow opacity (0=off) | 0.30 |
| PT_SHADOW_BLUR | Shadow blur (0=off) | 1.0 |
| PT_SHADOW_BLUR_RADIUS |   Shadow blur radius (texels) | 1.0 |
| PT_HALATION | Halation / diffuser glow (0=off) | 0.0 *(off — no backlight, no diffuser glow)* |
| PT_DITHER | Dither blend edges (0=off, 1=on) | 1.0 |
| PT_DITHER_STRENGTH |   Dither strength | 0.06 |
| PT_DITHER_MATRIX |   Dither matrix (0=2x2, 1=4x4, 2=8x8) | 1 (4×4) |
| PT_CURVATURE | Screen curvature (0=off) | 0.0 *(GB screen was flat)* |
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

> Parameters marked are in the **Advanced Defaults** `#define` block near the top of the `.slang` file — not in the RetroArch menu.

| Parameter | Menu label | Value |
|---|---|---|
| PT_SYSTEM | System (0=Manual, 1=GB, 2=GBC, 3=GBA SP, 4=GBA Orig) | 2 (GBC) |
| PT_SENSITIVITY |   Manual threshold (PT_SYSTEM=0 only) | 0.85 *(default — only active when PT_SYSTEM = 0)* |
| PT_PIXEL_MODE | Pixel mode (0=White only, 1=Bright, 2=All) | 0 (White only) |
| PT_BASE_ALPHA |   Base transparency amount | 0.20 |
| PT_WHITE_TRANSPARENCY |   White pixel min transparency | 0.50 |
| PT_BRIGHTNESS_MODE | Brightness mode (0=Simple, 1=Perceptual) | 0 (Simple) |
| PT_PALETTE | Background tint (0=Off, 1=Pocket, 2=Grey, 3=White, 4=Green-grey) | 1 (Pocket grey) |
| PT_PALETTE_INTENSITY |   Tint intensity | 1.00 |
| PT_GRAIN_INTENSITY |   Grain intensity (0=flat) | 0.07 |
| PT_GRAIN_SCALE |   Grain scale (lower=finer) | 0.25 |
| PT_DARK_FILTER_LEVEL | Dark color filter (0=off) | 10 *(optional — softens aggressive GBC colour palettes)* |
| PT_PIXEL_BORDER | Pixel border (0=Off, 1=Subtle, 2=Med, 3=Strong) | 1 (Subtle) |
| PT_SHADOW_OFFSET_X | Shadow X offset (texels) | 1.0 |
| PT_SHADOW_OFFSET_Y | Shadow Y offset (texels) | 1.0 |
| PT_SHADOW_OPACITY | Shadow opacity (0=off) | 0.25 |
| PT_SHADOW_BLUR | Shadow blur (0=off) | 1.0 |
| PT_SHADOW_BLUR_RADIUS |   Shadow blur radius (texels) | 1.0 |
| PT_HALATION | Halation / diffuser glow (0=off) | 0.0 *(off — no backlight, no diffuser glow)* |
| PT_DITHER | Dither blend edges (0=off, 1=on) | 1.0 |
| PT_DITHER_STRENGTH |   Dither strength | 0.04 |
| PT_DITHER_MATRIX |   Dither matrix (0=2x2, 1=4x4, 2=8x8) | 1 (4×4) |
| PT_CURVATURE | Screen curvature (0=off) | 0.0 *(GBC screen was flat)* |
| PT_CHROMA | Chromatic shift (0=off) | 0.0 |
| PT_VIGNETTE | Vignette strength (0=off) | 0.08 |

---

```
┌──────────────────────────────────────────────────────────────────┐
│  Game Boy Advance SP (front-lit)  —  PT_SYSTEM = 3               │
└──────────────────────────────────────────────────────────────────┘
```

The GBA SP used a front-lit screen — dramatically brighter and more vivid than any earlier Game Boy. Whites are genuinely bright. The transparency effect is subtler here, and the clean white backing makes see-through areas look more like polished glass than the DMG's matte grey. The front light scattered through a diffuser layer, producing a characteristic warm glow into neighbouring pixels — this is what the halation effect recreates. **PT_SYSTEM = 3 is tuned for this hardware.**

**Core settings (mGBA):**

| Setting | Value |
|---|---|
| Color correction | Enabled |
| Interframe blending | Enabled |

**Shader settings:**

> Parameters marked are in the **Advanced Defaults** `#define` block near the top of the `.slang` file — not in the RetroArch menu.

| Parameter | Menu label | Value |
|---|---|---|
| PT_SYSTEM | System (0=Manual, 1=GB, 2=GBC, 3=GBA SP, 4=GBA Orig) | 3 (GBA SP) |
| PT_SENSITIVITY |   Manual threshold (PT_SYSTEM=0 only) | 0.85 *(default — only active when PT_SYSTEM = 0)* |
| PT_PIXEL_MODE | Pixel mode (0=White only, 1=Bright, 2=All) | 0 (White only) |
| PT_BASE_ALPHA |   Base transparency amount | 0.15 |
| PT_WHITE_TRANSPARENCY |   White pixel min transparency | 0.45 |
| PT_BRIGHTNESS_MODE | Brightness mode (0=Simple, 1=Perceptual) | 1 (Perceptual) |
| PT_PALETTE | Background tint (0=Off, 1=Pocket, 2=Grey, 3=White, 4=Green-grey) | 3 (White) |
| PT_PALETTE_INTENSITY |   Tint intensity | 1.00 |
| PT_DARK_FILTER_LEVEL | Dark color filter (0=off) | 0 *(off — leave at default for this system)* |
| PT_GRAIN_INTENSITY |   Grain intensity (0=flat) | 0.03 |
| PT_GRAIN_SCALE |   Grain scale (lower=finer) | 0.15 |
| PT_PIXEL_BORDER | Pixel border (0=Off, 1=Subtle, 2=Med, 3=Strong) | 0 (Off) |
| PT_SHADOW_OFFSET_X | Shadow X offset (texels) | 1.0 |
| PT_SHADOW_OFFSET_Y | Shadow Y offset (texels) | 1.0 |
| PT_SHADOW_OPACITY | Shadow opacity (0=off) | 0.20 |
| PT_SHADOW_BLUR | Shadow blur (0=off) | 1.5 |
| PT_SHADOW_BLUR_RADIUS |   Shadow blur radius (texels) | 1.0 |
| PT_HALATION | Halation / diffuser glow (0=off) | 0.08 *(front-lit diffuser glow — only enable for GBA SP)* |
| PT_HALATION_RADIUS |   Halation radius (texels) | 1.5 |
| PT_HALATION_WARMTH |   Halation warmth (0=cool, 1=warm) | 0.30 |
| PT_DITHER | Dither blend edges (0=off, 1=on) | 1.0 |
| PT_DITHER_STRENGTH |   Dither strength | 0.02 |
| PT_DITHER_MATRIX |   Dither matrix (0=2x2, 1=4x4, 2=8x8) | 1 (4×4) |
| PT_CURVATURE | Screen curvature (0=off) | 0.0 *(GBA screen was flat)* |
| PT_CHROMA | Chromatic shift (0=off) | 0.0 |
| PT_VIGNETTE | Vignette strength (0=off) | 0.05 |

---

```
┌──────────────────────────────────────────────────────────────────┐
│  Game Boy Advance Original (no backlight)  —  PT_SYSTEM = 4      │
└──────────────────────────────────────────────────────────────────┘
```

The original GBA had a dim, washed-out reflective screen with no backlight — notoriously difficult to read in poor lighting. Colours were desaturated and whites appeared creamy or yellowish due to the LCD polariser and backing material. The transparency effect is more pronounced here than on any other system. The green-grey palette option captures the distinctive yellowish-green tint of the original GBA backing.

> **GBA Original vs GBA SP:** These are separate PT_SYSTEM presets in the Pro shader — use 3 for SP, 4 for original. The original GBA threshold (0.75) is deliberately lower to catch the creamy whites that wouldn't register at the SP's 0.80. Do not use PT_SYSTEM = 3 for original GBA hardware.

**Core settings (mGBA):**

| Setting | Value |
|---|---|
| Color correction | Enabled |
| Interframe blending | Enabled |

**Shader settings:**

> Parameters marked are in the **Advanced Defaults** `#define` block near the top of the `.slang` file — not in the RetroArch menu.

| Parameter | Menu label | Value |
|---|---|---|
| PT_SYSTEM | System (0=Manual, 1=GB, 2=GBC, 3=GBA SP, 4=GBA Orig) | 4 (GBA Orig) |
| PT_SENSITIVITY |   Manual threshold (PT_SYSTEM=0 only) | 0.85 *(default — only active when PT_SYSTEM = 0)* |
| PT_PIXEL_MODE | Pixel mode (0=White only, 1=Bright, 2=All) | 0 (White only) |
| PT_BASE_ALPHA |   Base transparency amount | 0.25 |
| PT_WHITE_TRANSPARENCY |   White pixel min transparency | 0.55 |
| PT_BRIGHTNESS_MODE | Brightness mode (0=Simple, 1=Perceptual) | 1 (Perceptual) |
| PT_PALETTE | Background tint (0=Off, 1=Pocket, 2=Grey, 3=White, 4=Green-grey) | 4 (Green-grey) |
| PT_PALETTE_INTENSITY |   Tint intensity | 1.00 |
| PT_DARK_FILTER_LEVEL | Dark color filter (0=off) | 0 *(off — leave at default for this system)* |
| PT_GRAIN_INTENSITY |   Grain intensity (0=flat) | 0.08 |
| PT_GRAIN_SCALE |   Grain scale (lower=finer) | 0.20 |
| PT_PIXEL_BORDER | Pixel border (0=Off, 1=Subtle, 2=Med, 3=Strong) | 0 (Off) |
| PT_SHADOW_OFFSET_X | Shadow X offset (texels) | 1.0 |
| PT_SHADOW_OFFSET_Y | Shadow Y offset (texels) | 1.0 |
| PT_SHADOW_OPACITY | Shadow opacity (0=off) | 0.20 |
| PT_SHADOW_BLUR | Shadow blur (0=off) | 1.0 |
| PT_SHADOW_BLUR_RADIUS |   Shadow blur radius (texels) | 1.0 |
| PT_HALATION | Halation / diffuser glow (0=off) | 0.0 *(off — no backlight, no diffuser glow)* |
| PT_DITHER | Dither blend edges (0=off, 1=on) | 1.0 |
| PT_DITHER_STRENGTH |   Dither strength | 0.05 |
| PT_DITHER_MATRIX |   Dither matrix (0=2x2, 1=4x4, 2=8x8) | 1 (4×4) |
| PT_CURVATURE | Screen curvature (0=off) | 0.0 *(GBA screen was flat)* |
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

- `Source` — the colour-corrected processed frame, used for display output, shadow sampling, and halation
- `Original` — the raw pre-correction input frame, used exclusively for white pixel detection, transparency gating, and shadow blur

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

The most important setting. Set this first. Determines the white detection threshold tuned for each system's display characteristics.

| Value | System | Threshold |
|---|---|---|
| 0 | Manual | Use PT_SENSITIVITY to set your own threshold |
| 1 | GB / Pocket | 0.90 — no backlight, aggressive detection |
| 2 | GBC | 0.85 — no backlight, moderate |
| 3 | GBA SP | 0.80 — front-lit, conservative |
| 4 | GBA Original | 0.75 — no backlight, dim whites, most aggressive |

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
**Default: 1 (Pocket grey)**

Tints the procedural backing texture visible through transparent pixels.

| Value | Tint | Description |
|---|---|---|
| 0 | Off | Neutral grey grain |
| 1 | Pocket grey | Warm green-grey — approximates the original DMG/Pocket screen backing |
| 2 | Cool grey | Neutral grey — good for GBC |
| 3 | White | Clean white — recommended for GBA SP |
| 4 | Green-grey | Yellowish-green — matches the original GBA polariser tint |

---

### Background Tint Intensity — `PT_PALETTE_INTENSITY`
**Default: 1.00 | Range: 0.00 – 2.00**

Controls how strongly the tint colour is applied. 0 = no tint regardless of PT_PALETTE setting.

---

### Grain Intensity — `PT_GRAIN_INTENSITY`
**Default: 0.08 | Range: 0.00 – 0.50**

Controls how visible the procedural backing grain is. Higher = more textured, rougher looking surface. GB backing was visibly textured (0.10), GBA SP backing was very clean (0.03).

---

### Grain Scale — `PT_GRAIN_SCALE`
**Default: 0.25 | Range: 0.05 – 1.00**

Controls the size of the grain pattern. Lower = finer grain. Higher = coarser grain. GB had a coarser backing texture than later hardware.

---

### Color Harshness Filter — `PT_DARK_FILTER_LEVEL`
**Default: 0 | Range: 0 – 100**

Softens overly vivid or harsh dark colours, simulating the way original LCD screens compressed and desaturated dark tones. Runs on the colour-corrected frame — bright pixels are largely unaffected. Most useful for GBC games. Set to 0 to disable.

---

### Pixel Border — `PT_PIXEL_BORDER`
**Default: 1 (Subtle)**

Simulates the physical gap between individual LCD dots on original hardware. Uses a sine-wave method that works correctly at any scale mode — aspect ratio, integer, or custom.

| Value | Style | Description |
|---|---|---|
| 0 | Off | No pixel border — recommended for GBA |
| 1 | Subtle | ~17% border darkening — recommended for GB/GBC |
| 2 | Moderate | ~41% border darkening |
| 3 | Strong | ~76% border darkening — very visible pixel grid |

---

### Shadow X Offset — `PT_SHADOW_OFFSET_X`
**Default: 2.0 | Range: -10.0 – 10.0**

Horizontal position of the drop shadow in source texels. The shadow is cast by opaque pixels onto the backing behind them and is visible through transparent areas. Positive = right, negative = left. Set PT_SHADOW_OPACITY to 0 to disable shadows entirely and skip all shadow texture taps.

---

### Shadow Y Offset — `PT_SHADOW_OFFSET_Y`
**Default: 2.0 | Range: -10.0 – 10.0**

Vertical position of the drop shadow in source texels. Positive = down, negative = up.

---

### Shadow Opacity — `PT_SHADOW_OPACITY`
**Default: 0.30 | Range: 0.00 – 1.00**

How dark the drop shadow is. Set to 0 to disable shadows entirely and save all shadow texture taps.

---

### Shadow Blur — `PT_SHADOW_BLUR`
**Default: 1.0 | Range: 0.00 – 5.00**

Enables directional gaussian blur on the drop shadow. Samples spread along the shadow direction vector with gaussian weighting, giving a natural elongated soft falloff. 0 = hard shadow edge, same as the standard version, fastest. Recommended range: 0.5–2.0.

---

### Shadow Blur Radius — `PT_SHADOW_BLUR_RADIUS`
**Default: 1.0 | Range: 0.10 – 4.00**

How far the blur spreads from the shadow origin, in source texels. Only active when PT_SHADOW_BLUR > 0. 0.5 = tight. 1.0 = natural. 2.0 = wide, very soft shadow.

---

### Halation — `PT_HALATION`
**Default: 0.0 | Range: 0.00 – 1.00**

Simulates light scattering through the diffuser layer of a backlit screen. Bright pixels bleed a soft warm glow into surrounding transparent areas. **Only physically present on screens with a backlight — set to 0 for GB, GBC, and GBA Original.** For GBA SP, start at 0.05–0.10.

---

### Halation Radius — `PT_HALATION_RADIUS`
**Default: 1.5 | Range: 0.10 – 5.00**

Radius of the halation glow in source texels. Only active when PT_HALATION > 0. Recommended for GBA SP: 1.0–2.0.

---

### Halation Warmth — `PT_HALATION_WARMTH`
**Default: 0.3 | Range: 0.00 – 1.00**

Colour temperature of the halation glow. 0 = cool white. 0.3 = warm white, matching the GBA SP front light. 1.0 = warm amber. Only active when PT_HALATION > 0.

---

### Dithering — `PT_DITHER`
**Default: 1.0 (on) | 0 = off, 1 = on**

Applies a Bayer ordered dither pattern at the transparency blend boundary. Replicates the natural dithering produced by the slow pixel response of original LCD panels.

---

### Dither Strength — `PT_DITHER_STRENGTH`
**Default: 0.05 | Range: 0.00 – 0.20**

How much the dither pattern offsets the blend alpha. Keep small — the original effect was subtle. Recommended: GB 0.06, GBC 0.04, GBA SP 0.02, GBA Orig 0.05.

---

### Dither Matrix — `PT_DITHER_MATRIX`
**Default: 1 (4×4) | 0 = 2×2, 1 = 4×4, 2 = 8×8**

| Value | Matrix | Description |
|---|---|---|
| 0 | 2×2 | Coarse visible pattern — fastest |
| 1 | 4×4 | Balanced — recommended for most uses |
| 2 | 8×8 | Finest pattern — most subtle and authentic |

---

### Screen Curvature — `PT_CURVATURE`
**Default: 0.0 (off) | Range: 0.00 – 1.00**

Applies barrel distortion to simulate a curved screen. All original GB/GBC/GBA screens were flat — this is an aesthetic option, not a hardware-accuracy feature. Values of 0.1–0.3 give a subtle curve.

---

### Curvature Strength — `PT_CURVATURE_STRENGTH`
**Default: 0.20 | Range: 0.00 – 1.00**

Amount of barrel distortion. Only active when PT_CURVATURE > 0.

---

### Edge Chromatic Fringe — `PT_CURVATURE_FRINGE`
**Default: 0.4 | Range: 0.00 – 1.00**

Colour channel separation at the screen edges, simulating refraction through curved glass. Only active when PT_CURVATURE > 0.

---

### Chromatic Shift — `PT_CHROMA`
**Default: 0.0 | Range: 0.00 – 1.00**

Global chromatic aberration across the full image, simulating colour channel misalignment in the screen glass. Different from edge chromatic fringe — affects the whole screen, not just edges. Pure UV math, zero extra texture samples.

---

### Vignette — `PT_VIGNETTE`
**Default: 0.08 | Range: 0.00 – 1.00**

Darkens the corners and edges of the screen, simulating uneven ambient light distribution. Pure math — no extra texture samples. GB in poor lighting: 0.10–0.15. GBA SP: 0.05.

---

```
╔══════════════════════════════════════════════════════════════════╗
║  PERFORMANCE                                                     ║
╚══════════════════════════════════════════════════════════════════╝
```

All Pro features can be individually disabled. To reduce GPU load on lower-end hardware, disable in this order:

1. `PT_SHADOW_BLUR = 0` — biggest saving; removes 15-tap directional blur
2. `PT_HALATION = 0` — removes 8-tap radial glow
3. `PT_CURVATURE = 0` — removes per-fragment UV distortion
4. `PT_DITHER = 0` — minor saving; removes Bayer matrix lookup
5. `PT_PIXEL_BORDER = 0` — minor saving; removes per-fragment trig

With all Pro features disabled, performance is equivalent to `PT_SkyWalker541.slang`.

---

```
╔══════════════════════════════════════════════════════════════════╗
║  EDITING DEFAULT VALUES                                          ║
╚══════════════════════════════════════════════════════════════════╝
```

To change a default value, open `PT_SkyWalker541_Pro.slang` in any text editor and find the UBO default values block. In the Slang version, defaults are set via `#pragma parameter` declarations at the top of the file. Edit the fifth number on any `#pragma parameter` line to change its default:

```glsl
//                              name          default  min   max  step
#pragma parameter PT_SYSTEM      "..."          1.0     0.0  4.0  1.0
#pragma parameter PT_SENSITIVITY "..."          0.85    0.0  1.0  0.01
#pragma parameter PT_BASE_ALPHA  "..."          0.20    0.0  1.0  0.01
// ... and so on for each parameter
```

The fifth number on each line is the default value. Change it and save. These values load when the preset is first applied and can still be adjusted live from the shader parameters menu at any time.

Change the number on the right of any line to set a new default. These values load when the preset is first applied and can still be adjusted live from the shader parameters menu at any time.

---

```
╔══════════════════════════════════════════════════════════════════╗
║  COMPATIBILITY                                                   ║
╚══════════════════════════════════════════════════════════════════╝
```

Works on any RetroArch-supported platform and display resolution. The shader works at any scale mode — aspect ratio, integer, or custom — no separate variants required.

Works on any RetroArch video driver that supports Slang shaders: **Vulkan**, **glcore**, **D3D11**, **D3D12**, and **Metal**. Does not work with the legacy **gl** driver — use `PT_SkyWalker541_Pro.glslp` for that.

---

```
╔══════════════════════════════════════════════════════════════════╗
║  CHANGELOG                                                       ║
╚══════════════════════════════════════════════════════════════════╝
```

> **Version note:** All PT_SkyWalker541 variants — Standard, Pro, and NextUI — share a unified version number. v1.5.1 represents the same release generation across all three.

| Version | Notes |
|---|---|
| v1.5.2 | Tuned defaults for accuracy on modern displays: PT_PIXEL_MODE reverted to 0 (White only), PT_WHITE_TRANSPARENCY lowered to 0.20, PT_BRIGHTNESS_MODE reverted to 0 (Simple), PT_SHADOW_OPACITY lowered to 0.30, PT_SHADOW_OFFSET default set to 2.0, GB detection threshold raised from 0.88 to 0.90. Shadow offset now scales with output resolution for consistent appearance across all display sizes. Tint formula rewritten as overlay blend |
| v1.5.1 | Fixed Slang shader failing to load on Android/Vulkan. `push_constant` restructured: builtins moved in alongside 15 menu params — 112 bytes, within the 128-byte Vulkan minimum. The 13 advanced sub-params moved to `#define` constants (ADVANCED DEFAULTS block, same as GLSL version). `getBayerDither()` rewritten from `ivec2`/`int` to pure `float` for mobile Vulkan driver compatibility. Also: unified version number across all variants, added cross-references between variant READMEs |
| v1.1.0 | Transparency pipeline improvements: soft detection edge (smoothstep over [threshold, threshold+0.08] replaces hard step — eliminates fringing at detection boundary); alpha now driven by raw pre-correction brightness for consistency with detection; alpha scales with distance above threshold rather than flat base + intensity/3; white pixels now use plain mix() blend path, coloured pixels (Bright/All modes) use hue-preserving blend — correct path for each case |
| v1.0.0 | Initial Pro release. Directional gaussian shadow blur (15-tap, spread along shadow direction vector with gaussian weights), LCD halation with adjustable radius and warmth, Bayer subpixel dithering at blend boundary (2×2 / 4×4 / 8×8 matrix), screen curvature with edge chromatic fringing, improved background grain with adjustable intensity and scale, PT_SYSTEM expanded to include GBA SP (3) and GBA Original (4), green-grey palette option added (PT_PALETTE = 4) |

---

*PT SkyWalker541 Pro by SkyWalker541 | Written for RetroArch*
