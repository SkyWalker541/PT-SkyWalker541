# PT-SkyWalker541 v2.0.0

> [!IMPORTANT]
> ### What's new in v2.0.0
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

*PT-SkyWalker541 by SkyWalker541 | v2.0.0 | RetroArch and NextUI*