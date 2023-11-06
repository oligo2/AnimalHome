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
    half3 baseColor = baseTex;  
    smoothness = _Smoothness*  baseTex.g;
    occlusion = baseTex.b;
    baseColor = lerp(_BaseColor.rgb, _Base2Color.rgb, baseTex.r);    

    float alpha = baseTex.a;
    #if defined (_EnableClip)
        clip(alpha - _Clip);
    #endif

#if defined (SLICECUTTING)
    half d = abs(dot(i.normalWS, i.viewDirWS));    

    float start = 0.3;
    float end = 0.2;
    float dither = 1;
    if(d < start)
    {
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
#endif
    
#if defined (VERTEXCOLOR)
    occlusion *= i.vertexColor.r;
    if(_EnableShowVertexColor)
    {
        return i.vertexColor;
    }
#endif

    //normal And face
	// if(_EnableTurnNormal)
	// {
	// 	i.normalWS.rgb = HandleDoubleFaceNormal(facing, i.normalWS.rgb);
	// }
    float3 normalTS = i.normalWS.xyz;    
   

    //AO对阴影补亮的影响
    half shadowBright = _ShadowBright - _ShadowBright *  (1-occlusion )* _OcclusionForBright;

    //color
    float3 color = CalculatePhong(i, baseColor, normalTS, smoothness, occlusion, _EnableEmission ? emission : 0, shadowBright, shadowBright, 1);

    return float4(color , alpha);
}