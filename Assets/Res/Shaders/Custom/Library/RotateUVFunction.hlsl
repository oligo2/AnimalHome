
inline float2 RotateUVByTime(float2 uv, float rotateSpeed)
{
	uv = uv - float2(0.5, 0.5);
	float sin1 = sin(rotateSpeed * _Time.x);
	float cos1 = cos(rotateSpeed * _Time.x);
	return float2(uv.x * cos1 - uv.y * sin1 + 0.5,
				uv.x * sin1 + uv.y * cos1 + 0.5	);
}
inline float2 RotateByTimeAndMoveUV(float2 uv, float2 move, float rotateStart, float4 st)
{
	uv = (RotateUVByTime(uv, rotateStart)*st.xy + _Time.x*float2(move.x, move.y) + float2(st.z, st.w));
	return uv;
}



inline float2 RotateUV(float2 uv, float rotateStart)
{
	uv = uv - float2(0.5, 0.5);
	float sin1 = sin(rotateStart);
	float cos1 = cos(rotateStart);
	return float2(uv.x * cos1 - uv.y * sin1 + 0.5,
				uv.x * sin1 + uv.y * cos1 + 0.5	);
}
inline float2 RotateAndMoveUV(float2 uv, float2 move, float rotateStart, float4 st)
{
	uv = (RotateUV(uv, rotateStart)*st.xy + _Time.x*float2(move.x, move.y) + float2(st.z, st.w));
	return uv;
}
