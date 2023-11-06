//#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

//已有的定义
//Vertex大类 Lit(有光), UnLit(无光有贴图), NoTex(无贴图),  ShadowCaster(影子Pass), DepthOnly（深度Pass), PostProcess(后处理)
//小类 WIND(风),  WORLDPOS(是否传入世界坐标)
// PseudoSubsurfaceFunction.hlsl 移出风控制宏，SSS 计算和风力无关 ———— By Adia 2022.06.29


#if defined(LIT)
	#ifndef WORLDPOS
    #define WORLDPOS
    #endif
#endif

#include "AtmosphereFunction.hlsl"


#if defined (PARALLAX)
#include "ParallaxMappingFunction.hlsl"
#endif

#if defined (_EnableWind)
#include "RotateAroundAxisFunction.hlsl"
#include "WindFunction.hlsl"
#endif

#if defined (LITINDIREDCT)
#include "InstanceFunction.hlsl"
#endif


#if defined(_TERRAIN_VT_ENABLED)
#include "Packages/com.unity.render-pipelines.universal/Shaders/TerrainVT/TerrainVTUtils.hlsl"
#include "VTFunction.hlsl"
#endif


//#if defined (TESSELLATION)
//#include ".\TessellationFunction.hlsl"
//#endif
SamplerState sampler_LinearClamp;
SamplerState sampler_LinearRepeat;



void rotate2D(inout float2 v, float r)
{
    float s, c;
    sincos(r, s, c);
    v = float2(v.x * c - v.y * s, v.x * s + v.y * c);
}

inline float SimplePow5(float v)
{
    return v*v*v*v*v;
}
inline float SimplePow2(float v)
{
    return v*v;
}            

#if defined (LIT)
    struct vert
    {
        float3 vertex : POSITION;
        float2 texcoord : TEXCOORD0;        
        float3 normal : NORMAL;
        float4 tangent : TANGENT;
        float2 lightmapUV : TEXCOORD1;
    #if defined(UV3) || defined(SOLIDUV)
        float2 uv3 : TEXCOORD2;
    #endif
    #if defined(UV4)
        float2 uv4 : TEXCOORD3;
    #endif

    #if defined (VERTEXCOLOR)
        float4 color :COLOR;        
    #endif

    #if defined(INSTANCING_ON)
        UNITY_VERTEX_INPUT_INSTANCE_ID
    #endif
    };
                
    struct v2f
    {
        float4 uvAndOther : TEXCOORD0;     //xy:uv, z:hight	, w:color
        float4 positionCS : SV_POSITION;
    #if defined (WORLDPOS) || defined(_TERRAIN_VT_ENABLED)
        float4 positionWS : TEXCOORD1;
    #endif

    #if defined (NORMALMAP)
        float4 normalWS                 : TEXCOORD2;    // xyz: normal, w: viewDir.x
        float4 tangentWS                : TEXCOORD3;    // xyz: tangent, w: viewDir.y
        float4 bitangentWS              : TEXCOORD4;    // xyz: bitangent, w: viewDir.z
    #else
        float3 normalWS                 : TEXCOORD2;
        float3 viewDirWS                : TEXCOORD3;
    #endif
        
        DECLARE_ATMOSPHERE(5)

        DECLARE_LIGHTMAP_OR_SH(lightmapUV, vertexSH, 7);
        #ifdef DYNAMICLIGHTMAP_ON
            float2  dynamicLightmapUV : TEXCOORD8; // Dynamic lightmap UVs
        #endif

    #if defined(PARALLAX_ON)
        float3 camPosTexcoord : TEXCOORD12;
    #endif

    #if defined(UV3) || defined(UV4) || defined(SOLIDUV)
        float4 uv34 : TEXCOORD14;
    #endif

    #if defined (VERTEXCOLOR)
        float4 vertexColor : TEXCOORD15;
    #endif

    #if defined (DEPTH) || defined(SCREEN)
        float4 projected : TEXCOORD16;   //也叫ScreenPos
    #endif  

    #if defined (DEPTHRIM) 
        float4 projected2 : TEXCOORD17; 
    #endif


    #if defined (_TERRAIN_VT_ENABLED)
        float4 positionOS : TEXCOORD19;   //初始世界位置
    #endif  

    #if defined(INSTANCING_ON)
        UNITY_VERTEX_INPUT_INSTANCE_ID
        UNITY_VERTEX_OUTPUT_STEREO
    #endif
    
    #if defined(LITINDIREDCT)
        uint instanceID1 : SV_InstanceID;
    #endif
    };
    
