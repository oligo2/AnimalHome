#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

//#include ".\LightFunction.hlsl"
#include ".\RotateUVFunction.hlsl"

#if defined (ATMOSPHERE_ON)
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/NepheleSky/Atmosphere.hlsl"
#endif


struct vert {
	float4 vertex : POSITION;
	half4  color : COLOR;
    float3 texcoord : TEXCOORD0;
};

struct v2f {
	float3 uv : TEXCOORD0;

#if defined(ARROW)
    float4 uv_MaskAndFlow : TEXCOORD1;
#endif

    float4 positionCS : SV_POSITION;
    float3 positionWS : TEXCOORD2;
	half4  color : COLOR;
    float4 screenPos : TEXCOORD3;

#if defined(ATMOSPHERE_ON) && !defined(ATMOSPHERE_POSTPROCESS_ON)
	float4 inscattering : TEXCOORD4;
#endif
    
#if defined(DECAL)
    float4 viewDirOS : TEXCOORD5;
    float4 cameraPosOS : TEXCOORD6;
#endif
};

v2f Vert(vert v)
{	
    v2f o = (v2f)0;

    float3 positionWS = TransformObjectToWorld(v.vertex.xyz);
    
    o.uv.xy = TRANSFORM_TEX(v.texcoord.xy, _MainTex);
    
    o.color = v.color;
    o.positionCS = TransformWorldToHClip(positionWS);
    o.positionWS = positionWS;   
    o.screenPos = ComputeScreenPos(o.positionCS);
    
#if defined(ARROW)
    o.uv_MaskAndFlow.xy = v.texcoord.xy;
    o.uv_MaskAndFlow.zw = float2(v.texcoord.x, v.texcoord.y + (1 - _Duration));
#endif

#if defined(ATMOSPHERE_ON) && !defined(ATMOSPHERE_POSTPROCESS_ON)
	o.inscattering = InScattering(_WorldSpaceCameraPos, positionWS);
#endif

#if defined(DECAL)
    float3 viewDirVS = TransformWorldToView(positionWS);
    // viewRay除以z分量必须在片元着色器中执行，不能在顶点着色器中执行! (由于光栅化变化插值的透视校正)
    // 我们先把viewRay.z存到o.viewDirOS.w中，等到片元着色器阶段在进行处理
    o.viewDirOS.w = viewDirVS.z;
    viewDirVS *= -1;// unity的相机空间是右手坐标系(z轴负方向指向屏幕)，我们希望片段着色器中z射线是正的，所以取反
    float4x4 ViewToObjectMatrix = mul(UNITY_MATRIX_I_M, UNITY_MATRIX_I_V);//观察空间到模型空间的变换矩阵
    o.viewDirOS.xyz = mul((float3x3)ViewToObjectMatrix, viewDirVS);// 观察空间 (view space) 转模型空间 (object space) 
    o.cameraPosOS.xyz = mul(ViewToObjectMatrix, float4(0,0,0,1)).xyz;// 模型空间下摄像机的坐标
#endif
    return o;
}


float4 Frag(v2f i) : SV_Target 
{    
    //base
    half2 uv = i.uv;
	half4 baseColor = 0;
    half alpha = 1;

    #if defined(DECAL)
        // 去齐次
        i.viewDirOS.xyz /= i.viewDirOS.w;
        // 深度纹理的UV
        float2 screenSpaceUV = i.screenPos.xy / i.screenPos.w;
        // 对深度纹理进行采样，得到深度信息
        float sceneRawDepth = SAMPLE_DEPTH_TEXTURE(_CameraDepth2Texture, sampler_CameraDepth2Texture, screenSpaceUV).r;
        float3 decalSpaceScenePos;
        float sceneDepthVS = LinearEyeDepth(sceneRawDepth, _ZBufferParams);
        decalSpaceScenePos = i.cameraPosOS.xyz + i.viewDirOS.xyz * sceneDepthVS;
        // unity 的 cube 的顶点坐标范围是 [-0.5, 0.5,]，我们把它转到 [0,1] 的范围，用于映射UV
        // 只有你使用 cube 作为 mesh filter 时才能这么干
        float2 decalSpaceUV = decalSpaceScenePos.xy + 0.5;
        // 剔除在 cube 以外的像素信息
        float decalSpaceAngle = normalize(cross(ddx(decalSpaceScenePos), ddy(decalSpaceScenePos))).z;
        half clipAngle = (1-_ProjectionAngleCut/90);
        half alphaAngle = (1-_ProjectionAngleAlpha/90);
        half shouldClip = clipAngle > decalSpaceAngle ? 1 : 0;
        half shouldAlpha = saturate((alphaAngle -decalSpaceAngle)/0.02);
        alpha = 1- shouldAlpha*(1-_AlphaInAngle);

        clip(0.5 - abs(decalSpaceScenePos) - shouldClip);
        uv = TRANSFORM_TEX(decalSpaceUV, _MainTex);        
        #if defined(ARROW)
            i.uv_MaskAndFlow.xy = decalSpaceUV.xy;
            i.uv_MaskAndFlow.zw = float2(decalSpaceUV.x, decalSpaceUV.y + (1 - _Duration));
        #endif
    #else
        //遮挡半透效果
        float2 screenUV = i.screenPos.xy/i.screenPos.w;
        real depth = SAMPLE_DEPTH_TEXTURE(_CameraDepth2Texture, sampler_CameraDepth2Texture, screenUV);
        #if UNITY_UV_STARTS_AT_TOP
            alpha = step(depth - i.positionCS.z, 0.000003);
        #else
            alpha = step(i.positionCS.z - depth, 0.000003);
        #endif
        alpha = max(alpha,_AlphaInCover);
    #endif

    baseColor = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv) * _Intensity;
    half4 color = 0;
    half4 flow = 0;

    #if defined(CIRCLE)
        //outline
        float2 centerUV = (uv * 2 - 1);
        float atan2UV = 1-abs(atan2(centerUV.y, centerUV.x)/3.14);
        half sector = 1.0 - ceil(atan2UV - _Angle*0.002777778);
        half sectorBig = 1.0 - ceil(atan2UV - (_Angle+ _Outline) * 0.002777778);
        half outline = (sectorBig -sector) * baseColor.g * _OutlineAlpha;
        half needOutline = 1 - step(359, _Angle);
        outline *= needOutline;

        //flow
        half flowCircleInner = smoothstep(_Duration - _FlowFade, _Duration, length(centerUV));
        half flowCircleMask = step(length(centerUV), _Duration);
        flow = flowCircleInner * flowCircleMask * _FlowColor * baseColor.g * sector;

        color = baseColor.r * _Color * sector + outline * _Color;
    #elif defined(ARROW)

        //尾部透明遮罩
        half mask = smoothstep(0, 0.3, i.uv_MaskAndFlow.y);

        //主纹理
        half4 mainCol = baseColor.r * mask* _Color;

        //扫光
        half4 flowTex = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv_MaskAndFlow.zw);
        flow = flowTex.b * baseColor.g * mask* _FlowColor;

        color = mainCol + flow;
    #else
        color.rgb = baseColor.rgb * _Color;
        color.a = baseColor.a;
    #endif

    color += flow;
    color *= alpha;
    return color;
}