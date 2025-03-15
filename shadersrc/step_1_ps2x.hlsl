// Shader for applying dynamic color palettes to textures using a SWTOR-like approach

#include "common.hlsl"
#include "swtor.hlsl"

HuePixelData HuePixel(Palette palette, float4 _hColor, float4 _mColor, float4 _dColor, float4 _sColor)
{
    HuePixelData result;
    
    // Manipulate HSL
    // r = H; g = S; b = L;
    float3 ExpandHSL = RGBAtoHSL(_hColor);

    float Manipulate_H = frac(ExpandHSL.r + palette.hue);
    Manipulate_H = clamp(Manipulate_H, 0.0, 1.0);

    float Manipulate_S = pow(ExpandHSL.g, palette.saturation) * (1.0 - palette.saturation);
    Manipulate_S = clamp(Manipulate_S, 0.0, 1.0);

    float Manipulate_L = pow(ExpandHSL.b, palette.contrast) * palette.contrast;
    Manipulate_L = (1.0 - palette.brightness) * Manipulate_L;
    Manipulate_L = palette.brightness + Manipulate_L;
    // Manipulate HSL END

    // ManipulateAO
    float tmp_brightness_add = palette.brightness + 1.0;
    float ManipulateAO = clamp((tmp_brightness_add + ((1.0 - tmp_brightness_add) * _hColor.r)) * _hColor.r, 0.0, 1.0);
    // ManipulateAO END

    // Apply AO to L
    Manipulate_L = Manipulate_L * ManipulateAO;

    float4 RGBColor = float4(HSLtoRGB(float3(Manipulate_H, Manipulate_S, Manipulate_L)), 1.0);
    RGBColor = MixShader(_dColor, RGBColor, (_mColor.r + _mColor.g));
    //RGBColor = float4(GammaCorrection(RGBColor.rgb, 2.1), 1.0);

    result.diffuse_color = RGBColor;

    float4 MetalicSpecular = float4(1.0,1.0,1.0,1.0); // TODO: Get a way for more vars to set in vmt...

    // Calculate Specular Color, cant really use this because no glossmap.
    float mul_1 = (_mColor.b - 0.5) * 2;
    float mul_2 = _mColor.b * 2;

    float4 mix_One = MixShader(float4(1.0,1.0,1.0,1.0), MetalicSpecular, mul_1);
    float4 mix_Two = MixShader(float4(palette.specular, 1.0), float4(1.0,1.0,1.0,1.0), mul_2);

    float4 vecMulti_One = mix_One * (_mColor.b > 0.5);
    float4 vecMulti_Two = mix_Two * ((_mColor.b > 0.5) < 1.0);
    float4 vecAdd_One = vecMulti_One + vecMulti_Two;

    float4 vecMulti_Three = vecAdd_One * _sColor.r;

    result.specular_color = MixShader(_sColor, vecMulti_Three, (_mColor.r + _mColor.g));

    return result;
};


// entry point
float4 main( PS_INPUT i ) : COLOR
{
    // Diffuse - Main color texture
    float4 diffuse = tex2D(TexBase, i.uv.xy);
    
    // GlossMap
    float4 glossmap = tex2D(Tex1, i.uv.xy);

    // PaletteMap - AO and HSL data
    // R: Ambient Occlusion
    // G: Hue
    // B: Saturation
    // A: Lightness
    float4 palettemap = tex2D(Tex2, i.uv.xy);

    // PaletteMaskMap - Masking for dye regions
    // R: Palette1 mask for primary dye
    // G: Palette2 mask for secondary dye
    // B: MetallicMask
    float4 palettemaskmap = tex2D(Tex3, i.uv.xy);

    // Primary Pallete
    Palette paletteOne;

    paletteOne.hue               = Constants0.r;
    paletteOne.saturation        = Constants0.g;
    paletteOne.brightness        = Constants0.b;
    paletteOne.contrast          = Constants0.a;
    paletteOne.specular          = Constants1.rgb;
    paletteOne.metallic_specular = float3(1.0,1.0,1.0);

    // Secondary Pallete
    Palette paletteTwo;

    paletteTwo.hue               = Constants2.r;
    paletteTwo.saturation        = Constants2.g;
    paletteTwo.brightness        = Constants2.b;
    paletteTwo.contrast          = Constants2.a;
    paletteTwo.specular          = Constants3.rgb;
    paletteTwo.metallic_specular = float3(1.0,1.0,1.0);
    
    Palette palette_to_use = ChosenPalette(palettemaskmap, paletteOne, paletteTwo);

    HuePixelData test = HuePixel(palette_to_use, palettemap, palettemaskmap, diffuse, glossmap);

    return test.diffuse_color; 
}