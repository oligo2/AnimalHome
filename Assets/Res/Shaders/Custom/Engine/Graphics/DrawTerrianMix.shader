Shader "Oligo/Graphics/DrawTerrian"
{
	Properties
	{
		_NoiseMap("noise map", 2D) = "white" {}
		
	}

	SubShader
	{
		Tags{"Queue" = "Geometry"}

		HLSLINCLUDE
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
		ENDHLSL

	    Pass
        {
            Tags{"LightMode" = "UniversalForward"}
			
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
			TEXTURE2D(_NoiseMap);     SAMPLER(sampler_NoiseMap);

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = TransformObjectToHClip(v.vertex.xyz);			

                o.uv = v.uv;
                return o;
            }
            
            float4 frag (v2f i) : SV_Target
            {
				half noise = SAMPLE_TEXTURE2D(_NoiseMap, sampler_NoiseMap, i.uv ).r;
                return noise;
            }
            ENDHLSL
        }
	}  
}