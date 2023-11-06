// hash波形
// https://www.shadertoy.com/view/XlBSRz
// https://www.shadertoy.com/view/MdlyDs


static const int CLOUD_MARCH_STEPS = 80;
static const int CLOUD_SELF_SHADOW_STEPS = 5;


uniform float4 _uSunColor; 
uniform float4 _uSunDir;
uniform float _uAttenuation; 
uniform float DISTANT_CLOUD_MARCH_STEPS;

uniform float4 _uMoonDir;
uniform float4 _uMoonColor;
uniform float _uMoonAttenuation;

uniform float _uCloudsBaseEdgeSoftness;
uniform float _uCloudsBottomSoftness; 
uniform float _uCloudsDensity; 
uniform float _uCloudsForwardScatteringG; 
uniform float _uCloudsBackwardScatteringG; 

uniform float3 _uLightningColor;
uniform float _uLightning = 0.0f;

uniform float4 _uCloudsColor; 
uniform float4 _uFogColor; 
uniform float _uFogAmount; 

uniform float3 _uCloudsAmbientColorTop; 
uniform float3 _uCloudsAmbientColorBottom; 

#define _uEarthRadius 637100.0f
uniform float _uCloudsBottom; 
uniform float _uCloudsHeight; 
uniform float _uCloudsBearing; //云的方向偏移

uniform float _uCloudsBaseScale; 
uniform float _uCloudsDetailScale; 
uniform float _uCloudsCoverage; 
uniform float _uCloudsCoverageBias;
uniform float _uCurlScale;
uniform float _uCurlStrength;

uniform float _uCloudsMovementSpeed; // 米每秒
uniform float _uDetailCloudMoveSpeed;
uniform float _uCloudsTurbulenceSpeed; 
uniform float _uBaseCloudOffset;
uniform float _uDetailCloudOffset;
uniform float _uCloudNoiseScale;

uniform float _uRaymarchOffset; 
uniform float2 _uJitter; 
uniform float _uCloudsDetailStrength; 

// https://www.shadertoy.com/view/4djSRW
float hash13(float3 p3) 
{
    p3 = frac(p3 * 1031.1031f);
    p3 += dot(p3, p3.yzx + 19.19f);
    return frac((p3.x + p3.y) * p3.z);
}


// float HenyeyGreenstein(float sundotrd, float g)
// {
//     float gg = g * g;
//     return (1.0f - gg) / pow(1.0f + gg - 2.0f * g * sundotrd, 1.5f);
// }

// 寒霜引擎分享的一种新的HG函数，可以不使用pow函数，效果十分近似
float HenyeyGreenstein(float sundotrd,float g)
{
    float k = 1.55 * g - 0.55 * g * g * g;
    float t = 1 - k * sundotrd;
    return (1 - k * k)/(t*t);
}

float intersectCloudSphereOuter(float3 ro, float3 rd, float sr)
{
    float a = dot(rd, rd);
    float b = 2.0f * dot(rd, ro);
    float c = dot(ro, ro) - (sr * sr);

    if (b * b - 4.0f * a * c < 0.0) {
        return -1.0f;
    }
    return (-b - sqrt((b * b) - 4.0f * a * c)) / (2.0f * a);
}

float intersectCloudSphereInner(float3 ro, float3 rd, float sr)
{
    float t = dot(-ro, rd);
    float y = length(ro + rd * t);

    float x = sqrt(sr * sr - y * y);
    return t + x;
}


float linearstep(const float s, const float e, float v)
{
    return clamp((v - s)*(1.0f / (e - s)), 0.0f, 1.0f);
}

float linearstep0(const float e, float v)
{
    return min(v*(1.0f / e), 1.0f);
}

float remap(float v, float s, float e)
{
    return (v - s) / (e - s);
}

float3 remap(float3 v, float s, float e)
{
    return (v - s) / (e - s);
}

