#if defined(DEBUG_DISPLAY)
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Debug/DebuggingCommon.hlsl"
#endif

#if defined(MIRROR) 
#include "MirrorFunction.hlsl"
#endif

#if defined(FUR)
#include "KajiyaKaySpecular.hlsl"
#endif

#include "LightCommonFunction.hlsl"

    TEXTURE2D(_CloudShadowMap);     SAMPLER(sampler_CloudShadowMap);

    //--------------------------------------------------------------------Lighting--------------------------------------------------------------------    
    //光照函数
    half3 LightingPBR(v2f i, BRDFData brdfData, Light light, half3 normalWS, half3 viewWS)
    {    
        //计算影子
        half3 shadowColor = CulShadowRamp(light.distanceAttenuation * light.shadowAttenuation);    

        //云影    
        half cloudNoise =  SAMPLE_TEXTURE2D(_CloudShadowMap, sampler_CloudShadowMap, (i.positionWS.xz) /300).r;
        shadowColor = min(shadowColor, cloudNoise);    

        half NdotL = saturate(dot(normalWS, light.direction));
        half3 radiance = light.color * NdotL * shadowColor;
        half3 brdf = brdfData.diffuse;
    #ifndef _SPECULARHIGHLIGHTS_OFF
        brdf += brdfData.specular * DirectBRDFSpecular(brdfData, normalWS, light.direction, viewWS);
    #endif

        return brdf * radiance;
    }

    half3 LightingLambert(v2f i, BRDFData brdfData, Light light, half3 normalWS, half3 viewWS, half shadowBright, half backBright)
    {
        //计算影子
        half3 shadowColor = CulShadowRamp(lerp(light.shadowAttenuation * light.distanceAttenuation, 1, shadowBright)) ;
    
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
        half3 color = brdfData.diffuse * light.color * (NdotL + (1-NdotL) *backBright);

        //spcular
        half smoothness = 1-brdfData.perceptualRoughness;
        #if defined(PBRSPCULAR)        
            color += DirectPhongSpecular(smoothness, normalWS, light.direction, viewWS); 
        #elif defined(GRASS)
            half y = clamp(i.uvAndOther.y, 0, 1);
            // y = max(0, y);
            float3 halfDir = normalize(viewWS + light.direction);
            float3 specular = dot(half3(0,1,0), halfDir);
            specular = pow(specular, _SpecularPower) * smoothness;
            specular = specular * y;
            specular = specular * _SpecularColor;

            //高光                       //麦浪   
            color += (specular + i.uvAndOther.w * _WindColor * y * y) * light.color; 
        #endif
 
        color = color* shadowColor;
        return color;
    }

#if defined(FUR)
    half3 LightingFur(v2f i, BRDFData brdfData, Light light, half3 normalWS, half3 viewWS)
    {
        half NdotL = saturate(dot(normalWS, light.direction));
        float3 h = SafeNormalize(light.direction + viewWS);
        float LdotH = dot(light.direction, h);

        half shadow = light.distanceAttenuation * light.shadowAttenuation;
        half3 radiance = light.color * NdotL * shadow ;

        half3 brdf = brdfData.diffuse;        
    #ifndef _SPECULARHIGHLIGHTS_OFF
        brdf += brdfData.specular * DirectBRDFSpecular(brdfData, normalWS, light.direction, viewWS);
        //Kajiya-Kay 高光
        brdf += KajiyaKaySpecular(i, brdfData, normalWS, viewWS, h, NdotL, LdotH);
    #endif
        return brdf * radiance;
    }
