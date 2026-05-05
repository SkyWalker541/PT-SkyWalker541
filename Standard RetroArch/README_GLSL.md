PT SkyWalker541
Pixel Transparency Shader for RetroArch — GLSL
by SkyWalker541 | v1.8.0 | works on gl / glcore drivers

Inspired by mattakins' pixel transparency work.
Pixel Effect dot and phosphor modes inspired by Themaister's dot shader (public domain).

───────────────────────────────────────────────────────────────────────────────

On original Game Boy, Game Boy Color, and Game Boy Advance hardware, pixels
that were fully off didn't show as white — the physical backing material showed
through instead. Game developers designed around this, using white areas as
intentional transparent zones. On modern displays those same pixels render as
bright white. PT SkyWalker541 restores the original appearance by detecting
white and bright pixels and blending them toward a procedurally generated
backing texture.

v1.7.0 added a unified Pixel Effect system replacing the previous pixel border
parameter. Three display simulation modes are available — Grid, LCD Dot, and
CRT Phosphor — each with their own dedicated parameters, tuned to run at
minimum cost when not selected.

v1.7.1 adds a Black Level Threshold parameter shared by LCD Dot and CRT
Phosphor modes. The threshold uses the raw input frame before color correction,
so unlit pixels remain clean regardless of emulator color settings. A hard gate
on truly black pixels ensures clean blacks at zero cost regardless of the
threshold setting.

v1.8.0 adds Gap / Grid Color and Gap / Grid Color Intensity parameters. The
gap / grid color applies to Grid, LCD Dot, and CRT Phosphor modes. Backing
Texture uses the already-computed backing texture at zero extra cost, with color
and appearance fully controlled by the existing Background tint and Tint
intensity parameters. Dot brightness compensation and Phosphor brightness comp
parameters have been removed — Gap / Grid Color solves brightness at the source
making them redundant. All parameter code names have been updated to closely
match their menu label names for clarity when editing defaults.

───────────────────────────────────────────────────────────────────────────────

  INSTALLATION
  ─────────────────────────────────────────────────────────────────

RetroArch expects the preset and shader in separate locations:

    shaders_glsl/handheld/
        PT_SkyWalker541.glslp       ← place the preset here
        shaders_glsl/handheld/shaders/
            PT_SkyWalker541.glsl    ← place the shader here

The preset file references the shader at:
    shaders/PT_SkyWalker541.glsl

This path is relative to RetroArch's shader root and is correct for a
standard RetroArch installation. No editing of the preset file is needed.

  1. Launch a game
  2. Quick Menu > Shaders > Load Shader Preset
  3. Navigate to PT_SkyWalker541.glslp and load it
  4. Open Shader Parameters and set System to match your hardware
  5. Apply the recommended settings from the section below
  6. Save via Save Shader Preset As for automatic loading in future sessions

───────────────────────────────────────────────────────────────────────────────

  PARAMETERS
  ─────────────────────────────────────────────────────────────────

