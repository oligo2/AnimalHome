TEXTURE2D(_BaseMap);          SAMPLER(sampler_BaseMap);
TEXTURE2D(_BumpMap);          SAMPLER(sampler_BumpMap);
TEXTURE2D(_MixMap); 		  SAMPLER(sampler_MixMap);
TEXTURE2D(_SplatMap); 		  SAMPLER(sampler_SplatMap);
TEXTURE2D(_FurMap); 		  SAMPLER(sampler_FurMap);

CBUFFER_START(UnityPerMaterial)
half4 _BaseMap_ST;
half4 _FurMap_ST;

half  _Metallic;
half  _Smoothness;
half4 _BaseColor;

half _EnableFur;
float _FurLength;
float3 _FurDir;
float _FurDirStrength;
half _FurRootDarknessPower;
half4 _FurRootDarknessColor;
half _FurShape;
half4 _KKColor;
half _KKShift;
half _KKExponent;

half _EnableParallax;
half _Depth;
half _ParallaxSampleTime;
half _ParallaxDetailTime;
half _DepthShadowIntensity;
half _DepthShadowSampleTime;

float _TessCount;

half  _Lod;
CBUFFER_END

float _LayerLength;