#include ".\BRDFFunction.hlsl"
#include ".\LightFunction.hlsl"


    #if defined (WAVE)
    half3 BlendNormals(half3 n1, half3 n2)
    {
        return normalize(half3(n1.xy + n2.xy, n1.z*n2.z));
    }
    #endif
    #if defined(LITINDIREDCT)
    VertexNormalInputs GetVertexNormalInputs_Indirect(float3 normalOS, float4 tangentOS,uint instanceID)
    {
        VertexNormalInputs tbn;

        // mikkts space compliant. only normalize when extracting normal at frag.
        real sign = real(tangentOS.w) * GetOddNegativeScale();
        tbn.normalWS = TransformObjectToWorldNormal(instanceID,normalOS,true);
        tbn.tangentWS = real3(TransformObjectToWorldDir(instanceID,tangentOS.xyz,true));
        tbn.bitangentWS = real3(cross(tbn.normalWS, float3(tbn.tangentWS))) * sign;
        return tbn;
    }
    #endif


    
#if defined(INDIREDCT)        
    v2f Vert(vert v, uint instanceID : SV_InstanceID)
#else
    v2f Vert(vert v)
#endif
    {	
        v2f o = (v2f)0;


    //instance    
    #if defined(INSTANCING_ON)
        UNITY_SETUP_INSTANCE_ID(v);
        UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
        UNITY_TRANSFER_INSTANCE_ID(v, o);
    #endif
        
    //worldPos
    float3 positionWS = TransformObjectToWorld(v.vertex);



    //base or main Tex
    #if defined(BASEMAP)    
        o.uvAndOther.xy = TRANSFORM_TEX(v.texcoord, _BaseMap);
        #if defined(UV3) || defined(SOLIDUV)
            o.uv34.xy = v.uv3;
        #endif
        #if defined(UV4)
            o.uv34.zw = v.uv4;
        #endif
    #elif defined(NOMAP)
        o.uvAndOther.xy = v.texcoord;
    #else
        o.uvAndOther.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
        #if defined(UV3) || defined(SOLIDUV)
            o.uv34.xy = TRANSFORM_TEX(v.uv3, _MainTex);
        #endif
        #if defined(UV4)
            o.uv34.zw = TRANSFORM_TEX(v.uv4, _MainTex);
        #endif
    #endif

    #if defined(SOLIDUV)   
        if(_EnableAutoSolidUV)      
        {
            o.uv34.xy = float2(v.vertex.x + _VertexRange.x + v.vertex.z + _VertexRange.z, v.vertex.y + _VertexRange.y) ;
        }  
    #endif 

    //vertexAnimation
    #if defined(FLAG)
        float dis = min( 1, min(   distance(v.vertex, _FlagAnimationPos.xyz)/20,  distance(v.vertex, _FlagAnimationPos2.xyz)/20) );
            v.vertex = v.vertex + sin(_Time.y * _FlagAnimationSpeed) *  dis * _FlagAnimationStrength;

        v.color = dis;    
        positionWS = TransformObjectToWorld(v.vertex.xyz);
    #endif


    #if defined (_EnableWind)



        #if defined(INDIREDCT)
            float4 data = positionBuffer[instanceID];
            // float rotation = data.w * data.w * _Time.x * 0.5f;
            rotate2D(v.vertex.xz, data.w);
            v.vertex.xyz = data.xyz + v.vertex.xyz;
            positionWS = TransformObjectToWorld(v.vertex.xyz);
        #endif
  
        float3 windDirection = TransformWorldToObjectDir(_WindDirection.xyz);
        v.vertex = CaculateWindAnimation(windDirection, _WindDirection.xyz, positionWS, v.vertex, o.uvAndOther.xy, o.uvAndOther.w);
        positionWS = TransformObjectToWorld(v.vertex.xyz);
    #endif

    #if defined (HIGH) 
        #if defined (HIGH_MG)        
            half offset = SAMPLE_TEXTURE2D_LOD(_MixMap, sampler_MixMap, v.texcoord, 0).g;
        #else
            half offset = SAMPLE_TEXTURE2D_LOD(_HighMap, sampler_HighMap, v.texcoord, 0).r;
        #endif
        v.vertex.y += offset*_High;
        positionWS = TransformObjectToWorld(v.vertex.xyz);
    #endif

    #if defined (WATERFALL) 
	    half speed = _Time.y*_Speed0;
        half offset = tex2Dlod(_VertexChangeMap, half4(o.uvAndOther.x * _Tilling0, o.uvAndOther.y * _Tilling0 + speed, 0, 0)).r;
        offset = ((offset-0.5)* _VertexChangeStrength) + 1;
        v.vertex.xyz *= offset;
        positionWS = TransformObjectToWorld(v.vertex.xyz);
    #endif

        o.uvAndOther.z = v.vertex.y;

        VertexNormalInputs normalInput = GetVertexNormalInputs(v.normal, v.tangent);
        half3 viewDirWS = normalize(GetCameraPositionWS() - positionWS);

    #if defined (NORMALMAP)
        o.normalWS = float4(normalInput.normalWS, viewDirWS.x);
        o.tangentWS = float4(normalInput.tangentWS, viewDirWS.y);
        o.bitangentWS = float4(normalInput.bitangentWS, viewDirWS.z);
    #else
        o.normalWS = normalInput.normalWS;
        o.viewDirWS = viewDirWS;
        OUTPUT_SH(o.normalWS.xyz, o.vertexSH);
    #endif

        OUTPUT_LIGHTMAP_UV(v.lightmapUV, unity_LightmapST, o.lightmapUV);



    #if defined (WORLDPOS)
        o.positionWS.xyz = positionWS;
    #endif


    #if defined (VERTEXCOLOR)
        o.vertexColor = v.color;
    #endif

    o.positionCS = TransformWorldToHClip(positionWS);
    
    #if defined(ATMOSPHERE_ON) && !defined(ATMOSPHERE_POSTPROCESS_ON)   
        o.inscattering = InScattering(_WorldSpaceCameraPos, o.positionWS);
    #endif


    #if defined(PARALLAX_ON)
        // texture space (TBN) basis-vector
        float3 binormal = cross(v.tangent, v.normal);
        float3x3 tbn = float3x3(v.tangent.xyz, binormal, v.normal.xyz);

        // get cam pos in texture (TBN) space
        float3 camPosLocal = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos, 1.0)).xyz;
        float3 dirToCamLocal = camPosLocal - v.vertex;
        float3 camPosTexcoord = mul(tbn, dirToCamLocal);
        o.camPosTexcoord = camPosTexcoord;
    #endif
    
    #if defined(DEPTH) || defined(SCREEN) || defined (INSERTCUTTING)
        o.projected = ComputeScreenPos(o.positionCS);

        #if defined(DEPTHRIM)
            o.projected2 = ComputeScreenPos(TransformObjectToHClip(v.vertex + v.normal.rgb * _DepthRimWidth));
        #endif

    #endif
    
        return o;
    }
