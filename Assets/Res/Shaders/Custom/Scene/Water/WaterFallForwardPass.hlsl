half4 Frag(v2f i) : SV_Target
{
	#if defined(INSTANCING_ON)
		UNITY_SETUP_INSTANCE_ID(i);
	#endif

	//base
	float2 uv = i.uvAndOther.xy;
	half occlusion = 1;
	half metallic = 0;
	half3 emission = 0;
	half speed1 = _Time.y * _Speed1;
	half speed2 = _Time.y * _Speed2;
	half fogSpeed = _Time.y * _FogSpeed;	
	half alpha = 1;

	//Color
	half3 baseColor = _BaseColor;	
	half3 sideColor = SAMPLE_TEXTURE2D( _SideMap, sampler_SideMap, half2(uv.x  , uv.y + speed1) );
	sideColor *= SAMPLE_TEXTURE2D( _SideMap, sampler_SideMap, half2(uv.x , uv.y + speed2) );
	alpha = sideColor.r;
	clip(alpha - 0.2);

	//normal
	float3 normal = i.normalWS.rgb; 

	//height
	half height = uv.y * uv.y;

	//base
	half2 baseUV = half2(uv.x * _Tilling1, (uv.y + speed1) * _Tilling1/2 );
	half3 color1 = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, baseUV);

	//Parallax
	half2 baseUV2 = half2(uv.x * _Tilling2, (uv.y + speed2) * _Tilling2/2 );
	float3 viewDirTS = CalculateParallaxIterationsViewDir(i.tangentWS, i.bitangentWS, i.normalWS);
	baseUV2 = ParallaxMappingIteration1(baseUV2, viewDirTS, _DepthChange, _BaseMap, sampler_BaseMap);
	half3 color2 = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, baseUV2);

	//fog	
#if defined (LOD0)|| defined( LOD1)
	half fog = SAMPLE_TEXTURE2D(_FogMap, sampler_FogMap, half2(uv.x * _Tilling3, (uv.y + fogSpeed)* _Tilling3)).r;
#endif
	
	baseColor = ((color1 +color2)/2) * baseColor.rgb;


#if defined (LOD0)|| defined( LOD1)
	half3 color = CalculatePhong(i, baseColor.rgb + fog*_FogStrength,  normal, 0, occlusion, 0, _ShadowBright, _BackBright, 1);
#else
	half3 color = CalculatePhong(i, baseColor.rgb, normal, 0, occlusion, 0, _ShadowBright, _BackBright, 1);
#endif

	//穿插虚化
	float thisDepth = LinearEyeDepth(i.positionWS.xyz, GetWorldToViewMatrix()).r;
	float sceneDepth = LinearEyeDepth(tex2D(_CameraDepth2Texture, UnityStereoTransformScreenSpaceTex(i.projected.xy / i.projected.w)).r, _ZBufferParams);
	float deltaDepth = abs(thisDepth - sceneDepth) / _DepthFadeIndensity;
	alpha *= min(deltaDepth, 1);

	return half4(color, alpha - _Alpha*(1-color.r));
}