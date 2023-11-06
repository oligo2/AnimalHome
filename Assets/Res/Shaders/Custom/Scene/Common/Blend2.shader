Shader "Baha/Scene/Industry/Blend2"
{
// 	Properties
// 	{
// 		[Button()] _CreateLodMat("创建LOD材质", float) = 0
// 		[Enum_Switch(LOD0,LOD1,LOD2)] _Lod("LOD分级", float) = 0

// 		_BaseMap("颜色图", 2D) = "white" {}
// 		[NoScaleOffset] _BumpMap("法线图", 2D) = "bump" {}
// 		[Switch(LOD0,LOD1)][NoScaleOffset]_MixMap("混合图（R金属、G光滑、BAO、A自发光）", 2D) = "blue" {}		
// 		[Space]
// 		_BaseColor("颜色", Color) = (1,1,1,1)
// 		[Switch(LOD0,LOD1)][HDR] _EmissionColor1("自发光颜色", Color) = (0,0,0)		
// 		[Space]
// 		[Switch(LOD0,LOD1)] _Metallic1("金属度", Range(0,1)) = 1
// 		[Switch(LOD0,LOD1)] _Smoothness1("平滑度", Range(0,1)) = 1	
// 		[Space]
// 		_TransitFade("过渡虚化", Range(0.01, 0.2)) = 0.1
// 		_TransitBegin("过渡起点", Range(0,1)) = 1
// 		_NormalTransitEffect("法线影响", Range(0,1)) = 1
// 		[Space]
// 		[Toggle_Switch(_EnableEmission, LOD0, LOD1)] _EnableEmission("开启自发光", Float) = 0.0000000
		

// 		[Space]
// 		[Foldout(1,2,0)] _EnableLayer2("第二层 R_Foldout", float) = 1
// 		[NoScaleOffset]_Color2Map("颜色图", 2D) = "white" {}
// 		[Switch(LOD0)][NoScaleOffset]_Bump2Map("法线图（RGB法线)", 2D) = "bump" {}
// 		[Switch(LOD0,LOD1)][NoScaleOffset]_Mix2Map("混合图（R金属、G光滑、BAO、A自发光）", 2D) = "blue" {}
// 		[NoScaleOffset]_Noise2Map("差异图（R差异）", 2D) = "black" {}
// 		[Space]
// 		_Color2("颜色", Color) = (1,1,1,1)
// 		[Switch(LOD0,LOD1)][HDR] _EmissionColor2("自发光颜色", Color) = (0,0,0)		
// 		[Space]
// 		[Switch(LOD0,LOD1)] _Metallic2("金属度", Range(0,1)) = 1
// 		[Switch(LOD0,LOD1)] _Smoothness2("平滑度", Range(0,1)) = 1
// 		[Space]
// 		_Tiling2("平铺比例", float) = 1
// 		[Vector2]_NoiseTiling2("差异图平铺比例", float) = (1, 1, 0, 0)
// 		_OffsetTransitEffect2("差异影响", Range(0,1)) = 1
// 		[Foldout_Out(1)]_EnableLayer2_e("_Foldout", float) = 1
				
// 		[Space]
// 		[Toggle(_EnableShowVertexColor)] _EnableShowVertexColor("显示顶点色", Float) = 0.0000000
// 	}

// 	SubShader
// 	{
// 		Tags{"RenderType"="_BaseMap" "Queue" = "Geometry" }   // RenderType,用作SceneViewDebug的标识，意为albedo的属性名    By 王英杰      
// 		Cull Back

// 		HLSLINCLUDE
// 			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
// 			#pragma multi_compile_instancing
// 			#include "./BlendInput.hlsl"
//             #define LIT
//             #define BASEMAP
// 			#define WORLDPOS
//             #define NORMALMAP
// 			#define VERTEXCOLOR
// 		ENDHLSL

// 		pass
// 		{
// 			Tags{"LightMode" = "UniversalForward"}

// 			HLSLPROGRAM
// 			#pragma target 3.0
//             #pragma vertex Vert
//             #pragma fragment Frag			
// 			#include "../../Library/CommonKeyword_Scene.hlsl"		
// 			#pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS 
// 			#include "../../Library/Base.hlsl"
// 			#include "./BlendForwardPass.hlsl"
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
