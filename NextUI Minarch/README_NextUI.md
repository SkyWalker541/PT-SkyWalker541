PT SkyWalker541 NextUI
Pixel Transparency Shader for NextUI / minarch
by SkyWalker541 | v1.7.1

Inspired by mattakins' pixel transparency work.
Pixel Effect LCD Dot mode inspired by Themaister's dot shader (public domain).

───────────────────────────────────────────────────────────────────────────────

On original Game Boy, Game Boy Color, and Game Boy Advance hardware, pixels
that were fully off didn't show as white — the physical backing material showed
through instead. Game developers designed around this, using white areas as
intentional transparent zones. On modern displays those same pixels render as
bright white. PT SkyWalker541 restores the original appearance by detecting
white and bright pixels and blending them toward a procedurally generated
backing texture.

v1.7.1 replaces the previous pixel border parameter with a unified Pixel Effect
system. Grid and LCD Dot modes are now available, each with dedicated parameters
that cost nothing to process when their mode is not selected.

───────────────────────────────────────────────────────────────────────────────

  NEXTUI VERSION — KEY DIFFERENCES
  ─────────────────────────────────────────────────────────────────

The RetroArch version of this shader uses RetroArch's built-in OrigTexture
uniform to run white detection and black level gating against the raw
unprocessed game frame. This gives clean, accurate detection that does not
require threshold compensation.

NextUI does not provide OrigTexture. This version detects white pixels and
the LCD Dot black level gate against the post-processed frame instead. The
detection thresholds are pre-compensated for NextUI's post-processing pipeline
to produce accurate results. This means:

  - Thresholds are lower than the RetroArch version
  - The LCD Dot black level threshold may need slight adjustment compared
    to the RetroArch version due to the post-processed frame difference
  - If white detection seems off, set System = 0 and adjust
    Manual sensitivity threshold until backgrounds go transparent correctly
  - When NextUI adds OrigTexture support this shader will be updated to
    match the RetroArch version's architecture

Previous NextUI versions required two separate files — Aspect and Integer —
because the sine-wave pixel border behaved differently at different scale
modes. This version uses a fract/abs pixel border that works correctly at
any scale mode, so one file covers both integer and aspect ratio scaling.

───────────────────────────────────────────────────────────────────────────────

  INSTALLATION
  ─────────────────────────────────────────────────────────────────

Place the files in the correct folders in your NextUI shaders directory:

    Shaders/PT_SkyWalker541_NextUI.cfg
    Shaders/glsl/PT_SkyWalker541_NextUI.glsl

Apply via your NextUI shader settings.

───────────────────────────────────────────────────────────────────────────────

  PARAMETERS
  ─────────────────────────────────────────────────────────────────

Parameter names below match exactly what you will see in the NextUI menu.

  ── System ──────────────────────────────────────────────────────

  System (0=Manual, 1=GB, 2=GBC, 3=GBA SP, 4=GBA Orig)   default: 1
    Selects the hardware preset. Sets the white detection threshold
    and bezel shadow width automatically to match each system.
    Set this first before adjusting any other parameters.

  Manual sensitivity threshold   default: 0.52   range: 0.35 to 0.75
    Only active when System = 0. Sets the white detection threshold
    manually. Range is restricted to the effective zone for NextUI's
    post-processed frame. Use this when colorization is enabled or
    when the hardware presets do not detect correctly.

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
    Note: tint appears more subtle on LCD screens than OLED. Raise
    Tint intensity above 1.0 if the tint feels too subtle.

  Tint intensity   default: 1.00
    How strongly the tint colour is applied. 0 = no tint.

  ── Color Filter ────────────────────────────────────────────────

  Dark color filter (0=off)   default: 0
    Softens overly vivid dark colours. Most useful for GBC games
    with aggressive colour palettes. 0 = off. Raise gradually
    until dark colours look natural.

  ── Pixel Effect ────────────────────────────────────────────────

  Pixel Effect (0=Off, 1=Grid, 2=LCD Dot)   default: 1
    Selects the pixel structure simulation effect. Each mode has its
    own dedicated parameters below. Parameters for inactive modes
    have no effect on the image and cost nothing to process.
    Note: CRT Phosphor is not available in the NextUI version.

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

  [LCD Dot]  Black level threshold   default: 0.15
    Controls where the dot effect fades in above black. Uses the
    post-processed frame brightness since OrigTexture is not
    available in NextUI. May need slight adjustment compared to
    the RetroArch version.
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

  DETECTION THRESHOLDS
  ─────────────────────────────────────────────────────────────────

This version uses lower thresholds than the RetroArch version to compensate
for NextUI's post-processing pipeline. If backgrounds are not going transparent
as expected, set System = 0 and adjust Manual sensitivity threshold manually.

  System       RetroArch threshold   NextUI threshold
  ─────────    ───────────────────   ────────────────
  1 (GB)       0.90                  0.62
  2 (GBC)      0.85                  0.68
  3 (GBA SP)   0.80                  0.45
  4 (GBA Orig) 0.75                  0.42

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

  CORE SETTINGS
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

  CORE SETTINGS
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

  CORE SETTINGS
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

  CORE SETTINGS
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

To change a default, open PT_SkyWalker541_NextUI.glsl in any text editor
and find the #define block near the top of the fragment shader. The menu
name for each parameter is shown alongside for reference:

    #define PT_SYSTEM             1.0    System
    #define PT_SENSITIVITY        0.52   Manual sensitivity threshold
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
    #define PT_BLACK_THRESHOLD    0.15   [LCD Dot] Black level threshold
    #define PT_SHADOW_OFFSET      1.0    Shadow offset
    #define PT_SHADOW_OPACITY     0.30   Shadow opacity
    #define PT_BEZEL              0.40   Bezel shadow strength

Change the value on the right of any line to set a new default.

───────────────────────────────────────────────────────────────────────────────

PT SkyWalker541 NextUI by SkyWalker541 | AI Assisted Development | v1.7.1 | Written for NextUI / minarch
