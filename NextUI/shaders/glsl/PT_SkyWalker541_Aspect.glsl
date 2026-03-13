/*
╔══════════════════════════════════════════════════════════════════╗
║  PT SkyWalker541 Aspect  v1.5.0                                  ║
║  by SkyWalker541  |  Written for NextUI / minarch               ║
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

  Use this variant for ASPECT RATIO / NON-INTEGER scaling.
  Use PT_SkyWalker541_Integer.glsl for NATIVE / INTEGER scaling.

  Standalone shader — no additional passes required.

╔══════════════════════════════════════════════════════════════════╗
║  SYSTEM GUIDE                                                    ║
╚══════════════════════════════════════════════════════════════════╝

  Set PT_SYSTEM first — it determines the detection threshold.
  Thresholds are pre-compensated for post-processing on NextUI.

  1 = Game Boy (GB)
      No backlight. Aggressive detection threshold (0.58).
      GB Colorization: Disabled recommended. Any colorization
      palette shifts what registers as white. If you use it,
      switch to Manual (0) and lower PT_SENSITIVITY until
      backgrounds go transparent as expected.

  2 = Game Boy Color (GBC)
      No backlight. Moderate detection threshold (0.65).
      Color correction: GBC Only.

  3 = Game Boy Advance (GBA)
      Backlit screen. Conservative detection threshold (0.42).
      Color correction: Enabled. Interframe blending: Enabled.

  0 = Manual — use PT_SENSITIVITY directly.

╔══════════════════════════════════════════════════════════════════╗
║  KNOWN LIMITATIONS                                               ║
╚══════════════════════════════════════════════════════════════════╝

  White detection runs against the post-processed texture rather
  than the raw game frame. Per-system thresholds are pre-compensated
  to account for this and produce accurate results.

  When NextUI adds OrigTexture support, this shader will be updated
  to run detection on the raw pre-correction frame — matching the
  RetroArch version's architecture. This is a planned architectural
  change: the threshold compensation logic will be replaced wholesale,
  not patched. Thresholds will be retuned to raw pixel values at that
  time.

╔══════════════════════════════════════════════════════════════════╗
║  CHANGELOG                                                       ║
╚══════════════════════════════════════════════════════════════════╝

  v1.5.0 - Unified version number across all PT_SkyWalker541 variants
           (Standard, Pro, NextUI). No shader logic changes.

  v1.3.0 - Added PT_SYSTEM = 4 (GBA Original, threshold 0.38) tuned
           for the original GBA's dim, creamy whites on NextUI.
           PT_BRIGHTNESS_MODE default changed from Perceptual to Simple
           — cheaper on PowerVR, correct for GB/GBC out of the box.

  v1.2.2 - Replaced noiseHash with reference shader's cheaper
           single-pass hash (fract/dot/fract). Reduces backing
           texture arithmetic from 4 fract/dot pairs to 1 per call.
           No visible change to grain quality at GB/GBC/GBA scales.

  v1.2.1 - Updated defaults to period-authentic values (verified on
           1024x768, applicable at any resolution):
             PT_SHADOW_OFFSET_X  1.5 → 1.0
             PT_SHADOW_OFFSET_Y  1.5 → 1.0
             PT_SHADOW_OPACITY   0.50 → 0.30
             PT_VIGNETTE         0.12 → 0.08

  v1.1.6 - Removed shadow blur. Shadow is now a single texture tap.
           At GB/GBC/GBA pixel scales, blur is imperceptible at any
           typical display resolution.

  v1.1.5 - Replaced 4-tap cross shadow blur with 2-tap diagonal blur.

  v1.1.4 - Fixed pixel border visibility in Aspect — wfactor
           multipliers were inverted. Subtle/Moderate/Strong now
           produce 17%/41%/76% border darkening, matching Integer.

  v1.1.3 - Fixed shadow performance — removed redundant
           floor()/TextureSize re-snapping from blur taps.

  v1.1.2 - Fixed pixel border — wrapped imgPixelCoord with fract()
           before sine argument to prevent mediump precision loss on
           PowerVR. Fixed drop shadows — removed redundant isWhitePixel
           gate that blocked shadows inside large white fills.

  v1.1.1 - Fixed drop shadows — taps now snap to texel centre.
           Fixed pixel border — sine-wave wfactor values corrected.

  v1.1.0 - Split into Aspect and Integer variants. Aspect uses
           sine-wave pixel border (works at any scale). Shadow
           formula rewritten using TextureSize/InputSize/OutputSize
           only — drops OrigInputSize (unreliable on NextUI).

  v1.0.9 - Fixed PT_PIXEL_BORDER modes 2 and 3.
           PT_VIGNETTE default lowered to 0.12.

  v1.0.8 - Replaced sin()-based noise hash — significant speedup
           on PowerVR.

  v1.0.7 - Chromatic shift rewritten as pure math — fixes pink
           tint, eliminates slowdown.

  v1.0.6 - Replaced subpixel fringing with chromatic shift.
           PT_FRINGE renamed to PT_CHROMA.

  v1.0.5 - Added PT_FRINGE (subpixel fringing) and PT_VIGNETTE.

  v1.0.4 - Shadow blur upgraded to weighted 4-tap.

  v1.0.3 - Removed all ON/OFF toggle parameters.

  v1.0.2 - Added PT_PIXEL_BORDER.

  v1.0.1 - Replaced adaptive white detection with dual-channel method.

  v1.0.0 - Initial release.
*/

