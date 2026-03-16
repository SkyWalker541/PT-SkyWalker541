# PT SkyWalker541
### Pixel Transparency Shader for RetroArch — GLSL Version
**by SkyWalker541 | v1.5.2 | GLSL (.glslp) — works on gl / glcore drivers**

---

On original Game Boy, Game Boy Color, and Game Boy Advance hardware, pixels that were fully off
didn't show as white. Because those screens had no backlight driving those areas, the physical
backing material showed through instead — a subtle grey-green translucency rather than solid white.
Game developers of that era designed around this, using "white" areas as intentional transparent
zones for backgrounds, windows, and UI overlays.

On modern displays and emulators, those same pixels render as bright white, which was never the
intended look. PT SkyWalker541 restores the original appearance by detecting bright and white
pixels and blending them toward a procedurally generated backing texture — putting the transparency
back where it belongs.

This version runs on standard RetroArch using a single-pass .glslp preset. White detection runs
against the raw unprocessed game frame via RetroArch's built-in OrigTexture uniform, giving
cleaner and more accurate results than would otherwise be possible.

  Looking for the Slang version? If you're on a driver that supports Slang (Vulkan, glcore,
  D3D11, D3D12, or Metal), use PT_SkyWalker541.slangp instead. Both versions produce identical
  output.

  Looking for more effects? PT_SkyWalker541_Pro adds adjustable grain, LCD halation glow, Bayer
  dithering, shadow blur, screen warp, subpixel layout, reflective sheen, and tight bloom —
  designed for more powerful hardware. Both versions are in the PT_SkyWalker541 repository.

  On NextUI / minarch? PT_SkyWalker541_Aspect and PT_SkyWalker541_Integer are purpose-built
  versions for NextUI / minarch, with thresholds pre-compensated for NextUI's post-processing
  pipeline. Both are in the PT_SkyWalker541 repository.

---

```
╔══════════════════════════════════════════════════════════════════╗
║  FEATURES                                                        ║
╚══════════════════════════════════════════════════════════════════╝
```

  Pixel transparency restoration
    Detects white and near-white pixels and blends them toward a procedurally generated backing
    texture. White detection runs on the raw pre-correction frame (OrigTexture uniform) for
    clean, accurate thresholds that don't require compensation for the emulator's colour
    correction. Supports three modes: white-only (most authentic), brightness-proportional,
    and all-pixels.

  Procedural backing texture with palette tint
    The backing visible through transparent pixels is a generated noise grain tinted to match
    the original hardware's backing material. Four palette options: neutral grain (off), Pocket
    grey (warm green-grey, DMG/Pocket), grey (neutral, GBC/GBA Original), and white (clean,
    GBA SP). Tint intensity is adjustable.

  Drop shadow
    A configurable drop shadow cast by all solid (non-white) pixels onto the backing behind
    them. Visible wherever the backing shows through — adds depth at sprite edges, text, and
    UI elements. Shadow is gated on the source pixel being non-white, not on the current pixel
    being transparent, so it correctly appears at all sprite and tile edges.

  Pixel border
    Simulates the thin physical gap between individual LCD dots on original hardware. Uses a
    sine-wave method that works correctly at any scale mode — aspect ratio, integer, or custom.
    Four strength levels from off to strong.

  Colour harshness filter
    Softens overly vivid or harsh dark colours, simulating the natural compression of dark tones
    on original LCD panels. Most useful for GBC games with aggressive colour palettes. Runs on
    the colour-corrected frame — bright and transparent pixels are largely unaffected.

  Vignette
    Darkens the screen toward the edges and corners, simulating the uneven light distribution
    of original handheld screens. Pure math — no extra texture samples.

  Chromatic shift  (hidden, default off)
    Radial RGB channel separation from the screen centre — R shifts outward, B shifts inward.
    Adds a subtle optical fringing effect. Zero GPU cost when disabled.

---

```
╔══════════════════════════════════════════════════════════════════╗
║  INSTALLATION                                                    ║
╚══════════════════════════════════════════════════════════════════╝
```

