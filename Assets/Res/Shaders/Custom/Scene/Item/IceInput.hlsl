TEXTURE2D(_BaseMap);          SAMPLER(sampler_BaseMap);
TEXTURE2D(_BumpMap);          SAMPLER(sampler_BumpMap);
TEXTURE2D(_InsideMap); 		  SAMPLER(sampler_InsideMap);
TEXTURE2D(_HeatMap); 		  SAMPLER(sampler_HeatMap);
TEXTURE2D(_SolidMap); 		  SAMPLER(sampler_SolidMap);

sampler2D _CameraOpaqueTexture;

#if !defined(INSTANCING_ON)
    CBUFFER_START(UnityPerMaterial)
#endif

half4 _BaseMap_ST;
half4 _BaseColor;
half _Depth;
half _Alpha;

half _HeatIntensity;

half4 _SolidMap_ST;
half3 _SolidColor;
float4 _VertexRange;

half4 _InsideMap_ST;
half _InsideDepth;
half3 _InsideColor;

half _EnableAutoSolidUV;
half _EnableSolid;
half _EnableInside;

half  _Lod;

#if !defined(INSTANCING_ON)
    CBUFFER_END
#endif

