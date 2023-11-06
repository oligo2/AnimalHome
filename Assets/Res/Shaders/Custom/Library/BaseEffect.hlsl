#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include ".\RotateUVFunction.hlsl"

#if defined (ATMOSPHERE_ON)
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/NepheleSky/Atmosphere.hlsl"
#endif


struct vert {
	float4 vertex : POSITION;
	half4  color : COLOR;
    #ifdef _EnableDissolve
    float3 texcoord : TEXCOORD0;//z 溶解pow
    #else
    float2 texcoord : TEXCOORD0;
    #endif
    float4 texcoord1 : TEXCOORD1;//xy 用来控制遮罩图的offset, zw控制基础图的tilling
    float4 texcoord2 : TEXCOORD2;//xy 用来控制颜色图的offset,
    float3 normal : NORMAL;
    float4 tangent : TANGENT;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct v2f {
    float3 positionWS : TEXCOORD1;
    float4 positionCS : SV_POSITION;
	half4  color : COLOR;
	float3 uv : TEXCOORD0;
	float4 uvDistortAndDissolve : TEXCOORD2; //DistortAndDissolve
	float4 uvMask : TEXCOORD3;  //mask mask1
    
#if defined(_EnableHeat)
    float4 uvHeat : TEXCOORD5;  //xy : uvHeat, zw : uvHeatMask   _EnableHeat
#endif

    float4 projected : TEXCOORD7;  //_EnableDepthFade
    float3 viewDirTS : TEXCOORD8;  //_EnableParallax
    
#if defined(_EnableRimColor)
    float3 normal : NORMAL;
    float3 normalWS                 : TEXCOORD9;   
    float3 viewDirWS                : TEXCOORD10;
#endif

#if defined(ATMOSPHERE_ON) && !defined(ATMOSPHERE_POSTPROCESS_ON)
	float4 inscattering             : TEXCOORD14;
#endif

	float4 uv1: TEXCOORD15;

    
#if defined(DECAL)
    float4 viewDirOS : TEXCOORD16;
    float4 cameraPosOS : TEXCOORD17;
#endif

#if defined(DECAL) || defined(_EnableHeat)
    float4 screenPos : TEXCOORD18;
#endif
};

v2f Vert(vert v)
{	
    v2f o = (v2f)0;

    if (_EnableVertexAnim)
    {
        float2 uvVertexAnim = RotateByTimeAndMoveUV(v.texcoord.xy, _VertexAnimScrollAndRotate.xy, _VertexAnimScrollAndRotate.z, _VertexAnimMap_ST);
        float noise = SAMPLE_TEXTURE2D_LOD(_VertexAnimMap, sampler_VertexAnimMap, uvVertexAnim, 0).r;
        v.vertex.xyz = v.vertex.xyz + _VertexOffset.xyz * _VertexOffsetPow * noise * v.normal;
    }

    float3 positionWS = TransformObjectToWorld(v.vertex.xyz);
    
    if(_OffsetCustomEnable)
    {
        _BaseMap_ST.zw += v.texcoord2.xy;
    }

    #if defined(DECAL)
        o.uv.xy = v.texcoord.xy;
    #else
        o.uv.xy = RotateAndMoveUV(v.texcoord.xy, _BaseScrollAndRotate.xy, _BaseScrollAndRotate.z, _BaseMap_ST);
    #endif

    #if defined(_EnableDissolve)
        if(_DissolveSpeedCustomEnable)
        {
            o.uv.z = v.texcoord.z;
        }
    #endif

    if (_EraseCustomEnable)
    {
        o.uv1.xyzw = v.texcoord1.xyzw;
    }


    if (_EnableDistort)
    {
        o.uvDistortAndDissolve.xy = RotateAndMoveUV(v.texcoord.xy, _DistortScrollAndRotate.xy, _DistortScrollAndRotate.z, _DistortMap_ST);
    }

    #if defined(_EnableDissolve)
        o.uvDistortAndDissolve.zw = RotateAndMoveUV(v.texcoord.xy, _DissolveScrollAndRotate.xy, _DissolveScrollAndRotate.z, _DissolveTex_ST);
    #endif

    if (_EnableMask)
    {
        float4 maskMapOffset = _MaskMap_ST;
        if(_MaskOffsetCustomEnable)
        {
            maskMapOffset.zw = _MaskMap_ST.zw  + v.texcoord1.zw;
        }

        o.uvMask.xy = RotateAndMoveUV(v.texcoord.xy, _MaskScrollAndRotate.xy, _MaskScrollAndRotate.z, maskMapOffset);
    }

    if (_EnableMask1)
    {
        o.uvMask.zw = RotateAndMoveUV(v.texcoord.xy, _MaskScrollAndRotate1.xy, _MaskScrollAndRotate1.z, _MaskMap1_ST);
    }

#if defined(_EnableRimColor)
    VertexNormalInputs normalInput = GetVertexNormalInputs(v.normal, v.tangent);
    half3 viewDirWS = normalize(GetCameraPositionWS() - positionWS);

    o.normalWS = normalInput.normalWS;
    o.viewDirWS = viewDirWS;
#endif

     o.color = v.color;
     o.positionCS = TransformWorldToHClip(positionWS);
     o.positionWS = positionWS;   

     if (_EnableDepthFade)
     {
         o.projected.xy = (float2(o.positionCS.x, o.positionCS.y * _ProjectionParams.x) + o.positionCS.w) * 0.5f;
         o.projected.zw = o.positionCS.zw;
     }
     
#if defined(_EnableHeat)
    o.uvHeat.xy = RotateAndMoveUV(v.texcoord.xy, _HeatScrollAndRotate.xy, _HeatScrollAndRotate.z, _HeatMap_ST);
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

#if defined(_EnableHeat) || defined(DECAL)
    o.screenPos = ComputeScreenPos(o.positionCS);
#endif

    return o;
}


half4 Frag(v2f i, FRONT_FACE_TYPE facing : FRONT_FACE_SEMANTIC) : SV_Target
{
    #if defined(DECAL)
        // 去齐次
        i.viewDirOS.xyz /= i.viewDirOS.w;
        // 深度纹理的UV
        float2 screenSpaceUV = i.screenPos.xy / i.screenPos.w;
        // 对深度纹理进行采样，得到深度信息
        float sceneRawDepth = tex2D(_CameraDepth2Texture, screenSpaceUV).r;
        float3 decalSpaceScenePos;
        float sceneDepthVS = LinearEyeDepth(sceneRawDepth, _ZBufferParams);
        decalSpaceScenePos = i.cameraPosOS.xyz + i.viewDirOS.xyz * sceneDepthVS;
        // unity 的 cube 的顶点坐标范围是 [-0.5, 0.5,]，我们把它转到 [0,1] 的范围，用于映射UV
        // 只有你使用 cube 作为 mesh filter 时才能这么干
        float2 uvDecalSpace = decalSpaceScenePos.xy + 0.5;
        // // 剔除在 cube 以外的像素信息
        float decalSpaceAngle = normalize(cross(ddx(decalSpaceScenePos), ddy(decalSpaceScenePos))).z;
        half shouldClip = 0.05 > decalSpaceAngle ? 1 : 0;  //单地面倾斜角度超过90时开始裁切
        // half shouldAlpha = saturate((0.6666 -decalSpaceAngle)/0.02);  //单地面倾斜角度超过30时开始半透
        // alpha = 1- shouldAlpha*(1-_AlphaInAngle);
        
        clip(0.5 - abs(decalSpaceScenePos) - shouldClip);
        
        i.uv.xy = TRANSFORM_TEX(uvDecalSpace, _BaseMap);
        i.uvMask.xy = TRANSFORM_TEX(uvDecalSpace, _MaskMap);
        #ifdef _EnableDissolve
            i.uvDistortAndDissolve.zw = TRANSFORM_TEX(uvDecalSpace, _DissolveTex);
        #endif
    #endif


    half4 baseColor = 0;
    half4 distortColor;
    //计算Distort
    if (_EnableDistort)
    {
        distortColor = tex2D(_DistortMap, i.uvDistortAndDissolve.xy * _DistortScale) * 2 - 1;
        if (_EnableAlphaR)
        {
            baseColor = tex2D(_BaseMap, i.uv.xy + distortColor.xy / 10).r;        
        }
        else
        {
            baseColor = tex2D(_BaseMap, i.uv.xy + distortColor.xy / 10);
        }
        baseColor = baseColor * _BaseColor;
    }
    else  //计算正常颜色
    {
        if (_EnableAlphaR)
        {
            baseColor = tex2D(_BaseMap, i.uv.xy).r * _BaseColor;    
        }
        else
        {
            baseColor = tex2D(_BaseMap, i.uv.xy) * _BaseColor;
        }
    }
    
    //UI层动效 色彩空间校正
    if (_EnableUIGamma)
    {
    baseColor.rgb = pow(baseColor.rgb, 0.45);
    }
    else

    baseColor.a = min(1,baseColor.a *_AlphaIntensity);

    //计算饱和度
    if (_EnableSaturation)
    {
        half avg = (baseColor.r + baseColor.g + baseColor.b) / 3;
        baseColor.rgb = lerp(half3(avg, avg, avg), baseColor.rgb, _Saturation);
    }

    #if defined(_EnableHeat)
        half4 col = baseColor * i.color.a;
    #else
        half4 col = baseColor * i.color;
    #endif


    //遮罩
    if (_EnableMask)
    {
        half maskValue = abs(tex2D(_MaskMap, i.uvMask.xy).r);
        maskValue = max(0, pow(maskValue, _MaskPow) - _MaskThreshold);
        if (_EnableMask1)
        {
            half maskValue1 = abs(tex2D(_MaskMap1, i.uvMask.zw).r);
            maskValue1 = max(0, pow(maskValue1, _MaskPow1) - _MaskThreshold1);
            col.a = saturate(col.a * maskValue) * saturate(col.a * maskValue1);
        }
        else
        {
            col.a = saturate(col.a * maskValue);
        }
    }

    //溶解
    #ifdef _EnableDissolve    
        float dissolveFactor = 0;
        if(_DissolveSpeedCustomEnable)
        {
            dissolveFactor = i.uv.z;
        }
        else
        {
            dissolveFactor = _DissolveSpeed;
        }
    
        half2 uvDissolve;
        if (_EnableDistort)//扰动对溶解边缘有效果
        {
            uvDissolve = i.uvDistortAndDissolve.zw + distortColor.x / 100;
        }
        else
        {
            uvDissolve = i.uvDistortAndDissolve.zw;
        }
    
        float dissolveValue = SAMPLE_TEXTURE2D(_DissolveTex, sampler_DissolveTex, uvDissolve ).r;
        float delta = saturate(dissolveFactor - dissolveValue);
        float EdgeColor = saturate(delta/(1.01-_DissolveSize));
        float EdgeSoft = saturate(delta/(_DissolveSoft));

        col.rgb = lerp(col.rgb, baseColor.rgb * _DissolveColor.rgb, EdgeColor);
        col.a = lerp(col.a, 0, EdgeSoft);
    #endif

    //穿插过渡
    if (_EnableDepthFade)
    {
        float thisDepth = LinearEyeDepth(i.positionWS.xyz, GetWorldToViewMatrix()).r;
        float sceneDepth = LinearEyeDepth(tex2D(_CameraDepth2Texture, UnityStereoTransformScreenSpaceTex(i.projected.xy / i.projected.w)).r, _ZBufferParams);
        float deltaDepth = abs(thisDepth - sceneDepth) / _DepthFadeIndensity;
        col.a = col.a * min(deltaDepth, 1);
    }
 
    //热扭曲
    #if defined(_EnableHeat)
        half4 grabColor1 = tex2Dproj(_CameraOpaqueTexture, i.screenPos / i.screenPos.w);

        half2 heatColor = tex2D(_HeatMap, i.uvHeat.xy).rg;
        float2 offset = heatColor * _HeatPow;
        i.screenPos.xy = offset * i.screenPos.z + i.screenPos.xy;
        half4 grabColor2 = tex2Dproj(_CameraOpaqueTexture, i.screenPos / i.screenPos.w);

        col.rgb = lerp(grabColor1.rgb, grabColor2.rgb, col.r);
        col.a = 1;
    #endif

    //边缘光
    #if defined(_EnableRimColor) 
        float NdotV = abs(dot(i.normalWS, normalize(i.viewDirWS)));
        float rim = _RimColor.rgb * saturate(_RimWidth - NdotV);

        col.rgb = col.rgb + _RimColor.rgb * rim ;
        col.a = saturate(1 - rim * _RimFade) * col.a;

        // float NdotV = abs(dot(i.normalWS, normalize(i.viewDirWS)));
        // float rim = saturate(1 - NdotV);
        // float rim2 = pow(rim, 2-_RimWidth);

        // col.rgb = col.rgb + _RimColor.rgb * rim2 ;
        // col.a = saturate(1 - rim2 * _RimFade) * col.a;
    #endif

	//fog
    #if defined(ATMOSPHERE_ON) && !defined(ATMOSPHERE_POSTPROCESS_ON)
		col.rgb = GetAtmosphereOutputColor(col.rgb, i.inscattering);
	#endif

    #ifdef _EnableFrontBackColor
    col *= facing > 0 ? _ColorFront : _ColorBack;
    #endif
    
    //计算擦除
    if(_EraseCustomEnable)
    {
        half y = 1.5-abs(i.uv.y-0.5);
        col.a *=  saturate((i.uv.x+1 - i.uv1.x) * (y - i.uv1.y));
    }

    return col;
}