// ╔══════════════════════════════════════════════════════════════╗
// ║  PARAMETERS                                                  ║
// ╚══════════════════════════════════════════════════════════════╝

// ┌──────────────────────────────────┐
// │  System Preset                   │
// └──────────────────────────────────┘
// 0=Manual  1=GB  2=GBC  3=GBA
// Thresholds pre-compensated for post-processing on NextUI.
#pragma parameter PT_SYSTEM "== PT SkyWalker541 Aspect v1.5.0 == System (0=Manual, 1=GB, 2=GBC, 3=GBA SP, 4=GBA Orig)" 1.0 0.0 4.0 1.0

// ┌──────────────────────────────────┐
// │  Sensitivity (Manual mode only)  │
// └──────────────────────────────────┘
// Only active when PT_SYSTEM = 0.
// Higher = only very obvious whites detected. Lower = more aggressive.
#pragma parameter PT_SENSITIVITY "== Detection sensitivity (Manual mode only)" 0.85 0.10 1.0 0.01

// ┌──────────────────────────────────┐
// │  Pixel Transparency              │
// └──────────────────────────────────┘
// 0=White only  1=Bright  2=All
#pragma parameter PT_PIXEL_MODE  "== Transparency mode == (0=White, 1=Bright, 2=All)" 0.0 0.0 2.0 1.0
#pragma parameter PT_BASE_ALPHA  "     ↳ Base transparency amount" 0.20 0.0 1.0 0.01
// Raises the transparency floor specifically for detected white pixels.
#pragma parameter PT_WHITE_TRANSPARENCY "     ↳ White pixel transparency boost" 0.50 0.0 1.0 0.01

// ┌──────────────────────────────────┐
// │  Brightness Mode                 │
// └──────────────────────────────────┘
// 0=Simple (R+G+B avg)  1=Perceptual (ITU-R BT.709)
#pragma parameter PT_BRIGHTNESS_MODE "== Brightness mode == (0=Simple, 1=Perceptual)" 0.0 0.0 1.0 1.0

// ┌──────────────────────────────────┐
// │  Background Tint                 │
// └──────────────────────────────────┘
// 0=OFF  1=Pocket grey  2=Grey  3=White
#pragma parameter PT_PALETTE           "== Background tint == (0=OFF, 1=Pocket, 2=Grey, 3=White)" 1.0 0.0 3.0 1.0
#pragma parameter PT_PALETTE_INTENSITY "     ↳ Tint intensity" 1.0 0.0 2.0 0.05

// ┌──────────────────────────────────┐
// │  Color Harshness Filter          │
// └──────────────────────────────────┘
// Softens vivid dark colors. Useful for GBC. Set to 0 to disable.
// Note: set device Dark Filter Level to 0 and use this instead.
#pragma parameter PT_DARK_FILTER_LEVEL "== Color harshness filter amount (0=OFF)" 10.0 0.0 100.0 1.0

// ┌──────────────────────────────────┐
// │  Pixel Border                    │
// └──────────────────────────────────┘
// Sine-wave method — works correctly at any scale mode.
// 0=OFF  1=Subtle  2=Moderate  3=Strong
#pragma parameter PT_PIXEL_BORDER "== Pixel border == (0=OFF, 1=Subtle, 2=Moderate, 3=Strong)" 1.0 0.0 3.0 1.0

