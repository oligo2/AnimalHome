Shader "Oligo/Graphics/DrawTerrian"
{
	Properties
	{
		// _NoiseMap("noise map", 2D) = "white" {}
		
		_SourceMap("source map", 2D) = "black" {}
		_ShapeMap("shape map", 2D) = "black" {}
	}


    HLSLINCLUDE
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
   
        SamplerState sampler_LinearClamp;
        SamplerState sampler_LinearRepeat;
        // TEXTURE2D(_NoiseMap);     SAMPLER(sampler_NoiseMap);

        
        TEXTURE2D(_SourceMap);
        TEXTURE2D(_ShapeMap);
        float2 _Offset;
        float _Scale;


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

        v2f Vert (appdata v)
        {
            v2f o;
            o.pos = TransformObjectToHClip(v.vertex.xyz);			

            o.uv = v.uv;
            return o;
        }
        
        float4 Frag (v2f i) : SV_Target
        {
            // half noise = SAMPLE_TEXTURE2D(_NoiseMap, sampler_NoiseMap, i.uv ).r;
            return 0;
        }
        
        float4 FragHigh (v2f i) : SV_Target
        {

            float o = SAMPLE_TEXTURE2D(_SourceMap, sampler_LinearClamp, i.uv).r;
            // half4 color = half4(1, 1, 0, 1);


            half2 uv = (i.uv - _Offset.xy)*_Scale;

            if(uv.x < 0|| uv.x > 1)
                return o;
            if(uv.y < 0|| uv.y > 1)
                return o;


            float r = SAMPLE_TEXTURE2D(_ShapeMap, sampler_LinearClamp, (i.uv - _Offset.xy)*_Scale).r;


            return  max(r, o);
        }
    ENDHLSL

	SubShader
	{
		Tags{"Queue" = "Geometry"}
	    Pass
        {		
            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag
            ENDHLSL
            
			
        }
        
        Pass
        {
            Name "DrawHigh"

            HLSLPROGRAM
                #pragma vertex Vert
                #pragma fragment FragHigh
            ENDHLSL
        }
	}  
}