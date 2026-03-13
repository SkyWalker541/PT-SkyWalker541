/*
╔══════════════════════════════════════════════════════════════════╗
║  PT SkyWalker541 Pro  v1.5.1                                     ║
║  by SkyWalker541  |  Written for RetroArch (GLSL)                ║
╚══════════════════════════════════════════════════════════════════╝

  High-end version targeting powerful handhelds and PC. All Pro
  features can be disabled individually for performance tuning.

  On original Game Boy, GBC, and GBA hardware, screen pixels that
  were fully off did not display as white. Those areas had no
  backlight driving them, so the physical backing material showed
  through instead: a grey-green translucency rather than solid white.
  PT SkyWalker541 Pro restores this with a full suite of effects:
  directional shadow blur, LCD halation, subpixel dithering, screen
  curvature with edge fringing, improved grain, and more.

╔══════════════════════════════════════════════════════════════════╗
║  SYSTEM GUIDE                                                    ║
╚══════════════════════════════════════════════════════════════════╝

  Set PT_SYSTEM first — it determines the detection threshold.
  Then tune per the per-system notes in the README.

  1 = Game Boy / Game Boy Pocket (DMG)
      No backlight. Slow ghosting LCD. Distinctive green-grey
      backing. PT_HALATION = 0 (no backlight, no glow).
      PT_PALETTE = 1 (Pocket grey).

  2 = Game Boy Color
      No backlight. Improved colour, slightly cleaner backing.
      PT_HALATION = 0. PT_PALETTE = 1 or 2.

  3 = Game Boy Advance SP (front-lit)
      Front-lit screen, bright and vivid. PT_HALATION = 0.08
      (warm diffuser glow from front light). PT_PALETTE = 3 (White).

  4 = Game Boy Advance Original (no backlight)
      Dim, washed-out reflective screen. Whites appear creamy.
      PT_HALATION = 0. PT_PALETTE = 4 (Green-grey).

  0 = Manual — use PT_SENSITIVITY directly.

╔══════════════════════════════════════════════════════════════════╗
║  PERFORMANCE GUIDE                                               ║
╚══════════════════════════════════════════════════════════════════╝

  Disable Pro features in this order to reduce GPU load:
    1. PT_SHADOW_BLUR = 0    — biggest saving (15-tap blur)
    2. PT_HALATION = 0       — 8-tap radial glow
    3. PT_CURVATURE = 0      — per-fragment UV distortion
    4. PT_DITHER = 0         — minor (Bayer lookup)
    5. PT_PIXEL_BORDER = 0   — minor (per-fragment trig)
  With all Pro features off = equivalent to PT_SkyWalker541.glsl.

╔══════════════════════════════════════════════════════════════════╗
║  CHANGELOG                                                       ║
╚══════════════════════════════════════════════════════════════════╝

  v1.5.1 - Fixed GLES compile failure on Android/RetroArch. getBayerDither()
           rewrote integer arithmetic (int x, y, idx, division) as pure float
           mod()/floor() operations — GLES 2.0 does not support integer types
           in fragment shaders. No change to dither output or any other logic.

  v1.5.0 - Unified version number across all PT_SkyWalker541 variants
           (Standard, Pro, NextUI). No shader logic changes.

  v1.1.0 - Transparency pipeline improvements:
           Soft detection edge — isWhitePixel() replaced with
           whitePixelStrength() returning 0..1 via smoothstep over
           [threshold, threshold+0.08]. Eliminates fringing at
           detection boundary. Alpha driven by raw pre-correction
           brightness. Alpha scales with distance above threshold.
           Separate blend paths: white pixels use mix(), coloured
           pixels use huePreservingBlend().

  v1.0.0 - Initial Pro release. Directional gaussian shadow blur
           (15-tap), LCD halation, Bayer dithering (2x2/4x4/8x8),
           screen curvature with edge fringing, improved grain,
           PT_SYSTEM expanded to include GBA SP (3) and GBA
           Original (4), green-grey palette option added.
*/

// ╔══════════════════════════════════════════════════════════════╗
// ║  PARAMETERS  (15 — RetroArch GLSL limit)                     ║
// ╚══════════════════════════════════════════════════════════════╝
// Advanced sub-parameters are hardcoded below in ADVANCED DEFAULTS.
// To change them, edit the #define values in that section.

// ┌──────────────────────────────────┐
// │  System Preset                   │
// └──────────────────────────────────┘
// 0=Manual  1=GB/Pocket  2=GBC  3=GBA SP  4=GBA Original
#pragma parameter PT_SYSTEM "System (0=Manual, 1=GB, 2=GBC, 3=GBA SP, 4=GBA Orig)" 1.0 0.0 4.0 1.0
// Active only when PT_SYSTEM = 0
#pragma parameter PT_SENSITIVITY "  Manual sensitivity threshold" 0.85 0.0 1.0 0.01

// ┌──────────────────────────────────┐
// │  Pixel Transparency              │
// └──────────────────────────────────┘
// 0=White only  1=Bright  2=All
#pragma parameter PT_PIXEL_MODE "Transparency mode (0=White, 1=Bright, 2=All)" 0.0 0.0 2.0 1.0
// GB/GBC: 0.20  GBA SP: 0.15  GBA Orig: 0.25
#pragma parameter PT_BASE_ALPHA "  Base transparency amount" 0.20 0.0 1.0 0.01
#pragma parameter PT_WHITE_TRANSPARENCY "  White pixel min transparency" 0.50 0.0 1.0 0.01

