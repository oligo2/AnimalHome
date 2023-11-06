
half4 Frag(v2f i) : SV_Target
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
	half height = 1;

	//splat
#if defined(FUR)
	if(!_EnableFur)
		clip(-1);
	half3 splatValue = SAMPLE_TEXTURE2D(_SplatMap, sampler_SplatMap, uv).rgb;
	if(splatValue.g < 0.5)
		clip(-1);
#endif

	//Color
	half4 baseColor = SAMPLE_TEXTURE2D( _BaseMap, sampler_BaseMap, uv ) * _BaseColor;
	half alpha = baseColor.a;

	//mix
	half4 mixValue = SAMPLE_TEXTURE2D(_MixMap, sampler_MixMap, uv );
	metallic = mixValue.r * _Metallic;
	smoothness = (1-mixValue.g) * _Smoothness;
	occlusion = mixValue.b;
	height = mixValue.a + 0.5;

	//normal
	float3 normalTS = i.normalWS.rgb;
	float3 normalWS = i.normalWS.rgb;
#if defined (LOD0) || defined(LOD1)
	normalTS = UnpackNormal(SAMPLE_TEXTURE2D(_BumpMap, sampler_BumpMap, uv));
	normalWS = CalculateNormalMap(i, normalTS);
#endif

	//final color
	half3 color = 0;
	
#if defined(FUR)
	if(splatValue.g >= 0.5)
	{
		//毛发分布和形状
	#if defined(FUR)
		half furValue = SAMPLE_TEXTURE2D(_FurMap, sampler_FurMap, TRANSFORM_TEX(uv, _FurMap)).r;
		half shape = pow(abs(_LayerLength), _FurShape);

		clip(alpha * furValue - shape);
		alpha =alpha * furValue;
	#endif
		
		//根部压暗环境光，模拟遮挡
		half furDarknessRate;
		furDarknessRate = pow(abs(_LayerLength), _FurRootDarknessPower);
		baseColor.rgb *= lerp(_FurRootDarknessColor.rgb, 1.0, furDarknessRate);

		BRDFData brdfData;
		InitializeBRDFData(baseColor.rgb, metallic, 0, smoothness, alpha, brdfData);
		OtherData otherData = InitializeOtherData(normalWS, normalTS, emission, occlusion);
		color = CalculateFur(i, brdfData, otherData, alpha);
	}
	else
#endif
	{
		BRDFData brdfData;
		InitializeBRDFData(baseColor.rgb, metallic, 0, smoothness, alpha, brdfData);
		OtherData otherData = InitializeOtherData(normalWS, normalTS, emission, occlusion);
		color = CalculatePBR(i, brdfData, otherData);
	}

	
	return half4(color, alpha);
}