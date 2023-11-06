
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

	//window遮罩
	half2 windowTex = SAMPLE_TEXTURE2D( _WindowMask, sampler_WindowMask, uv).rg;
	half windowMask = windowTex.r;
	half curtainMask = windowTex.g;

	//Time
	half time = TimeControl_Time;
	time = max(0, time);
	time = min(time, 24);
	half timelevel = smoothstep(5, 7, time) - smoothstep(17, 19, time);

	//skybox
	half3 reflectVector = reflect(-V, i.normalWS);
	half mip = PerceptualRoughnessToMipmapLevel(smoothness);
	half3 skyColor = half4(SAMPLE_TEXTURECUBE_LOD(unity_SpecCube0, samplerunity_SpecCube0, reflectVector, mip)).rgb;

	half3 windowColor = skyColor;
	baseColor.rgb = lerp(baseColor.rgb, windowColor, windowMask * _SkyWeight);

	//emission
	#if defined (LOD0) || defined(LOD1)
	if (_EnableEmission)
	{
		emission = mixValue.a * _EmissionColor.rgb;
	}
	#endif

	//outcolor
	half3 color = CalculatePBR(i, baseColor.rgb, normal, metallic, smoothness, occlusion, alpha, emission);

	//室内 窗口
	if (_IsProtal == 1)
	{
		color = lerp(color, skyColor * lerp(_NightColor, _DayColor, timelevel), windowMask);
	}
	
	//户外 夜灯
	if (_IsProtal == 0 && time >=_LightTime.x && time <= _LightTime.y)
	{
		color = lerp(color, _NightColor * curtainMask, windowMask);
	}

	return half4(color, alpha);
}