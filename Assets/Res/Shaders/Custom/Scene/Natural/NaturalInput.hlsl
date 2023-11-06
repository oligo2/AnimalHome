TEXTURE2D(_BaseMap);          SAMPLER(sampler_BaseMap);
TEXTURE2D(_BumpMap);          SAMPLER(sampler_BumpMap);
TEXTURE2D(_MixMap);           SAMPLER(sampler_MixMap);

TEXTURE2D(_TileColorMap);     SAMPLER(sampler_TileColorMap);

sampler2D _CameraDepthTexture;
sampler2D _WindMap; 

#if !defined(INSTANCING_ON)
    CBUFFER_START(UnityPerMaterial)
#endif

float4 _BaseMap_ST;
float4 _TileColorMap_ST;

float _Smoothness;

half _SpecularPower;

half3 _BaseColor;
half3 _SpecularColor;
half3 _TopColor;

float _Clip;
half _ShadowBright;
half _BackBright;
half _OcclusionForBright;

float4 _WindMap_ST;
half3 _WindColor;
float _WindSpeed;
float4 _WindDirection;
float _SwingingRange;
float _SwingingRhythm;

half4 _EmissionColor;
half _EnableEmission;

half _VTFade;

float _ScatteringStrength;
half3 _ScatteringColor;


half _EnableTurnNormal;
half _EnableShadow;
half _EnableTileColor;
half _EnableVT;
half _EnableScattering;
half _EnableShowVertexColor;
half _EnableInteractive;
half _EnableInteractiveWhole;

float _InteractivePow;


#if !defined(INSTANCING_ON)
    CBUFFER_END
#endif
