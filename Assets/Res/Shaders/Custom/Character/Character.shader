Shader "My/Character/Character"
{
	Properties
	{
		[Enum_Switch(LOD0,LOD1,LOD2)] _Lod("LOD等级", float) = 0

		_BaseMap("颜色图", 2D) = "white" {}
        [Switch(LOD0,LOD1)] [NoScaleOffset] _BumpMap("法线图", 2D) = "bump" {}
		[NoScaleOffset] _MixMap("混合图（R为金属、G为光滑、B为AO）", 2D) = "blue" {}
		
		[NoScaleOffset] _SplatMap("分层图（R为PBR，G为毛发）", 2D) = "white" {}
		[MainColor] _BaseColor("颜色", Color) = (1,1,1,1)
		_Metallic("金属度", Range(0,1)) = 1
		_Smoothness("平滑度", Range(0,1)) = 1
		
		[Space]
		[Foldout(1,2,1,1)]_EnableFur("绒毛_Foldout", float) = 0
		[NoScaleOffset]_FurMap("绒毛图", 2D) = "white" {}
		_FurLength("长度", Range(0.0, 1.0)) = 0.1
        _FurShape("粗细", Range(0.5, 5)) = 1.0

		[Space]
        [Vector3(1)]_FurDir("生长方向", Vector) = (0, -1, 0, 0)
		_FurDirStrength("弯曲力度", Range(0.0, 1.0)) = 0.1

		[Space]
		[Text]Tip("   【模拟绒毛互相遮挡】", float) = 1
        _FurRootDarknessColor("根部颜色", Color) = (0.0, 0.0, 0.0, 1.0)
        _FurRootDarknessPower("强度", Range(0, 5)) = 1.0

		[Space]
		[Text]Tip("   【Kajiya-Kay高光】", float) = 1
        [HDR]_KKColor("高光颜色", Color) = (1, 1, 1, 1)
        _KKExponent("高光集中度", Range(0, 30)) = 15
        _KKShift("高光偏移", Range(-1, 1)) = 0
		[Foldout_Out(1)] _EnableFur_e("_Foldout", float) = 1
				

		[Space]
		[Foldout(1,2,1,1)]_EnableTess("曲面细分_Foldout", float) = 0
        _TessCount("强度", Range(0, 10)) = 1.0
		[Foldout_Out(1)] _EnableTess_e("_Foldout", float) = 1


		[Space]
        [Enum(UnityEngine.Rendering.CullMode)] _Cull("剔除", Float) = 2.0
	}

	SubShader
	{
		Tags{"RenderType"="_BaseMap" "Queue" = "Geometry" }
		
		HLSLINCLUDE
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"	
			#include "CharacterInput.hlsl"
            #define LIT
            #define BASEMAP
			#define WORLDPOS
            #define NORMALMAP
			#define TESSELLATION
		ENDHLSL

		pass
		{
			Tags{"LightMode" = "UniversalForward"}
			Cull[_Cull]

			HLSLPROGRAM
			#pragma target 3.0
            #pragma vertex Vert
            #pragma fragment Frag
			#include "../Library/CommonKeyword_Character.hlsl"
			#pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS 
            #pragma shader_feature_local_fragment _FEVER_DECAL_ENABLE			
			
			#include "../Library/Base.hlsl"
			#include "CharacterForwardPass.hlsl"
            ENDHLSL			
		}
		pass
		{
			Tags{"LightMode" = "FurPass"}
			Cull off

			HLSLPROGRAM
			#pragma target 3.0
            #pragma vertex Vert
            #pragma fragment Frag
			#define FUR
			#include "../Library/CommonKeyword_Character.hlsl"
			#pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS 
            #pragma shader_feature_local_fragment _FEVER_DECAL_ENABLE			
			
			#include "../Library/Base.hlsl"
			#include "CharacterForwardPass.hlsl"
            ENDHLSL			
		}
        Pass
		{
			Name "ShadowCaster"
			Tags { "LightMode" = "ShadowCaster" }

			HLSLPROGRAM
			#pragma vertex Vert
			#pragma fragment Frag

			#include "../Library/Base_ShadowCaster.hlsl"
			ENDHLSL
		}
		Pass
        {
            Name "DepthOnly"
            Tags{"LightMode" = "DepthOnly"}
            ColorMask 0

            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag

			#include "../Library/Base_DepthOnly.hlsl"
            ENDHLSL
        }

	}
	CustomEditor"SimpleShaderGUI"
}