Accessible from Quick Menu > Shaders > Shader Parameters after loading.
Parameter names below match exactly what you will see in the RetroArch menu.

  ── System ──────────────────────────────────────────────────────

  System (0=Manual, 1=GB, 2=GBC, 3=GBA SP, 4=GBA Orig)   default: 1
    Selects the hardware preset. Sets the white detection threshold
    and bezel shadow width automatically to match each system.
    Set this first before adjusting any other parameters.

  Manual sensitivity threshold   default: 0.85
    Only active when System = 0. Sets the white detection threshold
    manually. Use this when colorization is enabled or when the
    hardware presets do not detect correctly.

  ── Pixel Transparency ──────────────────────────────────────────

  Pixel mode (0=White, 1=Bright, 2=All)   default: 0
    Which pixels receive transparency. White only is the most
    accurate to original hardware. Bright includes near-white pixels.
    All applies transparency to every pixel.

  Base transparency amount   default: 0.20
    How transparent detected pixels become. Lower = more opaque and
    brighter. Higher = more of the backing texture shows through.

  White pixel min transparency   default: 0.20
    Minimum transparency floor for confirmed white pixels. Ensures
    white pixels are always at least this transparent regardless of
    Base transparency amount.

  ── Background ──────────────────────────────────────────────────

  Background tint (0=Off, 1=Pocket, 2=Grey, 3=White)   default: 1
    Tint colour of the procedural backing texture. Pocket is a warm
    green-grey matching the DMG and Pocket screen backing. Grey
    matches GBC and GBA Original. White matches GBA SP.

  Tint intensity   default: 1.00
    How strongly the tint colour is applied. 0 = no tint.
    Raise above 1.0 if the tint feels too subtle on your display.

  ── Color Filter ────────────────────────────────────────────────

  Dark color filter (0=off)   default: 0
    Softens overly vivid dark colours. Most useful for GBC games
    with aggressive colour palettes. 0 = off. Raise gradually
    until dark colours look natural.

  ── Pixel Effect ────────────────────────────────────────────────

  Pixel Effect (0=Off, 1=Grid, 2=LCD Dot, 3=CRT Phosphor)   default: 1
    Selects the pixel structure simulation effect. Each mode has its
    own dedicated parameters below. Parameters for inactive modes
    have no effect on the image and cost nothing to process.

  [Grid] parameters — active when Pixel Effect = 1
  ─────────────────────────────────────────────────────────────────

  [Grid]     Grid width   default: 0.08
    Width of the gap between pixels. Higher values produce a wider,
    more visible gap. Dial to taste. 0 = off.
    Note: Gap / Grid color intensity controls how opaque the gap color
    is within the gap. Grid width and Gap / Grid color intensity are
    independent — width sets the gap size, intensity sets the color
    visibility.

  [LCD Dot] parameters — active when Pixel Effect = 2
  ─────────────────────────────────────────────────────────────────

  [LCD Dot]  Dot size   default: 0.50
    Radius of each dot within its pixel cell. Larger values fill
    more of the cell and leave a smaller gap. Smaller values leave
    a larger gap between dots. Range 0.1 to 0.9.

  [LCD Dot]  Dot sharpness   default: 0.0
    Controls the edge of each dot. 0 = soft Gaussian falloff,
    natural and subtle. Higher values produce a harder, more defined
    dot edge. Dial to taste.

  [Phosphor] parameters — active when Pixel Effect = 3
  ─────────────────────────────────────────────────────────────────

  [Phosphor] Phosphor dot size   default: 0.50
    Size of each phosphor dot within its cell. Affects how far each
    dot reaches into neighbouring cells during bloom. Range 0.1 to 0.9.

  [Phosphor] Bloom spread   default: 0.0
    How far each phosphor dot bleeds light into surrounding gaps.
    0 = tight dots with no bleed. Higher values simulate the glow
    of lit phosphors spreading across the screen surface.

  [Phosphor] Dot gamma   default: 2.40
    Controls how quickly each phosphor dot fades from centre to edge.
    Lower = soft, diffuse dots. Higher = tight, crisp dots.
    2.40 matches a typical CRT phosphor response and is a good
    starting point.

  [Phosphor] Scanline strength   default: 0.0
    Adds a vertical brightness roll-off between pixel rows to simulate
    the dark gap between CRT scanlines. 0 = off.

  [Phosphor] Subpixel layout (0=RGB, 1=BGR)   default: 0
    Subpixel stripe order. Match this to your monitor's physical
    subpixel layout to avoid colour fringing. Most monitors use RGB.
    If colours appear fringed or shifted, switch to BGR.

  [Dot/Phosphor] shared parameter — active when Pixel Effect = 2 or 3
  ─────────────────────────────────────────────────────────────────

  [Dot/Phosphor] Black level threshold   default: 0.15
    Controls where the dot or phosphor effect fades in above black.
    Black detection uses the raw input frame before color correction,
    so unlit pixels remain clean regardless of emulator color settings.
    A hard gate on truly black pixels ensures they are always clean
    at zero cost regardless of this setting.
    0 = dot effect applies to all pixels including near-black.
    Higher values suppress dots on progressively brighter dark pixels.

  ── Gap / Grid Color ────────────────────────────────────────────

  Gap / Grid color (0=Backing Texture, 1=Black, 2=White)   default: 0
    Sets the color that appears in the gaps between pixels for Grid,
    LCD Dot, and CRT Phosphor modes. The name reflects that this
    parameter controls both the gaps in LCD Dot and CRT Phosphor modes
    and the grid lines in Grid mode.

    Backing Texture (0) — the procedural backing texture fills the gaps.
    The appearance is fully controlled by the existing background
    parameters. Background tint selects the tint color and Tint intensity
    controls how strongly it is applied. This is the most authentic option
    as it matches the physical backing material visible between pixels on
    real hardware. Uses the already-computed backing texture at zero
    extra processing cost.

    Black (1) — gaps and grid lines are darkened toward pure black.
    Gap / Grid color intensity controls how opaque the black is.
    At 1.0 gaps are fully black. At 0.0 gaps are invisible and the
    game pixel color shows through.

    White (2) — gaps and grid lines are brightened toward pure white.
    Gap / Grid color intensity controls how opaque the white is.
    At 1.0 gaps are fully white. At 0.0 gaps are invisible and the
    game pixel color shows through.

  Gap / Grid color intensity   default: 1.0
    Controls how strongly the selected gap / grid color asserts itself
    into the gaps and grid lines. Applies to all three modes.

    Backing Texture — intensity controls how strongly the backing texture
    shows in the gaps versus blending back toward the game pixel color.
    1.0 = full backing texture in gaps. 0.0 = gaps invisible.

    Black — intensity controls opacity of black in the gaps.
    1.0 = pure black gaps. 0.0 = gaps invisible.

    White — intensity controls opacity of white in the gaps.
    1.0 = pure white gaps. 0.0 = gaps invisible.

    At 0.0 all three options look identical — gaps are invisible and the
    game pixel color shows through with no gap effect.

  Parameter interactions
  ─────────────────────────────────────────────────────────────────

  Gap / Grid color = Backing Texture is affected by two other parameters:

    Background tint — selects the tint colour of the backing texture.
    Whatever tint is selected here will also appear in the pixel gaps
    when Gap / Grid color = Backing Texture. Changing Background tint
    changes the gap / grid color simultaneously.

    Tint intensity — controls how strongly the tint colour is applied
    to the backing texture. This affects both the transparency blend on
    white/bright pixels AND the gap / grid color when Gap / Grid color = Backing
    Texture. Raising Tint intensity makes the tint more visible in both
    the transparent areas and the pixel gaps.

  If you want the gaps and the transparent areas to look consistent,
  use Gap / Grid color = Backing Texture and adjust Background tint
  and Tint intensity together. This gives the most authentic hardware
  appearance.

  Gap / Grid color = Black or White are independent of all background
  parameters. Only Gap / Grid color intensity affects their appearance.

  Brightness note — Dot brightness compensation and Phosphor brightness
  comp have been removed in v1.8.0. If the image feels too dark with
  LCD Dot or CRT Phosphor enabled, switch Gap / Grid color from Black
  to Backing Texture or White, or reduce Gap / Grid color intensity. These
  options control gap brightness directly at the source rather than
  compensating after the fact.

  ── Drop Shadow ─────────────────────────────────────────────────

  Shadow offset   default: 1.0
    Distance of the drop shadow cast by solid pixels onto the backing
    texture. Moves X and Y together in texels. Negative values shift
    the shadow in the opposite direction.

  Shadow opacity (0=off)   default: 0.30
    Strength of the drop shadow. 0 = off.

  ── Bezel ───────────────────────────────────────────────────────

  Bezel shadow strength (0=off)   default: 0.40
    Darkens screen edges to simulate the shadow cast by the physical
    bezel onto the LCD panel. Width is set automatically by System.
    0 = off.

