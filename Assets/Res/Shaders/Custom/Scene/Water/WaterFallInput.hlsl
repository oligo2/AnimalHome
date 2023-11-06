TEXTURE2D(_BaseMap);         SAMPLER(sampler_BaseMap);
TEXTURE2D(_BumpMap);         SAMPLER(sampler_BumpMap);
TEXTURE2D(_SideMap);         SAMPLER(sampler_SideMap);
TEXTURE2D(_FogMap);         SAMPLER(sampler_FogMap);

sampler2D _VertexChangeMap;
sampler2D _CameraDepth2Texture;

#if !defined(INSTANCING_ON)
    CBUFFER_START(UnityPerMaterial)
#endif

half4 _BaseMap_ST;
half4 _BaseColor;
half _Alpha;

half _Speed1;
half _Speed2;

half _DepthChange;

float _Tilling1;
float _Tilling2;
float _Tilling3;
float _Scale;

half _FogSpeed;
half _FogStrength;

float _Tilling0;
half _Speed0;
half _VertexChangeStrength;

half _ShadowBright;
half _BackBright;
half _DepthFadeIndensity;


half  _Lod;
#if !defined(INSTANCING_ON)
    CBUFFER_END
#endif
