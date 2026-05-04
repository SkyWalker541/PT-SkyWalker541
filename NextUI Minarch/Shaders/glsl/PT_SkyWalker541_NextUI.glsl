/*
  PT SkyWalker541 NextUI  v1.7.1
  by SkyWalker541  |  NextUI / minarch GLSL

  Pixel transparency shader inspired by mattakins' pixel transparency work.
  Restores GB/GBC/GBA backing material appearance on white/bright pixels.

  Pixel Effect LCD Dot mode inspired by Themaister's dot shader (public domain).

  NextUI variant — white detection runs against the post-processed frame.
  Thresholds are pre-compensated for NextUI's post-processing pipeline.
  OrigTexture is not available in NextUI — black level threshold uses the
  post-processed frame brightness. When OrigTexture support is added to
  NextUI this shader will be updated.

  v1.7.1 — replaced PT_PIXEL_BORDER with unified Pixel Effect system:
            Grid and LCD Dot modes. All LCD Dot parameters strictly gated
            so they cost nothing when Grid or Off is selected.
*/

// ── PARAMETERS ───────────────────────────────────────────────────────────────

// System
#pragma parameter PT_SYSTEM            "System (0=Manual, 1=GB, 2=GBC, 3=GBA SP, 4=GBA Orig)" 1.0 0.0 4.0 1.0
#pragma parameter PT_SENSITIVITY       "  Manual sensitivity threshold"          0.52 0.35 0.75 0.01

// Pixel Transparency
#pragma parameter PT_PIXEL_MODE        "Pixel mode (0=White, 1=Bright, 2=All)"  0.0 0.0 2.0 1.0
#pragma parameter PT_BASE_ALPHA        "  Base transparency amount"              0.20 0.0 1.0 0.01
#pragma parameter PT_WHITE_TRANSPARENCY "  White pixel min transparency"         0.20 0.0 1.0 0.01

// Background
#pragma parameter PT_PALETTE           "Background tint (0=Off, 1=Pocket, 2=Grey, 3=White)" 1.0 0.0 3.0 1.0
#pragma parameter PT_PALETTE_INTENSITY "  Tint intensity"                        1.0 0.0 2.0 0.05

// Color Filter
#pragma parameter PT_DARK_FILTER_LEVEL "Dark color filter (0=off)"              0.0 0.0 100.0 1.0

// Pixel Effect
#pragma parameter PT_GRID_MODE         "Pixel Effect (0=Off, 1=Grid, 2=LCD Dot)" 1.0 0.0 2.0 1.0

// [Grid] parameters — only active when PT_GRID_MODE = 1
#pragma parameter PT_GRID_STRENGTH     "  [Grid]     Grid strength"              0.08 0.0 1.0 0.01

// [LCD Dot] parameters — only active when PT_GRID_MODE = 2
#pragma parameter PT_DOT_SIZE          "  [LCD Dot]  Dot size"                   0.50 0.1 0.9 0.01
#pragma parameter PT_DOT_SHARPNESS     "  [LCD Dot]  Dot sharpness"              0.0  0.0 5.0 0.1
#pragma parameter PT_DOT_BRIGHTNESS    "  [LCD Dot]  Dot brightness compensation" 0.0 0.0 1.0 0.01
#pragma parameter PT_BLACK_THRESHOLD   "  [LCD Dot]  Black level threshold"      0.15 0.0 1.0 0.01

// Drop Shadow
#pragma parameter PT_SHADOW_OFFSET     "Shadow offset"                           1.0 -10.0 10.0 0.5
#pragma parameter PT_SHADOW_OPACITY    "Shadow opacity (0=off)"                 0.30 0.0 1.0 0.01

// Bezel Shadow
#pragma parameter PT_BEZEL             "Bezel shadow strength (0=off)"          0.40 0.0 1.0 0.01

// ── VERTEX SHADER ────────────────────────────────────────────────────────────
#if defined(VERTEX)

#if __VERSION__ >= 130
#define COMPAT_VARYING    out
#define COMPAT_ATTRIBUTE  in
#define COMPAT_TEXTURE    texture
#else
#define COMPAT_VARYING    varying
#define COMPAT_ATTRIBUTE  attribute
#define COMPAT_TEXTURE    texture2D
#endif

#ifdef GL_ES
#define COMPAT_PRECISION mediump
#else
#define COMPAT_PRECISION
#endif

