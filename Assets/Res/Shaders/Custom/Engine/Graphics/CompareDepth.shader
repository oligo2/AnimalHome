Shader "Baha/Graphics/CompareDepth"   //对比两个深度图，保留指定部分
{	
	Properties
	{
        [Header(Base)]
		[MainTexture] _BaseMap("主深度图", 2D) = "white" {}
	}

	HLSLINCLUDE
	#define BASEMAP
	#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

	TEXTURE2D(_BaseMap);      SAMPLER(sampler_BaseMap);
	TEXTURE2D(_CompareMap);     SAMPLER(sampler_CompareMap);

	CBUFFER_START(UnityPerMaterial)
	half4 _BaseMap_ST;
	CBUFFER_END
	#include "../../Library/Base_PostProcess.hlsl"

	half4 FragCompare(v2f i) : SV_Target
	{
		float2 uv = i.uvAndOther.xy;
		half4 col = SAMPLE_TEXTURE2D( _BaseMap, sampler_BaseMap, uv );

		if (col.r > 0.02 || col.g > 0.02 || col.b > 0.02)
		{
			return half4(1, 1, 0, 0);
		}
		else
		{
			return 0;
		}
	}

	half4 FragBlurH(v2f i) : SV_Target
	{
		float2 uv = i.uvAndOther.xy;
		float texelSize = 0.003;

		// 9-tap gaussian blur on the downsampled source
		half c0 = (SAMPLE_TEXTURE2D_X(_BaseMap, sampler_LinearClamp, uv - float2(texelSize * 4, 0))).g;
		half c1 = (SAMPLE_TEXTURE2D_X(_BaseMap, sampler_LinearClamp, uv - float2(texelSize * 3, 0))).g;
		half c2 = (SAMPLE_TEXTURE2D_X(_BaseMap, sampler_LinearClamp, uv - float2(texelSize * 2, 0))).g;
		half c3 = (SAMPLE_TEXTURE2D_X(_BaseMap, sampler_LinearClamp, uv - float2(texelSize * 1, 0))).g;
		half4 c4 = (SAMPLE_TEXTURE2D_X(_BaseMap, sampler_LinearClamp, uv                          ));
		half c5 = (SAMPLE_TEXTURE2D_X(_BaseMap, sampler_LinearClamp, uv + float2(texelSize * 1, 0))).g;
		half c6 = (SAMPLE_TEXTURE2D_X(_BaseMap, sampler_LinearClamp, uv + float2(texelSize * 2, 0))).g;
		half c7 = (SAMPLE_TEXTURE2D_X(_BaseMap, sampler_LinearClamp, uv + float2(texelSize * 3, 0))).g;
		half c8 = (SAMPLE_TEXTURE2D_X(_BaseMap, sampler_LinearClamp, uv + float2(texelSize * 4, 0))).g;

		half color = c0  + c1  + c2  + c3
					+ c4.g
					+ c5  + c6  + c7  + c8 ;
		color/= 9;

		return half4(c4.r, color, c4.r, c4.r);
	}

	half4 FragBlurV(v2f i) : SV_Target
	{
		float2 uv = i.uvAndOther.xy;
		float texelSize =  0.003;

		// Optimized bilinear 5-tap gaussian on the same-sized source (9-tap equivalent)
		half c0 = (SAMPLE_TEXTURE2D_X(_BaseMap, sampler_LinearClamp, uv - float2(0, texelSize * 4))).g;
		half c1 = (SAMPLE_TEXTURE2D_X(_BaseMap, sampler_LinearClamp, uv - float2(0, texelSize * 3))).g;
		half c2 = (SAMPLE_TEXTURE2D_X(_BaseMap, sampler_LinearClamp, uv - float2(0, texelSize * 2))).g;
		half c3 = (SAMPLE_TEXTURE2D_X(_BaseMap, sampler_LinearClamp, uv - float2(0, texelSize * 1))).g;
		half4 c4 = (SAMPLE_TEXTURE2D_X(_BaseMap, sampler_LinearClamp, uv                          ));
		half c5 = (SAMPLE_TEXTURE2D_X(_BaseMap, sampler_LinearClamp, uv + float2(0, texelSize * 1))).g;
		half c6 = (SAMPLE_TEXTURE2D_X(_BaseMap, sampler_LinearClamp, uv + float2(0, texelSize * 2))).g;
		half c7 = (SAMPLE_TEXTURE2D_X(_BaseMap, sampler_LinearClamp, uv + float2(0, texelSize * 3))).g;
		half c8 = (SAMPLE_TEXTURE2D_X(_BaseMap, sampler_LinearClamp, uv + float2(0, texelSize * 4))).g;

		half color = c0  + c1  + c2  + c3
					+ c4.g
					+ c5  + c6  + c7  + c8 ;
		color/= 9;

		return half4(c4.r, color, c4.r, c4.r);
	}

	ENDHLSL

	SubShader
	{
		pass   
		{
            Name "CompareDepth"
			HLSLPROGRAM
				#pragma vertex Vert
				#pragma fragment FragCompare			
			ENDHLSL			
		} 
		
		pass   
		{
            Name "BlurH"
			HLSLPROGRAM
				#pragma vertex Vert
				#pragma fragment FragBlurH			
			ENDHLSL			
		} 

		pass   
		{
            Name "BlurV"
			HLSLPROGRAM
				#pragma vertex Vert
				#pragma fragment FragBlurV			
			ENDHLSL			
		} 
	}
}