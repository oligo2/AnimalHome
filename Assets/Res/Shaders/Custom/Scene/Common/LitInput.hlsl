TEXTURE2D(_BaseMap);          SAMPLER(sampler_BaseMap);
TEXTURE2D(_BumpMap);          SAMPLER(sampler_BumpMap);
TEXTURE2D(_MixMap); 		  SAMPLER(sampler_MixMap);
TEXTURE2D(_DepthMap); 		  SAMPLER(sampler_DepthMap);

CBUFFER_START(UnityPerMaterial)
half4 _BaseMap_ST;
half  _Metallic;
half  _Smoothness;
half4 _BaseColor;

half4 _EmissionColor;
half  _EnableEmission;

half _Depth;

half _Clip;
half _EnableTurnNormal;
half _EnableParallax;


half  _Lod;
CBUFFER_END
