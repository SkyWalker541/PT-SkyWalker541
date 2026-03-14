# PT SkyWalker541
### Pixel Transparency Shader for NextUI / minarch
**by SkyWalker541 | v1.5.2 | NextUI / minarch**

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

Both shaders are standalone. No additional passes or files are required beyond the .glsl and .cfg
pair for your chosen variant.

  Using RetroArch? PT_SkyWalker541 (standard) and PT_SkyWalker541_Pro (feature-rich) are
  RetroArch versions of this shader supporting GLSL and Slang, with dedicated presets for gl,
  glcore, Vulkan, D3D11, and Metal drivers. Both are in the PT_SkyWalker541 repository.

---

```
╔══════════════════════════════════════════════════════════════════╗
║  FEATURES                                                        ║
╚══════════════════════════════════════════════════════════════════╝
```

  Pixel transparency restoration
    Detects white and near-white pixels and blends them toward a procedurally generated backing
    texture. Detection runs on the post-processed texture (NextUI does not yet provide access
    to the raw pre-correction frame). Thresholds are pre-compensated for NextUI's post-processing
    pipeline — they are different from the RetroArch version's thresholds by design.

  Two variants for different scale modes
    Aspect variant: pixel border uses a sine-wave grid method. Works correctly at any scale mode
    including aspect ratio and non-integer scaling. Use this if you are unsure.
    Integer variant: pixel border uses a distance-from-centre method (zfast_lcd equation).
    Produces a sharper, cleaner grid but only looks correct at exact integer scale multiples.

  Procedural backing texture with palette tint
    Same as the RetroArch standard version: neutral grain (off), Pocket grey, grey, and white.
    Tint intensity is adjustable.

  Drop shadow
    Same as the RetroArch standard version. Gated on the source pixel being non-white, not on
    the current pixel being transparent — correctly appears at all sprite and tile edges.

  Pixel border
    Simulates the thin physical gap between individual LCD dots. The Aspect and Integer variants
    use different methods internally, each optimised for their respective scale mode.

  Colour harshness filter
    Same as the RetroArch standard version. Particularly useful for GBC. Note: always set the
    device's own Dark Filter Level to 0 and use this shader parameter instead — running both
    simultaneously doubles the effect.

  Vignette
    Same as the RetroArch standard version.

---

```
╔══════════════════════════════════════════════════════════════════╗
║  WHICH VARIANT SHOULD I USE?                                     ║
╚══════════════════════════════════════════════════════════════════╝
```

  File                               Use when
  ─────────────────────────────────  ────────────────────────────────────────────
  PT_SkyWalker541_Aspect.glsl        Aspect ratio or any non-integer scale mode
  PT_SkyWalker541_Integer.glsl       Native / integer scaling only

The difference is entirely in how the pixel border effect works. Both variants are otherwise
identical — same parameters, same detection logic, same transparency blending, shadows, and
all other effects.

  Aspect variant  — sine-wave grid, works at any scale mode including aspect ratio.
  Integer variant — distance-from-centre grid, sharper and cleaner but only correct at exact
                    integer scale multiples. At native integer scale consider mode 2 or 3.

If you are unsure, use the Aspect variant.

---

```
╔══════════════════════════════════════════════════════════════════╗
║  INSTALLATION                                                    ║
╚══════════════════════════════════════════════════════════════════╝
```

Each variant is two files — a .glsl shader and a .cfg preset that loads it.

  Shaders folder:
    PT_SkyWalker541_Aspect.cfg
    PT_SkyWalker541_Integer.cfg

  Shaders/glsl folder:
    PT_SkyWalker541_Aspect.glsl
    PT_SkyWalker541_Integer.glsl

  1. Place the .cfg files in your NextUI shaders folder
  2. Place the .glsl files in the glsl subfolder inside your NextUI shaders folder
  3. Launch a game and open the in-game shader menu
  4. Load the .cfg for your chosen variant — not the .glsl file directly
  5. Open shader settings and set PT_SYSTEM to match your target system
  6. Apply the recommended settings for that system from the section below

---

