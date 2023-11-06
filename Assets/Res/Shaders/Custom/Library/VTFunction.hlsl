


half3 CalculateVTColor(half3 color, float4 pos, half fade)
{
	float2 uvVT = TerrainVT_GetUV(pos.xyz);
	float terrainH = pos.y - pos.w - g_TerrainRootPos.y;
	half4 col = tex2Dlod(g_TerrainColorVT, float4(uvVT, 0, 0));
	float lerpValue = saturate(terrainH / fade);
	return lerp(col.rgb, color, lerpValue).rgb;
}


