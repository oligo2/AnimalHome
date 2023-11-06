

    //-------------------------------------------ShadowRamp---------------------------------
    half3 _ShadowRamp;
    half _ShadowStrength;
    float3 _ShadowRampDivisionStrength;
    inline half3 CulShadowRamp(half shadow)
    {
        // 推到的原公式
        // half L = 1- (1-shadow)/ max(0.01,_ShadowStrength);
        // half3 ramp = lerp(0, _ShadowRamp, L);
        // ramp = lerp(ramp, 1, L);
        // return lerp(1, ramp, _ShadowStrength);


        half S = 1-shadow;
        return  S*_ShadowRampDivisionStrength*(_ShadowStrength - S) + shadow;        
    }  

    //-------------------------------------------ViewDir---------------------------------
    //获得视野方向
    half3 GetViewDir(v2f i)
    {
        float3 viewDir;
        #if defined (NORMALMAP)	|| defined (_NORMALMAP)  && !defined(ENABLE_TERRAIN_PERPIXEL_NORMAL)
            viewDir = float3(i.normalWS.w, i.tangentWS.w, i.bitangentWS.w);
        #else
            viewDir = i.viewDirWS;
        #endif
        return normalize(viewDir);
    }

    //-------------------------------------------法线相关----------------------------------   
    //计算法线
#if defined (NORMALMAP)
    half3 CalculateNormalMap(v2f i, half3 normalTS)
    {
        half3 normal = TransformTangentToWorld(normalTS, half3x3(i.tangentWS.xyz, i.bitangentWS.xyz, i.normalWS.xyz));
        return NormalizeNormalPerPixel(normal);   
    }
    //从两个通道计算第三个
    half3 UnpackNormalRG(half3 normalTS)
    {
        normalTS.z = sqrt(1- normalTS.x * normalTS.x  - normalTS.y * normalTS.y);
        return normalTS;
    }
#endif

    //法线根据反面反转
    float3 HandleDoubleFaceNormal(bool facing, float3 normal)
    {
        half face = IS_FRONT_VFACE( facing, true, false)*2 - 1;				
        normal *= face;
        return normal;
    }

    //法线融合
    float3 CombineNormal(float3 normal, float3 normal2, half intensity)
    {
        return normalize(float3(normal.xy + normal2.xy * intensity, normal.z)); 
    }

    //---------------------------------------------计算GI---------------------------
    void CalculateGIAndShadow(v2f i, out half3 bakedGI, out half4 shadowMask)
    {
        bakedGI = 0;
        shadowMask = 0;
#if defined(WISH_GI_ON) && defined(SCENE_WISH_GI_ON)
#if defined(VERTEX_COLOR_INDIRECT_LIGHTING) // 使用顶点颜色存储GI的不可复用模型                
        bakedGI = i.vertexGIAndShadow.rgb;
        shadowMask = i.vertexGIAndShadow.a;
#else
#if defined(MATERIAL_USE_SH2)
        bakedGI = SampleWishGI(i.normalWS, i.SH_R_V0, i.SH_G_V0, i.SH_B_V0, half4(0, 0, 0, 0), half4(0, 0, 0, 0), half4(0, 0, 0, 0), half4(0, 0, 0, 0));
#else
        bakedGI = SampleWishGI(i.normalWS, i.SH_R_V0, i.SH_G_V0, i.SH_B_V0, i.SH_Mix, i.SH_R_V1, i.SH_G_V1, i.SH_B_V1);
#endif
        shadowMask = i.SH_Mix.w;
#endif
#else
#if defined(DYNAMICLIGHTMAP_ON)
        bakedGI = SAMPLE_GI(i.lightmapUV, i.dynamicLightmapUV, i.vertexSH, i.normalWS.xyz);
#else
        bakedGI = SAMPLE_GI(i.lightmapUV, i.vertexSH, i.normalWS.xyz);
#endif
#endif
    }
    //-------------------------------------------fresnel---------------------------------        
    half3 CalculateFresnel(float3 normalWS, float3 viewDirectionWS, half3 insideColor, half3 outsideColor, half power, half range, half intensity)
    {
        half NdotV = saturate(dot(normalWS, viewDirectionWS));
        half oneSubNdotV = 1.0h - NdotV;
        //菲涅尔参数
        half fresnelFactor = saturate(pow(oneSubNdotV, power * power));
        //菲涅尔边缘
        half fresnelRangeFactor = smoothstep(range * 2 - 1, 1, oneSubNdotV);
        //菲涅尔颜色
        half3 fresnelColor = lerp(insideColor.rgb, outsideColor.rgb, fresnelFactor);
        fresnelColor *= intensity;
        fresnelColor *= lerp(0, fresnelColor, fresnelRangeFactor);
        return fresnelColor;
    }

    //-------------------------------------------refract---------------------------------   
