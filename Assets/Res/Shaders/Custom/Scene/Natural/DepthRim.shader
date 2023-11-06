Shader "Baha/Scene/Natural/DepthRim" //深度边缘光 
{
	Properties
	{
		_BaseMap("颜色图", 2D) = "white" {}
		
		[Space]
		[Foldout(1,2,1,0)]_EnableDepthRim("深度边缘光_Foldout", float) = 1	
		_DepthRimWidth("边缘光宽度", Range(0.0001, 0.1)) = 0.02
		[HDR] _DepthRimColor("边缘光颜色", Color) = (0,0,0)
		_DepthRimScale("近处强度", Range(1, 10000)) = 200
		
		[Foldout_Out(1)]_EnableDepthRim_e("_Foldout", float) = 1

		[Space]
		[Foldout(1,2,1)]_EnableInteractive("交互_Foldout", float) = 1
		[Toggle(_EnableInteractiveWhole)] _EnableInteractiveWhole("交互时保持整体", Float) = 1.0000000		
		_InteractivePow("交互强度", Range(1, 10)) = 3
		[Foldout_Out(1)]_EnableInteractive_e("_Foldout", float) = 1

		[Space]
		[Foldout(1,2,0)]_EnableWind("风浪_Foldout", float) = 1
		_WindSpeed("风速度", Range(0.0, 10.0)) = 1.6
		_WindMap("风浪", 2D) = "white" {}
		[Vector3]_WindDirection("风方向", vector) = (-1,1,1,0)
		_SwingingRange("摆动幅度", Range(0.0, 1.0)) = 0.25
		_SwingingRhythm("节奏差异", Range(0.0, 1.0)) = 0.2
		[Foldout_Out(1)]_EnableWind_e("_Foldout", float) = 1

		[Space]
		[Foldout(1,2,0)]_EnableClip("透明度裁剪_Foldout", float) = 0
		_Clip("裁剪值", Range(0.0, 1.0)) = 0.5
		[Foldout_Out(1)]_EnableClip_e("_Foldout", float) = 1

		[Space]
		[Text(1)]Tip("简介：		
深度边缘光:	根据深度比较出的边缘光。
注意点：	所有参数必须与主对象一致。
", float) = 1

		[HideInInspector] _WISHGI_State("WISHGI_State", Int) = 0
	}

	SubShader
	{
		Tags{"RenderType"="_BaseMap" "Queue" = "Geometry+501" } // RenderType,用作SceneViewDebug的标识，意为albedo的属性    王英杰
		Cull off
		ZTest Equal
		ZWrite off
		Blend SrcAlpha OneMinusSrcAlpha


		HLSLINCLUDE
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#pragma multi_compile_instancing
			TEXTURE2D(_BaseMap);          SAMPLER(sampler_BaseMap);
			sampler2D _CameraDepthTexture;
			sampler2D _WindMap; 

			half _EnableInteractive;
			half _EnableInteractiveWhole;
			float _InteractivePow;

			float4 _WindMap_ST;
			float _WindSpeed;
			float4 _WindDirection;
			float _SwingingRange;
			float _SwingingRhythm;

			half4 _BaseMap_ST;
			half _Clip;

			half _DepthRimWidth;
			half _DepthRimScale;
			half4 _DepthRimColor;

			#define _EnableWind
            #define _EnableClip
			#define LIT
            #define BASEMAP
			#define DEPTH
			#define DEPTHRIM
		ENDHLSL

		pass
		{
			Tags{"LightMode" = "UniversalForward"}
            
			HLSLPROGRAM
			#pragma target 3.0
            #pragma vertex Vert
            #pragma fragment Frag
			#include "../../Library/CommonKeyword_Scene.hlsl"			
			
			#include "../../Library/Base.hlsl"

			half4 Frag(v2f i) : SV_Target
			{
				#if defined(INSTANCING_ON)
					UNITY_SETUP_INSTANCE_ID(i);
				#endif
				
				float2 uv = i.uvAndOther.xy;
				half4 baseColor = SAMPLE_TEXTURE2D( _BaseMap, sampler_BaseMap, uv );
				half alpha = baseColor.a;
				clip(alpha - _Clip);

				half4 color = 0;
         		float thisDepth = Linear01Depth(tex2D(_CameraDepthTexture, UnityStereoTransformScreenSpaceTex(i.projected.xy / i.projected.w)).r, _ZBufferParams);
         		float sceneDepth = Linear01Depth(tex2D(_CameraDepthTexture, UnityStereoTransformScreenSpaceTex(i.projected2.xy / i.projected2.w)).r, _ZBufferParams);

				half depth = min(1,(sceneDepth-thisDepth)*_DepthRimScale);
				depth = step(0.1, depth);
		        color.rgb =  _DepthRimColor.rgb *depth;
				
				//背光面和阴影处 不显示
				#if defined(MAIN_LIGHT_CALCULATE_CACHED_SHADOWS) || defined(MAIN_LIGHT_CALCULATE_SHADOWS)
					float4 shadowCoord = TransformWorldToShadowCoord(i.positionWS.xyz);
				#else
					float4 shadowCoord = float4(0, 0, 0, 0);
				#endif
        		half shadowAttenuation = MainLightRealtimeShadow(shadowCoord);
        		half NdotL = saturate(dot(i.normalWS, _MainLightPosition.xyz));

				color.a = depth* NdotL * shadowAttenuation;

				return color;
			}

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