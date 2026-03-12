#version 450
/*
╔══════════════════════════════════════════════════════════════════╗
║  PT SkyWalker541 Pro  v1.5.0                                     ║
║  by SkyWalker541  |  Written for RetroArch (Slang / Vulkan)      ║
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
      backing. PT_HALATION = 0. PT_PALETTE = 1 (Pocket grey).

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
  With all Pro features off = equivalent to PT_SkyWalker541.slang.

╔══════════════════════════════════════════════════════════════════╗
║  CHANGELOG                                                       ║
╚══════════════════════════════════════════════════════════════════╝

  v1.5.0 - Unified version number across all PT_SkyWalker541 variants
           (Standard, Pro, NextUI). No shader logic changes.

  v1.1.0 - Transparency pipeline improvements:
           Soft detection edge — whitePixelStrength() returns 0..1
           via smoothstep over [threshold, threshold+0.08]. Eliminates
           detection boundary fringing. Alpha driven by raw brightness.
           Distance-above-threshold alpha scaling. Separate blend paths:
           white pixels use mix(), coloured pixels use
           huePreservingBlend().

  v1.0.0 - Initial Pro release. Directional gaussian shadow blur
           (15-tap), LCD halation, Bayer dithering (2x2/4x4/8x8),
           screen curvature with edge fringing, improved grain,
           PT_SYSTEM expanded to include GBA SP (3) and GBA
           Original (4), green-grey palette option.
*/

// ╔══════════════════════════════════════════════════════════════╗
// ║  PARAMETERS                                                  ║
// ║  All #pragma parameter lines must appear before #pragma stage║
// ╚══════════════════════════════════════════════════════════════╝

// ┌──────────────────────────────────┐
// │  System Preset                   │
// └──────────────────────────────────┘
// 0=Manual  1=GB/Pocket  2=GBC  3=GBA SP  4=GBA Original
#pragma parameter PT_SYSTEM "System (0=Manual, 1=GB, 2=GBC, 3=GBA SP, 4=GBA Orig)" 1.0 0.0 4.0 1.0
#pragma parameter PT_SENSITIVITY "  Manual threshold (PT_SYSTEM=0 only)" 0.85 0.0 1.0 0.01

// ┌──────────────────────────────────┐
// │  Pixel Transparency              │
// └──────────────────────────────────┘
// 0=White only  1=Bright  2=All
#pragma parameter PT_PIXEL_MODE "Pixel mode (0=White only, 1=Bright, 2=All)" 0.0 0.0 2.0 1.0
// GB/GBC: 0.20  GBA SP: 0.15  GBA Orig: 0.25
#pragma parameter PT_BASE_ALPHA "  Base transparency amount" 0.20 0.0 1.0 0.01
#pragma parameter PT_WHITE_TRANSPARENCY "  White pixel min transparency" 0.50 0.0 1.0 0.01

// ┌──────────────────────────────────┐
// │  Brightness                      │
// └──────────────────────────────────┘
// 0=Simple (R+G+B avg)  1=Perceptual (BT.709)
#pragma parameter PT_BRIGHTNESS_MODE "Brightness mode (0=Simple, 1=Perceptual)" 0.0 0.0 1.0 1.0

// ┌──────────────────────────────────┐
// │  Background                      │
// └──────────────────────────────────┘
// 0=Off  1=Pocket grey  2=Cool grey  3=White (GBA SP)  4=Green-grey (GBA Orig)
#pragma parameter PT_PALETTE "Background tint (0=Off, 1=Pocket, 2=Grey, 3=White, 4=Green-grey)" 1.0 0.0 4.0 1.0
#pragma parameter PT_PALETTE_INTENSITY "  Tint intensity" 1.0 0.0 2.0 0.05
// GB: 0.10  GBC: 0.07  GBA SP: 0.03  GBA Orig: 0.08
#pragma parameter PT_GRAIN_INTENSITY "  Grain intensity (0=flat)" 0.08 0.0 0.30 0.005
// GB: 0.30  GBC: 0.25  GBA: 0.15
#pragma parameter PT_GRAIN_SCALE "  Grain scale (lower=finer)" 0.25 0.05 1.0 0.05

