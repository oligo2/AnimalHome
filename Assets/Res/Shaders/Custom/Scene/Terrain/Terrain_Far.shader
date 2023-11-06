Shader "Baha/Scene/Terrain/Terrain-Far"
{
// 	Properties
// 	{
// 		// [Button()] _CreateLodMat("创建LOD材质", float) = 0
// 		_BaseMap("法线图", 2D) = "bump" {}

// 		[MainColor] _BaseColor("颜色", Color) = (1,1,1,1)
// 		_BaseAndRedRatio("雪地与岩石比例", Range(0,1)) = 0.5
// 		// _BaseHeight("雪地海拔范围", Range(0,1)) = 0.5
// 		_Transit("过渡", Range(0.01, 0.2)) = 0.1

// 		[Space]
// 		[Foldout(1,2,0)]_EnableOrigin("默认(雪)_Foldout", float) = 0
// 		[NoScaleOffset]_OriginMap("贴图(RGB颜色，A平滑度)", 2D) = "white" {}
// 		_ScaleOrigin("平铺", Range(1,20)) = 1
// 		_SmoothnessOrigin("平滑度", Range(0,2)) = 1
// 		[Foldout_Out(1)]_EnableOrigin_e("_Foldout", float) = 1

// 		[Space]
// 		[Foldout(1,2,0)]_EnableRed("R贴图(岩石)_Foldout", float) = 0
// 		[NoScaleOffset]_RedMap("贴图(RGB颜色，A平滑度)", 2D) = "white" {}
// 		_ScaleRed("平铺", Range(1,20)) = 1
// 		_SmoothnessRed("平滑度", Range(0,2)) = 1
// 		[Foldout_Out(1)]_EnableRed_e("_Foldout", float) = 1

// 		[Space]
// 		[Foldout(1,2,1)]_EnableGreen("G贴图 (草地)_Foldout", float) = 0
// 		[NoScaleOffset]_GreenMap("贴图(RGB颜色，A平滑度)", 2D) = "white" {}
// 		_ScaleGreen("平铺", Range(1,100)) = 1
// 		_SmoothnessGreen("平滑度", Range(0,2)) = 1
// 		[Foldout_Out(1)]_EnableGreen_e("_Foldout", float) = 1

// 		[Space]
// 		[Foldout(1,2,1)]_EnableBlur("B贴图 (其他)_Foldout", float) = 0
// 		[NoScaleOffset]_BlurMap("贴图(RGB颜色，A平滑度)", 2D) = "white" {}
// 		_ScaleBlur("平铺", Range(1,20)) = 1
// 		_SmoothnessBlur("平滑度", Range(0,2)) = 1
// 		[Foldout_Out(1)]_EnableBlur_e("_Foldout", float) = 1
		
// 		[Space]		
// 		[Toggle(_EnableShowVertexColor)] _EnableShowVertexColor("显示顶点色", Float) = 0.0000000
//         [Enum(UnityEngine.Rendering.CullMode)]_Cull("剔除", Float) = 2.0
		
// 		[HideInInspector] _WISHGI_State("WISHGI_State", Int) = 0
// 	}

// 	SubShader
// 	{
// 		Tags{"RenderType"="_BaseMap" "Queue" = "Geometry" }           
// 		Cull Back

// 		HLSLINCLUDE
// 			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
// 			#pragma multi_compile_instancing
// 			#include "./Terrain_FarInput.hlsl"
// 		ENDHLSL

// 		pass
// 		{
// 			Tags{ "LightMode" = "UniversalForward" }

// 			Cull[_Cull]

// 			HLSLPROGRAM
// 			#pragma target 3.0
// 			#pragma vertex Vert
// 			#pragma fragment Frag			
// 			#include "../../Library/CommonKeyword_Scene.hlsl"
			
// 			#define LIT
// 			#define BASEMAP
// 			#define WORLDPOS
// 			#define NORMALMAP
// 			#define NORMALMAPASBASE
// 			#define VERTEXCOLOR

// 			#include "../../Library/Base.hlsl"
// 			#include "./Terrain_FarForwardPass.hlsl"
//             ENDHLSL
// 		}
// 		Pass
// 		{
// 			Name "ShadowCaster"
// 			Tags { "LightMode" = "ShadowCaster" }

// 			HLSLPROGRAM
// 			#pragma vertex Vert
// 			#pragma fragment Frag

// 			#include "../../Library/Base_ShadowCaster.hlsl"
// 			ENDHLSL
// 		}
// 		Pass
//         {
//             Name "DepthOnly"
//             Tags{"LightMode" = "DepthOnly"}
//             ColorMask 0

//             HLSLPROGRAM
//             #pragma vertex Vert
//             #pragma fragment Frag

// 			#include "../../Library/Base_DepthOnly.hlsl"
//             ENDHLSL
//         }
// 	}  
// 	CustomEditor"SimpleShaderGUI"
}