#endif



    //---------------------------------------------------------------------GlobalIllumination--------------------------------------------------------------------
    half3 GlobalIlluminationPBR(BRDFData brdfData, half3 bakedGI, half occlusion, half3 normalWS, half3 viewWS)
    {
        half3 reflectVector = reflect(-viewWS, normalWS);
        half NoV = saturate(dot(normalWS, viewWS));
        half fresnelTerm = Pow4(1.0 - NoV);

        half3 indirectDiffuse = bakedGI * occlusion;
        half3 indirectSpecular = GlossyEnvironmentReflection(reflectVector, brdfData.perceptualRoughness, occlusion);

        half3 color = EnvironmentBRDF(brdfData, indirectDiffuse, indirectSpecular, fresnelTerm);
        return color;
    }
    half3 GlobalIlluminationPhong(BRDFData brdfData, half3 bakedGI, half occlusion, half3 normalWS, half3 viewWS)
    {
        half3 reflectVector = reflect(-viewWS, normalWS);
        half NoV = saturate(dot(normalWS, viewWS));
        half fresnelTerm = Pow4(1.0 - NoV);

        half3 indirectDiffuse = bakedGI*occlusion;
        half3 indirectSpecular = 0;

        half3 color = EnvironmentBRDF(brdfData, indirectDiffuse, indirectSpecular, fresnelTerm);
        return color;
    }
    
    
    //---------------------------------------------------------------------MainFunction--------------------------------------------------------------------    
    //PBR
    half3 CalculatePBR(v2f i, BRDFData brdfData, OtherData otherData)
    {   
        //DEBUG_DISPLAY
	#if defined(DEBUG_DISPLAY)
    	half4 debugColor;
        if (DebugDisplay(i, brdfData, otherData, debugColor))  { return debugColor;}
	#endif

        //PrepareRender
        float3 viewWS = 0;
        float4 shadowCoord  = 0;
        half4 shadowMask = 1;
        half3 bakedGI = 0;
        AmbientOcclusionFactor aoFactor;
        Light mainLight;
        PrepareRender(i, otherData.occlusion, viewWS, shadowCoord, shadowMask, bakedGI, aoFactor, mainLight);

        //color
        half3 color = GlobalIlluminationPBR(brdfData, bakedGI, aoFactor.indirectAmbientOcclusion, otherData.normalWS, viewWS);
        color += LightingPBR(i, brdfData, mainLight, otherData.normalWS, viewWS);

        #ifdef _ADDITIONAL_LIGHTS
            uint addLightCount = GetAdditionalLightsCount();
            for (uint index = 0u; index < addLightCount; ++index)
            {
                Light light = GetAdditionalLight(index, i.positionWS.xyz, shadowMask);
                color += LightingPBR(i, brdfData, light, otherData.normalWS, viewWS);
            }
        #endif

    #if defined(MIRROR) 
        viewWS = normalize(_WorldSpaceCameraPos.xyz - i.positionWS.xyz);
        float3 reflDir = reflect(-viewWS, normalWS);
        half3 skyReflection = GetCubemapReflection(reflDir);    
	    float2 refl_uv = GetScreenSpaceReflectionUV(normalWS, viewWS, KWS_CameraProjectionMatrix);
		float4 ssrReflection = GetScreenSpaceReflectionWithStretchingMask(refl_uv);
    
        ssrReflection.xyz = lerp(skyReflection, ssrReflection.rgb, ssrReflection.a);
        color.rgb = lerp( color.rgb, ssrReflection.rgb, _Reflection);
    #endif
        
        //emission
        color += otherData.emission;

        //fog        
        #if defined (ATMOSPHERE_ON) && !defined(ATMOSPHERE_POSTPROCESS_ON)
            color = GetAtmosphereOutputColor(color, i.inscattering);
        #endif

        return color;
    }

    half3 CalculatePhong(v2f i, BRDFData brdfData, OtherData otherData)
    {   
        //DEBUG_DISPLAY
	#if defined(DEBUG_DISPLAY)
    	half4 debugColor;
        if (DebugDisplay(i, brdfData, otherData, debugColor))  { return debugColor;}
	#endif

        //PrepareRender
        float3 viewWS = 0;
        float4 shadowCoord  = 0;
        half4 shadowMask = 1;
        half3 bakedGI = 0;
        half3 normalWS = otherData.normalWS;
        half3 occlusion = otherData.occlusion;
        AmbientOcclusionFactor aoFactor;
        Light mainLight;
        PrepareRender(i, occlusion, viewWS, shadowCoord, shadowMask, bakedGI, aoFactor, mainLight);

        //树叶需要顶部颜色和Scattering 透射
    #if defined(TOPCOLOR)  
        brdfData.albedo += _TopColor* (normalWS.y* normalWS.y);
    #endif

        //Scattering 透射
    #if defined(SCATTERING)
        float3 H = normalize(normalWS + mainLight.direction);
        float D =  abs(dot(H, viewWS));
        brdfData.albedo +=  D  * _ScatteringColor * occlusion * _ScatteringStrength;
    #endif

        //计算光照
        half3 color = GlobalIlluminationPhong(brdfData, bakedGI, aoFactor.indirectAmbientOcclusion, normalWS, viewWS);

        //上下渐变
    #if defined(GRASS)
        // brdfData.albedo = lerp(brdfData.albedo, brdfData.albedo + _BaseColor* mainLight.shadowAttenuation, baseTex.r) ;
        brdfData.albedo = lerp(brdfData.albedo, brdfData.albedo + _BaseColor* mainLight.shadowAttenuation, 1) ;
    #endif
        
        color += LightingLambert(i, brdfData, mainLight, normalWS, viewWS, otherData.shadowBright, otherData.backBright);
        int lightCount = GetAdditionalLightsCount();
        for (int j = 0; j < lightCount; ++j)
        {
            Light light = GetAdditionalLight(j, i.positionWS.xyz);
            half3 attenuatedLightColor = light.color * light.distanceAttenuation;
            color.rgb += LightingLambert(i, brdfData, mainLight, normalWS, viewWS, otherData.shadowBright, otherData.backBright);
        }    

        //emission
        color += otherData.emission;
        
        //fog        
        #if defined (ATMOSPHERE_ON) && !defined(ATMOSPHERE_POSTPROCESS_ON)
            color = GetAtmosphereOutputColor(color, i.inscattering);
        #endif

        return color;
    }

    #if defined(FUR)
    half3 CalculateFur(v2f i, BRDFData brdfData, OtherData otherData, out half alpha)
    {
        //DEBUG_DISPLAY
	#if defined(DEBUG_DISPLAY)
    	half4 debugColor;
        if (DebugDisplay(i, brdfData, otherData, debugColor))  { return debugColor;}
	#endif
   
        //PrepareRender
        alpha =1;
        float3 viewWS = 0;
        float4 shadowCoord  = 0;
        half4 shadowMask = 1;
        half3 bakedGI = 0;
        AmbientOcclusionFactor aoFactor;
        Light mainLight;
        PrepareRender(i, otherData.occlusion, viewWS, shadowCoord, shadowMask, bakedGI, aoFactor, mainLight);

        //计算光照
        half3 color = GlobalIlluminationPBR(brdfData,  bakedGI, otherData.occlusion, aoFactor.indirectAmbientOcclusion, i.positionWS.xyz);
        color += LightingFur(i, brdfData, mainLight, otherData.normalWS, viewWS);
        for (int j = 0; j < GetAdditionalLightsCount(); ++j)
        {
            Light light = GetAdditionalLight(j, i.positionWS.xyz);
            half3 attenuatedLightColor = light.color * light.distanceAttenuation;
            color.rgb += LightingFur(i, brdfData, light, otherData.normalWS, viewWS);
        }
        
        return color;
    }
    #endif




    //---------------------------------------------------------------------Phong--------------------------------------------------------------------
    



    //------------------------------------------计算自定义光照----------------------------------

