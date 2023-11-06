Shader "Baha/RendererFeature/CopyDepth"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "black" {}
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            sampler2D _CameraDepthTempTexture;
            sampler2D _MainTex;

			float _SceneWidth;
			float _SceneHeight;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
				
				float rat = _SceneHeight/_SceneWidth;

				v.uv.x -= 0.5;
				v.uv.x = v.uv.x * rat;
				v.uv.x += 0.5;

                o.uv = v.uv;
                return o;
            }
            
            fixed4 frag (v2f i) : SV_Target
            {
				// float a =_SceneHeight/400;
				// float b = a/_SceneWidth/400 ;

                // 内置 深度获取
                float depth = tex2D(_CameraDepthTempTexture, i.uv).r;
				// if(depth == 0)
				// 	depth = 1;
                float4 col = float4(depth, 0, 0, 1 );
                return col;
            }
            ENDCG
        }
    }
}