#if defined(REFRACT)
    half3 CalculateRefract(float3 normalWS, float2 uvRefract)
    {
        half3 refractColor = _RefractColor.rgb;

        float3 normalCS = TransformWorldToHClipDir(normalWS, true);
        #if !UNITY_UV_STARTS_AT_TOP
            normalCS.y = -normalCS.y;
        #endif

        uvRefract += normalCS.xy * _Distortion;   
        refractColor *= SAMPLE_TEXTURE2D_LOD(_RefractMap, sampler_RefractMap, uvRefract, _RefractRoughness).rgb;
   
        return refractColor;
    }
#endif        
  
    //------------------------------------------计算自定义光照----------------------------------
    struct OtherData
    {
        float3 normalWS;
        float3 normalTS;
        half3 emission;
        half occlusion;
        half depthV;
        half shadowBright;
        half backBright;
    };

    OtherData InitializeOtherData(float3 _normalWS, float3 _normalTS, half3 _emission, half _occlusion)
    {
        OtherData data = (OtherData)0;
        data.normalWS = _normalWS;
        data.normalTS = _normalTS;
        data.emission = _emission;
        data.occlusion = _occlusion;
        return data;
    }


    InputData InitInputData(v2f i, half2 uv)
    {
        InputData data = (InputData)0;
        data.positionCS = i.positionCS;
        data.positionWS = i.positionWS.xyz;
        data.normalWS = i.normalWS.xyz;
        data.viewDirectionWS = GetViewDir(i);

#if defined (NORMALMAP)
        float3 bitangent = i.tangentWS.w * cross(i.normalWS.xyz, i.tangentWS.xyz);
        data.tangentToWorld = half3x3(i.tangentWS.xyz, bitangent.xyz, i.normalWS.xyz);
#endif

        //shadowCoord
        #if defined(MAIN_LIGHT_CALCULATE_CACHED_SHADOWS) || defined(MAIN_LIGHT_CALCULATE_SHADOWS)
            data.shadowCoord = TransformWorldToShadowCoord(i.positionWS.xyz);
        #else
            data.shadowCoord = float4(0, 0, 0, 0);
        #endif
       
        data.fogCoord = 0;
        data.vertexLighting = 0;

        #if defined(DYNAMICLIGHTMAP_ON)
            data.bakedGI = SAMPLE_GI(i.lightmapUV, i.dynamicLightmapUV.xy, i.vertexSH, data.normalWS);
        #else
            data.bakedGI = SAMPLE_GI(i.lightmapUV, i.vertexSH, data.normalWS);
        #endif

        data.normalizedScreenSpaceUV = GetNormalizedScreenSpaceUV(i.positionCS);

        //CalculateGIAndShadowMask
        CalculateGIAndShadow(i, data.bakedGI, data.shadowMask);
        data.shadowMask = CalculateShadowMask(data.shadowMask);

        #if defined(DEBUG_DISPLAY)
            #if defined(DYNAMICLIGHTMAP_ON)
            data.dynamicLightmapUV = i.dynamicLightmapUV.xy;
            #endif
            #if defined(LIGHTMAP_ON)
            data.staticLightmapUV = i.lightmapUV;
            #else
            data.vertexSH = i.vertexSH;
            #endif
            
            data.uv = uv;
        #endif

        return data;
    }

    SurfaceData InitSurfaceData(v2f i, half3 albedo, half3 specular, half metallic, half smoothness, half occlusion, half emission, half alpha, float3 normalTS)
    {
        SurfaceData data = (SurfaceData)0;
        data.albedo              = albedo;
        data.specular            = specular;
        data.metallic            = metallic;
        data.smoothness          = smoothness,
        data.occlusion           = occlusion,
        data.emission            = emission,
        data.alpha               = alpha;
        data.normalTS            = normalTS;
        return data;
    }

    void PrepareRender(v2f i, half occlusion, inout float3 viewDir, inout float4 shadowCoord, inout half4 shadowMask, inout half3 bakedGI, inout AmbientOcclusionFactor aoFactor, inout Light mainLight)
    {
        //参数
        viewDir = GetViewDir(i);

        #if defined (NORMALMAP)
            OUTPUT_SH(i.normalWS.xyz, i.vertexSH);
        #endif

        //shadowCoord
        #if defined(MAIN_LIGHT_CALCULATE_CACHED_SHADOWS) || defined(MAIN_LIGHT_CALCULATE_SHADOWS)
            shadowCoord = TransformWorldToShadowCoord(i.positionWS.xyz);
        #else
            shadowCoord = float4(0, 0, 0, 0);
        #endif
        
        //CalculateGIAndShadowMask
        CalculateGIAndShadow(i, bakedGI, shadowMask);
        shadowMask = CalculateShadowMask(shadowMask);

        //AmbientOcclusion
        aoFactor = CreateAmbientOcclusionFactor(GetNormalizedScreenSpaceUV(i.positionCS), occlusion);

        //mainlight
        mainLight = GetMainLight(shadowCoord, i.positionWS.xyz, shadowMask, aoFactor);
        MixRealtimeAndBakedGI(mainLight, i.normalWS.xyz, bakedGI);
    }  



   
