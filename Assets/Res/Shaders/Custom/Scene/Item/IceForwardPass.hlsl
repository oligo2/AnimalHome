
half4 Frag(v2f i) : SV_Target
{
	#if defined(INSTANCING_ON)
		UNITY_SETUP_INSTANCE_ID(i);
	#endif

	//base
	float2 uv = i.uvAndOther.xy;
	half occlusion = 1;
	half smoothness = 1;
	half metallic = 0;
	half3 emission = 0;

	//Color
	half4 baseColor = 0;

	//normal
	float3 normal = i.normalWS.rgb;
#if defined (LOD0)
	normal = UnpackNormal(SAMPLE_TEXTURE2D(_BumpMap, sampler_BumpMap, uv));
	i.normalWS.rgb = CalculateNormalMap(i, normal);
	#if defined (_EnableClip)
		if(_EnableTurnNormal)
		{
			i.normalWS.rgb = HandleDoubleFaceNormal(facing, i.normalWS.rgb);
		}
	#endif
#endif

	//扭曲
	half2 heatXY = SAMPLE_TEXTURE2D(_HeatMap, sampler_HeatMap, uv).rg;
	float2 offset = heatXY * _HeatIntensity;

 
	//立体颜色图
	if(_EnableSolid)
	{
		half3 solidColor = SAMPLE_TEXTURE2D(_SolidMap, sampler_SolidMap, TRANSFORM_TEX(i.uv34.xy, _SolidMap) );
		baseColor.rgb += solidColor * _SolidColor;
	}

   	//深度
	float3 viewDirTS = CalculateParallaxIterationsViewDir(i.tangentWS, i.bitangentWS, i.normalWS);

	//表面纹理
	float2 uv2 = ParallaxMappingIteration1(uv, viewDirTS, _Depth /100, _BaseMap, sampler_BaseMap);
	half4 baseColor2 = SAMPLE_TEXTURE2D( _BaseMap, sampler_BaseMap, uv2);
	baseColor.rgb += baseColor2 *_BaseColor;
		

	//内部纹理
	if(_EnableInside)
	{
		float2 uv3 =  ParallaxMappingIterationDepth(uv, viewDirTS, _InsideDepth /100, _InsideMap, sampler_InsideMap);
		half4 baseColor3 = SAMPLE_TEXTURE2D( _InsideMap, sampler_InsideMap, TRANSFORM_TEX(uv3, _InsideMap) );
		baseColor.rgb += baseColor3 * _InsideColor;
	}

	half alpha = 1;
#if defined (VERTEXCOLOR)
	baseColor.rgb *= i.vertexColor.rgb;
	alpha *= i.vertexColor.a;
#endif

	//color
	half3 color = CalculatePhong(i, baseColor.rgb , normal, smoothness, occlusion);

	//扭曲
	i.projected.xy = offset * i.projected.z + i.projected.xy;
	half3 sceneColor = 0;
	sceneColor = tex2Dproj(_CameraOpaqueTexture, i.projected / i.projected.w );

	color = (sceneColor*_Alpha + color*(1-_Alpha));
	return half4(color.rgb, alpha);
}