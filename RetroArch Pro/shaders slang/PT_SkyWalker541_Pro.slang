#version 450
/*
╔══════════════════════════════════════════════════════════════════╗
║  PT SkyWalker541  v1.5.2                                         ║
║  by SkyWalker541  |  Written for RetroArch (Slang / Vulkan)      ║
╚══════════════════════════════════════════════════════════════════╝

  On original Game Boy, GBC, and GBA hardware, screen pixels that
  were fully off did not display as white. Those areas had no
  backlight driving them, so the physical backing material showed
  through instead: a grey-green translucency rather than solid white.
  Game developers of that era designed around this, using "white"
  areas as intentional transparent regions for backgrounds, windows,
  and UI overlays.

  On modern displays and emulators, those same pixels render as
  bright white, which was never the intended look. PT SkyWalker541
  restores the original appearance by detecting bright/white pixels
  and blending them toward a procedurally generated backing texture.

  Single-pass. White detection runs on "Original" — RetroArch's
  built-in semantic for the raw unprocessed input frame — giving
  clean pre-correction pixel values without a passthrough pass.

╔══════════════════════════════════════════════════════════════════╗
║  CHANGELOG                                                       ║
╚══════════════════════════════════════════════════════════════════╝

  v1.5.0 - Added PT_SYSTEM = 4 (GBA Original, threshold 0.75) for the
           original GBA's dim, creamy whites.

  v1.4.0 - Rebuilt as single-pass shader. Passthrough pass removed.
           RawFrame alias replaced with RetroArch built-in "Original"
           semantic, which provides the raw pre-correction input frame
           natively. Resolves "failed to load preset" on Android/
           Retroid devices. All shader logic, parameters, and visual
           output identical to v1.3.0.

  v1.3.0 - Ported to RetroArch Slang (.slang / .slangp).
           Works on Vulkan, glcore. Merged Aspect and Integer variants.
           White detection and transparency gating run against raw
           frame. Thresholds retuned for raw pixel values.

  v1.2.2 - Single-pass hash, reduced arithmetic cost.
  v1.2.1 - Period-authentic defaults (shadow 1.0/1.0/0.30, vig 0.08)
  v1.1.6 - Shadow blur removed: single texture tap.
  v1.1.0 - Split Aspect/Integer. Shadow formula rewritten.
  v1.0.0 - Initial release.
*/

// ╔══════════════════════════════════════════════════════════════╗
// ║  PARAMETERS                                                  ║
// ║  All #pragma parameter lines must appear before #pragma stage║
// ╚══════════════════════════════════════════════════════════════╝

// ┌──────────────────────────────────┐
// │  System Preset                   │
// └──────────────────────────────────┘
#pragma parameter PT_SYSTEM          "System (0=Manual, 1=GB, 2=GBC, 3=GBA SP, 4=GBA Orig)" 1.0 0.0 4.0 1.0
#pragma parameter PT_SENSITIVITY     "  Manual sensitivity threshold"          0.85 0.0 1.0 0.01

// ┌──────────────────────────────────┐
// │  Pixel Transparency              │
// └──────────────────────────────────┘
#pragma parameter PT_PIXEL_MODE      "Pixel mode (0=White, 1=Bright, 2=All)"  0.0 0.0 2.0 1.0
#pragma parameter PT_BASE_ALPHA      "  Base transparency amount"              0.20 0.0 1.0 0.01
#pragma parameter PT_WHITE_TRANSPARENCY "  White pixel min transparency"       0.20 0.0 1.0 0.01

// ┌──────────────────────────────────┐
// │  Shadow Blur                     │
// └──────────────────────────────────┘
#pragma parameter PT_SHADOW_BLUR     "Shadow blur (0=off)"   1.0 0.0 5.0 0.1

// ┌──────────────────────────────────┐
// │  Background                      │
// └──────────────────────────────────┘
#pragma parameter PT_PALETTE         "Background tint (0=Off, 1=Pocket, 2=Grey, 3=White)" 1.0 0.0 3.0 1.0
#pragma parameter PT_HALATION        "Halation glow (0=off)" 0.0 0.0 1.0 0.01

// ┌──────────────────────────────────┐
// │  Color Harshness Filter          │
// └──────────────────────────────────┘
#pragma parameter PT_DARK_FILTER_LEVEL "Dark color filter (0=off)"            0.0 0.0 100.0 1.0

