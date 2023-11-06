using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace WeatherSystem
{
    public class WeatherSystem : MonoBehaviour
    {

        static public WeatherSystem instance;

        public bool EnableRendering = true;
        public WeatherSetting weatherSetting;
       
        public Transform sun;

        private Vector3 forward = new Vector3(0, 0, 1);
        private WeatherSystemFeature systemFeature;
        //private WeatherFogFeature weatherFogFeature;

        private bool IsException = false;

        private void Awake()
        {
            try
            {
                instance = this;
                systemFeature = WeatherSystemFeature.Instance;
                systemFeature.UpdateParam(weatherSetting);
            }
            catch
            {
                IsException = true;
                enabled = false;
            }
            //weatherFogFeature = WeatherFogFeature.Instance;
        }
        private void OnEnable()
        {
            systemFeature.EnableRender(true);
        }
        private void OnDisable()
        {
            if (IsException) return;
            systemFeature.EnableRender(false);
        }

        private void Update()
        {
            if(systemFeature == null)
                systemFeature = WeatherSystemFeature.Instance;
            //if (weatherFogFeature == null)
            //    weatherFogFeature = WeatherFogFeature.Instance;
           
            //weatherSetting.systemSetting.time = TimeControl.Instance.currentTime / 24;
            CalculateSunDir();
            systemFeature.UpdateParam(weatherSetting);
            //weatherFogFeature.UpdateParam(weatherSetting);
        }

        private void CalculateSunDir()
        {
            //var upRot = Quaternion.Euler(-90f, 0, 0);
            //var tiltRot = Quaternion.Euler(-weatherSetting.systemSetting.EarthTilt,0,0);
            //var axisRot = Quaternion.Euler(0, weatherSetting.systemSetting.EarthAxis, 0);
            //sun.forward = axisRot * Quaternion.Euler(0f, 0f, -360f * weatherSetting.systemSetting.time) * tiltRot * upRot * forward;
            weatherSetting.sunDir = sun.forward;
        }
    }
}