// ┌──────────────────────────────────┐
// │  Color Harshness Filter          │
// └──────────────────────────────────┘
// 0=off. 5-15 natural for GBC/GBA. Not needed for GB.
#pragma parameter PT_DARK_FILTER_LEVEL "Dark color filter (0=off)" 0.0 0.0 100.0 1.0

// ┌──────────────────────────────────┐
// │  Pixel Border                    │
// └──────────────────────────────────┘
// 0=Off  1=Subtle  2=Moderate  3=Strong. GB/GBC: 1. GBA: 0.
#pragma parameter PT_PIXEL_BORDER "Pixel border (0=Off, 1=Subtle, 2=Med, 3=Strong)" 1.0 0.0 3.0 1.0

// ┌──────────────────────────────────┐
// │  Drop Shadow                     │
// └──────────────────────────────────┘
#pragma parameter PT_SHADOW_OFFSET_X "Shadow X offset (texels)" 1.0 -10.0 10.0 0.5
#pragma parameter PT_SHADOW_OFFSET_Y "Shadow Y offset (texels)" 1.0 -10.0 10.0 0.5
#pragma parameter PT_SHADOW_OPACITY "Shadow opacity (0=off)" 0.30 0.0 1.0 0.01
// Directional gaussian blur along shadow vector. 0=hard edge (fastest). 0.5-2.0 recommended.
#pragma parameter PT_SHADOW_BLUR "Shadow blur (0=off)" 1.0 0.0 5.0 0.1
// 0.5=tight  1.0=natural  2.0=wide
#pragma parameter PT_SHADOW_BLUR_RADIUS "  Shadow blur radius (texels)" 1.0 0.1 4.0 0.1

// ┌──────────────────────────────────┐
// │  Halation                        │
// └──────────────────────────────────┘
// ONLY for backlit screens. Off for GB, GBC, GBA Original.
// GBA SP: 0.05-0.15
#pragma parameter PT_HALATION "Halation / diffuser glow (0=off)" 0.0 0.0 1.0 0.01
// GBA SP: 1.0-2.0
#pragma parameter PT_HALATION_RADIUS "  Halation radius (texels)" 1.5 0.1 5.0 0.1
// 0=cool white  0.3=GBA SP warmth  1=warm amber
#pragma parameter PT_HALATION_WARMTH "  Halation warmth (0=cool, 1=warm)" 0.3 0.0 1.0 0.05

// ┌──────────────────────────────────┐
// │  Dithering                       │
// └──────────────────────────────────┘
// Simulates slow LCD pixel response at blend boundaries.
#pragma parameter PT_DITHER "Dither blend edges (0=off, 1=on)" 1.0 0.0 1.0 1.0
// GB: 0.06  GBC: 0.04  GBA SP: 0.02  GBA Orig: 0.05
#pragma parameter PT_DITHER_STRENGTH "  Dither strength" 0.05 0.0 0.20 0.005
// 0=2x2  1=4x4  2=8x8. 4x4 recommended.
#pragma parameter PT_DITHER_MATRIX "  Dither matrix (0=2x2, 1=4x4, 2=8x8)" 1.0 0.0 2.0 1.0

// ┌──────────────────────────────────┐
// │  Screen Curvature                │
// └──────────────────────────────────┘
// All original GB/GBC/GBA screens were flat — aesthetic option only.
#pragma parameter PT_CURVATURE "Screen curvature (0=off)" 0.0 0.0 1.0 0.01
// 0.1=barely visible  0.3=moderate  0.5=strong
#pragma parameter PT_CURVATURE_STRENGTH "  Curvature strength" 0.20 0.0 1.0 0.01
// Simulates light refraction at screen edges. 0=off  0.4=subtle  1.0=strong
#pragma parameter PT_CURVATURE_FRINGE "  Edge chromatic fringe (0=off)" 0.4 0.0 1.0 0.05

