using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace TCOcean.InfiniteOceanSystem
{
    // [ExecuteAlways]
    [Serializable]
    public partial class TCInfiniteOceanSystem : MonoBehaviour
    {
        #region 海水网格生成所需参数

        public TCInfiniteOceanSystemObject m_TCOceanPreset;

        //Common参数
        private Camera mCurrentCamera; //当前摄像机位置
        private Transform mOceanRoot; // 海水根节层级
        private GameObject mOceanMeshRoot; //网格对象总层级
        private bool mOceanResourcesInitialized = false; //海水初始化状态
        private float mFarMainCameraDist = 5000f;
        private float mFarMainCameraWidth = 12000.0f;

        //创建网格
        private TCInfiniteOceanSystem_PlaneMesh mPlaneMeshClass = new TCInfiniteOceanSystem_PlaneMesh();
        private Mesh mPlaneMesh;
        private GameObject mPlaneMeshObject;
        private TCInfiniteOceanSystem_CircleMesh mCircleMeshClass = new TCInfiniteOceanSystem_CircleMesh();
        private Mesh mCircleMesh;
        private GameObject mCircleMeshObject;
        private TCInfiniteOceanSystem_TrapezoidMesh mTrapezoidMeshClass = new TCInfiniteOceanSystem_TrapezoidMesh();
        private Mesh mTrapezoidMesh;
        private GameObject mTrapezoidMeshObject;

        //材质相关
        private Material mOceanMaterital; //海水材质

        #endregion

        private void Init()
        {
            mOceanRoot = this.transform;
            mOceanRoot.localScale = Vector3.one;
            mOceanResourcesInitialized = false;
            mCurrentCamera = Camera.main;
        }

        private void Awake()
        {
        }

        private void Start()
        {
            Init();
        }

        private void LateUpdate()
        {
            RenderInfiniteOcean();
        }
    }
}