// ┌──────────────────────────────────┐
// │  Background Tint                 │
// └──────────────────────────────────┘
// 0=Off  1=Pocket grey  2=Cool grey  3=White (GBA SP)  4=Green-grey (GBA Orig)
#pragma parameter PT_PALETTE "Background tint (0=Off, 1=Pocket, 2=Grey, 3=White, 4=Green-grey)" 1.0 0.0 4.0 1.0

// ┌──────────────────────────────────┐
// │  Color Harshness Filter          │
// └──────────────────────────────────┘
// 0=off. 5-15 natural for GBC/GBA. Not needed for GB.
#pragma parameter PT_DARK_FILTER_LEVEL "Dark color filter (0=off)" 0.0 0.0 100.0 1.0

// ┌──────────────────────────────────┐
// │  Pixel Border                    │
// └──────────────────────────────────┘
// 0=Off  1=Subtle  2=Moderate  3=Strong. GB/GBC: 1. GBA: 0.
#pragma parameter PT_PIXEL_BORDER "Pixel border (0=Off, 1=Subtle, 2=Moderate, 3=Strong)" 1.0 0.0 3.0 1.0

// ┌──────────────────────────────────┐
// │  Drop Shadow                     │
// └──────────────────────────────────┘
// Shadow opacity 0=off. Offset/blur/radius in ADVANCED DEFAULTS.
#pragma parameter PT_SHADOW_OPACITY "Shadow opacity (0=off)" 0.30 0.0 1.0 0.01
// 0=hard edge  0.5-2.0=gaussian blur along shadow vector
#pragma parameter PT_SHADOW_BLUR "  Shadow blur amount (0=off)" 1.0 0.0 5.0 0.1

// ┌──────────────────────────────────┐
// │  Halation                        │
// └──────────────────────────────────┘
// ONLY for backlit screens. Off for GB, GBC, GBA Original.
// GBA SP: 0.05-0.15. Radius/warmth in ADVANCED DEFAULTS.
#pragma parameter PT_HALATION "Halation glow (0=off)" 0.0 0.0 1.0 0.01

// ┌──────────────────────────────────┐
// │  Dithering                       │
// └──────────────────────────────────┘
// 0=off. Strength/matrix in ADVANCED DEFAULTS.
#pragma parameter PT_DITHER "Dither blend edges (0=off, 1=on)" 1.0 0.0 1.0 1.0

// ┌──────────────────────────────────┐
// │  Screen Curvature                │
// └──────────────────────────────────┘
// 0=off. All original screens were flat — aesthetic only.
// Strength/fringe in ADVANCED DEFAULTS.
#pragma parameter PT_CURVATURE "Screen curvature (0=off)" 0.0 0.0 1.0 0.01

// ┌──────────────────────────────────┐
// │  Post-Blend Effects              │
// └──────────────────────────────────┘
#pragma parameter PT_CHROMA "Chromatic shift (0=off)" 0.0 0.0 1.0 0.01
#pragma parameter PT_VIGNETTE "Vignette strength (0=off)" 0.08 0.0 1.0 0.01

// ╔══════════════════════════════════════════════════════════════╗
// ║  ADVANCED DEFAULTS                                           ║
// ║  Sub-parameters not exposed in the menu — edit here.         ║
// ╚══════════════════════════════════════════════════════════════╝

// ┌──────────────────────────────────┐
// │  Brightness Mode                 │
// └──────────────────────────────────┘
// How brightness is measured for white detection and blending.
// 0 = Simple average (R+G+B)/3    — recommended for GB / GBC
// 1 = Perceptual ITU-R BT.709     — recommended for GBA SP / GBA Original
#define PT_BRIGHTNESS_MODE_DEFAULT  0.0

// ┌──────────────────────────────────┐
// │  Background                      │
// └──────────────────────────────────┘
// How strongly the palette tint colour is applied to the backing texture.
// 0.0 = no tint (PT_PALETTE has no effect).  1.0 = full tint.  Range: 0.0-2.0
#define PT_PALETTE_INTENSITY_DEFAULT  1.0

// Visibility of the procedural grain on the backing texture.
// 0.0 = flat/no grain.  Range: 0.0-0.30
// Per-system recommendations: GB=0.10  GBC=0.07  GBA SP=0.03  GBA Orig=0.08
#define PT_GRAIN_INTENSITY_DEFAULT    0.065

// Size of the grain pattern. Lower = finer grain, higher = coarser grain.
// Range: 0.05-1.0
// Per-system recommendations: GB=0.30  GBC=0.25  GBA SP=0.15  GBA Orig=0.20
#define PT_GRAIN_SCALE_DEFAULT        0.25

// ┌──────────────────────────────────┐
// │  Shadow                          │
// └──────────────────────────────────┘
// Horizontal offset of the drop shadow in source texels.
// Positive = right, negative = left.  Range: -10.0 to 10.0
#define PT_SHADOW_OFFSET_X_DEFAULT    2.0

// Vertical offset of the drop shadow in source texels.
// Positive = down, negative = up.  Range: -10.0 to 10.0
#define PT_SHADOW_OFFSET_Y_DEFAULT    2.0

// How far the gaussian blur spreads from the shadow origin, in source texels.
// Only active when PT_SHADOW_BLUR > 0.
// 0.5=tight  1.0=natural  2.0=wide/very soft.  Range: 0.1-4.0
#define PT_SHADOW_BLUR_RADIUS_DEFAULT 1.0

// ┌──────────────────────────────────┐
// │  Halation                        │
// └──────────────────────────────────┘
// Radius of the halation glow in source texels.
// Only active when PT_HALATION > 0.  GBA SP recommendation: 1.0-2.0
// Range: 0.1-5.0
#define PT_HALATION_RADIUS_DEFAULT    1.5

