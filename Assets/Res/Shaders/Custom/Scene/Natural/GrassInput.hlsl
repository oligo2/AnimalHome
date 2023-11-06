TEXTURE2D(_BaseMap);          SAMPLER(sampler_BaseMap);
TEXTURE2D(_TileColorMap);     SAMPLER(sampler_TileColorMap);

sampler2D _WindMap; 

float4 _BaseMap_ST;
float4 _TileColorMap_ST;
float4 _WindMap_ST;

half3 _BaseColor;
float _Smoothness;
half _SpecularPower;
half3 _SpecularColor;
half _ShadowBright;
half _BackBright;


// half _OcclusionForBright;

half3 _WindColor;
float _WindSpeed;
float4 _WindDirection;
float _SwingingRange;
float _SwingingRhythm;


half _EnableVT;
half _VTFade;



half _EnableInteractive;
half _EnableInteractiveWhole;
float _InteractivePow;


float _Clip;
