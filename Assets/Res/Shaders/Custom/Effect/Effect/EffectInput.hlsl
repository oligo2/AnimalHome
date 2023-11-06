		sampler2D _BaseMap;
		sampler2D _DistortMap;
		sampler2D _MaskMap;
		sampler2D _MaskMap1;
		sampler2D _HeatMap;
		sampler2D _CameraOpaqueTexture;

		sampler2D _CameraDepth2Texture;

		TEXTURE2D(_VertexAnimMap);  SAMPLER(sampler_VertexAnimMap);
		
	#ifdef _EnableDissolve
	    TEXTURE2D(_DissolveTex);  SAMPLER(sampler_DissolveTex);	    
	#endif

		CBUFFER_START(UnityPerMaterial)
		float4 _BaseMap_ST;
		float4 _BaseScrollAndRotate;
		half4 _BaseColor;
		half _EnableSaturation;
		half _Saturation;
		float _DepthFadeIndensity;
		half _AlphaIntensity;

		float4 _DistortMap_ST;
		float4 _DistortScrollAndRotate;
		float _DistortSpeed;
		float _DistortScale;

		float4 _MaskMap_ST;
		float4 _MaskMap1_ST;
		float4 _MaskScrollAndRotate;
		float4 _MaskScrollAndRotate1;
		float _MaskThreshold;
		float _MaskThreshold1;
		float _MaskPow;
		float _MaskPow1;

	#ifdef _EnableDissolve
		float   _DissolveSpeed;
        float   _DissolveSoft;
        float   _DissolveSize;
        half4   _DissolveColor;
        float4  _DissolveTex_ST;
		float4 _DissolveScrollAndRotate;
    #endif
		float4 _EdgeColor;
		float _EdgeRange;
		float _EdgeSoft;

		float4 _RimColor;
		float _RimFade;
		float _RimWidth;

		float4 _HeatMap_ST;
		float4 _HeatScrollAndRotate;
		float _HeatPow;

		float4 _VertexAnimMap_ST;
		float4 _VertexAnimScrollAndRotate;
		float4 _VertexOffset;
		float _VertexOffsetPow;

		half _EnableDistort;
		half _EnableMask;
		half _EnableMask1;
		half _EnableVertexAnim;
		half _EnableDepthFade;		
		half _EnableHeat;

		float4 _ColorFront;
		float4 _ColorBack;

		half _EnableAlphaR;

		half _EnableUIGamma;

		half _OffsetCustomEnable;
		half _EraseCustomEnable;
		half _MaskOffsetCustomEnable;
		half _DissolveSpeedCustomEnable;
		
		CBUFFER_END
