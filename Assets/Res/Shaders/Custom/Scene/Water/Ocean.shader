Shader "Oligo/Scene/Water/Ocean"
{
	Properties
	{
		[Enum_Switch(LOD0,LOD1,LOD2)] _Lod("LOD等级", float) = 0

		_BaseColor("浅层颜色", Color) = (1,1,1,1)
		_BaseColor2("深层颜色", Color) = (1,1,1,1)

		_Scale("scale", float) = 1
		_Alpha("透明度", float) = 1
        [NoScaleOffset]_BumpMap("法线图（RGB法线)", 2D) = "bump" {}   //法线图为默认值并进行法线计算的话，所得到的表现与不进行法线计算的不一样。
		
		[NoScaleOffset] _HighMap("高度图", 2D) = "blue" {}	

	}

	SubShader
	{
		Tags{"RenderType"="_BaseMap" "Queue" = "Geometry" } 
		Blend SrcAlpha OneMinusSrcAlpha

		HLSLINCLUDE
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "./OceanInput.hlsl"
			
		ENDHLSL

		pass
		{
			Tags{"LightMode" = "UniversalForward"}

			HLSLPROGRAM
			#pragma target 3.0
            #pragma vertex Vert
            #pragma fragment Frag
 		
			#include "../../Library/CommonKeyword_Scene.hlsl"
			
            #define LIT
            #define NOMAP
			#define WORLDPOS
            #define NORMALMAP
			
			#include "../../Library/Base.hlsl"
			#include "./OceanForwardPass.hlsl"
            ENDHLSL
		}
	}  
	CustomEditor"SimpleShaderGUI"
}


