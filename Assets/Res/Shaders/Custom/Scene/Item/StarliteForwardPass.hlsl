
struct vert
{               
	float4 positionOS     : POSITION;
	float3 normalOS       : NORMAL;
	float4 tangentOS      : TANGENT;
	float2 uv1            : TEXCOORD0;
	float2 uv2            : TEXCOORD1;
};

struct v2f
{
	float4 positionCS     : SV_POSITION;
	float3 positionWS     : TEXCOORD0;
	float3 normalWS       : NORMAL;
	float3 tangentWS      : TEXCOORD1;
	float3 bitangentWS    : TEXCOORD2;
	float4 positionSS     : TEXCOORD3;
	float2 uv1            : TEXCOORD4;
	float2 uv2            : TEXCOORD5;
	float3 positionOS     : TEXCOORD6;

#if defined(ATMOSPHERE_ON) && !defined(ATMOSPHERE_POSTPROCESS_ON)
	float4 inscattering   : TEXCOORD7;
#endif

};

v2f Vert(vert v)
{
	v2f o = (v2f)0;

	VertexPositionInputs vertexInput = GetVertexPositionInputs(v.positionOS.xyz);
	o.positionCS                     = vertexInput.positionCS; 
	o.positionWS                     = vertexInput.positionWS; 
	o.normalWS                       = TransformObjectToWorldNormal(v.normalOS);
	o.tangentWS                      = normalize(TransformObjectToWorldDir(v.tangentOS.xyz));
	o.bitangentWS                    = normalize(cross(o.tangentWS.xyz, o.normalWS.xyz) * -v.tangentOS.w);
	o.uv1.xy                         = v.uv1.xy;
	o.uv2.xy                         = v.uv2.xy;
	o.positionSS                     = ComputeScreenPos(o.positionCS);
	o.positionOS                     = v.positionOS.xyz;

#if defined(ATMOSPHERE_ON) && !defined(ATMOSPHERE_POSTPROCESS_ON)
o.inscattering = InScattering(_WorldSpaceCameraPos, o.positionWS);
#endif
	return o;                      
}

