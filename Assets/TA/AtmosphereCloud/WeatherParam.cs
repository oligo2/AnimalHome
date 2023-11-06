using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace WeatherSystem
{
    public class WeatherParam : ScriptableObject
    {
        public float CloudsBottom;
        public float CloudsHeight;
        public float CloudsBaseEdgeSoftness;
        [Range(0,1)] public float CloudsCoverage;
        public float CloudsCoverageBias;
         
    }
}