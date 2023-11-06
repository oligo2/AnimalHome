using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace TCOcean.InfiniteOceanSystem
{
    public class TCInfiniteOceanSystem_PlaneMesh
    {
        private List<Vector3> vertices = new List<Vector3>();
        private List<Color> colors = new List<Color>();
        private List<int> triangles = new List<int>();
        private static List<Vector3> normals = new List<Vector3>();

        // private static List<Vector4> tangents = new List<Vector4>();
        // private static List<Vector2> uv = new List<Vector2>();
        private bool IsOutFarDistance;
        private float FarDistance;
        private Vector3 GlobalScale;

        public float m_FGridSize = 0; //每个网格单元的边长

        /// <summary>
        /// 无限平面生成
        /// </summary>
        /// <param name="doMainSizeMeters">初始块大小</param>
        /// <param name="doMainQuadsQuantity">初始块内网格数量</param>
        /// <param name="maxSizeMeters">最远距离</param>
        /// <returns></returns>
        public Mesh GeneratorPlane(float doMainSizeMeters, float doMainQuadsQuantityWeights, float maxSizeMeters)
        {
            IsOutFarDistance = false;
            FarDistance = maxSizeMeters;
            GlobalScale = Vector3.one;
            vertices.Clear();
            triangles.Clear();
            colors.Clear();
            int doMainQuadsQuantity = (int)Mathf.Lerp(1f, 9f, doMainQuadsQuantityWeights);
            doMainQuadsQuantity = (doMainQuadsQuantity + 1) * 4;
            m_FGridSize = doMainSizeMeters / doMainQuadsQuantity;
            var offset = CreateStartChunk(doMainSizeMeters, doMainQuadsQuantity);
            var newSize = doMainQuadsQuantity / 2 + 4;
            var count = (int)((doMainQuadsQuantity / 4f));
            var lastCount = newSize - 2;
            do
            {
                var currentScale = count;
                offset += CreateChunk(lastCount + 2, (doMainSizeMeters * 0.5f + offset), currentScale, out lastCount);
            } while (offset * 0.5f < maxSizeMeters);

            var mesh = new Mesh();
            // mesh.indexFormat = IndexFormat.UInt32;
            mesh.vertices = vertices.ToArray();
            mesh.triangles = triangles.ToArray();
            mesh.colors = colors.ToArray();
            mesh.name = "SeaPlane";
            // mesh.normals = normals.ToArray();
            // mesh.tangents = tangents.ToArray();
            // mesh.uv = uv.ToArray();
            return mesh;
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="size"></param>
        /// <param name="startScale"></param>
        /// <param name="count"></param>
        /// <param name="lastCount"></param>
        /// <returns></returns>
        private float CreateChunk(int size, float startScale, int count, out int lastCount)
        {
            float scaleOffset = 0;
            for (int i = 0; i < count; i++)
            {
                if (i < count - 1)
                {
                    var newSize = size + 2 * i;
                    scaleOffset += 1f / (size - 2) * startScale * 2;
                    AddRing(newSize, startScale + scaleOffset);
                }
                else
                {
                    int newSize = (size + 2 * i) / 2 + 1;
                    scaleOffset += 1f / (size - 2) * startScale * 4;
                    AddRing(newSize, (startScale + scaleOffset), true);
                }
            }

            lastCount = (size + 2 * (count - 1)) / 2 + 1;
            return scaleOffset;
        }


        /// <summary>
        /// 
        /// </summary>
        /// <param name="doMainSizeMeters">初始块大小</param>
        /// <param name="doMainQuadsQuantity">网格质量</param>
        /// <returns></returns>
        private float CreateStartChunk(float doMainSizeMeters, int doMainQuadsQuantity)
        {
            var halfsize = doMainQuadsQuantity / 2;
            float quadLength = doMainSizeMeters / doMainQuadsQuantity;
            for (int i = 0; i < halfsize; i++)
            {
                AddRing(doMainQuadsQuantity - i * 2, doMainSizeMeters * 0.5f - quadLength * i, false);
            }

            var offest = quadLength * 2;
            AddRing(halfsize + 2, doMainSizeMeters * 0.5f + offest, true);
            return offest;
        }

        private void AddRing(int size, float scale, bool isTripple = false)
        {
            if (IsOutFarDistance)
            {
                return;
            }

            if (IsOutFarDistance == false && scale * 0.5f > FarDistance)
            {
                IsOutFarDistance = true;
            }


            int x, y = 0;
            for (x = 0; x < size; x++)
                CreateQuad(size, scale, x, y, Side.Down, isTripple, Color.black);

            x = size - 1;
            for (y = 1; y < size; y++)
                CreateQuad(size, scale, x, y, Side.Right, isTripple, Color.black);

            y = size - 1;
            for (x = size - 2; x >= 0; x--)
                CreateQuad(size, scale, x, y, Side.Up, isTripple, Color.black);

            x = 0;
            for (y = size - 2; y > 0; y--)
                CreateQuad(size, scale, x, y, Side.Left, isTripple, Color.black);
        }

        private void CreateQuad(int size, float scale, int x, int y, Side side, bool isTripple, Color color)
        {
            var offset = (1f / size) * GlobalScale * scale;
            var position = new Vector3((x / (float)size - 0.5f) * GlobalScale.x, 0,
                (y / (float)size - 0.5f) * GlobalScale.z) * scale;

            var leftBottomIndex = AddPoint(position, color);
            var rightBottomIndex = AddPoint(position + new Vector3(offset.x, 0, 0), color);
            var rightUpIndex = AddPoint(position + new Vector3(0, 0, offset.z), color);
            var leftUpIndex = AddPoint(position + new Vector3(offset.x, 0, offset.z), color);
            if (isTripple)
            {
                if (Mathf.Abs(x - y) == size - 1 || Mathf.Abs(x - y) == 0) side = Side.Fringe;
                AddTripplePoint(side, leftBottomIndex, rightBottomIndex, rightUpIndex,
                    leftUpIndex, position, offset, color);
            }
            else
            {
                AddQuadIndexes(leftBottomIndex, rightBottomIndex, rightUpIndex, leftUpIndex);
            }
        }

        enum Side
        {
            Down,
            Right,
            Up,
            Left,
            Fringe
        }

        private int AddPoint(Vector3 position, Color color)
        {
            vertices.Add(position);
            if (color != null) colors.Add(color);
            // normals.Add(normal);
            return vertices.Count - 1;
        }

        private void AddTripplePoint(Side side, int leftBottomIndex, int rightBottomIndex, int rightUpIndex,
            int leftUpIndex, Vector3 position, Vector3 offset, Color color)
        {
            int middleIndex;
            if (side == Side.Fringe)
            {
                AddQuadIndexes(leftBottomIndex, rightBottomIndex, rightUpIndex, leftUpIndex);
                return;
            }

            if (side == Side.Down)
            {
                middleIndex = AddPoint(position + new Vector3(offset.x / 2f, 0, offset.z), color);
                AddTripleIndexesDown(leftBottomIndex, rightBottomIndex, rightUpIndex, leftUpIndex, middleIndex);
            }

            if (side == Side.Right)
            {
                middleIndex = AddPoint(position + new Vector3(0, 0, offset.z / 2), color);
                AddTripleIndexesRight(leftBottomIndex, rightBottomIndex, rightUpIndex, leftUpIndex, middleIndex);
            }

            if (side == Side.Up)
            {
                middleIndex = AddPoint(position + new Vector3(offset.x / 2, 0, 0), color);
                AddTripleIndexesUp(leftBottomIndex, rightBottomIndex, rightUpIndex, leftUpIndex, middleIndex);
            }

            if (side == Side.Left)
            {
                middleIndex = AddPoint(position + new Vector3(offset.x, 0, offset.z / 2), color);
                AddTripleIndexesLeft(leftBottomIndex, rightBottomIndex, rightUpIndex, leftUpIndex, middleIndex);
            }
        }

        private void AddQuadIndexes(int index1, int index2, int index3, int index4)
        {
            triangles.Add(index1);
            triangles.Add(index3);
            triangles.Add(index2);
            triangles.Add(index2);
            triangles.Add(index3);
            triangles.Add(index4);
        }

        #region TripleIndexes

        private void AddTripleIndexesDown(int index1, int index2, int index3, int index4, int index5)
        {
            triangles.Add(index3);
            triangles.Add(index5);
            triangles.Add(index1);
            triangles.Add(index1);
            triangles.Add(index5);
            triangles.Add(index2);
            triangles.Add(index5);
            triangles.Add(index4);
            triangles.Add(index2);
        }

        private void AddTripleIndexesRight(int index1, int index2, int index3, int index4, int index5)
        {
            triangles.Add(index3);
            triangles.Add(index4);
            triangles.Add(index5);
            triangles.Add(index1);
            triangles.Add(index5);
            triangles.Add(index2);
            triangles.Add(index5);
            triangles.Add(index4);
            triangles.Add(index2);
        }

        private void AddTripleIndexesUp(int index1, int index2, int index3, int index4, int index5)
        {
            triangles.Add(index3);
            triangles.Add(index4);
            triangles.Add(index5);
            triangles.Add(index3);
            triangles.Add(index5);
            triangles.Add(index1);
            triangles.Add(index5);
            triangles.Add(index4);
            triangles.Add(index2);
        }

        private void AddTripleIndexesLeft(int index1, int index2, int index3, int index4, int index5)
        {
            triangles.Add(index3);
            triangles.Add(index4);
            triangles.Add(index5);
            triangles.Add(index1);
            triangles.Add(index5);
            triangles.Add(index2);
            triangles.Add(index3);
            triangles.Add(index5);
            triangles.Add(index1);
        }

        #endregion
    }
}