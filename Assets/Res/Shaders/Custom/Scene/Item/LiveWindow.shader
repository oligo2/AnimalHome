Shader "Baha/Scene/Item/LiveWindow"
{
	// Properties
	// {
	// 	[Space]
	// 	[Text(1)]Tip("窗户材质, 根据昼夜时间改变效果。", float) = 1
	// 	[Space]

	// 	[Button()] _CreateLodMat("创建LOD材质", float) = 0
	// 	[Enum_Switch(LOD0,LOD1,LOD2)]_Lod("LOD分级", float) = 0

	// 	_BaseMap("颜色图", 2D) = "white" {}
    //     [Switch(LOD0)] [NoScaleOffset]_BumpMap("法线图（RGB法线)", 2D) = "bump" {} 
	// 	[Switch(LOD0,LOD1)] [NoScaleOffset]_MixMap("混合图（R金属、G光滑、BAO、A自发光）", 2D) = "white" {}
	// 	[MainColor]_BaseColor("颜色", Color) = (1,1,1,1)
	// 	[Switch(LOD0,LOD1)]_Metallic("金属度", Range(0,1)) = 1
	// 	[Switch(LOD0,LOD1)]_Smoothness("平滑度", Range(0,1)) = 1

	// 	[Space]
	// 	[Foldout(1,2,0)] _EnableWindow("窗户_Foldout", float) = 1
		
	// 	[NoScaleOffset]_WindowMask("遮罩图 (R:窗户 G:窗帘)", 2D) = "black" {}
	// 	[Toggle(_)]_IsProtal("室内窗口", float) = 0
	// 	_SkyWeight("反射程度", Range(0,1)) = 0.5
	// 	[HDR]_DayColor("日间颜色", Color) = (1,1,1)
	// 	[HDR]_NightColor("夜间颜色", Color) = (1,1,1)
	// 	[Vector2]_LightTime("开灯时间", float) = (18,22,1,1)
	// 	[Foldout_Out(1)] _EnableWindow_e("_Foldout", float) = 0

	// 	[Space]
	// 	[Foldout(1,2,1,0,LOD0,LOD1)] _EnableEmission("自发光_Foldout", float) = 0
	// 	[Switch(LOD0,LOD1)] [HDR] _EmissionColor("自发光颜色", Color) = (0,0,0)
	// 	[Foldout_Out(1)] _EnableEmission_e("_Foldout", float) = 1
		
	// 	//Hide
	// 	[HideInInspector] _WISHGI_State("WISHGI_State", Int) = 0

	// }

	// SubShader
	// {
	// 	Tags{"RenderType"="_BaseMap" "Queue" = "Geometry" } // 
	// 	Cull[Back]

	// 	HLSLINCLUDE
	// 		#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
	// 		#pragma multi_compile_instancing
	// 		#include "./LiveWindowInput.hlsl"
	// 		#define LIT
    //         #define BASEMAP
    //         #define NORMALMAP
	// 		#define DEPTH
	// 		#define PARALLAX
	// 	ENDHLSL

	// 	pass
	// 	{
	// 		Tags{"LightMode" = "UniversalForward"}

	// 		HLSLPROGRAM
	// 		#pragma target 3.0
    //         #pragma vertex Vert
    //         #pragma fragment Frag
	// 		#include "../../Library/CommonKeyword_Scene.hlsl"
	// 		#include "../../Library/Base.hlsl"
	// 		#include "./LiveWindowForwardPass.hlsl"
    //         ENDHLSL
	// 	}     
	// 	Pass
	// 	{
	// 		Name "ShadowCaster"
	// 		Tags { "LightMode" = "ShadowCaster" }

	// 		HLSLPROGRAM
	// 		#pragma vertex Vert
	// 		#pragma fragment Frag

	// 		#include "../../Library/Base_ShadowCaster.hlsl"
	// 		ENDHLSL
	// 	}
	// 	Pass
    //     {
    //         Name "DepthOnly"
    //         Tags{"LightMode" = "DepthOnly"}
    //         ColorMask 0

    //         HLSLPROGRAM
    //         #pragma vertex Vert
    //         #pragma fragment Frag

	// 		#include "../../Library/Base_DepthOnly.hlsl"
    //         ENDHLSL
    //     }
	// }  
	// CustomEditor"SimpleShaderGUI"
}