// Colour temperature of the halation glow.
// 0.0 = cool white.  0.3 = warm white (GBA SP front light).  1.0 = warm amber.
// Only active when PT_HALATION > 0.  Range: 0.0-1.0
#define PT_HALATION_WARMTH_DEFAULT    0.3

// ┌──────────────────────────────────┐
// │  Dithering                       │
// └──────────────────────────────────┘
// How much the Bayer dither pattern offsets the blend alpha. Keep small.
// Range: 0.0-0.20
// Per-system recommendations: GB=0.06  GBC=0.04  GBA SP=0.02  GBA Orig=0.05
#define PT_DITHER_STRENGTH_DEFAULT    0.05

// Which Bayer matrix to use. 4x4 is recommended for most uses.
// 0.0 = 2x2 (coarse, fastest)  1.0 = 4x4 (balanced)  2.0 = 8x8 (finest)
#define PT_DITHER_MATRIX_DEFAULT      1.0

// ┌──────────────────────────────────┐
// │  Screen Curvature                │
// └──────────────────────────────────┘
// Amount of barrel distortion when PT_CURVATURE > 0.
// 0.1=barely visible  0.2=subtle  0.3=moderate  0.5=strong.  Range: 0.0-1.0
#define PT_CURVATURE_STRENGTH_DEFAULT 0.20

// Colour channel separation at screen edges, simulating lens refraction.
// Only active when PT_CURVATURE > 0.
// 0.0=off  0.4=subtle  1.0=strong.  Range: 0.0-1.0
#define PT_CURVATURE_FRINGE_DEFAULT   0.4

// ╔══════════════════════════════════════════════════════════════╗
// ║  VERTEX SHADER                                               ║
// ╚══════════════════════════════════════════════════════════════╝
#if defined(VERTEX)

#if __VERSION__ >= 130
#define COMPAT_VARYING out
#define COMPAT_ATTRIBUTE in
#define COMPAT_TEXTURE texture
#else
#define COMPAT_VARYING varying
#define COMPAT_ATTRIBUTE attribute
#define COMPAT_TEXTURE texture2D
#endif

#ifdef GL_ES
#define COMPAT_PRECISION mediump
#else
#define COMPAT_PRECISION
#endif

COMPAT_ATTRIBUTE vec4 VertexCoord;
COMPAT_ATTRIBUTE vec4 COLOR;
COMPAT_ATTRIBUTE vec4 TexCoord;
COMPAT_VARYING vec4 TEX0;
COMPAT_VARYING vec2 texel;
COMPAT_VARYING vec2 orig_coord;

uniform mat4 MVPMatrix;
uniform COMPAT_PRECISION int FrameDirection;
uniform COMPAT_PRECISION int FrameCount;
uniform COMPAT_PRECISION vec2 OutputSize;
uniform COMPAT_PRECISION vec2 TextureSize;
uniform COMPAT_PRECISION vec2 InputSize;

void main()
{
    gl_Position = MVPMatrix * VertexCoord;
    TEX0.xy     = TexCoord.xy;
    texel       = 1.0 / TextureSize;
    // orig_coord shares the same normalised UV space as the main texture
    // in a single-pass shader — no remapping required.
    orig_coord  = TexCoord.xy;
}

// ╔══════════════════════════════════════════════════════════════╗
// ║  FRAGMENT SHADER                                             ║
// ╚══════════════════════════════════════════════════════════════╝
#elif defined(FRAGMENT)

#if __VERSION__ >= 130
#define COMPAT_VARYING in
#define COMPAT_TEXTURE texture
out vec4 FragColor;
#else
#define COMPAT_VARYING varying
#define FragColor gl_FragColor
#define COMPAT_TEXTURE texture2D
#endif

#ifdef GL_ES
#ifdef GL_FRAGMENT_PRECISION_HIGH
precision highp float;
#else
precision mediump float;
#endif
#define COMPAT_PRECISION mediump
#else
#define COMPAT_PRECISION
#endif

uniform COMPAT_PRECISION int FrameDirection;
uniform COMPAT_PRECISION int FrameCount;
uniform COMPAT_PRECISION vec2 OutputSize;
uniform COMPAT_PRECISION vec2 TextureSize;
uniform COMPAT_PRECISION vec2 InputSize;
uniform sampler2D Texture;
uniform sampler2D OrigTexture;

COMPAT_VARYING vec4 TEX0;
COMPAT_VARYING vec2 texel;
COMPAT_VARYING vec2 orig_coord;

// ┌──────────────────────────────────┐
// │  Parameter Uniforms / Fallbacks  │
// └──────────────────────────────────┘
// Parameters exposed in the RetroArch shader menu (15 max for GLSL)
#ifdef PARAMETER_UNIFORM
uniform COMPAT_PRECISION float PT_SYSTEM;
uniform COMPAT_PRECISION float PT_SENSITIVITY;
uniform COMPAT_PRECISION float PT_PIXEL_MODE;
uniform COMPAT_PRECISION float PT_BASE_ALPHA;
uniform COMPAT_PRECISION float PT_WHITE_TRANSPARENCY;
uniform COMPAT_PRECISION float PT_PALETTE;
uniform COMPAT_PRECISION float PT_DARK_FILTER_LEVEL;
uniform COMPAT_PRECISION float PT_PIXEL_BORDER;
uniform COMPAT_PRECISION float PT_SHADOW_OPACITY;
uniform COMPAT_PRECISION float PT_SHADOW_BLUR;
uniform COMPAT_PRECISION float PT_HALATION;
uniform COMPAT_PRECISION float PT_DITHER;
uniform COMPAT_PRECISION float PT_CURVATURE;
uniform COMPAT_PRECISION float PT_CHROMA;
uniform COMPAT_PRECISION float PT_VIGNETTE;
#else
// Fallback when PARAMETER_UNIFORM is not set
#define PT_SYSTEM             1.0
#define PT_SENSITIVITY        0.85
#define PT_PIXEL_MODE         0.0
#define PT_BASE_ALPHA         0.20
#define PT_WHITE_TRANSPARENCY 0.20
#define PT_PALETTE            1.0
#define PT_DARK_FILTER_LEVEL  0.0
#define PT_PIXEL_BORDER       1.0
#define PT_SHADOW_OPACITY     0.30
#define PT_SHADOW_BLUR        1.0
#define PT_HALATION           0.0
#define PT_DITHER             1.0
#define PT_CURVATURE          0.0
#define PT_CHROMA             0.0
#define PT_VIGNETTE           0.08
#endif

