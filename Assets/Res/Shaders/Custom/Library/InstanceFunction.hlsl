#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

CBUFFER_START(UnityPerMaterial)
StructuredBuffer<float4x4> _GrassWorldMatrix;
StructuredBuffer<int> _GrassRenderingIds;
CBUFFER_END

float3 TransformObjectToWorld(uint instanceID, float3 posOS)
{
	int grassID = _GrassRenderingIds[instanceID];
	unity_ObjectToWorld = _GrassWorldMatrix[grassID];
	return mul(unity_ObjectToWorld, float4(posOS, 1.0)).xyz;
}



// float3 TransformObjectToWorld(uint instanceID, float3 posOS)
// {
// 	int grassID = _GrassRenderingIds[instanceID];
// 	unity_ObjectToWorld = _GrassWorldMatrix[grassID];
// 	return mul(unity_ObjectToWorld, float4(posOS, 1.0)).xyz;
// }

float3 TransformObjectToWorldDir(uint instanceID,float3 dirOS, bool doNormalize = true)
{
	//int grassID = _GrassRenderingIds[instanceID];
	//unity_ObjectToWorld = _GrassWorldMatrix[grassID];
    float3 dirWS = mul((float3x3)unity_ObjectToWorld, dirOS);
    if (doNormalize)
        return SafeNormalize(dirWS);

    return dirWS;
}
float3 TransformObjectToWorldNormal(uint instanceID,float3 normalOS, bool doNormalize = true)
{
	//int grassID = _GrassRenderingIds[instanceID];
	//unity_ObjectToWorld = _GrassWorldMatrix[grassID];
//#ifdef UNITY_ASSUME_UNIFORM_SCALING
    return TransformObjectToWorldDir(instanceID,normalOS, doNormalize);
//#else
//    // Normal need to be multiply by inverse transpose
//    //float3 normalWS = mul(normalOS, transpose((float3x3)unity_ObjectToWorld)); //���ﱣ�ֵȱ����ţ���ʵӦ�������棬����û������꣬����Ӧ������������ת����ת��,�ȼ�����������
//    float3 normalWS = mul((float3x3)unity_ObjectToWorld,normalOS);
//    if (doNormalize)
//        return SafeNormalize(normalWS);

//    return normalWS;
//#endif
}
//TransformWorldToObjectDir
float3 TransformWorldToObjectDir(uint instanceID,float3 dirWS, bool doNormalize = true)
{
    //float3 dirOS = mul((float3x3)GetWorldToObjectMatrix(), dirWS);
    float3 dirOS = mul(dirWS,(float3x3)unity_ObjectToWorld);  //Ĭ�ϵ����ţ���������ת�õ��������
    if (doNormalize)
        return normalize(dirOS);

    return dirOS;
}

///获取矩阵
float4x4 GetObjectToWorldMatrixIndirect(uint instanceID)
{
    int grassID = _GrassRenderingIds[instanceID];
	unity_ObjectToWorld = _GrassWorldMatrix[grassID];
    return unity_ObjectToWorld;
}