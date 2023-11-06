Shader "Baha/Effect/Effect_Haet"
{
    Properties
	{
		_BaseMap("贴图（R:Mask）", 2D) = "white" {}      		 //贴图
		[Vector3]_BaseScrollAndRotate("UV动画(xy位移，z旋转)", float) = (0, 0, 0, 0)
		[Toggle()]_OffsetCustomEnable("Offset（texcoord2.xy）使用CustomData", Float) = 0.0
		[Toggle()]_EraseCustomEnable("擦除（texcoord1.xy）使用CustomData", Float) = 0.0
		_AlphaIntensity("透明度调整", range(0, 5)) = 1
		[HDR]_BaseColor("颜色", Color) = (0.5,0.5,0.5,0.5)   		//粒子颜色		
	
        
		//热扭曲
		[Space]
		[Foldout(1,2,0,1)]_EnableHeat("热扰动_Foldout", float) = 1
		_HeatMap("热力图 (RG)", 2D) = "white" {}
		[Vector3]_HeatScrollAndRotate("UV动画", float) = (0, 0, 0, 0)
		_HeatPow("扰动强度", range(0,30)) = 10
		[Foldout_Out(1)]_EnableHeat_e("_Foldout", float) = 0
						
		[Enum(UnityEngine.Rendering.CullMode)]_CullMode("剔除",float) = 2
		[Enum(Disable, 0, LEqual, 2, Always, 6)]_ZTest("深度测试", float) = 2
		[HideInInspector]_ColorMask("颜色Mask",float) = 15
		[HideInInspector]_OffsetFactor("偏移因子", Float) = 0
		[HideInInspector]_OffsetUnits("偏移单位", Float) = 0
	}
	SubShader
	{
		Tags { "Queue" = "Transparent+1600" }
		Blend SrcAlpha OneMinusSrcAlpha 
		ColorMask[_ColorMask]
		Cull[_CullMode]
		Lighting Off
		ZWrite Off
		ZTest [_ZTest]
		Offset[_OffsetFactor],[_OffsetUnits]

		HLSLINCLUDE
		#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
		#include "./EffectInput.hlsl"
		ENDHLSL

        Pass
        {
			Name "BasePass"	
			
            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag
			#define _EnableHeat

			#include "./EffectKeyword.hlsl"
			#include "../../Library/BaseEffect.hlsl"
            ENDHLSL
        }
    }

	CustomEditor"SimpleShaderGUI"
}

