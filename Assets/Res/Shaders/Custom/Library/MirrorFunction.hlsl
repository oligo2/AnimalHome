TextureCube KWS_CubemapReflectionRT;
texture2D KWS_ScreenSpaceReflectionRT;
float4 KWS_ScreenSpaceReflectionRT_TexelSize;
float4 KWS_ScreenSpaceReflection_RTHandleScale;

inline half3 GetCubemapReflection(float3 reflDir)
{
    reflDir.y = max(0, reflDir.y); //解决部分反射发黑问题(必须)
    return KWS_CubemapReflectionRT.Sample(sampler_LinearClamp, reflDir).xyz;
}

float2 GetScreenSpaceReflectionUV(half3 normal, half3 viewDir, float4x4 cameraProjectionMatrix)
{
    normal.xz = mul((float3x3)UNITY_MATRIX_V, half3(normal.x, 0, normal.z)).xz;
    viewDir = mul((float3x3)UNITY_MATRIX_V, viewDir);
    float3 ssrReflRay = reflect(-viewDir, normal);

    float4 ssrScreenPos = mul(cameraProjectionMatrix, float4(ssrReflRay, 1));
    ssrScreenPos.xy /= ssrScreenPos.w;
    return float2(ssrScreenPos.x * 0.5 + 0.5, -ssrScreenPos.y * 0.5 + 0.5);
}
    

inline float2 GetScreenSpaceReflectionNormalizedUV(float2 uv)
{
    return clamp(uv, 0.005, 0.995) * KWS_ScreenSpaceReflection_RTHandleScale.xy;
}
inline half4 GetScreenSpaceReflection(float2 uv)
{
    return KWS_ScreenSpaceReflectionRT.SampleLevel(sampler_LinearClamp, GetScreenSpaceReflectionNormalizedUV(uv), 0);
}

inline half4 GetScreenSpaceReflectionWithStretchingMask(float2 refl_uv)
{
    //refl_uv.y -= KWS_ReflectionClipOffset;

    float stretchingMask = 1 - abs(refl_uv.x * 2 - 1);
    stretchingMask = min(1, stretchingMask * 3);
    refl_uv.x = lerp(refl_uv.x * 0.97 + 0.015, refl_uv.x, stretchingMask);
    return GetScreenSpaceReflection(refl_uv);
}