// ┌──────────────────────────────────┐
// │  Pixel Border                    │
// └──────────────────────────────────┘
#pragma parameter PT_PIXEL_BORDER    "Pixel border (0=Off, 1=Subtle, 2=Med, 3=Strong)" 1.0 0.0 3.0 1.0

// ┌──────────────────────────────────┐
// │  Drop Shadow                     │
// └──────────────────────────────────┘
#pragma parameter PT_DITHER          "Dither (0=off, 1=on)"  1.0 0.0 1.0 1.0
#pragma parameter PT_SHADOW_OFFSET_X "Shadow X offset"       1.0 -10.0 10.0 0.5
#pragma parameter PT_SHADOW_OFFSET_Y "Shadow Y offset"       1.0 -10.0 10.0 0.5
#pragma parameter PT_SHADOW_OPACITY  "Shadow opacity (0=off)"                 0.30 0.0 1.0 0.01

// ┌──────────────────────────────────┐
// │  Post-Blend Effects              │
// └──────────────────────────────────┘
#pragma parameter PT_VIGNETTE        "Vignette strength (0=off)"              0.08 0.0 1.0 0.01

// ╔══════════════════════════════════════════════════════════════╗
// ║  UNIFORM BLOCKS                                              ║
// ║  All parameters in push_constant alongside builtins.         ║
// ║  Push constant: SourceSize+OriginalSize+OutputSize+FrameCount ║
// ║  + 15 param floats = 112 bytes. Within 128-byte minimum.     ║
// ╚══════════════════════════════════════════════════════════════╝

// ADVANCED DEFAULTS
#define PT_BRIGHTNESS_MODE_DEFAULT    0.0
#define PT_PALETTE_INTENSITY_DEFAULT  1.0
#define PT_GRAIN_INTENSITY_DEFAULT    0.065
#define PT_GRAIN_SCALE_DEFAULT        0.25
#define PT_SHADOW_BLUR_RADIUS_DEFAULT 1.0
#define PT_HALATION_RADIUS_DEFAULT    1.5
#define PT_HALATION_WARMTH_DEFAULT    0.3
#define PT_DITHER_STRENGTH_DEFAULT    0.05
#define PT_DITHER_MATRIX_DEFAULT      1.0

// ┌──────────────────────────────────────────────────────────────┐
// │  Subpixel Layout (hidden)                                    │
// │  Simulates the RGB stripe subpixel structure of the LCD.     │
// │  Modulates R/G/B channels by horizontal sub-pixel position.  │
// │  0.0 = off. Suggested: 0.2–0.5                               │
// │  Per-system: GB=0.0 (mono), GBC=0.25, GBA SP=0.30,          │
// │              GBA Orig=0.20                                   │
// └──────────────────────────────────────────────────────────────┘
#define PT_SUBPIXEL_STRENGTH_DEFAULT  0.0

// ┌──────────────────────────────────────────────────────────────┐
// │  Tight Bloom (hidden)                                        │
// │  Close-range pixel bleed between adjacent bright pixels.     │
// │  Separate from the wide halation glow — use both together    │
// │  for GBA SP. Off for GB, GBC, GBA Original (no backlight).   │
// │  0.0 = off. Suggested GBA SP: 0.10–0.20                      │
// │  Radius in source texels. Suggested: 0.5–1.0                 │
// └──────────────────────────────────────────────────────────────┘
#define PT_TIGHT_BLOOM_DEFAULT        0.0
#define PT_TIGHT_BLOOM_RADIUS_DEFAULT 0.6

// ┌──────────────────────────────────────────────────────────────┐
// │  Screen Warp (hidden)                                        │
// │  Subtle barrel distortion simulating the slight curvature    │
// │  of the physical screen glass under the bezel.               │
// │  Applies to all systems. 0.0 = off. Suggested: 0.02–0.06    │
// └──────────────────────────────────────────────────────────────┘
#define PT_WARP_STRENGTH_DEFAULT      0.0

