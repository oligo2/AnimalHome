/** 
名称：
作者：利伟民
时间：2022.06.16
描述：
    1.
项目参考：

**/
#ifndef EXTEND_DIRECT_BRDF_DIFFUSE_INCLUDED
#define EXTEND_DIRECT_BRDF_DIFFUSE_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/BRDF.hlsl"

//摘抄自 HDRP 中 Lit.hlsl 的 EvaluateBSDF 方法
half3 DisneyDiffuseNoPI(BRDFData brdfData, PreLightData preLightData)
{
    return brdfData.diffuse * DisneyDiffuseNoPI(preLightData.clampedNdotV, abs(preLightData.NdotL), preLightData.LdotV, brdfData.perceptualRoughness);
}

half3 ExtendDirectBRDFDiffuse(BRDFData brdfData, PreLightData preLightData)
{
    #if QUALITY_LEVEL == ULTRA
    return DisneyDiffuseNoPI(brdfData, preLightData);
    #else
    return brdfData.diffuse;
    #endif
}

#endif
