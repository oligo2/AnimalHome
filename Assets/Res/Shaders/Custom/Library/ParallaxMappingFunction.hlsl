inline float3 ParallaxMappingPOM(in float2 uv, in float3 viewDir, in float height, Texture2D<float4> heightMap, SamplerState samplerState)
{
	viewDir.z = abs(viewDir.z) + 0.42;

	const float numLayers = 10;
	float layerHeight = height/numLayers;
	float3 offsetStep = layerHeight * viewDir/viewDir.z;
	offsetStep.z /= height;

	float3 curUV = float3(uv.xy, 0);
	float3 preUV = curUV;

	float curMapHeight = SAMPLE_TEXTURE2D(heightMap, samplerState, curUV.xy).a;
	float preMapHeight = curMapHeight;


	//当前层高度高于高度图高度时停止
	// while(curMapHeight > curUV.z)
	// {
	// 	preUV = curUV;
	// 	// curUV.z += offsetStep;
	// 	preMapHeight = curMapHeight;
	// 	curMapHeight = 0.5;//SAMPLE_TEXTURE2D(heightMap, samplerState, float4(curUV.xy, 0, 0)).a;
	// }

	//
	float w = (curMapHeight - curUV.z) / (abs((curMapHeight - curUV.z) - (preMapHeight- preUV.z)) + 1e-7f );
	curUV = curUV * (1-w) + preUV * w;
	curUV.z = curMapHeight * (1-w) + preMapHeight * w;

	return curUV;
}

inline float2 ParallaxMapping(in float2 uv, in float3 viewDirTS, in float heightScale, Texture2D<float4> heightMap, SamplerState samplerState)
{
	float height = SAMPLE_TEXTURE2D(heightMap, samplerState, uv).r;
	viewDirTS = normalize(viewDirTS);
	float2 newUV = viewDirTS.xy/viewDirTS.z * height * heightScale;

	return newUV;
}


float3 CalculateParallaxIterationsViewDir(float4 tangentWS, float4 bitangentWS, float4 normalWS)
{
	float3 viewDir = float3(normalWS.w, tangentWS.w, bitangentWS.w);
	viewDir = viewDir.x * half3(tangentWS.x, bitangentWS.x, normalWS.x ) + 
							viewDir.y * half3(tangentWS.y, bitangentWS.y, normalWS.y ) +  
							viewDir.z * half3(tangentWS.z, bitangentWS.z, normalWS.z );
	return viewDir;
}

//只绘制一次深度纹理
inline float2 ParallaxMappingIterationDepth(in float2 uv, in float3 viewDir, in float heightScale, Texture2D<float4> heightMap, SamplerState samplerState)
{
	float2 Offset1 =- (  viewDir.xy * heightScale ) + uv; 
	float2 newUV = Offset1;
	return newUV;
}
inline float2 ParallaxMappingIteration1(in float2 uv, in float3 viewDir, in float heightScale, Texture2D<float4> heightMap, SamplerState samplerState)
{
	float2 Offset1 = ( ( SAMPLE_TEXTURE2D(heightMap, samplerState, uv ).g - 1) * viewDir.xy * heightScale ) + uv; 
	// float2 Offset2 = ( ( SAMPLE_TEXTURE2D(heightMap, samplerState, Offset1 ).g - 1 ) * viewDir.xy * heightScale ) + Offset1; 
	// float2 Offset3 = ( ( SAMPLE_TEXTURE2D(heightMap, samplerState, Offset2 ).g - 1 ) * viewDir.xy * heightScale ) + Offset2; 
	float2 newUV = Offset1;
	return newUV;
}

//多次采样叠加的厚度纹理
inline float2 ParallaxMappingIterations(in float2 uv, in float3 viewDir, in float heightScale, Texture2D<float4> heightMap, SamplerState samplerState)
{
	float2 Offset1 = ( ( SAMPLE_TEXTURE2D(heightMap, samplerState, uv ).g - 1) * viewDir.xy * heightScale ) + uv; 
	float2 Offset2 = ( ( SAMPLE_TEXTURE2D(heightMap, samplerState, Offset1 ).g - 1 ) * viewDir.xy * heightScale ) + Offset1; 
	float2 Offset3 = ( ( SAMPLE_TEXTURE2D(heightMap, samplerState, Offset2 ).g - 1 ) * viewDir.xy * heightScale ) + Offset2; 
	float2 newUV = Offset3;
	return newUV;
}
