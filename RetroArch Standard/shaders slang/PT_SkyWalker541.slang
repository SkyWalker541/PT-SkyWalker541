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
// │  Brightness                      │
// └──────────────────────────────────┘
#pragma parameter PT_BRIGHTNESS_MODE "Brightness mode (0=Simple, 1=Percept.)" 0.0 0.0 1.0 1.0

// ┌──────────────────────────────────┐
// │  Background                      │
// └──────────────────────────────────┘
#pragma parameter PT_PALETTE         "Background tint (0=Off, 1=Pocket, 2=Grey, 3=White)" 1.0 0.0 3.0 1.0
#pragma parameter PT_PALETTE_INTENSITY "  Tint intensity"                      1.0 0.0 2.0 0.05

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
#pragma parameter PT_SHADOW_OFFSET_X "Shadow X offset"                        1.0 -10.0 10.0 0.5
#pragma parameter PT_SHADOW_OFFSET_Y "Shadow Y offset"                        1.0 -10.0 10.0 0.5
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
    float PT_BRIGHTNESS_MODE;
    float PT_PALETTE;
    float PT_PALETTE_INTENSITY;
    float PT_DARK_FILTER_LEVEL;
    float PT_PIXEL_BORDER;
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
    return (params.PT_BRIGHTNESS_MODE < 0.5) ? simpleBrightness(c)
                                             : perceptualBrightness(c);
}

// ┌──────────────────────────────────┐
// │  White Detection                 │
// └──────────────────────────────────┘

// Resolve system preset → detection threshold.
// Thresholds tuned for raw pre-correction pixel values (Original semantic).
//   GB:          0.90 — no backlight, aggressive
//   GBC:         0.85 — no backlight, moderate
//   GBA SP:      0.80 — front-lit, conservative
//   GBA Original: 0.75 — no backlight, dim/creamy whites, most aggressive
//   Manual:      PT_SENSITIVITY directly
float resolveThreshold()
{
    if (params.PT_SYSTEM < 0.5) return params.PT_SENSITIVITY;
    if (params.PT_SYSTEM < 1.5) return 0.90;
    if (params.PT_SYSTEM < 2.5) return 0.85;
    if (params.PT_SYSTEM < 3.5) return 0.80;
    return 0.75;
}

// Dual-channel ratio method: pixel must be both bright AND neutral.
// Runs on rawPixel (Original semantic) — no correction compensation needed.
float isWhitePixel(vec3 pixel, float threshold)
{
    float brightness   = perceptualBrightness(pixel);
    float maxChannel   = max(max(pixel.r, pixel.g), pixel.b);
    float minChannel   = min(min(pixel.r, pixel.g), pixel.b);
    float channelRange = maxChannel - minChannel;
    return (brightness > threshold && channelRange < 0.15) ? 1.0 : 0.0;
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
    vec2  p     = uv * 256.0;
    float grain = noiseHash(p) * 0.5 + noiseHash(p * 2.0) * 0.25;
    float offset = (grain - 0.375) * 0.065;
    return vec3(0.478 + offset);
}

// ┌──────────────────────────────────┐
// │  Blend                           │
// └──────────────────────────────────┘

// Hue-preserving blend: blends luminance only, rescales RGB by
// luminance ratio so hue and saturation are preserved.
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
vec3 applyChroma(vec3 color, vec2 coord, sampler2D src, vec4 srcSize)
{
    if (PT_CHROMA_STRENGTH < 0.001) return color;
    vec2 toCenter = coord - vec2(0.5);
    vec2 offset   = toCenter * PT_CHROMA_STRENGTH * srcSize.zw;
    float r = texture(src, coord + offset).r;
    float b = texture(src, coord - offset).b;
    return vec3(r, color.g, b);
}

