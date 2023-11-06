Shader "TCDemo/InfiniteOcean(Tessellation)"
{
    SubShader
    {
        Tags
        {
            "ShaderModel"="4.6"
            "RenderType" = "Transparent"
            "Queue"="Transparent"
            "RenderPipeline" = "UniversalPipeline"
        }

        Pass
        {
            Name "ForwardLit"
            Tags
            {
                "LightMode" = "UniversalForward"
            }

            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite off
            Cull back

            HLSLPROGRAM
            #pragma exclude_renderers gles gles3 glcore
            #pragma target 4.6
            #pragma vertex Vert
            #pragma fragment Frag

            #pragma hull HullProgram
            #pragma require Tessellation
            #pragma domain DomainProgram
            #pragma require Geometry

            #pragma shader_feature_local _GERSTNER _FFT


            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "InfiniteOceanCommon.hlsl"
            #include "InfiniteOceanWaveForm.hlsl"

            Varyings AfterTessVertProgram(Attributes input)
            {
                Varyings output = (Varyings)0;
                VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
                VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);


                CalculateWave(vertexInput, normalInput, _GerstnerWaveData, _GerstnerWaveCount);
                output.normalWS = normalInput.normalWS;
                output.positionHCS = TransformWorldToHClip(vertexInput.positionWS);
                output.uv = TRANSFORM_TEX(input.texcoord, _BaseMap);
                return output;
            }

            #include "InfiniteOceanTessellation.hlsl"

            half4 Frag(Varyings input) : SV_Target
            {
                half4 color = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv);
                return half4(input.normalWS, 1.);
            }
            ENDHLSL
        }
    }
}