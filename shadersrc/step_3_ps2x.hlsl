#include "common.hlsl"
#include "swtor.hlsl"

float4 main( PS_INPUT i ) : COLOR
{
    // Diffuse Color
    float4 diffuse = tex2D(TexBase, i.uv.xy);
    
    // specular color
    float4 specular = tex2D(Tex1, i.uv.xy);

    // rotationmap
    float4 rotationmap = tex2D(Tex1, i.uv.xy);

    return diffuse;
};