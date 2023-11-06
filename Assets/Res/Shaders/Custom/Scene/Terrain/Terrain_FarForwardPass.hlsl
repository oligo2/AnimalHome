half4 Frag(v2f i) : SV_Target
{
	#if defined(INSTANCING_ON)
		UNITY_SETUP_INSTANCE_ID(i);
	#endif

	//base
	float2 uv = i.uvAndOther.xy;
	half4 baseColor = _BaseColor;
	half alpha = baseColor.a;
	half occlusion = 1;
	half smoothness = 1;

	//normal
	half4 baseMap = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, uv);
	float3 normal = UnpackNormal ( baseMap.rgba);  //UnpackNoraml这个函数对每个平台处理不一样， 所以要在Unpack之前读取B通道数值
	i.normalWS.rgb = CalculateNormalMap(i, normal);

	//splat				
	half4 colorOrigin = SAMPLE_TEXTURE2D(_OriginMap, sampler_OriginMap, uv * _ScaleOrigin);
	half4 colorRed = SAMPLE_TEXTURE2D(_RedMap, sampler_RedMap, uv * _ScaleRed); 
	half4 colorGreen = 0;
	half4 colorBlur = 0;

	//ratio
	half Ndot1 = abs(dot(normal.xyz, float3(0,1,0)));
	half ratio1 = saturate((_BaseAndRedRatio + i.vertexColor.r - (1-Ndot1)) / _Transit);
	half ratio2;
	half ratio3;
	//color
	baseColor.rgb = lerp(colorOrigin.rgb, colorRed.rgb, ratio1);

	//smoothness
	smoothness = lerp(_SmoothnessOrigin * colorOrigin.a, _SmoothnessRed * colorRed.a, ratio1);


	if (_EnableGreen)
	{
		 colorGreen = SAMPLE_TEXTURE2D(_GreenMap, sampler_GreenMap, uv * _ScaleGreen);
		 ratio2 = saturate((  i.vertexColor.g - Ndot1 * 0.9) / _Transit); 
		 baseColor.rgb = lerp(baseColor.rgb, colorGreen.rgb, ratio2); 
		 smoothness = lerp(smoothness, _SmoothnessGreen * colorGreen.a, ratio2); 
	}
	if (_EnableBlur) 
	{ 
		colorBlur = SAMPLE_TEXTURE2D(_BlurMap, sampler_BlurMap, uv * _ScaleBlur); 
		ratio3 = saturate(( i.vertexColor.b - Ndot1 * 0.9) / _Transit); 
		baseColor.rgb = lerp(baseColor.rgb, colorBlur.rgb, ratio3); 
		smoothness = lerp(smoothness, _SmoothnessBlur * colorBlur.a, ratio3); 
	}

	//color
	half3 color = CalculatePhong(i, baseColor.rgb, normal, smoothness, occlusion);
	
	if (_EnableShowVertexColor)
	{
		return i.vertexColor.rgba;
	}
	else
	{
		return half4(color, alpha);
	}
}