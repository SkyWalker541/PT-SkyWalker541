# PT SkyWalker541 Pro
### Pixel Transparency Shader for RetroArch — GLSL Pro Version
**by SkyWalker541 | v1.5.2 | GLSL (.glslp) — works on gl / glcore drivers**

---

On original Game Boy, Game Boy Color, and Game Boy Advance hardware, pixels that were fully off
didn't show as white. Because those screens had no backlight driving those areas, the physical
backing material showed through instead — a subtle grey-green translucency rather than solid white.
Game developers of that era designed around this, using "white" areas as intentional transparent
zones for backgrounds, windows, and UI overlays.

On modern displays and emulators, those same pixels render as bright white, which was never the
intended look. PT SkyWalker541 Pro restores the original appearance with a full suite of
hardware-accurate effects, targeting powerful handhelds and PC.

  Looking for the GLSL version? Use PT_SkyWalker541_Pro.slangp if your RetroArch video driver
  is set to Vulkan, glcore, D3D11, D3D12, or Metal. Both versions produce identical output.

  Looking for the lighter version? PT_SkyWalker541.slangp is the standard shader without the
  Pro-exclusive effects — better suited to modest hardware.

  On NextUI / minarch? PT_SkyWalker541_Aspect and PT_SkyWalker541_Integer are purpose-built
  versions for NextUI / minarch. Both are in the PT_SkyWalker541 repository.

---

```
╔══════════════════════════════════════════════════════════════════╗
║  FEATURES                                                        ║
╚══════════════════════════════════════════════════════════════════╝
```

All features from the standard shader, plus:

  Pixel transparency restoration
    Same core detection as the standard shader, with an improved soft-edge detection algorithm
    (smoothstep gradient instead of a hard step). This eliminates fringing at the detection
    boundary. White detection runs on the raw pre-correction frame (Original semantic).

  Procedural backing texture with palette tint
    Same as standard, with an additional Green-grey palette option (value 4) for the original
    GBA's distinctive yellowish polariser tint. Grain intensity and scale are independently
    adjustable hidden parameters.

  Drop shadow with directional gaussian blur
    The standard single-tap hard shadow upgraded to a 15-tap directional gaussian blur spreading
    along the shadow direction vector. Gives a natural elongated soft falloff. Hard shadow mode
    (PT_SHADOW_BLUR = 0) is still available and matches the standard shader's performance.

  LCD halation
    Simulates light scattering through the diffuser layer of a front-lit screen. Bright pixels
    bleed a soft warm glow into surrounding transparent areas. Physically meaningful only for the
    GBA SP — leave off for GB, GBC, and GBA Original. 8-tap radial sampling with adjustable
    radius and colour temperature.

  Tight bloom
    Close-range pixel bleed between adjacent bright pixels through the front-light diffuser.
    Separate from halation — halation is a wide area glow, tight bloom is the immediate bleed
    into direct neighbours. Use both together for the most authentic GBA SP front-light look.
    Only physically meaningful for the GBA SP.

  Bayer dithering
    Applies an ordered Bayer dither pattern at the transparency blend boundary, replicating
    the natural dithering produced by the slow pixel response of original LCD panels.
    Three matrix sizes: 2x2, 4x4, and 8x8.

  Screen warp
    Subtle barrel distortion simulating the slight curvature of the physical screen glass under
    the bezel. Applied to the texture sampling UV so the entire rendered image — background,
    shadows, all blend results — warps together correctly.

  Subpixel layout
    Simulates the RGB vertical stripe subpixel structure of the original LCD panels. Modulates
    R, G, and B channels independently based on horizontal sub-pixel position, using smoothstep
    transitions. Leave off for the monochrome GB.

  Reflective sheen
    Subtle edge brightening simulating ambient light bouncing off the reflective LCD surface.
    The opposite of vignette — brightens toward the edges rather than darkening. Physically
    meaningful only for reflective screens (GB, GBC, GBA Original). Leave off for GBA SP.

  Chromatic shift  (hidden, default off)
    Radial RGB channel separation from the screen centre. Same as the standard shader.

---

```
╔══════════════════════════════════════════════════════════════════╗
║  INSTALLATION                                                    ║
╚══════════════════════════════════════════════════════════════════╝
```

