TEXTURE2D(_BaseMap);          SAMPLER(sampler_BaseMap);
TEXTURE2D(_BumpMap);          SAMPLER(sampler_BumpMap);
TEXTURE2D(_MixMap); 		  SAMPLER(sampler_MixMap);
TEXTURE2D(_MacroMap); 		  SAMPLER(sampler_MacroMap);

#if !defined(INSTANCING_ON)
    CBUFFER_START(UnityPerMaterial)
#endif
half4 _BaseMap_ST;
half  _Metallic;
half  _Smoothness;
half4 _BaseColor;

half4 _EmissionColor;
half  _EnableEmission;
half _VTFade;

half  _Lod;
#if !defined(INSTANCING_ON)
    CBUFFER_END
#endif
