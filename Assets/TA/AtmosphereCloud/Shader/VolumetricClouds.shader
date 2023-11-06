Shader "Weather/Clouds/Volumetric"
{//s
	Properties
	{
		
		//_uLightningContrast("_uLightningContrast", Range(0.0, 3.0)) = 3.0
		//_uMoonAttenuation("_uMoonAttenuation", Float) = 1.0

		//_uCloudsBottom("_uCloudsBottom", Float) = 1350.0
		//_uCloudsHeight("_uCloudsHeight", Float) = 2150.0

		//_uCloudsCoverage("_uCloudsCoverage", Range(0.0, 1.0)) = 0.52
		//_uCloudsCoverageBias("_uCloudsCoverageBias", Range(-1.0, 1.0)) = 0.0

		//_uAttenuation("_uAttenuation", Float) = 1.0
		//_uCloudsMovementSpeed("_uCloudsMovementSpeed", Range(0.0, 150)) = 20
		//_uCloudsTurbulenceSpeed("_uCloudsTurbulenceSpeed", Range(0.0, 50)) = 50.0

		//_uCloudsDetailStrength("_uCloudsDetailStrength", Range(0.0, 0.4)) = 0.2
		//_uCloudsBaseEdgeSoftness("_uCloudsBaseEdgeSoftness", Float) = 0.1
		//_uCloudsBottomSoftness("_uCloudsBottomSoftness", Float) = 0.25
		//_uCloudsDensity("_uCloudsDensity", Range(0.0, 1.0)) = 0.03
		//_uCloudsForwardScatteringG("_uCloudsForwardScatteringG", Float) = 0.8
		//_uCloudsBackwardScatteringG("_uCloudsBackwardScatteringG", Float) = -0.2


		//_uCloudsBaseScale("_uCloudsBaseScale", Float) = 1.51
		//_uCloudsDetailScale("_uCloudsDetailScale", Float) = 20.0
		//_uCurlScale("_uCurlScale", Float) = 20.0
		//_uCurlStrength("_uCurlStrength", Range(0.0, 2.5)) = 1.0

		//_uHorizonDarkness("_uHorizonDarkness", Range(0.0, 2.0)) = 1.0
		//_uHorizonFadeStart("_uHorizonFadeStart", Float) = -0.1
		//_uSunFadeEnd("_uSunFadeEnd", Float) = 0.045
		//_uHorizonFadeEnd("_uHorizonFadeEnd", Float) = 0.25
		//_uHorizonHeight("_uHorizonHeight", Float) = 0.25
		//_uHorizonColorFadeStart("_uHorizonColorFadeStart", Float) = 0
		//_uHorizonColorFadeEnd("_uHorizonColorFadeEnd", Float) = 0
		//_uCloudAlpha("_uCloudAlpha", Range(0.0, 4.55)) = 3.25

		//_SunAlpha("Sun Alpha", float) = 23
		//_SunBeta("Sun Beta", float) = 0.4
		//_FogBlendHeight("-", Range(0, 1)) = 1.0

		//_SunIntensity("Fog Sun Intensity", float) = 2.0
		//_MoonIntensity("Fog Moon Intensity", float) = 1.0

		//_SunControl("Sun Control", float) = 1
		//_MoonControl("Moon Control", float) = 1

		// [Toggle] _VRSinglePassEnabled("VR Enabled", Float) = 0
		// [Toggle] _MaskMoon("Moon Masked", Float) = 0
		// [Toggle] _UseUniStormFog("Use UniStorm Fog", Float) = 0
		// [Toggle] _EnableDithering("Enable Dithering", Float) = 0
		// [Toggle] _UseHighConvergenceSpeed("Use High Convergence Speed", Float) = 0
		_NoiseTex("Noise Texture", 2D) = "white" {}
	}

		SubShader
	{
		LOD 100
		ZWrite Off

		Pass
		{

		CGPROGRAM

		//#if defined(D3D11)
		//#pragma warning disable x3595 // private field assigned but not used.
		//#endif

		#pragma vertex vert
		#pragma fragment frag
		// #pragma multi_compile LOW MEDIUM HIGH ULTRA
		// #pragma multi_compile TWOD VOLUMETRIC
		// #pragma multi_compile SHADOW __

	sampler2D _NoiseTex;
	float _EnableDithering;
    
    uniform sampler2D _uBaseNoise;
    uniform sampler2D _uCurlNoise;
    uniform sampler3D _uDetailNoise;

    uniform float _Seed; 
    uniform float _uSize;
	uniform float _uCloudAlpha;

    uniform float3 _uWorldSpaceCameraPos;
	half3 _SunColor;
	half3 _MoonColor;
	half _SunAlpha;
	half _SunBeta;
	half3 _FogColor;
	float _FogBlendHeight;
	half3 _SunVector;
	half3 _MoonVector;
	float _SunControl;
	float _MoonControl;
	half _SunIntensity;
	half _MoonIntensity;

    #include "UnityCG.cginc"
    #include "cloudsInclude.cginc"

    struct appdata
    {
        float2 uv : TEXCOORD0;
        float4 vertex : POSITION;
    };

    struct v2f
    {
        float4 vertex : SV_POSITION;
        float2 uv : TEXCOORD0;
		float3 worldPos : TEXCOORD1;
		float4 position_in_world_space : TEXCOORD2;
    };

    sampler2D _MainTex;
    float4 _MainTex_ST;

    inline float4 alphaBlend(float4 dst, float4 src)
    {
        float outA = max(0.001, src.a + dst.a * (1.0 - src.a));
        return float4 (
            (src.rgb + (dst.rgb * dst.a) * (1.0 - src.a)) / outA,
            outA
            );
    }

    v2f vert(appdata v)
    {
        v2f o;

        UNITY_INITIALIZE_OUTPUT(v2f, o);
		o.worldPos = mul(unity_ObjectToWorld, v.vertex);

		o.position_in_world_space = mul(unity_ObjectToWorld, v.vertex);

        o.uv = v.uv;
        o.vertex = UnityObjectToClipPos(v.vertex);
        return o;
    }

    uniform float _uHorizonDarkness;
	uniform float _MaskMoon;
	uniform float _UseUniStormFog;

	uniform float _uHorizonHeight;
    uniform float _uHorizonFadeEnd;
	uniform float _uSunFadeEnd;
    uniform float _uHorizonFadeStart;
	uniform float _uHorizonColorFadeEnd;
	uniform float _uHorizonColorFadeStart;
	float4 _uHorizonColor;
	float _uCloudHeight;

	float3 getNoise(float2 uv)
	{
		float3 noise = tex2D(_NoiseTex, uv * 100 + _Time * 50);
		noise = mad(noise, 2.0, -0.5);

		return noise / 255;
	}

	float4x4 _InverseViewProjectionMatrix;
	float3 GetWorldSpacePosition(float2 uv,float depth)
	{
    	float4 result = mul(_InverseViewProjectionMatrix, float4(uv*2-1, depth, 1.0));
    	return result.xyz/result.w;
	}

	sampler2D _CameraDepthTexture;
	fixed4 frag(v2f i) : SV_Target
	{
		
        float2 lon = (i.uv.xy + _uJitter * (1.0 / _uSize)) - 0.5;
        float a1 = length(lon) * 3.181592;
        float sin1 = sin(a1);
        float cos1 = cos(a1);
        float cos2 = lon.x / length(lon);
        float sin2 = lon.y / length(lon);

        float3 pos = float3(sin1 * cos2, cos1, sin1 * sin2);

		// float depth = tex2D(_CameraDepthTexture,i.uv);
		// float3 pos = GetWorldSpacePosition(i.uv,depth);

        float4 clouds = 0.0;

		float3 ro = float3(0, 0, 0);
        float3 rd = normalize(pos);
		
        renderClouds(clouds, ro, rd);

        float rddotup = dot(float3(0, 1, 0), rd);
        float sstep = smoothstep(_uHorizonFadeStart, _uHorizonFadeEnd, rddotup);
		float sstep2 = smoothstep(_uHorizonColorFadeStart, _uHorizonColorFadeEnd, rddotup);
		float HorizonStep = smoothstep(0, _uSunFadeEnd, rddotup);
		float4 final = float4(0,0,0,0);

			final = float4(
				lerp(_uCloudsAmbientColorBottom.rgb * _uCloudAlpha * (1.0 - remap(_uCloudsCoverage + _uCloudsCoverageBias, 0.77, 0.25)),
					clouds.rgb*1.035 * sstep * sstep2,
					sstep * sstep2),
				lerp((1.0 - remap(_uCloudsCoverage + _uCloudsCoverageBias, 0.9, 0.185)),
				(1.0 - clouds.a) * sstep,
					sstep)
				);
		// }
        
		if (_MaskMoon == 1)
		{
			final = float4(final.rgb, saturate(remap(final.a, 0.0, lerp(1.0, 0.94, saturate(rd.y)))));
		}

        return final;
    }
        ENDCG
}

Pass
{
	Cull Off ZWrite Off ZTest Always
	CGPROGRAM
	#pragma vertex vert
	#pragma fragment frag

	#pragma multi_compile LOW MEDIUM HIGH ULTRA
	#pragma multi_compile TWOD VOLUMETRIC
	#pragma multi_compile __ PREWARM

	#include "UnityCG.cginc"

		uniform float _DistantCloudUpdateSpeed;
        uniform float       _uSize;
        uniform float2      _uJitter;
        uniform sampler2D   _uPreviousCloudTex;
        uniform sampler2D   _uLowresCloudTex;

        uniform float _uCloudsCoverageBias;
		uniform float _UseHighConvergenceSpeed;
        uniform float _uLightningTimer = 0.0;

        uniform float _uConverganceRate;

        struct appdata
		{
			float4 vertex : POSITION;
			float2 uv : TEXCOORD0;
		};

		struct v2f
		{
			float4 vertex : SV_POSITION;
			float2 uv : TEXCOORD0;
		};

        v2f vert(appdata v)
        {
            v2f o;
            o.vertex = UnityObjectToClipPos(v.vertex);
            o.uv = v.uv;
            return o;
        }

        half CurrentCorrect(float2 uv, float2 jitter) {
            float2 texelRelativePos = floor(fmod(uv * _uSize, 4.0)); //between (0, 4.0)

            texelRelativePos = abs(texelRelativePos - jitter);

            return saturate(texelRelativePos.x + texelRelativePos.y);
        }

		half4 SamplePrev(float2 uv) {
			return tex2D(_uPreviousCloudTex, uv);
		}

        float4 SampleCurrent(float2 uv) {
            return tex2D(_uLowresCloudTex, uv);
        }

        float _uCloudsMovementSpeed;
        float remap(float v, float s, float e)
        {
            return (v - s) / (e - s);
        }

        half4 frag(v2f i) : SV_Target
        {
            float2 uvN = i.uv * 2.0 - 1.0;

            float4 currSample = SampleCurrent(i.uv);
            half4 prevSample = SamplePrev(i.uv);

            float luvN = length(uvN);

            half correct = CurrentCorrect(i.uv, _uJitter);

// #if defined(PREWARM)
//             return lerp(currSample, prevSample, correct); // No converging on prewarm
// #endif

			
// #if defined(ULTRA) || defined (HIGH)

			if (_UseHighConvergenceSpeed == 0)
			{
				float ms01 = remap(_uCloudsMovementSpeed, 0, 150);
				float converganceSpeed = lerp(0.4, 0.99, ms01);
				return lerp(prevSample, lerp(currSample, prevSample, correct), lerp(converganceSpeed, lerp(0.15, 0.25, ms01), luvN));
			}
			else //Using the Customize Quality settings
			{
				float ms01 = remap(_DistantCloudUpdateSpeed, 0, 150);
				float converganceSpeed = lerp(0.4, 0.99, ms01);
				return lerp(prevSample, lerp(currSample, prevSample, correct), lerp(converganceSpeed, lerp(0.15, 0.25, ms01), luvN));
			}
// #else
// 			float ms01 = remap(_uCloudsMovementSpeed, 0, 150);
//             float converganceSpeed = lerp(lerp(0.4, 0.95, ms01), 0.85, saturate(_uLightningTimer - _Time.y) * 5.0);
// 			return lerp(prevSample, lerp(currSample, prevSample, correct), lerp(converganceSpeed, lerp(0.15, 0.25, ms01), luvN));
// #endif		
        }

        ENDCG
    }
}
Fallback Off
}