// http://squircular.blogspot.com/2015/09/fg-squircle-mapping.html
// 曲面转换
// uv需要在 -1 --- 1 之间
float2 sqr2Ccl(float2 sqrUV)
{
    float u = sqrUV.x;
    float v = sqrUV.y;

    float x2 = sqrUV.x * sqrUV.x;
    float y2 = sqrUV.y * sqrUV.y;
    float r2 = x2 + y2;
    float rad = sqrt(r2 - x2 * y2);

    if (r2 < 0.00001f) {
        return float2(u, v);
    }

    float reciprocalSqrt = 1.0f / sqrt(r2);

    u = sqrUV.x * rad * reciprocalSqrt;
    v = sqrUV.y * rad * reciprocalSqrt;

    return float2(u, v);
}


float2 ccl2Sqr(float2 cclUV)
{
    float x = cclUV.x;
    float y = cclUV.y;

    float u2 = cclUV.x * cclUV.x;
    float v2 = cclUV.y * cclUV.y;
    float r2 = u2 + v2;
    float uv = cclUV.x * cclUV.y;
    float fouru2v2 = 4.0f * uv * uv;
    float rad = r2 * (r2 - fouru2v2);
    float sgnuv = sign(uv);
    float sqrto = sqrt(0.5f * (r2 - sqrt(rad)));

    if (abs(cclUV.x) > 0.00001f) {
        y = sgnuv / cclUV.x * sqrto;
    }

    if (abs(cclUV.y) > 0.00001f) {
        x = sgnuv / cclUV.y * sqrto;
    }

    return float2(x, y);
}
//-------------------------------

// an exponential fog density of 0.0003. Works really well with the earth radius
float getFogAmount(float dist)
{
    return 1.0f - (0.1f + exp(-dist * 0.0003f));
}

//采样基础云形状，p = pos，norY雕刻因子
float cloudMapBase(float3 p, float norY)
{
    float3 offset = float3(cos(_uCloudsBearing), 0.0f, sin(_uCloudsBearing)) * (_uBaseCloudOffset);

    float3 uv = (p + offset) * (0.00005f * _uCloudsBaseScale);
	float distance = length(uv.xz);


    float3 cloud = tex2Dlod(_uBaseNoise, float4(uv.xz, 0.0f, 1.0f)).rgb - float3(0.0f, 1.0f, 0.0f);

    float n = norY * norY;
	n += pow(1.0f - norY, 36);
    //R 云的基础形状，G 云的高频细节，越高细节越低
	return remap(cloud.r - n, cloud.g - n, 1.0f);
}

float3 cloudMapDetail(float3 p, float norY, float speed)
{
    float3 offset = float3(cos(_uCloudsBearing), 1.0f, sin(_uCloudsBearing)) * (_uDetailCloudOffset) * speed;


    float2 curl_noise = tex2Dlod(_uCurlNoise, float4(p.xz / _uCurlScale, 0.0, 1.0)).rg;
    offset.xz += curl_noise.rg * (1.0 - norY) * _uCurlScale * _uCurlStrength;


    float3 uv = abs(p + offset) * (0.00005f * _uCloudsBaseScale * _uCloudsDetailScale);

    return tex3Dlod(_uDetailNoise, float4(uv * 0.02f, 0.0f));
}

//高度遮罩，云在低处密度较大，高处密度较小
float cloudGradient(float norY) 
{
    return linearstep(0.0f, 0.05f, norY) - linearstep(0.8f, 1.2f, norY);
}

