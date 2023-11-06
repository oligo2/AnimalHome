using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace WeatherSystem
{
    public class WeatherSkyPass : ScriptableRenderPass
    {

        private Mesh skyBox = null;
        private Material skyMaterial = null;
        
        private Material cloudMaterial = null;
        private CommandBuffer commandBuffer = null;
        private WeatherRenderPass cloudRenderPass = null;

        public void SetMesh(Mesh sky)
        {
            skyBox = sky;
        }
        
        public void SetRenderEvent(RenderPassEvent e)
        {
            renderPassEvent = e;
        }

        public void SetSkyMaterial(Material m)
        {
            skyMaterial = m;
        }
        public void SetCloudRenderMaterial(Material m)
        {
            cloudMaterial = m;
        }

        public void SetCloudRenderPass(WeatherRenderPass cloud)
        {
            cloudRenderPass = cloud;
        }

        private ScriptableRenderer render = null;
        public void SetRender(ScriptableRenderer renderer)
        {
            this.render = renderer;
        }

        public WeatherSkyPass()
        {
            
        }

        private bool enableRender = false;
        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            if (!enableRender || renderingData.cameraData.renderType != CameraRenderType.Base)
                return;
            cloudMaterial.SetTexture("_Cloud", cloudRenderPass.GetCurrRT());
            commandBuffer = CommandBufferPool.Get("RenderSkyBox");
            RenderingUtils.SetViewAndProjectionMatrices(commandBuffer, renderingData.cameraData.GetViewMatrix(), renderingData.cameraData.GetGPUProjectionMatrix(), false);

            commandBuffer.DrawMesh(skyBox, Matrix4x4.identity, skyMaterial, 0, 0);
            //commandBuffer.DrawMesh(skyBox, Matrix4x4.identity, cloudMaterial,0,0);
            context.ExecuteCommandBuffer(commandBuffer);
            commandBuffer.Release();
        }

        public void UpdateParam(WeatherSetting setting)
        {
            var sys = setting.systemSetting;
            skyMaterial.SetVector("_SunColor", sys.SunColor.Evaluate(sys.time));
            skyMaterial.SetVector("_SunDir",- setting.sunDir);
        }
        public void EnableRender(bool en)
        {
            enableRender = en;
        }
    }
}