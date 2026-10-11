PT SkyWalker541
Pixel Transparency Shader for RetroArch and NextUI — GLSL
by SkyWalker541 | v2.1.0 | works on gl / glcore drivers

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

  WHAT'S NEW IN v2.1.0
  ─────────────────────────────────────────────────────────────────

v2.1.0 is a feature release. It adds one optional feature, Glare and sheen,
and it is OFF by default. With the default settings the picture is identical
to v2.0.1. No parameter was renamed, removed or changed, so settings saved
with v2.0.x keep working. Just replace the shader file.

  - Glare and sheen (optional): a soft hotspot of light (glare) and a faint
    rainbow tint in bands (sheen) around a light point, like sunlight
    catching a Game Boy screen. It is drawn on the backing material only.
    See "Glare and sheen" in the PARAMETERS section.
  - It is a matter of taste. Turn it on, adjust it to your liking, or leave
    it Off. Setting the "== Glare and sheen ==" switch back to 0 turns the
    whole feature off completely.
  - 11 new parameters (31 in total), placed under Backing color in the menu.
  - The light point is worked out in the vertex shader, which adds one
    varying (4 in total; v1.x used 8). With the feature Off the per-pixel
    cost is one check on a uniform. With it On the cost has not been
    measured on specific devices, so on a low-power handheld compare with it
    On and Off, and turn it off (or set Sheen ripple to 0) if you see
    slowdown.

  WHAT'S NEW IN v2.0.1
  ─────────────────────────────────────────────────────────────────

v2.0.1 is a fix release. It changes no parameter names, ranges or defaults,
so settings saved with v2.0.0 keep working. Just replace the shader file.

  - Parameters missing on some Android RetroArch builds: the Shadow direction
    menu label was longer than RetroArch's 63-character limit for parameter
    labels. On builds that enforce the limit, the shader's parameters did not
    appear at all. The label is now "Shadow direction (0=Down-R, 1=Down-L,
    2=Up-R, 3=Up-L)".
  - GLES3 fix: the fragment precision statement now comes before the
    FragColor output, as GLSL ES 3.00 requires. The shader now compiles under
    both GLSL ES 1.00 and 3.00.

  WHAT'S NEW IN v2.0.0
  ─────────────────────────────────────────────────────────────────

v2.0.0 is a major release. A single shader file serves both RetroArch and
NextUI. Parameter code names changed, so presets and parameter overrides saved
with 1.x fall back to the default values. Re-save your settings after updating
(see "Upgrading from 1.x" at the end of this file).

  - CRT Phosphor removed. It does not apply to the reflective LCD systems
    this shader targets. Pixel Effect now has three modes: Off, Grid and
    LCD Dot.
  - New menu layout. Each group has a "== Name ==" main row with its settings
    indented beneath it ("     > "). Effect-specific rows are tagged [Grid],
    [LCD Dot] or [Grid+Dot].
  - Every menu label now says plainly what it does, and the code names match
    the labels.
  - Grid reworked: Grid line width is a real line thickness, and Grid has its
    own Grid line opacity.
  - LCD Dot reworked: Dot edge softness (formerly Dot sharpness) sets how soft
    the edge of each dot is, and LCD Dot has its own Dot gap opacity. The old
    shared Gap / Grid color intensity setting no longer exists.
  - Backing gap fix: with Gap color = Backing, the gaps around non-white
    pixels in White mode used to be black. They now show the real backing
    color.
  - Low-end compatibility: the vertex shader passes 3 varyings instead of 8,
    the source is pure ASCII, a zero-width smoothstep was guarded, and the
    fallback defaults match the parameter defaults.
  - New defaults, tuned on a Game Boy Color.

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
  4. Open Shader Parameters and set Game system to match your hardware
  5. Apply the recommended settings from the section below
  6. Save via Save Shader Preset As for automatic loading in future sessions

  NextUI Compatibility (v6.11.0 and later)
  ─────────────────────────────────────────────────────────────────

  As of NextUI v6.11.0, this shader works natively on NextUI. NextUI uses
  a .cfg file to load the shader, not a .glslp preset (the .glslp is for
  RetroArch only). The same PT_SkyWalker541.glsl file is used on both.
  The .cfg file is provided in the NextUI/ folder of this repository.

  Place PT_SkyWalker541.glsl in your NextUI Shaders/glsl/ folder
  and PT_SkyWalker541.cfg in your NextUI Shaders/ folder, then load
  the .cfg from the in-game shader menu.

  Note: LCD Dot will not run at full speed on low-power devices such as
  the TrimUI Brick. Grid is recommended for constrained hardware.

  If the shader does not load
  ─────────────────────────────────────────────────────────────────

  If the shader shows in the pass list but has no parameters and no
  effect, the driver failed to compile or link it and RetroArch
  silently fell back to no shader. v2.0.0 reduces the things that most
  often cause this on low-end drivers, and v2.0.1 fixes a menu label that was
  too long for some RetroArch builds (see "What's new"). If it still
  happens on your device, start RetroArch with --verbose, load the
  shader, and report the shader compile messages from the log, together
  with your device and OS, at the project's GitHub issues page.