// ╔══════════════════════════════════════════════════════════════╗
// ║  MAIN                                                        ║
// ╚══════════════════════════════════════════════════════════════╝
void main()
{
    // Snap to texel centre to avoid bilinear filtering artifacts.
    vec2 imgPixelCoord = vTexCoord * params.SourceSize.xy;
    vec2 snappedUV     = (floor(imgPixelCoord) + vec2(0.5)) * params.SourceSize.zw;

    // Sample colour-corrected frame (Source) and raw input frame (Original).
    vec4 lcd      = texture(Source,   snappedUV);
    vec3 pixel    = lcd.rgb;
    vec3 rawPixel = texture(Original, snappedUV).rgb;

    // Color harshness filter — on Source (colour-corrected frame).
    if (params.PT_DARK_FILTER_LEVEL > 0.5) {
        pixel   = applyDarkFilter(pixel, params.PT_DARK_FILTER_LEVEL);
        lcd.rgb = pixel;
    }

    // White detection — on rawPixel (Original semantic, pre-correction).
    float threshold = resolveThreshold();
    float isWhite   = isWhitePixel(rawPixel, threshold);

    // Build procedural backing texture with optional palette tint.
    vec3 bg = proceduralBackground(vTexCoord);

    if (params.PT_PALETTE > 0.5) {
        vec3 tint;
        if (params.PT_PALETTE < 1.5) {
            tint = vec3(0.651, 0.675, 0.518); // Pocket: warm green-grey
        } else if (params.PT_PALETTE < 2.5) {
            tint = vec3(0.737, 0.737, 0.737); // Grey
        } else {
            tint = vec3(1.0, 1.0, 1.0);       // White
        }
        // Overlay blend: grain texture onto tint colour.
        // Dark grain pulls the tint down, bright grain lifts it --
        // matching the physical behaviour of a textured backing material.
        vec3 tinted = clamp(mix(
            2.0 * tint * bg,
            1.0 - 2.0 * (1.0 - tint) * (1.0 - bg),
            step(0.5, bg)
        ), 0.0, 1.0);
        bg = mix(bg, tinted, params.PT_PALETTE_INTENSITY);
    }

    // Transparency gate.
    float willBeTransparent;
    if (params.PT_PIXEL_MODE < 0.5) {
        willBeTransparent = isWhite;
    } else if (params.PT_PIXEL_MODE < 1.5) {
        willBeTransparent = step(threshold * 0.9, getBrightness(rawPixel));
    } else {
        willBeTransparent = 1.0;
    }

    // Drop shadow — cast by every solid (non-white) pixel onto the backing behind it.
    // Gated on shadow source being non-white rather than current pixel being transparent,
    // so shadows appear at all sprite and tile edges regardless of local transparency.
    if (params.PT_SHADOW_OPACITY > 0.001) {
        vec2  shadowPos    = snappedUV + vec2(-params.PT_SHADOW_OFFSET_X, -params.PT_SHADOW_OFFSET_Y)
                             * params.SourceSize.zw;
        // Skip shadow if sample position is outside valid texture bounds —
        // out-of-range UVs clamp to edge and produce false dark bars.
        if (all(greaterThanEqual(shadowPos, vec2(0.0))) && all(lessThanEqual(shadowPos, vec2(1.0)))) {
            vec3  shadowSrc      = texture(Original, shadowPos).rgb;
            float shadowSrcWhite = isWhitePixel(shadowSrc, threshold);
            if (shadowSrcWhite < 0.5) {
                float shadowDark     = 1.0 - getBrightness(shadowSrc);
                float shadowStrength = (shadowDark * shadowDark) * params.PT_SHADOW_OPACITY;
                bg = mix(bg, bg * 0.2, shadowStrength);
            }
        }
    }

    // Transparency blend.
    vec3 result = pixel;

    if (params.PT_PIXEL_MODE < 0.5) {
        // White only
        if (isWhite > 0.5) {
            float intensity = getBrightness(pixel);
            float alpha     = clamp((intensity / 3.0) + params.PT_BASE_ALPHA, 0.0, 1.0);
            alpha           = max(alpha, params.PT_WHITE_TRANSPARENCY);
            result          = huePreservingBlend(pixel, bg, alpha);
        }
    } else if (params.PT_PIXEL_MODE < 1.5) {
        // Bright
        float intensity = getBrightness(pixel);
        float alpha     = clamp(params.PT_BASE_ALPHA * intensity * 2.4, 0.0, 1.0);
        if (isWhite > 0.5) alpha = max(alpha, params.PT_WHITE_TRANSPARENCY);
        result = huePreservingBlend(pixel, bg, alpha);
    } else {
        // All
        float intensity = getBrightness(pixel);
        float alpha     = clamp((intensity / 3.0) + params.PT_BASE_ALPHA, 0.0, 1.0);
        if (isWhite > 0.5) alpha = max(alpha, params.PT_WHITE_TRANSPARENCY);
        result = huePreservingBlend(pixel, bg, alpha);
    }

    // Post-blend effects.
    result = result * pixelBorderFactor(vTexCoord);
    result = applyVignette(result, vTexCoord);
    result = applyChroma(result, vTexCoord, Source, params.SourceSize);

    FragColor = vec4(result, lcd.a);
}