float cloudMap(float3 pos, float3 rd, float norY,float baseFade)
{
    //最远处深度
	float fade2 = baseFade;
    // = sqrt(
    //     //(_uEarthRadius) * (_uEarthRadius)-_uEarthRadius * _uEarthRadius +
	// 	(_uEarthRadius + _uCloudsBottom) * (_uEarthRadius + _uCloudsBottom) - _uEarthRadius * _uEarthRadius);
	float d2 = length(pos.xz);
	fade2 = smoothstep(0, fade2, d2 * 2);  //距离遮罩

    float m = cloudMapBase(pos, lerp(norY*0.8, norY * 8, fade2 * 0.25));
	m *= cloudGradient(norY);   //乘以高度遮罩

	float dstrength = smoothstep(1.0f, 0.5f, fade2 * 0.6);
    //近处雕刻更多细节
    if (dstrength > 0.0)
    {		
        float3 detail = cloudMapDetail(pos, norY, 1) * dstrength * _uCloudsDetailStrength;
        float detailSampleResult = (detail.r * 0.625f) + (detail.g * 0.2f) + (detail.b * 0.125f);   //fbm
        m -= detailSampleResult;
    }

    float fade = baseFade;
    // sqrt(
    //     //(_uEarthRadius) * (_uEarthRadius) - _uEarthRadius * _uEarthRadius +
    //     (_uEarthRadius + _uCloudsBottom) * (_uEarthRadius + _uCloudsBottom) - _uEarthRadius * _uEarthRadius);
    
    float d = length(pos.xz);
    //距离遮罩
	fade = smoothstep(fade * 6, 0, d);
    //云的浓度受到距离影响，云的基础浓度，以Coverage为阈值，越近则显示越清楚，且浓度越大。
    m = smoothstep(0.0f, lerp(2.5f, _uCloudsBaseEdgeSoftness, fade), m + (lerp(_uCloudsCoverage + _uCloudsCoverageBias - 1.0f, _uCloudsCoverage + _uCloudsCoverageBias , fade) - 1.));

	m *= linearstep0(_uCloudsBottomSoftness, norY);

    return clamp(m * _uCloudsDensity * (1.0f + max((d - 7000.0f)*0.0005f, 0.0f)), 0.0f, 1.0f);
}

float volumetricShadow(in float3 from, in float sundotrd, in float3 sunDir,float baseFade) {

	float sundotup = max(0.0f, dot(float3(0, 1, 0), -_uSunDir));

    float dd = 12;
    float3 rd = -sunDir;
    float d = dd * 2.0f;
	float shadow = 1.0 * lerp(1.5, 1, sundotup);


    UNITY_LOOP
    for (int s = 0; s < CLOUD_SELF_SHADOW_STEPS; s++)
    {
        float3 pos = from + rd * d;
        float norY = (length(pos) - (_uEarthRadius + _uCloudsBottom)) * (1.0f / ((_uCloudsBottom + _uCloudsHeight) - _uCloudsBottom));

        if (norY > 1.0f) return shadow;

        float muE = cloudMap(pos, rd, norY,baseFade);
        shadow *= exp(-muE * dd / 8);

        dd *= 1.0 * lerp(1.8, 1, sundotup);
        d += dd;
    }
    return shadow;
}

