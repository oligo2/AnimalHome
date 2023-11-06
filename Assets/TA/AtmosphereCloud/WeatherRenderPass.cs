using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;


namespace WeatherSystem
{
    public class WeatherRT
    {
        public RenderTexture RT;

        public WeatherRT() { }
        public WeatherRT(RenderTexture r) 
        {
            RT = r;
        }

        public static void EnsureRT(ref WeatherRT rt,int w,int h,RenderTextureFormat f,FilterMode filterMode,int depthBits,int antiAliasing)
        {
            if(rt != null )
            {
                var r = rt.RT;
                if(r.width != w || r.height != h || r.format != f || r.filterMode != filterMode || r.depth != depthBits || r.antiAliasing != antiAliasing)
                {
                    RenderTexture.ReleaseTemporary(rt.RT);
                    rt = null;
                    
                }
            }
            if(rt == null)
            {
               var r = RenderTexture.GetTemporary(w, h, depthBits, f, RenderTextureReadWrite.Linear, antiAliasing);
                r.filterMode = filterMode;
                r.wrapMode = TextureWrapMode.Repeat;
                r.enableRandomWrite = true;
                rt = new WeatherRT(r);
                Debug.Log("Create new rt");
            }
        }
    }





    public class WeatherRenderPass : ScriptableRenderPass
    {
        private CommandBuffer cmd;
       
        public WeatherRT lowResolution;
        public WeatherRT[] fullResolution = new WeatherRT[2];
        Material cloudMaterial;
        Material sampleCloudMaterial;
        WeatherSetting setting;

        Transform cameraTransform;
        Transform mainLight;
        ScriptableRenderer render;

        public enum CloudPerformance { Low = 0, Medium = 1, High = 2, Ultra = 3 }
        private int[] presetResolutions = { 1024, 2048, 2048, 2048 };
        private CloudPerformance performance = CloudPerformance.High;

        private int frameIndex = 0;
        private int haltonSequenceIndex = 0;
        private int fullBufferIndex = 0;

        static int[] haltonSequence = {
            8, 4, 12, 2, 10, 6, 14, 1
        };

        static int[,] offset = {
                    {2,1}, {1,2}, {2,0}, {0,1},
                    {2,3}, {3,2}, {3,1}, {0,3},
                    {1,0}, {1,1}, {3,3}, {0,0},
                    {2,2}, {1,3}, {3,0}, {0,2}
                };
        static int[,] bayerOffsets = {
            {0,8,2,10 },
            {12,4,14,6 },
            {3,11,1,9 },
            {15,7,13,5 }
        };

        public WeatherRenderPass()
        {

            //cameraTransform = GameObject.Find("Main Camera").transform;
            //mainLight = GameObject.Find("Directional Light").transform;

        }

        public void SetRenderPassEvent(RenderPassEvent e)
        {
            renderPassEvent = e;
        }

        private GenNoise genNoise;
        private Texture2D noiseTex;
        private Texture baseNoiseTex;
        private Texture3D detailNoiseTex;
        private Texture2D curlNoiseTex;

        public void SetCpuBaseNoise(Texture2D texture, ComputeShader computeShader)
        {
            genNoise = new GenNoise();
            genNoise.SetNoiseCompute(computeShader);
            genNoise.cpuBaseNoise = texture;
            genNoise.GenerateBaseCloudNoise();
            baseNoiseTex = genNoise.baseNoiseTexture;
            cloudMaterial.SetTexture("_uBaseNoise", baseNoiseTex);
        }
        
        public void SetDetailNoise(Texture3D c)
        {
            cloudMaterial.SetTexture("_uDetailNoise", c);
            detailNoiseTex = c;
        }
        public void SetNoise(Texture2D c)
        {
            cloudMaterial.SetTexture("_NoiseTex", c);
            noiseTex = c;
        }
        public void SetCurlNoise(Texture2D c)
        {
            cloudMaterial.SetTexture("_uCurlNoise", c);
            curlNoiseTex = c;
        }

        public void SetRender(ScriptableRenderer renderer)
        {
            this.render = renderer;
        }

        public void SetCloudMaterial(Material material)
        {
            cloudMaterial = material;
            cloudMaterial.EnableKeyword("HIGH");
            cloudMaterial.EnableKeyword("VOLUMETRIC");

        }