COMPAT_ATTRIBUTE vec4 VertexCoord;
COMPAT_ATTRIBUTE vec4 TexCoord;
COMPAT_VARYING   vec2 TEX0;
COMPAT_VARYING   vec2 texel;

uniform mat4 MVPMatrix;
uniform COMPAT_PRECISION vec2 TextureSize;
uniform COMPAT_PRECISION vec2 InputSize;

void main()
{
    gl_Position = MVPMatrix * VertexCoord;
    TEX0        = TexCoord.xy;
    texel       = 1.0 / TextureSize;
}

// ── FRAGMENT SHADER ──────────────────────────────────────────────────────────
#elif defined(FRAGMENT)

#if __VERSION__ >= 130
#define COMPAT_VARYING  in
#define COMPAT_TEXTURE  texture
out vec4 FragColor;
#else
#define COMPAT_VARYING  varying
#define FragColor       gl_FragColor
#define COMPAT_TEXTURE  texture2D
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

uniform COMPAT_PRECISION vec2 TextureSize;
uniform COMPAT_PRECISION vec2 InputSize;
uniform sampler2D Texture;

COMPAT_VARYING vec2 TEX0;
COMPAT_VARYING vec2 texel;

// ── PARAMETER UNIFORMS / FALLBACKS ───────────────────────────────────────────
#ifdef PARAMETER_UNIFORM
uniform COMPAT_PRECISION float PT_SYSTEM;
uniform COMPAT_PRECISION float PT_SENSITIVITY;
uniform COMPAT_PRECISION float PT_PIXEL_MODE;
uniform COMPAT_PRECISION float PT_BASE_ALPHA;
uniform COMPAT_PRECISION float PT_WHITE_TRANSPARENCY;
uniform COMPAT_PRECISION float PT_PALETTE;
uniform COMPAT_PRECISION float PT_PALETTE_INTENSITY;
uniform COMPAT_PRECISION float PT_DARK_FILTER_LEVEL;
uniform COMPAT_PRECISION float PT_GRID_MODE;
uniform COMPAT_PRECISION float PT_GRID_STRENGTH;
uniform COMPAT_PRECISION float PT_DOT_SIZE;
uniform COMPAT_PRECISION float PT_DOT_SHARPNESS;
uniform COMPAT_PRECISION float PT_DOT_BRIGHTNESS;
uniform COMPAT_PRECISION float PT_BLACK_THRESHOLD;
uniform COMPAT_PRECISION float PT_SHADOW_OFFSET;
uniform COMPAT_PRECISION float PT_SHADOW_OPACITY;
uniform COMPAT_PRECISION float PT_BEZEL;
#else
#define PT_SYSTEM             1.0
#define PT_SENSITIVITY        0.52
#define PT_PIXEL_MODE         0.0
#define PT_BASE_ALPHA         0.20
#define PT_WHITE_TRANSPARENCY 0.20
#define PT_PALETTE            1.0
#define PT_PALETTE_INTENSITY  1.0
#define PT_DARK_FILTER_LEVEL  0.0
#define PT_GRID_MODE          1.0
#define PT_GRID_STRENGTH      0.08
#define PT_DOT_SIZE           0.50
#define PT_DOT_SHARPNESS      0.0
#define PT_DOT_BRIGHTNESS     0.0
#define PT_BLACK_THRESHOLD    0.15
#define PT_SHADOW_OFFSET      1.0
#define PT_SHADOW_OPACITY     0.30
#define PT_BEZEL              0.40
#endif

// ── CONSTANTS ────────────────────────────────────────────────────────────────
#define LUMA_R 0.2126
#define LUMA_G 0.7152
#define LUMA_B 0.0722
#define PI     3.14159265

// ── HELPER FUNCTIONS ─────────────────────────────────────────────────────────

// Perceptual brightness (ITU-R BT.709).
float getBrightness(vec3 c)
{
    return LUMA_R * c.r + LUMA_G * c.g + LUMA_B * c.b;
}

// Threshold from system preset.
// Thresholds pre-compensated for NextUI post-processing pipeline.
float resolveThreshold()
{
    if (PT_SYSTEM < 0.5) return PT_SENSITIVITY;
    if (PT_SYSTEM < 1.5) return 0.62; // GB
    if (PT_SYSTEM < 2.5) return 0.68; // GBC
    if (PT_SYSTEM < 3.5) return 0.45; // GBA SP
    return 0.42;                       // GBA Orig
}