// ┌──────────────────────────────────┐
// │  Drop Shadow                     │
// └──────────────────────────────────┘
// Single tap. Visible through transparent areas — adds depth at sprite edges.
// Default 1.0/1.0 = smallest visible diagonal shift. Set opacity to 0 to disable.
#pragma parameter PT_SHADOW_OFFSET_X "== Shadow X offset" 1.0 -30.0 30.0 0.5
#pragma parameter PT_SHADOW_OFFSET_Y "     ↳ Shadow Y offset" 1.0 -30.0 30.0 0.5
#pragma parameter PT_SHADOW_OPACITY  "     ↳ Shadow opacity (0=OFF)" 0.30 0.0 1.0 0.01

// ┌──────────────────────────────────┐
// │  Post-Blend Effects              │
// └──────────────────────────────────┘
// Chromatic shift — simulates R/B channel misalignment of original LCD panels.
// Pure UV math — zero extra texture samples. Set to 0 to disable.
#pragma parameter PT_CHROMA "== Chromatic shift amount (0=OFF)" 0.20 0.0 1.0 0.01
// Vignette — darkens edges/corners. Pure math — no extra texture samples.
#pragma parameter PT_VIGNETTE "== Vignette strength (0=OFF)" 0.08 0.0 1.0 0.01

// ╔══════════════════════════════════════════════════════════════╗
// ║  VERTEX SHADER                                               ║
// ╚══════════════════════════════════════════════════════════════╝
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
COMPAT_ATTRIBUTE vec4 COLOR;
COMPAT_ATTRIBUTE vec4 TexCoord;
COMPAT_VARYING   vec4 TEX0;
COMPAT_VARYING   vec2 InvTextureSize;

uniform mat4 MVPMatrix;
uniform COMPAT_PRECISION int  FrameDirection;
uniform COMPAT_PRECISION int  FrameCount;
uniform COMPAT_PRECISION vec2 OutputSize;
uniform COMPAT_PRECISION vec2 TextureSize;
uniform COMPAT_PRECISION vec2 InputSize;

void main()
{
    gl_Position    = MVPMatrix * VertexCoord;
    TEX0.xy        = TexCoord.xy;
    InvTextureSize = 1.0 / TextureSize;
}

// ╔══════════════════════════════════════════════════════════════╗
// ║  FRAGMENT SHADER                                             ║
// ╚══════════════════════════════════════════════════════════════╝
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

uniform COMPAT_PRECISION int  FrameDirection;
uniform COMPAT_PRECISION int  FrameCount;
uniform COMPAT_PRECISION vec2 OutputSize;
uniform COMPAT_PRECISION vec2 TextureSize;
uniform COMPAT_PRECISION vec2 InputSize;

// OrigTexture aliased to Texture — will be updated when NextUI adds OrigTexture support.
uniform sampler2D Texture;
#define Source Texture

COMPAT_VARYING vec4 TEX0;
COMPAT_VARYING vec2 InvTextureSize;

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
uniform COMPAT_PRECISION float PT_CHROMA;
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
#define PT_DARK_FILTER_LEVEL  10.0
#define PT_PIXEL_BORDER       1.0
#define PT_SHADOW_OFFSET_X    2.0
#define PT_SHADOW_OFFSET_Y    2.0
#define PT_SHADOW_OPACITY     0.30
#define PT_CHROMA             0.20
#define PT_VIGNETTE           0.08
#endif

// ┌──────────────────────────────────┐
// │  Constants                       │
// └──────────────────────────────────┘
// Perceptual luma weights — ITU-R BT.709
#define LUMA_R 0.2126
#define LUMA_G 0.7152
#define LUMA_B 0.0722

// Sine-wave pixel border constant
#define PI 3.141592654
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
    return (PT_BRIGHTNESS_MODE < 0.5) ? simpleBrightness(c) : perceptualBrightness(c);
}

// ┌──────────────────────────────────┐
// │  White Detection                 │
// └──────────────────────────────────┘

