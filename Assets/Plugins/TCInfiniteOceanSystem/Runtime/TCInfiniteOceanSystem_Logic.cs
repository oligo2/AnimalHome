using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Object = System.Object;

namespace TCOcean.InfiniteOceanSystem
{
    [ExecuteAlways]
    public partial class TCInfiniteOceanSystem
    {
        /// <summary>
        /// 海洋渲染入口
        /// </summary>
        private void RenderInfiniteOcean()
        {
            if (mCurrentCamera == null)
            {
                Debug.LogError("Ocean:当前场景未设置主相机");
                return;
            }

            if (!mOceanResourcesInitialized)
            {
                InitializeOceanResources();
            }

            //海水位置处理
            switch (m_TCOceanPreset.m_TCOceanMeshType)
            {
                case TCInfiniteOceanSystemObject.TCOceanMeshTypeEnum.InfinitePlane:
                    if (mPlaneMeshObject != null)
                    {
                        UpdatePositionPlaneMesh(mCurrentCamera, mPlaneMeshObject.transform);
                    }
                    else
                    {
                        return;
                    }

                    break;
                case TCInfiniteOceanSystemObject.TCOceanMeshTypeEnum.CircleTrapezoid:
                    if (mCircleMeshObject != null && mTrapezoidMeshObject != null)
                    {
                        UpdatePositionCricleTrapezoidMesh(mCurrentCamera, mCircleMeshObject.transform, mTrapezoidMeshObject.transform);
                    }
                    else
                    {
                        return;
                    }

                    break;
            }
        }


        /// <summary>
        /// 创建一个临时的Gameobject
        /// </summary>
        /// <param name="gameobjectname">名称</param>
        /// <param name="parentgameobject">父物体坐标</param>
        /// <returns></returns>
        GameObject CreateTempGameobject(string gameobjectname, Transform parentgameobject)
        {
            GameObject tempGameobject = new GameObject(gameobjectname)
            {
                hideFlags = HideFlags.DontSave
            };

            tempGameobject.transform.parent = parentgameobject;
            tempGameobject.transform.localPosition = Vector3.zero;
            return tempGameobject;
        }

        /// <summary>
        /// 初始化海洋资源
        /// </summary>
        private void InitializeOceanResources()
        {
            if (mOceanMeshRoot == null)
            {
                mOceanMeshRoot = CreateTempGameobject("OceanMeshRoot", mOceanRoot);
                SafeDestroy(mOceanMaterital);
                InitializeMaterial();
                InitializeMesh();
                Debug.Log("初始化海洋资源成功！ ");
                mOceanResourcesInitialized = true;
            }
        }


        /// <summary>
        /// 计算远剪裁面相关数据
        /// </summary>
        public void CalculateCameraFrustum()
        {
            //计算摄像机最远截面
            Camera maincam = Camera.main;
            if (maincam != null)
            {
                mFarMainCameraDist = maincam.farClipPlane;
                Vector3 leftPoint = new Vector3(0, 0, maincam.farClipPlane);
                Vector3 rightPoint = new Vector3(1, 0, maincam.farClipPlane);
                Vector3 worldLeftPoint = maincam.ViewportToWorldPoint(leftPoint);
                Vector3 worldRightPoint = maincam.ViewportToWorldPoint(rightPoint);
                mFarMainCameraWidth = Math.Abs(worldRightPoint.x - worldLeftPoint.x);
                var farCameraWidth = mFarMainCameraWidth * 0.2f + mFarMainCameraWidth;
                mFarMainCameraWidth = farCameraWidth;
            }
        }

        #region 初始化网格

        /// <summary>
        /// 网格初始化总方法
        /// </summary>
        public void InitializeMesh()
        {
            Debug.Log("InitializeMesh 方法更新");
            CalculateCameraFrustum();

            switch (m_TCOceanPreset.m_TCOceanMeshType)
            {
                case TCInfiniteOceanSystemObject.TCOceanMeshTypeEnum.InfinitePlane:
                    SafeDestroy(mCircleMeshObject);
                    SafeDestroy(mTrapezoidMeshObject);
                    CreatePlaneMesh();
                    break;
                case TCInfiniteOceanSystemObject.TCOceanMeshTypeEnum.CircleTrapezoid:
                    SafeDestroy(mPlaneMeshObject);
                    CreateCircleMesh();
                    CreateTrapezoidMesh();
                    break;
            }
        }

