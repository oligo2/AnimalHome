using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace WeatherSystem
{

    [CreateAssetMenu(fileName = "WeatherType", menuName = "WeatherSystem/WeatherSystemSetting")]
    public class WeatherSystemSetting : ScriptableObject
    { 
        [Range(0, 1)] 
        public float time;
        public Gradient SunColor; //
        //public Gradient StormySunColor;
        public Gradient MoonColor;//
        //public Gradient SkyColor;
        //public Gradient AmbientSkyLightColor;
        //public Gradient StormyAmbientSkyLightColor;
        //public Gradient AmbientEquatorLightColor;
        //public Gradient StormyAmbientEquatorLightColor;
        //public Gradient AmbientGroundLightColor;
        //public Gradient StormyAmbientGroundLightColor;
        //public Gradient StarLightColor;
        //public Gradient FogColor;
        //public Gradient FogStormyColor;
        [Tooltip("云上层的颜色")]
        public Gradient CloudLightColor;
        //public Gradient StormyCloudLightColor;
        [Tooltip("云底层的颜色")]
        public Gradient CloudBaseColor;
        //public Gradient CloudStormyBaseColor;
        //public Gradient SkyTintColor;
        //[GradientUsage(true)]
        //[Tooltip("太阳周边的颜色")]
        //public Gradient SunSpotColor;
        //public Gradient FogLightColor;
        //public Gradient StormyFogLightColor;
        //public Color MoonPhaseColor = Color.white;
        //public Color MoonlightColor;
        [Tooltip("云的基础颜色")]
        public Color CloudsColor = new Color(0.6795f, 0.6795f, 0.6795f,1);

        public float CloudsBottom = 500.0f;
        public float CloudsHeight = 1000.0f;
        public float CloudsDetailScale = 1000.0f;
        [Range(0, 1)] public float CloudsBaseEdgeSoftness;
        [Range(0, 1)] public float CloudsCoverage;
        //[Range(0, 1)] public float CloudsCoverageBias;
        //[HideInInspector]
        [Range(0, 1)] public float CloudsBottomSoftness;
        //[HideInInspector]
        [Range(0, 1)] public float CloudsBearing;
        [Range(0, 1)] public float CloudsDensity;
        [Range(0, 1000)] public float CloudsMoveSpeed;
        [Range(0, 500)] public float CloudDetailMoveSpeed;
        
        [Range(0, 90)] public float EarthTilt;
        [Range(0, 90)] public float EarthAxis;
        [Range(0,1)] public float MoonAttenuation = 0.1f;
        [Range(0, 1)] public float FogBlendHeight = 1;
        [Range(0,1)] public float FogHeight = 0.85f;

        
        //public Light m_SunLight;
        //Transform m_CelestialAxisTransform;
        [Tooltip("太阳光一天内的强度")]
        public AnimationCurve SunIntensityCurve = AnimationCurve.Linear(0, 0, 24, 5);

        ////public AnimationCurve SunAtmosphericFogIntensity = AnimationCurve.Linear(0, 2, 24, 2);
        //public AnimationCurve SunControlCurve = AnimationCurve.Linear(0, 1, 24, 1);

        //public Light m_MoonLight;

        //public AnimationCurve MoonIntensityCurve = AnimationCurve.Linear(0, 0, 24, 5);

        //public int LowCloudHeight = 225;
        public AnimationCurve SunAttenuationCurve = AnimationCurve.Linear(0, 1, 24, 3);

        //public float CloudHeight = 1000;

        [Range(0.1f, 2)] public float CloudBaseScale;

        //public float HeightFogGroundHeight;
        //public float HeightFogRange;
        //public Color FogBottomColor;    //雾底部的颜色，受到周围环境光的影响
        //public Color FogColor;          //雾本身的颜色
        //[Range(0, 1)] public float HeightFogDensity;
        //[Range(0, 1)] public float HeightFogScattering;
    }
}