───────────────────────────────────────────────────────────────────────────────

  RECOMMENDED SETTINGS PER SYSTEM
  ─────────────────────────────────────────────────────────────────

Set System first. The following are configured automatically by System
and do not need manual adjustment:

  White detection threshold
  Bezel shadow width

All other parameters use the defaults listed above unless noted below.

───────────────────────────────────────────────────────────────────────────────

  Game Boy DMG / Pocket  —  System = 1
  ─────────────────────────────────────────────────────────────────

The DMG and Pocket used a slow reflective LCD with no backlight. The
backing material was a distinctive matte green-grey visible through
unlit pixels. The bezel had a deep recess casting a pronounced shadow.

  CORE SETTINGS  (Gambatte / SameBoy)
  ─────────────────────────────────────────────────────────────────
  Color correction           Disabled
  Interframe blending        Disabled
  GB Colorization            Disabled

  Note: If using GB colorization, set System = 0 and adjust
  Manual sensitivity threshold until backgrounds go transparent.

  SHADER PARAMETERS
  ─────────────────────────────────────────────────────────────────
  System                         1
  Background tint                1    (Pocket)

  All other parameters use defaults.

───────────────────────────────────────────────────────────────────────────────

  Game Boy Color  —  System = 2
  ─────────────────────────────────────────────────────────────────