// Advanced parameters — always sourced from ADVANCED DEFAULTS block above
#define PT_BRIGHTNESS_MODE    PT_BRIGHTNESS_MODE_DEFAULT
#define PT_PALETTE_INTENSITY  PT_PALETTE_INTENSITY_DEFAULT
#define PT_GRAIN_INTENSITY    PT_GRAIN_INTENSITY_DEFAULT
#define PT_GRAIN_SCALE        PT_GRAIN_SCALE_DEFAULT
#define PT_SHADOW_OFFSET_X    PT_SHADOW_OFFSET_X_DEFAULT
#define PT_SHADOW_OFFSET_Y    PT_SHADOW_OFFSET_Y_DEFAULT
#define PT_SHADOW_BLUR_RADIUS PT_SHADOW_BLUR_RADIUS_DEFAULT
#define PT_HALATION_RADIUS    PT_HALATION_RADIUS_DEFAULT
#define PT_HALATION_WARMTH    PT_HALATION_WARMTH_DEFAULT
#define PT_DITHER_STRENGTH    PT_DITHER_STRENGTH_DEFAULT
#define PT_DITHER_MATRIX      PT_DITHER_MATRIX_DEFAULT
#define PT_CURVATURE_STRENGTH PT_CURVATURE_STRENGTH_DEFAULT
#define PT_CURVATURE_FRINGE   PT_CURVATURE_FRINGE_DEFAULT

// ┌──────────────────────────────────┐
// │  Constants                       │
// └──────────────────────────────────┘
#define LUMA_R 0.2126
#define LUMA_G 0.7152
#define LUMA_B 0.0722
#define PI     3.141592654
#define BORDER_WIDTH_FACTOR_MAX 31.0

// ╔══════════════════════════════════════════════════════════════╗
// ║  HELPER FUNCTIONS                                            ║
// ╚══════════════════════════════════════════════════════════════╝

// ┌──────────────────────────────────┐
// │  Brightness                      │
// └──────────────────────────────────┘
float perceptualBrightness(vec3 c)
{
    return LUMA_R * c.r + LUMA_G * c.g + LUMA_B * c.b;
}

float simpleBrightness(vec3 c)
{
    return (c.r + c.g + c.b) / 3.0;
}

float getBrightness(vec3 c)
{
    return (PT_BRIGHTNESS_MODE < 0.5) ? simpleBrightness(c)
                                      : perceptualBrightness(c);
}

// ┌──────────────────────────────────┐
// │  White Detection                 │
// └──────────────────────────────────┘

// Resolve system preset to detection threshold.
//   GB/Pocket: 0.88   GBC: 0.85   GBA SP: 0.80   GBA Orig: 0.75
float resolveThreshold()
{
    if (PT_SYSTEM < 0.5) return PT_SENSITIVITY;
    if (PT_SYSTEM < 1.5) return 0.90;
    if (PT_SYSTEM < 2.5) return 0.85;
    if (PT_SYSTEM < 3.5) return 0.80;
    return 0.75;
}

// Soft detection: channel range check is hard, brightness is smoothstep.
// Returns 0..1 — gradient over [threshold, threshold+0.08].
// Eliminates the hard fringing of a step function at the detection boundary.
float whitePixelStrength(vec3 pixel, float threshold)
{
    float brightness   = perceptualBrightness(pixel);
    float maxChannel   = max(max(pixel.r, pixel.g), pixel.b);
    float minChannel   = min(min(pixel.r, pixel.g), pixel.b);
    float channelRange = maxChannel - minChannel;
    if (channelRange >= 0.15) return 0.0;
    return smoothstep(threshold, threshold + 0.08, brightness);
}

// ┌──────────────────────────────────┐
// │  Color Harshness Filter          │
// └──────────────────────────────────┘
vec3 applyDarkFilter(vec3 c, float level)
{
    float strength = level * 0.01;
    float luma     = perceptualBrightness(c);
    float factor   = max(1.0 - strength * luma, 0.0);
    return c * factor;
}

// ┌──────────────────────────────────┐
// │  Procedural Backing Texture      │
// └──────────────────────────────────┘

// Multi-octave hash noise. Loops unrolled for GLSL ES compatibility.
float noiseHash(vec2 p)
{
    vec3 p3 = fract(vec3(p.xyx) * 0.1031);
    p3 = p3 + vec3(dot(p3, p3.yzx + 33.33));
    return fract((p3.x + p3.y) * p3.z);
}

vec3 proceduralBackground(vec2 uv)
{
    vec2  p = uv * (256.0 * PT_GRAIN_SCALE);
    float n = 0.0;
    n = n + noiseHash(p)       * 0.500;
    n = n + noiseHash(p * 2.0) * 0.250;
    n = n + noiseHash(p * 4.0) * 0.125;
    float offset = (n - 0.4375) * PT_GRAIN_INTENSITY;
    return vec3(0.478 + offset);
}