// ┌──────────────────────────────────┐
// │  Post-Blend Effects              │
// └──────────────────────────────────┘
// Global chromatic aberration across full image (different from curvature fringe).
#pragma parameter PT_CHROMA "Chromatic shift (0=off)" 0.0 0.0 1.0 0.01
// GB poor light: 0.10-0.15  GBA SP: 0.05
#pragma parameter PT_VIGNETTE "Vignette strength (0=off)" 0.08 0.0 1.0 0.01

// ╔══════════════════════════════════════════════════════════════╗
// ║  UNIFORM BLOCKS                                              ║
// ║  RetroArch Slang requires #pragma parameter floats to be in  ║
// ║  push_constant. Builtins go in UBO to stay under 128 bytes.  ║
// ║  28 params × 4 bytes = 112 bytes — fits the Vulkan minimum.  ║
// ╚══════════════════════════════════════════════════════════════╝

layout(push_constant) uniform Push {
    float PT_SYSTEM;
    float PT_SENSITIVITY;
    float PT_PIXEL_MODE;
    float PT_BASE_ALPHA;
    float PT_WHITE_TRANSPARENCY;
    float PT_BRIGHTNESS_MODE;
    float PT_PALETTE;
    float PT_PALETTE_INTENSITY;
    float PT_GRAIN_INTENSITY;
    float PT_GRAIN_SCALE;
    float PT_DARK_FILTER_LEVEL;
    float PT_PIXEL_BORDER;
    float PT_SHADOW_OFFSET_X;
    float PT_SHADOW_OFFSET_Y;
    float PT_SHADOW_OPACITY;
    float PT_SHADOW_BLUR;
    float PT_SHADOW_BLUR_RADIUS;
    float PT_HALATION;
    float PT_HALATION_RADIUS;
    float PT_HALATION_WARMTH;
    float PT_DITHER;
    float PT_DITHER_STRENGTH;
    float PT_DITHER_MATRIX;
    float PT_CURVATURE;
    float PT_CURVATURE_STRENGTH;
    float PT_CURVATURE_FRINGE;
    float PT_CHROMA;
    float PT_VIGNETTE;
} params;

layout(std140, set = 0, binding = 0) uniform UBO {
    mat4  MVP;
    vec4  SourceSize;    // xy = source texture dimensions, zw = 1/dimensions
    vec4  OriginalSize;  // xy = original input dimensions, zw = 1/dimensions
    vec4  OutputSize;    // xy = output viewport dimensions, zw = 1/dimensions
    uint  FrameCount;
} global;

// Convenience macros — access push_constant params without "params." prefix
#define PT_SYSTEM             params.PT_SYSTEM
#define PT_SENSITIVITY        params.PT_SENSITIVITY
#define PT_PIXEL_MODE         params.PT_PIXEL_MODE
#define PT_BASE_ALPHA         params.PT_BASE_ALPHA
#define PT_WHITE_TRANSPARENCY params.PT_WHITE_TRANSPARENCY
#define PT_BRIGHTNESS_MODE    params.PT_BRIGHTNESS_MODE
#define PT_PALETTE            params.PT_PALETTE
#define PT_PALETTE_INTENSITY  params.PT_PALETTE_INTENSITY
#define PT_GRAIN_INTENSITY    params.PT_GRAIN_INTENSITY
#define PT_GRAIN_SCALE        params.PT_GRAIN_SCALE
#define PT_DARK_FILTER_LEVEL  params.PT_DARK_FILTER_LEVEL
#define PT_PIXEL_BORDER       params.PT_PIXEL_BORDER
#define PT_SHADOW_OFFSET_X    params.PT_SHADOW_OFFSET_X
#define PT_SHADOW_OFFSET_Y    params.PT_SHADOW_OFFSET_Y
#define PT_SHADOW_OPACITY     params.PT_SHADOW_OPACITY
#define PT_SHADOW_BLUR        params.PT_SHADOW_BLUR
#define PT_SHADOW_BLUR_RADIUS params.PT_SHADOW_BLUR_RADIUS
#define PT_HALATION           params.PT_HALATION
#define PT_HALATION_RADIUS    params.PT_HALATION_RADIUS
#define PT_HALATION_WARMTH    params.PT_HALATION_WARMTH
#define PT_DITHER             params.PT_DITHER
#define PT_DITHER_STRENGTH    params.PT_DITHER_STRENGTH
#define PT_DITHER_MATRIX      params.PT_DITHER_MATRIX
#define PT_CURVATURE          params.PT_CURVATURE
#define PT_CURVATURE_STRENGTH params.PT_CURVATURE_STRENGTH
#define PT_CURVATURE_FRINGE   params.PT_CURVATURE_FRINGE
#define PT_CHROMA             params.PT_CHROMA
#define PT_VIGNETTE           params.PT_VIGNETTE

