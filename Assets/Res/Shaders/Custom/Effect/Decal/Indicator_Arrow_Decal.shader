Shader "Baha/Effect/Indicator/Arrow_Decal"
{
	Properties
	{
		[HDR]_Color("颜色（R颜色，G扫光Mask，B扫光形状）",color) = (1,1,1,1)
		_MainTex ("图片", 2D) = "white" {}
		_Intensity("亮度", Range(0.01,3)) = 1
		_ProjectionAngleCut("需要裁剪的角度值(默认90)", Range(0,180)) = 90
        _ProjectionAngleAlpha("需要透明的角度值(默认30)", Range(0,90)) = 30
        _AlphaInAngle("透明值", Range(0,1)) = 0.5
		
		[Foldout(1,2,0)] _EnableFlow("流动_Foldout", float) = 0
		_FlowColor("颜色",color) = (1,1,1,1)
		_Duration ("进度",range(0,2)) = 0	
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

            #define ARROW
            #define DECAL

			#include "../../Library/BaseIndicator.hlsl"
            ENDHLSL
        }
    }
	CustomEditor"SimpleShaderGUI"
	FallBack "Hidden/ShadowAndDepth_Transparent"
}