```
╔══════════════════════════════════════════════════════════════════╗
║  RECOMMENDED SETTINGS PER SYSTEM                                 ║
╚══════════════════════════════════════════════════════════════════╝
```

Set PT_SYSTEM first — it configures the white detection threshold for your system. Then apply
the settings below.

Important: Always set the device Dark Filter Level to 0 and use the shader's own
PT_DARK_FILTER_LEVEL instead. Running both at once doubles the effect.

---

```
┌──────────────────────────────────────────────────────────────────┐
│  Game Boy DMG / Game Boy Pocket  —  PT_SYSTEM = 1                │
└──────────────────────────────────────────────────────────────────┘
```

The original DMG and Pocket both used a slow, ghosting LCD with no backlight — ambient light
only. The physical backing was a distinctive matte green-grey, visible as a translucent tint
through unlit pixels.

  GB Colorization: Any colorization palette (Auto, GBC, SGB, Internal, or Custom) shifts
  pixel values including whites. If you want to use colorization, set PT_SYSTEM = 0 (Manual)
  and lower PT_SENSITIVITY gradually until backgrounds go transparent as expected.

  DEVICE SETTINGS
  ─────────────────────────────────────────────────────────────────
  Scale mode                 Aspect or Integer
  Screen effect              None
  Color correction           Disabled
  Frontlight position        Central
  Dark filter level          0  (use shader PT_DARK_FILTER_LEVEL instead)
  Interframe blending        Disabled
  GB Colorization            Disabled  (see note above)

  SHADER PARAMETERS
  ─────────────────────────────────────────────────────────────────
  PT_SYSTEM                  1          (GB)
  PT_PIXEL_MODE              0          (White only)
  PT_BASE_ALPHA              0.20
  PT_WHITE_TRANSPARENCY      0.20
  PT_BRIGHTNESS_MODE         0          (Simple)
  PT_PALETTE                 1          (Pocket grey)
  PT_PALETTE_INTENSITY       1.00
  PT_DARK_FILTER_LEVEL       10         (device-appropriate dark filter)
  PT_PIXEL_BORDER            1          (Subtle)
  PT_SHADOW_OFFSET_X         1.0
  PT_SHADOW_OFFSET_Y         1.0
  PT_SHADOW_OPACITY          0.30
  PT_VIGNETTE                0.08

---

```
┌──────────────────────────────────────────────────────────────────┐
│  Game Boy Color  —  PT_SYSTEM = 2                                │
└──────────────────────────────────────────────────────────────────┘
```

Similar LCD construction to the original GB but with improved colour response and slightly
faster pixel transitions. Still fully reflective with no backlight. The backing material was
cleaner and more neutral than the DMG.

  DEVICE SETTINGS
  ─────────────────────────────────────────────────────────────────
  Scale mode                 Aspect or Integer
  Screen effect              None
  Color correction           GBC Only
  Frontlight position        Central
  Dark filter level          0  (use shader PT_DARK_FILTER_LEVEL instead)
  Interframe blending        Disabled

  SHADER PARAMETERS
  ─────────────────────────────────────────────────────────────────
  PT_SYSTEM                  2          (GBC)
  PT_PIXEL_MODE              0          (White only)
  PT_BASE_ALPHA              0.20
  PT_WHITE_TRANSPARENCY      0.20
  PT_BRIGHTNESS_MODE         0          (Simple)
  PT_PALETTE                 1          (Pocket grey)
  PT_PALETTE_INTENSITY       1.00
  PT_DARK_FILTER_LEVEL       10         (softens aggressive GBC palettes)
  PT_PIXEL_BORDER            1          (Subtle)
  PT_SHADOW_OFFSET_X         1.0
  PT_SHADOW_OFFSET_Y         1.0
  PT_SHADOW_OPACITY          0.30
  PT_VIGNETTE                0.08

---

```
┌──────────────────────────────────────────────────────────────────┐
│  Game Boy Advance SP (front-lit)  —  PT_SYSTEM = 3               │
└──────────────────────────────────────────────────────────────────┘
```