The shader uses two files. Place them in your RetroArch shaders folder:

    PT_SkyWalker541.glslp
    PT_SkyWalker541.glsl

  1. Launch a game
  2. Open the RetroArch menu and go to Quick Menu > Shaders > Load Shader Preset
  3. Select PT_SkyWalker541.glslp — not the .glsl file directly
  4. Open Shader Parameters and set PT_SYSTEM to match your target system
  5. Apply the recommended settings for that system from the section below
  6. Optionally save via Save Shader Preset As for automatic loading on future sessions

---

```
╔══════════════════════════════════════════════════════════════════╗
║  RECOMMENDED SETTINGS PER SYSTEM                                 ║
╚══════════════════════════════════════════════════════════════════╝
```

Set PT_SYSTEM first — it configures the white detection threshold for your system. Then apply
the settings below. Each system had meaningfully different display hardware and the right
settings make a real difference.

---

```
┌──────────────────────────────────────────────────────────────────┐
│  Game Boy DMG / Game Boy Pocket  —  PT_SYSTEM = 1                │
└──────────────────────────────────────────────────────────────────┘
```

The original DMG and Pocket both used a slow, ghosting LCD with no backlight — ambient light
only. The physical backing was a distinctive matte green-grey, visible as a translucent tint
through unlit pixels. Pixel response was slow enough that moving sprites produced visible
trails, and the boundary between transparent and opaque areas was naturally soft.

  DMG vs Pocket: Shader settings are identical for both. The Pocket is slightly cleaner and
  less green in person, but the difference is minor enough that PT_SYSTEM = 1 covers both
  accurately. If you prefer a more neutral backing for the Pocket, try PT_PALETTE = 2 (Grey).

  GB Colorization: Any colorization palette (Auto, GBC, SGB, Internal, or Custom) shifts
  pixel values including whites. If you want to use colorization, set PT_SYSTEM = 0 (Manual)
  and lower PT_SENSITIVITY until backgrounds go transparent as expected.

  CORE SETTINGS  (Gambatte / SameBoy)
  ─────────────────────────────────────────────────────────────────
  Color correction           Disabled
  Interframe blending        Disabled
  GB Colorization            Disabled  (see note above)

  SHADER PARAMETERS
  ─────────────────────────────────────────────────────────────────
  PT_SYSTEM (System)  1   GB
  PT_PIXEL_MODE (Pixel mode)  0   White only
  PT_BASE_ALPHA (Base transparency)  0.20
  PT_WHITE_TRANSPARENCY (White pixel min transparency)  0.20
  PT_BRIGHTNESS_MODE (Brightness mode)  0   Simple
  PT_PALETTE (Background tint)  1   Pocket grey
  PT_PALETTE_INTENSITY (Tint intensity)  1.00
  PT_DARK_FILTER_LEVEL (Dark color filter)  0   off
  PT_PIXEL_BORDER (Pixel border)  1   Subtle
  PT_SHADOW_OFFSET_X (Shadow X offset)  1.0
  PT_SHADOW_OFFSET_Y (Shadow Y offset)  1.0
  PT_SHADOW_OPACITY (Shadow opacity)  0.30
  PT_VIGNETTE (Vignette strength)  0.10

  HIDDEN PARAMETERS  (edit in PT_SkyWalker541.glsl)
  ─────────────────────────────────────────────────────────────────
  PT_CHROMA_STRENGTH         0.0        (off — not applicable)

---

```
┌──────────────────────────────────────────────────────────────────┐
│  Game Boy Color  —  PT_SYSTEM = 2                                │
└──────────────────────────────────────────────────────────────────┘
```

Similar LCD construction to the original GB but with improved colour response and slightly
faster pixel transitions. Still fully reflective with no backlight. The backing material was
cleaner and more neutral than the original DMG — Pocket grey still works well but the effect
is subtler.

  CORE SETTINGS  (Gambatte / SameBoy)
  ─────────────────────────────────────────────────────────────────
  Color correction           GBC Only
  Interframe blending        Disabled

  SHADER PARAMETERS
  ─────────────────────────────────────────────────────────────────
  PT_SYSTEM (System)  2   GBC
  PT_PIXEL_MODE (Pixel mode)  0   White only
  PT_BASE_ALPHA (Base transparency)  0.20
  PT_WHITE_TRANSPARENCY (White pixel min transparency)  0.20
  PT_BRIGHTNESS_MODE (Brightness mode)  0   Simple
  PT_PALETTE (Background tint)  1   Pocket grey
  PT_PALETTE_INTENSITY (Tint intensity)  1.00
  PT_DARK_FILTER_LEVEL (Dark color filter)  10   softens aggressive GBC palettes
  PT_PIXEL_BORDER (Pixel border)  1   Subtle
  PT_SHADOW_OFFSET_X (Shadow X offset)  1.0
  PT_SHADOW_OFFSET_Y (Shadow Y offset)  1.0
  PT_SHADOW_OPACITY (Shadow opacity)  0.25
  PT_VIGNETTE (Vignette strength)  0.08

  HIDDEN PARAMETERS  (edit in PT_SkyWalker541.glsl)
  ─────────────────────────────────────────────────────────────────
  PT_CHROMA_STRENGTH         0.0        (off — not applicable)

