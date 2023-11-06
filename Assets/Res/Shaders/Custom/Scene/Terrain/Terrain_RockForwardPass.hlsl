half4 Frag(v2f i) : SV_Target
{
	#if defined(INSTANCING_ON)
		UNITY_SETUP_INSTANCE_ID(i);
	#endif

	//base
	float2 uv0 = i.uvAndOther.xy;
#if defined(UV3)
	float2 uv1 = TRANSFORM_TEX(i.uv34.xy, _BaseMap);
#else
	float2 uv1 = TRANSFORM_TEX(i.uvAndOther.xy, _BaseMap);
#endif
    float2 uv2 = i.positionWS.xz * _Color2Map_ST.xy + _Color2Map_ST.zw;

	half occlusion = 1;
	half smoothness = 0.3;
	half metallic = 0;
	half3 emission = 0;
	half alpha = 1;
	
	//ratio
	float3 normal = i.normalWS.rgb; 

	//整体法线
	normal = UnpackNormalScale(SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv0), _BumpScale0);  //整体
	float3 normalTemp = CalculateNormalMap(i, normal);
	half dot1 = dot(normalTemp.xyz, _UPNormal);
	half ratio = saturate((dot1 - _Slope )/_SlopeFade);

	//Color
	half4 baseColor = SAMPLE_TEXTURE2D( _BaseMap, sampler_BaseMap, uv1) * _Color; //石头	
#if defined(UV3)
	half4 baseColor1 = SAMPLE_TEXTURE2D( _MainColorTex, sampler_BaseMap, uv0);	
	baseColor = lerp(baseColor, baseColor1, _ColorMix);
#endif
	
	//grass	
	half4 baseColor2 = SAMPLE_TEXTURE2D( _Color2Map, sampler_BaseMap, uv2) ;	 //草地

	if(_EnableHuge)
	{
		float2 worldUV = i.positionWS.xz/1000 * _HugeMap_ST.xy + _HugeMap_ST.zw;
		half3 hugeColor = SAMPLE_TEXTURE2D(_HugeMap, sampler_HugeMap, worldUV).rgb;
		baseColor2.rgb = lerp(baseColor2, hugeColor, _HugeStrength) ;
	}
	baseColor2.rgb *= _Color2;

	baseColor = lerp(baseColor, baseColor2, ratio);

#if defined(_TERRAIN_VT_ENABLED)
	half fade = lerp(_VTFade, _VTFade2, ratio);        
    baseColor.rgb = CalculateVTColor(baseColor.rgb, i.positionOS, fade);
#endif

	//normal
#if defined (LOD0)
	//detail
	float3 normalRock = UnpackNormalScale(SAMPLE_TEXTURE2D(_BumpMap, sampler_BumpMap, uv1), _BumpScale);  //石头
	normalRock = BlendNormalRNM(normalRock, normal); 

	//grass	
	float3 normalGrass = UnpackNormalScale(SAMPLE_TEXTURE2D(_Bump2Map, sampler_Bump2Map, uv2), _BumpScale2);  //草地
	normalGrass = BlendNormalRNM(normalGrass, normal); 

	//ratio
	normal = lerp(normalRock, normalGrass, ratio);
#endif
	i.normalWS.rgb = CalculateNormalMap(i, normal) ;

	//mix
#if defined (LOD0) || defined(LOD1)
	half4 mixValue = SAMPLE_TEXTURE2D(_MixMap, sampler_MixMap, uv1 );
	metallic = mixValue.r * _Metallic;
	smoothness = mixValue.g * _Smoothness;
	occlusion = mixValue.b;

	half4 mixValue2 = SAMPLE_TEXTURE2D(_Mix2Map, sampler_MixMap, uv2 );
	metallic = lerp(metallic, mixValue2.r * _Metallic2, ratio);
	smoothness = lerp(smoothness, mixValue2.g * _Smoothness2, ratio);
	occlusion = lerp(occlusion, mixValue2.b, ratio);
#endif
	
	//color
	half3 color = CalculatePBR(i, baseColor.rgb, normal, metallic, smoothness, occlusion, alpha, emission);	
	return half4(color, alpha);
}