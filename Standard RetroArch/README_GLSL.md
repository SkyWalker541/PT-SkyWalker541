PT SkyWalker541
Pixel Transparency Shader for RetroArch — GLSL
by SkyWalker541 | v1.7.1 | works on gl / glcore drivers

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

───────────────────────────────────────────────────────────────────────────────

  INSTALLATION
  ─────────────────────────────────────────────────────────────────

  RetroArch (standard installation)
  ─────────────────────────────────────────────────────────────────

RetroArch expects the preset and shader in separate locations:

    shaders/
        PT_SkyWalker541.glslp       ← place the preset here
        shaders/
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

  ─────────────────────────────────────────────────────────────────

  NextUI
  ─────────────────────────────────────────────────────────────────

NextUI places both the preset and shader in the same folder. Place both
files together in your shader folder:

    PT_SkyWalker541.glslp
    PT_SkyWalker541.glsl

Because both files are in the same folder, the preset's shader path must
be edited before use. Open PT_SkyWalker541.glslp in any text editor and
change the shader path from:

    shader0 = shaders/PT_SkyWalker541.glsl

to:

    shader0 = PT_SkyWalker541.glsl

Save the file. The preset will now find the shader correctly in NextUI.

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

  [Grid]     Grid strength   default: 0.08
    Strength of the gap between pixels. Higher values produce a more
    visible grid. Dial to taste. 0 = off.

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

  [LCD Dot]  Dot brightness compensation   default: 0.0
    Compensates for overall brightness lost to the inter-dot gaps.
    Raise slowly if the image appears too dark with LCD Dot enabled.
    0 = no compensation.

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

  [Phosphor] Phosphor brightness comp   default: 0.0
    Compensates for brightness lost to subpixel masking. Raise slowly
    if the image appears too dark with CRT Phosphor enabled.
    0 = no compensation.

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
    #define PT_SENSITIVITY        0.85   Manual sensitivity threshold
    #define PT_PIXEL_MODE         0.0    Pixel mode
    #define PT_BASE_ALPHA         0.20   Base transparency amount
    #define PT_WHITE_TRANSPARENCY 0.20   White pixel min transparency
    #define PT_PALETTE            1.0    Background tint
    #define PT_PALETTE_INTENSITY  1.0    Tint intensity
    #define PT_DARK_FILTER_LEVEL  0.0    Dark color filter
    #define PT_GRID_MODE          1.0    Pixel Effect
    #define PT_GRID_STRENGTH      0.08   [Grid] Grid strength
    #define PT_DOT_SIZE           0.50   [LCD Dot] Dot size
    #define PT_DOT_SHARPNESS      0.0    [LCD Dot] Dot sharpness
    #define PT_DOT_BRIGHTNESS     0.0    [LCD Dot] Dot brightness compensation
    #define PT_PHOS_SIZE          0.50   [Phosphor] Phosphor dot size
    #define PT_PHOS_BLOOM         0.0    [Phosphor] Bloom spread
    #define PT_PHOS_GAMMA         2.40   [Phosphor] Dot gamma
    #define PT_PHOS_BRIGHTNESS    0.0    [Phosphor] Phosphor brightness comp
    #define PT_PHOS_SCANLINE      0.0    [Phosphor] Scanline strength
    #define PT_PHOS_LAYOUT        0.0    [Phosphor] Subpixel layout
    #define PT_BLACK_THRESHOLD    0.15   [Dot/Phosphor] Black level threshold
    #define PT_SHADOW_OFFSET      1.0    Shadow offset
    #define PT_SHADOW_OPACITY     0.30   Shadow opacity
    #define PT_BEZEL              0.40   Bezel shadow strength

Change the value on the right of any line to set a new default.

───────────────────────────────────────────────────────────────────────────────

PT SkyWalker541 by SkyWalker541 | v1.7.1 | Written for RetroArch