        /// <summary>
        /// 创建片状网格
        /// </summary>
        public void CreatePlaneMesh()
        {
            if (mPlaneMesh != null)
            {
                SafeDestroy(mPlaneMesh);
                Debug.LogWarning(mPlaneMesh.name + "已销毁！");
            }

            mPlaneMesh = mPlaneMeshClass.GeneratorPlane(m_TCOceanPreset.m_PlaneMeshDoMainSize, m_TCOceanPreset.m_PlaneMeshQualityWeights, mFarMainCameraDist);
            mPlaneMesh.RecalculateBounds();

            if (mOceanMeshRoot != null)
            {
                if (mPlaneMeshObject == null)
                {
                    mPlaneMeshObject = CreateTempGameobject("PlaneMesh", mOceanMeshRoot.transform);
                    mPlaneMeshObject.layer = LayerMask.NameToLayer("Water");
                    mPlaneMeshObject.AddComponent<MeshFilter>();
                    mPlaneMeshObject.AddComponent<MeshRenderer>();
                }

                mPlaneMeshObject.GetComponent<MeshFilter>().sharedMesh = mPlaneMesh;
                mPlaneMeshObject.GetComponent<MeshRenderer>().sharedMaterial = mOceanMaterital;
            }
        }

        /// <summary>
        /// 创建圆形Mesh
        /// </summary>
        public void CreateCircleMesh()
        {
            if (mCircleMesh != null)
            {
                SafeDestroy(mCircleMesh);
                Debug.LogWarning(mCircleMesh.name + "已销毁！");
            }

            mCircleMesh = mCircleMeshClass.GeneratorCircle(m_TCOceanPreset.m_CircleGridNumber, m_TCOceanPreset.m_TrapezoidalUpperLine);
            mCircleMesh.RecalculateBounds();

            if (mOceanMeshRoot != null)
            {
                if (mCircleMeshObject == null)
                {
                    mCircleMeshObject = CreateTempGameobject("CircleMesh", mOceanMeshRoot.transform);
                    mCircleMeshObject.layer = LayerMask.NameToLayer("Water");
                    mCircleMeshObject.AddComponent<MeshFilter>();
                    mCircleMeshObject.AddComponent<MeshRenderer>();
                }

                mCircleMeshObject.GetComponent<MeshFilter>().sharedMesh = mCircleMesh;
                mCircleMeshObject.GetComponent<MeshRenderer>().sharedMaterial = mOceanMaterital;
            }
        }

        /// <summary>
        /// 创建不规则梯形Mesh
        /// </summary>
        public void CreateTrapezoidMesh()
        {
            if (mTrapezoidMesh != null)
            {
                SafeDestroy(mTrapezoidMesh);
                Debug.LogWarning(mTrapezoidMesh.name + "已销毁！");
            }

            mTrapezoidMesh = mTrapezoidMeshClass.GenerateTrapezoid(m_TCOceanPreset.m_CircleGridNumber, m_TCOceanPreset.m_TrapezoidalUpperLine,
                mFarMainCameraWidth, mFarMainCameraDist);
            mTrapezoidMesh.RecalculateBounds();

            if (mOceanMeshRoot != null)
            {
                if (mTrapezoidMeshObject == null)
                {
                    mTrapezoidMeshObject = CreateTempGameobject("TrapezoidMesh", mOceanMeshRoot.transform);
                    mTrapezoidMeshObject.layer = LayerMask.NameToLayer("Water");
                    mTrapezoidMeshObject.AddComponent<MeshFilter>();
                    mTrapezoidMeshObject.AddComponent<MeshRenderer>();
                }

                mTrapezoidMeshObject.GetComponent<MeshFilter>().sharedMesh = mTrapezoidMesh;
                mTrapezoidMeshObject.GetComponent<MeshRenderer>().sharedMaterial = mOceanMaterital;
            }
        }

        #endregion


        /// <summary>
        /// 对象销毁
        /// </summary>
        /// <param name="components"></param>
        public static void SafeDestroy(params UnityEngine.Object[] components)
        {
            if (!Application.isPlaying)
            {
                foreach (var component in components)
                {
                    if (component != null)
                    {
                        DestroyImmediate(component);
                    }
                }
            }
            else
            {
                foreach (var component in components)
                {
                    if (component != null)
                    {
                        Destroy(component);
                    }
                }
            }
        }
    }
}