───────────────────────────────────────────────────────────────────────────────

  PARAMETERS
  ─────────────────────────────────────────────────────────────────

Accessible from Quick Menu > Shaders > Shader Parameters after loading.
Parameter names below match exactly what you will see in the menu.

In the menu, each "== Name ==" row is the main setting of a group. The
rows beneath it, shown with "     > ", only matter when that main setting
is turned on. Tags in square brackets show which pixel effect a row
applies to: [Grid], [LCD Dot] or [Grid+Dot].

  ── Game system ─────────────────────────────────────────────────

  == Game system == (0=Manual, 1=GB, 2=GBC, 3=GBA SP, 4=GBA Orig)   default: 2
    Selects the hardware preset. Sets the white detection level
    and bezel shadow width automatically to match each system.
    Set this first before adjusting any other parameters.

       > Manual white detection level (Manual only)   default: 0.85
    Only active when Game system = 0. Sets the white detection level
    manually. Use this when colorization is enabled or when the
    hardware presets do not detect correctly.

  ── Transparent pixels ──────────────────────────────────────────

  == Transparent pixels == (0=White, 1=Bright, 2=All)   default: 2
    Which pixels receive transparency. White only is the most
    accurate to original hardware. Bright includes near-white pixels.
    All applies transparency to every pixel.

       > Transparency amount   default: 0.10
    How transparent detected pixels become. Lower = more opaque and
    brighter. Higher = more of the backing texture shows through.

       > Minimum white transparency   default: 0.20
    Minimum transparency floor for confirmed white pixels. Ensures
    white pixels are always at least this transparent regardless of
    Transparency amount.

  ── Backing color ───────────────────────────────────────────────

  == Backing color == (0=Off, 1=Pocket, 2=Grey, 3=White)   default: 1
    Tint color of the procedural backing texture. Pocket is a warm
    green-grey matching the DMG and Pocket screen backing. Grey
    matches GBC and GBA Original. White matches GBA SP.

       > Backing color strength   default: 2.00   (range 0.00 to 2.00)
    How strongly the backing color is applied. 0 = no tint.
    Lower it if the tint feels too strong on your display.

  ── Glare and sheen (optional) ──────────────────────────────────

  == Glare and sheen == (0=Off, 1=On)   default: 0 (Off)
    Master switch for this whole group. It is Off by default. Set it to 1
    to try the effect, and back to 0 to turn the whole feature off. With
    it at 0 the picture is identical to v2.0.1 and none of the rows below
    has any effect.

    This feature is a matter of taste. Adjust it to your liking.

    What it does: it adds a soft hotspot of light (glare) and a faint
    rainbow tint in bands (sheen) around a light point, like sunlight
    catching a Game Boy screen. It is drawn on the backing material only:
    the transparent areas, and the grid lines or dot gaps when Gap color =
    Backing. Pixels that stay solid are not touched. If you cannot see it,
    raise Transparency amount, or use Gap color = Backing, so more of the
    backing shows. There is no tilt-sensor input; the light is moved by the
    shader over time, or held still.

       > Glare strength   default: 0.15   (range 0.00 to 1.00)
    How bright the white hotspot is. 0 turns glare off.

       > Glare spread   default: 0.35   (range 0.05 to 1.00)
    How large the hotspot is, relative to the picture height. Higher = a
    wider, softer patch of light.

       > Sheen strength   default: 0.12   (range 0.00 to 0.50)
    How strong the rainbow tint is. 0 turns sheen off. The tint shifts the
    color of the backing without making it brighter or darker overall.

       > Sheen band density   default: 2.0   (range 0.5 to 6.0)
    How many color bands appear around the light. Higher = more, narrower
    bands. Lower = fewer, wider bands.

       > Sheen hue turn (1.0 = one full color cycle)   default: 0.00   (range 0.00 to 1.00)
    Shifts which colors the bands show. 1.0 is one full trip around the
    color cycle, so 0 and 1 look the same. Try values in between to move
    the rainbow toward warmer or cooler colors.

       > Sheen ripple (0=smooth bands)   default: 0.00   (range 0.00 to 1.00)
    Makes the bands uneven, like film that is not perfectly smooth,
    instead of clean rings. 0 = smooth bands, and the extra work is skipped
    entirely. Small values (about 0.2 to 0.4) give a subtle unevenness;
    high values are strong.

       > Sheen ripple size   default: 0.6   (range 0.1 to 3.0)
    The size of the uneven patches when Sheen ripple is above 0. Larger =
    bigger patches. Smaller = finer, busier patches. No effect when ripple
    is 0.

       > Light home, left to right (0.5=middle)   default: 0.50   (range -0.50 to 1.50)
    Where the light sits across the picture. 0 = the left edge, 0.5 = the
    middle, 1 = the right edge. Values below 0 or above 1 put the light
    just off the edge of the picture, which gives a gentler, wider wash.

       > Light home, top to bottom (0.5=middle)   default: 0.45   (range -0.50 to 1.50)
    Where the light sits down the picture. 0 = the top edge, 0.5 = the
    middle, 1 = the bottom edge. Values outside 0 to 1 put the light off
    the edge.

       > Light drift speed (0=stay at home)   default: 0.50   (range 0.00 to 4.00)
    How fast the light wanders slowly around its home position. 0 = the
    light stays exactly at its home position (you can park it where you
    like with the two Light home rows). Higher = it moves faster.

    Tips: to set up a still, fixed glare, set Light drift speed to 0 and
    place the light with the two Light home rows. To keep only one part of
    the effect, set the other part's strength to 0 (Glare strength 0 leaves
    only sheen; Sheen strength 0 leaves only glare).

  ── Darken picture ──────────────────────────────────────────────

  == Darken picture == (0=Off)   default: 0   (range 0 to 100)
    Softens overly vivid dark colors. Most useful for GBC games
    with aggressive color palettes. 0 = off. Raise gradually
    until dark colors look natural.

  ── Pixel Effect ────────────────────────────────────────────────

  == Pixel Effect == (0=Off, 1=Grid, 2=LCD Dot)   default: 1
    Selects the pixel structure simulation effect. Each mode has its
    own dedicated parameters below. Parameters for the inactive mode
    have no effect on the image and cost nothing to process.

       > [Grid+Dot] Gap color (0=Backing, 1=Black, 2=White)   default: 0
    The color that fills the grid lines in Grid mode and the gaps
    around the dots in LCD Dot mode. See "Gap color" below.

  [Grid] parameters — active when Pixel Effect = 1
  ─────────────────────────────────────────────────────────────────

       > [Grid] Grid line width   default: 0.25   (range 0.00 to 0.50)
    Thickness of the grid line, as a fraction of one game pixel. The
    line is centered on the border between two game pixels, half on
    each side. Higher = a wider line. 0 = no line.
    A screen can only draw whole pixels, so very thin widths fade out
    or do not show. See "Grid line width and screen resolution" below.

       > [Grid] Grid line opacity   default: 0.50
    How strongly the Gap color is drawn into the line. 1.0 = the line
    is fully the gap color. 0.0 = the line is invisible. Line width
    and opacity are independent: width sets the size, opacity sets how
    visible it is.

  [LCD Dot] parameters — active when Pixel Effect = 2
  ─────────────────────────────────────────────────────────────────

       > [LCD Dot] Dot size   default: 0.90   (range 0.10 to 0.90)
    Size of each dot within its pixel cell. Larger values fill
    more of the cell and leave a smaller gap. Smaller values leave
    a larger gap between dots.

       > [LCD Dot] Dot edge softness (0=hard, 1=soft)   default: 1.00
    Controls the edge of each dot. 0 = a hard, sharply defined
    edge. 1 = a soft, gradual edge, which matches the look of the
    old default in version 1.x.

       > [LCD Dot] Dot gap opacity   default: 0.50
    How strongly the Gap color shows in the gaps around the dots.
    1.0 = gaps are fully the gap color. 0.0 = no gaps (the game pixel
    shows through with no dot effect).

       > [LCD Dot] Min brightness for dots   default: 0.15
    Controls where the dot effect fades in above black. Black
    detection uses the raw input frame before color correction,
    so unlit pixels remain clean regardless of emulator color settings.
    A hard gate on truly black pixels ensures they are always clean
    at zero cost regardless of this setting.
    0 = dot effect applies to all pixels including near-black.
    Higher values suppress dots on progressively brighter dark pixels.

  ── Gap color ───────────────────────────────────────────────────

  Gap color (0=Backing, 1=Black, 2=White)   default: 0
    Sets the color that appears in the grid lines (Grid) and in the
    gaps around the dots (LCD Dot).

    Backing (0) — the procedural backing texture fills the lines and
    gaps. Its appearance is controlled by Backing color and Backing
    color strength. This is the most authentic option, as it matches
    the physical backing material visible between pixels on real
    hardware. It uses the already-computed backing texture at zero
    extra processing cost. In White mode, the gaps around non-white
    pixels show the real backing color too.

    Black (1) — lines and gaps are darkened toward pure black.

    White (2) — lines and gaps are brightened toward pure white.

    How strongly the gap color appears is set per effect: Grid line
    opacity for Grid, Dot gap opacity for LCD Dot. At 0.0 the effect
    is invisible and the game pixel color shows through.

  Parameter interactions
  ─────────────────────────────────────────────────────────────────

  Gap color = Backing is affected by two other parameters:

    Backing color — selects the tint of the backing texture. Whatever
    is selected there also appears in the lines and gaps when Gap color
    = Backing. Changing Backing color changes the gap color
    simultaneously.

    Backing color strength — controls how strongly the tint is applied
    to the backing texture. This affects both the transparent areas
    on white/bright pixels AND the lines and gaps when Gap color =
    Backing.

  If you want the lines and gaps and the transparent areas to look
  consistent, use Gap color = Backing and adjust Backing color and
  Backing color strength together. This gives the most authentic
  hardware appearance.

  Gap color = Black or White is independent of all backing
  parameters. Only Grid line opacity (Grid) or Dot gap opacity
  (LCD Dot) affects how visible it is.

  Brightness note — if the image feels too dark with LCD Dot enabled,
  switch Gap color from Black to Backing or White, or reduce Dot gap
  opacity. These options control gap brightness directly at the source.

  Grid line width and screen resolution
  ─────────────────────────────────────────────────────────────────

  Grid line width is a fraction of one game pixel, but your screen can
  only draw whole screen pixels. With integer scaling at N times (each
  game pixel drawn N screen pixels wide), one screen pixel is 1/N of a
  game pixel. A line thinner than that can fade out or not show at all.

  Because the line is centered on the border between two game pixels,
  it is drawn on both sides of the border, so on an integer-scaled
  screen it is typically an even number of screen pixels wide.

  Example (calculated from the shader math, not measured on a device):
  Retroid Pocket Classic, 1240 x 1080, integer scaling, 160 x 144 GBC
  game = 7x scale. At Grid line opacity 0.50:

    Grid line width   Result
    below 0.15        no line visible
    0.15 to 0.22      line fades in from almost invisible to full strength
    0.22 to 0.42      full-strength line, 2 screen pixels wide
    above 0.43        line grows to 4 screen pixels wide

  The values change with your screen and scale. As a rule of thumb, the
  smallest useful width is about 1/N (0.14 at 7x), and the line reaches
  full strength at about 1.5/N. Raise Grid line opacity for a stronger
  line; lower it for a subtler one.

  ── Drop shadow ─────────────────────────────────────────────────

  == Drop shadow opacity == (0=Off)   default: 0.30
    Strength of the drop shadow cast by solid pixels onto the backing
    texture. 0 = off.

       > Shadow distance   default: 1.0   (range -10.0 to 10.0)
    Distance of the drop shadow. Moves X and Y together in texels.

       > Shadow direction (0=Down-R, 1=Down-L, 2=Up-R, 3=Up-L)   default: 0
    Direction the drop shadow is cast: 0 = Down Right, 1 = Down Left,
    2 = Up Right, 3 = Up Left. Down Right is the default and
    most natural, simulating light from the upper left.

  ── Bezel edge shadow ───────────────────────────────────────────

  == Bezel edge shadow == (0=Off)   default: 0.40
    Darkens screen edges to simulate the shadow cast by the physical
    bezel onto the LCD panel. Width is set automatically by Game system.
    0 = off.

