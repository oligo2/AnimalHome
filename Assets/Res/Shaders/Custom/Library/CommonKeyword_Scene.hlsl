// Universal Pipeline keywords
#pragma multi_compile _ _MAIN_LIGHT_CACHED_SHADOW _MAIN_LIGHT_SHADOWS
#pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE 
#pragma multi_compile _ADDITIONAL_LIGHTS 
#pragma multi_compile_fragment _SHADOWS_SOFT
#pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING

// Unity defined keywords
#pragma multi_compile _ SHADOWS_SHADOWMASK
#pragma multi_compile _ LIGHTMAP_ON
#pragma shader_feature_fragment _ DEBUG_DISPLAY

//MY
#pragma shader_feature_fragment LOD0 LOD1 LOD2



// #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
// #pragma multi_compile _ ATMOSPHERE_POSTPROCESS_ON