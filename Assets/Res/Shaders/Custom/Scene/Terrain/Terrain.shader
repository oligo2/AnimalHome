Shader "Oligo/Scene/Terrain/Terrain"
{
	Properties
	{
		[Enum_Switch(LOD0,LOD1,LOD2)] _Lod("LOD等级", float) = 0

		_BaseMap("草地图", 2D) = "white" {}

		
		_BaseMap2("沙滩图", 2D) = "white" {}

		
		_BaseMap3("沙漠图", 2D) = "white" {}

		
		// _BaseMap("颜色图", 2D) = "white" {}
        // [Switch(LOD0,LOD1)] [NoScaleOffset] _BumpMap("法线图", 2D) = "bump" {}
		// [NoScaleOffset] _MixMap("混合图（R金属、G高度、BAO）", 2D) = "blue" {}



		[NoScaleOffset] _HighMap("高度图", 2D) = "blue" {}		
		_High("高度", Range(0,200)) = 100
		
		[NoScaleOffset] _SplatMap("分层图（0.2-0.4, 0.4-0.6, 0.6-0.8, 0.8-1）", 2D) = "white" {}
		
		
		
		[MainColor] _BaseColor("颜色", Color) = (1,1,1,1)
		_Metallic("金属度", Range(0,1)) = 1
		_Smoothness("平滑度", Range(0,1)) = 1

		[Space]
		[Foldout(1,2,0)]TESSELLATION("曲面细分_Foldout", float) = 0
        _TessCount("强度", Range(0, 100)) = 1.0
		[Foldout_Out(1)] TESSELLATION_e("_Foldout", float) = 1
		
	}

	SubShader
	{
		Tags{"RenderType"="_BaseMap" "Queue" = "Geometry" }
		Cull Back
		
		HLSLINCLUDE
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"	
			#include "TerrainInput.hlsl"
            #define LIT
            #define BASEMAP
			#define WORLDPOS
            #define NORMALMAP
			#define HIGH
			#define TESSELLATION
		ENDHLSL

		Pass
		{
			Tags{"LightMode" = "UniversalForward"}

			HLSLPROGRAM
			#pragma target 3.0
            #pragma vertex Vert_ts
            #pragma fragment Frag
			#include "../../Library/CommonKeyword_Scene.hlsl"
			#pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS 	
			
			#include "../../Library/Base.hlsl"
			#include "TerrainForwardPass.hlsl"
            ENDHLSL			
		}
        Pass
		{
			Name "ShadowCaster"
			Tags { "LightMode" = "ShadowCaster" }

			HLSLPROGRAM
			#pragma vertex Vert
			#pragma fragment Frag

			#include "../../Library/Base_ShadowCaster.hlsl"
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

			#include "../../Library/Base_DepthOnly.hlsl"
            ENDHLSL
        }

	}
	CustomEditor"SimpleShaderGUI"
}