        public void SetSampleCloudMaterial(Material material)
        {
            sampleCloudMaterial = material;
        }

        public void SetPreformance(CloudPerformance p)
        {
            performance = p;
        }

        public RenderTexture GetCurrRT()
        {
            return fullResolution[fullBufferIndex ^ 1].RT;
        }
        bool enableRender = false;
        int frameCount = 0;
        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            if (!enableRender || renderingData.cameraData.renderType != CameraRenderType.Base)
                return;
            frameIndex = (frameIndex + 1) % 16;
            if (frameIndex == 0)
                haltonSequenceIndex = (haltonSequenceIndex + 1) % haltonSequence.Length;
            fullBufferIndex = fullBufferIndex ^ 1;

            frameCount++;
            if (frameCount < 32)
                cloudMaterial.EnableKeyword("PREWARM");
            else if (frameCount == 32)
                cloudMaterial.DisableKeyword("PREWARM");

            var camera = renderingData.cameraData.camera;
            Shader.SetGlobalMatrix("_InverseViewProjectionMatrix", (GL.GetGPUProjectionMatrix(camera.projectionMatrix, false) * camera.worldToCameraMatrix).inverse);

            int w = camera.pixelWidth;
            int h = camera.pixelHeight;
            int size = presetResolutions[(int)performance];
            WeatherRT.EnsureRT(ref lowResolution, size/4, size/4, RenderTextureFormat.ARGBFloat, FilterMode.Point, 0, 1);
            WeatherRT.EnsureRT(ref fullResolution[0], size, size, RenderTextureFormat.ARGBHalf, FilterMode.Bilinear, 0, 1);
            WeatherRT.EnsureRT(ref fullResolution[1], size, size, RenderTextureFormat.ARGBHalf, FilterMode.Bilinear, 0, 1);
            UpdateSysParam();
            //UpdateParam();

            cmd = CommandBufferPool.Get("RenderCloud");
            //cmd.SetRenderTarget(lowResolution.RT);
            cmd.Blit(null, lowResolution.RT, cloudMaterial, 0);

            cmd.SetGlobalTexture("_uLowresCloudTex", lowResolution.RT);
            cmd.SetGlobalTexture("_uPreviousCloudTex", fullResolution[fullBufferIndex].RT);
            cmd.Blit(fullResolution[fullBufferIndex].RT, fullResolution[fullBufferIndex ^ 1].RT, cloudMaterial, 1);
            cmd.SetGlobalTexture("_uCustomCloud", fullResolution[fullBufferIndex ^ 1].RT);
            //cmd.Blit(lowResolution.RT, render.cameraColorTarget, sampleCloudMaterial, 0);
            context.ExecuteCommandBuffer(cmd);
            cmd.Release();
        }

        public void UpdateSysParam()
        {
            float offsetX = offset[frameIndex, 0];
            float offsetY = offset[frameIndex, 1];
            cloudMaterial.SetVector("_uJitter", new Vector2(offsetX, offsetY));
            cloudMaterial.SetFloat("_uRaymarchOffset", (haltonSequence[haltonSequenceIndex] / 16.0f + bayerOffsets[offset[frameIndex, 0], offset[frameIndex, 1]] / 16.0f));
        }

