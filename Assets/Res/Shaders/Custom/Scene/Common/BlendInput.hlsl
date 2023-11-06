TEXTURE2D(_BaseMap);          SAMPLER(sampler_BaseMap);
TEXTURE2D(_BumpMap);          SAMPLER(sampler_BumpMap);
TEXTURE2D(_MixMap); 		  SAMPLER(sampler_MixMap);

TEXTURE2D(_Color2Map);        
TEXTURE2D(_Bump2Map);        
TEXTURE2D(_Mix2Map); 		 
TEXTURE2D(_Noise2Map); 		  SAMPLER(sampler_Noise2Map); 

TEXTURE2D(_Color3Map);        
TEXTURE2D(_Bump3Map);        
TEXTURE2D(_Mix3Map); 		 
TEXTURE2D(_Noise3Map); 		  

TEXTURE2D(_Color4Map);    
TEXTURE2D(_Bump4Map);        
TEXTURE2D(_Mix4Map); 		  
TEXTURE2D(_Noise4Map); 		 

#if !defined(INSTANCING_ON)
    CBUFFER_START(UnityPerMaterial)
#endif
half4 _BaseMap_ST;

half4 _BaseColor;
half _Metallic1;
half _Smoothness1;
half4 _EmissionColor1;

half _TransitFade;
half _TransitBegin;
float _NormalTransitEffect;
float _OffsetTransitEffect;

half4 _Color2;
half4 _EmissionColor2;
half _Metallic2;
half _Smoothness2;
float _Tiling2;
float2 _NoiseTiling2;
float _OffsetTransitEffect2;

half4 _Color3;
half4 _EmissionColor3;
half _Metallic3;
half _Smoothness3;
float _Tiling3;
float2 _NoiseTiling3;
float _OffsetTransitEffect3;

half4 _Color4;
half4 _EmissionColor4;
half _Metallic4;
half _Smoothness4;
float _Tiling4;
float2 _NoiseTiling4;
float _OffsetTransitEffect4;

half _EnableEmission;
half _EnableShowVertexColor;
half _Lod;

#if !defined(INSTANCING_ON)
    #include "../../Library/FeverDecalInput.hlsl"
    CBUFFER_END
#endif
