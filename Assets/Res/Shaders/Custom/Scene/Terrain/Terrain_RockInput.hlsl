
TEXTURE2D(_MainTex);          SAMPLER(sampler_MainTex);
TEXTURE2D(_BaseMap);          SAMPLER(sampler_BaseMap);
TEXTURE2D(_BumpMap);          SAMPLER(sampler_BumpMap);
TEXTURE2D(_MixMap);           SAMPLER(sampler_MixMap);
TEXTURE2D(_Bump2Map);         SAMPLER(sampler_Bump2Map);
TEXTURE2D(_Mix2Map);          SAMPLER(sampler_Mix2Map);

TEXTURE2D(_HugeMap);         SAMPLER(sampler_HugeMap);

TEXTURE2D(_MainColorTex);
TEXTURE2D(_Color2Map);

#include "../../Library/DetailTexture.hlsl"

#if !defined(INSTANCING_ON)
    CBUFFER_START(UnityPerMaterial)
#endif

half _ColorMix;

half4 _MainTex_ST;
half _BumpScale0;

half _Slope;
half _SlopeFade;
half3 _UPNormal;

half4 _BaseMap_ST;
half4 _Color;
half _BumpScale;
half _Metallic;
half _Smoothness;

half4 _Color2;
half4 _Color2Map_ST;
half _BumpScale2;
half _Metallic2;
half _Smoothness2;

half _EnableHuge;
half4 _HugeMap_ST;
half _HugeStrength;

half _VTFade;
half _VTFade2;

#include "../../Library/DetailInput.hlsl"

#if !defined(INSTANCING_ON)
    CBUFFER_END
#endif