// #if defined(CUSTOMPBR)
//     //PBR
//     half3 CalculateCustomPBR(v2f i, half3 albedo, half3 normalTS, half metallic, half smoothness, half occlusion, half alpha, half3 emission, half shadowBright, half3 refractNormal)
//     {
//         //BRDF        
//         BRDFData brdfData;        
//         InitializeBRDFData(albedo, metallic, occlusion, smoothness, alpha, brdfData);

// 	#if defined(DEBUG_DISPLAY)
//         InputData inputData = InitInputData(i);
//         SurfaceData surfaceData = InitSurfaceData(i, albedo, 1, metallic, smoothness, occlusion, emission, alpha, normalTS);
//     	half4 debugColor;
//         if (CanDebugOverrideOutputColor(inputData, surfaceData, brdfData, debugColor))
//         {
//             return debugColor;
//         }
// 	#endif

//         //PrepareRender
//         float3 viewDir = 0;
//         float4 shadowCoord  = 0;
//         half4 shadowMask = 1;
//         half3 bakedGI = 0;
//         AmbientOcclusionFactor aoFactor;
//         Light mainLight;
//         PrepareRender(i, occlusion, viewDir, shadowCoord, shadowMask, bakedGI, aoFactor, mainLight);

//         //shadowBright
//         mainLight.shadowAttenuation = lerp(mainLight.shadowAttenuation, 1, shadowBright);
//         half3 lightColor = mainLight.color * mainLight.shadowAttenuation;

