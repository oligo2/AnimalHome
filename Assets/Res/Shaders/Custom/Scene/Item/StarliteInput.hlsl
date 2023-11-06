TEXTURE2D(_BaseColorMap);      SAMPLER(sampler_BaseColorMap);
TEXTURE2D(_OcculusionMap);     SAMPLER(sampler_OcculusionMap);
TEXTURE2D(_NormalMap);         SAMPLER(sampler_NormalMap);
TEXTURE2D(_RefractMap);        SAMPLER(sampler_RefractMap);
TEXTURE2D(_ParallexMap);       SAMPLER(sampler_ParallexMap);
TEXTURE2D(_DetailNormalMap);   SAMPLER(sampler_DetailNormalMap);
TEXTURE2D(_FleckMap);          SAMPLER(sampler_FleckMap);

#if !defined(INSTANCING_ON)
    CBUFFER_START(UnityPerMaterial)
    float3 _Diffuse;
    float  _BumpScale;
    float3 _OcculusionColor;
    float3 _GradientColor0;
    float3 _GradientColor1;
    float  _GradientOffset;
    float3 _RefractColor;
    float  _ParallexOffset;
    float4 _RefractMap_ST;
    float  _RefractOpacity;
    float  _ShadowWeight;
    float4 _FleckMap_ST;
    float2 _FleckMove;
    float4 _DetailNormalMap_ST;
    float  _DetailNormalScale;
    float3 _SpecularColor;
    float  _SpecularShininess;
    float3 _FresnelColor;
    float  _FresnelPower;
    float3 _InLightColor;
    float  _InLightOffset;
    float  _InLightRange;
    float  _InLightPower;
    float2 _InLightMove;
    float  _InLightBreath;
    CBUFFER_END
#endif

