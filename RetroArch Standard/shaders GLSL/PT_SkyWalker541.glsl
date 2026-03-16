/*
╔══════════════════════════════════════════════════════════════════╗
║  PT SkyWalker541  v1.5.2                                         ║
║  by SkyWalker541  |  Written for RetroArch (GLSL)                ║
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

  Single-pass. White detection runs on OrigTexture — RetroArch's
  built-in uniform for the raw unprocessed input frame — giving
  clean pre-correction pixel values without a passthrough pass.

╔══════════════════════════════════════════════════════════════════╗
║  CHANGELOG                                                       ║
╚══════════════════════════════════════════════════════════════════╝

  v1.5.0 - Added PT_SYSTEM = 4 (GBA Original, threshold 0.75) for the
           original GBA's dim, creamy whites. Reduced procedural
           background noise from three octaves to two — lower cost,
           no visible quality difference on target hardware. Fixed
           undefined OrigTextureSize/OrigInputSize uniforms. Fixed
           orig_coord vertex calculation. Fixed shadow offset formula.
           Fixed getBrightness for GLSL ES compatibility.

  v1.4.0 - Rebuilt as single-pass shader. Passthrough pass removed.
           PassPrev2Texture replaced with RetroArch built-in
           OrigTexture, which provides the raw pre-correction input
           frame natively. orig_coord computed in vertex shader for
           correct OrigTexture sampling. Loops unrolled for GLSL ES
           compatibility on Android/mobile. Resolves missing shader
           in browser and load failures on Android. All shader logic,
           parameters, and visual output identical to v1.3.0.

  v1.3.0 - Ported to RetroArch GLSL multipass (.glsl / .glslp).
           Merged Aspect and Integer variants. White detection and
           transparency gating run against raw frame. Thresholds
           retuned for raw pixel values.

  v1.2.2 - Single-pass hash, reduced arithmetic cost.
  v1.2.1 - Period-authentic defaults (shadow 1.0/1.0/0.30, vig 0.08)
  v1.1.6 - Shadow blur removed: single texture tap.
  v1.1.0 - Split Aspect/Integer. Shadow formula rewritten.
  v1.0.0 - Initial release.
*/

// ╔══════════════════════════════════════════════════════════════╗
// ║  PARAMETERS                                                  ║
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
#pragma parameter PT_PALETTE         "Background tint (0=Off, 1=Pocket, 2=Grey, 3=White, 4=GrnGrey)" 1.0 0.0 4.0 1.0
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
#ifdef PARAMETER_UNIFORM
uniform COMPAT_PRECISION float PT_SYSTEM;
uniform COMPAT_PRECISION float PT_SENSITIVITY;
uniform COMPAT_PRECISION float PT_PIXEL_MODE;
uniform COMPAT_PRECISION float PT_BASE_ALPHA;
uniform COMPAT_PRECISION float PT_WHITE_TRANSPARENCY;
uniform COMPAT_PRECISION float PT_BRIGHTNESS_MODE;
uniform COMPAT_PRECISION float PT_PALETTE;
uniform COMPAT_PRECISION float PT_PALETTE_INTENSITY;
uniform COMPAT_PRECISION float PT_DARK_FILTER_LEVEL;
uniform COMPAT_PRECISION float PT_PIXEL_BORDER;
uniform COMPAT_PRECISION float PT_SHADOW_OFFSET_X;
uniform COMPAT_PRECISION float PT_SHADOW_OFFSET_Y;
uniform COMPAT_PRECISION float PT_SHADOW_OPACITY;
uniform COMPAT_PRECISION float PT_VIGNETTE;
#else
#define PT_SYSTEM             1.0
#define PT_SENSITIVITY        0.85
#define PT_PIXEL_MODE         0.0
#define PT_BASE_ALPHA         0.20
#define PT_WHITE_TRANSPARENCY 0.20
#define PT_BRIGHTNESS_MODE    0.0
#define PT_PALETTE            1.0
#define PT_PALETTE_INTENSITY  1.0
#define PT_DARK_FILTER_LEVEL  0.0
#define PT_PIXEL_BORDER       1.0
#define PT_SHADOW_OFFSET_X    1.0
#define PT_SHADOW_OFFSET_Y    1.0
#define PT_SHADOW_OPACITY     0.30
#define PT_VIGNETTE           0.08
#endif

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
    return (PT_BRIGHTNESS_MODE < 0.5) ? simpleBrightness(c)
                                      : perceptualBrightness(c);
}

// ┌──────────────────────────────────┐
// │  White Detection                 │
// └──────────────────────────────────┘

// Resolve system preset to detection threshold.
// Thresholds tuned for raw pre-correction pixel values (OrigTexture).
float resolveThreshold()
{
    if (PT_SYSTEM < 0.5) return PT_SENSITIVITY;
    if (PT_SYSTEM < 1.5) return 0.90;
    if (PT_SYSTEM < 2.5) return 0.85;
    if (PT_SYSTEM < 3.5) return 0.80;
    return 0.75;
}

