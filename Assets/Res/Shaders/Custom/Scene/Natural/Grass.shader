Shader "My/Scene/Natural/Grass" //2023.7.4
{
	Properties
	{
		_BaseMap("混合图（R草尖、G、B、A）", 2D) = "white" {}	
		_BaseColor ("草尖颜色", Color) = (1,1,1,1)
		_Smoothness("平滑度", Range(0,1)) = 1
		_ShadowBright("阴影补亮", Range(0,1)) = 0
		_BackBright("背面补亮", Range(0,1)) = 0
		// _OcclusionForBright("AO对补亮的影响", Range(0, 1)) = 0
		_SpecularPower("阳光聚集", Range(0,20)) = 5		
		_SpecularColor ("阳光颜色", Color) = (1,1,1,1)
		
		[Space]
		[Foldout(1,2,0)] _EnableInteractive("交互_Foldout", float) = 1
		_InteractivePow("交互强度", Range(0.01, 1)) = 0.1
		[Foldout_Out(1)] _EnableInteractive_e("_Foldout", float) = 1

		[Space]
		[Foldout(1,2,0)] _EnableWind("风动_Foldout", float) = 1		
		_WindColor ("麦浪颜色", Color) = (1,1,1,1)
		_WindSpeed("风速度", Range(0.0, 10.0)) = 2
		_WindMap("风浪（R强度）", 2D) = "white" {}
		_SwingingRange("摆动幅度", Range(0.0, 1.0)) = 0.1
		_SwingingRhythm("节奏差异", Range(0.0, 10.0)) = 5
		[Vector2]_WindDirection("风方向", vector) = (-1,1,0,0)
		[Foldout_Out(1)] _EnableWind_e("_Foldout", float) = 1

		[Space]
		[Foldout(1,2,1)] _EnableVT("VT_Foldout", float) = 1
		_VTFade("渐变", Range(0.1,1)) = 0.25  
		[Foldout_Out(1)] _EnableVT_e("_Foldout", float) = 1
		
		[Space]
		[Foldout(1,2,0)] _EnableTileColor("平铺颜色_Foldout", float) = 1
		_TileColorMap("平铺颜色图（100米）", 2D) = "green" {}
		[Foldout_Out(1)] _EnableTileColor_e("_Foldout", float) = 1
		
        [Space]
        [Foldout(1,2,0)] _EnableStencil("模板测试_Foldout", Float)                                 = 0
		[CustomStencil(NoHbao)] _Stencil("模板值", int) = 16
        [Foldout_Out(1)] _EnableStencil_e("_Foldout", Float)                                         = 1
        [Space]   

		[Space]
		[Foldout(1,2,0)] _EnableClip("透明度裁剪_Foldout", float) = 0
		_Clip("裁剪值", Range(0.0, 1.0)) = 0.5
		[Foldout_Out(1)] _EnableClip_e("_Foldout", float) = 1

		
		[Space]
		[Text(1)]Tip("简介：
混合图：	R草尖，G，B，A
颜色：		由平铺颜色决定。
平滑度:		只影响阳光高光强弱。 
阴影处补亮：	提升阴影亮度。
背面补亮：	提升模型反面亮度。

", float) = 1

		[Space]
		[HideInInspector] _WISHGI_State("WISHGI_State", Int) = 0
	}

	SubShader
	{
		Tags{"RenderType"="_BaseMap" "Queue" = "Geometry+473"} // RenderType,用作SceneViewDebug的标识，意为albedo的属性    王英杰            
		Cull Off


		HLSLINCLUDE
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#pragma multi_compile_instancing
			// #pragma multi_compile _ INDIREDCT
        	// #pragma instancing_options procedural:setup
       		// StructuredBuffer<float4> positionBuffer;
			// #define INDIREDCT

			#include "./GrassInput.hlsl"

			#define _EnableWind
			#define _EnableClip
            #define _NoNormal
            #define LOD0
			#define LIT
			#define BASEMAP
			#define WORLDPOS
			#define TILECOLOR
			#define GRASS
			#define SHADOWRAMP
		ENDHLSL

		pass
		{
			Stencil
			{  
				Ref [_Stencil]
				Comp Always
				Pass Replace
			}
			
			Name "ForwardLit"
			Tags{"LightMode" = "UniversalForward"}

			HLSLPROGRAM
			#pragma target 3.0
            #pragma vertex Vert
            #pragma fragment Frag
			#include "../../Library/CommonKeyword_Scene.hlsl"
						
			#include "../../Library/Base.hlsl"         
			#include "./GrassForwardPass.hlsl"
            ENDHLSL
		}
		// Pass
        // {
        //     Name "DepthOnly"
        //     Tags{"LightMode" = "DepthOnly"}
        //     ColorMask 0

        //     HLSLPROGRAM
        //     #pragma vertex Vert
        //     #pragma fragment Frag

		// 	#include "../../Library/Base_DepthOnly.hlsl"
        //     ENDHLSL
        // }
	}  
	CustomEditor"SimpleShaderGUI"
}