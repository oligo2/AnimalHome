Shader "Baha/Scene/Item/Mirror"
{
// 	Properties
// 	{
// 		[Button()] _CreateLodMat("创建LOD材质", float) = 0
// 		[Enum_Switch(LOD0,LOD1,LOD2)]_Lod("LOD分级", float) = 0

// 		_BaseMap("颜色图", 2D) = "white" {}
//         [Switch(LOD0)] [NoScaleOffset]_BumpMap("法线图（RGB法线)", 2D) = "bump" {}
// 		[Switch(LOD0,LOD1)] [NoScaleOffset] _MixMap("混合图（R金属、G光滑、BAO、A自发光）", 2D) = "blue" {}
// 		[MainColor] _BaseColor("颜色", Color) = (1,1,1,1)
// 		[Switch(LOD0,LOD1)] _Metallic("金属度", Range(0,1)) = 1
// 		[Switch(LOD0,LOD1)] _Smoothness("平滑度", Range(0,1)) = 1
// 		[Switch(LOD0,LOD1)] _NormalMul("法线强度", Range(0,2)) = 1
// 		_Reflection("反射度", Range(0,1)) = 1

// 		[Space]
// 		[Foldout(1,2,1,0,LOD0,LOD1)] _EnableEmission("自发光_Foldout", float) = 0
// 		[Switch(LOD0,LOD1)] [HDR] _EmissionColor("自发光颜色", Color) = (0,0,0)
// 		[Foldout_Out(1)] _EnableEmission_e("_Foldout", float) = 1
		
// 		[Text(1)]Tip("简介：
// 特性：	与MirrorReflecion脚本配合的平面反射材质。
// 光照：	PBR光照原则。
// 反射度：越高镜面反射越强。
// 	一般来讲强反射度由高的金属度与高的平滑度决定。
// 	但这边的镜面反射强度由反射度决定。

// ", float) = 1

//         [HideInInspector] _PlanarReflectionTexture("", 2D) = "bump" {}
// 		[HideInInspector] _WISHGI_State("WISHGI_State", Int) = 0		
// 	}

// 	SubShader
// 	{
// 		Tags{"RenderType"="_BaseMap" "Queue" = "Geometry+700"} 
// 		Cull back

// 		HLSLINCLUDE
// 			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
// 			#pragma multi_compile_instancing
// 			//#pragma shader_feature __ MIRROR
// 			#include "./MirrorInput.hlsl"
//             #define LIT
//             #define BASEMAP
// 			#define WORLDPOS
//             #define NORMALMAP
// 			#define SCREEN
// 			#define MIRROR
// 		ENDHLSL
// 		pass
// 		{

// 			Tags{"LightMode" = "UniversalForward"}
// 			//Tags{"LightMode" = "SSR"}
// 			HLSLPROGRAM
// 			#pragma target 3.0
// 			#pragma vertex Vert
// 			#pragma fragment Frag
// 			#include "../../Library/CommonKeyword_Scene.hlsl"
// 			#include "../../Library/Base.hlsl"
// 			#include "MirrorForwardPass.hlsl"
// 			ENDHLSL
// 		}
// 		pass
// 		{
// 			//Tags{"LightMode" = "UniversalForward"}
// 			Tags{"LightMode" = "SSR"}

// 			HLSLPROGRAM
// 			#pragma target 3.0
//             #pragma vertex Vert
//             #pragma fragment Frag

// 			#include "../../Library/CommonKeyword_Scene.hlsl"
// 			#include "../../Library/Base.hlsl"
// 			#include "MirrorForwardPass.hlsl"
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


