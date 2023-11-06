using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace TCOcean.InfiniteOceanSystem
{
    public class TCInfiniteOceanSystem_CircleMesh : MonoBehaviour
    {
        public float m_FGridSize = 0; //每个网格单元的边长

        /// <summary>
        /// 生成圆形网格
        /// </summary>
        /// <param name="grid">网格数量</param>
        /// <param name="diameter">圆的直径</param>
        /// <returns></returns>
        public Mesh GeneratorCircle(int grid, float diameter)
        {
            CombineInstance[] combine = new CombineInstance[5];
            combine[0].mesh = GenerateMeshCenter(grid, diameter);
            combine[0].transform = Matrix4x4.identity;

            combine[1].mesh = GenerateMeshTop(grid, diameter); // top
            combine[1].transform = Matrix4x4.identity;
            combine[2].mesh = GenerateMeshTop(grid, diameter); // left
            combine[2].transform = Matrix4x4.Rotate(Quaternion.Euler(0, -90, 0));
            combine[3].mesh = GenerateMeshTop(grid, diameter); // right
            combine[3].transform = Matrix4x4.Rotate(Quaternion.Euler(0, 90, 0));
            combine[4].mesh = GenerateMeshTop(grid, diameter); // bottom
            combine[4].transform = Matrix4x4.Rotate(Quaternion.Euler(0, 180, 0));

            Mesh mesh = new Mesh();
            mesh.CombineMeshes(combine);
            mesh.name = "TCInfiniteMesh_Cricle";
            return mesh;
        }

        /// <summary>
        /// 生成网格中心
        /// </summary>
        /// <param name="grid">网格数量</param>
        /// <param name="diameter">圆的直径</param>
        /// <returns></returns>
        public Mesh GenerateMeshCenter(int grid, float diameter)
        {
            // 生成类似铜钱的形状，中间部分是正方形区域
            float side = diameter / Mathf.Sqrt(2); // 正方形边长
            float halfSide = side * 0.5f;

            int ver = grid + 1;
            int verNum = ver * ver;

            // Build vertices and UVs
            Vector3[] vertices = new Vector3[verNum];
            Vector3[] normals = new Vector3[verNum];
            Vector4[] tangents = new Vector4[verNum];
            Vector2[] uv = new Vector2[verNum];

            Vector2 uvScale = new Vector2(1.0f / grid, 1.0f / grid);
            Vector3 sizeScale = new Vector3(side / grid, 0, side / grid);

            m_FGridSize = side / grid;

            int y = 0;
            int x = 0;
            for (y = 0; y < ver; y++)
            {
                for (x = 0; x < ver; x++)
                {
                    vertices[y * ver + x] = new Vector3(x * sizeScale.x - halfSide, 0.0f, y * sizeScale.z - halfSide);
                    uv[y * ver + x] = Vector2.Scale(new Vector2(x, y), uvScale);
                    normals[y * ver + x] = new Vector3(0.0f, 1.0f, 0.0f);
                    tangents[y * ver + x] = new Vector4(1.0f, 0.0f, 0.0f, -1.0f);
                }
            }

            // Build triangle indices: 3 indices into vertex array for each triangle
            int index = 0;
            int nW = grid + 1;
            int[] triangles = new int[grid * grid * 6];
            for (y = 0; y < grid; y++)
            {
                for (x = 0; x < grid; x++)
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
#if UNITY_2017_3_OR_NEWER
            if (grid > 128) mesh.indexFormat = UnityEngine.Rendering.IndexFormat.UInt32;
#endif
            mesh.vertices = vertices;
            mesh.uv = uv;
            mesh.normals = normals;
            mesh.tangents = tangents;
            mesh.triangles = triangles;

            vertices = null;
            tangents = null;
            uv = null;
            return mesh;
        }


        public Mesh GenerateMeshTop(int grid, float diameter)
        {
            if (grid % 2 == 1)
                grid += 1; // 限制为偶数格

            // 生成类似铜钱的形状，中间部分是正方形区域
            float radius = diameter * 0.5f; // 半径
            float side = diameter / Mathf.Sqrt(2); // 正方形边长
            float halfSide = side * 0.5f;

            float segmentsAngle = 90.0f / grid; // 一格划分的角度

            int ver = grid + 1;
            int verNum = ver * 2;

            // Build vertices and UVs
            Vector3[] vertices = new Vector3[verNum];
            Vector3[] normals = new Vector3[verNum];
            Vector4[] tangents = new Vector4[verNum];

            Vector2 uvScale = new Vector2(1.0f / grid, 1.0f / grid);
            Vector3 sizeScale = new Vector3(side / grid, 0, side / grid);

            Vector3 dir = new Vector3(0, 0, radius);

            int count = 0;
            for (int i = 0; i < ver; i++)
            {
                Vector3 v1 = new Vector3(i * sizeScale.x - halfSide, 0.0f, halfSide);

                float angle = -45 + i * segmentsAngle;
                float x = Mathf.Sin(Mathf.Deg2Rad * angle) * radius;
                float z = Mathf.Cos(Mathf.Deg2Rad * angle) * radius;
                Vector3 v2 = new Vector3(x, 0, z);

                vertices[count] = v1;
                normals[count] = new Vector3(0.0f, 1.0f, 0.0f);
                tangents[count] = new Vector4(1.0f, 0.0f, 0.0f, -1.0f);
                count++;

                vertices[count] = v2;
                normals[count] = new Vector3(0.0f, 1.0f, 0.0f);
                tangents[count] = new Vector4(1.0f, 0.0f, 0.0f, -1.0f);
                count++;
            } //end for

            // Build triangle indices: 3 indices into vertex array for each triangle
            int index = 0;
            int[] triangles = new int[grid * 6];
            for (int i = 0; i < grid; i++)
            {
                // For each grid cell output two triangles
                triangles[index++] = i * 2;
                triangles[index++] = i * 2 + 1;
                triangles[index++] = i * 2 + 2;

                triangles[index++] = i * 2 + 2;
                triangles[index++] = i * 2 + 1;
                triangles[index++] = i * 2 + 3;
            }

            Mesh mesh = new Mesh();
#if UNITY_2017_3_OR_NEWER
            if (grid > 128) mesh.indexFormat = UnityEngine.Rendering.IndexFormat.UInt32;
#endif
            mesh.vertices = vertices;
            mesh.normals = normals;
            mesh.tangents = tangents;
            mesh.triangles = triangles;
            return mesh;
        }
    }
}