Place both files in the same folder inside your RetroArch shaders directory:

    PT_SkyWalker541_Pro.glslp
    PT_SkyWalker541_Pro.glsl

  1. Launch a game
  2. Open the RetroArch menu and go to Quick Menu > Shaders > Load Shader Preset
  3. Select PT_SkyWalker541_Pro.glslp — not the .slang file directly
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

Parameters marked (edit in shader) are in the Advanced Defaults #define block near the top
of PT_SkyWalker541_Pro.slang — they are not accessible from the RetroArch menu.

---

```
┌──────────────────────────────────────────────────────────────────┐
│  Game Boy DMG / Game Boy Pocket  —  PT_SYSTEM = 1                │
└──────────────────────────────────────────────────────────────────┘
```

The original DMG and Pocket both used a very slow, ghosting LCD with no backlight — ambient
light only. The physical backing was a distinctive matte green-grey, visible as a translucent
tint through unlit pixels. Pixel response was slow enough that moving sprites produced visible
trails, and the boundary between transparent and opaque areas was naturally dithered by the
panel's response time.

  DMG vs Pocket: Shader settings are identical for both. The Pocket is slightly cleaner and
  less green in person. If you prefer a more neutral backing for the Pocket, try PT_PALETTE = 2
  (Grey) and reduce PT_GRAIN_INTENSITY slightly to around 0.07.

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
  PT_PIXEL_MODE (Transparency mode)  0   White only
  PT_BASE_ALPHA (Base transparency)  0.20
  PT_WHITE_TRANSPARENCY (White pixel min transparency)  0.20
  PT_PALETTE (Background tint)  1   Pocket grey
  PT_DARK_FILTER_LEVEL (Dark color filter)  0   off
  PT_PIXEL_BORDER (Pixel border)  1   Subtle
  PT_SHADOW_OFFSET_X (Shadow X offset)  1.0
  PT_SHADOW_OFFSET_Y (Shadow Y offset)  1.0
  PT_SHADOW_OPACITY (Shadow opacity)  0.30
  PT_SHADOW_BLUR (Shadow blur amount)  1.0
  PT_HALATION (Halation glow)  0.0   off — no backlight
  PT_DITHER (Dither blend edges)  1.0   on
  PT_VIGNETTE (Vignette strength)  0.10

  HIDDEN PARAMETERS  (edit in PT_SkyWalker541_Pro.glsl)
  ─────────────────────────────────────────────────────────────────
  PT_BRIGHTNESS_MODE         0.0        (Simple)
  PT_PALETTE_INTENSITY       1.0
  PT_GRAIN_INTENSITY         0.10
  PT_GRAIN_SCALE             0.30
  PT_SHADOW_BLUR_RADIUS      1.0
  PT_DITHER_STRENGTH         0.06
  PT_DITHER_MATRIX           1.0        (4x4)
  PT_SUBPIXEL_STRENGTH       0.0        (off — monochrome panel, no colour subpixels)
  PT_TIGHT_BLOOM             0.0        (off — no backlight)
  PT_WARP_STRENGTH           0.04       (subtle glass curvature)
  PT_SHEEN_STRENGTH          0.06       (reflective screen)
  PT_CHROMA_STRENGTH         0.0        (off)

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
  PT_PIXEL_MODE (Transparency mode)  0   White only
  PT_BASE_ALPHA (Base transparency)  0.20
  PT_WHITE_TRANSPARENCY (White pixel min transparency)  0.20
  PT_PALETTE (Background tint)  1   Pocket grey
  PT_DARK_FILTER_LEVEL (Dark color filter)  10   softens aggressive GBC palettes
  PT_PIXEL_BORDER (Pixel border)  1   Subtle
  PT_SHADOW_OFFSET_X (Shadow X offset)  1.0
  PT_SHADOW_OFFSET_Y (Shadow Y offset)  1.0
  PT_SHADOW_OPACITY (Shadow opacity)  0.25
  PT_SHADOW_BLUR (Shadow blur amount)  1.0
  PT_HALATION (Halation glow)  0.0   off — no backlight
  PT_DITHER (Dither blend edges)  1.0   on
  PT_VIGNETTE (Vignette strength)  0.08

  HIDDEN PARAMETERS  (edit in PT_SkyWalker541_Pro.glsl)
  ─────────────────────────────────────────────────────────────────
  PT_BRIGHTNESS_MODE         0.0        (Simple)
  PT_PALETTE_INTENSITY       1.0
  PT_GRAIN_INTENSITY         0.07
  PT_GRAIN_SCALE             0.25
  PT_SHADOW_BLUR_RADIUS      1.0
  PT_DITHER_STRENGTH         0.04
  PT_DITHER_MATRIX           1.0        (4x4)
  PT_SUBPIXEL_STRENGTH       0.25       (colour LCD subpixel structure)
  PT_TIGHT_BLOOM             0.0        (off — no backlight)
  PT_WARP_STRENGTH           0.03       (subtle glass curvature)
  PT_SHEEN_STRENGTH          0.05       (reflective screen)
  PT_CHROMA_STRENGTH         0.0        (off)