// Resolve system preset to detection threshold.
// Thresholds pre-compensated for post-processing detection on NextUI.
//   GB: 0.58   GBC: 0.65   GBA SP: 0.42   GBA Orig: 0.38   Manual: PT_SENSITIVITY
// GBA Original threshold is estimated from the SP offset pattern — verify
// with PT_SYSTEM = 0 (Manual) and PT_SENSITIVITY if results seem off.
float resolveThreshold()
{
    if (PT_SYSTEM < 0.5)  return PT_SENSITIVITY; // Manual
    if (PT_SYSTEM < 1.5)  return 0.58;           // GB
    if (PT_SYSTEM < 2.5)  return 0.65;           // GBC
    if (PT_SYSTEM < 3.5)  return 0.42;           // GBA SP
    return 0.38;                                  // GBA Original
}

// Dual-channel ratio method: pixel must be both bright AND neutral.
// Naturally rejects pixels that are bright due to color correction processing,
// which tends to produce uneven channel values. Zero extra texture samples.
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
// Scales dark colors toward black proportional to luma.
// Bright pixels are largely unaffected.
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

// Hash from simpletex_lcd reference shader.
// Single fract/dot/fract — equivalent grain quality at roughly half the
// arithmetic cost of the previous 4-tap interpolated hash.
float noiseHash(vec2 p)
{
    vec3 p3 = fract(vec3(p.xyx) * 0.1031);
    p3 += vec3(dot(p3, p3.yzx + 33.33));
    return fract((p3.x + p3.y) * p3.z);
}

vec3 proceduralBackground(vec2 uv)
{
    vec2  p      = uv * 256.0;
    float grain  = noiseHash(p) * 0.5 + noiseHash(p * 2.0) * 0.25;
    float offset = (grain - 0.375) * 0.065;
    return vec3(0.478 + offset);
}

// ┌──────────────────────────────────┐
// │  Blend                           │
// └──────────────────────────────────┘

// Hue-preserving blend: blends luminance only, rescales RGB by luminance
// ratio to preserve hue and saturation. Prevents GBC/GBA colours from
// greying out as they become semi-transparent.
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

// Sine-wave method. Works correctly at any scale mode — aspect, integer, custom.
// fract() wraps imgPixelCoord to 0..1 per texel before multiplying by 2*PI,
// keeping sin() arguments small and precise on mediump (PowerVR).
float pixelBorderFactor(vec2 coord)
{
    if (PT_PIXEL_BORDER < 0.5) return 1.0;

    vec2 imgPixelCoord = fract(coord * TextureSize);
    vec2 angle = 2.0 * PI * (imgPixelCoord - 0.25);

    float wfactor, strength;
    if (PT_PIXEL_BORDER < 1.5) {
        wfactor  = 1.0 + (BORDER_WIDTH_FACTOR_MAX - (0.80 * BORDER_WIDTH_FACTOR_MAX));
        strength = 0.40; // Subtle   — 17% border darkening
    } else if (PT_PIXEL_BORDER < 2.5) {
        wfactor  = 1.0 + (BORDER_WIDTH_FACTOR_MAX - (0.90 * BORDER_WIDTH_FACTOR_MAX));
        strength = 0.65; // Moderate — 41% border darkening
    } else {
        wfactor  = 1.0 + (BORDER_WIDTH_FACTOR_MAX - (0.97 * BORDER_WIDTH_FACTOR_MAX));
        strength = 0.85; // Strong   — 76% border darkening
    }

    float yfactor    = (wfactor + sin(angle.y)) / (wfactor + 1.0);
    float xfactor    = (wfactor + sin(angle.x)) / (wfactor + 1.0);
    float lineWeight = 1.0 - (yfactor * xfactor);

    return 1.0 - lineWeight * strength;
}

// ┌──────────────────────────────────┐
// │  Post-Blend Effects              │
// └──────────────────────────────────┘