---

```
┌──────────────────────────────────────────────────────────────────┐
│  Game Boy Advance SP (front-lit)  —  PT_SYSTEM = 3               │
└──────────────────────────────────────────────────────────────────┘
```

The GBA SP used a front-lit screen — dramatically brighter and more vivid than any earlier
Game Boy. Whites are genuinely bright. The transparency effect is subtler here, and the clean
white backing makes see-through areas look more like polished glass than the DMG's matte grey.

  CORE SETTINGS  (mGBA)
  ─────────────────────────────────────────────────────────────────
  Color correction           Enabled
  Interframe blending        Enabled

  SHADER PARAMETERS
  ─────────────────────────────────────────────────────────────────
  PT_SYSTEM (System)  3   GBA SP
  PT_PIXEL_MODE (Pixel mode)  0   White only
  PT_BASE_ALPHA (Base transparency)  0.15
  PT_WHITE_TRANSPARENCY (White pixel min transparency)  0.45
  PT_BRIGHTNESS_MODE (Brightness mode)  1   Perceptual
  PT_PALETTE (Background tint)  3   White
  PT_PALETTE_INTENSITY (Tint intensity)  1.00
  PT_DARK_FILTER_LEVEL (Dark color filter)  0   off
  PT_PIXEL_BORDER (Pixel border)  0   Off
  PT_SHADOW_OFFSET_X (Shadow X offset)  1.0
  PT_SHADOW_OFFSET_Y (Shadow Y offset)  1.0
  PT_SHADOW_OPACITY (Shadow opacity)  0.20
  PT_VIGNETTE (Vignette strength)  0.05

  HIDDEN PARAMETERS  (edit in PT_SkyWalker541.glsl)
  ─────────────────────────────────────────────────────────────────
  PT_CHROMA_STRENGTH         0.0        (off — not applicable)

---

```
┌──────────────────────────────────────────────────────────────────┐
│  Game Boy Advance Original (no backlight)  —  PT_SYSTEM = 4      │
└──────────────────────────────────────────────────────────────────┘
```

The original GBA had a dim, washed-out reflective screen with no backlight — notoriously
difficult to read in poor lighting. Colours were desaturated and whites appeared creamy or
yellowish due to the LCD polariser and backing material. The transparency effect is more
pronounced here than on any other system.

  CORE SETTINGS  (mGBA)
  ─────────────────────────────────────────────────────────────────
  Color correction           Enabled
  Interframe blending        Enabled

  SHADER PARAMETERS
  ─────────────────────────────────────────────────────────────────
  PT_SYSTEM (System)  4   GBA Orig
  PT_PIXEL_MODE (Pixel mode)  0   White only
  PT_BASE_ALPHA (Base transparency)  0.25
  PT_WHITE_TRANSPARENCY (White pixel min transparency)  0.55
  PT_BRIGHTNESS_MODE (Brightness mode)  1   Perceptual
  PT_PALETTE (Background tint)  2   Grey — GBA backing was neutral, not green-grey
  PT_PALETTE_INTENSITY (Tint intensity)  1.00
  PT_DARK_FILTER_LEVEL (Dark color filter)  0   off
  PT_PIXEL_BORDER (Pixel border)  0   Off
  PT_SHADOW_OFFSET_X (Shadow X offset)  1.0
  PT_SHADOW_OFFSET_Y (Shadow Y offset)  1.0
  PT_SHADOW_OPACITY (Shadow opacity)  0.20
  PT_VIGNETTE (Vignette strength)  0.12

  HIDDEN PARAMETERS  (edit in PT_SkyWalker541.glsl)
  ─────────────────────────────────────────────────────────────────
  PT_CHROMA_STRENGTH         0.0        (off — not applicable)