---

```
┌──────────────────────────────────────────────────────────────────┐
│  Game Boy Advance SP (front-lit)  —  PT_SYSTEM = 3               │
└──────────────────────────────────────────────────────────────────┘
```

The GBA SP used a front-lit screen — dramatically brighter and more vivid than any earlier
Game Boy. Whites are genuinely bright. The transparency effect is subtler here, and the clean
white backing makes see-through areas look more like polished glass than the DMG's matte grey.
The front light scattered through a diffuser layer, producing a characteristic warm glow into
neighbouring pixels — this is what the halation and tight bloom effects recreate.

  GBA SP vs GBA Original: These are separate PT_SYSTEM presets — use 3 for SP, 4 for original.
  Do not use PT_SYSTEM = 3 for original GBA hardware. The SP's 0.80 threshold is too
  conservative for the dimmer, creamy whites of the original GBA.

  CORE SETTINGS  (mGBA)
  ─────────────────────────────────────────────────────────────────
  Color correction           Enabled
  Interframe blending        Enabled

  SHADER PARAMETERS
  ─────────────────────────────────────────────────────────────────
  PT_SYSTEM (System)  3   GBA SP
  PT_PIXEL_MODE (Transparency mode)  0   White only
  PT_BASE_ALPHA (Base transparency)  0.15
  PT_WHITE_TRANSPARENCY (White pixel min transparency)  0.45
  PT_PALETTE (Background tint)  3   White
  PT_DARK_FILTER_LEVEL (Dark color filter)  0   off
  PT_PIXEL_BORDER (Pixel border)  0   Off
  PT_SHADOW_OFFSET_X (Shadow X offset)  1.0
  PT_SHADOW_OFFSET_Y (Shadow Y offset)  1.0
  PT_SHADOW_OPACITY (Shadow opacity)  0.20
  PT_SHADOW_BLUR (Shadow blur amount)  1.5
  PT_HALATION (Halation glow)  0.08   front-lit diffuser glow
  PT_DITHER (Dither blend edges)  1.0   on
  PT_VIGNETTE (Vignette strength)  0.05

  HIDDEN PARAMETERS  (edit in PT_SkyWalker541_Pro.glsl)
  ─────────────────────────────────────────────────────────────────
  PT_BRIGHTNESS_MODE         1.0        (Perceptual)
  PT_PALETTE_INTENSITY       1.0
  PT_GRAIN_INTENSITY         0.03       (very clean backing)
  PT_GRAIN_SCALE             0.15
  PT_SHADOW_BLUR_RADIUS      1.0
  PT_HALATION_RADIUS         1.5
  PT_HALATION_WARMTH         0.30       (warm white matching SP front light)
  PT_DITHER_STRENGTH         0.02
  PT_DITHER_MATRIX           1.0        (4x4)
  PT_SUBPIXEL_STRENGTH       0.30       (fine pixel pitch)
  PT_TIGHT_BLOOM             0.10       (front-light diffuser bleed)
  PT_TIGHT_BLOOM_RADIUS      0.6
  PT_WARP_STRENGTH           0.02       (flatter form factor)
  PT_SHEEN_STRENGTH          0.0        (off — front-lit, not reflective)
  PT_CHROMA_STRENGTH         0.0        (off)

---

```
┌──────────────────────────────────────────────────────────────────┐
│  Game Boy Advance Original (no backlight)  —  PT_SYSTEM = 4      │
└──────────────────────────────────────────────────────────────────┘
```