// ┌──────────────────────────────────────────────────────────────┐
// │  Reflective Sheen (hidden)                                   │
// │  Subtle edge brightening simulating ambient light bouncing   │
// │  off the reflective LCD surface. Most authentic for GB, GBC, │
// │  and GBA Original. Off for GBA SP (front-lit, not reflective)│
// │  0.0 = off. Suggested: 0.03–0.08                             │
// └──────────────────────────────────────────────────────────────┘
#define PT_SHEEN_STRENGTH_DEFAULT     0.0

layout(push_constant) uniform Push {
    vec4  SourceSize;
    vec4  OriginalSize;
    vec4  OutputSize;
    uint  FrameCount;
    float PT_SYSTEM;
    float PT_SENSITIVITY;
    float PT_PIXEL_MODE;
    float PT_BASE_ALPHA;
    float PT_WHITE_TRANSPARENCY;
    float PT_SHADOW_BLUR;
    float PT_PALETTE;
    float PT_HALATION;
    float PT_DARK_FILTER_LEVEL;
    float PT_PIXEL_BORDER;
    float PT_DITHER;
    float PT_SHADOW_OFFSET_X;
    float PT_SHADOW_OFFSET_Y;
    float PT_SHADOW_OPACITY;
    float PT_VIGNETTE;
} params;

layout(std140, set = 0, binding = 0) uniform UBO {
    mat4 MVP;
} global;

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
#define PT_BRIGHTNESS_MODE    PT_BRIGHTNESS_MODE_DEFAULT
#define PT_PALETTE_INTENSITY  PT_PALETTE_INTENSITY_DEFAULT
#define PT_GRAIN_INTENSITY    PT_GRAIN_INTENSITY_DEFAULT
#define PT_GRAIN_SCALE        PT_GRAIN_SCALE_DEFAULT
#define PT_SHADOW_BLUR_RADIUS PT_SHADOW_BLUR_RADIUS_DEFAULT
#define PT_HALATION_RADIUS    PT_HALATION_RADIUS_DEFAULT
#define PT_HALATION_WARMTH    PT_HALATION_WARMTH_DEFAULT
#define PT_DITHER_STRENGTH    PT_DITHER_STRENGTH_DEFAULT
#define PT_DITHER_MATRIX      PT_DITHER_MATRIX_DEFAULT
#define PT_SUBPIXEL_STRENGTH  PT_SUBPIXEL_STRENGTH_DEFAULT
#define PT_TIGHT_BLOOM        PT_TIGHT_BLOOM_DEFAULT
#define PT_TIGHT_BLOOM_RADIUS PT_TIGHT_BLOOM_RADIUS_DEFAULT
#define PT_WARP_STRENGTH      PT_WARP_STRENGTH_DEFAULT
#define PT_SHEEN_STRENGTH     PT_SHEEN_STRENGTH_DEFAULT

