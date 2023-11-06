/** 
名称：
作者：利伟民
时间：2022.06.16
描述：
    1.
项目参考：

**/
#ifndef PRE_LIGHT_DATA_INCLUDED
#define PRE_LIGHT_DATA_INCLUDED

struct PreLightData
{
    half3 N; //法线
    half3 L; //光线
    half3 V; //视线

    half NdotV;
    half clampedNdotV;
    half saturateNdotV;

    half NdotL;
    half saturateNdotL;
    half absNdotL;
    half halfLambert;

    half LdotV;

    float3 H; //半角向量
    float NdotH;
    float saturateNdotH;
    float LdotH;
    float saturateLdotH;
};

//优化：预计算各种方向的点乘，方便后续复用
PreLightData GetPreLightData(half3 N, half3 L, half3 V)
{
    PreLightData preLightData;
    preLightData.N = N;
    preLightData.L = L;
    preLightData.V = V;

    preLightData.NdotV = dot(N, V);
    preLightData.clampedNdotV = ClampNdotV(preLightData.NdotV);
    preLightData.saturateNdotV = saturate(preLightData.NdotV);

    preLightData.NdotL = dot(N, L);
    preLightData.saturateNdotL = saturate(preLightData.NdotL);
    preLightData.absNdotL = abs(preLightData.NdotL);
    preLightData.halfLambert = saturate(preLightData.NdotL * 0.5 + 0.5);

    preLightData.LdotV = dot(L, V);

    float3 normalWSfloat3 = float3(N);
    float3 lightDirectionWSfloat3 = float3(L);
    float3 viewDirectionWSfloat3 = float3(V);
    
    #if QUALITY_LEVEL == ULTRA
    float invLenLV = rsqrt(max(2.0 * preLightData.LdotV + 2.0, FLT_EPS)); // invLenLV = rcp(length(L + V)), clamp to avoid rsqrt(0) = inf, inf * 0 = NaN
    float NdotH = (preLightData.NdotL + preLightData.NdotV) * invLenLV;
    float LdotH = invLenLV * preLightData.LdotV + invLenLV;
    float3 halfDirWSfloat3 = (lightDirectionWSfloat3 + viewDirectionWSfloat3) * invLenLV;
    halfDirWSfloat3 = SafeNormalize(halfDirWSfloat3);
    #else
    float3 halfDirWSfloat3 = SafeNormalize(lightDirectionWSfloat3 + viewDirectionWSfloat3);
    float NdotH = dot(normalWSfloat3, halfDirWSfloat3);
    float LdotH = dot(lightDirectionWSfloat3, halfDirWSfloat3);
    #endif

    preLightData.H = halfDirWSfloat3;
    preLightData.NdotH = NdotH;
    preLightData.saturateNdotH = saturate(preLightData.NdotH);
    preLightData.LdotH = LdotH;
    preLightData.saturateLdotH = saturate(preLightData.LdotH);

    return preLightData;
}

#endif
