
half4 Frag(v2f i, FRONT_FACE_TYPE facing : FRONT_FACE_SEMANTIC) : SV_Target
{
	#if defined(INSTANCING_ON)
		UNITY_SETUP_INSTANCE_ID(i);
	#endif

	//base
	float2 uv = i.uvAndOther.xy;
	half occlusion = 1;
	half smoothness = 0.3;
	half metallic = 0;
	half3 emission = 0;

#if defined(PARALLAX) && (defined (LOD0) || defined(LOD1) )
	if	(_EnableParallax)
	{
		float3 viewDirTS = CalculateParallaxIterationsViewDir(i.tangentWS, i.bitangentWS, i.normalWS);
		uv = ParallaxMappingIterations(uv, viewDirTS, _Depth /100, _DepthMap, sampler_DepthMap);
	}
#endif

	//Color
	half4 baseColor = SAMPLE_TEXTURE2D( _BaseMap, sampler_BaseMap, uv ) * _BaseColor;	

	half alpha = baseColor.a;
	#if defined(_EnableClip)
		clip(alpha - _Clip);
	#endif

	//mix
#if defined (LOD0) || defined(LOD1)
	half4 mixValue = SAMPLE_TEXTURE2D(_MixMap, sampler_MixMap, uv );
	metallic = mixValue.r * _Metallic;
	smoothness = mixValue.g * _Smoothness;
	occlusion = mixValue.b;
#endif

	//emission
#if defined (LOD0) || defined(LOD1)
	if (_EnableEmission)
	{
		emission = mixValue.a * _EmissionColor.rgb;
	}
#endif

	//decal
#if defined(_FEVER_DECAL_ENABLE)
	ApplyFeverDecal(_FeverDecalStartIndex, _FeverDecalEndIndex, _FeverDecalMetallic, _FeverDecalSmoothness, i.positionWS, i.normalWS.rgb, baseColor.rgb, metallic, smoothness);
#endif

	//normal
	if(_EnableTurnNormal)
	{
		i.normalWS.rgb = HandleDoubleFaceNormal(facing, i.normalWS.rgb);
	}
	
	float3 normalTS = i.normalWS.rgb;
	float3 normalWS = i.normalWS.rgb;
#if defined (LOD0)
	normalTS = UnpackNormal(SAMPLE_TEXTURE2D(_BumpMap, sampler_BumpMap, uv));
	normalWS = CalculateNormalMap(i, normalTS);
#endif

	//color
	BRDFData brdfData;
	InitializeBRDFData(baseColor.rgb, metallic, 0, smoothness, alpha, brdfData);
	OtherData otherData = InitializeOtherData(normalWS, normalTS, emission, occlusion);
	half3 color = CalculatePBR(i, brdfData, otherData);
	
	return half4(color, alpha);
}