// White detection — pixel must be bright with all channels near-white.
float isWhitePixel(vec3 pixel, float brightness, float threshold)
{
    float minCh = min(pixel.r, min(pixel.g, pixel.b));
    if (brightness > threshold && minCh > threshold * 0.9) return 1.0;
    return 0.0;
}

// Dark color filter.
vec3 applyDarkFilter(vec3 c, float level)
{
    float strength = level * 0.01;
    float luma     = getBrightness(c);
    float factor   = max(1.0 - strength * luma, 0.0);
    return c * factor;
}

// Single-octave hash noise.
float noiseHash(vec2 p)
{
    vec3 p3 = fract(vec3(p.xyx) * 0.1031);
    p3 = p3 + vec3(dot(p3, p3.yzx + 33.33));
    return fract((p3.x + p3.y) * p3.z);
}

// Procedural backing texture.
vec3 proceduralBackground(vec2 uv)
{
    float grain  = noiseHash(uv * 128.0) * 0.875;
    float offset = (grain - 0.4375) * 0.065;
    return vec3(0.50 + offset);
}

// ── PIXEL EFFECT — MODE 1 : GRID ─────────────────────────────────────────────
// fract/abs border darkening. No texture samples, no exp(), no sqrt().
// Only PT_GRID_STRENGTH is evaluated.

vec3 applyGrid(vec3 color, vec2 coord)
{
    vec2  cellUV = fract(coord * TextureSize);
    float bx     = 1.0 - abs(cellUV.x * 2.0 - 1.0);
    float by     = 1.0 - abs(cellUV.y * 2.0 - 1.0);
    return color * mix(1.0, bx * by, PT_GRID_STRENGTH);
}

// ── PIXEL EFFECT — MODE 2 : LCD DOT ──────────────────────────────────────────
// Gaussian falloff from dot centre with brightness-dependent dot sizing.
// Single sample. Only PT_DOT_SIZE, PT_DOT_SHARPNESS, PT_DOT_BRIGHTNESS,
// PT_BLACK_THRESHOLD evaluated. Uses post-processed brightness for black gate
// since OrigTexture is not available in NextUI.

vec3 applyLCDDot(vec3 color, vec2 coord, float pixLuma)
{
    // Gate: pure black and near-black pixels pass through unchanged.
    if (pixLuma < 0.01) return color;
    float lumaFade = smoothstep(0.0, PT_BLACK_THRESHOLD, pixLuma);

    vec2  cellUV = fract(coord * TextureSize);
    vec2  delta  = cellUV - 0.5;
    float dist   = sqrt(dot(delta, delta));

    // Brightness-dependent radius: bright pixels get slightly larger dots,
    // dark pixels slightly smaller.
    float bloomBias = mix(0.0, 0.08, pixLuma);
    float radius    = PT_DOT_SIZE * 0.5 + bloomBias;

    // Sharpness controls Gaussian falloff rate.
    float falloff = PT_DOT_SHARPNESS + 1.0;
    float edge    = clamp(radius - dist, 0.0, 1.0);
    float dotMask = pow(edge / max(radius, 0.001), falloff);
    dotMask       = clamp(dotMask, 0.0, 1.0);

    // Blend dot result with original color based on pixel brightness —
    // dark pixels get original color, bright pixels get full dot effect.
    vec3 dotResult = color * dotMask;
    vec3 result    = mix(color, dotResult, lumaFade);

    // Brightness compensation restores luminance lost to inter-dot gaps.
    float litFraction = clamp(PI * radius * radius, 0.001, 1.0);
    result = mix(result, result / litFraction, PT_DOT_BRIGHTNESS * lumaFade);

    return result;
}

// ── UNIFIED PIXEL EFFECT DISPATCHER ──────────────────────────────────────────
// Strictly gated — each branch only evaluates its own mode's parameters.

vec3 applyPixelEffect(vec3 color, vec2 coord, float pixLuma)
{
    if (PT_GRID_MODE < 0.5) return color;
    if (PT_GRID_MODE < 1.5) return applyGrid(color, coord);
    return applyLCDDot(color, coord, pixLuma);
}

