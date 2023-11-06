
half4 Frag(v2f i) : SV_Target
{
	#if defined(INSTANCING_ON)
		UNITY_SETUP_INSTANCE_ID(i);
	#endif

	//base
	float2 uv = i.uvAndOther.xy;
	half occlusion = 1;
	half smoothness = 0;
	half metallic = 0;
	half3 emission = 0;
	half height = 0;

	//splat
	// half3 splatValue = SAMPLE_TEXTURE2D(_SplatMap, sampler_SplatMap, uv).rgb;


	//Color
	half4 baseColor = SAMPLE_TEXTURE2D( _BaseMap, sampler_LinearRepeat, uv ) * _BaseColor;
	
	half4 baseColor2 = SAMPLE_TEXTURE2D( _BaseMap2, sampler_LinearRepeat, uv ) * _BaseColor;
	half4 baseColor3 = SAMPLE_TEXTURE2D( _BaseMap3, sampler_LinearRepeat, uv ) * _BaseColor;
	
	
	half alpha = baseColor.a;




	//splat

	//高度小于一定数值， 显示沙滩
	//   i.positionWS.y < 0.5

	baseColor = lerp(baseColor, baseColor2, 1-i.positionWS.y );


	//mix
	// half4 mixValue = SAMPLE_TEXTURE2D(_MixMap, sampler_MixMap, uv );
	// metallic = mixValue.r * _Metallic;
	// smoothness = (1-mixValue.g) * _Smoothness;
	// occlusion = mixValue.b;
	// height = mixValue.a + 0.5;

	//normal
	float3 normalTS = i.normalWS.rgb;
	float3 normalWS = i.normalWS.rgb;
#if defined (LOD0) || defined(LOD1)
	normalTS = UnpackNormal(SAMPLE_TEXTURE2D(_BumpMap, sampler_BumpMap, uv));
	normalWS = CalculateNormalMap(i, normalTS);
#endif

	//final color	
	BRDFData brdfData;
	InitializeBRDFData(baseColor.rgb, metallic, 0, smoothness, alpha, brdfData);
	OtherData otherData = InitializeOtherData(normalWS, normalTS, emission, occlusion);
	half3 color = CalculatePBR(i, brdfData, otherData);

	
	return half4(color, alpha);
}