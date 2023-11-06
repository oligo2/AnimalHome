TEXTURE2D(_BaseMap);          SAMPLER(sampler_BaseMap);
TEXTURE2D(_BumpMap);          SAMPLER(sampler_BumpMap);
TEXTURE2D(_MixMap); 		  SAMPLER(sampler_MixMap);
TEXTURE2D(_WindowMask);       SAMPLER(sampler_WindowMask);

#if !defined(INSTANCING_ON)
    CBUFFER_START(UnityPerMaterial)
#endif
half4 _BaseMap_ST;
half  _Metallic;
half  _Smoothness;
half4 _BaseColor;

half4 _BumpMap_ST;

half4 _WindowMask_ST;
half  _IsProtal;
half3 _DayColor;
half3 _NightColor;
half  _SkyWeight;
half2 _LightTime;
half  _GlobalTime;

half4 _EmissionColor;
half  _EnableEmission;

half  _Lod;
half  TimeControl_Time;

#if !defined(INSTANCING_ON)
    CBUFFER_END
#endif

