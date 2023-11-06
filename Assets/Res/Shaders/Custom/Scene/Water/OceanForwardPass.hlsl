half4 Frag(v2f i) : SV_Target
{
	half2 uv = (i.positionWS.xz)/200+0.5;

	half high =	(SAMPLE_TEXTURE2D(_HighMap, sampler_HighMap, uv));

	
	high = saturate(high*_Scale);
	//normal
	float3 normalTS = i.normalWS.rgb;
	float3 normalWS = i.normalWS.rgb;
#if defined (LOD0) || defined(LOD1)
	normalTS = UnpackNormal(SAMPLE_TEXTURE2D(_BumpMap, sampler_BumpMap, uv));
	normalWS = CalculateNormalMap(i, normalTS);
#endif


	//Color
	half4 baseColor = 0;
	baseColor.rgb = lerp(_BaseColor2.rgb, _BaseColor.rgb, high);	
	baseColor.a = _Alpha *(1-high);
	return baseColor;
}