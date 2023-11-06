using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

namespace TCOcean.InfiniteOceanSystem
{
    public partial class TCInfiniteOceanSystem
    {
        /// <summary>
        /// 刷新海水网格位置
        /// </summary>
        /// <param name="camera">摄像机位置</param>
        /// <param name="planeMesh">海水网格位置</param>
        public void UpdatePositionPlaneMesh(Camera camera, Transform planeMesh)
        {
            //计算相机移动量
            Vector3 myVCenter = camera.transform.position;
            myVCenter.y = m_TCOceanPreset.m_OceanLevel;
            //计算出当前相机偏移了多少个网格单位，计算出所有网格单位的距离，重新赋值给网格位置。
            int x = (int)(myVCenter.x / mPlaneMeshClass.m_FGridSize);
            int z = (int)(myVCenter.z / mPlaneMeshClass.m_FGridSize);
            myVCenter.x = x * mPlaneMeshClass.m_FGridSize;
            myVCenter.z = z * mPlaneMeshClass.m_FGridSize;
            planeMesh.position = myVCenter;
            // Vector3 pos = planeMesh.position;
            // //相对相机位置
            // Vector3 relativeToCamPos = new Vector3(camerapos.x, pos.y, camerapos.z);
            // if (Vector3.Distance(pos, relativeToCamPos) > 10f)
            // {
            //     planeMesh.position = relativeToCamPos;
            // }
        }

        /// <summary>
        /// 刷新海水网格位置
        /// </summary>
        public void UpdatePositionCricleTrapezoidMesh(Camera camera, Transform cricleMesh, Transform trapezoidMesh)
        {
            //计算相机旋转角
            Vector3 myVAngles = camera.transform.localEulerAngles;
            myVAngles.x = 0f;
            myVAngles.z = 0f;
            //计算相机移动量
            Vector3 myVCenter = camera.transform.position;
            myVCenter.y = m_TCOceanPreset.m_OceanLevel;
            //计算出当前相机偏移了多少个网格单位，计算出所有网格单位的距离，重新赋值给网格位置。
            int x = (int)(myVCenter.x / mCircleMeshClass.m_FGridSize);
            int z = (int)(myVCenter.z / mCircleMeshClass.m_FGridSize);
            myVCenter.x = x * mCircleMeshClass.m_FGridSize;
            myVCenter.z = z * mCircleMeshClass.m_FGridSize;
            cricleMesh.position = myVCenter;
            trapezoidMesh.position = myVCenter;
            //计算出当前相机旋转偏移了多少个网格单位，计算出所有网格单位的弧长距离，重新赋值给网格旋转角度。
            int myTAngle = (int)(myVAngles.y / mTrapezoidMeshClass.m_FSegmentsAngle);
            myVAngles.y = myTAngle * mTrapezoidMeshClass.m_FSegmentsAngle;
            trapezoidMesh.localEulerAngles = myVAngles;
        }
    }
}