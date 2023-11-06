using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace WeatherSystem
{

    //天气系统的参数化资产
    [CreateAssetMenu(fileName = "WeatherType",menuName = "WeatherSystem/WeatherSetting")]
    public class WeatherSetting : ScriptableObject
    {
        public WeatherSystemSetting systemSetting;

        [Tooltip("太阳强度缩放，一般在降水时降低太阳强度")]
        [Range(0, 1)] public float SunAttenuationMultipler = 1;

        [HideInInspector]
        public Vector3 sunDir;
    }
}