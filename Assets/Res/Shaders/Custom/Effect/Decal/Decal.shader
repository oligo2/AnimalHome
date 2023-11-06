Shader "Oligo/Effect/Decal/Decal"
{
	Properties
	{
		[HDR]_Color("颜色",color) = (1,1,1,1)
		_MainTex ("图片", 2D) = "white" {}
		_Intensity("亮度", Range(0.01,3)) = 1		
        _AlphaInCover("遮挡时的透明度", Range(0,1)) = 0.15	
	}

    SubShader 
    {
        Tags { "Queue"="Transparent" "RenderType" = "Transparent" "IgnoreProjector" = "True" "RenderPipeline" = "UniversalPipeline" }
        Blend SrcAlpha OneMinusSrcAlpha 
        ZWrite Off
        ZTest Always

		HLSLINCLUDE
		#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
		#include "IndicatorInput.hlsl"
		ENDHLSL

        Pass 
        {            
            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag

			#include "../../Library/BaseIndicator.hlsl"
            ENDHLSL
        }
    }
	CustomEditor"SimpleShaderGUI"
}
