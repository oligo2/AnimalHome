using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace TCOcean.InfiniteOceanSystem
{
    public class TCInfiniteOceanSystem_TrapezoidMesh : MonoBehaviour
    {
        public float m_FSegmentsAngle = 0;//每个网格单元的弧长

        /// <summary>
        /// 生成梯形Mesh
        /// </summary>
        /// <param name="grid">格子数</param>
        /// <param name="xMin">梯形短边</param>
        /// <param name="xMax">梯形长边</param>
        /// <param name="zLen">梯形高</param>
        /// <returns></returns>
        public Mesh GenerateTrapezoid(int grid, float xMin, float xMax, float zLen)
        {
            if (grid % 2 == 1)
                grid += 1; // 限制为偶数格
            grid *= 2; // 中心正方形才是grid，半圆就是grid*2

            float diameter = xMin;
            float radius = diameter * 0.5f; // 半径
            float segmentsAngle = 180.0f / grid; // 一格划分的角度
            m_FSegmentsAngle = segmentsAngle;

            int gridX = grid;
            int gridZ = 3;
            if (gridZ < 1) gridZ = 1;
            int verWidth = gridX + 1;
            int verHeight = gridZ + 1;

            // Build vertices and UVs
            Vector3[] vertices = new Vector3[verHeight * verWidth];
            Vector3[] normals = new Vector3[verHeight * verWidth];
            Vector4[] tangents = new Vector4[verHeight * verWidth];

            float xGridW = xMin / gridX * 2;
            int y = 0;
            int x = 0;
            for (y = 0; y < verHeight; y++)
            {
                float yPos = zLen * (float)y / gridZ;
                //float yPos = zLen * Mathf.Pow((float)y / gridZ, 8);// 密度越远越低
                if (yPos < y * xGridW)
                {
                    // 保证近处密度平均分布
                    yPos = y * xGridW;
                }

                float xTri = (xMax - xMin) / 2;
                float xTriNow = xTri / zLen * yPos;
                float xWidth = xMin + xTriNow * 2;
                float xPos = -xWidth / 2;
                for (x = 0; x < verWidth; x++)
                {
                    Vector3 vertex = new Vector3(x, 0.0f, y);
                    vertex.x = xPos + xWidth * x / gridX;
                    vertex.z = yPos;
                    if (y == 0)
                    {
                        float angle = -90 + x * segmentsAngle;
                        float xT = Mathf.Sin(Mathf.Deg2Rad * angle) * radius;
                        float zT = Mathf.Cos(Mathf.Deg2Rad * angle) * radius;
                        vertex = new Vector3(xT, 0, zT);
                    }

                    vertices[y * verWidth + x] = vertex;
                    normals[y * verWidth + x] = new Vector3(0.0f, 1.0f, 0.0f);
                    tangents[y * verWidth + x] = new Vector4(1.0f, 0.0f, 0.0f, -1.0f);
                }
            }

            // Build triangle indices: 3 indices into vertex array for each triangle
            int index = 0;
            int nW = gridX + 1;
            int[] triangles = new int[gridX * gridZ * 6];
            for (y = 0; y < gridZ; y++)
            {
                for (x = 0; x < gridX; x++)
                {
                    // For each grid cell output two triangles
                    triangles[index++] = (y * nW) + x;
                    triangles[index++] = ((y + 1) * nW) + x;
                    triangles[index++] = (y * nW) + x + 1;

                    triangles[index++] = ((y + 1) * nW) + x;
                    triangles[index++] = ((y + 1) * nW) + x + 1;
                    triangles[index++] = (y * nW) + x + 1;
                }
            }

            Mesh mesh = new Mesh();
            mesh.vertices = vertices;
            mesh.normals = normals;
            mesh.tangents = tangents;
            mesh.triangles = triangles;
            mesh.name = "TCInfiniteMesh_Trapezoid";

            return mesh;
        }
    }
}