// ┌──────────────────────────────────┐
// │  Chromatic Shift (hidden)        │
// │  Radial RGB channel separation.  │
// │  Not exposed in the shader menu. │
// │  Edit this value to adjust.      │
// │  0.0 = off. Suggested: 0.3–0.8   │
// └──────────────────────────────────┘
#define PT_CHROMA_STRENGTH 0.0


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
    if (params.PT_SYSTEM < 0.5) return params.PT_SENSITIVITY;
    if (params.PT_SYSTEM < 1.5) return 0.90;
    if (params.PT_SYSTEM < 2.5) return 0.85;
    if (params.PT_SYSTEM < 3.5) return 0.80;
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
    if (params.PT_PIXEL_BORDER < 0.5) return 1.0;

    vec2 imgPixelCoord = fract(coord * params.SourceSize.xy);
    vec2 angle         = 2.0 * PI * (imgPixelCoord - 0.25);

    float wfactor, strength;
    if (params.PT_PIXEL_BORDER < 1.5) {
        wfactor  = 1.0 + (BORDER_WIDTH_FACTOR_MAX - 0.80 * BORDER_WIDTH_FACTOR_MAX);
        strength = 0.40;
    } else if (params.PT_PIXEL_BORDER < 2.5) {
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
    if (params.PT_HALATION < 0.001 || isTransparent < 0.5) return color;

    float hStep = PT_HALATION_RADIUS * params.SourceSize.z;

    float glow = 0.0;
    glow += getBrightness(texture(Source, coord + vec2( hStep,  0.0)).rgb);
    glow += getBrightness(texture(Source, coord + vec2(-hStep,  0.0)).rgb);
    glow += getBrightness(texture(Source, coord + vec2( 0.0,  hStep)).rgb);
    glow += getBrightness(texture(Source, coord + vec2( 0.0, -hStep)).rgb);
    glow += getBrightness(texture(Source, coord + vec2( hStep,  hStep)).rgb) * 0.5;
    glow += getBrightness(texture(Source, coord + vec2(-hStep,  hStep)).rgb) * 0.5;
    glow += getBrightness(texture(Source, coord + vec2( hStep, -hStep)).rgb) * 0.5;
    glow += getBrightness(texture(Source, coord + vec2(-hStep, -hStep)).rgb) * 0.5;
    glow /= 6.0;

    // Warm amber = GBA SP front-light colour temperature
    vec3 glowColor = mix(vec3(1.0, 1.0, 1.0), vec3(1.0, 0.92, 0.75), PT_HALATION_WARMTH);
    return clamp(color + glowColor * glow * params.PT_HALATION, 0.0, 1.0);
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
    // Pure float — no ivec2/int types, compatible with mobile Vulkan drivers.
    float fx = mod(floor(coord.x * params.SourceSize.x), 8.0);
    float fy = mod(floor(coord.y * params.SourceSize.y), 8.0);

    if (PT_DITHER_MATRIX < 0.5) {
        // 2x2 Bayer
        float idx = mod(fy, 2.0) * 2.0 + mod(fx, 2.0);
        float v;
        if      (idx < 0.5) v = 0.0;
        else if (idx < 1.5) v = 2.0;
        else if (idx < 2.5) v = 3.0;
        else                v = 1.0;
        return v / 4.0 - 0.5;

    } else if (PT_DITHER_MATRIX < 1.5) {
        // 4x4 Bayer
        float idx = mod(fy, 4.0) * 4.0 + mod(fx, 4.0);
        float v;
        if      (idx <  0.5) v =  0.0; else if (idx <  1.5) v =  8.0;
        else if (idx <  2.5) v =  2.0; else if (idx <  3.5) v = 10.0;
        else if (idx <  4.5) v = 12.0; else if (idx <  5.5) v =  4.0;
        else if (idx <  6.5) v = 14.0; else if (idx <  7.5) v =  6.0;
        else if (idx <  8.5) v =  3.0; else if (idx <  9.5) v = 11.0;
        else if (idx < 10.5) v =  1.0; else if (idx < 11.5) v =  9.0;
        else if (idx < 12.5) v = 15.0; else if (idx < 13.5) v =  7.0;
        else if (idx < 14.5) v = 13.0; else                 v =  5.0;
        return v / 16.0 - 0.5;

    } else {
        // 8x8 Bayer
        float idx = mod(fy, 8.0) * 8.0 + mod(fx, 8.0);
        float v;
        if      (idx <  0.5) v =  0.0; else if (idx <  1.5) v = 32.0;
        else if (idx < 2.5) v =  8.0; else if (idx < 3.5) v = 40.0;
        else if (idx < 4.5) v =  2.0; else if (idx < 5.5) v = 34.0;
        else if (idx < 6.5) v = 10.0; else if (idx < 7.5) v = 42.0;
        else if (idx < 8.5) v = 48.0; else if (idx < 9.5) v = 16.0;
        else if (idx < 10.5) v = 56.0; else if (idx < 11.5) v = 24.0;
        else if (idx < 12.5) v = 50.0; else if (idx < 13.5) v = 18.0;
        else if (idx < 14.5) v = 58.0; else if (idx < 15.5) v = 26.0;
        else if (idx < 16.5) v = 12.0; else if (idx < 17.5) v = 44.0;
        else if (idx < 18.5) v =  4.0; else if (idx < 19.5) v = 36.0;
        else if (idx < 20.5) v = 14.0; else if (idx < 21.5) v = 46.0;
        else if (idx < 22.5) v =  6.0; else if (idx < 23.5) v = 38.0;
        else if (idx < 24.5) v = 60.0; else if (idx < 25.5) v = 28.0;
        else if (idx < 26.5) v = 52.0; else if (idx < 27.5) v = 20.0;
        else if (idx < 28.5) v = 62.0; else if (idx < 29.5) v = 30.0;
        else if (idx < 30.5) v = 54.0; else if (idx < 31.5) v = 22.0;
        else if (idx < 32.5) v =  3.0; else if (idx < 33.5) v = 35.0;
        else if (idx < 34.5) v = 11.0; else if (idx < 35.5) v = 43.0;
        else if (idx < 36.5) v =  1.0; else if (idx < 37.5) v = 33.0;
        else if (idx < 38.5) v =  9.0; else if (idx < 39.5) v = 41.0;
        else if (idx < 40.5) v = 51.0; else if (idx < 41.5) v = 19.0;
        else if (idx < 42.5) v = 59.0; else if (idx < 43.5) v = 27.0;
        else if (idx < 44.5) v = 49.0; else if (idx < 45.5) v = 17.0;
        else if (idx < 46.5) v = 57.0; else if (idx < 47.5) v = 25.0;
        else if (idx < 48.5) v = 15.0; else if (idx < 49.5) v = 47.0;
        else if (idx < 50.5) v =  7.0; else if (idx < 51.5) v = 39.0;
        else if (idx < 52.5) v = 13.0; else if (idx < 53.5) v = 45.0;
        else if (idx < 54.5) v =  5.0; else if (idx < 55.5) v = 37.0;
        else if (idx < 56.5) v = 63.0; else if (idx < 57.5) v = 31.0;
        else if (idx < 58.5) v = 55.0; else if (idx < 59.5) v = 23.0;
        else if (idx < 60.5) v = 61.0; else if (idx < 61.5) v = 29.0;
        else if (idx < 62.5) v = 53.0; else                v = 21.0;
        return v / 64.0 - 0.5;
    }
}



