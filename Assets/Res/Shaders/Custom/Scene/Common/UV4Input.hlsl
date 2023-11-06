TEXTURE2D(_BaseMap);          SAMPLER(sampler_BaseMap);
TEXTURE2D(_BumpMap);          SAMPLER(sampler_BumpMap);
TEXTURE2D(_MixMap); 		  SAMPLER(sampler_MixMap);

TEXTURE2D(_Base2Map);         SAMPLER(sampler_Base2Map);
TEXTURE2D(_Bump2Map);         SAMPLER(sampler_Bump2Map);
TEXTURE2D(_Mix2Map); 		  SAMPLER(sampler_Mix2Map);

#if defined(UV4)
    TEXTURE2D(_Bump3Map);         SAMPLER(sampler_Bump3Map);
#endif

#if !defined(INSTANCING_ON)
    CBUFFER_START(UnityPerMaterial)
#endif
half4 _BaseMap_ST;
half4 _BaseColor;
half _Metallic;
half _Smoothness;

half4 _BaseColor2;
half _Metallic2;
half _Smoothness2;


half4 _EmissionColor;
half4 _EmissionColor2;

half _EnableEmission;
half _Clip;
half _Lod;
#if !defined(INSTANCING_ON)
    #include "../../Library/FeverDecalInput.hlsl"
    CBUFFER_END
#endif


