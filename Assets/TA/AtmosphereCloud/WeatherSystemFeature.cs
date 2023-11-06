using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering.Universal;

namespace WeatherSystem
{
    public class WeatherSystemFeature : ScriptableRendererFeature
    {
        public static WeatherSystemFeature Instance = null;

        //Ìì¿ÕºÐ×ÓµÄäÖÈ¾
        private WeatherSkyPass skyPass = null;
        public Mesh skyBox = null;
        public Shader skyBoxShader = null;
        public RenderPassEvent skyBoxRenderEvent = RenderPassEvent.AfterRenderingSkybox;

        //ÔÆ
        private WeatherRenderPass weatherRenderPass = null;
        private WeatherSetting weatherParam = null;
        public Shader cloudRenderShader = null;
        public Shader sampleCloudShader = null;
        public RenderPassEvent cloudRenderEvent = RenderPassEvent.BeforeRenderingSkybox;

        public ComputeShader noiseGen;
        public Texture2D cpuBaseNoise;
        public Texture2D noiseTex;
        public Texture2D curlNoiseTex;
        public Texture3D detailNoiseTex;



        public override void Create()
        {
            Instance = this;

            skyPass = new WeatherSkyPass();
            skyPass.SetMesh(skyBox);
            skyPass.SetSkyMaterial(new Material(skyBoxShader));
            
            skyPass.SetCloudRenderMaterial(new Material(sampleCloudShader));
            skyPass.SetRenderEvent(skyBoxRenderEvent);

            weatherRenderPass = new WeatherRenderPass();
            weatherRenderPass.SetCloudMaterial(new Material(cloudRenderShader));
            weatherRenderPass.SetSampleCloudMaterial(new Material(sampleCloudShader));
            weatherRenderPass.SetRenderPassEvent(cloudRenderEvent);
            
            weatherRenderPass.SetDetailNoise(detailNoiseTex);
            weatherRenderPass.SetCurlNoise(curlNoiseTex);
            weatherRenderPass.SetNoise(noiseTex);
            weatherRenderPass.SetCpuBaseNoise(cpuBaseNoise, noiseGen);

            //fogPass = new WeatherFogPass();
            //fogPass.SetMaterial(fogShader);

            skyPass.SetCloudRenderPass(weatherRenderPass);
        }



        public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
        {
            skyPass.SetRender(renderer);
            weatherRenderPass.SetRender(renderer);
            
            renderer.EnqueuePass(weatherRenderPass);
            renderer.EnqueuePass(skyPass);
            
            
        }

        public void UpdateParam(WeatherSetting setting)
        {
            //weatherParam = setting;
            weatherRenderPass.SetParam(setting);
            skyPass.UpdateParam(setting);
        }

        public void EnableRender(bool e)
        {
            weatherRenderPass.EnableRender(e);
            skyPass.EnableRender(e);
        }

    }
}