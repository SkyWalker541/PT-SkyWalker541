/*
  PT SkyWalker541  v1.7.0
  by SkyWalker541  |  RetroArch GLSL

  Pixel transparency shader inspired by mattakins' pixel transparency work.
  Restores GB/GBC/GBA backing material appearance on white/bright pixels.

  v1.7.0 — replaced PT_PIXEL_BORDER with unified Pixel Effect system:
            Grid, LCD Dot (Gaussian falloff), CRT Phosphor (9-sample neighbourhood,
            RGB subpixels, scanlines, bloom). All effect parameters strictly
            gated to their own mode for minimum cost when not selected.
*/

// ── PARAMETERS ───────────────────────────────────────────────────────────────

// System
#pragma parameter PT_SYSTEM              "System (0=Manual, 1=GB, 2=GBC, 3=GBA SP, 4=GBA Orig)" 1.0 0.0 4.0 1.0
#pragma parameter PT_SENSITIVITY         "  Manual sensitivity threshold"            0.85 0.0 1.0 0.01

// Pixel Transparency
#pragma parameter PT_PIXEL_MODE          "Pixel mode (0=White, 1=Bright, 2=All)"    0.0 0.0 2.0 1.0
#pragma parameter PT_BASE_ALPHA          "  Base transparency amount"                0.20 0.0 1.0 0.01
#pragma parameter PT_WHITE_TRANSPARENCY  "  White pixel min transparency"            0.20 0.0 1.0 0.01

// Background
#pragma parameter PT_PALETTE             "Background tint (0=Off, 1=Pocket, 2=Grey, 3=White)" 1.0 0.0 3.0 1.0
#pragma parameter PT_PALETTE_INTENSITY   "  Tint intensity"                          1.0 0.0 2.0 0.05

// Color Filter
#pragma parameter PT_DARK_FILTER_LEVEL   "Dark color filter (0=off)"                0.0 0.0 100.0 1.0

// Pixel Effect — mode selector
#pragma parameter PT_GRID_MODE           "Pixel Effect (0=Off, 1=Grid, 2=LCD Dot, 3=CRT Phosphor)" 1.0 0.0 3.0 1.0

// [Grid] parameters — only active when PT_GRID_MODE = 1
#pragma parameter PT_GRID_STRENGTH       "  [Grid]     Grid strength"                0.08 0.0 1.0 0.01

// [LCD Dot] parameters — only active when PT_GRID_MODE = 2
#pragma parameter PT_DOT_SIZE            "  [LCD Dot]  Dot size"                     0.50 0.1 0.9 0.01
#pragma parameter PT_DOT_SHARPNESS       "  [LCD Dot]  Dot sharpness"                0.0  0.0 5.0 0.1
#pragma parameter PT_DOT_BRIGHTNESS      "  [LCD Dot]  Dot brightness compensation"  0.0  0.0 1.0 0.01

// [Phosphor] parameters — only active when PT_GRID_MODE = 3
#pragma parameter PT_PHOS_SIZE           "  [Phosphor] Phosphor dot size"            0.50 0.1 0.9 0.01
#pragma parameter PT_PHOS_BLOOM          "  [Phosphor] Bloom spread"                 0.0  0.0 1.0 0.01
#pragma parameter PT_PHOS_GAMMA          "  [Phosphor] Dot gamma"                    2.40 0.5 5.0 0.05
#pragma parameter PT_PHOS_BRIGHTNESS     "  [Phosphor] Phosphor brightness comp"     0.0  0.0 1.0 0.01
#pragma parameter PT_PHOS_SCANLINE       "  [Phosphor] Scanline strength"            0.0  0.0 1.0 0.01
#pragma parameter PT_PHOS_LAYOUT         "  [Phosphor] Subpixel layout (0=RGB, 1=BGR)" 0.0 0.0 1.0 1.0

// Drop Shadow
#pragma parameter PT_SHADOW_OFFSET       "Shadow offset"                             1.0 -10.0 10.0 0.5
#pragma parameter PT_SHADOW_OPACITY      "  Shadow opacity (0=off)"                  0.30 0.0 1.0 0.01

// Bezel Shadow
#pragma parameter PT_BEZEL               "Bezel shadow strength (0=off)"             0.40 0.0 1.0 0.01

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
COMPAT_VARYING   vec2 orig_coord;

