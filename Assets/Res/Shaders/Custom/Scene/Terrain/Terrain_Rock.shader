Shader "Baha/Scene/Terrain/Terrian-Rock"
{
// 	Properties
// 	{
// 		[Button()] _CreateLodMat("创建LOD材质", float) = 0
// 		[Enum_Switch(LOD0,LOD1,LOD2)]_Lod("LOD分级", float) = 0
		
// 		[Text]_Text("顶点色 (A通道为顶点AO)", float) = 0
// 		[Space]
// 		_Slope("坡度", Range(-1, 1.0)) = 0
// 		_SlopeFade("坡度过渡", Range(0.01, 1.0)) = 0.8
// 		[Vector3(1)]_UPNormal("上方向", Vector) = (0,1,0,0)
// 		_ShadowColor("影子颜色", Color) = (1,1,1,1)

// 		[Space]
// 		[Foldout(1,2,0,1)] _HighModel("高模_Foldout", float) = 1
// 		[Switch(LOD0)] [Normal]_MainTex("高模法线图", 2D) = "bump" {}
// 		_BumpScale0("法线强度", Range(0, 2)) = 1
// 		[Foldout_Out(1)]_HighModel_e("_Foldout", float) = 1

// 		[Space]
// 		[Foldout(1,2,0,1)] _Rock("石头_Foldout", float) = 1
// 		[MainTexture]_BaseMap("颜色图", 2D) = "white" {}
// 		[Switch(LOD0)] [Normal] [NoScaleOffset] _BumpMap("法线图", 2D) = "bump" {}
// 		[Switch(LOD0,LOD1)] [NoScaleOffset]_MixMap("混合图（R金属、G光滑、BAO）", 2D) = "white" {}
// 		_Color("颜色", Color) = (1,1,1,1)
// 		_BumpScale("法线强度", Range(0, 2)) = 1	
// 		_Metallic("金属度", Range(0.0, 1.0)) = 0.0
// 		_Smoothness("光滑度", Range(0.0, 1.0)) = 0.5		
// 		[Foldout_Out(1)]_Rock_e("_Foldout", float) = 1

// 		[Space]
// 		[Foldout(1,2,0,1)] _Grass("草地_Foldout", float) = 1
// 		_Color2Map("颜色图", 2D) = "white" {}
// 		[Switch(LOD0)] [NoScaleOffset][Normal]_Bump2Map("法线图", 2D) = "bump" {}
// 		[Switch(LOD0,LOD1)] [NoScaleOffset]_Mix2Map("混合图（R金属、G光滑、BAO）", 2D) = "white" {}
// 		_Color2("颜色", Color) = (1,1,1,1)
// 		_BumpScale2("法线强度", Range(0, 2)) = 1	
// 		_Metallic2("金属度", Range(0.0, 1.0)) = 0.0
// 		_Smoothness2("光滑度", Range(0.0, 1.0)) = 0.5
// 		[Foldout_Out(1)]_Grass_e("_Foldout", float) = 1

// 		[Space]
// 		[Foldout(1,2,1)] _EnableHuge("大地块颜色_Foldout", float) = 0
// 		_HugeMap("大地块图（1000米）", 2D) = "black" {}
// 		_HugeStrength("强度比例",Range(0,1)) = 1
// 		[Foldout_Out(1)] _EnableHuge_e("_Foldout", float) = 1
		
// 		[Space]
// 		[Foldout(1,2,0,1)] _EnableVT("VT_Foldout", float) = 1
// 		_VTFade("石头渐变", Range(0.1,3)) = 0.4
// 		_VTFade2("草地渐变", Range(0.1,3)) = 1.5
// 		[Foldout_Out(1)] _EnableVT_e("_Foldout", float) = 1
// 	}

// 	SubShader
// 	{
// 		Tags{"RenderType"="_BaseMap" "Queue" = "Geometry" } // RenderType,用作SceneViewDebug的标识，意为albedo的属性名    By 王英杰            
// 		Cull Back

// 		HLSLINCLUDE
// 			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"	
// 			#pragma multi_compile_instancing
// 			#include "./Terrain_RockInput.hlsl"

//             #define LIT
// 			#define WORLDPOS
//             #define NORMALMAP
// 			#define VERTEXCOLOR
// 			#define SHADOWRAMP
// 		ENDHLSL

// 		pass
// 		{
// 			Tags{"LightMode" = "UniversalForward"}

// 			HLSLPROGRAM
// 			#pragma target 3.0
//             #pragma vertex Vert
//             #pragma fragment Frag
			
// 			#include "../../Library/CommonKeyword_Scene.hlsl"
//             #pragma multi_compile _ _TERRAIN_VT_ENABLED
			
// 			#include "../../Library/Base.hlsl"
// 			#include "./Terrain_RockForwardPass.hlsl"
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