#ifndef INFINITE_OCEAN_COMMON_INCLUDED
#define INFINITE_OCEAN_COMMON_INCLUDED

struct Attributes
{
    float4 positionOS : POSITION;
    float3 normalOS : NORMAL;
    float4 tangentOS : TANGENT;
    float2 texcoord : TEXCOORD0;
    float4 color : COLOR;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings
{
    float4 positionHCS : SV_POSITION;
    float2 uv : TEXCOORD0;
    float3 positionWS : TEXCOORD1;
    float3 normalWS : TEXCOORD2;
    UNITY_VERTEX_INPUT_INSTANCE_ID
    UNITY_VERTEX_OUTPUT_STEREO
};

TEXTURE2D(_BaseMap);
SAMPLER(sampler_BaseMap);
CBUFFER_START(UnityPerMaterial)
float4 _BaseMap_ST;
//Tesselation
half _TesselationMaxDistance;
half _TesselationMaxDisplace;
half _TesselationFactor;
//Wave
uint _GerstnerWaveCount;
half4 _GerstnerWaveData[10]; // 0-9 amplitude, direction, wavelength ,0
CBUFFER_END

#endif