// ┌──────────────────────────────────┐
// │  Blend                           │
// └──────────────────────────────────┘

// White pixels: plain mix(). No hue to preserve.
vec3 whiteBlend(vec3 src, vec3 bg, float alpha)
{
    return mix(src, bg, alpha);
}

// Coloured pixels (Bright/All modes): hue-preserving blend.
// Blends luminance only, rescales RGB by ratio to preserve hue/saturation.
// Prevents GBC/GBA colours from greying out as they go semi-transparent.
vec3 huePreservingBlend(vec3 src, vec3 bg, float alpha)
{
    float srcLuma   = perceptualBrightness(src);
    float bgLuma    = perceptualBrightness(bg);
    float blendLuma = mix(srcLuma, bgLuma, alpha);
    float ratio     = (srcLuma > 0.001) ? (blendLuma / srcLuma) : 1.0;
    return clamp(src * ratio, 0.0, 1.0);
}

// ┌──────────────────────────────────┐
// │  Pixel Border                    │
// └──────────────────────────────────┘

// Sine-wave method. Works at any scale mode: aspect, integer, custom.
float pixelBorderFactor(vec2 coord)
{
    if (PT_PIXEL_BORDER < 0.5) return 1.0;

    vec2 imgPixelCoord = fract(coord * TextureSize);
    vec2 angle         = 2.0 * PI * (imgPixelCoord - 0.25);

    float wfactor, strength;
    if (PT_PIXEL_BORDER < 1.5) {
        wfactor  = 1.0 + (BORDER_WIDTH_FACTOR_MAX - 0.80 * BORDER_WIDTH_FACTOR_MAX);
        strength = 0.40;
    } else if (PT_PIXEL_BORDER < 2.5) {
        wfactor  = 1.0 + (BORDER_WIDTH_FACTOR_MAX - 0.90 * BORDER_WIDTH_FACTOR_MAX);
        strength = 0.65;
    } else {
        wfactor  = 1.0 + (BORDER_WIDTH_FACTOR_MAX - 0.97 * BORDER_WIDTH_FACTOR_MAX);
        strength = 0.85;
    }

    float yfactor    = (wfactor + sin(angle.y)) / (wfactor + 1.0);
    float xfactor    = (wfactor + sin(angle.x)) / (wfactor + 1.0);
    float lineWeight = 1.0 - (yfactor * xfactor);
    return 1.0 - lineWeight * strength;
}

// ┌──────────────────────────────────┐
// │  Drop Shadow                     │
// └──────────────────────────────────┘

// Directional gaussian blur along shadow direction vector.
// Gaussian weights sigma≈2.5, normalised. Centre + 7 per side = 15 samples.
// Loops fully unrolled for GLSL ES / mobile Vulkan compatibility.
float directionalShadowBlur(vec2 basePos, vec2 shadowDir, float stepSize, float blurAmt)
{
    float w0 = 0.2040; float w1 = 0.1801; float w2 = 0.1238; float w3 = 0.0666;
    float w4 = 0.0281; float w5 = 0.0093; float w6 = 0.0024; float w7 = 0.0005;

    float cBright = getBrightness(COMPAT_TEXTURE(OrigTexture, basePos).rgb);
    float blurred   = (1.0 - cBright) * w0;
    float weightSum = w0;

    blurred += (1.0 - getBrightness(COMPAT_TEXTURE(OrigTexture, basePos + shadowDir * stepSize * 1.0).rgb)) * w1;
    blurred += (1.0 - getBrightness(COMPAT_TEXTURE(OrigTexture, basePos - shadowDir * stepSize * 1.0).rgb)) * w1;
    weightSum += w1 * 2.0;

    blurred += (1.0 - getBrightness(COMPAT_TEXTURE(OrigTexture, basePos + shadowDir * stepSize * 2.0).rgb)) * w2;
    blurred += (1.0 - getBrightness(COMPAT_TEXTURE(OrigTexture, basePos - shadowDir * stepSize * 2.0).rgb)) * w2;
    weightSum += w2 * 2.0;

    blurred += (1.0 - getBrightness(COMPAT_TEXTURE(OrigTexture, basePos + shadowDir * stepSize * 3.0).rgb)) * w3;
    blurred += (1.0 - getBrightness(COMPAT_TEXTURE(OrigTexture, basePos - shadowDir * stepSize * 3.0).rgb)) * w3;
    weightSum += w3 * 2.0;

    blurred += (1.0 - getBrightness(COMPAT_TEXTURE(OrigTexture, basePos + shadowDir * stepSize * 4.0).rgb)) * w4;
    blurred += (1.0 - getBrightness(COMPAT_TEXTURE(OrigTexture, basePos - shadowDir * stepSize * 4.0).rgb)) * w4;
    weightSum += w4 * 2.0;

    blurred += (1.0 - getBrightness(COMPAT_TEXTURE(OrigTexture, basePos + shadowDir * stepSize * 5.0).rgb)) * w5;
    blurred += (1.0 - getBrightness(COMPAT_TEXTURE(OrigTexture, basePos - shadowDir * stepSize * 5.0).rgb)) * w5;
    weightSum += w5 * 2.0;

    blurred += (1.0 - getBrightness(COMPAT_TEXTURE(OrigTexture, basePos + shadowDir * stepSize * 6.0).rgb)) * w6;
    blurred += (1.0 - getBrightness(COMPAT_TEXTURE(OrigTexture, basePos - shadowDir * stepSize * 6.0).rgb)) * w6;
    weightSum += w6 * 2.0;

    blurred += (1.0 - getBrightness(COMPAT_TEXTURE(OrigTexture, basePos + shadowDir * stepSize * 7.0).rgb)) * w7;
    blurred += (1.0 - getBrightness(COMPAT_TEXTURE(OrigTexture, basePos - shadowDir * stepSize * 7.0).rgb)) * w7;
    weightSum += w7 * 2.0;

    float softShadow = blurred / weightSum;
    float hardShadow = 1.0 - cBright;
    return mix(hardShadow, softShadow, blurAmt);
}