#endif




#if defined (TESSELLATION)
    #pragma hull hs
    #pragma domain ds
    //v2t
    struct v2t
    {
        float3 pos : INTERNALTESSPOS;
        float3 normal : NORMAL;
        float4 tangent : TANGENT;
        float2 texcoord : TEXCOORD0;  
        float change : TEXCOORD1;  
    };  
    v2t Vert_ts(vert v)
    {
        v2t o;
        o.pos = v.vertex;
        o.normal = v.normal;
        o.texcoord = v.texcoord;
        o.tangent = v.tangent;
        
       // half4 mixColor1 =  SAMPLE_TEXTURE2D_LOD(_MixMap1, sampler_MixMap1, v.texcoord, 0);
        o.change = 1;//step(0.9, mixColor1.b);
        return o;
    }

    //patch
    struct patch
    {
        float edge[3] : SV_TessFactor;
        float inside : SV_InsideTessFactor;
    };
    patch constfunc(InputPatch<v2t, 3> v)
    {
        patch o;
        o.edge[0] = 1 + _TessCount;// * v[0].change; 
        o.edge[1] = 1 + _TessCount; //* v[0].change;  
        o.edge[2] = 1 + _TessCount; //* v[0].change;  
        o.inside = 1 + _TessCount;// * v[0].change; 
        return o;
    }
    
    //Calculate func
    float  ComputeWeight(InputPatch<v2t, 3> v, int i, int j)
    {
        return dot(v[j].pos - v[i].pos, v[i].normal);
    }
    float3 ComputeEdgePosition(InputPatch<v2t, 3> v, int i, int j)
    {
        return (2*v[i].pos + v[j].pos - ComputeWeight(v, i, j) * v[i].normal)/3;
    }
    float3 ComputeEdgeNormal(InputPatch<v2t, 3> v, int i, int j)
    {
        float t = dot(v[j].pos - v[i].pos, v[i].normal + v[j].normal);

        float b = dot(v[j].pos - v[i].pos, v[j].normal - v[i].normal);

        float a = 2 * (t/b);

        return normalize(v[i].normal + v[j].normal - a * (v[j].pos - v[i].pos)) ;
    }

    //TessFunc
    [domain("tri")]
    [partitioning("fractional_odd")]  // integer/ fractional_even / fractional_odd
    [outputtopology("triangle_cw")]   // triangle_cw / triangle_ccw / line
    [patchconstantfunc("constfunc")]
    [outputcontrolpoints(13)]
    v2t hs(InputPatch<v2t, 3> v, uint i : SV_OutputControlPointID)
    {
        v2t o;
        o.pos = float3(0,0,0);
        o.normal = float3(0,0,0);

        switch(i)
        {
            case 0:
            case 1:
            case 2:
                o.pos = v[i].pos;
                o.normal = v[i].normal;
                break;
            case 3:
                o.pos = ComputeEdgePosition(v, 0, 1);
                break;
            case 4:
                o.pos = ComputeEdgePosition(v, 1, 0);
                break;
            case 5:
                o.pos = ComputeEdgePosition(v, 1, 2);
                break;
            case 6:
                o.pos = ComputeEdgePosition(v, 2, 1);
                break;
            case 7:
                o.pos = ComputeEdgePosition(v, 2, 0);
                break;
            case 8:
                o.pos = ComputeEdgePosition(v, 0, 2);
                break;
            case 9: // 
                float3 E = (ComputeEdgePosition(v, 0, 1) + ComputeEdgePosition(v, 1, 0)
                    + ComputeEdgePosition(v, 1, 2) + ComputeEdgePosition(v, 2, 1)
                    + ComputeEdgePosition(v, 2, 0) + ComputeEdgePosition(v, 0, 2)
                    ) / 6;
                float3 V = (v[0].pos + v[1].pos + v[2].pos) / 3;
                o.pos = E + (E-V)/2;
                break;
            case 10: //between 0 - 1
                o.normal = ComputeEdgeNormal(v, 0, 1);
                break;
            case 11: //between 1 - 2
                o.normal = ComputeEdgeNormal(v, 1, 2);
                break;
            case 12: //between 2 - 0
                o.normal = ComputeEdgeNormal(v, 2, 0);
                break;
        }
        o.texcoord = v[i].texcoord;
        o.tangent = v[i].tangent;
        o.change = 0;

        return o;
    }

    [domain("tri")]
    v2f ds(patch factors, const OutputPatch<v2t, 13> patch, float3 bary : SV_DomainLocation)
    {
        vert o;

        float u = bary.x;
        float v = bary.y;
        float w = bary.z;

        float3 p300 = patch[0].pos;
        float3 p030 = patch[1].pos;
        float3 p003 = patch[2].pos;
        
        float3 p210 = patch[3].pos;
        float3 p120 = patch[4].pos;
        
        float3 p021 = patch[5].pos;
        float3 p012 = patch[6].pos;
        
        float3 p102 = patch[7].pos;
        float3 p201 = patch[8].pos;
        
        float3 p111 = patch[9].pos;

        float3 pos = (p300 * pow(w,3)) + (p030 * pow(u, 3)) + (p003 * pow(v, 3))
            +  (p210 * 3 * pow(w, 2)* u)
            +  (p120 * 3 * pow(u, 2)* w)
            +  (p201 * 3 * pow(w, 2)* v)
            +  (p021 * 3 * pow(u, 2)* v)
            +  (p102 * 3 * pow(v, 2)* w)
            +  (p012 * 3 * pow(v, 2)* u)
            +  (p111 * 6 * w * v * u);

        float3 normal = w * patch[0].normal + u * patch[1].normal + v * patch[2].normal;

        o.vertex.rgb = pos;
        o.normal = normal;
        o.texcoord = patch[0].texcoord * w + patch[1].texcoord * u + patch[2].texcoord * v;
        o.tangent = patch[0].tangent * bary.x + patch[1].tangent * bary.y + patch[2].tangent * bary.z;

        return Vert(o);
    }
#endif