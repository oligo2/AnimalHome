half4 Frag(v2f i) : SV_Target
{
	#if defined(INSTANCING_ON)
		UNITY_SETUP_INSTANCE_ID(i);
	#endif

	//base
	float2 uv = i.uvAndOther.xy;
	half occlusion = 1;
	half smoothness = 0.2;
	half metallic = 0;
	half alpha = 1;
	half3 emission = 0;

	//normal
	float3 normal = i.normalWS.rgb;
	half4 bumpMap = SAMPLE_TEXTURE2D(_BumpMap, sampler_BumpMap, uv);	
	normal = UnpackNormal(bumpMap.rgba);  //UnpackNoraml这个函数对每个平台处理不一样， 所以要在Unpack之前读取B通道数值

	//splat			
	half4 colorBase = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, uv ) * _BaseColor;
	half4 colorRed = SAMPLE_TEXTURE2D(_Color2Map, sampler_BaseMap, uv * _Tiling2) * _Color2;

#if defined (LOD0) || defined(LOD1)
	half4 mixBase = SAMPLE_TEXTURE2D(_MixMap, sampler_MixMap, uv);
	half4 mixRed = SAMPLE_TEXTURE2D(_Mix2Map, sampler_MixMap, uv * _Tiling2);
#endif

#if defined (LOD0)
	half3 normalRed = UnpackNormal(SAMPLE_TEXTURE2D(_Bump2Map, sampler_BumpMap, uv * _Tiling2));
#endif

	half offsetRed = 1;
	half offsetGreen = 1;
	half offsetBlur = 1;
	offsetRed = SAMPLE_TEXTURE2D(_Noise2Map, sampler_Noise2Map, uv * _NoiseTiling2);

	//ratio
	half Ndot1 = 1 - dot(normal.xyz, float3(0,1,0));
	half ratio1 = i.vertexColor.r > 0.01 ? saturate((i.vertexColor.r - (Ndot1 - _TransitBegin)*_NormalTransitEffect - (offsetRed - _TransitBegin)*_OffsetTransitEffect2 ) / _TransitFade) * i.vertexColor.r : i.vertexColor.r; 

	//color
	colorBase.rgb = lerp(colorBase.rgb, colorRed.rgb, ratio1);

#if defined (LOD0) || defined(LOD1)
	metallic = lerp(mixBase.r * _Metallic1, mixRed.r * _Metallic2, ratio1) ;
	smoothness = lerp(mixBase.g * _Smoothness1, mixRed.g * _Smoothness2, ratio1);
	occlusion = lerp(mixBase.b, mixRed.b, ratio1);

	if (_EnableEmission == 1)
	{
		emission = lerp(mixBase.a * _EmissionColor1.rgb, mixRed.a * _EmissionColor2.rgb, ratio1);
	}
#endif

	//normal
#if defined (LOD0)
	// normal = normalize(float3(normal.xy + normalRed.xy *ratio1 + normalGreen.xy *ratio2 + normalBlur * ratio3, normal.z));  //UDN Blending   比线性混合更加立体
	normal = lerp(normal, normalRed, ratio1);
	i.normalWS.rgb = CalculateNormalMap(i, normal);
#else
	i.normalWS.rgb = CalculateNormalMap(i, normal);
#endif

	//decal
#if defined(_FEVER_DECAL_ENABLE)
	ApplyFeverDecal(_FeverDecalStartIndex, _FeverDecalEndIndex, _FeverDecalMetallic, _FeverDecalSmoothness, i.positionWS, i.normalWS.rgb, colorBase.rgb, metallic, smoothness);
#endif
	
	if (_EnableShowVertexColor)
	{
		return i.vertexColor.rgba;
	}
	else
	{
		//color
		half3 color = CalculatePBR(i, colorBase.rgb, normal, metallic, smoothness, occlusion, alpha, emission);
		return half4(color, alpha);
	}
}

