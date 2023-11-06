using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace TCOcean.InfiniteOceanSystem
{
    [Serializable]
    [CreateAssetMenu(menuName = "TCDemo/Infinite Ocean Preset Asset", fileName = "Infinite Ocean Preset")]
    public class TCInfiniteOceanSystemObject : ScriptableObject
    {
        //网格相关
        [Range(-100f, 100f)] public float m_OceanLevel;
        public TCOceanMeshTypeEnum m_TCOceanMeshType;
        [Range(0f, 1f)] public float m_PlaneMeshQualityWeights = 10; //网格质量
        [Range(100, 400)] public int m_PlaneMeshDoMainSize = 10; //最中心初始块区域的大小
        [Range(20, 200)] public int m_CircleGridNumber = 32; // 格子数
        [Range(200f, 640f)] public float m_TrapezoidalUpperLine = 500.0f; // 梯形上底

        //曲面细分
        public bool m_UseTesselation;
        public Material m_MateritalUnableTesselation;
        public Material m_MateritalAbleTesselation;
        [Range(0f, 1f)] public float m_TesselationFactorWeights = 0.6f;
        [Range(0f, 10f)] public float m_TesselationMaxFactor = 10;
        [Range(0f, 1000f)] public float m_TesselationMaxDistance = 1000f;

        //波形相关
        public TCOceanWaveFormTypeEnum m_TCOceanWaveFormType;
        [Range(1, 10)] public int m_GerstnerWaveCount = 8;
        public int m_GerstnerWaveRandomSeed = 1;
        [Range(0.01f, 5f)] public float m_GerstnerWaveAmplitude = 1f;
        [Range(0f, 180f)] public float m_GerstnerWaveDirection = 1f;
        [Range(0f, 100f)] public float m_GerstnerWaveLength = 1f;

        public enum TCOceanMeshTypeEnum
        {
            InfinitePlane,
            CircleTrapezoid
        }

        public enum TCOceanWaveFormTypeEnum
        {
            Gerstner,
            FFT
        }
    }
}