───────────────────────────────────────────────────────────────────────────────

  RECOMMENDED SETTINGS
  ─────────────────────────────────────────────────────────────────

One set of settings is a good starting point for every system. The
built-in defaults were tuned and tested on a Game Boy Color, so the only
things to change for your system are Game system and Backing color.
Game system also sets the white detection level (GB 0.90, GBC 0.85,
GBA SP 0.80, GBA Orig 0.75) and the bezel shadow width automatically.

  1. SET THESE TWO FOR YOUR SYSTEM
  ─────────────────────────────────────────────────────────────────
  System                 Game system     Backing color
  Game Boy / Pocket      1               1  (Pocket)
  Game Boy Color         2               1  (Pocket)
  GBA SP                 3               3  (White)
  GBA Original           4               2  (Grey)

  2. LEAVE EVERYTHING ELSE AT THE DEFAULTS
  ─────────────────────────────────────────────────────────────────
  Transparent pixels             2    (All)
  Transparency amount            0.10
  Minimum white transparency     0.20
  Backing color strength         2.00
  Darken picture                 0
  Pixel Effect                   1    (Grid)
  Gap color                      0    (Backing)
  Grid line width                0.25
  Grid line opacity              0.50
  Drop shadow opacity            0.30
  Shadow distance                1.0
  Shadow direction               0    (Down Right)
  Bezel edge shadow              0.40

  LCD DOT ALTERNATIVE
  ─────────────────────────────────────────────────────────────────
  To use LCD Dot instead of Grid, set Pixel Effect to 2 and use:

  Pixel Effect                   2    (LCD Dot)
  Gap color                      0    (Backing)
  Dot size                       0.90
  Dot edge softness              1.00
  Dot gap opacity                0.50
  Min brightness for dots        0.15

  This is a good starting point for each system when Game system and
  Backing color are set for that system as shown above. Everything else
  can be adjusted to taste.

  Glare and sheen is optional, is Off by default, and is not part of these
  recommended settings. It is purely a matter of taste. Turn it on with
  "== Glare and sheen ==" = 1, adjust it to your liking, or leave it Off.

  EMULATOR CORE SETTINGS
  ─────────────────────────────────────────────────────────────────
  These are settings in the emulator core, not the shader.

  System                 Core                  Color correction   Interframe blending
  Game Boy / Pocket      Gambatte / SameBoy    Disabled           Disabled
  Game Boy Color         Gambatte / SameBoy    GBC Only           Disabled
  GBA SP                 mGBA                  Enabled            Smart
  GBA Original           mGBA                  Enabled            LCD ghosting (accurate)

  For Game Boy / Pocket, also disable GB Colorization. If you do use
  GB colorization, set Game system = 0 and adjust Manual white
  detection level until backgrounds go transparent.