The original GBA had a dim, washed-out reflective screen with no backlight — notoriously
difficult to read in poor lighting. Colours were desaturated and whites appeared creamy or
yellowish due to the LCD polariser and backing material. The transparency effect is more
pronounced here than on any other system. The Green-grey palette option captures the
distinctive yellowish-green tint of the original GBA backing.

  CORE SETTINGS  (mGBA)
  ─────────────────────────────────────────────────────────────────
  Color correction           Enabled
  Interframe blending        Enabled

  SHADER PARAMETERS
  ─────────────────────────────────────────────────────────────────
  PT_SYSTEM (System)  4   GBA Orig
  PT_PIXEL_MODE (Transparency mode)  0   White only
  PT_BASE_ALPHA (Base transparency)  0.25
  PT_WHITE_TRANSPARENCY (White pixel min transparency)  0.55
  PT_PALETTE (Background tint)  4   Green-grey — matches original GBA polariser tint
  PT_DARK_FILTER_LEVEL (Dark color filter)  0   off
  PT_PIXEL_BORDER (Pixel border)  0   Off
  PT_SHADOW_OFFSET_X (Shadow X offset)  1.0
  PT_SHADOW_OFFSET_Y (Shadow Y offset)  1.0
  PT_SHADOW_OPACITY (Shadow opacity)  0.20
  PT_SHADOW_BLUR (Shadow blur amount)  1.0
  PT_HALATION (Halation glow)  0.0   off — no backlight
  PT_DITHER (Dither blend edges)  1.0   on
  PT_VIGNETTE (Vignette strength)  0.12

  HIDDEN PARAMETERS  (edit in PT_SkyWalker541_Pro.glsl)
  ─────────────────────────────────────────────────────────────────
  PT_BRIGHTNESS_MODE         1.0        (Perceptual)
  PT_PALETTE_INTENSITY       1.0
  PT_GRAIN_INTENSITY         0.08
  PT_GRAIN_SCALE             0.20
  PT_SHADOW_BLUR_RADIUS      1.0
  PT_DITHER_STRENGTH         0.05
  PT_DITHER_MATRIX           1.0        (4x4)
  PT_SUBPIXEL_STRENGTH       0.20       (reflective panel, subtle effect)
  PT_TIGHT_BLOOM             0.0        (off — no backlight)
  PT_WARP_STRENGTH           0.02       (similar form factor to SP)
  PT_SHEEN_STRENGTH          0.05       (reflective screen)
  PT_CHROMA_STRENGTH         0.0        (off)

---

```
╔══════════════════════════════════════════════════════════════════╗
║  HOW IT WORKS                                                    ║
╚══════════════════════════════════════════════════════════════════╝
```

This is a single-pass shader. It uses RetroArch's built-in Original texture semantic, which
provides the raw unprocessed input frame directly — no passthrough pass required.

The shader has access to two textures at all times:

  Source   — the colour-corrected processed frame, used for display output, shadow sampling,
             and halation
  Original — the raw pre-correction input frame, used exclusively for white pixel detection,
             transparency gating, and shadow blur

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

Some values are not exposed in the menu — these are Advanced Defaults controlled via #define
constants in the .slang file. They are noted as (hidden) throughout this section and can be
found and edited in the Advanced Defaults block near the top of PT_SkyWalker541_Pro.glsl.

---

System Preset — PT_SYSTEM
  Default: 1 (GB)

  The most important setting. Set this first. Determines the white detection threshold tuned
  for each system's display characteristics.

  Value  System              Threshold
  -----  ------------------  ----------------------------------------
  0      Manual              Use PT_SENSITIVITY to set your own
  1      GB / Pocket         0.90  no backlight, aggressive detection
  2      GBC                 0.85  no backlight, moderate
  3      GBA SP              0.80  front-lit, conservative
  4      GBA Original        0.75  no backlight, dim whites, most aggressive

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

Brightness Mode — PT_BRIGHTNESS_MODE  (hidden)
  Default: 0 (Simple)
  Edit PT_BRIGHTNESS_MODE_DEFAULT in the Advanced Defaults block.

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
  2      Cool grey    Neutral grey — good for GBC
  3      White        Clean white — recommended for GBA SP
  4      Green-grey   Yellowish-green — matches the original GBA polariser tint

---

Background Tint Intensity — PT_PALETTE_INTENSITY  (hidden)
  Default: 1.00  |  Range: 0.00 – 2.00
  Edit PT_PALETTE_INTENSITY_DEFAULT in the Advanced Defaults block.

  Controls how strongly the tint colour is applied. 0 = no tint regardless of PT_PALETTE.

