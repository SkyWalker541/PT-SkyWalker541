# PT-SkyWalker541 v2.1.0

> [!IMPORTANT]
> ### What's new in v2.1.0
>
> A feature release. It adds one new, **optional** feature: **Glare and sheen**. It is **Off by default**, so with its default settings the picture is identical to v2.0.1. No parameter was renamed, removed or changed, so settings saved with v2.0.x keep working. Just replace the shader file.
>
> * **Glare and sheen:** a soft hotspot of light (glare) and a faint rainbow tint in bands (sheen) around a light point, like sunlight catching a Game Boy screen. It is drawn on the screen's backing material only: the transparent areas, and the grid lines or dot gaps when *Gap color* is Backing.
> * **It is a matter of taste.** Set **== Glare and sheen ==** to 1 to try it and adjust the settings to your liking. Set it back to 0 and the whole feature is completely off. It is not part of the Recommended Settings.
> * **11 new parameters** (31 in total), placed under *Backing color* in the menu:
>     * *Glare strength* and *Glare spread*: how bright and how large the hotspot is.
>     * *Sheen strength*, *Sheen band density* and *Sheen hue turn*: how strong the rainbow tint is, how many bands there are, and which colors they show.
>     * *Sheen ripple* and *Sheen ripple size*: make the bands uneven, like uneven film (0 = smooth bands).
>     * *Light home, left to right* and *Light home, top to bottom*: where the light sits.
>     * *Light drift speed*: how fast the light wanders around its home position (0 = it stays at home).
> * **No tilt input:** there is no sensor support in GLSL, so the light is moved by the shader over time, or held still.
> * **Cost:** with the feature Off the extra cost is one check per pixel. With it On the cost has not been measured on specific devices, so on a low-power handheld compare with it On and Off, and turn it off if you see slowdown. The light position is worked out in the vertex shader, which adds one varying (4 in total).
> * **Full descriptions** of every new parameter are in `README_GLSL.md` and the main `README.md`.
>
> ### Changes in v2.0.1 (still included)
>
> A fix release.
>
> * **Parameters missing on some Android RetroArch builds:** the *Shadow direction* menu label was longer than RetroArch's 63-character limit for parameter labels. On builds that enforce the limit, the shader's parameters did not appear at all. The label is now shorter.
> * **GLES3 fix:** the fragment shader declared its output before the precision statement, which GLSL ES 3.00 (GLES3) rejects. The order is fixed, and the shader now compiles under both GLSL ES 1.00 and 3.00.
>
> ### Changes in v2.0.0 (still included)
>
> A major release. One shader file now serves both **RetroArch and NextUI** — there is no longer a separate NextUI build or NextUI readme.
>
> **Upgrading from 1.x:** parameter code names changed, so saved shader presets and parameter overrides from 1.x fall back to the default values. Re-save your settings after updating. The old-to-new name table is in `README_GLSL.md`.

* **CRT Phosphor removed:** it does not apply to the reflective LCD systems this shader targets. Pixel Effect now has three modes: **Off, Grid, and LCD Dot**.
* **New menu layout:** every group has a `== Name ==` main row with its settings indented beneath it. Effect-specific rows are tagged **[Grid]**, **[LCD Dot]** or **[Grid+Dot]**, so it is obvious what each parameter affects.
* **Plain-language names:** every menu label now says what the setting does, and the code names match the labels.
* **Grid reworked:** *Grid line width* is now a real line thickness (a fraction of one game pixel), and Grid has its own *Grid line opacity*.
* **LCD Dot reworked:** *Dot edge softness* sets how soft the edge of each dot is (0 = hard, 1 = soft), and LCD Dot has its own *Dot gap opacity*. The old shared *Gap / Grid color intensity* setting is gone.
* **Backing gap fix:** with *Gap color* set to Backing, the gaps around non-white pixels in White mode used to render black. They now use the real backing color.
* **Better low-end compatibility:** the vertex shader passes 3 varyings instead of 8, the source is pure ASCII, a zero-width `smoothstep` was guarded, and the fallback defaults now match the parameter defaults. This targets devices where the shader previously appeared in the pass list but showed no parameters and had no effect.
* **New defaults** (tuned on a GBC): Game system GBC, Transparent pixels All, Transparency amount 0.10, Backing color strength 2.00, Grid line width 0.25, Grid line opacity 0.50, Dot size 0.90, Dot gap opacity 0.50.

---

## Downloads

This release ships three separate archives:

| Archive | Contents |
| :--- | :--- |
| `PT-SkyWalker541-NextUI.zip` | `NextUI/Shaders/PT_SkyWalker541.cfg` and `NextUI/Shaders/glsl/PT_SkyWalker541.glsl` |
| `PT-SkyWalker541-Standard-RetroArch.zip` | `shaders_glsl/handheld/PT_SkyWalker541.glslp` and `shaders_glsl/handheld/shaders/PT_SkyWalker541.glsl` |
| `PT-SkyWalker541-README_GLSL.zip` | Just the `README_GLSL.md` documentation |

See **README_GLSL.md** for full documentation and recommended settings per system.

*PT-SkyWalker541 by SkyWalker541 | v2.1.0 | RetroArch and NextUI*