───────────────────────────────────────────────────────────────────────────────

  EDITING DEFAULT VALUES
  ─────────────────────────────────────────────────────────────────

To change a default, open PT_SkyWalker541.glsl in any text editor and
change the first number after the menu label on the matching
"#pragma parameter" line near the top of the file. The line has the form:

    #pragma parameter CODE_NAME "label" default min max step

Then change the same parameter in the fallback "#define" block so both
agree. (The Glare and sheen light settings, namely Glare and sheen, Light
home X and Y, Light drift speed and Sheen hue turn, also have a second
fallback "#define" in the vertex shader; change that one too.) The fallback values are used only when
the host does not supply shader parameters. The menu name for each
parameter is shown alongside for reference:

    #define PT_GAME_SYSTEM                   2.0    == Game system ==
    #define PT_MANUAL_WHITE_DETECTION_LEVEL  0.85   Manual white detection level
    #define PT_TRANSPARENT_PIXELS            2.0    == Transparent pixels ==
    #define PT_TRANSPARENCY_AMOUNT           0.10   Transparency amount
    #define PT_MINIMUM_WHITE_TRANSPARENCY    0.20   Minimum white transparency
    #define PT_BACKING_COLOR                 1.0    == Backing color ==
    #define PT_BACKING_COLOR_STRENGTH        2.0    Backing color strength
    #define PT_GLARE_AND_SHEEN               0.0    == Glare and sheen ==
    #define PT_GLARE_STRENGTH                0.15   Glare strength
    #define PT_GLARE_SPREAD                  0.35   Glare spread
    #define PT_SHEEN_STRENGTH                0.12   Sheen strength
    #define PT_SHEEN_BAND_DENSITY            2.0    Sheen band density
    #define PT_SHEEN_HUE_TURN                0.0    Sheen hue turn
    #define PT_SHEEN_RIPPLE                  0.0    Sheen ripple
    #define PT_SHEEN_RIPPLE_SIZE             0.6    Sheen ripple size
    #define PT_LIGHT_HOME_X                  0.5    Light home, left to right
    #define PT_LIGHT_HOME_Y                  0.45   Light home, top to bottom
    #define PT_LIGHT_DRIFT_SPEED             0.5    Light drift speed
    #define PT_DARKEN_PICTURE                0.0    == Darken picture ==
    #define PT_PIXEL_EFFECT                  1.0    == Pixel Effect ==
    #define PT_GAP_COLOR                     0.0    [Grid+Dot] Gap color
    #define PT_GRID_LINE_WIDTH               0.25   [Grid] Grid line width
    #define PT_GRID_LINE_OPACITY             0.50   [Grid] Grid line opacity
    #define PT_DOT_SIZE                      0.90   [LCD Dot] Dot size
    #define PT_DOT_EDGE_SOFTNESS             1.0    [LCD Dot] Dot edge softness
    #define PT_DOT_GAP_OPACITY               0.50   [LCD Dot] Dot gap opacity
    #define PT_MIN_BRIGHTNESS_FOR_DOTS       0.15   [LCD Dot] Min brightness for dots
    #define PT_DROP_SHADOW_OPACITY           0.30   == Drop shadow opacity ==
    #define PT_SHADOW_DISTANCE               1.0    Shadow distance
    #define PT_SHADOW_DIRECTION              0.0    Shadow direction
    #define PT_BEZEL_EDGE_SHADOW             0.40   == Bezel edge shadow ==