// ┌──────────────────────────────────┐
// │  Post-Blend Effects              │
// └──────────────────────────────────┘


// Vignette — pure math, zero extra taps.
vec3 applyVignette(vec3 color, vec2 coord)
{
    if (params.PT_VIGNETTE < 0.001) return color;
    vec2  uv       = coord * 2.0 - 1.0;
    float dist     = dot(uv, uv);
    float vignette = 1.0 - dist * params.PT_VIGNETTE;
    return color * clamp(vignette, 0.0, 1.0);
}

// ┌──────────────────────────────────┐
// │  Chromatic Shift                 │
// └──────────────────────────────────┘

// Radial RGB channel separation from screen centre.
// R shifts outward, B shifts inward by the same amount.
// Strength is in source texels. Only samples two extra taps.
// Skipped entirely when PT_CHROMA_STRENGTH is 0.
vec3 applyChroma(vec3 color, vec2 coord)
{
    if (PT_CHROMA_STRENGTH < 0.001) return color;
    vec2 toCenter = coord - vec2(0.5);
    vec2 offset   = toCenter * PT_CHROMA_STRENGTH * params.SourceSize.zw;
    float r = texture(Source, coord + offset).r;
    float b = texture(Source, coord - offset).b;
    return vec3(r, color.g, b);
}

// ┌──────────────────────────────────┐
// │  Subpixel Layout                 │
// └──────────────────────────────────┘

// Simulates the RGB stripe subpixel structure of the original LCD panels.
// Modulates R, G, B channels independently based on horizontal sub-pixel
// position within each logical pixel. Strength 0 = off, no cost.
vec3 applySubpixel(vec3 color, vec2 coord)
{
    if (PT_SUBPIXEL_STRENGTH < 0.001) return color;
    float subX  = fract(coord.x * params.SourceSize.x * 3.0);
    float rMask = smoothstep(0.0, 0.33, subX) * (1.0 - smoothstep(0.33, 0.66, subX));
    float gMask = smoothstep(0.33, 0.66, subX) * (1.0 - smoothstep(0.66, 1.0, subX));
    float bMask = 1.0 - smoothstep(0.66, 1.0, subX) + smoothstep(0.0, 0.0, subX) * (1.0 - smoothstep(0.0, 0.33, subX));
    vec3 mask   = clamp(vec3(rMask, gMask, bMask) * 3.0, 0.0, 1.5);
    return clamp(mix(color, color * mask, PT_SUBPIXEL_STRENGTH), 0.0, 1.0);
}

// ┌──────────────────────────────────┐
// │  Tight Bloom                     │
// └──────────────────────────────────┘