// ┌──────────────────────────────────┐
// │  Halation                        │
// └──────────────────────────────────┘

// LCD diffuser glow for backlit screens (GBA SP only).
// Cross-pattern 8-tap radial sample. Only runs on transparent pixels.
// Off for GB, GBC, GBA Original — those had no backlight.
vec3 applyHalation(vec3 color, vec2 coord, float isTransparent)
{
    if (PT_HALATION < 0.001 || isTransparent < 0.5) return color;

    float step = PT_HALATION_RADIUS * texel.x;

    float glow = 0.0;
    glow += getBrightness(COMPAT_TEXTURE(Texture, coord + vec2( step,  0.0)).rgb);
    glow += getBrightness(COMPAT_TEXTURE(Texture, coord + vec2(-step,  0.0)).rgb);
    glow += getBrightness(COMPAT_TEXTURE(Texture, coord + vec2( 0.0,  step)).rgb);
    glow += getBrightness(COMPAT_TEXTURE(Texture, coord + vec2( 0.0, -step)).rgb);
    glow += getBrightness(COMPAT_TEXTURE(Texture, coord + vec2( step,  step)).rgb) * 0.5;
    glow += getBrightness(COMPAT_TEXTURE(Texture, coord + vec2(-step,  step)).rgb) * 0.5;
    glow += getBrightness(COMPAT_TEXTURE(Texture, coord + vec2( step, -step)).rgb) * 0.5;
    glow += getBrightness(COMPAT_TEXTURE(Texture, coord + vec2(-step, -step)).rgb) * 0.5;
    glow /= 6.0;

    vec3 glowColor = mix(vec3(1.0, 1.0, 1.0), vec3(1.0, 0.92, 0.75), PT_HALATION_WARMTH);
    return clamp(color + glowColor * glow * PT_HALATION, 0.0, 1.0);
}

// ┌──────────────────────────────────┐
// │  Dithering                       │
// └──────────────────────────────────┘

// Bayer ordered dither — breaks hard blend edge into dithered transition.
// Simulates slow LCD pixel response at colour/transparency boundaries.
// All if/else chains fully unrolled — no dynamic array indexing.
float getBayerDither(vec2 coord)
{
    // Pure float implementation — no integer types, GLES 2.0 compatible.
    float fx = mod(floor(coord.x * TextureSize.x), 8.0);
    float fy = mod(floor(coord.y * TextureSize.y), 8.0);

    if (PT_DITHER_MATRIX < 0.5) {
        // 2x2 Bayer
        float xi  = mod(fx, 2.0);
        float yi  = mod(fy, 2.0);
        float idx = yi * 2.0 + xi;
        float val;
        if      (idx < 0.5) val = 0.0;
        else if (idx < 1.5) val = 2.0;
        else if (idx < 2.5) val = 3.0;
        else                val = 1.0;
        return val / 4.0 - 0.5;

    } else if (PT_DITHER_MATRIX < 1.5) {
        // 4x4 Bayer
        float xi  = mod(fx, 4.0);
        float yi  = mod(fy, 4.0);
        float idx = yi * 4.0 + xi;
        float val;
        if      (idx <  0.5) val =  0.0; else if (idx <  1.5) val =  8.0;
        else if (idx <  2.5) val =  2.0; else if (idx <  3.5) val = 10.0;
        else if (idx <  4.5) val = 12.0; else if (idx <  5.5) val =  4.0;
        else if (idx <  6.5) val = 14.0; else if (idx <  7.5) val =  6.0;
        else if (idx <  8.5) val =  3.0; else if (idx <  9.5) val = 11.0;
        else if (idx < 10.5) val =  1.0; else if (idx < 11.5) val =  9.0;
        else if (idx < 12.5) val = 15.0; else if (idx < 13.5) val =  7.0;
        else if (idx < 14.5) val = 13.0; else                 val =  5.0;
        return val / 16.0 - 0.5;

    } else {
        // 8x8 Bayer
        float xi  = mod(fx, 8.0);
        float yi  = mod(fy, 8.0);
        float idx = yi * 8.0 + xi;
        float val;
        if      (idx <  0.5) val =  0.0; else if (idx <  1.5) val = 32.0;
        else if (idx <  2.5) val =  8.0; else if (idx <  3.5) val = 40.0;
        else if (idx <  4.5) val =  2.0; else if (idx <  5.5) val = 34.0;
        else if (idx <  6.5) val = 10.0; else if (idx <  7.5) val = 42.0;
        else if (idx <  8.5) val = 48.0; else if (idx <  9.5) val = 16.0;
        else if (idx < 10.5) val = 56.0; else if (idx < 11.5) val = 24.0;
        else if (idx < 12.5) val = 50.0; else if (idx < 13.5) val = 18.0;
        else if (idx < 14.5) val = 58.0; else if (idx < 15.5) val = 26.0;
        else if (idx < 16.5) val = 12.0; else if (idx < 17.5) val = 44.0;
        else if (idx < 18.5) val =  4.0; else if (idx < 19.5) val = 36.0;
        else if (idx < 20.5) val = 14.0; else if (idx < 21.5) val = 46.0;
        else if (idx < 22.5) val =  6.0; else if (idx < 23.5) val = 38.0;
        else if (idx < 24.5) val = 60.0; else if (idx < 25.5) val = 28.0;
        else if (idx < 26.5) val = 52.0; else if (idx < 27.5) val = 20.0;
        else if (idx < 28.5) val = 62.0; else if (idx < 29.5) val = 30.0;
        else if (idx < 30.5) val = 54.0; else if (idx < 31.5) val = 22.0;
        else if (idx < 32.5) val =  3.0; else if (idx < 33.5) val = 35.0;
        else if (idx < 34.5) val = 11.0; else if (idx < 35.5) val = 43.0;
        else if (idx < 36.5) val =  1.0; else if (idx < 37.5) val = 33.0;
        else if (idx < 38.5) val =  9.0; else if (idx < 39.5) val = 41.0;
        else if (idx < 40.5) val = 51.0; else if (idx < 41.5) val = 19.0;
        else if (idx < 42.5) val = 59.0; else if (idx < 43.5) val = 27.0;
        else if (idx < 44.5) val = 49.0; else if (idx < 45.5) val = 17.0;
        else if (idx < 46.5) val = 57.0; else if (idx < 47.5) val = 25.0;
        else if (idx < 48.5) val = 15.0; else if (idx < 49.5) val = 47.0;
        else if (idx < 50.5) val =  7.0; else if (idx < 51.5) val = 39.0;
        else if (idx < 52.5) val = 13.0; else if (idx < 53.5) val = 45.0;
        else if (idx < 54.5) val =  5.0; else if (idx < 55.5) val = 37.0;
        else if (idx < 56.5) val = 63.0; else if (idx < 57.5) val = 31.0;
        else if (idx < 58.5) val = 55.0; else if (idx < 59.5) val = 23.0;
        else if (idx < 60.5) val = 61.0; else if (idx < 61.5) val = 29.0;
        else if (idx < 62.5) val = 53.0; else                 val = 21.0;
        return val / 64.0 - 0.5;
    }
}