Similar reflective LCD to the DMG but with improved colour response.
No backlight. The backing was cleaner and more neutral than the DMG.

  CORE SETTINGS  (Gambatte / SameBoy)
  ─────────────────────────────────────────────────────────────────
  Color correction           GBC Only
  Interframe blending        Disabled

  SHADER PARAMETERS
  ─────────────────────────────────────────────────────────────────
  System                         2
  Background tint                1    (Pocket)
  Dark color filter              10

  All other parameters use defaults.

───────────────────────────────────────────────────────────────────────────────

  Game Boy Advance SP (front-lit)  —  System = 3
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
  System                         3
  Base transparency amount       0.15
  White pixel min transparency   0.45
  Background tint                3    (White)
  Shadow opacity                 0.20
  Bezel shadow strength          0.30

───────────────────────────────────────────────────────────────────────────────

  Game Boy Advance Original  —  System = 4
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
  System                         4
  Base transparency amount       0.25
  White pixel min transparency   0.55
  Background tint                2    (Grey)
  Shadow opacity                 0.20

  All other parameters use defaults.

───────────────────────────────────────────────────────────────────────────────

  EDITING DEFAULT VALUES
  ─────────────────────────────────────────────────────────────────

To change a default, open PT_SkyWalker541.glsl in any text editor and
find the #define block near the top of the fragment shader. The menu
name for each parameter is shown alongside for reference:

    #define PT_SYSTEM             1.0    System
    #define PT_MANUAL_SENSITIVITY_THRESHOLD        0.85   Manual sensitivity threshold
    #define PT_PIXEL_MODE         0.0    Pixel mode
    #define PT_BASE_TRANSPARENCY_AMOUNT         0.20   Base transparency amount
    #define PT_WHITE_PIXEL_MIN_TRANSPARENCY 0.20   White pixel min transparency
    #define PT_BACKGROUND_TINT            1.0    Background tint
    #define PT_TINT_INTENSITY  1.0    Tint intensity
    #define PT_DARK_COLOR_FILTER  0.0    Dark color filter
    #define PT_PIXEL_EFFECT          1.0    Pixel Effect
    #define PT_GRID_WIDTH      0.08   [Grid] Grid width
    #define PT_DOT_SIZE           0.50   [LCD Dot] Dot size
    #define PT_DOT_SHARPNESS      0.0    [LCD Dot] Dot sharpness
    #define PT_PHOSPHOR_DOT_SIZE          0.50   [Phosphor] Phosphor dot size
    #define PT_PHOSPHOR_BLOOM_SPREAD         0.0    [Phosphor] Bloom spread
    #define PT_PHOSPHOR_DOT_GAMMA         2.40   [Phosphor] Dot gamma
    #define PT_PHOSPHOR_SCANLINE_STRENGTH      0.0    [Phosphor] Scanline strength
    #define PT_PHOSPHOR_SUBPIXEL_LAYOUT        0.0    [Phosphor] Subpixel layout
    #define PT_BLACK_LEVEL_THRESHOLD    0.15   [Dot/Phosphor] Black level threshold
    #define PT_GAP_GRID_COLOR          0.0    Gap / Grid color
    #define PT_GAP_GRID_COLOR_INTENSITY      1.0    Gap / Grid color intensity
    #define PT_SHADOW_OFFSET      1.0    Shadow offset
    #define PT_SHADOW_OPACITY     0.30   Shadow opacity
    #define PT_BEZEL_SHADOW_STRENGTH              0.40   Bezel shadow strength

Change the value on the right of any line to set a new default.

───────────────────────────────────────────────────────────────────────────────

PT SkyWalker541 by SkyWalker541 | AI Assisted Development | v1.8.0 | Written for RetroArch
