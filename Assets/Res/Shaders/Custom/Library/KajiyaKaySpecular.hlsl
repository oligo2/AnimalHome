#ifndef KAJIYA_KAY_INCLUDED
#define KAJIYA_KAY_INCLUDED

half3 KajiyaKaySpecular(v2f i, BRDFData brdfData, half3 normalWS,
                        half3 viewWS, half3 h, half NdotL, half LdotH)
{
    float NdotV = dot(i.normalWS.xyz, viewWS);
    
    half3 t1 = ShiftTangent(i.bitangentWS.xyz, normalWS, _KKShift);
    half3 D1 = _KKColor.rgb * D_KajiyaKay(t1, h, _KKExponent * _KKExponent);
    
    half3 F = F_Schlick(brdfData.specular, LdotH);
    half G = NdotL * saturate(NdotV * FLT_MAX) * 0.25;
    
    return D1 * F * G;
}
#endif
