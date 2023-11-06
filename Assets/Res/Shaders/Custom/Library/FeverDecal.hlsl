/** 
名称：Fever贴花
作者：利伟民，张雷
时间：2022.10.20
描述：

项目参考：

**/

#ifndef FEVER_DECAL_INCLUDED
#define FEVER_DECAL_INCLUDED


#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Packing.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"

TEXTURE2D(_FeverDecalAlbedoAtlas2D);
SAMPLER(sampler_FeverDecalAlbedoAtlas2D);
TEXTURE2D(_FeverDecalNormalAtlas2D);
SAMPLER(sampler_FeverDecalNormalAtlas2D);
TEXTURE2D(_FeverDecalDataTex);

#define UNITY_DEFINE_INSTANCED_PROP_ARRAY_ELEMENT(type, name, index) UNITY_DEFINE_INSTANCED_PROP(type, name##index##_)
#define UNITY_ACCESS_INSTANCED_PROP_ARRAY_ELEMENT(arr, name, index) UNITY_ACCESS_INSTANCED_PROP(arr, name##index##_);

UNITY_INSTANCING_BUFFER_START(FeverDecal)
UNITY_DEFINE_INSTANCED_PROP(int, _FeverDecalCount)
//GPUInstance传不了数组，这里只能拆开写
//UNITY_DEFINE_INSTANCED_PROP(float4x4, _FeverDecal_WorldToDecals[16])
//UNITY_DEFINE_INSTANCED_PROP(float4x4, _FeverDecal_NormalToWorlds[16])
UNITY_DEFINE_INSTANCED_PROP_ARRAY_ELEMENT(float4x4, _FeverDecal_WorldToDecals, 0)
UNITY_DEFINE_INSTANCED_PROP_ARRAY_ELEMENT(float4x4, _FeverDecal_WorldToDecals, 1)
UNITY_DEFINE_INSTANCED_PROP_ARRAY_ELEMENT(float4x4, _FeverDecal_WorldToDecals, 2)
UNITY_DEFINE_INSTANCED_PROP_ARRAY_ELEMENT(float4x4, _FeverDecal_WorldToDecals, 3)
UNITY_DEFINE_INSTANCED_PROP_ARRAY_ELEMENT(float4x4, _FeverDecal_WorldToDecals, 4)
UNITY_DEFINE_INSTANCED_PROP_ARRAY_ELEMENT(float4x4, _FeverDecal_WorldToDecals, 5)
UNITY_DEFINE_INSTANCED_PROP_ARRAY_ELEMENT(float4x4, _FeverDecal_WorldToDecals, 6)
UNITY_DEFINE_INSTANCED_PROP_ARRAY_ELEMENT(float4x4, _FeverDecal_WorldToDecals, 7)
UNITY_DEFINE_INSTANCED_PROP_ARRAY_ELEMENT(float4x4, _FeverDecal_WorldToDecals, 8)
UNITY_DEFINE_INSTANCED_PROP_ARRAY_ELEMENT(float4x4, _FeverDecal_WorldToDecals, 9)
UNITY_DEFINE_INSTANCED_PROP_ARRAY_ELEMENT(float4x4, _FeverDecal_WorldToDecals, 10)
UNITY_DEFINE_INSTANCED_PROP_ARRAY_ELEMENT(float4x4, _FeverDecal_WorldToDecals, 11)
UNITY_DEFINE_INSTANCED_PROP_ARRAY_ELEMENT(float4x4, _FeverDecal_WorldToDecals, 12)
UNITY_DEFINE_INSTANCED_PROP_ARRAY_ELEMENT(float4x4, _FeverDecal_WorldToDecals, 13)
UNITY_DEFINE_INSTANCED_PROP_ARRAY_ELEMENT(float4x4, _FeverDecal_WorldToDecals, 14)
UNITY_DEFINE_INSTANCED_PROP_ARRAY_ELEMENT(float4x4, _FeverDecal_WorldToDecals, 15)
UNITY_DEFINE_INSTANCED_PROP_ARRAY_ELEMENT(float4x4, _FeverDecal_NormalToWorlds, 0)
UNITY_DEFINE_INSTANCED_PROP_ARRAY_ELEMENT(float4x4, _FeverDecal_NormalToWorlds, 1)
UNITY_DEFINE_INSTANCED_PROP_ARRAY_ELEMENT(float4x4, _FeverDecal_NormalToWorlds, 2)
UNITY_DEFINE_INSTANCED_PROP_ARRAY_ELEMENT(float4x4, _FeverDecal_NormalToWorlds, 3)
UNITY_DEFINE_INSTANCED_PROP_ARRAY_ELEMENT(float4x4, _FeverDecal_NormalToWorlds, 4)
UNITY_DEFINE_INSTANCED_PROP_ARRAY_ELEMENT(float4x4, _FeverDecal_NormalToWorlds, 5)
UNITY_DEFINE_INSTANCED_PROP_ARRAY_ELEMENT(float4x4, _FeverDecal_NormalToWorlds, 6)
UNITY_DEFINE_INSTANCED_PROP_ARRAY_ELEMENT(float4x4, _FeverDecal_NormalToWorlds, 7)
UNITY_DEFINE_INSTANCED_PROP_ARRAY_ELEMENT(float4x4, _FeverDecal_NormalToWorlds, 8)
UNITY_DEFINE_INSTANCED_PROP_ARRAY_ELEMENT(float4x4, _FeverDecal_NormalToWorlds, 9)
UNITY_DEFINE_INSTANCED_PROP_ARRAY_ELEMENT(float4x4, _FeverDecal_NormalToWorlds, 10)
UNITY_DEFINE_INSTANCED_PROP_ARRAY_ELEMENT(float4x4, _FeverDecal_NormalToWorlds, 11)
UNITY_DEFINE_INSTANCED_PROP_ARRAY_ELEMENT(float4x4, _FeverDecal_NormalToWorlds, 12)
UNITY_DEFINE_INSTANCED_PROP_ARRAY_ELEMENT(float4x4, _FeverDecal_NormalToWorlds, 13)
UNITY_DEFINE_INSTANCED_PROP_ARRAY_ELEMENT(float4x4, _FeverDecal_NormalToWorlds, 14)
UNITY_DEFINE_INSTANCED_PROP_ARRAY_ELEMENT(float4x4, _FeverDecal_NormalToWorlds, 15)
UNITY_INSTANCING_BUFFER_END(FeverDecal)