---

```
╔══════════════════════════════════════════════════════════════════╗
║  HOW IT WORKS                                                    ║
╚══════════════════════════════════════════════════════════════════╝
```

This is a single-pass shader. It uses RetroArch's built-in OrigTexture uniform, which provides
the raw unprocessed input frame directly — no passthrough pass required.

The shader has access to two textures at all times:

  Texture     — the colour-corrected processed frame, used for display output and shadow sampling
  OrigTexture — the raw pre-correction input frame, used exclusively for white pixel detection
                and transparency gating

Running detection on pre-correction pixels means thresholds can be accurate values rather than
compensated guesses. A white pixel on original hardware is very close to 1.0 before any
processing — the shader detects that directly.

---

```
╔══════════════════════════════════════════════════════════════════╗
║  SHADER PARAMETERS                                               ║
╚══════════════════════════════════════════════════════════════════╝
```

All parameters are accessible from Quick Menu > Shaders > Shader Parameters after loading the
preset. Changes preview live.

---

System Preset — PT_SYSTEM
  Default: 1 (GB)

  The most important setting. Set this first. Configures the white detection threshold tuned
  for each system's display characteristics.

  Value  System              Threshold
  -----  ------------------  ----------------------------------------
  0      Manual              Use PT_SENSITIVITY to set your own
  1      GB / Pocket         0.90  no backlight, aggressive detection
  2      GBC                 0.85  no backlight, moderate
  3      GBA SP (front-lit)  0.80  front-lit, conservative
  4      GBA Original        0.75  no backlight, catches creamy whites

---

Detection Sensitivity — PT_SENSITIVITY
  Default: 0.85  |  Range: 0.10 – 1.00  |  Manual mode only

  Only active when PT_SYSTEM = 0. Has no effect when using a system preset.
  Higher values = only very obvious whites go transparent.
  Lower values  = more pixels treated as white.

---

Transparency Mode — PT_PIXEL_MODE
  Default: 0 (White only)

  Value  Mode        Description
  -----  ----------  -------------------------------------------------------
  0      White only  Only white and near-white pixels go transparent
  1      Bright      Brighter pixels become proportionally more transparent
  2      All         Every pixel blends toward the backing texture

  Mode 0 is recommended for the most accurate look.

---

Base Transparency — PT_BASE_ALPHA
  Default: 0.20  |  Range: 0.00 – 1.00

  Controls how transparent detected pixels become.
  Lower = more opaque, higher = more see-through.

---

White Pixel Transparency Boost — PT_WHITE_TRANSPARENCY
  Default: 0.20  |  Range: 0.00 – 1.00

  Sets a minimum transparency level specifically for confirmed white pixels. Ensures clearly
  white pixels are always at least this transparent, regardless of PT_BASE_ALPHA.

---

Brightness Mode — PT_BRIGHTNESS_MODE
  Default: 0 (Simple)

  Value  Mode        Best for
  -----  ----------  -------------------------------------------------------
  0      Simple      Equal average of R, G, B — good for GB/GBC
  1      Perceptual  Human vision weighted (ITU-R BT.709) — good for GBA

---

Background Tint — PT_PALETTE
  Default: 1 (Pocket grey)

  Tints the procedural backing texture visible through transparent pixels.

  Value  Tint         Description
  -----  -----------  -------------------------------------------------------
  0      Off          Neutral grey grain
  1      Pocket grey  Warm green-grey — approximates the DMG/Pocket backing
  2      Grey         Neutral grey — good for GBC
  3      White        Clean white — recommended for GBA SP
  4      Green-grey   Yellowish-green — matches the original GBA polariser tint

---

Background Tint Intensity — PT_PALETTE_INTENSITY
  Default: 1.00  |  Range: 0.00 – 2.00

  Controls how strongly the tint colour is applied. 0 = no tint regardless of PT_PALETTE.

---