// ╔══════════════════════════════════════════════════════════════╗
// ║  VERTEX SHADER                                               ║
// ╚══════════════════════════════════════════════════════════════╝
#pragma stage vertex

layout(location = 0) in  vec4 Position;
layout(location = 1) in  vec2 TexCoord;
layout(location = 0) out vec2 vTexCoord;

void main()
{
    gl_Position = global.MVP * Position;
    vTexCoord   = TexCoord;
}

// ╔══════════════════════════════════════════════════════════════╗
// ║  FRAGMENT SHADER                                             ║
// ╚══════════════════════════════════════════════════════════════╝
#pragma stage fragment

layout(location = 0) in  vec2 vTexCoord;
layout(location = 0) out vec4 FragColor;

// Source:   colour-corrected processed frame (display output + shadow sampling)
// Original: raw unprocessed input frame (white detection only)
layout(set = 0, binding = 2) uniform sampler2D Source;
layout(set = 0, binding = 3) uniform sampler2D Original;

// ┌──────────────────────────────────┐
// │  Constants                       │
// └──────────────────────────────────┘
#define LUMA_R 0.2126
#define LUMA_G 0.7152
#define LUMA_B 0.0722
#define PI                      3.141592654
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

// Resolve system preset → detection threshold.
//   GB/Pocket: 0.88   GBC: 0.85   GBA SP: 0.80   GBA Orig: 0.75
float resolveThreshold()
{
    if (PT_SYSTEM < 0.5) return PT_SENSITIVITY;
    if (PT_SYSTEM < 1.5) return 0.88;
    if (PT_SYSTEM < 2.5) return 0.85;
    if (PT_SYSTEM < 3.5) return 0.80;
    return 0.75;
}

// Soft detection: channel range is hard gate, brightness is smoothstep.
// Returns 0..1 — gradient over [threshold, threshold+0.08].
// Eliminates hard fringing at the detection boundary.
// Runs on rawPixel (Original semantic) — pre-correction values are stable.
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
float noiseHash(vec2 p)
{
    vec3 p3 = fract(vec3(p.xyx) * 0.1031);
    p3 += vec3(dot(p3, p3.yzx + 33.33));
    return fract((p3.x + p3.y) * p3.z);
}

