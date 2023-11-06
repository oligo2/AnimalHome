TEXTURE2D(_BaseMap);          SAMPLER(sampler_BaseMap);
TEXTURE2D(_BumpMap);          SAMPLER(sampler_BumpMap);
TEXTURE2D(_MixMap); 		  SAMPLER(sampler_MixMap);
TEXTURE2D(_InsideMap); 		  SAMPLER(sampler_InsideMap);
TEXTURE2D(_InsideMap2);       SAMPLER(sampler_InsideMap2);
TEXTURE2D(_InsideMask); 	  SAMPLER(sampler_InsideMask);

#if !defined(INSTANCING_ON)
    CBUFFER_START(UnityPerMaterial)
#endif
half4 _BaseMap_ST;
half  _Metallic;
half  _Smoothness;
half4 _BaseColor;

half4 _BumpMap_ST;

half4 _InsideMap_ST;
half4 _InsideMap2_ST;
half _InsideOpacity;
half _InsideDepth;
half3 _InsideColor;

half _FresnelPower;
half3 _FresnelColor;

half4 _EmissionColor;
half  _EnableEmission;

half  _Lod;

#if !defined(INSTANCING_ON)
    CBUFFER_END
#endif