───────────────────────────────────────────────────────────────────────────────

  UPGRADING FROM 1.x
  ─────────────────────────────────────────────────────────────────

Nothing was renamed in 2.1.0; the table below is only for settings saved
with 1.x. Code names changed in 2.0.0 so they match the menu labels. A preset or
parameter override that uses an old name falls back to the default value for
that parameter, so re-save your settings after updating.

  Old name (1.x)                     New name (2.0.0)
  PT_SYSTEM                          PT_GAME_SYSTEM
  PT_MANUAL_SENSITIVITY_THRESHOLD    PT_MANUAL_WHITE_DETECTION_LEVEL
  PT_PIXEL_MODE                      PT_TRANSPARENT_PIXELS
  PT_BASE_TRANSPARENCY_AMOUNT        PT_TRANSPARENCY_AMOUNT
  PT_WHITE_PIXEL_MIN_TRANSPARENCY    PT_MINIMUM_WHITE_TRANSPARENCY
  PT_BACKGROUND_TINT                 PT_BACKING_COLOR
  PT_TINT_INTENSITY                  PT_BACKING_COLOR_STRENGTH
  PT_DARK_COLOR_FILTER               PT_DARKEN_PICTURE
  PT_PIXEL_EFFECT                    PT_PIXEL_EFFECT (unchanged; CRT Phosphor option removed)
  PT_GRID_WIDTH                      PT_GRID_LINE_WIDTH (now a real line width)
  PT_DOT_SIZE                        PT_DOT_SIZE (unchanged)
  PT_DOT_SHARPNESS                   PT_DOT_EDGE_SOFTNESS (new range and meaning)
  PT_BLACK_LEVEL_THRESHOLD           PT_MIN_BRIGHTNESS_FOR_DOTS
  PT_GAP_GRID_COLOR                  PT_GAP_COLOR
  PT_GAP_GRID_COLOR_INTENSITY        PT_GRID_LINE_OPACITY and PT_DOT_GAP_OPACITY (split in two)
  PT_SHADOW_OPACITY                  PT_DROP_SHADOW_OPACITY
  PT_SHADOW_OFFSET                   PT_SHADOW_DISTANCE
  PT_SHADOW_DIRECTION                PT_SHADOW_DIRECTION (unchanged)
  PT_BEZEL_SHADOW_STRENGTH           PT_BEZEL_EDGE_SHADOW
  PT_PHOSPHOR_*                      removed (CRT Phosphor mode no longer exists)

───────────────────────────────────────────────────────────────────────────────

PT SkyWalker541 by SkyWalker541 | AI Assisted Development | v2.1.0 | Written for RetroArch and NextUI