Colour Harshness Filter — PT_DARK_FILTER_LEVEL
  Default: 0  |  Range: 0 – 100

  Softens overly vivid or harsh dark colours. Most useful for GBC games with aggressive colour
  palettes. Runs on the colour-corrected frame — bright pixels are largely unaffected. 0 = off.

---

Pixel Border — PT_PIXEL_BORDER
  Default: 1 (Subtle)

  Simulates the thin physical gap between individual LCD dots on original hardware. Uses a
  sine-wave method that works correctly at any scale mode.

  Value  Style     Description
  -----  --------  -------------------------------------------------------
  0      Off       No pixel border
  1      Subtle    ~17% border darkening — closest to original hardware
  2      Moderate  ~41% border darkening
  3      Strong    ~76% border darkening — clearly defined pixel grid

---

Shadow X Offset — PT_SHADOW_OFFSET_X
  Default: 1.0  |  Range: -10.0 – 10.0

  Horizontal position of the drop shadow. 1.0 is the smallest visible diagonal shift.
  Positive = right, negative = left.

---

Shadow Y Offset — PT_SHADOW_OFFSET_Y
  Default: 1.0  |  Range: -10.0 – 10.0

  Vertical position of the drop shadow. Positive = down, negative = up.

---

Shadow Opacity — PT_SHADOW_OPACITY
  Default: 0.30  |  Range: 0.00 – 1.00

  How dark the drop shadow is. Set to 0 to disable shadows entirely.

---

Vignette — PT_VIGNETTE
  Default: 0.08  |  Range: 0.00 – 1.00

  Darkens the screen toward the edges and corners, simulating the uneven light distribution
  of original handheld screens. Pure math — no extra texture samples. Set to 0 to disable.

---

```
╔══════════════════════════════════════════════════════════════════╗
║  HIDDEN PARAMETERS                                               ║
╚══════════════════════════════════════════════════════════════════╝
```

Some values are intentionally not exposed in the RetroArch shader menu. They can be changed
by opening PT_SkyWalker541.glsl in a text editor and editing the relevant #define near the
top of the file.

---

Chromatic Shift — PT_CHROMA_STRENGTH
  Default: 0.0 (off)  |  Suggested range: 0.3 – 0.8

  Applies a subtle radial RGB channel separation from the screen centre — R shifts slightly
  outward, B shifts slightly inward. Adds a very mild optical fringing effect at the edges
  of the image. Zero GPU cost at default value.

  To enable, edit this line in the shader file:

    #define PT_CHROMA_STRENGTH 0.0   // change to e.g. 0.5 to enable

---

```
╔══════════════════════════════════════════════════════════════════╗
║  EDITING DEFAULT VALUES                                          ║
╚══════════════════════════════════════════════════════════════════╝
```

To change a default value, open PT_SkyWalker541.glsl in any text editor and find this block
inside the #ifdef PARAMETER_UNIFORM / #else section near the top of the fragment shader:

    #define PT_SYSTEM             1.0
    #define PT_SENSITIVITY        0.85
    #define PT_PIXEL_MODE         0.0
    #define PT_BASE_ALPHA         0.20
    #define PT_WHITE_TRANSPARENCY 0.20
    #define PT_BRIGHTNESS_MODE    0.0
    #define PT_PALETTE            1.0
    #define PT_PALETTE_INTENSITY  1.0
    #define PT_DARK_FILTER_LEVEL  0.0
    #define PT_PIXEL_BORDER       1.0
    #define PT_SHADOW_OFFSET_X    1.0
    #define PT_SHADOW_OFFSET_Y    1.0
    #define PT_SHADOW_OPACITY     0.30
    #define PT_VIGNETTE           0.08

Change the number on the right of any line to set a new default. These values load when the
preset is first applied and can still be adjusted live from the shader parameters menu.

---

```
╔══════════════════════════════════════════════════════════════════╗
║  COMPATIBILITY                                                   ║
╚══════════════════════════════════════════════════════════════════╝
```

Works on any RetroArch-supported platform and display resolution. The shader works at any
scale mode — aspect ratio, integer, or custom — no separate variants required.

Requires a RetroArch video driver that supports GLSL shaders. This includes the gl and glcore
drivers. Does not work with the Vulkan driver — use PT_SkyWalker541.slangp for Vulkan.

---

*PT SkyWalker541 by SkyWalker541 | v1.5.2 | Written for RetroArch*