float4x4 ApplyCameraTranslationToInverseMatrix(float4x4 inverseModelMatrix)
{
    #if (SHADEROPTIONS_CAMERA_RELATIVE_RENDERING != 0)
    // To handle camera relative rendering we need to apply translation before converting to object space
    float4x4 translationMatrix = { { 1.0, 0.0, 0.0, _WorldSpaceCameraPos.x },{ 0.0, 1.0, 0.0, _WorldSpaceCameraPos.y },{ 0.0, 0.0, 1.0, _WorldSpaceCameraPos.z },{ 0.0, 0.0, 0.0, 1.0 } };
    return mul(inverseModelMatrix, translationMatrix);
    #else
    return inverseModelMatrix;
    #endif
}

void EvalDecal(float4x4 worldToDecal, float4x4 normalToWorld, half decalMetallic, half decalSmoothness, float3 positionWS, inout half3 normalWS, inout half3 albedo, inout half metallic,
               inout half smoothness)
{
    half alphaBlend = normalToWorld[0][3];
    half normalBlend = normalToWorld[1][3];
    half msBlend = normalToWorld[2][3];

    float3 positionDS = mul(worldToDecal, float4(positionWS, 1.0)).xyz;
    positionDS = positionDS * float3(1.0, -1.0, 1.0) + float3(0.5, 0.5f, 0.5); // decal clip space
    positionDS = saturate(positionDS);

    UNITY_BRANCH
    if (all(0.0f < positionDS.xyz) && all(positionDS.xyz < 1.0f))
    {
        float2 uvScale = float2(normalToWorld[3][0], normalToWorld[3][1]);
        float2 uvBias = float2(normalToWorld[3][2], normalToWorld[3][3]);
        float2 sampleUV = positionDS.xz * uvScale + uvBias;

        //albedo
        half4 sampleColor = SAMPLE_TEXTURE2D(_FeverDecalAlbedoAtlas2D, sampler_FeverDecalAlbedoAtlas2D, sampleUV);
        half blendFactor = saturate(sampleColor.a * alphaBlend);
        albedo = lerp(albedo, sampleColor.rgb, blendFactor);

        //normalWS
        half4 sampleNormal = SAMPLE_TEXTURE2D(_FeverDecalNormalAtlas2D, sampler_FeverDecalNormalAtlas2D, sampleUV);
        half3 sampleNormalTS = UnpackNormalRG(sampleNormal.rgb);
        half3 sampleNormalWS = mul((float3x3)normalToWorld, sampleNormalTS);
        sampleNormalWS = SafeNormalize(sampleNormalWS);
        normalBlend = saturate(normalBlend * blendFactor);
        normalWS = lerp(normalWS, sampleNormalWS, normalBlend);
        normalWS = SafeNormalize(normalWS);

        //metalness, smoothness
        msBlend = saturate(msBlend * blendFactor);
        metallic = lerp(metallic, sampleNormal.b * decalMetallic, msBlend);
        smoothness = lerp(smoothness, sampleNormal.a * decalSmoothness, msBlend);
    }
}

#if defined(UNITY_INSTANCING_ENABLED)
#define EVAL_DECAL_INSTANCED(index, count, decalMetallic, decalSmoothness, positionWS, normalWS, albedo, metallic, smoothness) \
if(index < count)\
{\
    float4x4 worldToDecal = UNITY_ACCESS_INSTANCED_PROP_ARRAY_ELEMENT(FeverDecal, _FeverDecal_WorldToDecals, index);\
    float4x4 normalToWorld = UNITY_ACCESS_INSTANCED_PROP_ARRAY_ELEMENT(FeverDecal, _FeverDecal_NormalToWorlds, index);\
    EvalDecal(worldToDecal, normalToWorld, decalMetallic, decalSmoothness, positionWS, normalWS, albedo, metallic, smoothness);\
}
#endif

