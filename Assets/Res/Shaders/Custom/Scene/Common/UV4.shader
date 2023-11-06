 Shader "Baha/Scene/Industry/UV4"
{
	// Properties
	// {
	// 	[Button()] _CreateLodMat("创建LOD材质", float) = 0
	// 	[Enum_Switch(LOD0,LOD1,LOD2)] _Lod("LOD分级", float) = 0

	// 	_BaseMap("颜色图", 2D) = "white" {}
	// 	[Switch(LOD0)][NoScaleOffset] _BumpMap("法线图", 2D) = "bump" {}
	// 	[Switch(LOD0,LOD1)][NoScaleOffset]_MixMap("混合图（R金属、G光滑、BAO、A自发光）", 2D) = "blue" {}		
	// 	[Space]
	// 	_BaseColor("颜色", Color) = (1,1,1,1)
	// 	[Space]
	// 	[Switch(LOD0,LOD1)] _Metallic("金属度", Range(0,1)) = 1
	// 	[Switch(LOD0,LOD1)] _Smoothness("平滑度", Range(0,1)) = 1	

	// 	[Foldout(1,2,0,1)] _EnableUV3("UV3_Foldout", float) = 1
	// 	[NoScaleOffset]_Base2Map("颜色图", 2D) = "black" {}
	// 	[Switch(LOD0)][NoScaleOffset] _Bump2Map("法线图", 2D) = "bump" {}
	// 	[Switch(LOD0,LOD1)][NoScaleOffset]_Mix2Map("混合图（R金属、G光滑、BAO、A自发光）", 2D) = "blue" {}		
	// 	[Space]
	// 	_BaseColor2("颜色", Color) = (1,1,1,1)
	// 	[Switch(LOD0,LOD1)] _Metallic2("金属度", Range(0,1)) = 1
	// 	[Switch(LOD0,LOD1)] _Smoothness2("平滑度", Range(0,1)) = 1	
	// 	[Foldout_Out(1)]_EnableUV3_e("_Foldout", float) = 1
		
	// 	[Foldout(1,2,0,1)] _EnableUV4("UV4（法线叠加）_Foldout", float) = 1
	// 	[Switch(LOD0,LOD1)][NoScaleOffset] _Bump3Map("法线图", 2D) = "bump" {}	
	// 	[Space]
	// 	[Foldout_Out(1)]_EnableUV4_e("_Foldout", float) = 1

	// 	[Space]
	// 	[Foldout(1,2,1,0,LOD0,LOD1)] _EnableEmission("自发光_Foldout", float) = 0
	// 	[Switch(LOD0,LOD1)][HDR] _EmissionColor("自发光颜色", Color) = (0,0,0)		
	// 	[Switch(LOD0,LOD1)][HDR] _EmissionColor2("UV3自发光颜色", Color) = (0,0,0)
	// 	[Foldout_Out(1)] _EnableEmission_e("_Foldout", float) = 1
		
	// 	[Space]
    //     [Enum(UnityEngine.Rendering.CullMode)]_Cull("剔除", Float) = 2.0
	// }

	// SubShader
	// {
	// 	Tags{"RenderType"="Opaque" "Queue" = "Geometry" }
	// 	Cull[_Cull]

	// 	HLSLINCLUDE
	// 		#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
	// 		#define UV3
	// 		#define UV4
	// 		#pragma multi_compile_instancing
	// 		#include "./UV4Input.hlsl"
	// 	ENDHLSL

	// 	pass
	// 	{
	// 		Tags{"LightMode" = "UniversalForward"}
            
	// 		HLSLPROGRAM
	// 		#pragma target 3.0
    //         #pragma vertex Vert
    //         #pragma fragment Frag			
	// 		#include "../../Library/CommonKeyword_Scene.hlsl"

    //         #define LIT
    //         #define BASEMAP
    //         #define NORMALMAP
			
	// 		#include "../../Library/Base.hlsl"
	// 		#include "./UV4ForwardPass.hlsl"
    //         ENDHLSL
	// 	}

	// }
	// CustomEditor"SimpleShaderGUI"
	// FallBack "Baha/Scene/Industry/Lit-Opaque"
}