// ┌──────────────────────────────────┐
// │  Screen Curvature                │
// └──────────────────────────────────┘

// Barrel distortion. Returns vec2(-1) sentinel for out-of-bounds pixels.
vec2 applyCurvature(vec2 coord)
{
    if (PT_CURVATURE < 0.5) return coord;
    vec2  uv       = coord * 2.0 - 1.0;
    float strength = PT_CURVATURE_STRENGTH * 0.3;
    uv = uv + uv * dot(uv, uv) * strength;
    vec2 remapped = uv * 0.5 + 0.5;
    if (remapped.x < 0.0 || remapped.x > 1.0 ||
        remapped.y < 0.0 || remapped.y > 1.0) {
        return vec2(-1.0);
    }
    return remapped;
}

// Edge chromatic fringing — simulates lens refraction at screen periphery.
vec3 sampleWithFringe(vec2 coord)
{
    if (PT_CURVATURE_FRINGE < 0.001) return COMPAT_TEXTURE(Texture, coord).rgb;
    vec2  fromCenter = coord - 0.5;
    float dist       = length(fromCenter);
    float fringe     = dist * 0.02 * PT_CURVATURE_FRINGE;
    vec2  dir        = normalize(fromCenter + vec2(0.0001));
    float r = COMPAT_TEXTURE(Texture, coord + dir * fringe).r;
    float g = COMPAT_TEXTURE(Texture, coord            ).g;
    float b = COMPAT_TEXTURE(Texture, coord - dir * fringe).b;
    return vec3(r, g, b);
}

// ┌──────────────────────────────────┐
// │  Post-Blend Effects              │
// └──────────────────────────────────┘

// Global chromatic aberration — pure UV math, zero extra taps.
vec3 applyChromaShift(vec3 color, vec2 coord)
{
    if (PT_CHROMA < 0.001) return color;
    vec2  offset = (coord - 0.5) * PT_CHROMA * 0.02;
    float r      = mix(color.r, color.r * (1.0 + offset.x), 0.5);
    float b      = mix(color.b, color.b * (1.0 - offset.x), 0.5);
    return clamp(vec3(r, color.g, b), 0.0, 1.0);
}

// Vignette — pure math, zero extra taps.
vec3 applyVignette(vec3 color, vec2 coord)
{
    if (PT_VIGNETTE < 0.001) return color;
    vec2  uv       = coord * 2.0 - 1.0;
    float dist     = dot(uv, uv);
    float vignette = 1.0 - dist * PT_VIGNETTE;
    return color * clamp(vignette, 0.0, 1.0);
}

