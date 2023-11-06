Shader "Baha/MirrorReflection/MirrorReplace"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_MirrorReplaceParam ("MirrorReplaceParam", Vector) = (300,1,0,0)
		_MirrorReplaceSkyColor ("MirrorReplaceSkyColor", Color) = (1,1,1,1)
		_MirrorReplaceTintColor("MirrorReplaceTintColor", Color) = (1,1,1,1)
	}
	SubShader
	{
		Tags { "RenderType" = "Opaque" }
		LOD 100

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
				float3 dis:TEXCOORD1;

			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float3 _MirrorReplaceParam;
			half4 _MirrorReplaceSkyColor;
			half4 _MirrorReplaceTintColor;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.dis = mul(unity_ObjectToWorld, v.vertex);

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv) * _MirrorReplaceTintColor;
				col.rgb = lerp(col.rgb, _MirrorReplaceSkyColor.rgb, saturate(pow(i.dis.y / _MirrorReplaceParam.x, _MirrorReplaceParam.y)));
			
				return col;
			}
			ENDCG
		}
	}
}