float4 Frag(v2f i) : SV_Target
{
	#if defined(INSTANCING_ON)
		UNITY_SETUP_INSTANCE_ID(i);
	#endif
	
	//ShadowMap
	float4 shadowCoord      = TransformWorldToShadowCoord(i.positionWS);

	//MainLight
	Light mainLight         = GetMainLight(shadowCoord);

	//Normal
	float3 normalMap        = UnpackNormalScale(SAMPLE_TEXTURE2D(_NormalMap, sampler_NormalMap, i.uv1), _BumpScale);
	float3 detailNormalMap  = UnpackNormalScale(SAMPLE_TEXTURE2D(_DetailNormalMap, sampler_DetailNormalMap, i.uv1  * _DetailNormalMap_ST.xy + _DetailNormalMap_ST.zw), _DetailNormalScale);

	//Basic Vector
	float3x3 TBN            = float3x3(i.tangentWS, i.bitangentWS, i.normalWS.xyz);
	float3 L                = normalize(mainLight.direction);
	float3 V                = normalize(_WorldSpaceCameraPos - i.positionWS.xyz);
	float3 N                = normalize(mul(normalMap, TBN));
	float3 dN               = normalize(mul(BlendNormal(detailNormalMap, normalMap), TBN));

	//Parallex Coord
	float3 camPosLocal      = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos, 1.0)).xyz;
	float3 dirToCamLocal    = camPosLocal - i.positionOS;
	float3 camPosTexcoord   = mul(TBN, dirToCamLocal); // get cam pos in texture (TBN) space
	float3 eyeVec           = normalize(camPosTexcoord);
	float height            = SAMPLE_TEXTURE2D(_ParallexMap, sampler_ParallexMap, i.uv1).r;
	float v                 = height * _ParallexOffset - (_ParallexOffset * 0.5);
	float2 newCoords        = i.uv1 + eyeVec.xy * v;

	//HalfLambert
	float halfLambert       = saturate(dot(L, N) * 0.5 + 0.5);
	halfLambert            *= mainLight.shadowAttenuation;

	//GI
	float3 ambColor           = float3(0.2,0.2,0.2);//Debug Color

	//Occulusion
	float occulusion        = SAMPLE_TEXTURE2D(_OcculusionMap, sampler_OcculusionMap, i.uv1).r;
	float3 occulusionColor  = lerp(_OcculusionColor, 1, occulusion);

	//Gradient
	float gradient          = saturate(i.uv2.y + _GradientOffset);
	float3 gradientColor    = lerp(_GradientColor0, _GradientColor1, gradient);
	
	//Refract
	float2 refractMapUV     = float2(newCoords.x * _RefractMap_ST.x, newCoords.y * _RefractMap_ST.y);
	float3 refractColor     = SAMPLE_TEXTURE2D(_RefractMap, sampler_RefractMap, refractMapUV).rgb;
	
	//Fleck
	float2 fleckMapUV        = float2(newCoords.x * _FleckMap_ST.x, newCoords.y * _FleckMap_ST.y);
	fleckMapUV               = fleckMapUV * _FleckMap_ST.xy + _Time.x * float2(_FleckMove.x, _FleckMove.y) + float2(_FleckMap_ST.z, _FleckMap_ST.w);
	float3 fleckColor        = SAMPLE_TEXTURE2D(_FleckMap, sampler_FleckMap, fleckMapUV).rgb;

	//Specular
	float specularShininess = max(1, _SpecularShininess * 100);
	float blinnphong        = max(dot(dN, normalize(L + V)), 0);
	float specular          = pow(blinnphong, specularShininess);
	specular               *= saturate(_SpecularShininess * 10);
	float3 specularColor    = _SpecularColor * specular;

	//Fresnel
	float fresnel           = saturate(1 - (dot(V, dN) * lerp(2, 1, _FresnelPower)));
	float3 fresnelColor     = _FresnelColor * fresnel;

	//InLight
	float inLightBreath    = abs(_SinTime.w);
	float2 inLightUV       = refractMapUV * _RefractMap_ST.xy + _Time.x * float2(_InLightMove.x, _InLightMove.y) + float2(_RefractMap_ST.z, _RefractMap_ST.w);
	float3 inLightColor    = SAMPLE_TEXTURE2D(_RefractMap, sampler_RefractMap, inLightUV).rgb;
	float inLight          = 1 - saturate(abs(i.uv2.y + _InLightOffset - 0.5) / (_InLightRange * 10));
	inLight                = pow(inLight, 2.2);
	inLight               *= _InLightPower * max(0.5, 1 - occulusion);
	inLight               *= max(0.6, halfLambert);
	inLight               *= lerp(inLight, inLight * inLightBreath, _InLightBreath);
	
	//Finalcolor
	float3 diffuse          = _Diffuse * gradientColor;
	diffuse                *= lerp(ambColor, saturate(mainLight.color), halfLambert * saturate(mainLight.color));
	float3 refract          = refractColor * gradientColor * max(halfLambert, _ShadowWeight);

	float3 finalcolor       = lerp(diffuse, refract, _RefractOpacity);
	finalcolor             *= occulusionColor;
	finalcolor             += specularColor * mainLight.color * occulusion;
	finalcolor             += fresnelColor * occulusion * finalcolor;
	finalcolor             += lerp(0, fleckColor, _RefractOpacity);
	finalcolor             += inLight * inLightColor * _InLightColor;

	//AdditionalLight
	int lightCount = GetAdditionalLightsCount();
	for (int j = 0; j < lightCount; ++j)
	{
		Light light = GetAdditionalLight(j, i.positionWS);
		half3 attenuatedLightColor = light.color * light.distanceAttenuation;
		half3 blinn = pow(max(dot(N, normalize(light.direction + V)), 0), 10);
		half3 Lit = refractColor * gradientColor ;
		finalcolor += attenuatedLightColor * Lit;
	}

#if defined(ATMOSPHERE_ON) && !defined(ATMOSPHERE_POSTPROCESS_ON) //fog        
	finalcolor = CalculateAtmosphere(finalcolor, i.inscattering);
#endif
	return float4(finalcolor, 1);
}