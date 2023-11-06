using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace TCOcean.InfiniteOceanSystem
{
    public partial class TCInfiniteOceanSystem
    {
        public void InitializeMaterial()
        {
            if (m_TCOceanPreset.m_UseTesselation && SystemInfo.graphicsShaderLevel >= 46)
            {
                if (m_TCOceanPreset.m_MateritalAbleTesselation != null)
                {
                    mOceanMaterital = m_TCOceanPreset.m_MateritalAbleTesselation;
                    SetMatTesselationValue();
                    SetMatValue();
                }
                else
                {
                    Debug.LogError("包含曲面细分的海水材质为空！");
                    return;
                }
            }
            else
            {
                if (m_TCOceanPreset.m_MateritalUnableTesselation != null)
                {
                    mOceanMaterital = m_TCOceanPreset.m_MateritalUnableTesselation;
                }
                else
                {
                    Debug.LogError("不包含曲面细分的海水材质为空！");
                    return;
                }
            }

            Debug.Log("当前使用材质" + mOceanMaterital.name);
        }

        /// <summary>
        /// 曲面细分相关参数设置
        /// </summary>
        private void SetMatTesselationValue()
        {
            var myCurrentTessFactor = Mathf.Lerp(1, m_TCOceanPreset.m_TesselationMaxFactor, m_TCOceanPreset.m_TesselationFactorWeights);
            mOceanMaterital.SetFloat(OceanPID.TesselationFactor, myCurrentTessFactor);
            mOceanMaterital.SetFloat(OceanPID.TesselationMaxDistance, m_TCOceanPreset.m_TesselationMaxDistance);
            var myMaxTessCullDisplace = Mathf.Max(1.5f, 2);
            mOceanMaterital.SetFloat(OceanPID.TesselationMaxDisplace, myMaxTessCullDisplace);
        }

        /// <summary>
        /// 通用参数设置合集
        /// </summary>
        private void SetMatValue()
        {
            SetWaveFormValue();
        }

        /// <summary>
        /// 波形计算函数
        /// </summary>
        private void SetWaveFormValue()
        {
            switch (m_TCOceanPreset.m_TCOceanWaveFormType)
            {
                case TCInfiniteOceanSystemObject.TCOceanWaveFormTypeEnum.Gerstner:
                    mOceanMaterital.SetInt(OceanPID.GerstnerWaveCount, m_TCOceanPreset.m_GerstnerWaveCount);
                    var myGerstnerWaveData = CalculateRandomGerstnerWave();
                    mOceanMaterital.SetVectorArray(OceanPID.GerstnerWaveData, myGerstnerWaveData);
                    Debug.Log(m_TCOceanPreset.m_GerstnerWaveRandomSeed);
                    break;
                case TCInfiniteOceanSystemObject.TCOceanWaveFormTypeEnum.FFT:
                    break;
            }
        }

        /// <summary>
        /// 计算随机波形
        /// </summary>
        /// <returns></returns>
        private Vector4[] CalculateRandomGerstnerWave()
        {
            var myBackupSeed = Random.state;
            Random.InitState(m_TCOceanPreset.m_GerstnerWaveRandomSeed);
            var myAmplitude = m_TCOceanPreset.m_GerstnerWaveAmplitude;
            var myDirection = m_TCOceanPreset.m_GerstnerWaveDirection;
            var myWaveLength = m_TCOceanPreset.m_GerstnerWaveLength;
            var myWaveCount = m_TCOceanPreset.m_GerstnerWaveCount;
            Vector4[] myGerstnerWaveData = new Vector4[myWaveCount];
            var myLerpFactor = 1f / myWaveCount;
            for (var i = 0; i < myWaveCount; i++)
            {
                var p = Mathf.Lerp(0.5f, 1.5f, i * myLerpFactor);
                var amp = myAmplitude * p * Random.Range(0.8f, 1.2f);
                var dir = myDirection + Random.Range(-90f, 90f);
                var len = myWaveLength * p * Random.Range(0.6f, 1.4f);
                myGerstnerWaveData[i] = new Vector4(amp, dir, len, 0);
                Random.InitState(m_TCOceanPreset.m_GerstnerWaveRandomSeed + i + 1);
            }

            Random.state = myBackupSeed;
            return myGerstnerWaveData;
        }
    }

    public class OceanPID
    {
        //曲面细分
        public static readonly int TesselationFactor = Shader.PropertyToID("_TesselationFactor");
        public static readonly int TesselationMaxDistance = Shader.PropertyToID("_TesselationMaxDistance");
        public static readonly int TesselationMaxDisplace = Shader.PropertyToID("_TesselationMaxDisplace");

        //波形计算
        //波形计算 - Gerstner Wave
        public static readonly int GerstnerWaveCount = Shader.PropertyToID("_GerstnerWaveCount");
        public static readonly int GerstnerWaveData = Shader.PropertyToID("_GerstnerWaveData");
    }
}