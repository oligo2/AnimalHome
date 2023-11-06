
half3 LightingLambert(v2f i, half3 diffuse, half smoothness, Light light, half3 normalWS, half3 viewWS, half shadowBright, half backBright)
{
    // 计算影子
    half3 shadowColor = light.shadowAttenuation * light.distanceAttenuation;//CulShadowRamp(lerp(light.shadowAttenuation * light.distanceAttenuation, 1, shadowBright)) ;

    //云影
    half cloudNoise =  SAMPLE_TEXTURE2D(_CloudShadowMap, sampler_CloudShadowMap, (i.positionWS.xz) /300).r;
    shadowColor = min(shadowColor, cloudNoise);

#if defined(NOSHADOW) 
    if (!_EnableShadow)
    {
        return 1;
    }
#endif

    half NdotL = saturate(dot(normalWS, light.direction));
    half3 color = diffuse * light.color * (NdotL + (1-NdotL) *backBright);

    //spcular
    #if defined(PBRSPCULAR)        
        color += DirectPhongSpecular(smoothness, normalWS, light.direction, viewWS); 
    #elif defined(GRASS)
        half y = clamp(i.uvAndOther.y, 0, 1);
        // float3 halfDir = normalize(viewWS + light.direction);
        // float3 specular = dot(half3(0,1,0), halfDir);
        // specular = pow(specular, _SpecularPower) * smoothness;
        // specular = specular * y;
        // specular = specular * _SpecularColor;

        //高光                       //麦浪   
        // color += (specular + i.uvAndOther.w * _WindColor * y * y) * light.color; 
        color += (i.uvAndOther.w * _WindColor * y * y) * light.color; 
    #endif

    return color * shadowColor;
}

float4 Frag(v2f i, FRONT_FACE_TYPE facing : FRONT_FACE_SEMANTIC) : SV_Target
{
	#if defined(INSTANCING_ON)
		UNITY_SETUP_INSTANCE_ID(i);
	#endif

    //base		
    float2 uv = i.uvAndOther.xy;
    float hight = i.uvAndOther.z;
	// half occlusion = 1;
	// half3 emission = 0;
	half smoothness = _Smoothness;
    // half alpha = 1;

    //基础数值
    // float4 baseTex = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, uv);    
    half3 baseColor = 1;
    smoothness = _Smoothness;
    
    //平铺色
    float2 worldUV = (i.positionWS.xz * _TileColorMap_ST.xy + _TileColorMap_ST.zw)/100;
    half3 tileColor = SAMPLE_TEXTURE2D(_TileColorMap, sampler_TileColorMap, worldUV).rgb;
    baseColor = tileColor;
  
	//normal
	// float3 normalTS = i.normalWS.rgb;
	float3 normalWS = i.normalWS.rgb;

    //VT
#if defined(_TERRAIN_VT_ENABLED)
    if(_EnableVT)
    {
        baseColor = CalculateVTColor(baseColor, i.positionOS, _VTFade);
    }
#endif

    //AO对补亮的影响    
    // BRDFData brdfData;
    // InitializeBRDFData(baseColor.rgb, 0, 0, smoothness, alpha, brdfData);
    // OtherData otherData = InitializeOtherData(normalWS, normalTS, emission, occlusion);
    // otherData.shadowBright = _ShadowBright;
    // otherData.backBright = _BackBright;
    // float3 color = CalculatePhong(i, brdfData, otherData);


    //计算光照
    half3 color = 0;//GlobalIlluminationPhong(brdfData, bakedGI, aoFactor.indirectAmbientOcclusion, normalWS, viewWS);

    //     //上下渐变
    // #if defined(GRASS)
    //     // brdfData.albedo = lerp(brdfData.albedo, brdfData.albedo + _BaseColor* mainLight.shadowAttenuation, baseTex.r) ;
    //     brdfData.albedo = lerp(brdfData.albedo, brdfData.albedo + _BaseColor* mainLight.shadowAttenuation, 1) ;
    // #endif
        
    Light mainLight;
    mainLight = GetMainLight();
    half3 viewWS = GetViewDir(i);


    color += LightingLambert(i, baseColor, smoothness, mainLight, normalWS, viewWS, _ShadowBright, _BackBright);
    // int lightCount = GetAdditionalLightsCount();
    // for (int j = 0; j < lightCount; ++j)
    // {
    //     Light light = GetAdditionalLight(j, i.positionWS.xyz);
    //     half3 attenuatedLightColor = light.color * light.distanceAttenuation;
    //     color.rgb += LightingLambert(i, baseColor, smoothness, mainLight, normalWS, viewWS, _ShadowBright, _BackBright);
    // }    

    return float4(color, 1);
}