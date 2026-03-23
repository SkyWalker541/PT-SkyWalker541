PT SkyWalker541
Pixel Transparency Shader for RetroArch — GLSL
by SkyWalker541 | v1.6.0 | works on gl / glcore drivers

Inspired by mattakins' pixel transparency work.

───────────────────────────────────────────────────────────────────────────────

On original Game Boy, Game Boy Color, and Game Boy Advance hardware, pixels
that were fully off didn't show as white — the physical backing material showed
through instead. Game developers designed around this, using white areas as
intentional transparent zones. On modern displays those same pixels render as
bright white. PT SkyWalker541 restores the original appearance by detecting
white and bright pixels and blending them toward a procedurally generated
backing texture.

───────────────────────────────────────────────────────────────────────────────

  INSTALLATION
  ─────────────────────────────────────────────────────────────────

Place both files in the same folder in your RetroArch shaders directory:

    PT_SkyWalker541.glslp
    PT_SkyWalker541.glsl

  1. Launch a game
  2. Quick Menu > Shaders > Load Shader Preset
  3. Open Shader Parameters and set PT_SYSTEM to match your system
  4. Apply the recommended settings from the section below
  5. Save via Save Shader Preset As for automatic loading in future sessions

───────────────────────────────────────────────────────────────────────────────

  PARAMETERS
  ─────────────────────────────────────────────────────────────────

Accessible from Quick Menu > Shaders > Shader Parameters after loading.

  PT_SYSTEM            default: 1
    Selects the hardware preset. Sets white detection threshold and
    bezel shadow width automatically. 0=Manual, 1=GB, 2=GBC,
    3=GBA SP, 4=GBA Orig.

  PT_SENSITIVITY       default: 0.85
    Only active when PT_SYSTEM = 0. Sets the white detection threshold
    manually. Use this when colorization is enabled or when the
    hardware presets do not detect correctly.

  PT_PIXEL_MODE        default: 0
    Which pixels receive transparency. 0=White only, 1=Bright,
    2=All pixels. White only is the most accurate.

  PT_BASE_ALPHA        default: 0.20
    How transparent detected pixels become. Lower = more opaque.

  PT_WHITE_TRANSPARENCY   default: 0.20
    Minimum transparency floor for confirmed white pixels. Ensures
    white pixels are always at least this transparent regardless of
    PT_BASE_ALPHA.

  PT_PALETTE           default: 1
    Tint colour of the procedural backing texture. 0=Off, 1=Pocket
    (warm green-grey, DMG/Pocket), 2=Grey (GBC/GBA Original),
    3=White (GBA SP).

  PT_PALETTE_INTENSITY    default: 1.00
    How strongly the tint colour is applied. 0 = no tint.
    Raise above 1.0 on LCD screens if the tint feels too subtle.

  PT_DARK_FILTER_LEVEL    default: 0
    Softens overly vivid dark colours. Most useful for GBC games with
    aggressive colour palettes. 0 = off.

  PT_PIXEL_BORDER      default: 0.08
    Simulates the thin gap between individual LCD pixels. Continuous
    range — dial to taste. 0 = off.

  PT_SHADOW_OFFSET     default: 1.0
    Distance of the drop shadow in texels. Moves X and Y together.

  PT_SHADOW_OPACITY    default: 0.30
    Strength of the drop shadow. 0 = off.

  PT_BEZEL             default: 0.40
    Darkens screen edges to simulate the shadow cast by the physical
    bezel onto the LCD panel. Width is set automatically per PT_SYSTEM.
    0 = off.

───────────────────────────────────────────────────────────────────────────────

  RECOMMENDED SETTINGS PER SYSTEM
  ─────────────────────────────────────────────────────────────────

Set PT_SYSTEM first. The following are set automatically by PT_SYSTEM
and do not need manual adjustment:

  White detection threshold
  Bezel shadow width

All other parameters use the defaults listed above unless noted below.

───────────────────────────────────────────────────────────────────────────────

  Game Boy DMG / Pocket  —  PT_SYSTEM = 1
  ─────────────────────────────────────────────────────────────────