void ApplyFeverDecal(int startIndex, int endIndex, half decalMetallic, half decalSmoothness, float3 positionWS,
                     inout half3 normalWS, inout half3 albedo, inout half metallic, inout half smoothness)
{
    #if defined(UNITY_INSTANCING_ENABLED)
    int count = UNITY_ACCESS_INSTANCED_PROP(FeverDecal, _FeverDecalCount);
    /*
    float4x4 worldToDecals[16] = UNITY_ACCESS_INSTANCED_PROP(FeverDecal, _FeverDecal_WorldToDecals);
    float4x4 normalToWorlds[16] = UNITY_ACCESS_INSTANCED_PROP(FeverDecal, _FeverDecal_NormalToWorlds);
    UNITY_LOOP
    for (int i = 0; i < count; i++)
    {
        float4x4 worldToDecal = worldToDecals[i];
        float4x4 normalToWorld = normalToWorlds[i];
        EvalDecal(worldToDecal, normalToWorld, decalMetallic, decalSmoothness, positionWS, normalWS, albedo, metallic, smoothness);
    }
    */
    //GPUInstance传不了数组，这里只能拆开写
    EVAL_DECAL_INSTANCED(0, count, decalMetallic, decalSmoothness, positionWS, normalWS, albedo, metallic, smoothness);
    EVAL_DECAL_INSTANCED(1, count, decalMetallic, decalSmoothness, positionWS, normalWS, albedo, metallic, smoothness);
    EVAL_DECAL_INSTANCED(2, count, decalMetallic, decalSmoothness, positionWS, normalWS, albedo, metallic, smoothness);
    EVAL_DECAL_INSTANCED(3, count, decalMetallic, decalSmoothness, positionWS, normalWS, albedo, metallic, smoothness);
    EVAL_DECAL_INSTANCED(4, count, decalMetallic, decalSmoothness, positionWS, normalWS, albedo, metallic, smoothness);
    EVAL_DECAL_INSTANCED(5, count, decalMetallic, decalSmoothness, positionWS, normalWS, albedo, metallic, smoothness);
    EVAL_DECAL_INSTANCED(6, count, decalMetallic, decalSmoothness, positionWS, normalWS, albedo, metallic, smoothness);
    EVAL_DECAL_INSTANCED(7, count, decalMetallic, decalSmoothness, positionWS, normalWS, albedo, metallic, smoothness);
    EVAL_DECAL_INSTANCED(8, count, decalMetallic, decalSmoothness, positionWS, normalWS, albedo, metallic, smoothness);
    EVAL_DECAL_INSTANCED(9, count, decalMetallic, decalSmoothness, positionWS, normalWS, albedo, metallic, smoothness);
    EVAL_DECAL_INSTANCED(10, count, decalMetallic, decalSmoothness, positionWS, normalWS, albedo, metallic, smoothness);
    EVAL_DECAL_INSTANCED(11, count, decalMetallic, decalSmoothness, positionWS, normalWS, albedo, metallic, smoothness);
    EVAL_DECAL_INSTANCED(12, count, decalMetallic, decalSmoothness, positionWS, normalWS, albedo, metallic, smoothness);
    EVAL_DECAL_INSTANCED(13, count, decalMetallic, decalSmoothness, positionWS, normalWS, albedo, metallic, smoothness);
    EVAL_DECAL_INSTANCED(14, count, decalMetallic, decalSmoothness, positionWS, normalWS, albedo, metallic, smoothness);
    EVAL_DECAL_INSTANCED(15, count, decalMetallic, decalSmoothness, positionWS, normalWS, albedo, metallic, smoothness);
    #else
    UNITY_LOOP
    for (int i = startIndex; i < endIndex; i++)
    {
        float4x4 worldToDecal = float4x4(
            LOAD_TEXTURE2D(_FeverDecalDataTex, float2(0,i)),
            LOAD_TEXTURE2D(_FeverDecalDataTex, float2(1,i)),
            LOAD_TEXTURE2D(_FeverDecalDataTex, float2(2,i)),
            float4(0.0, 0.0, 0.0, 1.0));
        float4x4 normalToWorld = float4x4(
            LOAD_TEXTURE2D(_FeverDecalDataTex, float2(3,i)),
            LOAD_TEXTURE2D(_FeverDecalDataTex, float2(4,i)),
            LOAD_TEXTURE2D(_FeverDecalDataTex, float2(5,i)),
            LOAD_TEXTURE2D(_FeverDecalDataTex, float2(6,i)));
        EvalDecal(worldToDecal, normalToWorld, decalMetallic, decalSmoothness, positionWS, normalWS, albedo, metallic, smoothness);
    }
    #endif
}

#endif
