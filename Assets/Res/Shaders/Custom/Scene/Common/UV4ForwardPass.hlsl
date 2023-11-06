half4 Frag(v2f i) : SV_Target
{
	#if defined(INSTANCING_ON)
		UNITY_SETUP_INSTANCE_ID(i);
	#endif

	//base
	float2 uv = i.uvAndOther.xy;
	float2 uv3 = i.uv34.xy;
	float2 uv4 = i.uv34.zw;
	half occlusion = 1;
	half smoothness = 0.3;
	half metallic = 0;
	half3 emission = 0;

	//Color
	half4 baseColor = SAMPLE_TEXTURE2D( _BaseMap, sampler_BaseMap, uv ) * _BaseColor;
	half alpha = 1;
	half4 baseColor2 = SAMPLE_TEXTURE2D( _Base2Map, sampler_Base2Map, uv3 ) * _BaseColor2;

	baseColor.rgb = lerp(baseColor.rgb, baseColor2.rgb, baseColor2.a);

	//normal
	float3 normal = i.normalWS.rgb; 
	float3 normal2 = float3(0,1,0);
	float3 normal3 = float3(0,1,0);
#if defined (LOD0)
	normal = UnpackNormal(SAMPLE_TEXTURE2D(_BumpMap, sampler_BumpMap, uv));	
	normal2 = UnpackNormal(SAMPLE_TEXTURE2D(_Bump2Map, sampler_Bump2Map, uv3));	
	normal.rgb = lerp(normal.rgb, normal2.rgb, baseColor2.a);
#endif

#if defined (LOD0) || defined(LOD1)
	#if defined (UV4) 
		normal3 = UnpackNormal(SAMPLE_TEXTURE2D(_Bump3Map, sampler_Bump3Map, uv4));
		normal = normalize(float3(normal.xy + normal3.xy, normal.z));  //UDN Blending   比线性混合更加立体
	#endif
#endif
	i.normalWS.rgb = CalculateNormalMap(i, normal);

	//mix
#if defined (LOD0) || defined(LOD1)
	half4 mixValue = SAMPLE_TEXTURE2D(_MixMap, sampler_MixMap, uv );
	metallic = mixValue.r * _Metallic;
	smoothness = mixValue.g * _Smoothness;
	occlusion = mixValue.b;

	half4 mixValue2 = SAMPLE_TEXTURE2D(_Mix2Map, sampler_Mix2Map, uv3 );
	half metallic2 = mixValue2.r * _Metallic2;
	half smoothness2 = mixValue2.g * _Smoothness2;
	half occlusion2 = mixValue2.b;

	metallic = lerp(metallic, metallic2, baseColor2.a);
	smoothness = lerp(smoothness, smoothness2, baseColor2.a);
	occlusion = lerp(occlusion, occlusion2, baseColor2.a);
#endif
		
	//emission
#if defined (LOD0) || defined(LOD1)
	if (_EnableEmission)
	{
		emission = lerp(mixValue.a * _EmissionColor.rgb, mixValue2.a * _EmissionColor2.rgb, baseColor2.a);
	}
#endif

	//decal
#if defined(_FEVER_DECAL_ENABLE)
	ApplyFeverDecal(_FeverDecalStartIndex, _FeverDecalEndIndex, _FeverDecalMetallic, _FeverDecalSmoothness, i.positionWS, i.normalWS.rgb, baseColor.rgb, metallic, smoothness);
#endif

	//color
	half3 color = CalculatePBR(i, baseColor.rgb, normal , metallic, smoothness, occlusion, alpha, emission);
	
	return half4(color.rgb, alpha);
}