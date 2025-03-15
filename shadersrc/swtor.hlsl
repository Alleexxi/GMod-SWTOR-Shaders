// idk

float3 RGBAtoHSL(float4 color)
{
    float h_1 = color.g * (0.706 - 0.314) + 0.314;
    float h_2 = h_1 - 0.412;

    float H = h_2;
    float S = color.b * 0.588;
    float L = color.a * 0.706;

    float3 result;

    result.r = H;
    result.g = S;
    result.b = L;

    return result;
};

float3 HUEtoRGB(in float H)
{
    float R = abs(H * 6 - 3) - 1;
    float G = 2 - abs(H * 6 - 2);
    float B = 2 - abs(H * 6 - 4);
    return saturate(float3(R,G,B));
}

float3 HSLtoRGB(in float3 HSL)
{
    float3 RGB = HUEtoRGB(HSL.x);
    float C = (1 - abs(2 * HSL.z - 1)) * HSL.y;
    return (RGB - 0.5) * C + HSL.z;
}

struct Palette {
    float hue;
    float saturation;
    float brightness;
    float contrast;
    float3 specular;
    float3 metallic_specular;
};


// Chosen Palette
Palette ChosenPalette(float4 _mColor, Palette paletteOne, Palette paletteTwo)
{
    float should_mask_paletteTwo = _mColor.r < _mColor.g;
    float should_mask_paletteOne = should_mask_paletteTwo < 1.0;

    Palette tempOne = paletteOne;
    Palette tempTwo = paletteTwo;

    // Apply masks
    tempOne.hue *= should_mask_paletteOne;
    tempOne.saturation *= should_mask_paletteOne;
    tempOne.brightness *= should_mask_paletteOne;
    tempOne.contrast *= should_mask_paletteOne;
    tempOne.specular *= should_mask_paletteOne;
    tempOne.metallic_specular *= should_mask_paletteOne;

    tempTwo.hue *= should_mask_paletteTwo;
    tempTwo.saturation *= should_mask_paletteTwo;
    tempTwo.brightness *= should_mask_paletteTwo;
    tempTwo.contrast *= should_mask_paletteTwo;
    tempTwo.specular *= should_mask_paletteTwo;
    tempTwo.metallic_specular *= should_mask_paletteTwo;

    Palette result;

    result.hue = tempTwo.hue + tempOne.hue;
    result.saturation = tempTwo.saturation + tempOne.saturation;
    result.brightness = tempTwo.brightness + tempOne.brightness;
    result.contrast = tempTwo.contrast + tempOne.contrast;
    result.specular = tempTwo.specular + tempOne.specular;
    result.metallic_specular = tempTwo.metallic_specular + tempOne.metallic_specular;

    return result;
};

float4 MixShader(float4 shaderA, float4 shaderB, float factor)
{
    return lerp(shaderA, shaderB, factor);
}

float3 GammaCorrection(float3 color, float gamma)
{
    return pow(color, 1.0 / gamma);
}

struct HuePixelData
{
    float4 diffuse_color;
    float4 specular_color;
};