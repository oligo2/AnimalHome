#ifndef SSS_INCLUDED
#define SSS_INCLUDED

half SubsurfaceScatterFactor(half3 normalDir, half3 lightDir, half3 viewDir, half frontSSSDistortion, half frontSSSPower, half backSSSDistortion, half backSSSPower)
{
    half result = 0;

    //计算正面次表面散射
    #if QUALITY_LEVEL >= HIGH
    half3 frontLitDir = normalDir * frontSSSDistortion - lightDir;
    half frontSSS = dot(viewDir, -frontLitDir);
    frontSSS = pow(saturate(frontSSS), frontSSSPower);
    result += frontSSS;
    #endif

    //计算背面次表面散射
    half3 backLitDir = normalDir * backSSSDistortion + lightDir;
    half backSSS = dot(viewDir, -backLitDir);
    backSSS = pow(saturate(backSSS), backSSSPower);
    result += backSSS;

    return result;
}

half SubsurfaceScatterFactor(half3 normalDir, half3 lightDir, half3 viewDir, half SSSDistortion, half SSSPower)
{
    return SubsurfaceScatterFactor(normalDir, lightDir, viewDir, SSSDistortion, SSSPower, SSSDistortion, SSSPower);
}

half3 SubsurfaceScatterColor(half3 normalDir, half3 lightDir, half3 viewDir, half SSSDistortion, half SSSPower, half3 SSSInsideColor, half3 SSSOutsideColor, half SSSIntensity)
{
    half sssFactor = SubsurfaceScatterFactor(normalDir, lightDir, viewDir, SSSDistortion, SSSPower);
    half3 sssColor = lerp(SSSInsideColor.rgb, SSSOutsideColor.rgb, saturate(sssFactor));
    sssColor *= SSSIntensity;
    return sssColor;
}

#endif
