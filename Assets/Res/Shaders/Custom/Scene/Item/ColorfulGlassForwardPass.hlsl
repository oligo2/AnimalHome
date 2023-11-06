
half4 Frag(v2f i) : SV_Target
{
	#if defined(INSTANCING_ON)
		UNITY_SETUP_INSTANCE_ID(i);
	#endif

	//base
	float2 uv = i.uvAndOther.xy;
	half occlusion = 1;
	half smoothness = 1;
	half metallic = 0;
	half3 emission = 0;

	//Color
	half4 baseColor = SAMPLE_TEXTURE2D( _BaseMap, sampler_BaseMap, uv ) * _BaseColor;	
	half alpha = 1;

	//mix
#if defined (LOD0) || defined(LOD1)
	half4 mixValue = SAMPLE_TEXTURE2D(_MixMap, sampler_MixMap, uv );
	metallic = mixValue.r * _Metallic;
	smoothness = mixValue.g * _Smoothness;
	occlusion = mixValue.b;
#endif

	//normal
	float3 normal = i.normalWS.rgb;
#if defined (LOD0)
	normal = UnpackNormal(SAMPLE_TEXTURE2D(_BumpMap, sampler_BumpMap, TRANSFORM_TEX(uv, _BumpMap)));
	i.normalWS.rgb = CalculateNormalMap(i, normal);
#endif

	//ViewDir
	float3 V = float3(i.normalWS.w, i.tangentWS.w, i.bitangentWS.w);

	//inside遮罩
	half insideMask = SAMPLE_TEXTURE2D( _InsideMask, sampler_InsideMask, uv).r;

   	//inside深度
	float3 viewDirTS = CalculateParallaxIterationsViewDir(i.tangentWS, i.bitangentWS, i.normalWS);

	//inside纹理
	float2 insideUV =   ParallaxMappingIterationDepth(uv, viewDirTS, _InsideDepth * 0.3, _InsideMap, sampler_InsideMap);
	half insideTex = SAMPLE_TEXTURE2D( _InsideMap, sampler_InsideMap, TRANSFORM_TEX(insideUV, _InsideMap)).r;
	
	//inside颜色
	float2 inside2UV =  ParallaxMappingIterationDepth(uv, viewDirTS, _InsideDepth, _InsideMap2, sampler_InsideMap2);
	half4 inside2Tex = SAMPLE_TEXTURE2D( _InsideMap2, sampler_InsideMap2, TRANSFORM_TEX(inside2UV, _InsideMap2) );
	
	// //inside混合
	half3 insideColor = baseColor.rgb;
	insideColor += _InsideColor * inside2Tex * 1;
	insideColor *= lerp(1, insideTex ,_InsideOpacity);
	insideColor *= occlusion;

	//skybox
	half3 reflectVector = reflect(-V, i.normalWS);
	half mip = PerceptualRoughnessToMipmapLevel(smoothness);
	half3 skyColor = half4(SAMPLE_TEXTURECUBE_LOD(unity_SpecCube0, samplerunity_SpecCube0, reflectVector, mip)).rgb;

	//fresnel
	half dotNV = 1.0 - saturate(dot(i.normalWS, V));
	dotNV = smoothstep((1.0 - _FresnelPower) * 2 - 1, 1, dotNV);
	insideColor += dotNV * skyColor * _FresnelColor;

	//emission
	#if defined (LOD0) || defined(LOD1)
	if (_EnableEmission)
	{
		emission = mixValue.a * _EmissionColor.rgb;
	}
	#endif

	//outcolor
	metallic = lerp(metallic, 0, insideMask);
	smoothness = lerp(smoothness, 0, insideMask);
	baseColor.rgb = lerp(baseColor.rgb, insideColor, insideMask);
	half3 color = CalculatePBR(i, baseColor.rgb, normal, metallic, smoothness, occlusion, alpha, emission);

	return half4(color, alpha);
}