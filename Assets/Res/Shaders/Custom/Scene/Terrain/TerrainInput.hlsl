TEXTURE2D(_BaseMap);          SAMPLER(sampler_BaseMap);
TEXTURE2D(_BaseMap2);          SAMPLER(sampler_BaseMap2);
TEXTURE2D(_BaseMap3);          SAMPLER(sampler_BaseMap3);


TEXTURE2D(_BumpMap);          SAMPLER(sampler_BumpMap);
TEXTURE2D(_MixMap); 		  SAMPLER(sampler_MixMap);
TEXTURE2D(_HighMap); 		  SAMPLER(sampler_HighMap);


CBUFFER_START(UnityPerMaterial)
half4 _BaseMap_ST;

half  _Metallic;
half  _Smoothness;
half4 _BaseColor;

half _EnableParallax;
half _Depth;
half _ParallaxSampleTime;
half _ParallaxDetailTime;
half _DepthShadowIntensity;
half _DepthShadowSampleTime;

float _TessCount;

float _High;

half  _Lod;
CBUFFER_END

float _LayerLength;