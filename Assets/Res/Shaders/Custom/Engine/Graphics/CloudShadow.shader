Shader "Oligo/Graphics/CloudShadow"
{
	Properties
	{
		
		_NoiseMap1("noise map", 2D) = "white" {}
		_NoiseMap2("noise map", 2D) = "white" {}
		
		_CloudDir("云影方向", Range(0, 360)) = 0
		_CloudBright("云影亮度", Range(0, 1)) = 0.2
		_CloudSpeed("云影速度", Range(0, 100)) = 0
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
            
			TEXTURE2D(_NoiseMap1);     SAMPLER(sampler_NoiseMap1);
			TEXTURE2D(_NoiseMap2);     SAMPLER(sampler_NoiseMap2);

			float _CloudDir;
			half _CloudSpeed;
			half _CloudBright;
            half _CloudDirX;
            half _CloudDirZ;

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
                half2 dir = half2(_CloudDirX, _CloudDirZ);
                float2 uv = i.uv + _Time.y * dir *  _CloudSpeed;

				half noise1 = SAMPLE_TEXTURE2D(_NoiseMap1, sampler_NoiseMap1, uv ).r;
				half noise2 = SAMPLE_TEXTURE2D(_NoiseMap2, sampler_NoiseMap2, uv ).r;

				noise1 = lerp(noise1, noise2,  abs(sin(_Time.y/5)) );

				float value = 1-noise1;

				value = saturate(value+_CloudBright);
                return value;
            }
            ENDHLSL
        }
	}  
}