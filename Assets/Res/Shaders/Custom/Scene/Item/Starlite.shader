Shader "Baha/Scene/Item/Starlite"
{
	Properties
	{
		[Header(Diffuse)]
		_Diffuse                             ("漫反射", Color)                           = (0.5,0.5,0.5)
		[Header(Gradient)]
		_GradientColor1                      ("颜色(V1)", Color)                         = (1,1,1)
		_GradientColor0                      ("颜色(V0)", Color)                         = (1,1,1)
		_GradientOffset                      ("渐变偏移",Range(-1,1))                    = 0
		[Header(Normal)]
		[NoScaleOffset]_NormalMap            ("法线贴图", 2D)                            = "bump" {}
		_BumpScale                           ("法线强度", Range(0,2))                    = 1
		[Header(Occulusion)]
		[NoScaleOffset]_OcculusionMap        ("遮蔽贴图", 2D)                            = "white" {}
		[HDR]_OcculusionColor                ("遮蔽颜色", Color)                         = (0,0,0)
		[Header(Refract)]
		_RefractOpacity                      ("透明度",Range(0,1))                       = 1
		_RefractMap                          ("折射纹理", 2D)                            = "white" {}
		[NoScaleOffset]_ParallexMap          ("视差贴图", 2D)                            = "grey" {}
		_ParallexOffset                      ("折射率",Range(-1,1))                      = 0
		_ShadowWeight                        ("暗部灰度",Range(0,1))                     = 0
		[Header(Fleck)]
		_FleckMap                            ("颗粒纹理", 2D)                            = "black" {}
		[Vector2]_FleckMove                  ("纹理流动",Float)                          = (0,0,0,0)
		[Header(DetailNormal)]
		_DetailNormalMap                     ("法线贴图", 2D)                            = "bump" {}
		_DetailNormalScale                   ("法线强度", Range(0,1))                    = 1
		[Header(Specular)]
		_SpecularColor                       ("颜色", Color)                             = (1,1,1)
		_SpecularShininess                   ("光泽度",Range(0,1))                       = 0.5
		[Header(Fresnel)]
		[HDR]_FresnelColor                   ("颜色", Color)                             = (1,1,1)
		_FresnelPower                        ("强度",Range(0,1))                         = 0.5
		[Header(InLight)]
		[HDR]_InLightColor                   ("发光颜色", Color)                         = (0,0,0)
		_InLightOffset                       ("发光偏移",Range(-1,1))                    = 0
		_InLightRange                        ("发光范围",Range(0,1))                     = 0
		_InLightPower                        ("发光强度",Range(0,10))                    = 1
		[Toggle(_)]_InLightBreath            ("呼吸",Float)                             = 0
		[Vector2]_InLightMove                ("流动",Float)                             = (0,0,0,0)
	}

	CustomEditor"SimpleShaderGUI"

	SubShader
	{
		Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" "Queue" = "Geometry" }

		HLSLINCLUDE
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#pragma multi_compile_instancing
			#include "./StarliteInput.hlsl"
		ENDHLSL

		pass
		{
			Name "StarLit"
			Tags
			{
				"LightMode" = "UniversalForward"
			}
			Cull back

			HLSLPROGRAM
			#pragma target 3.0
			#pragma vertex Vert
			#pragma fragment Frag
			#include "../../Library/CommonKeyword_Scene.hlsl"
			#include "../../Library/Base.hlsl"
			#include "./StarliteForwardPass.hlsl"
			ENDHLSL
		}

		Pass
		{
			Name "ShadowCaster"
			Tags { "LightMode" = "ShadowCaster" }

			HLSLPROGRAM
			#pragma vertex Vert
			#pragma fragment Frag

			#include "../../Library/Base_ShadowCaster.hlsl"
			ENDHLSL
		}

		Pass
        {
            Name "DepthOnly"
            Tags{"LightMode" = "DepthOnly"}
            ColorMask 0

            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag

			#include "../../Library/Base_DepthOnly.hlsl"
            ENDHLSL
        }
	}
		
}