---

Grain Intensity — PT_GRAIN_INTENSITY  (hidden)
  Default: 0.065  |  Range: 0.00 – 0.50
  Edit PT_GRAIN_INTENSITY_DEFAULT in the Advanced Defaults block.

  Controls how visible the procedural backing grain is.
  GB backing was visibly textured (0.10), GBA SP backing was very clean (0.03).

---

Grain Scale — PT_GRAIN_SCALE  (hidden)
  Default: 0.25  |  Range: 0.05 – 1.00
  Edit PT_GRAIN_SCALE_DEFAULT in the Advanced Defaults block.

  Controls the size of the grain pattern.
  Lower = finer grain. Higher = coarser grain.

---

Colour Harshness Filter — PT_DARK_FILTER_LEVEL
  Default: 0  |  Range: 0 – 100

  Softens overly vivid or harsh dark colours, simulating the way original LCD screens
  compressed and desaturated dark tones. Most useful for GBC games. 0 = off.

---

Pixel Border — PT_PIXEL_BORDER
  Default: 1 (Subtle)

  Simulates the physical gap between individual LCD dots on original hardware. Uses a
  sine-wave method that works correctly at any scale mode.

  Value  Style     Description
  -----  --------  -------------------------------------------------------
  0      Off       No pixel border — recommended for GBA
  1      Subtle    ~17% border darkening — recommended for GB/GBC
  2      Moderate  ~41% border darkening
  3      Strong    ~76% border darkening — very visible pixel grid

---

Shadow X Offset — PT_SHADOW_OFFSET_X
  Default: 1.0  |  Range: -10.0 – 10.0

  Horizontal position of the drop shadow in source texels. Positive = right, negative = left.
  Set PT_SHADOW_OPACITY to 0 to disable shadows and skip all shadow texture taps.

---

Shadow Y Offset — PT_SHADOW_OFFSET_Y
  Default: 1.0  |  Range: -10.0 – 10.0

  Vertical position of the drop shadow in source texels. Positive = down, negative = up.

---

Shadow Opacity — PT_SHADOW_OPACITY
  Default: 0.30  |  Range: 0.00 – 1.00

  How dark the drop shadow is. Set to 0 to disable shadows entirely.

---

Shadow Blur — PT_SHADOW_BLUR
  Default: 1.0  |  Range: 0.00 – 5.00

  Directional gaussian blur on the drop shadow. Samples spread along the shadow vector with
  gaussian weighting. 0 = hard shadow edge (same as standard shader). Recommended: 0.5 – 2.0.

---

Shadow Blur Radius — PT_SHADOW_BLUR_RADIUS  (hidden)
  Default: 1.0  |  Range: 0.10 – 4.00
  Edit PT_SHADOW_BLUR_RADIUS_DEFAULT in the Advanced Defaults block.

  How far the blur spreads from the shadow origin in source texels.
  0.5 = tight.  1.0 = natural.  2.0 = wide, very soft shadow.

---

Halation — PT_HALATION
  Default: 0.0  |  Range: 0.00 – 1.00

  Simulates light scattering through the diffuser layer of a front-lit screen. Bright pixels
  bleed a soft warm glow into surrounding transparent areas. Only physically present on screens
  with a backlight — leave at 0 for GB, GBC, and GBA Original. For GBA SP: 0.05 – 0.10.

---

Halation Radius — PT_HALATION_RADIUS  (hidden)
  Default: 1.5  |  Range: 0.10 – 5.00
  Edit PT_HALATION_RADIUS_DEFAULT in the Advanced Defaults block.

  Radius of the halation glow in source texels. Recommended for GBA SP: 1.0 – 2.0.

---

Halation Warmth — PT_HALATION_WARMTH  (hidden)
  Default: 0.3  |  Range: 0.00 – 1.00
  Edit PT_HALATION_WARMTH_DEFAULT in the Advanced Defaults block.

  Colour temperature of the halation glow.
  0.0 = cool white.  0.3 = warm white (GBA SP front light).  1.0 = warm amber.

---

Dithering — PT_DITHER
  Default: 1.0 (on)  |  0 = off, 1 = on

  Applies a Bayer ordered dither pattern at the transparency blend boundary. Replicates the
  natural dithering produced by the slow pixel response of original LCD panels.

---