vec3 proceduralBackground(vec2 uv)
{
    vec2  p = uv * (256.0 * PT_GRAIN_SCALE);
    float n = 0.0;
    n += noiseHash(p)       * 0.500;
    n += noiseHash(p * 2.0) * 0.250;
    n += noiseHash(p * 4.0) * 0.125;
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

    vec2 imgPixelCoord = fract(coord * global.SourceSize.xy);
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
// Fully unrolled — no loop, no array. Required for mobile Vulkan (Adreno, Mali).
float directionalShadowBlur(vec2 basePos, vec2 shadowDir, float stepSize, float blurAmount)
{
    float w0 = 0.2040; float w1 = 0.1801; float w2 = 0.1238; float w3 = 0.0666;
    float w4 = 0.0281; float w5 = 0.0093; float w6 = 0.0024; float w7 = 0.0005;

    float cBright = getBrightness(texture(Original, basePos).rgb);
    float blurred   = (1.0 - cBright) * w0;
    float weightSum = w0;

    blurred += (1.0 - getBrightness(texture(Original, basePos + shadowDir * stepSize * 1.0).rgb)) * w1;
    blurred += (1.0 - getBrightness(texture(Original, basePos - shadowDir * stepSize * 1.0).rgb)) * w1;
    weightSum += w1 * 2.0;
    blurred += (1.0 - getBrightness(texture(Original, basePos + shadowDir * stepSize * 2.0).rgb)) * w2;
    blurred += (1.0 - getBrightness(texture(Original, basePos - shadowDir * stepSize * 2.0).rgb)) * w2;
    weightSum += w2 * 2.0;
    blurred += (1.0 - getBrightness(texture(Original, basePos + shadowDir * stepSize * 3.0).rgb)) * w3;
    blurred += (1.0 - getBrightness(texture(Original, basePos - shadowDir * stepSize * 3.0).rgb)) * w3;
    weightSum += w3 * 2.0;
    blurred += (1.0 - getBrightness(texture(Original, basePos + shadowDir * stepSize * 4.0).rgb)) * w4;
    blurred += (1.0 - getBrightness(texture(Original, basePos - shadowDir * stepSize * 4.0).rgb)) * w4;
    weightSum += w4 * 2.0;
    blurred += (1.0 - getBrightness(texture(Original, basePos + shadowDir * stepSize * 5.0).rgb)) * w5;
    blurred += (1.0 - getBrightness(texture(Original, basePos - shadowDir * stepSize * 5.0).rgb)) * w5;
    weightSum += w5 * 2.0;
    blurred += (1.0 - getBrightness(texture(Original, basePos + shadowDir * stepSize * 6.0).rgb)) * w6;
    blurred += (1.0 - getBrightness(texture(Original, basePos - shadowDir * stepSize * 6.0).rgb)) * w6;
    weightSum += w6 * 2.0;
    blurred += (1.0 - getBrightness(texture(Original, basePos + shadowDir * stepSize * 7.0).rgb)) * w7;
    blurred += (1.0 - getBrightness(texture(Original, basePos - shadowDir * stepSize * 7.0).rgb)) * w7;
    weightSum += w7 * 2.0;

    float hardShadow = 1.0 - cBright;
    float softShadow = blurred / weightSum;
    return mix(hardShadow, softShadow, blurAmount);
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

    float step = PT_HALATION_RADIUS * global.SourceSize.z;

    float glow = 0.0;
    glow += getBrightness(texture(Source, coord + vec2( step,  0.0)).rgb);
    glow += getBrightness(texture(Source, coord + vec2(-step,  0.0)).rgb);
    glow += getBrightness(texture(Source, coord + vec2( 0.0,  step)).rgb);
    glow += getBrightness(texture(Source, coord + vec2( 0.0, -step)).rgb);
    glow += getBrightness(texture(Source, coord + vec2( step,  step)).rgb) * 0.5;
    glow += getBrightness(texture(Source, coord + vec2(-step,  step)).rgb) * 0.5;
    glow += getBrightness(texture(Source, coord + vec2( step, -step)).rgb) * 0.5;
    glow += getBrightness(texture(Source, coord + vec2(-step, -step)).rgb) * 0.5;
    glow /= 6.0;

    // Warm amber = GBA SP front-light colour temperature
    vec3 glowColor = mix(vec3(1.0, 1.0, 1.0), vec3(1.0, 0.92, 0.75), PT_HALATION_WARMTH);
    return clamp(color + glowColor * glow * PT_HALATION, 0.0, 1.0);
}

// ┌──────────────────────────────────┐
// │  Dithering                       │
// └──────────────────────────────────┘

// Bayer ordered dither — breaks hard blend edge into dithered transition.
// Simulates slow LCD pixel response at colour/transparency boundaries.
// Fully unrolled if/else — no arrays, no dynamic indexing.
// Required for mobile Vulkan drivers (Adreno, Mali).
float getBayerDither(vec2 coord)
{
    ivec2 px = ivec2(mod(coord * global.SourceSize.xy, 8.0));
    int x = px.x;
    int y = px.y;

    if (PT_DITHER_MATRIX < 0.5) {
        // 2x2 Bayer
        int idx = (y % 2) * 2 + (x % 2);
        float v;
        if      (idx == 0) v = 0.0;
        else if (idx == 1) v = 2.0;
        else if (idx == 2) v = 3.0;
        else               v = 1.0;
        return v / 4.0 - 0.5;

    } else if (PT_DITHER_MATRIX < 1.5) {
        // 4x4 Bayer
        int idx = (y % 4) * 4 + (x % 4);
        float v;
        if      (idx ==  0) v =  0.0; else if (idx ==  1) v =  8.0;
        else if (idx ==  2) v =  2.0; else if (idx ==  3) v = 10.0;
        else if (idx ==  4) v = 12.0; else if (idx ==  5) v =  4.0;
        else if (idx ==  6) v = 14.0; else if (idx ==  7) v =  6.0;
        else if (idx ==  8) v =  3.0; else if (idx ==  9) v = 11.0;
        else if (idx == 10) v =  1.0; else if (idx == 11) v =  9.0;
        else if (idx == 12) v = 15.0; else if (idx == 13) v =  7.0;
        else if (idx == 14) v = 13.0; else                v =  5.0;
        return v / 16.0 - 0.5;

    } else {
        // 8x8 Bayer
        int idx = (y % 8) * 8 + (x % 8);
        float v;
        if      (idx ==  0) v =  0.0; else if (idx ==  1) v = 32.0;
        else if (idx ==  2) v =  8.0; else if (idx ==  3) v = 40.0;
        else if (idx ==  4) v =  2.0; else if (idx ==  5) v = 34.0;
        else if (idx ==  6) v = 10.0; else if (idx ==  7) v = 42.0;
        else if (idx ==  8) v = 48.0; else if (idx ==  9) v = 16.0;
        else if (idx == 10) v = 56.0; else if (idx == 11) v = 24.0;
        else if (idx == 12) v = 50.0; else if (idx == 13) v = 18.0;
        else if (idx == 14) v = 58.0; else if (idx == 15) v = 26.0;
        else if (idx == 16) v = 12.0; else if (idx == 17) v = 44.0;
        else if (idx == 18) v =  4.0; else if (idx == 19) v = 36.0;
        else if (idx == 20) v = 14.0; else if (idx == 21) v = 46.0;
        else if (idx == 22) v =  6.0; else if (idx == 23) v = 38.0;
        else if (idx == 24) v = 60.0; else if (idx == 25) v = 28.0;
        else if (idx == 26) v = 52.0; else if (idx == 27) v = 20.0;
        else if (idx == 28) v = 62.0; else if (idx == 29) v = 30.0;
        else if (idx == 30) v = 54.0; else if (idx == 31) v = 22.0;
        else if (idx == 32) v =  3.0; else if (idx == 33) v = 35.0;
        else if (idx == 34) v = 11.0; else if (idx == 35) v = 43.0;
        else if (idx == 36) v =  1.0; else if (idx == 37) v = 33.0;
        else if (idx == 38) v =  9.0; else if (idx == 39) v = 41.0;
        else if (idx == 40) v = 51.0; else if (idx == 41) v = 19.0;
        else if (idx == 42) v = 59.0; else if (idx == 43) v = 27.0;
        else if (idx == 44) v = 49.0; else if (idx == 45) v = 17.0;
        else if (idx == 46) v = 57.0; else if (idx == 47) v = 25.0;
        else if (idx == 48) v = 15.0; else if (idx == 49) v = 47.0;
        else if (idx == 50) v =  7.0; else if (idx == 51) v = 39.0;
        else if (idx == 52) v = 13.0; else if (idx == 53) v = 45.0;
        else if (idx == 54) v =  5.0; else if (idx == 55) v = 37.0;
        else if (idx == 56) v = 63.0; else if (idx == 57) v = 31.0;
        else if (idx == 58) v = 55.0; else if (idx == 59) v = 23.0;
        else if (idx == 60) v = 61.0; else if (idx == 61) v = 29.0;
        else if (idx == 62) v = 53.0; else                v = 21.0;
        return v / 64.0 - 0.5;
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
    uv += uv * dot(uv, uv) * strength;
    vec2 remapped = uv * 0.5 + 0.5;
    if (remapped.x < 0.0 || remapped.x > 1.0 ||
        remapped.y < 0.0 || remapped.y > 1.0) {
        return vec2(-1.0);
    }
    return remapped;
}

// Edge chromatic fringing — simulates lens refraction at screen periphery.
vec3 sampleWithFringe(sampler2D tex, vec2 coord)
{
    if (PT_CURVATURE_FRINGE < 0.001) return texture(tex, coord).rgb;
    vec2  fromCenter = coord - 0.5;
    float dist       = length(fromCenter);
    float fringe     = dist * 0.02 * PT_CURVATURE_FRINGE;
    vec2  dir        = normalize(fromCenter + vec2(0.0001));
    float r = texture(tex, coord + dir *  fringe).r;
    float g = texture(tex, coord             ).g;
    float b = texture(tex, coord - dir *  fringe).b;
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
    vec2 curvedUV = applyCurvature(vTexCoord);
    if (curvedUV.x < 0.0) {
        FragColor = vec4(0.0, 0.0, 0.0, 1.0);
        return;
    }

    // Snap to texel centre to eliminate bilinear filtering artifacts.
    vec2 imgPixelCoord = curvedUV * global.SourceSize.xy;
    vec2 snappedUV     = (floor(imgPixelCoord) + vec2(0.5)) * global.SourceSize.zw;

    // Sample source textures.
    // lcd      — colour-corrected frame (Source). Used for display and shadows.
    // rawPixel — raw pre-correction frame (Original). Used for white detection.
    vec4 lcd;
    if (PT_CURVATURE > 0.5 && PT_CURVATURE_FRINGE > 0.001) {
        lcd = vec4(sampleWithFringe(Source, snappedUV), 1.0);
    } else {
        lcd = texture(Source, snappedUV);
    }
    vec3 pixel    = lcd.rgb;
    vec3 rawPixel = texture(Original, snappedUV).rgb;

    // Color harshness filter — applied to Source before any blending.
    if (PT_DARK_FILTER_LEVEL > 0.5) {
        pixel   = applyDarkFilter(pixel, PT_DARK_FILTER_LEVEL);
        lcd.rgb = pixel;
    }

    // White detection — on rawPixel (Original, pre-correction).
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
        vec3 tinted = clamp(vec3(
            tint.r + mix(-1.0, 1.0, bg.r),
            tint.g + mix(-1.0, 1.0, bg.g),
            tint.b + mix(-1.0, 1.0, bg.b)
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
        vec2 shadowOffset = vec2(-PT_SHADOW_OFFSET_X, -PT_SHADOW_OFFSET_Y) * global.SourceSize.zw;
        vec2 shadowPos    = snappedUV + shadowOffset;
        float shadowDark;
        if (PT_SHADOW_BLUR > 0.001) {
            vec2  shadowDir = normalize(shadowOffset);
            float stepSize  = PT_SHADOW_BLUR_RADIUS * global.SourceSize.z;
            shadowDark = directionalShadowBlur(shadowPos, shadowDir, stepSize, PT_SHADOW_BLUR / 5.0);
        } else {
            shadowDark = 1.0 - getBrightness(texture(Original, shadowPos).rgb);
        }
        float shadowStrength = (shadowDark * shadowDark) * PT_SHADOW_OPACITY;
        bg = mix(bg, bg * 0.2, shadowStrength);
    }

    // Transparency blend with optional Bayer dithering.
    // Alpha driven by raw brightness. White pixels: mix(). Coloured: hue-preserving.
    float dither = (PT_DITHER > 0.5) ? getBayerDither(curvedUV) * PT_DITHER_STRENGTH : 0.0;
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
    result = applyHalation(result, snappedUV, willBeTransparent);

    // Post-blend effects.
    result = result * pixelBorderFactor(curvedUV);
    result = applyChromaShift(result, curvedUV);
    result = applyVignette(result, curvedUV);

    FragColor = vec4(result, lcd.a);
}
