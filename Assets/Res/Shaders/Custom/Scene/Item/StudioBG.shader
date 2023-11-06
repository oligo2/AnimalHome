Shader "Baha/Scene/Item/StudioBG"
{
	Properties
	{
		[Header(Base)]
		_Color                               ("颜色", Color)                            = (1,1,1)
		_ColorMap                            ("纹理", 2D)                               = "white" {}
		[Header(Gradient)]
		[Toggle(_)]_IsGradient4              ("渐变(4)", Float)                         = 0
		_GradientPoint4                      ("渐变端点(4)", Float)                      = 4
		_GradientColor4                      ("渐变颜色(4)", Color)                      = (1,1,1)
		[Toggle(_)]_IsGradient3              ("渐变(3)", Float)                         = 0
		_GradientPoint3                      ("渐变端点(3)", Float)                      = 3
		_GradientColor3                      ("渐变颜色(3)", Color)                      = (1,1,1)
		[Toggle(_)]_IsGradient2              ("渐变(2)", Float)                         = 0
		_GradientPoint2                      ("渐变端点(2)", Float)                      = 2
		_GradientColor2                      ("渐变颜色(2)", Color)                      = (1,1,1)
		[Space]
		_GradientPoint1                      ("渐变端点(1)", Float)                      = 1
		_GradientColor1                      ("渐变颜色(1)", Color)                      = (1,1,1)
		_GradientPoint0                      ("渐变端点(0)", Float)                      = 0
		_GradientColor0                      ("渐变颜色(0)", Color)                      = (1,1,1)
	}
	CustomEditor"SimpleShaderGUI"

	SubShader
	{
		Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" "Queue" = "Geometry" }

		HLSLINCLUDE
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			
			//input
			TEXTURE2D(_ColorMap);          SAMPLER(sampler_ColorMap);
			CBUFFER_START(UnityPerMaterial)
			float3 _Color;
			float4 _ColorMap_ST;
			float  _IsGradient2;
			float  _IsGradient3;
			float  _IsGradient4;
			float3 _GradientColor0;
			float3 _GradientColor1;
			float3 _GradientColor2;
			float3 _GradientColor3;
			float3 _GradientColor4;
			float  _GradientPoint0;
			float  _GradientPoint1;
			float  _GradientPoint2;
			float  _GradientPoint3;
			float  _GradientPoint4;
			float  _GradientOffset;
			CBUFFER_END

		ENDHLSL

		pass
		{
			Name "StudioBGColor"
			Tags
			{
				"LightMode" = "UniversalForward"
			}
			Cull back

			HLSLPROGRAM
			#pragma target 3.0
			#pragma vertex Vert
			#pragma fragment Frag
			#include "../../Library/CommonKeyword_Scene.hlsl"
			#include "../../Library/Base.hlsl"

			struct vert
			{               
				float4 positionOS     : POSITION;
				float3 normalOS       : NORMAL;
				float2 uv1            : TEXCOORD0;
			};

			struct v2f
			{
				float4 positionCS     : SV_POSITION;
				float3 normalWS       : NORMAL;
				float2 uv1            : TEXCOORD0;
				float3 positionWS     : TEXCOORD1;
				float3 positionOS     : TEXCOORD17;

// #if defined(ATMOSPHERE_ON) && !defined(ATMOSPHERE_POSTPROCESS_ON)
// 	float4 inscattering   : TEXCOORD5;
// #endif
			};

			v2f Vert(vert v)
			{
				v2f o = (v2f)0;

				VertexPositionInputs vertexInput = GetVertexPositionInputs(v.positionOS.xyz);
				o.positionCS                     = vertexInput.positionCS; 
				o.positionWS                     = vertexInput.positionWS; 
				o.positionOS                     = v.positionOS;
				o.normalWS                       = TransformObjectToWorldNormal(v.normalOS);
				o.uv1.xy                         = v.uv1.xy;

// #if defined(ATMOSPHERE_ON) && !defined(ATMOSPHERE_POSTPROCESS_ON)
// 		o.inscattering = InScattering(_WorldSpaceCameraPos, o.positionWS);
// #endif
					return o;                      
			}

			float4 Frag(v2f i) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(i);
				//ShadowMap
				float4 shadowCoord      = TransformWorldToShadowCoord(i.positionWS);
				
				//MainLight
				Light mainLight         = GetMainLight(shadowCoord);

				//Basic Vector
				// float3 L                = normalize(mainLight.direction);
				// float3 V                = normalize(_WorldSpaceCameraPos - i.positionWS.xyz);
				float3 N                = i.normalWS;

				//BaseColor
				float3 baseMap          = SAMPLE_TEXTURE2D(_ColorMap, sampler_ColorMap, i.uv1 * _ColorMap_ST.xy + _ColorMap_ST.zw);
				float3 baseColor        = baseMap * _Color;

				//Gradient
				float gradient1         = smoothstep(_GradientPoint0, _GradientPoint1, i.positionOS.y);
				float gradient2         = smoothstep(_GradientPoint0, _GradientPoint2, i.positionOS.y);
				float gradient3         = smoothstep(_GradientPoint0, _GradientPoint3, i.positionOS.y);
				float gradient4         = smoothstep(_GradientPoint0, _GradientPoint4, i.positionOS.y);

				//FinalColor
				float3 finalcolor       = _GradientColor0;
				finalcolor              = lerp(finalcolor, _GradientColor1, gradient1);
				finalcolor              = lerp(finalcolor, lerp(finalcolor, _GradientColor2, gradient2), _IsGradient2);
				finalcolor              = lerp(finalcolor, lerp(finalcolor, _GradientColor3, gradient3), _IsGradient3);
				finalcolor              = lerp(finalcolor, lerp(finalcolor, _GradientColor4, gradient4), _IsGradient4);
				finalcolor             *= baseColor;
				finalcolor             *= mainLight.shadowAttenuation;

				//AdditionalLight
				int lightCount = GetAdditionalLightsCount();
				for (int j = 0; j < lightCount; ++j)
				{
					Light light = GetAdditionalLight(j, i.positionWS);
					half3 attenuatedLightColor = light.color * light.distanceAttenuation;
					half3 lambert = max((dot(N, light.direction)), 0);
					finalcolor += attenuatedLightColor * baseColor * lambert;
				}

// #if defined(ATMOSPHERE_ON) && !defined(ATMOSPHERE_POSTPROCESS_ON) //fog        
// 	finalcolor = CalculateAtmosphere(finalcolor, i.inscattering);
// #endif

				return float4(finalcolor, 1);
			}
			ENDHLSL
		}

		Pass
		{
			Name "ShadowCaster"
			Tags { "LightMode" = "ShadowCaster" }

			HLSLPROGRAM
			#pragma vertex Vert
			#pragma fragment Frag

			#include "../../Library/Base_ShadowCaster.hlsl"
			ENDHLSL
		}

		Pass
        {
            Name "DepthOnly"
            Tags{"LightMode" = "DepthOnly"}
            ColorMask 0

            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag

			#include "../../Library/Base_DepthOnly.hlsl"
            ENDHLSL
        }
	}
		
}
