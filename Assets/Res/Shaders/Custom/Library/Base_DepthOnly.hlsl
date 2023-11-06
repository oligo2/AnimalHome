#if defined (_EnableWind)
#include "RotateAroundAxisFunction.hlsl"
#include "WindFunction.hlsl"
#endif

struct vert
{
    float3 vertex : POSITION;
    float2 texcoord : TEXCOORD0;
#if defined (VERTEXCOLOR)
    float4 color :COLOR;
#endif

#if defined (INSTANCING_ON)
    UNITY_VERTEX_INPUT_INSTANCE_ID
#endif
};
struct v2f
{
    float4 positionCS : SV_POSITION;
    float4 uvAndOther : TEXCOORD0;

#if defined (INSTANCING_ON)
    UNITY_VERTEX_INPUT_INSTANCE_ID
    UNITY_VERTEX_OUTPUT_STEREO
#endif
};

v2f Vert(vert v)
{
    v2f o = (v2f)0;
    
#if defined (INSTANCING_ON)
    UNITY_SETUP_INSTANCE_ID(v);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
    UNITY_TRANSFER_INSTANCE_ID(v, o);
#endif

    o.uvAndOther.xy = v.texcoord;
    float3 positionWS = TransformObjectToWorld(v.vertex);

//vertexAnimation
#if defined (_EnableWind)   
    #if defined(LITINDIREDCT)
        float3 windDirection = TransformWorldToObjectDir(instanceID, _WindDirection.xyz, true);
    #else
        float3 windDirection = TransformWorldToObjectDir(_WindDirection.xyz);
    #endif

    v.vertex = CaculateWindAnimation(windDirection, _WindDirection.xyz, positionWS, v.vertex, o.uvAndOther.xy, o.uvAndOther.w);

    #if defined (LITINDIREDCT)
        positionWS = TransformObjectToWorld(instanceID, v.vertex.xyz);
    #else
        positionWS = TransformObjectToWorld(v.vertex.xyz);
    #endif  
#endif

    o.uvAndOther.z = v.vertex.y;
    o.positionCS = TransformWorldToHClip(positionWS);
    return o;
}
float4 Frag(v2f i) : SV_TARGET
{
#if defined (_EnableClip)  
    float4 baseColor = SAMPLE_TEXTURE2D( _BaseMap, sampler_BaseMap, i.uvAndOther.xy );
    clip(baseColor.a - _Clip);
#endif

#if defined (TRANSPARENT)
    half4 baseColor = SAMPLE_TEXTURE2D( _BaseMap, sampler_BaseMap, i.uvAndOther.xy );
    clip(baseColor.a - 0.9);
#endif

#if defined (DISSOLVE)
    float dissolve = SAMPLE_TEXTURE2D(_DissolveMap, sampler_DissolveMap, i.uvAndOther.xy).r;
    clip(dissolve -_DissolveFactor);
#endif  

#if defined (MIXCOLOR_G) //NPR角色逻辑 毛发不写入深度值
    float b =  SAMPLE_TEXTURE2D(_MixMap1, sampler_MixMap1, i.uvAndOther.xy).b;
    b = step(b, 0.15);
    b = step(b, 0.25) - b;
    clip(b);
#endif
    return 0;
}
