#ifndef BRDF_FUNCTION_INCLUDED
#define BRDF_FUNCTION_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/BRDF.hlsl"

//摘抄自 HDRP 中 Lit.hlsl 的 EvaluateBSDF 方法
half3 DirectBRDFSpecular_HDRP(BRDFData brdfData, half3 normalWS, half3 lightDirectionWS, half3 viewDirectionWS)
{
    float3 halfDir = SafeNormalize(lightDirectionWS + viewDirectionWS);
    float NoH = saturate(dot(normalWS, halfDir));
    half LoH = half(saturate(dot(lightDirectionWS, halfDir)));
    float NoL = abs(dot(normalWS, lightDirectionWS));
    float NoV = ClampNdotV(dot(normalWS, viewDirectionWS));

    float3 F = F_Schlick(brdfData.specular, LoH);
    float DV = DV_SmithJointGGX(NoH, NoL, NoV, brdfData.roughness);
    DV *= PI; //URP是无PI的版本，这里要乘回PI
    return F * DV;
}


//摘抄自 BRDF.hlsl 的 DirectBRDFSpecular 方法
half3 DirectBRDFSpecular_URP(BRDFData brdfData, half3 normalWS, half3 lightDirectionWS, half3 viewDirectionWS)
{
    float3 halfDir = SafeNormalize(lightDirectionWS + viewDirectionWS);
    float NoH = saturate(dot(normalWS, halfDir));
    half LoH = half(saturate(dot(lightDirectionWS, halfDir)));

    float d = NoH * NoH * brdfData.roughness2MinusOne + 1.00001f;
    half d2 = half(d * d);

    half LoH2 = LoH * LoH;
    half specularTerm = brdfData.roughness2 / (d2 * max(half(0.1), LoH2) * brdfData.normalizationTerm);

    #if defined (SHADER_API_MOBILE) || defined (SHADER_API_SWITCH)
    specularTerm = specularTerm - HALF_MIN;
    specularTerm = clamp(specularTerm, 0.0, 100.0); // Prevent FP16 overflow on mobiles
    #endif

    return brdfData.specular * specularTerm;
}

half3 DirectBlinnPhongSpecular(BRDFData brdfData, half3 normalWS, half3 lightDirectionWS, half3 viewDirectionWS)
{
    float3 halfDir = SafeNormalize(lightDirectionWS + viewDirectionWS);
    float NoH = saturate(dot(normalWS, halfDir));

    half smoothness = 1.0 - brdfData.perceptualRoughness;
    //来自于 Lighting.hlsl 的 CalculateBlinnPhong 方法
    //half shininess = exp2(10 * smoothness + 1);
    half shininess = exp2(6.5 * smoothness + 1); //lwm：经验公式，在URP场景的单直线光模式下，6.5比10更接近PBR高光形状
    half modifier = pow(NoH, shininess);
    return brdfData.specular * modifier;
}
#endif
