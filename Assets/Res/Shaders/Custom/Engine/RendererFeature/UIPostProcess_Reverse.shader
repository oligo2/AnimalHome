Shader "Baha/RendererFeature/UIPostProcess_Reverse"
{
    Properties
    {
        [MainTexture]_MainTex ("Texture", 2D) = "black" {}
    }
    SubShader
    {
        Pass
        {
            HLSLPROGRAM

            #define	POSTPROCESS
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal@12.1.3/Shaders/PostProcessing/PostProcessingBase.hlsl"

			#pragma vertex Vert
			#pragma fragment Frag
            
            
            TEXTURE2D(_MainTex);
            
            half3 Frag (v2f i) : SV_Target
            {
                half3 color = SAMPLE_TEXTURE2D(_MainTex, sampler_LinearClamp, i.uv).rgb;
                color.rgb = pow(color.rgb, 0.45);
                return color;
            }

            ENDHLSL
        }
    }
}