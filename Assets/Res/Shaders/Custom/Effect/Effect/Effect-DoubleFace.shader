Shader "Baha/Effect/Effect-DoubleFace"
{
    Properties
	{
		_BaseMap("贴图", 2D) = "white" {}      		 //贴图
		[Vector3]_BaseScrollAndRotate("UV动画(xy位移，z旋转)", float) = (0, 0, 0, 0)
		[Toggle()]_OffsetCustomEnable("Offset（texcoord2.xy）使用CustomData", Float) = 0.0
		[Toggle()]_EraseCustomEnable("擦除（texcoord1.xy）使用CustomData", Float) = 0.0
		[HDR]_BaseColor("颜色", Color) = (0.5,0.5,0.5,0.5)   		//粒子颜色		
		_AlphaIntensity("透明度调整", range(0, 5)) = 1
		[Toggle(_EnableAlphaR)] _EnableAlphaR("以R值为颜色", Float) = 0.0000000


		[Foldout(1,2,1)]_EnableSaturation("饱和度_Foldout", float) = 0
		_Saturation("饱和度", range(0, 1)) = 1

		[Space]
		[Foldout(1,2,1)]_EnableDepthFade("穿插虚化(Game窗口才有效果)_Foldout", float) = 0
		_DepthFadeIndensity("虚化度", range(0.01, 100)) = 1
		[Foldout_Out(1)]_EnableDepth_e("_Foldout", float) = 0

		[Space]
		[Foldout(1,2,1)]_EnableMask("遮罩_Foldout", float) = 0
		_MaskMap("遮罩图(R)", 2D) = "white" {} 
		[Vector3]_MaskScrollAndRotate("UV动画", float) = (0, 0, 0, 0)
		[Toggle()]_MaskOffsetCustomEnable("遮罩Offset（texcoord1.zw）使用CustomData", Float) = 0.0
		_MaskThreshold("阈值", Range(0, 1)) = 0
		_MaskPow("强度", Range(0, 10)) = 1
		[Foldout_Out(1)]_EnableMask_e("_Foldout", float) = 0
		
		[Space]
		[Foldout(1,2,1)]_EnableMask1("遮罩2_Foldout", float) = 0
		_MaskMap1("遮罩图1(R)", 2D) = "white" {} 
		[Vector3]_MaskScrollAndRotate1("UV动画2", float) = (0, 0, 0, 0)
		_MaskThreshold1("阈值2", Range(0, 1)) = 0
		_MaskPow1("强度2", Range(0, 10)) = 1
		[Foldout_Out(1)]_EnableMask1_e("_Foldout", float) = 0
		
		[Space]
		[Foldout(1,2,1)]_EnableDistort("扰动_Foldout", float) = 0
		_DistortMap("扰动图 (RG)", 2D) = "white" {}
		[Vector3]_DistortScrollAndRotate("UV动画", float) = (0, 0, 0, 0)
		_DistortScale("扰动缩放", float) = 1
		[Foldout_Out(1)]_EnableDistort_e("_Foldout", float) = 0

		[Space]
		[Foldout(1,2,1)]_EnableDissolve("溶解_Foldout", float) = 0
	    _DissolveTex("溶解图", 2D) = "white" {}
		[Vector3]_DissolveScrollAndRotate("UV动画", float) = (0, 0, 0, 0)
		[Toggle()]_DissolveSpeedCustomEnable("溶解速度（texcoord0.z）使用CustomData", Float) = 0.0
	    _DissolveSpeed("溶解速度", Range(0, 2)) = 1
	    _DissolveSoft("羽化", Range(0, 1)) = 0
	    _DissolveSize("扩散", Range(0, 1)) = 0.1 
	    [HDR]_DissolveColor("颜色", Color) = (1, 1, 1, 1)
		[Foldout_Out(1)]_EnableDissolve_e("_Foldout", float) = 0

		[Space]
		[Foldout(1,2,1)]_EnableRimColor("边缘相关_Foldout", float) = 0
		[HDR]_RimColor("边缘光颜色", Color) = (0,0,0,0)
		_RimWidth("边缘宽度", Range(0.01, 2)) = 0.01
		_RimFade("边缘虚化", Range(0, 2)) = 0
		[Foldout_Out(1)]_EnableRimColor_e("_Foldout", float) = 0
        				
		[Space]
		[Foldout(1,2,1)]_EnableVertexAnim("顶点动画_Foldout", float) = 0
		_VertexAnimMap("顶点动画图 (R)", 2D) = "white" {}
		[Vector3]_VertexAnimScrollAndRotate("UV动画", float) = (0, 0, 0, 0)
		[Vector3]_VertexOffset("顶点偏移", float) = (0, 0, 0, 0)
		_VertexOffsetPow("偏移强度", range(0,10)) = 5
		[Foldout_Out(1)]_EnableVertexAnim_e ("_Foldout", float) = 1
		
		[Space]
		[Foldout(1,2,1)]_EnableFrontBackColor("正反面颜色_Foldout",float) = 0
		[HDR]_ColorFront("正面颜色",Color) = (1,1,1,1)
		[HDR]_ColorBack("背面颜色",Color) = (0,0,0,1)
		[Foldout_Out(1)]_EnableFrontBackColor_e("_Foldout",float) = 1
		
		[HideInInspector]_OffsetFactor("偏移因子", Float) = 0
		[HideInInspector]_OffsetUnits("偏移单位", Float) = 0		
	}
	SubShader
	{
		Tags {
				"Queue" = "Transparent" 
				"IgnoreProjector" = "True"  
				"RenderType" = "Transparent"
			}

		Offset[_OffsetFactor],[_OffsetUnits]

		HLSLINCLUDE
		#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
		#include "./EffectInput.hlsl"
		ENDHLSL
		
		Pass
        {
			Name "DepthWrite"	
			Tags {"LightMode"="SRPDefaultUnlit"}
        	
        	ZWrite Off
        	Blend SrcAlpha OneMinusSrcAlpha 
        	Cull Front
        	ZTest LEqual
        	
            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag

			#include "./EffectKeyword.hlsl"
			#include "../../Library/BaseEffect.hlsl"
            ENDHLSL
        }

        Pass
        {
			Name "BasePass"	
			Tags {"LightMode"="UniversalForward"}
        	
        	ZWrite Off
        	Blend SrcAlpha OneMinusSrcAlpha 
        	Cull Back
        	ZTest LEqual
        	
            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag

			#include "./EffectKeyword.hlsl"
			#include "../../Library/BaseEffect.hlsl"
            ENDHLSL
        }
    }

	CustomEditor"SimpleShaderGUI"
}