// Phosphor 9-sample neighbourhood coords packed into vec4 pairs.
// Declared always — vertex cost on 4 vertices is negligible.
// xy = neighbour A, zw = neighbour B.
COMPAT_VARYING   vec4 phos_c00_c10;   // (-1,-1) and ( 0,-1)
COMPAT_VARYING   vec4 phos_c20_c01;   // ( 1,-1) and (-1, 0)
COMPAT_VARYING   vec4 phos_c21_c02;   // ( 1, 0) and (-1, 1)
COMPAT_VARYING   vec4 phos_c12_c22;   // ( 0, 1) and ( 1, 1)
COMPAT_VARYING   vec2 phos_c11;       // ( 0, 0) centre

uniform mat4 MVPMatrix;
uniform COMPAT_PRECISION vec2 OutputSize;
uniform COMPAT_PRECISION vec2 TextureSize;
uniform COMPAT_PRECISION vec2 InputSize;
uniform COMPAT_PRECISION vec2 OrigTextureSize;
uniform COMPAT_PRECISION vec2 OrigInputSize;

#ifdef PARAMETER_UNIFORM
uniform COMPAT_PRECISION float PT_PHOS_SIZE;
#else
#define PT_PHOS_SIZE 0.50
#endif

void main()
{
    gl_Position = MVPMatrix * VertexCoord;
    TEX0        = TexCoord.xy;
    texel       = 1.0 / TextureSize;
    orig_coord  = TEX0.xy * (TextureSize / InputSize) * (OrigInputSize / OrigTextureSize);

    // Phosphor neighbourhood coords — pixel_no is position in source pixel space,
    // d converts back to texture coordinates.
    // Spread scaled by PT_PHOS_SIZE so dot size affects neighbourhood reach.
    vec2  pixel_no = TEX0.xy * TextureSize / InputSize * OrigInputSize;
    vec2  d        = 1.0 / TextureSize * InputSize / OrigInputSize;
    float spread   = PT_PHOS_SIZE;

    phos_c00_c10 = vec4((pixel_no + vec2(-1.0, -1.0) * spread) * d,
                        (pixel_no + vec2( 0.0, -1.0) * spread) * d);
    phos_c20_c01 = vec4((pixel_no + vec2( 1.0, -1.0) * spread) * d,
                        (pixel_no + vec2(-1.0,  0.0) * spread) * d);
    phos_c21_c02 = vec4((pixel_no + vec2( 1.0,  0.0) * spread) * d,
                        (pixel_no + vec2(-1.0,  1.0) * spread) * d);
    phos_c12_c22 = vec4((pixel_no + vec2( 0.0,  1.0) * spread) * d,
                        (pixel_no + vec2( 1.0,  1.0) * spread) * d);
    phos_c11     = pixel_no * d;
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
uniform COMPAT_PRECISION vec2 OrigTextureSize;
uniform COMPAT_PRECISION vec2 OrigInputSize;
uniform sampler2D Texture;
uniform sampler2D OrigTexture;

COMPAT_VARYING vec2 TEX0;
COMPAT_VARYING vec2 texel;
COMPAT_VARYING vec2 orig_coord;
COMPAT_VARYING vec4 phos_c00_c10;
COMPAT_VARYING vec4 phos_c20_c01;
COMPAT_VARYING vec4 phos_c21_c02;
COMPAT_VARYING vec4 phos_c12_c22;
COMPAT_VARYING vec2 phos_c11;

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
uniform COMPAT_PRECISION float PT_PHOS_SIZE;
uniform COMPAT_PRECISION float PT_PHOS_BLOOM;
uniform COMPAT_PRECISION float PT_PHOS_GAMMA;
uniform COMPAT_PRECISION float PT_PHOS_BRIGHTNESS;
uniform COMPAT_PRECISION float PT_PHOS_SCANLINE;
uniform COMPAT_PRECISION float PT_PHOS_LAYOUT;
uniform COMPAT_PRECISION float PT_SHADOW_OFFSET;
uniform COMPAT_PRECISION float PT_SHADOW_OPACITY;
uniform COMPAT_PRECISION float PT_BEZEL;
#else
#define PT_SYSTEM             1.0
#define PT_SENSITIVITY        0.85
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
#define PT_PHOS_SIZE          0.50
#define PT_PHOS_BLOOM         0.0
#define PT_PHOS_GAMMA         2.40
#define PT_PHOS_BRIGHTNESS    0.0
#define PT_PHOS_SCANLINE      0.0
#define PT_PHOS_LAYOUT        0.0
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

float getBrightness(vec3 c)
{
    return LUMA_R * c.r + LUMA_G * c.g + LUMA_B * c.b;
}

float resolveThreshold()
{
    if (PT_SYSTEM < 0.5) return PT_SENSITIVITY;
    if (PT_SYSTEM < 1.5) return 0.90;
    if (PT_SYSTEM < 2.5) return 0.85;
    if (PT_SYSTEM < 3.5) return 0.80;
    return 0.75;
}

float isWhitePixel(vec3 pixel, float brightness, float threshold)
{
    float minCh = min(pixel.r, min(pixel.g, pixel.b));
    if (brightness > threshold && minCh > threshold * 0.9) return 1.0;
    return 0.0;
}

vec3 applyDarkFilter(vec3 c, float level)
{
    float strength = level * 0.01;
    float luma     = getBrightness(c);
    float factor   = max(1.0 - strength * luma, 0.0);
    return c * factor;
}

float noiseHash(vec2 p)
{
    vec3 p3 = fract(vec3(p.xyx) * 0.1031);
    p3 = p3 + vec3(dot(p3, p3.yzx + 33.33));
    return fract((p3.x + p3.y) * p3.z);
}

vec3 proceduralBackground(vec2 uv)
{
    float grain  = noiseHash(uv * 128.0) * 0.875;
    float offset = (grain - 0.4375) * 0.065;
    return vec3(0.478 + offset);
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
// Single sample. Only PT_DOT_SIZE, PT_DOT_SHARPNESS, PT_DOT_BRIGHTNESS evaluated.

vec3 applyLCDDot(vec3 color, vec2 coord)
{
    vec2  cellUV = fract(coord * TextureSize);
    vec2  delta  = cellUV - 0.5;
    float dist   = sqrt(dot(delta, delta));

    // Brightness-dependent radius: bright pixels get slightly larger dots,
    // dark pixels slightly smaller — consistent with physical LCD behaviour.
    float luma      = getBrightness(color);
    float bloomBias = mix(0.0, 0.08, luma);
    float radius    = PT_DOT_SIZE * 0.5 + bloomBias;

    // Sharpness controls Gaussian falloff rate.
    // sharpness=0 → soft edge; sharpness=5 → near-hard edge.
    float falloff = PT_DOT_SHARPNESS + 1.0;
    float edge    = clamp(radius - dist, 0.0, 1.0);
    float dotMask = pow(edge / max(radius, 0.001), falloff);
    dotMask       = clamp(dotMask, 0.0, 1.0);

    vec3 result = color * dotMask;

    // Brightness compensation restores luminance lost to inter-dot gaps.
    float litFraction = clamp(PI * radius * radius, 0.001, 1.0);
    result = mix(result, result / litFraction, PT_DOT_BRIGHTNESS);

    return result;
}

// ── PIXEL EFFECT — MODE 3 : CRT PHOSPHOR ─────────────────────────────────────
// 9-sample Gaussian neighbourhood, RGB subpixel stripes, scanlines.
// Only PT_PHOS_* parameters evaluated.

// Gaussian contribution of one neighbour pixel.
// Brightness-dependent size: bright=larger dot, dark=smaller dot.
float phosphorDot(vec2 pixel_no, float offset_x, float offset_y, vec3 srcColor)
{
    vec2  delta  = fract(pixel_no) - (vec2(offset_x, offset_y) + vec2(0.5));
    float dist   = sqrt(dot(delta, delta));
    float bright = dot(srcColor, vec3(0.30, 0.59, 0.11));
    float bloom  = mix(1.05, 0.95, bright);
    return exp(-PT_PHOS_GAMMA * dist * bloom);
}

// RGB subpixel stripe mask with optional BGR layout and scanline roll-off.
vec3 subpixelMask(float cellX, float cellY)
{
    float edge   = 0.08;
    float rStripe = smoothstep(0.0,   0.0   + edge, cellX) - smoothstep(0.333, 0.333 + edge, cellX);
    float gStripe = smoothstep(0.333, 0.333 + edge, cellX) - smoothstep(0.667, 0.667 + edge, cellX);
    float bStripe = smoothstep(0.667, 0.667 + edge, cellX) - smoothstep(1.0,   1.0   + edge, cellX);

    // Scanline: cosine roll-off vertically, strength controlled by PT_PHOS_SCANLINE.
    float scan    = 0.5 + 0.5 * cos(cellY * PI);
    float scanMod = mix(1.0, scan, PT_PHOS_SCANLINE);
    rStripe *= scanMod;
    gStripe *= scanMod;
    bStripe *= scanMod;

    if (PT_PHOS_LAYOUT > 0.5)
        return vec3(bStripe, gStripe, rStripe);   // BGR
    else
        return vec3(rStripe, gStripe, bStripe);   // RGB
}

vec3 applyPhosphor(vec3 color, vec2 coord)
{
    vec2 pixel_no = coord * TextureSize / InputSize * OrigInputSize;

    // 9-sample neighbourhood using vertex-precomputed coords.
    vec3 s11 = COMPAT_TEXTURE(Texture, phos_c11).rgb;
    vec3 s00 = COMPAT_TEXTURE(Texture, phos_c00_c10.xy).rgb;
    vec3 s10 = COMPAT_TEXTURE(Texture, phos_c00_c10.zw).rgb;
    vec3 s20 = COMPAT_TEXTURE(Texture, phos_c20_c01.xy).rgb;
    vec3 s01 = COMPAT_TEXTURE(Texture, phos_c20_c01.zw).rgb;
    vec3 s21 = COMPAT_TEXTURE(Texture, phos_c21_c02.xy).rgb;
    vec3 s02 = COMPAT_TEXTURE(Texture, phos_c21_c02.zw).rgb;
    vec3 s12 = COMPAT_TEXTURE(Texture, phos_c12_c22.xy).rgb;
    vec3 s22 = COMPAT_TEXTURE(Texture, phos_c12_c22.zw).rgb;

    // Accumulate Gaussian-weighted colour from all neighbours.
    vec3 acc = vec3(0.0);
    acc += s11 * phosphorDot(pixel_no,  0.0,  0.0, s11);
    acc += s00 * phosphorDot(pixel_no, -1.0, -1.0, s00);
    acc += s10 * phosphorDot(pixel_no,  0.0, -1.0, s10);
    acc += s20 * phosphorDot(pixel_no,  1.0, -1.0, s20);
    acc += s01 * phosphorDot(pixel_no, -1.0,  0.0, s01);
    acc += s21 * phosphorDot(pixel_no,  1.0,  0.0, s21);
    acc += s02 * phosphorDot(pixel_no, -1.0,  1.0, s02);
    acc += s12 * phosphorDot(pixel_no,  0.0,  1.0, s12);
    acc += s22 * phosphorDot(pixel_no,  1.0,  1.0, s22);

    // Blend between sharp centre dot and full neighbourhood bloom.
    vec3 sharpDot = s11 * phosphorDot(pixel_no, 0.0, 0.0, s11);
    vec3 bloomed  = mix(sharpDot, acc, PT_PHOS_BLOOM);

    // Apply RGB subpixel mask.
    vec2 cellUV = fract(coord * TextureSize);
    vec3 mask   = subpixelMask(cellUV.x, cellUV.y);
    vec3 result = bloomed * mask;

    // Brightness compensation restores luminance lost to subpixel masking.
    float avgMask = max((mask.r + mask.g + mask.b) / 3.0, 0.001);
    result = mix(result, result / avgMask, PT_PHOS_BRIGHTNESS);

    return result;
}

// ── UNIFIED PIXEL EFFECT DISPATCHER ──────────────────────────────────────────
// Strictly gated — each branch only evaluates its own mode's parameters.

vec3 applyPixelEffect(vec3 color, vec2 coord)
{
    if (PT_GRID_MODE < 0.5) return color;
    if (PT_GRID_MODE < 1.5) return applyGrid(color, coord);
    if (PT_GRID_MODE < 2.5) return applyLCDDot(color, coord);
    return applyPhosphor(color, coord);
}

// ── BEZEL SHADOW ─────────────────────────────────────────────────────────────

vec3 applyBezelShadow(vec3 color, vec2 coord)
{
    if (PT_BEZEL < 0.001) return color;

    float scale = 35.0;
    if      (PT_SYSTEM < 1.5) scale = 22.0;
    else if (PT_SYSTEM < 2.5) scale = 35.0;
    else if (PT_SYSTEM < 3.5) scale = 70.0;
    else                      scale = 55.0;

    vec2  gameUV = coord / (InputSize / TextureSize);
    vec2  uv     = gameUV * 2.0 - 1.0;
    float shadow = clamp((1.0 - abs(uv.x)) * scale, 0.0, 1.0) *
                   clamp((1.0 - abs(uv.y)) * scale, 0.0, 1.0);

    return color * mix(1.0 - PT_BEZEL, 1.0, shadow);
}

// ── MAIN ─────────────────────────────────────────────────────────────────────
void main()
{
    // Sample corrected frame and raw input frame.
    vec4 lcd      = COMPAT_TEXTURE(Texture,     TEX0.xy);
    vec3 pixel    = lcd.rgb;
    vec3 rawPixel = COMPAT_TEXTURE(OrigTexture, orig_coord).rgb;

    // Cache brightness.
    float pixBrightness = getBrightness(pixel);
    float rawBrightness = getBrightness(rawPixel);

    // Dark color filter — on corrected frame.
    if (PT_DARK_FILTER_LEVEL > 0.5) {
        pixel         = applyDarkFilter(pixel, PT_DARK_FILTER_LEVEL);
        pixBrightness = getBrightness(pixel);
    }

    // White detection — on raw frame.
    float threshold = resolveThreshold();
    float isWhite   = isWhitePixel(rawPixel, rawBrightness, threshold);

    // White mode — non-white pixels exit early, post effects still applied.
    float alpha = 0.0;
    if (PT_PIXEL_MODE < 0.5 && isWhite < 0.5) {
        vec3 result = applyPixelEffect(pixel, TEX0.xy);
        result = applyBezelShadow(result, TEX0.xy);
        FragColor = vec4(result, lcd.a);
        return;
    }

    // Procedural backing texture.
    vec3 bg = proceduralBackground(TEX0.xy);

    // Drop shadow — single tap on raw frame, before palette tint.
    if (PT_SHADOW_OPACITY > 0.001) {
        vec2  shadowPos      = orig_coord + vec2(-PT_SHADOW_OFFSET, -PT_SHADOW_OFFSET) * texel;
        vec3  shadowSrc      = COMPAT_TEXTURE(OrigTexture, shadowPos).rgb;
        float shadowBright   = getBrightness(shadowSrc);
        float shadowSrcWhite = isWhitePixel(shadowSrc, shadowBright, threshold);
        if (shadowSrcWhite < 0.5) {
            float shadowStrength = (1.0 - shadowBright) * PT_SHADOW_OPACITY;
            bg = mix(bg, bg * 0.2, shadowStrength);
        }
    }

    // Palette tint — after shadow.
    if (PT_PALETTE > 0.5) {
        vec3 tint;
        if      (PT_PALETTE < 1.5) tint = vec3(0.651, 0.675, 0.518);
        else if (PT_PALETTE < 2.5) tint = vec3(0.737, 0.737, 0.737);
        else                       tint = vec3(1.0,   1.0,   1.0  );
        vec3 tinted = clamp(tint + (bg * 2.0 - vec3(1.0)), 0.0, 1.0);
        bg = mix(bg, tinted, PT_PALETTE_INTENSITY);
    }

    // Transparency alpha.
    if (PT_PIXEL_MODE < 0.5) {
        alpha = clamp((pixBrightness / 3.0) + PT_BASE_ALPHA, 0.0, 1.0);
    } else if (PT_PIXEL_MODE < 1.5) {
        alpha = clamp(PT_BASE_ALPHA * pixBrightness * 2.665, 0.0, 1.0);
    } else {
        alpha = clamp((pixBrightness / 3.0) + PT_BASE_ALPHA, 0.0, 1.0);
    }

    if (isWhite > 0.5) alpha = max(alpha, PT_WHITE_TRANSPARENCY);

    vec3 result = mix(pixel, bg, alpha);

    // Post-blend pixel effect and bezel — applied last.
    result = applyPixelEffect(result, TEX0.xy);
    result = applyBezelShadow(result, TEX0.xy);

    FragColor = vec4(result, lcd.a);
}
#endif
