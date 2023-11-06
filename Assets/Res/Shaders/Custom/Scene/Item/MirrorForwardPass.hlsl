
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

	//Color
	half4 baseColor = SAMPLE_TEXTURE2D( _BaseMap, sampler_BaseMap, uv ) * _BaseColor;
	half alpha = baseColor.a;

	//normal
	float3 normal = i.normalWS.rgb;
#if defined (LOD0)
	normal = UnpackNormal(SAMPLE_TEXTURE2D(_BumpMap, sampler_BumpMap, uv)) ;
	normal.xy *= _NormalMul;
	i.normalWS.rgb = CalculateNormalMap(i, normal);
#endif

	//mix
#if defined (LOD0) || defined(LOD1)
	half4 mixValue = SAMPLE_TEXTURE2D(_MixMap, sampler_MixMap, uv);
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

	half3 color = CalculatePBR(i, baseColor.rgb, normal, metallic, smoothness, occlusion, alpha, emission);

    return half4(color , alpha);
}