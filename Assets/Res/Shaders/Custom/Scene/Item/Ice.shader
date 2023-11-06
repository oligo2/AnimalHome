Shader "Baha/Scene/Item/Ice"
{
// 	Properties
// 	{
// 		[Button()] _CreateLodMat("创建LOD材质", float) = 0
// 		[Enum_Switch(LOD0,LOD1,LOD2)]_Lod("LOD分级", float) = 0

// 		_BaseMap("颜色图", 2D) = "white" {}
//         [Switch(LOD0)] [NoScaleOffset]_BumpMap("法线图（RGB法线)", 2D) = "bump" {}   //法线图为默认值并进行法线计算的话，所得到的表现与不进行法线计算的不一样。
// 		[MainColor] [HDR]_BaseColor("颜色", Color) = (1,1,1,1)
// 		_Depth("表面厚度", Range(1,50)) = 1
// 		_Alpha("透度", Range(0,1)) = 0.3

// 		[Space]
// 		[Foldout(1,2,1,0)] _EnableSolid("立体颜色图（3UV）_Foldout", float) = 1
// 		_SolidMap("立体颜色图", 2D) = "white" {}
// 		[HDR]_SolidColor("颜色", Color) = (1,1,1,1)
// 		[Toggle_Switch]_EnableAutoSolidUV("自动计算UV", float) = 1
// 		[Switch(_EnableAutoSolidUV)] _VertexRange("顶点坐标偏移距离(X,Y,Z)", Vector) = (0.5,0.5,0.5,0)		
// 		[Foldout_Out(1)] _EnableSolid_e("_Foldout", float) = 0
		

// 		[Space]
// 		[Foldout(1,2,0)] _EnableHeat("扭曲_Foldout", float) = 1
// 		_HeatMap("扭曲图 (RG)", 2D) = "white" {}
// 		_HeatIntensity("扭曲强度", Range(0,100)) = 1
// 		[Foldout_Out(1)] _EnableHeat_e("_Foldout", float) = 0
		
// 		[Space]
// 		[Foldout(1,2,1,0)] _EnableInside("内部纹理_Foldout", float) = 1
// 		_InsideMap("内部图", 2D) = "white" {}
// 		[HDR]_InsideColor("颜色", Color) = (1,1,1,1)
// 		_InsideDepth("深度", Range(1,100)) = 1
// 		[Foldout_Out(1)] _EnableInside_e("_Foldout", float) = 0
// 		[Space]

// 		[Text(1)]Tip("简介：
// 特性：		冰冻材质。
// 光照：		Phong光照原则。
// 影子：		冰块产生的影子比较弱，因此可以关闭影子。
// 透度:		决定冰块透射率。
// 立体颜色图：	表现一个自下而上的纹理，默认需要布置3UV来表现。
// 自动计算UV：	根据模型顶点位置自动计算立体UV。
// 顶点坐标偏移距离:指顶点距离0点的最短距离。如果最近顶点为（1,1,1），则偏移距离为（0.5,0.5,0.5）。
// 光滑度：	冰块光滑度始终为1。
// 内部纹理：	用来模拟冰块内部的结构。
// 深度：		调整到视角变换情况下，较为正常就行。
// ", float) = 1

// 		[HideInInspector] _WISHGI_State("WISHGI_State", Int) = 0		
// 	}

// 	SubShader
// 	{
// 		Tags{"RenderType"="_BaseMap" "Queue" = "Geometry+600"} 

// 		HLSLINCLUDE
// 			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
// 			#pragma multi_compile_instancing
// 			#include "./IceInput.hlsl"
			
//             #define LIT
//             #define BASEMAP
//             #define NORMALMAP
//             #define DEPTH
// 			#define PARALLAX
// 			#define SOLIDUV
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
// 			#include "../../Library/Base.hlsl"
// 			#include "IceForwardPass.hlsl"
//             ENDHLSL
// 		}
// 		Pass
// 		{
// 			Name "ShadowCaster"
// 			Tags { "LightMode" = "ShadowCaster" }
//             ColorMask 0

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