// Close-range pixel bleed between adjacent bright pixels.
// Simulates the tight local glow of the GBA SP front-light diffuser.
// Separate from the wide halation — use both together for full GBA SP look.
// Only physically meaningful for backlit screens. Off by default.
vec3 applyTightBloom(vec3 color, vec2 coord)
{
    if (PT_TIGHT_BLOOM < 0.001) return color;
    float step = PT_TIGHT_BLOOM_RADIUS * params.SourceSize.z;
    vec3 bloom = vec3(0.0);
    bloom += texture(Source, coord + vec2( step, 0.0)).rgb;
    bloom += texture(Source, coord + vec2(-step, 0.0)).rgb;
    bloom += texture(Source, coord + vec2(0.0,  step)).rgb;
    bloom += texture(Source, coord + vec2(0.0, -step)).rgb;
    bloom *= 0.25;
    float bloomLuma = perceptualBrightness(bloom);
    return clamp(color + bloom * bloomLuma * PT_TIGHT_BLOOM, 0.0, 1.0);
}

// ┌──────────────────────────────────┐
// │  Screen Warp                     │
// └──────────────────────────────────┘

// Returns warped UV coordinates simulating slight barrel distortion
// from the physical curvature of the screen glass under the bezel.
// Applied before sampling in main() — warp affects the whole image.
vec2 warpCoord(vec2 coord)
{
    if (PT_WARP_STRENGTH < 0.001) return coord;
    vec2 uv     = coord * 2.0 - 1.0;
    float dist  = dot(uv, uv);
    uv          = uv * (1.0 + dist * PT_WARP_STRENGTH);
    return uv * 0.5 + 0.5;
}

// ┌──────────────────────────────────┐
// │  Reflective Sheen                │
// └──────────────────────────────────┘

// Subtle edge brightening simulating ambient light bouncing off the
// reflective LCD surface of GB, GBC, and GBA Original screens.
// Inverse radial gradient — brightens toward the edges, not the centre.
// Not physically meaningful for backlit screens (GBA SP). Off by default.
vec3 applySheen(vec3 color, vec2 coord)
{
    if (PT_SHEEN_STRENGTH < 0.001) return color;
    vec2  uv     = coord * 2.0 - 1.0;
    float dist   = dot(uv, uv);
    float sheen  = dist * PT_SHEEN_STRENGTH;
    return clamp(color + sheen, 0.0, 1.0);
}

