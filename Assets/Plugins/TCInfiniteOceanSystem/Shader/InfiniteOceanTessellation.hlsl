#ifndef INFINITE_OCEAN_TESSELLATION_INCLUDED
#define INFINITE_OCEAN_TESSELLATION_INCLUDED

struct TessellationFactors
{
    float edge[3] : SV_TessFactor;
    float inside : SV_InsideTessFactor;
};

struct ControlPointHull
{
    float4 positionOS : INTERNALTESSPOS;
    float3 normalOS : NORMAL;
    float4 tangentOS : TANGENT;
    float2 texcoord : TEXCOORD0;
    float4 color : COLOR;
    // UNITY_VERTEX_INPUT_INSTANCE_ID
};

ControlPointHull Vert(Attributes input)
{
    ControlPointHull output;
    output.positionOS = input.positionOS;
    output.normalOS = input.normalOS;
    output.tangentOS = input.tangentOS;
    output.texcoord = input.texcoord;
    output.color = input.color;
    return output;
}

float CalcDistanceTessFactor(float4 positionOS, float minDist, float maxDist, float tess)
{
    float3 worldPosition = TransformObjectToWorld(positionOS.xyz);
    float dist = distance(worldPosition, GetCameraPositionWS());
    float f = clamp(1.0 - (dist - minDist) / (maxDist - minDist), 0.01, 1.0) * tess;
    return f;
}

//---------------------------------------------------------------------------------------------------------------------------------------------------------
float4 CalcTriEdgeTessFactors(float3 triVertexFactors)
{
    float4 tess;
    tess.x = 0.5 * (triVertexFactors.y + triVertexFactors.z);
    tess.y = 0.5 * (triVertexFactors.x + triVertexFactors.z);
    tess.z = 0.5 * (triVertexFactors.x + triVertexFactors.y);
    tess.w = (triVertexFactors.x + triVertexFactors.y + triVertexFactors.z) / 3.0f;
    return tess;
}

float DistanceToPlane(float3 pos, float4 plane)
{
    float d = dot(float4(pos, 1.0f), plane);
    return d;
}

bool IsTriangleVisible(float3 wpos0, float3 wpos1, float3 wpos2, float cullEps)
{
    float4 planeTest;
    // left
    planeTest.x = ((DistanceToPlane(wpos0, unity_CameraWorldClipPlanes[0]) > -cullEps) ? 1.0f : 0.0f) +
        ((DistanceToPlane(wpos1, unity_CameraWorldClipPlanes[0]) > -cullEps) ? 1.0f : 0.0f) +
        ((DistanceToPlane(wpos2, unity_CameraWorldClipPlanes[0]) > -cullEps) ? 1.0f : 0.0f);
    // right
    planeTest.y = ((DistanceToPlane(wpos0, unity_CameraWorldClipPlanes[1]) > -cullEps) ? 1.0f : 0.0f) +
        ((DistanceToPlane(wpos1, unity_CameraWorldClipPlanes[1]) > -cullEps) ? 1.0f : 0.0f) +
        ((DistanceToPlane(wpos2, unity_CameraWorldClipPlanes[1]) > -cullEps) ? 1.0f : 0.0f);
    // top
    planeTest.z = ((DistanceToPlane(wpos0, unity_CameraWorldClipPlanes[2]) > -cullEps) ? 1.0f : 0.0f) +
        ((DistanceToPlane(wpos1, unity_CameraWorldClipPlanes[2]) > -cullEps) ? 1.0f : 0.0f) +
        ((DistanceToPlane(wpos2, unity_CameraWorldClipPlanes[2]) > -cullEps) ? 1.0f : 0.0f);
    // bottom
    planeTest.w = ((DistanceToPlane(wpos0, unity_CameraWorldClipPlanes[3]) > -cullEps) ? 1.0f : 0.0f) +
        ((DistanceToPlane(wpos1, unity_CameraWorldClipPlanes[3]) > -cullEps) ? 1.0f : 0.0f) +
        ((DistanceToPlane(wpos2, unity_CameraWorldClipPlanes[3]) > -cullEps) ? 1.0f : 0.0f);

    // has to pass all 4 plane tests to be visible
    return !all(planeTest);
}

float4 DistanceBasedTessCull(float4 v0, float4 v1, float4 v2, float minDist, float maxDist, float tessFactor, float maxDisplace)
{
    float3 pos0 = mul(UNITY_MATRIX_M, v0).xyz;
    float3 pos1 = mul(UNITY_MATRIX_M, v1).xyz;
    float3 pos2 = mul(UNITY_MATRIX_M, v2).xyz;
    float4 tess;


    if (IsTriangleVisible(pos0, pos1, pos2, maxDisplace))
    {
        tess = 0.0f;
    }
    else
    {
        float3 f;
        f.x = CalcDistanceTessFactor(v0, minDist, maxDist, tessFactor);
        f.y = CalcDistanceTessFactor(v1, minDist, maxDist, tessFactor);
        f.z = CalcDistanceTessFactor(v2, minDist, maxDist, tessFactor);
        tess = CalcTriEdgeTessFactors(f);
    }
    return tess;
}

TessellationFactors HSConstantFactor(InputPatch<ControlPointHull, 3> patch)
{
    TessellationFactors f;
    half4 factor = DistanceBasedTessCull(patch[0].positionOS, patch[1].positionOS, patch[2].positionOS, 1, _TesselationMaxDistance,
                                         _TesselationFactor, _TesselationMaxDisplace);
    f.edge[0] = factor.x;
    f.edge[1] = factor.y;
    f.edge[2] = factor.z;
    f.inside = factor.w;

    return f;
}

[domain("tri")]
[outputcontrolpoints(3)]
[outputtopology("triangle_cw")]
[partitioning("pow2")]
[patchconstantfunc("HSConstantFactor")]
ControlPointHull HullProgram(InputPatch<ControlPointHull, 3> patch, uint id : SV_OutputControlPointID) { return patch[id]; }

[domain("tri")]
Varyings DomainProgram(TessellationFactors factors, OutputPatch<ControlPointHull, 3> patch, float3 barycentricCoordinates : SV_DomainLocation)
{
    Attributes v;

    #define DomainInterpolate(fieldName) v.fieldName = \
                        patch[0].fieldName * barycentricCoordinates.x + \
                        patch[1].fieldName * barycentricCoordinates.y + \
                        patch[2].fieldName * barycentricCoordinates.z;
    DomainInterpolate(positionOS)
    DomainInterpolate(texcoord)
    DomainInterpolate(color)
    DomainInterpolate(normalOS)
    DomainInterpolate(tangentOS)
    return AfterTessVertProgram(v);
}

#endif
