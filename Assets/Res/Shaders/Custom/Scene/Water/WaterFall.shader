Shader "Baha/Scene/Water/WaterFall"
{
// 	Properties
// 	{
// 		[Button()] _CreateLodMat("创建LOD材质", float) = 0
// 		[Enum_Switch(LOD0,LOD1,LOD2)]_Lod("LOD分级", float) = 0

// 		_BaseMap("颜色图", 2D) = "white" {}
// 		[NoScaleOffset]_SideMap("侧面遮罩", 2D) = "white" {}	

// 		[Space]
// 		[MainColor] [HDR]_BaseColor("水颜色", Color) = (1,1,1,1)

// 		[Space]
// 		_ShadowBright("阴影补亮", Range(0,1)) = 0
// 		_BackBright("背面补亮", Range(0,1)) = 0

// 		_DepthFadeIndensity("穿插虚化", range(0.01, 1)) = 1
// 		_Alpha("透明度", range(0.01, 1)) = 0.1

// 		[Space]
// 		[Foldout(1,2,0)]_EnableVein("正面纹理_Foldout", float) = 0
// 		_Speed1("流速", Range(0,1)) = 1
// 		_Speed2("流速2", Range(0,1)) = 1
// 	    _Tilling1("纹理平铺1",  Range(0,5)) = 2
// 	    _Tilling2("纹理平铺2",  Range(0,5)) = 3
// 	    _Scale("纹理宽高比",  Range(0,2)) = 1.5
// 		[Foldout_Out(1)]_EnableVein_e("_Foldout", float) = 0
		
// 		[Space]	
// 		[Foldout(1,2,0)]_EnableDepth("深度_Foldout", float) = 0
// 		_DepthChange("深度变化", Range(0,1)) = 0.05
// 		[Foldout_Out(1)]_EnableDepth_e("_Foldout", float) = 0
		
// 		[Space]	
// 		[Foldout(1,2,0,0,LOD0,LOD1)]_EnableFog("雾气_Foldout", float) = 0
// 		[Switch(LOD0,LOD1)][NoScaleOffset]_FogMap("雾气", 2D) = "white" {}
// 	    [Switch(LOD0,LOD1)]_Tilling3("雾气平铺",  Range(0,5)) = 2
// 	    [Switch(LOD0,LOD1)]_FogSpeed("雾气速度",  Range(0,1)) = 0.5
// 	    [Switch(LOD0,LOD1)]_FogStrength("雾气强度",  Range(0,2)) = 0.2
// 		[Foldout_Out(1)]_EnableFog_e("_Foldout", float) = 0

// 		[Space]	
// 		[Foldout(1,2,0,0)]_EnableVertexChange("顶点变化_Foldout", float) = 0
// 		[NoScaleOffset]_VertexChangeMap("顶点变化图", 2D) = "white" {}
// 	    _Tilling0("平铺",  Range(0.1,5)) = 0.5
// 		_Speed0("速度", Range(0, 1)) = 1
// 		_VertexChangeStrength("变化强度", Range(0, 1)) = 1
// 		[Foldout_Out(1)]_EnableVertexChange_e("_Foldout", float) = 0

// 		[HideInInspector] _WISHGI_State("WISHGI_State", Int) = 0
// 	}

// 	SubShader
// 	{
// 		Tags{"RenderType"="_BaseMap" "Queue" = "Transparent" } 
		
// 		Blend SrcAlpha OneMinusSrcAlpha

// 		HLSLINCLUDE
// 			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
// 			#pragma multi_compile_instancing
// 			#include "./WaterFallInput.hlsl"
// 		ENDHLSL

// 		pass
// 		{
// 			Tags{"LightMode" = "UniversalForward"}

// 			HLSLPROGRAM
// 			#pragma target 3.0
//             #pragma vertex Vert
//             #pragma fragment Frag
// 			#include "../../Library/CommonKeyword_Scene.hlsl"
			
//             #define LIT
//             #define BASEMAP
// 			#define WORLDPOS
//             #define NORMALMAP
// 			#define PARALLAX
// 			#define WATERFALL
// 			#define DEPTH
			
// 			#include "../../Library/Base.hlsl"
// 			#include "./WaterFallForwardPass.hlsl"
//             ENDHLSL
// 		}
//         Pass
// 		{
// 			Name "ShadowCaster"
// 			Tags { "LightMode" = "ShadowCaster" }

// 			HLSLPROGRAM
// 			#pragma vertex Vert
// 			#pragma fragment Frag
// 			#define TRANSPARENT

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
// 			#define TRANSPARENT

// 			#include "../../Library/Base_DepthOnly.hlsl"
//             ENDHLSL
//         }
// 	}  
// 	CustomEditor"SimpleShaderGUI"
}