// Dual-channel ratio method: pixel must be both bright AND neutral.
float isWhitePixel(vec3 pixel, float threshold)
{
    float brightness   = perceptualBrightness(pixel);
    float maxChannel   = max(max(pixel.r, pixel.g), pixel.b);
    float minChannel   = min(min(pixel.r, pixel.g), pixel.b);
    float channelRange = maxChannel - minChannel;
    if (brightness > threshold && channelRange < 0.15) return 1.0;
    return 0.0;
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

// Two-octave hash noise. Kept at two octaves deliberately — this is a
// low-end shader and the third octave adds cost with no perceptible benefit.
// Matches the Slang version exactly.
float noiseHash(vec2 p)
{
    vec3 p3 = fract(vec3(p.xyx) * 0.1031);
    p3 = p3 + vec3(dot(p3, p3.yzx + 33.33));
    return fract((p3.x + p3.y) * p3.z);
}

vec3 proceduralBackground(vec2 uv)
{
    vec2  p     = uv * 256.0;
    float grain = noiseHash(p) * 0.500 + noiseHash(p * 2.0) * 0.250;
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
// │  Post-Blend Effects              │
// └──────────────────────────────────┘


// Vignette — pure math, zero extra taps.
vec3 applyVignette(vec3 color, vec2 coord)
{
    if (PT_VIGNETTE < 0.001) return color;
    vec2  uv       = coord * 2.0 - 1.0;
    float dist     = dot(uv, uv);
    float vignette = 1.0 - dist * PT_VIGNETTE;
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
    vec2 offset   = toCenter * PT_CHROMA_STRENGTH * (1.0 / TextureSize);
    float r = COMPAT_TEXTURE(Texture, coord + offset).r;
    float b = COMPAT_TEXTURE(Texture, coord - offset).b;
    return vec3(r, color.g, b);
}

// ╔══════════════════════════════════════════════════════════════╗
// ║  MAIN                                                        ║
// ╚══════════════════════════════════════════════════════════════╝
void main()
{
    // Sample colour-corrected frame (Texture) and raw input frame (OrigTexture).
    vec4 lcd      = COMPAT_TEXTURE(Texture,     TEX0.xy);
    vec3 pixel    = lcd.rgb;
    vec3 rawPixel = COMPAT_TEXTURE(OrigTexture, orig_coord).rgb;

    // Color harshness filter — on Source (colour-corrected).
    if (PT_DARK_FILTER_LEVEL > 0.5) {
        pixel   = applyDarkFilter(pixel, PT_DARK_FILTER_LEVEL);
        lcd.rgb = pixel;
    }

    // White detection — on rawPixel (OrigTexture, pre-correction).
    float threshold = resolveThreshold();
    float isWhite   = isWhitePixel(rawPixel, threshold);

    // Build procedural backing texture with optional palette tint.
    vec3 bg = proceduralBackground(TEX0.xy);

    if (PT_PALETTE > 0.5) {
        vec3 tint;
        if (PT_PALETTE < 1.5) {
            tint = vec3(0.651, 0.675, 0.518); // Pocket: warm green-grey
        } else if (PT_PALETTE < 2.5) {
            tint = vec3(0.737, 0.737, 0.737); // Grey
        } else if (PT_PALETTE < 3.5) {
            tint = vec3(1.0, 1.0, 1.0);       // White
        } else {
            tint = vec3(0.60, 0.64, 0.46);    // Green-grey (GBA Orig)
        }
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

    // Transparency gate.
    float willBeTransparent;
    if (PT_PIXEL_MODE < 0.5) {
        willBeTransparent = isWhite;
    } else if (PT_PIXEL_MODE < 1.5) {
        willBeTransparent = step(threshold * 0.9, getBrightness(rawPixel));
    } else {
        willBeTransparent = 1.0;
    }

    // Drop shadow — single tap on OrigTexture.
    // Gated on shadow source being non-white rather than current pixel being transparent,
    // so shadows appear at all sprite and tile edges regardless of local transparency.
    if (PT_SHADOW_OPACITY > 0.001) {
        vec2  shadow_offset  = vec2(-PT_SHADOW_OFFSET_X, -PT_SHADOW_OFFSET_Y)
                               * (1.0 / TextureSize);
        vec2  shadowPos      = orig_coord + shadow_offset;
        // Skip shadow if sample position is outside valid texture bounds —
        // out-of-range UVs clamp to edge and produce false dark bars.
        if (shadowPos.x >= 0.0 && shadowPos.x <= 1.0 && shadowPos.y >= 0.0 && shadowPos.y <= 1.0) {
            vec3  shadowSrc      = COMPAT_TEXTURE(OrigTexture, shadowPos).rgb;
            float shadowSrcWhite = isWhitePixel(shadowSrc, threshold);
            if (shadowSrcWhite < 0.5) {
                float shadowDark     = 1.0 - getBrightness(shadowSrc);
                float shadowStrength = (shadowDark * shadowDark) * PT_SHADOW_OPACITY;
                bg = mix(bg, bg * 0.2, shadowStrength);
            }
        }
    }

    // Transparency blend.
    vec3 result = pixel;

    if (PT_PIXEL_MODE < 0.5) {
        // White only
        if (isWhite > 0.5) {
            float intensity = getBrightness(pixel);
            float alpha     = clamp((intensity / 3.0) + PT_BASE_ALPHA, 0.0, 1.0);
            alpha           = max(alpha, PT_WHITE_TRANSPARENCY);
            result          = huePreservingBlend(pixel, bg, alpha);
        }
    } else if (PT_PIXEL_MODE < 1.5) {
        // Bright
        float intensity = getBrightness(pixel);
        float alpha     = clamp(PT_BASE_ALPHA * intensity * 2.4, 0.0, 1.0);
        if (isWhite > 0.5) alpha = max(alpha, PT_WHITE_TRANSPARENCY);
        result = huePreservingBlend(pixel, bg, alpha);
    } else {
        // All
        float intensity = getBrightness(pixel);
        float alpha     = clamp((intensity / 3.0) + PT_BASE_ALPHA, 0.0, 1.0);
        if (isWhite > 0.5) alpha = max(alpha, PT_WHITE_TRANSPARENCY);
        result = huePreservingBlend(pixel, bg, alpha);
    }

    // Post-blend effects.
    result = result * pixelBorderFactor(TEX0.xy);
    result = applyVignette(result, TEX0.xy);
    result = applyChroma(result, TEX0.xy);

    FragColor = vec4(result, lcd.a);
}
#endif