// Chromatic shift — pure UV math, zero extra taps.
vec3 applyChromaShift(vec3 color, vec2 coord)
{
    if (PT_CHROMA < 0.001) return color;
    vec2 offset = (coord - 0.5) * PT_CHROMA * 0.02;
    float r = mix(color.r, color.r * (1.0 + offset.x), 0.5);
    float b = mix(color.b, color.b * (1.0 - offset.x), 0.5);
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
    // Sample current pixel — snap to texel center to avoid filtering artifacts
    vec2 imgPixelCoord  = TEX0.xy * TextureSize;
    vec2 imgCenterCoord = floor(imgPixelCoord) + vec2(0.5);
    vec4 lcd   = COMPAT_TEXTURE(Source, imgCenterCoord * InvTextureSize);
    vec3 pixel = lcd.rgb;

    // Color harshness filter
    if (PT_DARK_FILTER_LEVEL > 0.5) {
        pixel   = applyDarkFilter(pixel, PT_DARK_FILTER_LEVEL);
        lcd.rgb = pixel;
    }

    // Resolve per-system detection threshold
    float threshold = resolveThreshold();
    float isWhite   = isWhitePixel(pixel, threshold);

    // ------------------------------------------------------------------
    // Build procedural backing texture with optional palette tint.
    // Computed unconditionally — matches reference shader pattern.
    // Dynamic branching on per-pixel data causes branch divergence on
    // PowerVR, which can be slower than always running the code.
    // ------------------------------------------------------------------
    vec3 bg = proceduralBackground(TEX0.xy);

    if (PT_PALETTE > 0.5) {
        vec3 tint;
        if (PT_PALETTE < 1.5) {
            tint = vec3(0.651, 0.675, 0.518); // Pocket: warm green-grey
        } else if (PT_PALETTE < 2.5) {
            tint = vec3(0.737, 0.737, 0.737); // Grey
        } else {
            tint = vec3(1.0,   1.0,   1.0  ); // White
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

    // ------------------------------------------------------------------
    // Drop shadows — only cast through pixels that will be transparent.
    // Shadow offset uses InvTextureSize — proven on NextUI.
    // ------------------------------------------------------------------
    float willBeTransparent = 0.0;
    if (PT_PIXEL_MODE < 0.5) {
        willBeTransparent = isWhite;
    } else if (PT_PIXEL_MODE < 1.5) {
        willBeTransparent = step(threshold * 0.9, getBrightness(pixel));
    } else {
        willBeTransparent = 1.0;
    }

    if (willBeTransparent > 0.5 && PT_SHADOW_OPACITY > 0.001) {
        // Single tap shadow — one sample at the offset position.
        // No blur: at GB/GBC/GBA pixel scales, shadow edge softening is
        // imperceptible at any typical display resolution — verified on
        // 1024x768. Single tap matches the cost floor of the reference shaders.
        // No white gate — if behind-pixel is white, shadowStrength ~ 0 and
        // bg is unchanged. The math self-regulates.
        // Scale shadow offset proportionally to output scale so it appears
        // consistent regardless of how much the source frame is scaled up.
        float shadow_sx  = OutputSize.x / InputSize.x;
        float shadow_sy  = OutputSize.y / InputSize.y;
        float shadow_scale = sqrt(shadow_sx * shadow_sy);
        vec2 shadowPos   = TEX0.xy + vec2(-PT_SHADOW_OFFSET_X, -PT_SHADOW_OFFSET_Y) * InvTextureSize * shadow_scale;
        float shadowDark     = 1.0 - getBrightness(COMPAT_TEXTURE(Source, shadowPos).rgb);
        float shadowStrength = (shadowDark * shadowDark) * PT_SHADOW_OPACITY;

        bg = mix(bg, bg * 0.2, shadowStrength);
    }

    // ------------------------------------------------------------------
    // Transparency blend
    // ------------------------------------------------------------------
    vec3 result = pixel;

    if (PT_PIXEL_MODE < 0.5) {
        if (isWhite > 0.5) {
            float intensity = getBrightness(pixel);
            float alpha     = clamp((intensity / 3.0) + PT_BASE_ALPHA, 0.0, 1.0);
            alpha           = max(alpha, PT_WHITE_TRANSPARENCY);
            result          = huePreservingBlend(pixel, bg, alpha);
        }
    } else if (PT_PIXEL_MODE < 1.5) {
        float intensity = getBrightness(pixel);
        float alpha     = clamp(PT_BASE_ALPHA * intensity * 2.4, 0.0, 1.0);
        if (isWhite > 0.5) alpha = max(alpha, PT_WHITE_TRANSPARENCY);
        result = huePreservingBlend(pixel, bg, alpha);
    } else {
        float intensity = getBrightness(pixel);
        float alpha     = clamp((intensity / 3.0) + PT_BASE_ALPHA, 0.0, 1.0);
        if (isWhite > 0.5) alpha = max(alpha, PT_WHITE_TRANSPARENCY);
        result = huePreservingBlend(pixel, bg, alpha);
    }

    result  = result * pixelBorderFactor(TEX0.xy);
    result  = applyChromaShift(result, TEX0.xy);
    result  = applyVignette(result, TEX0.xy);

    FragColor = vec4(result, lcd.a);
}
#endif