// ╔══════════════════════════════════════════════════════════════╗
// ║  MAIN                                                        ║
// ╚══════════════════════════════════════════════════════════════╝
void main()
{
    // Screen curvature UV remapping — must happen first.
    vec2 curvedUV = applyCurvature(TEX0.xy);
    if (curvedUV.x < 0.0) {
        FragColor = vec4(0.0, 0.0, 0.0, 1.0);
        return;
    }
    vec2 curvedOrigCoord = orig_coord + (curvedUV - TEX0.xy);

    // Sample source textures.
    vec4 lcd;
    if (PT_CURVATURE > 0.5 && PT_CURVATURE_FRINGE > 0.001) {
        lcd = vec4(sampleWithFringe(curvedUV), 1.0);
    } else {
        lcd = COMPAT_TEXTURE(Texture, curvedUV);
    }
    vec3 pixel    = lcd.rgb;
    vec3 rawPixel = COMPAT_TEXTURE(OrigTexture, curvedOrigCoord).rgb;

    // Color harshness filter.
    if (PT_DARK_FILTER_LEVEL > 0.5) {
        pixel   = applyDarkFilter(pixel, PT_DARK_FILTER_LEVEL);
        lcd.rgb = pixel;
    }

    // White detection — on rawPixel (OrigTexture, pre-correction).
    // whiteness is 0..1 soft gradient. rawBrightness drives alpha.
    float threshold     = resolveThreshold();
    float whiteness     = whitePixelStrength(rawPixel, threshold);
    float rawBrightness = perceptualBrightness(rawPixel);

    // Build procedural backing texture.
    vec3 bg = proceduralBackground(curvedUV);
    if (PT_PALETTE > 0.5) {
        vec3 tint;
        if      (PT_PALETTE < 1.5) tint = vec3(0.651, 0.675, 0.518); // Pocket grey
        else if (PT_PALETTE < 2.5) tint = vec3(0.737, 0.737, 0.737); // Cool grey
        else if (PT_PALETTE < 3.5) tint = vec3(1.0,   1.0,   1.0  ); // White (GBA SP)
        else                       tint = vec3(0.60,  0.64,  0.46  ); // Green-grey (GBA Orig)
        // Overlay blend: grain texture onto tint colour.
        // Dark grain pulls the tint down, bright grain lifts it --
        // matching the physical behaviour of a textured backing material.
        vec3 tinted = clamp(mix(
            2.0 * tint * bg,
            1.0 - 2.0 * (1.0 - tint) * (1.0 - bg),
            step(0.5, bg)
        ), 0.0, 1.0);
        bg = mix(bg, tinted, PT_PALETTE_INTENSITY);
    }

    // Transparency gate — 0/1 for shadow and halation gating.
    float willBeTransparent;
    if      (PT_PIXEL_MODE < 0.5) willBeTransparent = step(0.001, whiteness);
    else if (PT_PIXEL_MODE < 1.5) willBeTransparent = step(threshold * 0.9, rawBrightness);
    else                          willBeTransparent = 1.0;

    // Drop shadow with optional directional gaussian blur.
    if (willBeTransparent > 0.5 && PT_SHADOW_OPACITY > 0.001) {
        // Scale shadow offset proportionally to output scale so it appears
        // consistent regardless of how much the source frame is scaled up.
        float shadow_sx    = OutputSize.x / InputSize.x;
        float shadow_sy    = OutputSize.y / InputSize.y;
        float shadow_scale = sqrt(shadow_sx * shadow_sy);
        vec2 shadowOffset  = vec2(-PT_SHADOW_OFFSET_X, -PT_SHADOW_OFFSET_Y)
                            * (1.0 / TextureSize) * shadow_scale;
        vec2 shadowPos    = curvedOrigCoord + shadowOffset;

        float shadowDark;
        if (PT_SHADOW_BLUR > 0.001) {
            vec2  shadowDir = normalize(shadowOffset + vec2(0.0001));
            float stepSize  = PT_SHADOW_BLUR_RADIUS * (1.0 / TextureSize.x);
            shadowDark = directionalShadowBlur(shadowPos, shadowDir, stepSize, PT_SHADOW_BLUR / 5.0);
        } else {
            shadowDark = 1.0 - getBrightness(COMPAT_TEXTURE(OrigTexture, shadowPos).rgb);
        }
        float shadowStrength = (shadowDark * shadowDark) * PT_SHADOW_OPACITY;
        bg = mix(bg, bg * 0.2, shadowStrength);
    }

    // Transparency blend with optional Bayer dithering.
    // Alpha driven by raw brightness — consistent with detection on raw frame.
    // White pixels: plain mix(). Coloured pixels: hue-preserving blend.
    float dither = 0.0;
    if (PT_DITHER > 0.5) dither = getBayerDither(curvedUV) * PT_DITHER_STRENGTH;
    vec3 result = pixel;

    if (PT_PIXEL_MODE < 0.5) {
        if (whiteness > 0.001) {
            float distAbove = clamp((rawBrightness - threshold) / (1.0 - threshold + 0.001), 0.0, 1.0);
            float alpha     = clamp(PT_BASE_ALPHA + distAbove * (1.0 - PT_BASE_ALPHA) * whiteness + dither, 0.0, 1.0);
            alpha           = max(alpha, PT_WHITE_TRANSPARENCY * whiteness);
            result          = whiteBlend(pixel, bg, alpha);
        }
    } else if (PT_PIXEL_MODE < 1.5) {
        float alpha = clamp(PT_BASE_ALPHA * rawBrightness * 2.4 + dither, 0.0, 1.0);
        if (whiteness > 0.001) alpha = max(alpha, PT_WHITE_TRANSPARENCY * whiteness);
        result = huePreservingBlend(pixel, bg, alpha);
    } else {
        float distAbove = clamp((rawBrightness - threshold) / (1.0 - threshold + 0.001), 0.0, 1.0);
        float alpha     = clamp(PT_BASE_ALPHA + distAbove * (1.0 - PT_BASE_ALPHA) * 0.5 + dither, 0.0, 1.0);
        if (whiteness > 0.001) alpha = max(alpha, PT_WHITE_TRANSPARENCY * whiteness);
        result = huePreservingBlend(pixel, bg, alpha);
    }

    // Halation — after blend, only on transparent pixels.
    result = applyHalation(result, curvedUV, willBeTransparent);

    // Post-blend effects.
    result = result * pixelBorderFactor(curvedUV);
    result = applyChromaShift(result, curvedUV);
    result = applyVignette(result, curvedUV);

    FragColor = vec4(result, lcd.a);
}
#endif
