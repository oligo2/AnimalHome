/** 
名称：
作者：利伟民
时间：2022.06.16
描述：
    1.
项目参考：

**/
#ifndef EXTEND_DIRECT_BRDF_SPECULAR_INCLUDED
#define EXTEND_DIRECT_BRDF_SPECULAR_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/BRDF.hlsl"

//摘抄自 HDRP 中 Lit.hlsl 的 EvaluateBSDF 方法
half3 DirectBRDFSpecular_HDRP(BRDFData brdfData, PreLightData preLightData)
{
    float3 F = F_Schlick(brdfData.specular, preLightData.saturateLdotH);
    float DV = DV_SmithJointGGX(preLightData.saturateNdotH, preLightData.absNdotL, preLightData.clampedNdotV, brdfData.roughness);
    DV *= PI; //URP是无PI的版本，这里要乘回PI
    return F * DV;
}

//摘抄自 BRDF.hlsl 的 DirectBRDFSpecular 方法
half3 DirectBRDFSpecular_URP(BRDFData brdfData, PreLightData preLightData)
{
    float NoH = preLightData.saturateNdotH;
    half LoH = half(preLightData.saturateLdotH);

    // GGX Distribution multiplied by combined approximation of Visibility and Fresnel
    // BRDFspec = (D * V * F) / 4.0
    // D = roughness^2 / ( NoH^2 * (roughness^2 - 1) + 1 )^2
    // V * F = 1.0 / ( LoH^2 * (roughness + 0.5) )
    // See "Optimizing PBR for Mobile" from Siggraph 2015 moving mobile graphics course
    // https://community.arm.com/events/1155

    // Final BRDFspec = roughness^2 / ( NoH^2 * (roughness^2 - 1) + 1 )^2 * (LoH^2 * (roughness + 0.5) * 4.0)
    // We further optimize a few light invariant terms
    // brdfData.normalizationTerm = (roughness + 0.5) * 4.0 rewritten as roughness * 4.0 + 2.0 to a fit a MAD.
    float d = NoH * NoH * brdfData.roughness2MinusOne + 1.00001f;
    half d2 = half(d * d);

    half LoH2 = LoH * LoH;
    half specularTerm = brdfData.roughness2 / (d2 * max(half(0.1), LoH2) * brdfData.normalizationTerm);

    // On platforms where half actually means something, the denominator has a risk of overflow
    // clamp below was added specifically to "fix" that, but dx compiler (we convert bytecode to metal/gles)
    // sees that specularTerm have only non-negative terms, so it skips max(0,..) in clamp (leaving only min(100,...))
    #if defined (SHADER_API_MOBILE) || defined (SHADER_API_SWITCH)
    specularTerm = specularTerm - HALF_MIN;
    specularTerm = clamp(specularTerm, 0.0, 100.0); // Prevent FP16 overflow on mobiles
    #endif

    return brdfData.specular * specularTerm;
}

half3 DirectBlinnPhongSpecular(BRDFData brdfData, PreLightData preLightData)
{
    half smoothness = 1.0 - brdfData.perceptualRoughness;
    //来自于 Lighting.hlsl 的 CalculateBlinnPhong 方法
    half shininess = exp2(10 * smoothness + 1);
    half modifier = pow(preLightData.saturateNdotH, shininess);
    return brdfData.specular * modifier;
}

half3 ExtendDirectBRDFSpecular(BRDFData brdfData, PreLightData preLightData)
{
    #if QUALITY_LEVEL == ULTRA
    return DirectBRDFSpecular_HDRP(brdfData, preLightData);
    #elif QUALITY_LEVEL <= LOW
    return DirectBlinnPhongSpecular(brdfData, preLightData);
    #else
    //直接用 BRDF.hlsl 中内置的方法
    return DirectBRDFSpecular_URP(brdfData, preLightData);
    #endif
}
#endif
