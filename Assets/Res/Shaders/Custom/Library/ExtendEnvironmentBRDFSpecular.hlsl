/** 
名称：
作者：利伟民
时间：2022.06.16
描述：
    1.
项目参考：

**/
#ifndef EXTEND_ENVIRONMENT_BRDF_SPECULAR_INCLUDED
#define EXTEND_ENVIRONMENT_BRDF_SPECULAR_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/BRDF.hlsl"

half3 ExtendRefract(BRDFData brdfData, half3 normalWS, half3 viewDirectionWS, half NoV)
{
    half3 reflectVector = reflect(-viewDirectionWS, normalWS);
    #if QUALITY_LEVEL == ULTRA
    //摘抄自 HDRP 中 Lit.hlsl 的 EvaluateBSDF_Env 方法
    half3 dominantReflectVector = GetSpecularDominantDir(normalWS, reflectVector, brdfData.perceptualRoughness, ClampNdotV(NoV));
    // When we are rough, we tend to see outward shifting of the reflection when at the boundary of the projection volume
    // Also it appear like more sharp. To avoid these artifact and at the same time get better match to reference we lerp to original unmodified reflection.
    // Formula is empirical.
    float roughness = brdfData.roughness;
    reflectVector = lerp(dominantReflectVector, reflectVector, saturate(smoothstep(0, 1, roughness * roughness)));
    #endif
    return reflectVector;
}

half ExtendFresnelTerm(half NoV)
{
    half oneSubNoV = 1.0 - NoV;

    #if QUALITY_LEVEL == ULTRA
    half fresnelTerm = Pow4(oneSubNoV) * oneSubNoV; //Pow5
    #else
    half fresnelTerm = Pow4(oneSubNoV);
    #endif

    return fresnelTerm;
}

//摘抄自 GlobalIllumination.hlsl 的 GlossyEnvironmentReflection 方法
half3 ExtendGlossyEnvironmentReflection(half3 reflectVector, float3 positionWS, half perceptualRoughness)
{
    #if !defined(_ENVIRONMENTREFLECTIONS_OFF)
    half3 irradiance;
    #if defined(_REFLECTION_PROBE_BLENDING) && QUALITY_LEVEL == ULTRA
    {
        irradiance = CalculateIrradianceFromReflectionProbes(reflectVector, positionWS, perceptualRoughness);
    }
    #else
    {
        #if defined(_REFLECTION_PROBE_BOX_PROJECTION) && QUALITY_LEVEL == ULTRA
        reflectVector = BoxProjectedCubemapDirection(reflectVector, positionWS, unity_SpecCube0_ProbePosition, unity_SpecCube0_BoxMin, unity_SpecCube0_BoxMax);
        #endif // _REFLECTION_PROBE_BOX_PROJECTION
        half mip = PerceptualRoughnessToMipmapLevel(perceptualRoughness);
        half4 encodedIrradiance = half4(SAMPLE_TEXTURECUBE_LOD(unity_SpecCube0, samplerunity_SpecCube0, reflectVector, mip));
        #if defined(UNITY_USE_NATIVE_HDR)
        irradiance = encodedIrradiance.rgb;
        #else
        irradiance = DecodeHDREnvironment(encodedIrradiance, unity_SpecCube0_HDR);
        #endif // UNITY_USE_NATIVE_HDR
    }
    #endif // _REFLECTION_PROBE_BLENDING
    return irradiance;
    #else
    return _GlossyEnvironmentColor.rgb;
    #endif // _ENVIRONMENTREFLECTIONS_OFF
}

half3 ExtendEnvironmentBRDFSpecular(BRDFData brdfData, half3 indirectSpecular, half fresnelTerm)
{
    half3 specular = indirectSpecular * lerp(brdfData.specular, brdfData.grazingTerm, fresnelTerm);
    // #if QUALITY_LEVEL >= MEDIUM
    //摘抄自 BRDF.hlsl 的 EnvironmentBRDFSpecular 方法
        float surfaceReduction = 1.0 / (brdfData.roughness2 + 1.0);
        return specular * surfaceReduction;
    // #else
        // return specular;
    // #endif
}

#endif
