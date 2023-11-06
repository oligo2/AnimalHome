Shader "URP/Scene/Cloud"
{
//	Properties
//	{
//		_BaseMap("云图1", 2D) = "white" {}
//		[MainColor] _BaseColor("颜色", Color) = (1,1,1,1)
//        [NoScaleOffset]_BumpMap("法线图", 2D) = "bump" {}
//        _BumpScale("法线缩放", Float) = 1.0
//		[NoScaleOffset]_MetallicGlossMap("混合贴图[R金属、GAO、B、A光滑]", 2D) = "white" {}
//		_Metallic("金属度", Range(0,1)) = 1
//		_Smoothness("平滑度", Range(0,1)) = 1		
//		
//		[Space]
//		[Foldout(1,2,0,1)]_2("云变化_Foldout", float) = 1
//		_CloudMap2("云图2", 2D) = "white" {}
//		_NoiseMap("噪点图", 2D) = "white" {}
//		_CloudChange("云变化", float) = 1
//		[Foldout_Out(1)]_2e("_Foldout", float) = 1
//
//		[Space]
//		[Foldout(1,2,0,1)]_2("风浪_Foldout", float) = 1
//        _WindSpeed("风速度", Range(0.0, 10.0)) = 1.6
//        _WindDirection("风方向", vector) = (-1,1,1,0)
//		[Foldout_Out(1)]_2e("_Foldout", float) = 1
//
//		[Space]
//		[Foldout(1,2,0,1)]_2("透明度裁剪_Foldout", float) = 1
//    	[Toggle(_EnableClip)] _EnableClip("裁剪开关", Float) = 0.0000000
//		_Clip("裁剪值", Range(0.0, 1.0)) = 0.5
//		[Foldout_Out(1)]_2e("_Foldout", float) = 1		
//		
//		[Space]
//    	// [Toggle(_SPECULARHIGHLIGHTS_OFF)] _SPECULARHIGHLIGHTS_OFF("关闭高光", Float) = 0.0000000
//    	// [Toggle(_ENVIRONMENTREFLECTIONS_OFF)] _ENVIRONMENTREFLECTIONS_OFF("关闭环境反射", Float) = 0.0000000
//        // [Enum(UnityEngine.Rendering.BlendMode)]_SrcBlend("原混合因子", Float) = 5.0
//        // [Enum(UnityEngine.Rendering.BlendMode)]_DstBlend("目标混合因子", Float) = 10.0
//        // [Enum(Off, 0, On, 1)]_ZWrite("写入深度", Float) = 1.0
//		// [Enum(UnityEngine.Rendering.CompareFunction)] _ZTest ("深度测试", Float) = 4
//        [Enum(UnityEngine.Rendering.CullMode)]_Cull("剔除", Float) = 2.0
//	}
//
//	SubShader
//	{
//		Tags{"Queue" = "Geometry"}
//
//		pass
//		{
//			Tags{"LightMode" = "UniversalForward"}
//            
//            Blend SrcAlpha OneMinusSrcAlpha
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
//			#pragma multi_compile _ _EnableClip 
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
//			// TEXTURE2D(_MetallicGlossMap); SAMPLER(sampler_MetallicGlossMap);
//			// TEXTURE2D(_EmissionMap);      SAMPLER(sampler_EmissionMap);
//			
//			TEXTURE2D(_CloudMap2);          SAMPLER(sampler_CloudMap2);
//			
//			TEXTURE2D(_NoiseMap);          SAMPLER(sampler_NoiseMap);
//
//			CBUFFER_START(UnityPerMaterial)
//			half4 _BaseMap_ST;
//			half  _BumpScale;
//			half  _Metallic;
//			half  _Smoothness;
//			half4 _BaseColor;
//			half4 _EmissionColor;
//			half _Clip;
//			float _WindSpeed;
//			float2 _WindDirection;
//			float _CloudChange;
//
//		// _CloudTex2("云图2", 2D) = "white" {}
//		// _NoiseTex("噪点图", 2D) = "white" {}
//		// _CloudChange("云变化", float) = 1
//			CBUFFER_END
//
//			#include "../../Library/Base.hlsl"			
//
//			half4 Frag(v2f i) : SV_Target
//			{
//				//base
//				half offset = _Time.y *_WindSpeed / 10;
//				half2 offset2 = offset*_WindDirection;
//				
//				float2 uv = i.uvAndOther.xy;
//                half alpha = SAMPLE_TEXTURE2D( _BaseMap, sampler_BaseMap, uv + offset2 ) * _BaseColor.r;
//				// half alpha = baseColor.r;
//
//				half noise = SAMPLE_TEXTURE2D( _NoiseMap, sampler_NoiseMap, uv + offset2*_CloudChange).r;
//
//				// noise = (noise+1) /2;
//				 alpha += noise;
//
//				#if defined (_EnableClip)
//					clip(alpha - _Clip);
//				#endif
//
//				// //mix
//				// half4 mixValue = SAMPLE_TEXTURE2D( _MetallicGlossMap, sampler_MetallicGlossMap, i.uv );
//				// half occlusion = mixValue.g;
//				// _Metallic *= mixValue.r;
//				// _Smoothness *= mixValue.a;
//				
//				// //normal
//				// float3 normal = UnpackNormalScale(SAMPLE_TEXTURE2D(_BumpMap, sampler_BumpMap, i.uv), _BumpScale);
//				// normal = CalculateNormalMap(i, normal);
//
//				// //color
//				half3 color = alpha;//CalculatePBR(i, baseColor.rgb, normal, _Metallic, _Smoothness, occlusion, alpha);
//				// alpha += noise;
//				// #if defined (_EnableEmission)
//				// 	half3 emission = SAMPLE_TEXTURE2D( _EmissionMap, sampler_EmissionMap, i.uv ).rgb * _EmissionColor;
//    			// 	color += emission;
//				// #endif
//				
//		// 		// //fog
//		// 		// #if defined(ATMOSPHERE_ON)
//		//			#if !defined(ATMOSPHERE_POSTPROCESS_ON)
//		// 		// 	color.rgb = GetAtmosphereOutputColor(color.rgb, i.inscattering);
//		//			#endif
//		// 		// #else
//		// 		// 	color.rgb = MixFog(color.rgb, i.fogAndOther.x);
//		// 		// #endif
//
//                return half4(color, alpha);
//			}
//			
//            ENDHLSL
//		}
//
//     
//        // Pass
//		// {
//		// 	Name "ShadowCaster"
//		// 	Tags { "LightMode" = "ShadowCaster" }
//        //     ZWrite On
//
//		// 	HLSLPROGRAM
//		// 	#pragma vertex Vert
//		// 	#pragma fragment Frag
//		// 	#pragma multi_compile _ _EnableClip
//		// 	#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
//		// 	#define SHADOWCASTER	
//	
//		// 	TEXTURE2D(_BaseMap);           SAMPLER(sampler_BaseMap);
//		// 	TEXTURE2D(_MetallicGlossMap);  SAMPLER(sampler_MetallicGlossMap);
//		// 	TEXTURE2D(_EmissionMap);       SAMPLER(sampler_EmissionMap);
//
//		// 	CBUFFER_START(UnityPerMaterial)
//		// 	half4 _BaseMap_ST;
//		// 	half  _BumpScale;
//		// 	half  _Metallic;
//		// 	half  _Smoothness;
//		// 	half4 _BaseColor;
//		// 	half4 _EmissionColor;
//		// 	half _Clip;
//		// 	CBUFFER_END
//		// 	float3 _LightDirection;		
//
//		// 	#include "../../Library/Base.hlsl"
//		// 	ENDHLSL
//		// }
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
//		 	#pragma multi_compile _ _EnableClip
//
//			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
//		 	#define DEPTHONLY
//	
//		 	TEXTURE2D(_BaseMap);           SAMPLER(sampler_BaseMap);
//			TEXTURE2D(_MetallicGlossMap);  SAMPLER(sampler_MetallicGlossMap);
//		 	TEXTURE2D(_EmissionMap);       SAMPLER(sampler_EmissionMap);
//
//		 	CBUFFER_START(UnityPerMaterial)
//		 	half4 _BaseMap_ST;
//			half  _BumpScale;
//		 	half  _Metallic;
//		 	half  _Smoothness;
//		 	half4 _BaseColor;
//		 	half4 _EmissionColor;
//		 	half _Clip;
//		 	CBUFFER_END
//
//			#include "../../Library/Base.hlsl"
//            ENDHLSL
//        }
//	}  
//	CustomEditor"SimpleShaderGUI"
}