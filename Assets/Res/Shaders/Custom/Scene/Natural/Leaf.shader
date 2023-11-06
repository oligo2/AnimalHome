Shader "Baha/Scene/Natural/Leaf" //2023.3.4
{
// 	Properties
// 	{
// 		[Button()] _CreateLodMat("创建LOD材质", float) = 0
// 		[Enum_Switch(LOD0,LOD1,LOD2)]_Lod("LOD分级", float) = 0

// 		_BaseMap("混合图（R颜色，G光滑，BAO，A透明度）", 2D) = "white" {}
// 		_Base2Color ("颜色亮", Color) = (1,1,1,1)
// 		[MainColor] _BaseColor ("颜色暗", Color) = (1,1,1,1)
// 		_TopColor ("顶部颜色", Color) = (1,1,1,1)
// 		[Switch(LOD0,LOD1)]_Smoothness("平滑度", Range(0,1)) = 1
// 		_ShadowBright("阴影补亮", Range(0,1)) = 0
// 		_OcclusionForBright("AO对补亮的影响", Range(0, 1)) = 0
// 		[Toggle(_EnableTurnNormal)] _EnableTurnNormal("背面法线反转", Float) = 0.0000000
// 		[Toggle(_EnableShadow)] _EnableShadow("开启影子", Float) = 1.0000000
		
// 		[Space]
// 		[Foldout(1,2,0)]_EnableScattering("透射_Foldout", float) = 1			
// 		_ScatteringStrength("透射强度", Range(0, 5.0)) = 1		
// 		[HDR] _ScatteringColor("透射颜色", Color) = (0,0,0)
// 		[Foldout_Out(1)]_EnableScattering_e("_Foldout", float) = 1

// 		[Space]
// 		[Foldout(1,2,0)]_EnableWind("风浪_Foldout", float) = 1
// 		_WindSpeed("风速度", Range(0.0, 10.0)) = 1.6
// 		_WindMap("风浪", 2D) = "white" {}
// 		[Vector3]_WindDirection("风方向", vector) = (-1,1,1,0)
// 		_SwingingRange("摆动幅度", Range(0.0, 1.0)) = 0.25
// 		_SwingingRhythm("节奏差异", Range(0.0, 1.0)) = 0.2
// 		[Foldout_Out(1)]_EnableWind_e("_Foldout", float) = 1

// 		[Space]
// 		[Foldout(1,2,0)]_EnableClip("透明度裁剪_Foldout", float) = 0
// 		_Clip("裁剪值", Range(0.0, 1.0)) = 0.5
// 		[Foldout_Out(1)]_EnableClip_e("_Foldout", float) = 1

// 		[Space]
// 		[Toggle(_EnableShowVertexColor)] _EnableShowVertexColor("显示顶点色", Float) = 0.0000000
		
// 		[Space]
// 		[Text(1)]Tip("简介：
// 混合图：	R颜色，G光滑，BAO，A透明度
// 颜色：		由混合图R决定。0是颜色暗，1是颜色亮。
// AO：		取自顶点色R与混合图B通道。（对环境光、透射、边缘光都有影响） 
// 顶部颜色：	上半部叠加颜色。（根据球形法线判断）
// 透射：		光照方向叠加颜色。
// 阴影处补亮：	提升阴影亮度。
// ", float) = 1

// 		[HideInInspector] _WISHGI_State("WISHGI_State", Int) = 0
// 	}

// 	SubShader
// 	{
// 		Tags{"RenderType"="_BaseMap" "Queue" = "Geometry+472"}
// 		Cull Off

// 		HLSLINCLUDE
// 			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
// 			#pragma multi_compile_instancing
// 			#include "./NaturalInput.hlsl"
// 			#define _EnableWind
// 			#define _EnableClip

// 			#define LIT
// 			#define BASEMAP
// 			#define WORLDPOS
// 			#define VERTEXCOLOR
// 			#define GRADUALCOLOR
// 			#define TOPCOLOR
// 			#define SCATTERING
// 			#define NOSHADOW
// 			// #define INSERTCUTTING
// 		ENDHLSL

// 		pass
// 		{
// 			Name "ForwardLit"
// 			Tags{"LightMode" = "UniversalForward"}

// 			HLSLPROGRAM
// 			#pragma target 3.0
//             #pragma vertex Vert
//             #pragma fragment Frag
// 			#include "../../Library/CommonKeyword_Scene.hlsl"
			
// 			#include "../../Library/Base.hlsl"         
// 			#include "./LeafForwardPass.hlsl"
//             ENDHLSL
// 		}
//         Pass
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