// ╔══════════════════════════════════════════════════════════════╗
// ║  MAIN                                                        ║
// ╚══════════════════════════════════════════════════════════════╝
void main()
{
    // Screen warp — applied first, remaps UV for all subsequent samples.
    vec2 warpedUV = warpCoord(vTexCoord);

    // Snap to texel centre to eliminate bilinear filtering artifacts.
    vec2 imgPixelCoord = warpedUV * params.SourceSize.xy;
    vec2 snappedUV     = (floor(imgPixelCoord) + vec2(0.5)) * params.SourceSize.zw;


    // Sample source textures.
    // lcd      — colour-corrected frame (Source). Used for display and shadows.
    // rawPixel — raw pre-correction frame (Original). Used for white detection.
    vec4 lcd = texture(Source, snappedUV);
    vec3 pixel    = lcd.rgb;
    vec3 rawPixel = texture(Original, snappedUV).rgb;

    // Color harshness filter — applied to Source before any blending.
    if (params.PT_DARK_FILTER_LEVEL > 0.5) {
        pixel   = applyDarkFilter(pixel, params.PT_DARK_FILTER_LEVEL);
        lcd.rgb = pixel;
    }

    // White detection — on rawPixel (Original, pre-correction).
    // whiteness is 0..1 soft gradient. rawBrightness drives alpha.
    float threshold     = resolveThreshold();
    float whiteness     = whitePixelStrength(rawPixel, threshold);
    float rawBrightness = perceptualBrightness(rawPixel);

    // Build procedural backing texture.
    vec3 bg = proceduralBackground(snappedUV);
    if (params.PT_PALETTE > 0.5) {
        vec3 tint;
        if      (params.PT_PALETTE < 1.5) tint = vec3(0.651, 0.675, 0.518); // Pocket grey
        else if (params.PT_PALETTE < 2.5) tint = vec3(0.737, 0.737, 0.737); // Cool grey
        else if (params.PT_PALETTE < 3.5) tint = vec3(1.0,   1.0,   1.0  ); // White (GBA SP)
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
    if      (params.PT_PIXEL_MODE < 0.5) willBeTransparent = step(0.001, whiteness);
    else if (params.PT_PIXEL_MODE < 1.5) willBeTransparent = step(threshold * 0.9, rawBrightness);
    else                          willBeTransparent = 1.0;

    // Drop shadow with optional directional gaussian blur.
    // Gated on shadow source being non-white rather than current pixel being transparent,
    // so shadows appear at all sprite and tile edges regardless of local transparency.
    if (params.PT_SHADOW_OPACITY > 0.001) {
        vec2  shadowOffset   = vec2(-params.PT_SHADOW_OFFSET_X, -params.PT_SHADOW_OFFSET_Y) * params.SourceSize.zw;
        vec2  shadowPos      = snappedUV + shadowOffset;
        // Skip shadow if sample position is outside valid texture bounds —
        // out-of-range UVs clamp to edge and produce false dark bars.
        if (all(greaterThanEqual(shadowPos, vec2(0.0))) && all(lessThanEqual(shadowPos, vec2(1.0)))) {
            vec3  shadowSrc      = texture(Original, shadowPos).rgb;
            float shadowSrcWhite = whitePixelStrength(shadowSrc, threshold);
            if (shadowSrcWhite < 0.5) {
                float shadowDark;
                if (params.PT_SHADOW_BLUR > 0.001) {
                    vec2  shadowDir = normalize(shadowOffset);
                    float stepSize  = PT_SHADOW_BLUR_RADIUS * params.SourceSize.z;
                    shadowDark = directionalShadowBlur(shadowPos, shadowDir, stepSize, params.PT_SHADOW_BLUR / 5.0);
                } else {
                    shadowDark = 1.0 - getBrightness(shadowSrc);
                }
                float shadowStrength = (shadowDark * shadowDark) * params.PT_SHADOW_OPACITY;
                bg = mix(bg, bg * 0.2, shadowStrength);
            }
        }
    }

    // Transparency blend with optional Bayer dithering.
    // Alpha driven by raw brightness. White pixels: mix(). Coloured: hue-preserving.
    float dither = (params.PT_DITHER > 0.5) ? getBayerDither(snappedUV) * PT_DITHER_STRENGTH : 0.0;
    vec3 result = pixel;

    if (params.PT_PIXEL_MODE < 0.5) {
        if (whiteness > 0.001) {
            float distAbove = clamp((rawBrightness - threshold) / (1.0 - threshold + 0.001), 0.0, 1.0);
            float alpha     = clamp(params.PT_BASE_ALPHA + distAbove * (1.0 - params.PT_BASE_ALPHA) * whiteness + dither, 0.0, 1.0);
            alpha           = max(alpha, params.PT_WHITE_TRANSPARENCY * whiteness);
            result          = whiteBlend(pixel, bg, alpha);
        }
    } else if (params.PT_PIXEL_MODE < 1.5) {
        float alpha = clamp(params.PT_BASE_ALPHA * rawBrightness * 2.4 + dither, 0.0, 1.0);
        if (whiteness > 0.001) alpha = max(alpha, params.PT_WHITE_TRANSPARENCY * whiteness);
        result = huePreservingBlend(pixel, bg, alpha);
    } else {
        float distAbove = clamp((rawBrightness - threshold) / (1.0 - threshold + 0.001), 0.0, 1.0);
        float alpha     = clamp(params.PT_BASE_ALPHA + distAbove * (1.0 - params.PT_BASE_ALPHA) * 0.5 + dither, 0.0, 1.0);
        if (whiteness > 0.001) alpha = max(alpha, params.PT_WHITE_TRANSPARENCY * whiteness);
        result = huePreservingBlend(pixel, bg, alpha);
    }

    // Halation — after blend, only on transparent pixels.
    result = applyHalation(result, snappedUV, willBeTransparent);

    // Post-blend effects.
    result = result * pixelBorderFactor(warpedUV);
    result = applySubpixel(result, warpedUV);
    result = applyTightBloom(result, snappedUV);
    result = applyVignette(result, warpedUV);
    result = applySheen(result, warpedUV);
    result = applyChroma(result, warpedUV);

    FragColor = vec4(result, lcd.a);
}