The GBA SP used a front-lit screen — dramatically brighter and more vivid than any earlier
Game Boy. Whites are genuinely bright, and the transparency effect is subtler here.

  DEVICE SETTINGS
  ─────────────────────────────────────────────────────────────────
  Scale mode                 Aspect or Integer
  Screen effect              None
  Color correction           Enabled
  Interframe blending        Enabled

  SHADER PARAMETERS
  ─────────────────────────────────────────────────────────────────
  PT_SYSTEM                  3          (GBA SP)
  PT_PIXEL_MODE              0          (White only)
  PT_BASE_ALPHA              0.15
  PT_WHITE_TRANSPARENCY      0.45
  PT_BRIGHTNESS_MODE         1          (Perceptual)
  PT_PALETTE                 3          (White)
  PT_PALETTE_INTENSITY       1.00
  PT_DARK_FILTER_LEVEL       0          (off)
  PT_PIXEL_BORDER            0          (Off)
  PT_SHADOW_OFFSET_X         1.0
  PT_SHADOW_OFFSET_Y         1.0
  PT_SHADOW_OPACITY          0.20
  PT_VIGNETTE                0.05

---

```
┌──────────────────────────────────────────────────────────────────┐
│  Game Boy Advance Original (no backlight)  —  PT_SYSTEM = 4      │
└──────────────────────────────────────────────────────────────────┘
```

The original GBA had a dim, washed-out reflective screen with no backlight. Colours were
desaturated and whites appeared creamy or yellowish due to the LCD polariser and backing
material. The transparency effect is more pronounced here than on any other system.

  Threshold note: PT_SYSTEM = 4 uses a threshold of 0.38, estimated from the established
  NextUI post-processing offset pattern. If too many near-white pixels are being missed,
  switch to PT_SYSTEM = 0 (Manual) and lower PT_SENSITIVITY gradually until backgrounds
  go transparent as expected.

  DEVICE SETTINGS
  ─────────────────────────────────────────────────────────────────
  Scale mode                 Aspect or Integer
  Screen effect              None
  Color correction           Enabled
  Interframe blending        Enabled

  SHADER PARAMETERS
  ─────────────────────────────────────────────────────────────────
  PT_SYSTEM                  4          (GBA Orig)
  PT_PIXEL_MODE              0          (White only)
  PT_BASE_ALPHA              0.25
  PT_WHITE_TRANSPARENCY      0.55
  PT_BRIGHTNESS_MODE         1          (Perceptual)
  PT_PALETTE                 2          (Grey — GBA backing was neutral, not green-grey)
  PT_PALETTE_INTENSITY       1.00
  PT_DARK_FILTER_LEVEL       0          (off)
  PT_PIXEL_BORDER            0          (Off)
  PT_SHADOW_OFFSET_X         1.0
  PT_SHADOW_OFFSET_Y         1.0
  PT_SHADOW_OPACITY          0.20
  PT_VIGNETTE                0.12

---

```
╔══════════════════════════════════════════════════════════════════╗
║  HOW IT WORKS                                                    ║
╚══════════════════════════════════════════════════════════════════╝
```

Both shaders are single-pass. White detection and transparency blending run on the same frame
— no passthrough pass required.

White detection uses a dual-channel ratio method: a pixel must be both bright (above the
system threshold) and neutral (low variation across R, G, B channels). This naturally rejects
pixels that appear bright only due to colour correction processing, which tends to shift channel
values unevenly.

Detection runs against the post-processed texture. Thresholds are pre-compensated to account
for this — a raw white pixel on original hardware would be near 1.0, but after colour correction
it lands lower. Per-system thresholds are tuned to that post-correction range:

  GB 0.58     GBC 0.65     GBA SP 0.42     GBA Original 0.38

When NextUI adds OrigTexture support, these shaders will be updated to run detection on the raw
pre-correction frame — matching the RetroArch version's architecture. This is a planned
architectural change and will require retuning all thresholds. It is not a minor patch.

---

```
╔══════════════════════════════════════════════════════════════════╗
║  SHADER PARAMETERS                                               ║
╚══════════════════════════════════════════════════════════════════╝
```