Dither Strength — PT_DITHER_STRENGTH  (hidden)
  Default: 0.05  |  Range: 0.00 – 0.20
  Edit PT_DITHER_STRENGTH_DEFAULT in the Advanced Defaults block.

  How much the dither pattern offsets the blend alpha. Keep small — the original effect was
  subtle. Recommended: GB 0.06, GBC 0.04, GBA SP 0.02, GBA Orig 0.05.

---

Dither Matrix — PT_DITHER_MATRIX  (hidden)
  Default: 1 (4x4)
  Edit PT_DITHER_MATRIX_DEFAULT in the Advanced Defaults block.

  Value  Matrix  Description
  -----  ------  -------------------------------------------------------
  0      2x2     Coarse visible pattern — fastest
  1      4x4     Balanced — recommended for most uses
  2      8x8     Finest pattern — most subtle and authentic

---

Vignette — PT_VIGNETTE
  Default: 0.08  |  Range: 0.00 – 1.00

  Darkens the corners and edges of the screen, simulating uneven ambient light distribution.
  Pure math — no extra texture samples. Set to 0 to disable.

---

```
╔══════════════════════════════════════════════════════════════════╗
║  HIDDEN PARAMETERS                                               ║
╚══════════════════════════════════════════════════════════════════╝
```

The following parameters are not accessible from the RetroArch shader menu. To change them,
open PT_SkyWalker541_Pro.slang in a text editor and edit the values in the Advanced Defaults
block near the top of the file. All default to 0.0 (off).

---

Subpixel Layout — PT_SUBPIXEL_STRENGTH
  Default: 0.0 (off)  |  Suggested range: 0.20 – 0.40
  Edit PT_SUBPIXEL_STRENGTH_DEFAULT in the Advanced Defaults block.

  Simulates the RGB vertical stripe subpixel structure of the original LCD panels. Modulates
  R, G, and B channels independently based on horizontal sub-pixel position within each logical
  pixel, using smoothstep transitions for natural-looking colour fringing at pixel edges.

  System          Recommended value
  ──────────────  ─────────────────────────────────────────────────────
  GB / Pocket     0.0   monochrome panel — no colour subpixels, leave off
  GBC             0.25  colour LCD, visible subpixel structure
  GBA SP          0.30  slightly finer pixel pitch than GBC
  GBA Original    0.20  reflective panel, subtler effect appropriate

---

Tight Bloom — PT_TIGHT_BLOOM / PT_TIGHT_BLOOM_RADIUS
  Default: 0.0 (off) / 0.6 texels
  Edit PT_TIGHT_BLOOM_DEFAULT and PT_TIGHT_BLOOM_RADIUS_DEFAULT in the Advanced Defaults block.

  Close-range pixel bleed between adjacent bright pixels through the front-light diffuser.
  Distinct from PT_HALATION (wide area glow) — this models the tight, immediate bleed into
  direct neighbours. Only physically meaningful for the GBA SP.

  System          PT_TIGHT_BLOOM    PT_TIGHT_BLOOM_RADIUS
  ──────────────  ────────────────  ──────────────────────
  GB / Pocket     0.0               —  no backlight
  GBC             0.0               —  no backlight
  GBA SP          0.10 – 0.15       0.5 – 0.8
  GBA Original    0.0               —  no backlight

---

Screen Warp — PT_WARP_STRENGTH
  Default: 0.0 (off)  |  Suggested range: 0.02 – 0.06
  Edit PT_WARP_STRENGTH_DEFAULT in the Advanced Defaults block.

  Subtle barrel distortion simulating the slight curvature of the physical screen glass. Applied
  to the texture sampling UV so the entire rendered image warps together correctly. Pixel border
  and vignette are applied in warped space so they follow the image geometry.

  System          Recommended value
  ──────────────  ─────────────────────────────────────────────────────
  GB / Pocket     0.03 – 0.05  visibly curved glass under thick plastic bezel
  GBC             0.03         similar construction to DMG
  GBA SP          0.02         flatter form factor, more subtle
  GBA Original    0.02         similar to SP

---