        public void EnableRender(bool en)
        {
            enableRender = en;
        }
        float detailOffst = 0;
        public void SetParam( WeatherSetting setting)
        {
            if (setting == null)
            {
                return;
            }
            var sys = setting.systemSetting;
            float time = sys.time;

            cloudMaterial.SetTexture("_uDetailNoise", detailNoiseTex);
            cloudMaterial.SetTexture("_uBaseNoise", baseNoiseTex);
            cloudMaterial.SetTexture("_uCurlNoise",curlNoiseTex);

            cloudMaterial.SetFloat("_EnableDithering", 1);
            cloudMaterial.SetFloat("_uSize", 2048);
            cloudMaterial.SetFloat("_uCloudsBottom", sys.CloudsBottom);
            cloudMaterial.SetFloat("_uCloudsHeight", sys.CloudsHeight);
            cloudMaterial.SetVector("_uSunDir", setting.sunDir);
            //cloudMaterial.SetVector("_uSunDir", new Vector4(-0.707f,-0.0831f,-0.7022f,0));
            cloudMaterial.SetFloat("_uCloudAlpha", 1);
            cloudMaterial.SetVector("_uMoonDir", new Vector4(0.573f, 0.09628f, 0.813f, 0));
            //cloudMaterial.SetFloat("_uRaymarchOffset", (haltonSequence[haltonSequenceIndex] / 16.0f + bayerOffsets[offset[frameIndex, 0], offset[frameIndex, 1]] / 16.0f));
            cloudMaterial.SetFloat("_uCloudsBaseEdgeSoftness", sys.CloudsBaseEdgeSoftness);
            cloudMaterial.SetFloat("_uCloudsCoverage", sys.CloudsCoverage);
            //cloudMaterial.SetFloat("_uCloudsCoverageBias",sys.CloudsCoverageBias);
            cloudMaterial.SetFloat("_uCloudsCoverageBias",0);
            cloudMaterial.SetFloat("_uCloudsBottomSoftness", sys.CloudsBottomSoftness);
            cloudMaterial.SetFloat("_uCloudsBearing", sys.CloudsBearing);
            //cloudMaterial.SetFloat("_uBaseCloudOffset", 3300);
            cloudMaterial.SetFloat("_uBaseCloudOffset", 43);
            cloudMaterial.SetFloat("_uCloudsBaseScale", sys.CloudBaseScale);

            cloudMaterial.SetFloat("_uDetailCloudOffset", detailOffst += sys.CloudDetailMoveSpeed * Time.deltaTime);
            //cloudMaterial.SetFloat("_uDetailCloudOffset", 43);
            cloudMaterial.SetFloat("_uCloudsDetailScale", sys.CloudsDetailScale);
            cloudMaterial.SetFloat("_uCurlScale", 1000);
            cloudMaterial.SetFloat("_uCloudsDetailStrength", 0.072f);
            cloudMaterial.SetFloat("_uCloudsDensity", sys.CloudsDensity);

            cloudMaterial.SetVector("_uCloudsAmbientColorBottom",sys.CloudBaseColor.Evaluate(time));

            cloudMaterial.SetVector("_uCloudsAmbientColorTop", sys.CloudLightColor.Evaluate(time));
            //cloudMaterial.SetColor("_uCloudsAmbientColorTop", new Vector4(0.9728f,0.6882f,0.543f,1));
            cloudMaterial.SetVector("_uLightningColor", new Vector4(0.764f, 0.8325f, 0.886f, 1));
            
            cloudMaterial.SetVector("_uCloudsColor", sys.CloudsColor);
            //cloudMaterial.SetColor("_uCloudsColor", new Vector4(0.843f,0.843f,0.843f,1));
            cloudMaterial.SetVector("_uSunColor", sys.SunColor.Evaluate(time) * sys.SunIntensityCurve.Evaluate(time * 24));

            cloudMaterial.SetVector("_uMoonColor", sys.MoonColor.Evaluate(time));
            cloudMaterial.SetFloat("_uMoonAttenuation", sys.MoonAttenuation);
            cloudMaterial.SetFloat("_uAttenuation", sys.SunAttenuationCurve.Evaluate(time * 24) * setting.SunAttenuationMultipler);
            //cloudMaterial.SetFloat("_uAttenuation", 0.75f);
            cloudMaterial.SetFloat("_CloudsMovementSpeed", 5);

            //cloudMaterial.SetColor("_SunColor", sys.SunSpotColor.Evaluate(time));
            cloudMaterial.SetColor("_SunColor", sys.SunColor.Evaluate(time));
            //cloudMaterial.SetVector("_MoonColor",3) 用默认的
            cloudMaterial.SetFloat("_SunAlpha", 9.4f);
            //cloudMaterial.SetFloat("_SunBeta", 1);
            //cloudMaterial.SetColor("_FogColor", sys.FogColor.Evaluate(time));
            cloudMaterial.SetFloat("_FogBlendHeight", sys.FogBlendHeight);
            cloudMaterial.SetVector("_SunVector", setting.sunDir);
            cloudMaterial.SetFloat("_MaskMoon", 0); //5-19点为0，其余为1

            cloudMaterial.SetFloat("_uCloudsMovementSpeed", sys.CloudsMoveSpeed);
            cloudMaterial.SetFloat("_uDetailCloudMoveSpeed", sys.CloudDetailMoveSpeed * Time.deltaTime);
        }
    }
}