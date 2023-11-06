TEXTURE2D(_BaseMap);    SAMPLER(sampler_BaseMap);
TEXTURE2D(_RedMap);		SAMPLER(sampler_RedMap);
TEXTURE2D(_GreenMap);	SAMPLER(sampler_GreenMap);
TEXTURE2D(_BlurMap);	SAMPLER(sampler_BlurMap);
TEXTURE2D(_OriginMap);	SAMPLER(sampler_OriginMap);

#if !defined(INSTANCING_ON)
    CBUFFER_START(UnityPerMaterial)
#endif

half4 _BaseMap_ST;
half4 _BaseColor;

half _SmoothnessOrigin;
half _SmoothnessRed;
half _SmoothnessGreen;
half _SmoothnessBlur;

half _ScaleOrigin;
half _ScaleRed;
half _ScaleGreen;
half _ScaleBlur;

half _BaseAndRedRatio;
// half _BlurAndGreenRatio;
half _Transit;

half _EnableShowVertexColor;
half _EnableGreen;
half _EnableBlur;

#if !defined(INSTANCING_ON)
    // #include "../../Library/FeverDecalInput.hlsl"
    CBUFFER_END
#endif