float3 _LightDirection;

#if defined (_EnableWind)
#include "RotateAroundAxisFunction.hlsl"
#include "WindFunction.hlsl"
#endif

struct vert
{
    float3 vertex : POSITION;
    float3 normal : NORMAL;
    float4 tangent : TANGENT;
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
    v2f o=(v2f)0;
    
#if defined (INSTANCING_ON)
    UNITY_SETUP_INSTANCE_ID(v);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
    UNITY_TRANSFER_INSTANCE_ID(v, o);
#endif

    o.uvAndOther.xy = v.texcoord;
    float3 positionWS = TransformObjectToWorld(v.vertex.xyz);        

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
    float3 lightDirectionWS = _MainLightPosition.xyz;

    float3 normalWS = TransformObjectToWorldNormal(v.normal);
    float4 positionCS = TransformWorldToHClip(ApplyShadowBias(positionWS, normalWS, lightDirectionWS));

#if UNITY_REVERSED_Z
    positionCS.z = min(positionCS.z, positionCS.w * UNITY_NEAR_CLIP_VALUE);
#else
    positionCS.z = max(positionCS.z, positionCS.w * UNITY_NEAR_CLIP_VALUE);
#endif   

    o.positionCS = positionCS;
    return o;
}

half4 Frag(v2f i) : SV_TARGET
{
#if defined (_EnableClip)
    half4 baseColor = SAMPLE_TEXTURE2D( _BaseMap, sampler_BaseMap, i.uvAndOther.xy );
    clip(baseColor.a - _Clip);
#endif

#if defined (TRANSPARENT)
    half4 baseColor = SAMPLE_TEXTURE2D( _BaseMap, sampler_BaseMap, i.uvAndOther.xy );
    clip(baseColor.a - 0.5);
#endif

#if defined (DISSOLVE)
    float dissolve = SAMPLE_TEXTURE2D(_DissolveMap, sampler_DissolveMap, i.uv).r;
    clip(dissolve -_DissolveFactor);
#endif  

#if defined (MIXCOLOR_G)
    float b =  SAMPLE_TEXTURE2D(_MixMap1, sampler_MixMap1, i.uv).b;
    b = step(b, 0.15);
    b = step(b, 0.25) - b;
    clip(b);
#endif
    return 0;
}

