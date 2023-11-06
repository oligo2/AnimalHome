

#if defined(ATMOSPHERE_ON) && !defined(ATMOSPHERE_POSTPROCESS_ON)
	#define DECLARE_ATMOSPHERE(index) float4 inscattering : TEXCOORD##index;
#else
	#define DECLARE_ATMOSPHERE(index)
#endif


#if defined (ATMOSPHERE_ON)

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/NepheleSky/Atmosphere.hlsl"


half3 CalculateAtmosphere(half3 color, float4 inscattering )
{
	#if defined(ATMOSPHERE_ON) && !defined(ATMOSPHERE_POSTPROCESS_ON)
		color.rgb = GetAtmosphereOutputColor(color.rgb, inscattering);
	#endif
	return color.rgb;
}

#endif

