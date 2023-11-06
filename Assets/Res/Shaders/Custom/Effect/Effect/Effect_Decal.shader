Shader "Baha/Effect/Effect_Decal"
{
    Properties
	{
		_BaseMap("贴图", 2D) = "white" {}      		 //贴图
		[HDR]_BaseColor("颜色", Color) = (0.5,0.5,0.5,0.5)   		//粒子颜色		
		_AlphaIntensity("透明度调整", range(0, 5)) = 1
		[Toggle(_EnableAlphaR)] _EnableAlphaR("以R值为颜色", Float) = 0.0

		[Space]
		[Foldout(1,2,1)]_EnableMask("遮罩_Foldout", float) = 0
		_MaskMap("遮罩图(R)", 2D) = "white" {}		
		// [Vector3]_MaskScrollAndRotate("UV动画", float) = (0, 0, 0, 0)
		[Toggle()]_MaskOffsetCustomEnable("遮罩Offset（texcoord1.zw）使用CustomData", Float) = 0.0
		_MaskThreshold("阈值", Range(0, 1)) = 0
		_MaskPow("强度", Range(0, 10)) = 1
		[Foldout_Out(1)]_EnableMask_e("_Foldout", float) = 0
		
		[Space]
		[Foldout(1,2,1)]_EnableDissolve("溶解_Foldout", float) = 0
	    _DissolveTex("溶解图", 2D) = "white" {}
		// [Vector3]_DissolveScrollAndRotate("UV动画", float) = (0, 0, 0, 0)
		[Toggle()]_DissolveSpeedCustomEnable("溶解速度（texcoord0.z）使用CustomData", Float) = 0.0
	    _DissolveSpeed("溶解速度", Range(0, 2)) = 1
	    _DissolveSize("扩散", Range(0.01, 1)) = 0.1 
	    _DissolveSoft("羽化", Range(0.01, 1)) = 0
	    [HDR]_DissolveColor("颜色", Color) = (1, 1, 1, 1)
		[Foldout_Out(1)]_EnableDissolve_e("_Foldout", float) = 0
		
		[Enum(Alpha,10, Additive,1)]_BlendDst("混合类型", float) = 1

		[HideInInspector]_BlendSrc("混合原因子", float) = 5
		[HideInInspector]_ColorMask("颜色Mask",float) = 15
		[HideInInspector]_OffsetFactor("偏移因子", Float) = 0
		[HideInInspector]_OffsetUnits("偏移单位", Float) = 0		
	}
	SubShader
	{
		Tags { "Queue" = "Transparent" }
		Blend[_BlendSrc][_BlendDst]
		ColorMask[_ColorMask]
        Cull Front
		Lighting Off
		ZWrite Off
        ZTest Always
		Offset[_OffsetFactor],[_OffsetUnits]

		//Decal不显示在角色上
		Stencil
		{
			ReadMask 8
			Ref 8
			Comp NotEqual
			Pass Keep
		}

		HLSLINCLUDE
		#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
		#include "./EffectInput.hlsl"
		#define DECAL
		ENDHLSL

        Pass
        {
			Name "BasePass"	
			
            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag
  
			#pragma multi_compile _ _EnableDissolve//溶解
			#pragma multi_compile _ ATMOSPHERE_ON
			#pragma multi_compile _ ATMOSPHERE_POSTPROCESS_ON

			#include "../../Library/BaseEffect.hlsl"
            ENDHLSL
        }
    }

	CustomEditor"SimpleShaderGUI"
}

