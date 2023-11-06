Shader "Baha/Scene/Item/ColorfulGlass"
{
// 	Properties
// 	{
// 		[Button()] _CreateLodMat("创建LOD材质", float) = 0
// 		[Enum_Switch(LOD0,LOD1,LOD2)]_Lod("LOD分级", float) = 0

// 		_BaseMap("颜色图", 2D) = "white" {}
//         [Switch(LOD0)] _BumpMap("法线图（RGB法线)", 2D) = "bump" {}  
// 		[Switch(LOD0,LOD1)] [NoScaleOffset]_MixMap("混合图（R金属、G光滑、BAO、A自发光）", 2D) = "blue" {}
// 		[MainColor] _BaseColor("颜色", Color) = (1,1,1,1)
// 		[Switch(LOD0,LOD1)] _Metallic("金属度", Range(0,1)) = 1
// 		[Switch(LOD0,LOD1)] _Smoothness("平滑度", Range(0,1)) = 1

// 		[Space]
// 		[Foldout(1,2,0)] _EnableInside("折射_Foldout", float) = 1
// 		_InsideMask("遮罩(R)", 2D) = "red" {}
// 		_InsideDepth("深度", Range(-1,1)) = 0
// 		[Space]
// 		_InsideMap("纹理贴图(R)", 2D) = "red" {}
// 		_InsideOpacity("纹理透明度", Range(0,1)) = 1
// 		[Space]
// 		_InsideMap2("颜色贴图(RGB)", 2D) = "white" {}
// 		[HDR]_InsideColor("颜色", Color) = (1,1,1,1)
// 		[Space]
// 		_FresnelPower("菲尼尔强度", Range(0, 1)) = 0
// 		[HDR]_FresnelColor("菲尼尔颜色", Color) = (1,1,1,1)
// 		[Foldout_Out(1)] _EnableInside_e("_Foldout", float) = 0

// 		[Space]
// 		[Foldout(1,2,1,0,LOD0,LOD1)] _EnableEmission("自发光_Foldout", float) = 0
// 		[Switch(LOD0,LOD1)] [HDR] _EmissionColor("自发光颜色", Color) = (0,0,0)
// 		[Foldout_Out(1)] _EnableEmission_e("_Foldout", float) = 1

// 		//Hide
// 		[HideInInspector] _WISHGI_State("WISHGI_State", Int) = 0
// 	}

// 	SubShader
// 	{
// 		Tags{"RenderType"="_BaseMap" "Queue" = "Geometry" } // 
// 		Cull[Back]

// 		HLSLINCLUDE
// 			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
// 			#pragma multi_compile_instancing
// 			#include "./ColorfulGlassInput.hlsl"
// 			#define LIT
//             #define BASEMAP
//             #define NORMALMAP
// 			#define DEPTH
// 			#define PARALLAX
// 		ENDHLSL

// 		pass
// 		{
// 			Tags{"LightMode" = "UniversalForward"}

// 			HLSLPROGRAM
// 			#pragma target 3.0
//             #pragma vertex Vert
//             #pragma fragment Frag
// 			#include "../../Library/CommonKeyword_Scene.hlsl"
// 			#include "../../Library/Base.hlsl"
// 			#include "./ColorfulGlassForwardPass.hlsl"
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