float4 renderCloudsInternal(float3 ro, float3 rd, inout float dist)
{
    ro.y = _uEarthRadius + ro.y;

    float start = 0, end = 0;

    start = intersectCloudSphereInner(ro, rd, _uEarthRadius + _uCloudsBottom);
    end = intersectCloudSphereInner(ro, rd, _uEarthRadius + (_uCloudsBottom + _uCloudsHeight));
	float Fade = length(end);

    float sundotrd = dot(rd, _uSunDir);
    float sundotup = max(0.0f, dot(float3(0, 1, 0), -_uSunDir));

    float moondotrd = dot(rd, -_uMoonDir);
    float moondotup = max(0.0f, dot(float3(0, 1, 0), -_uMoonDir));


    int nSteps = lerp(10, CLOUD_MARCH_STEPS, dot(rd, float3(0, 1, 0))); 


	float d = start;
	float dD = min(100.0f, (end - start) / float(nSteps));

    float h = frac(_uRaymarchOffset);
    d -= dD * h;

    float scattering = lerp(HenyeyGreenstein(sundotrd, 0.8),
        HenyeyGreenstein(sundotrd, -0.35f), 0.65f);	

    float moonScattering = lerp(HenyeyGreenstein(moondotrd, 0.3f),
        HenyeyGreenstein(moondotrd, 0.75f), 0.5f);

    float transmittance = 1.0f;
    float3 scatteredLight = 0.0f;

    dist = _uEarthRadius;

    float baseFade = sqrt(
        //(_uEarthRadius) * (_uEarthRadius)-_uEarthRadius * _uEarthRadius +
		(_uEarthRadius + _uCloudsBottom) * (_uEarthRadius + _uCloudsBottom) - _uEarthRadius * _uEarthRadius);

    UNITY_LOOP
    for (int s = 0; s < nSteps; s++)
    {
        float3 p = ro + d * rd;

        float norY = clamp((length(p) - (_uEarthRadius + _uCloudsBottom)) * (1.0f / _uCloudsHeight), 0.0f, 1.0f);

        float alpha = cloudMap(p, rd, norY,baseFade);

        if (alpha > 0.005f)
        {
			float3 detail2 = cloudMapDetail(p * 0.35, norY, 1.0);
			float3 detail3 = cloudMapDetail(p * 1, norY, 1.0);
			
			dist = min(dist, d);

            //颜色 = lerp(底部颜色，顶部颜色);
			float3 ambientLight = lerp(
				lerp(_uCloudsAmbientColorBottom - (detail2.r * lerp(0.25, 0.75, sundotup)) * (lerp(0.2, 0.05, (_uCloudsCoverage)) * _uAttenuation * 0.4f), 0.0f, saturate(_uLightning * 3.0f)),
				lerp(_uCloudsAmbientColorTop - detail2.r * lerp(1, 4, sundotup) * (0.1 * _uAttenuation * 0.9), _uCloudsAmbientColorTop + (_uLightningColor * lerp(0.35f, 0.75f, sundotup)), saturate(_uLightning * 10.0f)),
				norY) * _uCloudsColor;


			float3 light = _uSunColor * _uAttenuation * 1.5 * smoothstep(0.04, 0.055, sundotup);

			light *= smoothstep(-0.03f, 0.075f, sundotup) - lerp(clamp(lerp(detail2.r * 1.6, detail3.r * 1.6, norY ), 0.75, 0.9), clamp(detail3.r * 1.3, 0, 0.8), norY * 4);

			light *= lerp(smoothstep(0.99f, 0.55f, sundotrd), 1.0f, smoothstep(0.1, 0.99f, sundotup));

            float3 moonLight = _uMoonColor * _uMoonAttenuation * 0.6f *smoothstep(0.11, 0.35, moondotup);
            moonLight *= smoothstep(-0.03f, 0.075f, moondotup);

            float3 S = (
                ambientLight + 
                light * (scattering * volumetricShadow(p, sundotrd, _uSunDir,baseFade)) +
                moonLight * (moonScattering * volumetricShadow(p, moondotrd, _uMoonDir,baseFade)))
                * alpha;	

            float dTrans = exp(-alpha * dD);
            float3 Sint = (S - (S * dTrans)) * (1.0f / alpha);

            scatteredLight += transmittance * Sint;
            transmittance *= dTrans;		
        }

        if (transmittance <= 0.035f) break;

        d += dD;
    }

    return float4(scatteredLight, transmittance);
}

void renderClouds(out float4 fragColor, in float3 ro, in float3 rd)
{
    float dist = 300000.0f;
    float4 col = float4(0, 0, 0, 1);


    col = renderCloudsInternal(ro, rd, dist);

    if (col.w > 1.0f) 
    {
        fragColor = float4(0, 0, 0, 1);
    }
    else 
    {
        fragColor = float4(clamp(col.rgb, 0, 0.9), col.a);
    }
}