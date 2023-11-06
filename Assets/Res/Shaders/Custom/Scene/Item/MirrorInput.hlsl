TEXTURE2D(_BaseMap);          SAMPLER(sampler_BaseMap);
TEXTURE2D(_BumpMap);          SAMPLER(sampler_BumpMap);
TEXTURE2D(_MixMap);           SAMPLER(sampler_MixMap);
TEXTURE2D(_PlanarReflectionTexture);

float4x4 KWS_CameraProjectionMatrix;// 很奇怪 这个不能放到cbuffer里

#if !defined(INSTANCING_ON)
    CBUFFER_START(UnityPerMaterial)
#endif

half4 _BaseMap_ST;
half4 _BaseColor;

half _Metallic;
half _Smoothness;
half _NormalMul;
half _Reflection;

half4 _EmissionColor;
half  _EnableEmission;

float2 _MirrorReplaceParam;
half3 _MirrorReplaceSkyColor;
half3 _MirrorReplaceTintColor;



#if !defined(INSTANCING_ON)
    CBUFFER_END
#endif
