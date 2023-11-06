Shader "Baha/Scene/Natural/Tree"
{
// 	Properties
// 	{
// 		[Button()] _CreateLodMat("创建LOD材质", float) = 0
// 		[Enum_Switch(LOD0,LOD1,LOD2)]_Lod("LOD分级", float) = 0

// 		_BaseMap("颜色图", 2D) = "white" {}
// 		[Switch(LOD0)][NoScaleOffset]_BumpMap("法线图", 2D) = "bump" {}		
// 		[Switch(LOD0,LOD1)][NoScaleOffset]_MixMap("混合图（R、G光滑、BAO、A自发光）", 2D) = "white" {}
// 		[MainColor] _BaseColor("颜色", Color) = (1,1,1,1)
// 		[Switch(LOD0,LOD1)]_Smoothness("平滑度", Range(0,1)) = 1
// 		_ShadowBright("阴影处补亮", Range(0,1)) = 0
		
// 		[Space]
// 		[Foldout(1,2,0)]_EnableWind("风浪_Foldout", float) = 1
// 		_WindSpeed("风速度", Range(0.0, 10.0)) = 1.6
// 		_WindMap("风浪", 2D) = "white" {}
// 		[Vector3]_WindDirection("风方向", vector) = (-1,1,1,0)
// 		_SwingingRange("摆动幅度", Range(0.0, 1.0)) = 0.25
// 		_SwingingRhythm("节奏差异", Range(0.0, 1.0)) = 0.2
// 		[Foldout_Out(1)]_EnableWind_e("_Foldout", float) = 1

// 		[Space]
// 		[Foldout(1, 2, 1, 0,LOD0,LOD1)] _EnableEmission("自发光_Foldout", float) = 0
// 		[Switch(LOD0,LOD1)][HDR] _EmissionColor("自发光颜色", Color) = (0,0,0)
// 		[Foldout_Out(1)] _EnableEmission_e("_Foldout", float) = 1
		
// 		[Space]
// 		[HideInInspector] _WISHGI_State("WISHGI_State", Int) = 0
// 	}

// 	SubShader
// 	{
// 		Tags{"RenderType"="_BaseMap" "Queue" = "Geometry" } // RenderType,用作SceneViewDebug的标识，意为albedo的属性    王英杰            
// 		Cull Back

// 		HLSLINCLUDE
// 			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
// 			#pragma multi_compile_instancing
// 			#include "./NaturalInput.hlsl"
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

// 			#pragma multi_compile_fragment LOD0 LOD1 LOD2
//             #pragma multi_compile_fragment _ DEBUG_DISPLAY
// 			#define _EnableWind

// 			#define LIT
// 			#define BASEMAP
// 			#define WORLDPOS
// 			#define NORMALMAP
			
// 			#include "../../Library/Base.hlsl"         
// 			#include "./NaturalForwardPass.hlsl"
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