SamplerState sampler_LinearClamp;
SamplerState sampler_LinearRepeat;
// SamplerState sampler_PointClamp;
// SamplerState sampler_PointRepeat;

struct vert 
{
    float3 vertex : POSITION;

    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct v2f
{   
    float4 uvAndOther : TEXCOORD0;	
    float4 positionCS : SV_POSITION;
    
#if defined (DEPTH) || defined(SCREEN)
    float4 projected : TEXCOORD1;
#endif  

    UNITY_VERTEX_OUTPUT_STEREO
};

v2f Vert(vert v)
{
    v2f o = (v2f)0;

    o.uvAndOther.xy = v.vertex.xy;
    o.positionCS = TransformObjectToHClip(v.vertex);
    
#if defined(DEPTH) || defined(SCREEN)
    o.projected.xy = (float2(o.positionCS.x, o.positionCS.y * _ProjectionParams.x) + o.positionCS.w)* 0.5f;
    o.projected.zw = o.positionCS.zw;
#endif

    return o;
}