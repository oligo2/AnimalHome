float4 Frag(v2f i, FRONT_FACE_TYPE facing : FRONT_FACE_SEMANTIC) : SV_Target
{
	#if defined(INSTANCING_ON)
		UNITY_SETUP_INSTANCE_ID(i);
	#endif

    //base		
    float2 uv = i.uvAndOther.xy;
    float hight = i.uvAndOther.z;
	half occlusion = 1;
	half3 emission = 0;
	half smoothness = 0;

    float4 baseTex = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, uv);    
    float4 baseColor = baseTex;    
#if defined(GRADUALCOLOR) 
    smoothness = _Smoothness*  baseTex.g;
    occlusion = baseTex.b;
    baseColor.rgb = lerp(_BaseColor.rgb, _Base2Color.rgb, baseTex.r);    
#else
    baseColor.rgb *= _BaseColor;
#endif

    float alpha = baseColor.a;
    #if defined (_EnableClip)
        clip(alpha - _Clip);
    #endif

#if defined (INSERTCUTTING)
    half d = abs(dot(i.normalWS, i.viewDirWS));    

    float start = 0.3;
    float end = 0.2;
    float dither = 1;
    if(d < start){
    dither = d/(start - end) - end / (start - end); 
    const float DITHER_THRESHOLDS[16] =
    {
        1.0 / 17.0,  9.0 / 17.0,  3.0 / 17.0, 11.0 / 17.0,
        13.0 / 17.0,  5.0 / 17.0, 15.0 / 17.0,  7.0 / 17.0,
        4.0 / 17.0, 12.0 / 17.0,  2.0 / 17.0, 10.0 / 17.0,
        16.0 / 17.0,  8.0 / 17.0, 14.0 / 17.0,  6.0 / 17.0
    };
    float2 pos = (i.projected.xy/ i.projected.w)*_ScreenParams.xy;
    int index = (int(pos.x) % 4) * 4 + int(pos.y) % 4;
    clip(dither - DITHER_THRESHOLDS[index]);
    }


    // clip(d - _Clip);// * (1+i.uvAndOther.w/10));
#endif
    
    if(_EnableTileColor)
    {
        float2 worldUV = i.positionWS.xz/100 * _TileColorMap_ST.xy;
        half3 tileColor = SAMPLE_TEXTURE2D(_TileColorMap, sampler_TileColorMap, worldUV).rgb;

        baseColor.rgb *= tileColor;
        
    }
    else
    {
    //mix
#if defined (LOD0) || defined(LOD1)

    #if defined(GRADUALCOLOR) 
    #else
        half4 mixValue = SAMPLE_TEXTURE2D(_MixMap, sampler_MixMap, uv);
        smoothness = _Smoothness* mixValue.g;
        occlusion = mixValue.b;
        emission = mixValue.a;
    #endif
#endif
    }

#if defined (VERTEXCOLOR)
    occlusion *= i.vertexColor.r;
    if(_EnableShowVertexColor)
    {
        return i.vertexColor;
    }
#endif

    //normal And face
	if(_EnableTurnNormal)
	{
		i.normalWS.rgb = HandleDoubleFaceNormal(facing, i.normalWS.rgb);
	}
    float3 normalTS = i.normalWS.xyz;    
#if defined(NORMALMAP) && defined (LOD0)
	normalTS = UnpackNormal(SAMPLE_TEXTURE2D(_BumpMap, sampler_BumpMap, uv));
	i.normalWS.rgb = CalculateNormalMap(i, normalTS);
#endif

    //VT
#if defined(_TERRAIN_VT_ENABLED)
    if(_EnableVT)
    {
        baseColor.rgb = CalculateVTColor(baseColor, i.positionOS, _VTFade);
        occlusion = 1;
    }
#endif
    // return baseColor * 3.15;

	//emission
#if defined (LOD0) || defined(LOD1)
	if (_EnableEmission)
	{
		emission *= _EmissionColor.rgb;
	}
#endif

    //AO对阴影补亮的影响
    half shadowBright = _ShadowBright - _ShadowBright *  (1-occlusion )* _OcclusionForBright;

    //color
    
    BRDFData brdfData;
    InitializeBRDFData(baseColor.rgb, 0, 0, smoothness, alpha, brdfData);
    OtherData otherData = InitializeOtherData(normalWS, normalTS, emission, occlusion, shadowBright);

    float3 color = CalculatePhong(i, brdfData, otherData, alpha);

    return float4(color , alpha);
}