using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace WeatherSystem
{

    //����ϵͳ�Ĳ������ʲ�
    [CreateAssetMenu(fileName = "WeatherType",menuName = "WeatherSystem/WeatherSetting")]
    public class WeatherSetting : ScriptableObject
    {
        public WeatherSystemSetting systemSetting;

        [Tooltip("̫��ǿ�����ţ�һ���ڽ�ˮʱ����̫��ǿ��")]
        [Range(0, 1)] public float SunAttenuationMultipler = 1;

        [HideInInspector]
        public Vector3 sunDir;
    }
}