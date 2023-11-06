Shader "URP/RendererFeature/KawaseUIBlur"
{
    Properties
    {
		//[PerRendererData] _MainTex("Sprite Texture", 2D) = "white" {}
		_Color("Tint", Color) = (1,1,1,1)
    	_BlurTexture("Blur  Texture",2D)= "white" {}

		_StencilComp("Stencil Comparison", Float) = 8
		_Stencil("Stencil ID", Float) = 0
		_StencilOp("Stencil Operation", Float) = 0
		_StencilWriteMask("Stencil Write Mask", Float) = 255
		_StencilReadMask("Stencil Read Mask", Float) = 255

		_ColorMask("Color Mask", Float) = 15

		[Toggle(UNITY_UI_ALPHACLIP)] _UseUIAlphaClip("Use Alpha Clip", Float) = 0

		[HideInInspector]_discolorLerp("去色程度", range(0,1)) = 0
		[HideInInspector]_exposurePower("曝光强度", float) = 0
    }
    SubShader
    {
		Tags
		{
			"Queue" = "Transparent"
			"IgnoreProjector" = "True"
		}

		Stencil
		{
			Ref[_Stencil]
			Comp[_StencilComp]
			Pass[_StencilOp]
			ReadMask[_StencilReadMask]
			WriteMask[_StencilWriteMask]
		}

		Cull Off
		Lighting Off
		ZWrite Off
		ZTest[unity_GUIZTestMode]
		Blend One Zero

		Pass
		{
			Name "Default"
			HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 2.0

			#include "UnityCG.cginc"
			#include "UnityUI.cginc"

			#pragma multi_compile_local _ UNITY_UI_CLIP_RECT
			#pragma multi_compile_local _ UNITY_UI_ALPHACLIP

			struct appdata_t
			{
				float4 vertex    : POSITION;
				float4 color     : COLOR;
				float2 texcoord  : TEXCOORD0;
				float4 screenPos : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				fixed4 color : COLOR;
				float2 texcoord : TEXCOORD0;
				float4 worldPosition : TEXCOORD1;
				float4 screenPos : TEXCOORD2;
				UNITY_VERTEX_OUTPUT_STEREO
			};

			//sampler2D _MainTex;
			sampler2D _BlurTexture;//自定义的blur贴图，由RenderFeature输出的结果拷贝

			fixed _discolorLerp;
			fixed _exposurePower;

			fixed4 _Color;
			fixed4 _TextureSampleAdd;
			float4 _ClipRect;
			float4 _MainTex_ST;
			float4 _BlurTexture_ST;

			v2f vert(appdata_t v)
			{
				v2f OUT;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);
				OUT.worldPosition = v.vertex;
				OUT.vertex = UnityObjectToClipPos(OUT.worldPosition);
				OUT.screenPos = ComputeScreenPos(OUT.vertex);

				OUT.texcoord = TRANSFORM_TEX(v.texcoord, _BlurTexture);

				OUT.color = v.color * _Color;
				return OUT;
			}

			fixed4 frag(v2f IN) : SV_Target
			{ 
				//half4 color = (tex2D(_MainTex, IN.texcoord) + _TextureSampleAdd) * IN.color;

				float2 screenUV = IN.screenPos.xy / IN.screenPos.w;
				#if UNITY_UV_STARTS_AT_TOP
					screenUV.y = 1 - screenUV.y;
				#else
				#endif
				half4 color= 1 ;
				color.rgb *= tex2D(_BlurTexture, IN.texcoord).rgb;

				#ifdef UNITY_UI_CLIP_RECT
					color.a *= UnityGet2DClipping(IN.worldPosition.xy, _ClipRect);
				#endif

				#ifdef UNITY_UI_ALPHACLIP
					clip(color.a - 0.001);
				#endif

				// 去色 //
				float  gray     = saturate(0.2125 * color.r + 0.7154 * color.g + 0.0721 * color.b);
				fixed3 graycolor = fixed3(gray, gray, gray);
				color.rgb = lerp(color.rgb, graycolor, _discolorLerp);

				// 曝光 //
				color.rgb = saturate(color.rgb + color.rgb * _exposurePower);
				
				// Tint Color //
				color.rgb *= _Color;

				return color;
			}
		ENDHLSL
		}
    }
}