The DMG and Pocket used a slow reflective LCD with no backlight. The
backing material was a distinctive matte green-grey visible through
unlit pixels. The bezel had a deep recess casting a pronounced shadow.

  CORE SETTINGS  (Gambatte / SameBoy)
  ─────────────────────────────────────────────────────────────────
  Color correction           Disabled
  Interframe blending        Disabled
  GB Colorization            Disabled

  Note: If using GB colorization, set PT_SYSTEM = 0 and adjust
  PT_SENSITIVITY until backgrounds go transparent.

  SHADER PARAMETERS
  ─────────────────────────────────────────────────────────────────
  PT_SYSTEM              1
  PT_PALETTE             1    (Pocket)

  All other parameters use defaults.

───────────────────────────────────────────────────────────────────────────────

  Game Boy Color  —  PT_SYSTEM = 2
  ─────────────────────────────────────────────────────────────────

Similar reflective LCD to the DMG but with improved colour response.
No backlight. The backing was cleaner and more neutral than the DMG.

  CORE SETTINGS  (Gambatte / SameBoy)
  ─────────────────────────────────────────────────────────────────
  Color correction           GBC Only
  Interframe blending        Disabled

  SHADER PARAMETERS
  ─────────────────────────────────────────────────────────────────
  PT_SYSTEM              2
  PT_PALETTE             1    (Pocket)
  PT_DARK_FILTER_LEVEL   10

  All other parameters use defaults.

───────────────────────────────────────────────────────────────────────────────

  Game Boy Advance SP (front-lit)  —  PT_SYSTEM = 3
  ─────────────────────────────────────────────────────────────────

The GBA SP had a front-lit screen — brighter and more vivid than any
earlier Game Boy. Whites are genuinely bright. The transparency effect
is subtler. The bezel was thin with minimal shadow.

  CORE SETTINGS  (mGBA)
  ─────────────────────────────────────────────────────────────────
  Color correction           Enabled
  Interframe blending        Enabled

  SHADER PARAMETERS
  ─────────────────────────────────────────────────────────────────
  PT_SYSTEM              3
  PT_BASE_ALPHA          0.15
  PT_WHITE_TRANSPARENCY  0.45
  PT_PALETTE             3    (White)
  PT_SHADOW_OPACITY      0.20
  PT_BEZEL               0.30

───────────────────────────────────────────────────────────────────────────────

  Game Boy Advance Original  —  PT_SYSTEM = 4
  ─────────────────────────────────────────────────────────────────

The original GBA had a dim reflective screen with no backlight. Colours
were desaturated and whites appeared creamy. The transparency effect is
more pronounced than on any other system.

  CORE SETTINGS  (mGBA)
  ─────────────────────────────────────────────────────────────────
  Color correction           Enabled
  Interframe blending        Enabled

  SHADER PARAMETERS
  ─────────────────────────────────────────────────────────────────
  PT_SYSTEM              4
  PT_BASE_ALPHA          0.25
  PT_WHITE_TRANSPARENCY  0.55
  PT_PALETTE             2    (Grey)
  PT_SHADOW_OPACITY      0.20

  All other parameters use defaults.

───────────────────────────────────────────────────────────────────────────────

  EDITING DEFAULT VALUES
  ─────────────────────────────────────────────────────────────────

To change a default, open PT_SkyWalker541.glsl in any text editor and
find the #define block near the top of the fragment shader:

    #define PT_SYSTEM             1.0
    #define PT_SENSITIVITY        0.85
    #define PT_PIXEL_MODE         0.0
    #define PT_BASE_ALPHA         0.20
    #define PT_WHITE_TRANSPARENCY 0.20
    #define PT_PALETTE            1.0
    #define PT_PALETTE_INTENSITY  1.0
    #define PT_DARK_FILTER_LEVEL  0.0
    #define PT_PIXEL_BORDER       0.08
    #define PT_SHADOW_OFFSET      1.0
    #define PT_SHADOW_OPACITY     0.30
    #define PT_BEZEL              0.40

Change the value on the right of any line to set a new default.

───────────────────────────────────────────────────────────────────────────────

PT SkyWalker541 by SkyWalker541 | v1.6.0 | Written for RetroArch
