Shader "Oligo/Effect/Indicator/Arrow"
{
	Properties
	{
		[HDR]_Color("颜色（R颜色，G扫光Mask，B扫光形状）",color) = (1,1,1,1)
		_MainTex ("图片", 2D) = "white" {}
		_Intensity("亮度", Range(0.01,3)) = 1		
        _AlphaInCover("遮挡时的透明度", Range(0,1)) = 0.15
		
		[Foldout(1,2,0)] _EnableFlow("流动_Foldout", float) = 1
		_FlowColor("颜色",color) = (1,1,1,1)
		_Duration ("进度",range(0,2)) = 0	
		[Foldout_Out(1)] _EnableFlow_e("_Foldout", float) = 1

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

            #define ARROW

			#include "../../Library/BaseIndicator.hlsl"
            ENDHLSL
        }
    }
	CustomEditor"SimpleShaderGUI"
	FallBack "Hidden/ShadowAndDepth_Transparent"
}
