Shader "Baha/Effect/Indicator/Circle_Decal" 
{
    Properties 
    {
		[HDR]_Color("颜色（R颜色，G扫光Mask）",color) = (1,1,1,1)
		_MainTex ("图片", 2D) = "white" {}
		_Intensity("亮度", Range(0.01,3)) = 1
		_ProjectionAngleCut("超过此角度时裁剪(默认90)", Range(0,180)) = 90
        _ProjectionAngleAlpha("超过此角度时透明(默认30)", Range(0,90)) = 30
        _AlphaInAngle("超过角度时的透明度", Range(0,1)) = 0.5

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
        Cull Front
        ZWrite Off
        ZTest Always

		HLSLINCLUDE
		#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
		#include "IndicatorInput.hlsl"
		ENDHLSL

        Pass 
        {            
            //Decal不显示在角色上
            Stencil
            {
                ReadMask 8
                Ref 8
                Comp NotEqual
                Pass Keep
            }

            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag

            #define CIRCLE
            #define DECAL

			#include "../../Library/BaseIndicator.hlsl"
            ENDHLSL
        }
    }
	CustomEditor"SimpleShaderGUI"
	FallBack "Hidden/ShadowAndDepth_Transparent"
}
