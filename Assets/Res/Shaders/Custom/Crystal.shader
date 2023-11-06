Shader "URP/Scene/Crystal"
{
//	Properties
//	{
//		_BaseMap("颜色图", 2D) = "white" {}
//		[NoScaleOffset]_BumpMap("法线图", 2D) = "bump" {}
//		[NoScaleOffset]_MetallicGlossMap("混合图（R金属、GAO、B、A光滑）", 2D) = "white" {}
//		[MainColor] _BaseColor("颜色", Color) = (1,1,1,1)
//		_BumpScale("法线缩放", Range(0,2)) = 1.0
//		_Metallic("金属度", Range(0,1)) = 1
//		_Smoothness("平滑度", Range(0,1)) = 1
//
//		[Space]
//		[Foldout(1,2,1)]_EnableDepthLayer1("深度层_Foldout", float) = 0
//		_Layer1Depth("深度", Range(0,5)) = 1
//		_Layer1DepthMap("高度图(G高度)", 2D) = "white" {}
//		[NoScaleOffset]_Layer1ColorMap("颜色图", 2D) = "balck" {}
//		[Vector3]_Layer1ScrollAndRotate("UV动画", float) = (0, 0, 0, 0)
//		_Layer1Color("颜色", COLOR) = (1,1,1,1)
//		[Foldout_Out(1)]_EnableDepthLayer1_e("_Foldout", float) = 1
//
//		[Space]
//		[Foldout(1,2,1)]_EnableEmission("自发光_Foldout", float) = 0
//		[NoScaleOffset]_EmissionMap("自发光图", 2D) = "white" {}
//		[HDR] _EmissionColor("自发光颜色", Color) = (1,1,1)
//		[Foldout_Out(1)]_EnableEmission_e("_Foldout", float) = 1
//
//		[Space]
//		[Foldout(1,2,1)] _EnableFresnel("菲涅尔_Foldout", Float) = 0
//		_FresnelPow("菲涅尔次方", Range(0.0, 10.0)) = 4.0
//		_fresnelIntensity("菲涅尔亮度", Range(0.0, 2.0)) = 1.0
//		_FresnelColorInside("内部颜色", COLOR) = (1,1,0.5,1)
//		_FresnelColorOutside("外围颜色", COLOR) = (1,1,1,1)
//		[Foldout_Out(1)]_EnableFresnel_e("_Foldout", float) = 1
//
//
//		//[Space]
//		// [Toggle(_SPECULARHIGHLIGHTS_OFF)] _SPECULARHIGHLIGHTS_OFF("关闭高光", Float) = 0.0000000
//		// [Toggle(_ENVIRONMENTREFLECTIONS_OFF)] _ENVIRONMENTREFLECTIONS_OFF("关闭环境反射", Float) = 0.0000000
//		//[Enum(UnityEngine.Rendering.CullMode)]_Cull("剔除", Float) = 2.0
//	}
//
//	SubShader
//	{
//		Tags{"Queue" = "Geometry"}
//
//		pass
//		{
//			Tags{"LightMode" = "UniversalForward"}
//            Cull[_Cull]
//
//			HLSLPROGRAM
//            #pragma vertex Vert
//            #pragma fragment Frag
//			
//            // Material Keywords
//            // #pragma shader_feature_local_fragment _SPECULARHIGHLIGHTS_OFF
//            // #pragma shader_feature_local_fragment _ENVIRONMENTREFLECTIONS_OFF
//
//            // Universal Pipeline keywords
//            #pragma multi_compile _ _MAIN_LIGHT_CACHED_SHADOW _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE 
//            #pragma multi_compile _ _ADDITIONAL_LIGHTS 
//            #pragma multi_compile_fragment _ _SHADOWS_SOFT
//			
//            // Unity defined keywords
//            #pragma multi_compile _ SHADOWS_SHADOWMASK
//            #pragma multi_compile _ LIGHTMAP_ON
//            #pragma multi_compile_fog
//
//			//My keywords
//			#pragma multi_compile _ _EnableEmission
//			#pragma multi_compile _ _EnableFresnel
//			#pragma multi_compile _ _EnableDepthLayer1
//			// #pragma multi_compile _ ATMOSPHERE_ON
//			// #pragma multi_compile _ ATMOSPHERE_POSTPROCESS_ON
//			
//            #define LIT
//            #define BASEMAP
//			#define WORLDPOS
//            #define NORMALMAP
//			
//			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
//
//			TEXTURE2D(_BaseMap);          SAMPLER(sampler_BaseMap);
//			TEXTURE2D(_BumpMap);          SAMPLER(sampler_BumpMap);
//			TEXTURE2D(_MetallicGlossMap); SAMPLER(sampler_MetallicGlossMap);
//			TEXTURE2D(_EmissionMap);      SAMPLER(sampler_EmissionMap);
//			TEXTURE2D(_Layer1DepthMap);   SAMPLER(sampler_Layer1DepthMap);
//			TEXTURE2D(_Layer1ColorMap);   SAMPLER(sampler_Layer1ColorMap);
//
//			CBUFFER_START(UnityPerMaterial)
//			half4 _BaseMap_ST;
//			half  _BumpScale;
//			half  _Metallic;
//			half  _Smoothness;
//			half4 _BaseColor;
//			half4 _EmissionColor;
//			
//			float _FresnelPow;
//			float _fresnelIntensity;
//			half4 _FresnelColorInside;
//			half4 _FresnelColorOutside;
//			
//            float4 _Layer1DepthMap_ST;
//			float4 _Layer1ScrollAndRotate;
//			half   _Layer1Depth;
//            half4  _Layer1Color;
//			CBUFFER_END
//
//			#include "../../Library/Base.hlsl"			
//
//
//			float2 ParallaxMapping(float2 uv, float3 viewDir, float height)
//			{
//				float2 p = viewDir.xy* (height );
//				return uv - p;
//			}
//
//			half4 Frag(v2f i) : SV_Target
//			{		
//				//base
//                float2 uv = i.uvAndOther.xy;
//				half4 baseColor = SAMPLE_TEXTURE2D( _BaseMap, sampler_BaseMap, uv ) * _BaseColor;
//				half alpha = baseColor.a;
//
//				//mix
//				half4 mixValue = SAMPLE_TEXTURE2D( _MetallicGlossMap, sampler_MetallicGlossMap, uv );
//				half occlusion = mixValue.g;
//				_Metallic *= mixValue.r;
//				_Smoothness *= mixValue.a;
//				
//				//normal
//				float3 normal = UnpackNormalScale(SAMPLE_TEXTURE2D(_BumpMap, sampler_BumpMap, uv), _BumpScale);
//				normal = CalculateNormalMap(i, normal);
//
//				float layerCount = 1;
//
//				// Layer1
//                #if defined (_EnableDepthLayer1)
//                    float2 layerUV = RotateAndMoveUV(uv, _Layer1ScrollAndRotate.xy, _Layer1ScrollAndRotate.z, _Layer1DepthMap_ST);               
//					float3 viewDirTS = CalculateParallaxIterationsViewDir(i.tangentWS, i.bitangentWS, i.normalWS);				
//					float2 newUV = ParallaxMappingIterations(layerUV, viewDirTS.xyz, _Layer1Depth, _Layer1DepthMap, sampler_Layer1DepthMap);
//                    baseColor.rgb += SAMPLE_TEXTURE2D(_Layer1ColorMap, sampler_Layer1ColorMap, newUV).rgb * _Layer1Color.xyz;
//					layerCount ++;					              
//                #endif
//			
//				baseColor.rgb /= layerCount;
//				
//				//color
//				half3 color = CalculatePBR(i, baseColor.rgb, normal, _Metallic, _Smoothness, occlusion, alpha);
//
//				#if defined (_EnableEmission)
//					half3 emission = SAMPLE_TEXTURE2D( _EmissionMap, sampler_EmissionMap, uv ).rgb * _EmissionColor;
//    				color += emission;
//				#endif
//				
//				//fresnel
//				#if defined (_EnableFresnel)
//                half ndotv = saturate(dot(normal, normalize(_WorldSpaceCameraPos - i.positionWS)));
//				float fresnel = pow(1.0 - ndotv, _FresnelPow);
//					color += lerp(_FresnelColorInside, _FresnelColorOutside, fresnel).xyz * fresnel * _fresnelIntensity;
//				#endif
//
//				//fog
//				#if defined(ATMOSPHERE_ON)
//				#if !defined(ATMOSPHERE_POSTPROCESS_ON)
//					color.rgb = GetAtmosphereOutputColor(color.rgb, i.inscattering);
//				#endif
//				#else
//					color.rgb = MixFog(color.rgb, i.fogAndOther.x);
//				#endif
//
//                return half4(color, alpha);
//			}			
//            ENDHLSL
//		}
//
//     
//        Pass
//		{
//			Name "ShadowCaster"
//			Tags { "LightMode" = "ShadowCaster" }
//            ZWrite On
//
//			HLSLPROGRAM
//			#pragma vertex Vert
//			#pragma fragment Frag
//			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
//			#define SHADOWCASTER	
//	
//			TEXTURE2D(_BaseMap);          SAMPLER(sampler_BaseMap);
//			TEXTURE2D(_BumpMap);          SAMPLER(sampler_BumpMap);
//			TEXTURE2D(_MetallicGlossMap); SAMPLER(sampler_MetallicGlossMap);
//			TEXTURE2D(_EmissionMap);      SAMPLER(sampler_EmissionMap);
//			TEXTURE2D(_Layer1DepthMap);   SAMPLER(sampler_Layer1DepthMap);
//			TEXTURE2D(_Layer1ColorMap);   SAMPLER(sampler_Layer1ColorMap);
//
//			CBUFFER_START(UnityPerMaterial)
//			half4 _BaseMap_ST;
//			half  _BumpScale;
//			half  _Metallic;
//			half  _Smoothness;
//			half4 _BaseColor;
//			half4 _EmissionColor;
//			
//			float _FresnelPow;
//			float _fresnelIntensity;
//			half4 _FresnelColorInside;
//			half4 _FresnelColorOutside;
//			
//            float4 _Layer1DepthMap_ST;
//			float4 _Layer1ScrollAndRotate;
//			half   _Layer1Depth;
//            half4  _Layer1Color;
//			CBUFFER_END
//
//			float3 _LightDirection;		
//
//			#include "../../Library/Base.hlsl"
//			ENDHLSL
//		}
//		Pass
//        {
//            Name "DepthOnly"
//            Tags{"LightMode" = "DepthOnly"}
//
//            ZWrite On
//            ColorMask 0
//
//            HLSLPROGRAM
//            #pragma vertex Vert
//            #pragma fragment Frag
//
//			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
//		 	#define DEPTHONLY
//	
//			TEXTURE2D(_BaseMap);          SAMPLER(sampler_BaseMap);
//			TEXTURE2D(_BumpMap);          SAMPLER(sampler_BumpMap);
//			TEXTURE2D(_MetallicGlossMap); SAMPLER(sampler_MetallicGlossMap);
//			TEXTURE2D(_EmissionMap);      SAMPLER(sampler_EmissionMap);
//			TEXTURE2D(_Layer1DepthMap);   SAMPLER(sampler_Layer1DepthMap);
//			TEXTURE2D(_Layer1ColorMap);   SAMPLER(sampler_Layer1ColorMap);
//
//			CBUFFER_START(UnityPerMaterial)
//			half4 _BaseMap_ST;
//			half  _BumpScale;
//			half  _Metallic;
//			half  _Smoothness;
//			half4 _BaseColor;
//			half4 _EmissionColor;
//			
//			float _FresnelPow;
//			float _fresnelIntensity;
//			half4 _FresnelColorInside;
//			half4 _FresnelColorOutside;
//			
//            float4 _Layer1DepthMap_ST;
//			float4 _Layer1ScrollAndRotate;
//			half   _Layer1Depth;
//            half4  _Layer1Color;
//			CBUFFER_END
//
//			#include "../../Library/Base.hlsl"
//            ENDHLSL
//        }
//	}  
//	CustomEditor"SimpleShaderGUI"
}