//         //color
//         half3 color = ExtendGlobalIllumination(brdfData, bakedGI, aoFactor.indirectAmbientOcclusion, i.positionWS, i.normalWS, viewDir);
//         PreLightData preLightData = GetPreLightData(i.normalWS, mainLight.direction, viewDir);
//         color += ExtendLightingPhysicallyBased(brdfData, preLightData, mainLight.color * mainLight.distanceAttenuation, mainLight.shadowAttenuation);
//         #ifdef _ADDITIONAL_LIGHTS
//             uint addLightCount = GetAdditionalLightsCount();
//             for (uint index = 0u; index < addLightCount; ++index)
//             {
//                 Light light = GetAdditionalLight(index, i.positionWS.xyz, shadowMask, aoFactor);
//                 preLightData = GetPreLightData(i.normalWS, light.direction, viewDir);

//                 lightColor += light.color * lerp(light.shadowAttenuation, 1, shadowBright) * light.distanceAttenuation;
//                 color += ExtendLightingPhysicallyBased(brdfData, preLightData, light.color * light.distanceAttenuation, light.shadowAttenuation);
//             }
//         #endif
        
//         // ramp图：可以给彩虹色
//         #if defined(_EnableRamp) //&& QUALITY_LEVEL >= HIGH
//         {
//             half3 refractDir = refract(-viewDir, i.normalWS, 1.0 / _RampIR);
//             half LdotR = saturate(dot(-mainLight.direction, refractDir) * 0.5 + 0.5);
//             half3 rampColor = SAMPLE_TEXTURE2D(_RampTex, sampler_RampTex, float2(LdotR, 0)).rgb;
//             color += rampColor * _RampIntensity  * lightColor * albedo;
//         }
//         #endif

//         // emission
//         color += emission;

//         //refract
//         #if defined(REFRACT)
//             half3 refractColor = CalculateRefract(refractNormal, i.uvAndOther.xy * _RefractMap_ST.xy + _RefractMap_ST.zw) ;            
//             half3 transmissionColor = _TransmissionColor.rgb;
//             transmissionColor *= refractColor;
            
//             color += occlusion * brdfData.diffuse  * transmissionColor * lightColor;
//         #endif

//         // fresnel
//         #if defined(_EnableFresnel)             
//             half3 fresnel = CalculateFresnel(i.normalWS, viewDir, _FresnelInsideColor.rgb, _FresnelOutsideColor.rgb, _FresnelPower, _FresnelRange, _FresnelIntensity);
//             color += fresnel  * albedo * lightColor;
//         #endif
 

//         //fog        
//         #if defined (ATMOSPHERE_ON) && !defined(ATMOSPHERE_POSTPROCESS_ON)
//             color = CalculateAtmosphere(color, i.inscattering);
//         #endif

//         return color.rgb;
//     }
//     half3 CalculateCustomPBR(v2f i, half3 albedo, half3 normalTS, half metallic, half smoothness, half occlusion, half alpha, half3 emission)
//     {
//         return CalculateCustomPBR(i, albedo, normalTS, metallic, smoothness, occlusion, alpha, emission, 0, 0);
//     }

// #endif
    