// Bezel shadow — rectangular edge darkening simulating physical bezel shadow.
// Width approximated per system. Scales correctly at any output resolution.
vec3 applyBezelShadow(vec3 color, vec2 coord)
{
    if (PT_BEZEL < 0.001) return color;

    // Falloff scale per system — higher = narrower shadow.
    // Based on actual shadow cast onto screen by bezel recess depth.
    float scale = 35.0;
    if      (PT_SYSTEM < 1.5) scale = 22.0; // GB — deep recess, most shadow
    else if (PT_SYSTEM < 2.5) scale = 35.0; // GBC — moderate shadow
    else if (PT_SYSTEM < 3.5) scale = 70.0; // GBA SP — minimal shadow
    else                      scale = 55.0; // GBA Orig — shallow recess, little shadow

    // Normalise coord to true 0..1 over the game image, then remap to -1..+1.
    vec2  gameUV = coord / (InputSize / TextureSize);
    vec2  uv     = gameUV * 2.0 - 1.0;
    float shadow = clamp((1.0 - abs(uv.x)) * scale, 0.0, 1.0) *
                   clamp((1.0 - abs(uv.y)) * scale, 0.0, 1.0);

    return color * mix(1.0 - PT_BEZEL, 1.0, shadow);
}

// ── MAIN ─────────────────────────────────────────────────────────────────────
void main()
{
    // Sample post-processed frame.
    vec4 lcd   = COMPAT_TEXTURE(Texture, TEX0.xy);
    vec3 pixel = lcd.rgb;

    // Cache brightness — used throughout.
    float pixBrightness = getBrightness(pixel);

    // Dark color filter — on corrected frame.
    if (PT_DARK_FILTER_LEVEL > 0.5) {
        pixel         = applyDarkFilter(pixel, PT_DARK_FILTER_LEVEL);
        pixBrightness = getBrightness(pixel);
    }

    // White detection — on post-processed frame.
    // Thresholds pre-compensated for NextUI pipeline.
    float threshold = resolveThreshold();
    float isWhite   = isWhitePixel(pixel, pixBrightness, threshold);

    // White mode — non-white pixels exit early, still applying post effects.
    float alpha = 0.0;
    if (PT_PIXEL_MODE < 0.5 && isWhite < 0.5) {
        vec3 result = applyPixelEffect(pixel, TEX0.xy, pixBrightness);
        result = applyBezelShadow(result, TEX0.xy);
        FragColor = vec4(result, lcd.a);
        return;
    }

    // Procedural backing texture — only reached by pixels that will be blended.
    vec3 bg = proceduralBackground(TEX0.xy);

    // Drop shadow — single tap on post-processed frame, applied before palette tint.
    if (PT_SHADOW_OPACITY > 0.001) {
        vec2  shadowPos      = TEX0.xy + vec2(-PT_SHADOW_OFFSET, -PT_SHADOW_OFFSET) * texel;
        vec3  shadowSrc      = COMPAT_TEXTURE(Texture, shadowPos).rgb;
        float shadowBright   = getBrightness(shadowSrc);
        float shadowSrcWhite = isWhitePixel(shadowSrc, shadowBright, threshold);
        if (shadowSrcWhite < 0.5) {
            float shadowStrength = (1.0 - shadowBright) * PT_SHADOW_OPACITY;
            bg = mix(bg, bg * 0.2, shadowStrength);
        }
    }

    // Palette tint — applied after shadow.
    if (PT_PALETTE > 0.5) {
        vec3 tint;
        if      (PT_PALETTE < 1.5) tint = vec3(0.651, 0.675, 0.518);
        else if (PT_PALETTE < 2.5) tint = vec3(0.737, 0.737, 0.737);
        else                       tint = vec3(1.0,   1.0,   1.0  );
        vec3 tinted = clamp(mix(
            2.0 * tint * bg,
            1.0 - 2.0 * (1.0 - tint) * (1.0 - bg),
            step(0.5, bg)
        ), 0.0, 1.0);
        bg = mix(bg, tinted, PT_PALETTE_INTENSITY);
    }

    if (PT_PIXEL_MODE < 0.5) {
        // White only.
        alpha = clamp((pixBrightness / 3.0) + PT_BASE_ALPHA, 0.0, 1.0);
    } else if (PT_PIXEL_MODE < 1.5) {
        // Bright.
        alpha = clamp(PT_BASE_ALPHA * pixBrightness * 2.665, 0.0, 1.0);
    } else {
        // All.
        alpha = clamp((pixBrightness / 3.0) + PT_BASE_ALPHA, 0.0, 1.0);
    }

    if (isWhite > 0.5) alpha = max(alpha, PT_WHITE_TRANSPARENCY);

    vec3 result = mix(pixel, bg, alpha);

    // Post-blend pixel effect — applied last.
    result = applyPixelEffect(result, TEX0.xy, pixBrightness);
    result = applyBezelShadow(result, TEX0.xy);

    FragColor = vec4(result, lcd.a);
}
#endif