All parameters are the same between both shader variants. They are accessible from the in-game
shader settings menu after loading the preset. Changes apply live.

---

System Preset — PT_SYSTEM
  Default: 1 (GB)

  The most important setting. Set this first. Configures the white detection threshold tuned
  for each system's display characteristics. Thresholds are pre-compensated for NextUI's
  post-processing pipeline.

  Value  System              Threshold
  -----  ------------------  ----------------------------------------
  0      Manual              Use PT_SENSITIVITY to set your own
  1      GB / Pocket         0.58  no backlight, aggressive detection
  2      GBC                 0.65  no backlight, moderate
  3      GBA SP (front-lit)  0.42  front-lit, conservative
  4      GBA Original        0.38  no backlight, catches creamy whites

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
  3      White        Clean white — recommended for GBA

---

Background Tint Intensity — PT_PALETTE_INTENSITY
  Default: 1.00  |  Range: 0.00 – 2.00

  Controls how strongly the tint colour is applied. 0 = no tint regardless of PT_PALETTE.

---

Colour Harshness Filter — PT_DARK_FILTER_LEVEL
  Default: 10  |  Range: 0 – 100

  Softens overly vivid or harsh dark colours. Most useful for GBC games with aggressive colour
  palettes. Set to 0 to disable.

  Always set the device's own Dark Filter Level to 0 and use this parameter instead.
  Running both simultaneously doubles the effect.

---

Pixel Border — PT_PIXEL_BORDER
  Default: 1 (Subtle)

  Simulates the thin physical gap between individual LCD dots on original hardware. The Aspect
  and Integer variants use different methods internally, each optimised for their scale mode.

  Value  Style     Description
  -----  --------  -------------------------------------------------------
  0      Off       No pixel border
  1      Subtle    ~17% border darkening — closest to original hardware
  2      Moderate  ~41% border darkening
  3      Strong    ~76% border darkening — clearly defined pixel grid

  Integer variant: at native/integer scaling the pixel grid is particularly sharp.
  Consider mode 2 or 3 for a more visible grid effect.

---

Shadow X Offset — PT_SHADOW_OFFSET_X
  Default: 1.0  |  Range: -30.0 – 30.0

  Horizontal position of the drop shadow. 1.0 is the smallest visible diagonal shift.
  Positive = right, negative = left.

---

Shadow Y Offset — PT_SHADOW_OFFSET_Y
  Default: 1.0  |  Range: -30.0 – 30.0

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
║  EDITING DEFAULT VALUES                                          ║
╚══════════════════════════════════════════════════════════════════╝
```

To change a default value, open either .glsl file in any text editor and find this block
inside the #ifdef PARAMETER_UNIFORM / #else section near the top of the fragment shader:

    #define PT_SYSTEM             1.0
    #define PT_SENSITIVITY        0.85
    #define PT_PIXEL_MODE         0.0
    #define PT_BASE_ALPHA         0.20
    #define PT_WHITE_TRANSPARENCY 0.20
    #define PT_BRIGHTNESS_MODE    0.0
    #define PT_PALETTE            1.0
    #define PT_PALETTE_INTENSITY  1.0
    #define PT_DARK_FILTER_LEVEL  10.0
    #define PT_PIXEL_BORDER       1.0
    #define PT_SHADOW_OFFSET_X    1.0
    #define PT_SHADOW_OFFSET_Y    1.0
    #define PT_SHADOW_OPACITY     0.30
    #define PT_VIGNETTE           0.08

Change the number on the right of any line to set a new default. These values load when the
preset is first applied and can still be adjusted live from the shader settings menu.

---

```
╔══════════════════════════════════════════════════════════════════╗
║  COMPATIBILITY                                                   ║
╚══════════════════════════════════════════════════════════════════╝
```

Both shaders are written for NextUI / minarch. Shadow offsets and pixel borders are calculated
using coordinate methods proven on NextUI — they work correctly at any device resolution and
scale mode.

The shaders use only Texture / Source as input. They do not require OrigTexture or multipass
support.

---

*PT SkyWalker541 by SkyWalker541 | v1.5.2 | Written for NextUI*
