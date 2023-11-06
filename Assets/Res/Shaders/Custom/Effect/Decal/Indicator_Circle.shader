Shader "Baha/Effect/Indicator/Circle" 
{
    Properties 
    {
		[HDR]_Color("颜色（R颜色，G扫光Mask）",color) = (1,1,1,1)
		_MainTex ("图片", 2D) = "white" {}
		_Intensity("亮度", Range(0.01,3)) = 1		
        _AlphaInCover("遮挡时的透明度", Range(0,1)) = 0.15

		[Foldout(1,2,0)] _EnableSector("伞形_Foldout", float) = 1
        _Angle ("角度", Range(0, 360)) = 60
        _Outline ("描边宽度", Range(0, 5)) = 0.35
        _OutlineAlpha("描边透明度",Range(0,1)) = 0.5
		[Foldout_Out(1)] _EnableSector_e("_Foldout", float) = 1


		[Foldout(1,2,0)] _EnableFlow("流动_Foldout", float) = 0
        _FlowColor("颜色",color) = (1,1,1,1)
        _FlowFade("渐变",range(0,1)) = 1
        _Duration("进度",range(0,2)) = 0
		[Foldout_Out(1)] _EnableFlow_e("_Foldout", float) = 1

    }

    SubShader 
    {
        Tags { "Queue"="Transparent" "RenderType" = "Transparent" "IgnoreProjector" = "True" "RenderPipeline" = "UniversalPipeline" }
        Blend SrcAlpha OneMinusSrcAlpha 
        ZWrite Off

		HLSLINCLUDE
		#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
		#include "IndicatorInput.hlsl"
		ENDHLSL

        Pass 
        {            
            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag

            #define CIRCLE

			#include "../../Library/BaseIndicator.hlsl"
            ENDHLSL
        }
    }
	CustomEditor"SimpleShaderGUI"
	FallBack "Hidden/ShadowAndDepth_Transparent"
}
