
// #if defined(_EnableClip)
// 	half4 Frag(v2f i, FRONT_FACE_TYPE facing : FRONT_FACE_SEMANTIC) : SV_Target
// #else
// #endif
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
	float3 normal = i.normalWS.rgb;
#if defined (LOD0)
	normal = UnpackNormal(SAMPLE_TEXTURE2D(_BumpMap, sampler_BumpMap, uv));
	i.normalWS.rgb = CalculateNormalMap(i, normal);
	#if defined (_EnableClip)
		if(_EnableTurnNormal)
		{
			i.normalWS.rgb = HandleDoubleFaceNormal(facing, i.normalWS.rgb);
		}
	#endif
#endif

	if (_EnableShowVertexColor)
	{
		return i.vertexColor.rgba;
	}
	else
	{
		half3 color = CalculatePBR(i, baseColor.rgb, normal, metallic, smoothness, occlusion, alpha, emission);
		return half4(color, alpha);
	}
}