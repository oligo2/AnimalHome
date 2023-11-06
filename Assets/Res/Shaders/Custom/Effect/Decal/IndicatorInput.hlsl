TEXTURE2D(_MainTex);               SAMPLER(sampler_MainTex);
// TEXTURE2D(_CameraDepthTexture);   SAMPLER(sampler_CameraDepthTexture);
TEXTURE2D(_CameraDepth2Texture);   SAMPLER(sampler_CameraDepth2Texture);

CBUFFER_START(UnityPerMaterial)
float4 _MainTex_ST;

float _ProjectionAngleCut;
float _ProjectionAngleAlpha;
float _AlphaInAngle;

//arrow
half4 _Color;
half _Intensity;
half _AlphaInCover;

half4 _FlowColor;
half _Duration;

//circle
float _Angle;
half _Outline;
half _OutlineAlpha;
half _FlowFade;
CBUFFER_END