Reflective Sheen — PT_SHEEN_STRENGTH
  Default: 0.0 (off)  |  Suggested range: 0.03 – 0.08
  Edit PT_SHEEN_STRENGTH_DEFAULT in the Advanced Defaults block.

  Subtle edge brightening simulating ambient light bouncing off the reflective LCD surface.
  Inverse radial gradient — brightens toward the screen edges and corners. The opposite of
  vignette. Only physically meaningful for reflective screens.

  System          Recommended value
  ──────────────  ─────────────────────────────────────────────────────
  GB / Pocket     0.05 – 0.08  strong ambient reflection on matte green-grey backing
  GBC             0.04 – 0.06  slightly cleaner surface than DMG
  GBA SP          0.0          front-lit — not a reflective screen, leave off
  GBA Original    0.04 – 0.06  reflective screen, similar to GBC

---

Chromatic Shift — PT_CHROMA_STRENGTH
  Default: 0.0 (off)  |  Suggested range: 0.3 – 0.8
  Edit PT_CHROMA_STRENGTH in the Advanced Defaults block.

  Radial RGB channel separation from the screen centre — R shifts slightly outward, B shifts
  slightly inward. Adds a very mild optical fringing effect at the edges of the image.
  Zero GPU cost at default value.

---

```
╔══════════════════════════════════════════════════════════════════╗
║  PERFORMANCE                                                     ║
╚══════════════════════════════════════════════════════════════════╝
```

All Pro features can be individually disabled. To reduce GPU load on lower-end hardware,
disable in this order:

  1. PT_SHADOW_BLUR = 0          biggest saving — removes 15-tap directional blur
  2. PT_HALATION = 0             removes 8-tap radial glow
  3. PT_TIGHT_BLOOM = 0          removes 4-tap tight bloom (if enabled)
  4. PT_DITHER = 0               minor saving — removes Bayer matrix lookup
  5. PT_PIXEL_BORDER = 0         minor saving — removes per-fragment trig
  6. PT_SUBPIXEL_STRENGTH = 0.0  removes subpixel mask (if enabled)
  7. PT_WARP_STRENGTH = 0.0      removes barrel distortion (if enabled)
  8. PT_SHEEN_STRENGTH = 0.0     removes reflective sheen (if enabled)

With all Pro features disabled, performance is equivalent to PT_SkyWalker541.slang.

---

```
╔══════════════════════════════════════════════════════════════════╗
║  EDITING DEFAULT VALUES                                          ║
╚══════════════════════════════════════════════════════════════════╝
```

Menu-exposed parameters have their defaults set via #pragma parameter declarations at the top
of the file. Edit the fifth number on any line to change its default:

    #pragma parameter PT_SYSTEM  "..."  1.0  0.0  4.0  1.0
                                        ^^^
                                        default value

Hidden Advanced Default parameters are set in the #define block near the top of the file:

    #define PT_BRIGHTNESS_MODE_DEFAULT    0.0
    #define PT_PALETTE_INTENSITY_DEFAULT  1.0
    #define PT_GRAIN_INTENSITY_DEFAULT    0.065
    #define PT_GRAIN_SCALE_DEFAULT        0.25
    #define PT_SHADOW_BLUR_RADIUS_DEFAULT 1.0
    #define PT_HALATION_RADIUS_DEFAULT    1.5
    #define PT_HALATION_WARMTH_DEFAULT    0.3
    #define PT_DITHER_STRENGTH_DEFAULT    0.05
    #define PT_DITHER_MATRIX_DEFAULT      1.0
    #define PT_SUBPIXEL_STRENGTH_DEFAULT  0.0
    #define PT_TIGHT_BLOOM_DEFAULT        0.0
    #define PT_TIGHT_BLOOM_RADIUS_DEFAULT 0.6
    #define PT_WARP_STRENGTH_DEFAULT      0.0
    #define PT_SHEEN_STRENGTH_DEFAULT     0.0
    #define PT_CHROMA_STRENGTH            0.0

All values load when the preset is first applied. Menu-exposed ones can still be adjusted live
from the shader parameters menu at any time. Hidden values require a file edit and shader reload.

---

```
╔══════════════════════════════════════════════════════════════════╗
║  COMPATIBILITY                                                   ║
╚══════════════════════════════════════════════════════════════════╝
```

Works on any RetroArch-supported platform and display resolution. The shader works at any
scale mode — aspect ratio, integer, or custom — no separate variants required.

Requires a RetroArch video driver that supports GLSL shaders: gl or glcore. Does not work
with the Vulkan driver — use PT_SkyWalker541_Pro.slangp for Vulkan.

---

*PT SkyWalker541 Pro by SkyWalker541 | v1.5.2 | Written for RetroArch*
