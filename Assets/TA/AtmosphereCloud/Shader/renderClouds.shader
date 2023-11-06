Shader "UniStorm/Clouds/Cloud Computing"
{
	SubShader
	{

        ZWrite Off
		ZTest LEqual
		//ZTest Always
		Cull Off
		Blend SrcAlpha OneMinusSrcAlpha
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

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

			sampler2D _Cloud;
			
			
			
			v2f vert (appdata v)
			{
				v2f o;

                float s = _ProjectionParams.z ;
				s = 5000;
                float4x4 mvNoTranslation =
                    float4x4(
                        float4(UNITY_MATRIX_V[0].xyz, 0.0f),
                        float4(UNITY_MATRIX_V[1].xyz, 0.0f),
                        float4(UNITY_MATRIX_V[2].xyz, 0.0f),
                        float4(0, 0, 0, 1.1)
                    );
                    
				//o.vertex = mul(UNITY_MATRIX_P, v.vertex);
                
				o.vertex = mul(mul(UNITY_MATRIX_P, mvNoTranslation), v.vertex *float4(s, s, s, 1));
				//o.vertex = mul(mul(UNITY_MATRIX_P, mvNoTranslation), v.vertex );
				//o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.uv = v.uv;
				return o;
			}
			
			fixed4 frag(v2f i) : SV_Target
			{
				
				//return fixed4(1,0,0,1);
				// sample the texture
				fixed4 col = tex2D(_Cloud, i.uv);
				return col;
			}
			ENDCG
		}
	}
}
