# SWTOR Garment Shader

Because we currently only got 4 Textures for Shaders, we cant process the entire thing in one.

Split system:

1. Step:
`_d`, `_m`, `_h` -> Diffuse Color

2. Step:
`_d`, `_s`, `_m`, `_h` -> Specular Color

2. Step
`1 output`, `2 output`,  `_n` -> Final Outcum

# Material Data Structure
Step 1:
    Palatte 1: `c0`
    Palette 2: `c1`

Step 2:
    Palatte 1:
        `c0`: specular
        `c1`: metallic specular
    Palette 2:
        `c2`: specular
        `c3`: metallic specular