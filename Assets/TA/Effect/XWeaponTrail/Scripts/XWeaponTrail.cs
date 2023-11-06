using System.Collections.Generic;
using UnityEngine;

namespace XftWeapon {
    public class XWeaponTrail : MonoBehaviour
    {
        #region struct
        public class Element {
            public Vector3 PointStart;
            public Vector3 PointEnd;
            public Vector3 Pos {
                get {
                    return (PointStart + PointEnd) / 2f;
                }
            }

            public Element(Vector3 start, Vector3 end) {
                PointStart = start;
                PointEnd = end;
            }

            public Element() {

            }
        }
        public class ElementPool {
            private readonly Stack<Element> _stack = new Stack<Element>();
            public int CountAll { get; private set; }
            public ElementPool(int preCount) {
                for (int i = 0; i < preCount; i++) {
                    Element element = new Element();
                    _stack.Push(element);
                    CountAll++;
                }
            }

            public Element Get() {
                Element element;
                if (_stack.Count == 0) {
                    element = new Element();
                    CountAll++;
                } else {
                    element = _stack.Pop();
                }
                return element;
            }

            public void Release(Element element) {
                if (_stack.Count > 0 && ReferenceEquals(_stack.Peek(), element)) {
                    Debug.LogError("Internal error. Trying to destroy object that is already released to pool.");
                }
                _stack.Push(element);
            }
        }
        #endregion

        public enum TrailType
        {
            Follow = 0, //跟随
            Circle = 1, //圆形
        }

        public TrailType type = TrailType.Follow;
                
        public float Angle;
        public float Radius = 0.2f;
        public Vector3 CharacterPos;
        public Vector3 CharacterForward;
        public Vector3 HeadStartWorldPos;
        public Vector3 TailStartWorldPos;
        public Vector3 HeadEndWorldPos;
        public Vector3 TailEndWorldPos;

        public float Diversion;

        Vector3 mHeadStartWorldPos;
        Vector3 mTailStartWorldPos;
        Vector3 mHeadEndWorldPos;
        Vector3 mTailEndWorldPos;
        Vector3 mCenterPoint;
        Vector3 mAxis;

        public float StartTime = 0f;
        public float SpanTime = 5f;
        public float FadeTime = 0.2f;
        float EndTime;

        public int MaxFrame = 20;
        public int Granularity = 20;
        public Gradient MyGradient;
        public Material MyMaterial;
        public Material HeatMaterial;

        public float CenterPointOffset;
        public Transform CharacterPoint;
        public Transform MeshStartPoint;
        public Transform MeshEndPoint;
        public bool UseWithSRP = false;

        float mTrailWidth = 0f;
        List<Element> mSnapshotList = new List<Element>();
        ElementPool mElemPool;
        Spline mSpline = new Spline();
        float mFadeT = 1f;
        bool mIsFading = false;
        bool mIsEnd = false;
        float mElapsedTime = 0f;
        float mFadeElapsedime = 0f;
        VertexPool mVertexPool;
        VertexPool.VertexSegment mVertexSegment;
        bool mInited = false;
        int Fps = 60;
        
        Vector3 meshHeadStartLocalPos;
        Vector3 meshTailStartLocalPos;

        public float UpdateInterval {
            get {
                return 1f / Fps;
            }
        }
        public Vector3 CurHeadPos {
            get { return (MeshStartPoint.position + MeshEndPoint.position) / 2f; }
        }

        public void OnEnable()
        {
            mInited = false;
            mFadeT = 1f;
            mIsFading = false;
            mIsEnd = false;
            mFadeElapsedime = 0f;
            mElapsedTime = 0f;
            currentTime = 0f;
            EndTime = StartTime + SpanTime;
        }

        public void OnDisable()
        {
            if (type == TrailType.Circle)
            {
                MeshStartPoint.localPosition = meshHeadStartLocalPos;
                MeshEndPoint.localPosition = meshTailStartLocalPos;
            }
            if (mVertexPool != null)
                mVertexPool.SetMeshObjectActive(false);
        }

        //主逻辑
        public float TotalTimeScale = 1f;
        public float currentTime = 0;
        int oldGranularity = -1;
        void LateUpdate() 
        {
            if(Application.isPlaying)
            {
                currentTime += Time.deltaTime* TotalTimeScale;
            }
                        
            if(currentTime < StartTime || mIsEnd)
            {
                return;
            }
            else if(currentTime > EndTime)
            {
                mIsFading = true;
            }

            if(!mInited)
            {
                mInited = true;

                if (MeshStartPoint == null)
                {
                    MeshStartPoint = this.transform.Find("StartPoint");
                }
                if (MeshEndPoint == null)
                {
                    MeshEndPoint = this.transform.Find("EndPoint");
                }

                if(type == TrailType.Circle)
                {
                    meshHeadStartLocalPos = MeshStartPoint.localPosition;
                    meshTailStartLocalPos = MeshEndPoint.localPosition;


                    Vector3 currentPos = CharacterPoint.position;
                    Vector3 currentForward = CharacterPoint.forward;

                    Vector3 move = currentPos - CharacterPos;
                    mHeadStartWorldPos = HeadStartWorldPos + move;
                    mTailStartWorldPos = TailStartWorldPos + move;
                    mHeadEndWorldPos = HeadEndWorldPos + move;
                    mTailEndWorldPos = TailEndWorldPos + move;

                    float angle = Vector3.Angle(CharacterForward, currentForward) * (Vector3.Cross(CharacterForward, currentForward).y > 0 ? 1 : -1) ;

                    mHeadStartWorldPos = RotateAxis(mHeadStartWorldPos, currentPos, CharacterPoint.up, angle);
                    mTailStartWorldPos = RotateAxis(mTailStartWorldPos, currentPos, CharacterPoint.up, angle);
                    mHeadEndWorldPos = RotateAxis(mHeadEndWorldPos, currentPos, CharacterPoint.up, angle);
                    mTailEndWorldPos = RotateAxis(mTailEndWorldPos, currentPos, CharacterPoint.up, angle);

                    CalculateAxisAndAngle();

                    MeshStartPoint.position = mHeadEndWorldPos;
                    MeshStartPoint.RotateAround(mCenterPoint, mAxis,  -Angle);

                    MeshEndPoint.position = mTailEndWorldPos;
                    MeshEndPoint.RotateAround(mCenterPoint, mAxis, -Angle);
                }

                mElemPool = new ElementPool(MaxFrame);
                mTrailWidth = (MeshStartPoint.position - MeshEndPoint.position).magnitude;
                InitMeshObj();
                InitOriginalElements();
                InitSpline();

                //reset all elemts to head pos.
                for (int i = 0; i < mSnapshotList.Count; i++) {
                    mSnapshotList[i].PointStart = MeshStartPoint.position;
                    mSnapshotList[i].PointEnd = MeshEndPoint.position;

                    mSpline.ControlPoints[i].Position = mSnapshotList[i].Pos;
                    mSpline.ControlPoints[i].Normal = mSnapshotList[i].PointEnd - mSnapshotList[i].PointStart;
                }

                //reset vertex too.
                RefreshSpline();
                UpdateVertex();
            }
            // else
            // {
            //     if(type == TrailType.Circle)
            //     {
            //         meshHeadStartLocalPos = MeshStartPoint.localPosition;
            //         meshTailStartLocalPos = MeshEndPoint.localPosition;


            //         Vector3 currentPos = CharacterPoint.position;
            //         Vector3 currentForward = CharacterPoint.forward;

            //         Vector3 move = currentPos - CharacterPos;
            //         mHeadStartWorldPos = HeadStartWorldPos + move;
            //         mTailStartWorldPos = TailStartWorldPos + move;
            //         mHeadEndWorldPos = HeadEndWorldPos + move;
            //         mTailEndWorldPos = TailEndWorldPos + move;

            //         float angle = Vector3.Angle(CharacterForward, currentForward) * (Vector3.Dot(CharacterForward, currentForward) < 0 ? -1 : 1) ;
            //         mHeadStartWorldPos = RotateAxis(mHeadStartWorldPos, currentPos, CharacterPoint.up, angle);
            //         mTailStartWorldPos = RotateAxis(mTailStartWorldPos, currentPos, CharacterPoint.up, angle);
            //         mHeadEndWorldPos = RotateAxis(mHeadEndWorldPos, currentPos, CharacterPoint.up, angle);
            //         mTailEndWorldPos = RotateAxis(mTailEndWorldPos, currentPos, CharacterPoint.up, angle);

            //         CalculateAxisAndAngle();

            //         MeshStartPoint.position = mHeadEndWorldPos;
            //         MeshStartPoint.RotateAround(mCenterPoint, mAxis,  -Angle);

            //         MeshEndPoint.position = mTailEndWorldPos;
            //         MeshEndPoint.RotateAround(mCenterPoint, mAxis, -Angle);
            //     }

            // }

            if(Granularity != oldGranularity)
            {
                InitMeshObj();
                oldGranularity = Granularity;
            }

            MyPreRender();
            MyPostRender();
        }


        //Circle 计算垂直轴，半径，旋转角度，中心点
        void CalculateAxisAndAngle()
        {
            Vector3 dir1 = (mHeadStartWorldPos - mTailStartWorldPos).normalized;
            Vector3 dir2 = (mHeadEndWorldPos - mTailEndWorldPos).normalized;
            mAxis = Vector3.Cross(dir1, dir2);
            Angle = Vector3.Angle(dir1, dir2) - 360;

            Vector3 dir = mTailEndWorldPos - mHeadEndWorldPos;
            mCenterPoint = (dir) * Radius + mTailEndWorldPos + new Vector3(0, CenterPointOffset, 0);
            mAxis = RotateAxis(mAxis, Vector3.zero, dir, Diversion);
        }

        Vector3 RotateAxis(Vector3 source, Vector3 point, Vector3 axis, float angle)
        {
            source -= point;
            Quaternion q = Quaternion.AngleAxis(angle, axis);
            return q * source + point;
        }

        public void MyPreRender() {

            if (!mInited)
                return;
            mElapsedTime += Time.deltaTime* TotalTimeScale;

            // 更新拖尾头位置
            UpdateHeadElem();

            if (mElapsedTime > UpdateInterval) {
                mElapsedTime = 0f;
                RecordCurElem();
            }

            RefreshSpline();
            UpdateFade();           
            UpdateVertex();
        }

        public void MyPostRender() {
            if (!mInited)
                return;

            mVertexPool.SetMeshObjectActive(true);
            mVertexPool.LateUpdate();
        }

        void OnDestroy() {
            if (!mInited || mVertexPool == null) {
                return;
            }
            mVertexPool.Destroy();
        }

        #region local methods

        void InitSpline() {
            mSpline.Granularity = Granularity;

            mSpline.Clear();

            for (int i = 0; i < MaxFrame; i++) {
                mSpline.AddControlPoint(CurHeadPos, MeshStartPoint.position - MeshEndPoint.position);
            }
        }

        void RefreshSpline() {
            for (int i = 0; i < mSnapshotList.Count; i++) {
                mSpline.ControlPoints[i].Position = mSnapshotList[i].Pos;
                mSpline.ControlPoints[i].Normal = mSnapshotList[i].PointEnd - mSnapshotList[i].PointStart;
            }

            mSpline.RefreshSpline();
        }

        
        void UpdateVertex() {

            VertexPool pool = mVertexSegment.Pool;

            Color c = GetCurGradientColor();
            for (int i = 0; i < Granularity; i++) {
                int baseIdx = mVertexSegment.VertStart + i * 3;

                float uvSegment = (float) i / Granularity;

                float fadeT = uvSegment * mFadeT;

                Vector2 uvCoord = Vector2.zero;

                Vector3 pos = mSpline.InterpolateByLen(fadeT);
                Vector3 up = mSpline.InterpolateNormalByLen(fadeT);
                Vector3 pos0 = pos + (up.normalized * mTrailWidth * 0.5f);
                Vector3 pos1 = pos - (up.normalized * mTrailWidth * 0.5f);

                // pos0
                pool.Vertices[baseIdx] = pos0;
                pool.Colors[baseIdx] = c;
                uvCoord.x = 0f;
                uvCoord.y = uvSegment;
                pool.UVs[baseIdx] = uvCoord;

                //pos
                pool.Vertices[baseIdx + 1] = pos;
                pool.Colors[baseIdx + 1] = c;
                uvCoord.x = 0.5f;
                uvCoord.y = uvSegment;
                pool.UVs[baseIdx + 1] = uvCoord;

                //pos1
                pool.Vertices[baseIdx + 2] = pos1;
                pool.Colors[baseIdx + 2] = c;
                uvCoord.x = 1f;
                uvCoord.y = uvSegment;
                pool.UVs[baseIdx + 2] = uvCoord;
            }

            mVertexSegment.Pool.UVChanged = true;
            mVertexSegment.Pool.VertChanged = true;
            mVertexSegment.Pool.ColorChanged = true;
        }

        void UpdateIndices() {

            VertexPool pool = mVertexSegment.Pool;

            for (int i = 0; i < Granularity - 1; i++) {
                int baseIdx = mVertexSegment.VertStart + i * 3;
                int nextBaseIdx = mVertexSegment.VertStart + (i + 1) * 3;
                int iidx = mVertexSegment.IndexStart + i * 12;

                //triangle left
                pool.Indices[iidx + 0] = nextBaseIdx;
                pool.Indices[iidx + 1] = nextBaseIdx + 1;
                pool.Indices[iidx + 2] = baseIdx;
                pool.Indices[iidx + 3] = nextBaseIdx + 1;
                pool.Indices[iidx + 4] = baseIdx + 1;
                pool.Indices[iidx + 5] = baseIdx;

                //triangle right
                pool.Indices[iidx + 6] = nextBaseIdx + 1;
                pool.Indices[iidx + 7] = nextBaseIdx + 2;
                pool.Indices[iidx + 8] = baseIdx + 1;
                pool.Indices[iidx + 9] = nextBaseIdx + 2;
                pool.Indices[iidx + 10] = baseIdx + 2;
                pool.Indices[iidx + 11] = baseIdx + 1;
            }
            pool.IndiceChanged = true;
        }

        void UpdateHeadElem() {

            if (type == TrailType.Circle) // 圆形模式需要对首尾点进行重定位
            {
                float tempTime = currentTime - StartTime;
                float process = Mathf.Min(1, tempTime / SpanTime);

                MeshStartPoint.position = mHeadEndWorldPos;
                MeshStartPoint.RotateAround(mCenterPoint, mAxis, ( 1-process) * -Angle);

                MeshEndPoint.position = mTailEndWorldPos;
                MeshEndPoint.RotateAround(mCenterPoint, mAxis, (1- process) * -Angle);

                mSnapshotList[0].PointStart = MeshStartPoint.position;
                mSnapshotList[0].PointEnd = MeshEndPoint.position;
            }
            else if (type == TrailType.Follow)
            {
                mSnapshotList[0].PointStart = MeshStartPoint.position;
                mSnapshotList[0].PointEnd = MeshEndPoint.position;
            }
        }

        void UpdateFade() {
            if (!mIsFading)
                return;

            mFadeElapsedime += Time.deltaTime* TotalTimeScale;

            float t = mFadeElapsedime / FadeTime;
            mFadeT = 1f - t;
            if (mFadeT < 0.01f) {
                mIsEnd = true;
            }
        }

        void RecordCurElem() {
            //TODO: use element pool to avoid gc alloc.
            //Element elem = new Element(PointStart.position, PointEnd.position);

            Element elem = mElemPool.Get();
            elem.PointStart = MeshStartPoint.position;
            elem.PointEnd = MeshEndPoint.position;

            if (mSnapshotList.Count < MaxFrame) {
                mSnapshotList.Insert(1, elem);
            } else {
                mElemPool.Release(mSnapshotList[mSnapshotList.Count - 1]);
                mSnapshotList.RemoveAt(mSnapshotList.Count - 1);
                mSnapshotList.Insert(1, elem);
            }
        }

        void InitOriginalElements() {
            mSnapshotList.Clear();
            //at least add 2 original elements
            mSnapshotList.Add(new Element(MeshStartPoint.position, MeshEndPoint.position));
            mSnapshotList.Add(new Element(MeshStartPoint.position, MeshEndPoint.position));
        }

        void InitMeshObj() {
            //init vertexpool
            mVertexPool = new VertexPool(MyMaterial, HeatMaterial, this);
            mVertexSegment = mVertexPool.GetVertices(Granularity * 3, (Granularity - 1) * 12);
            UpdateIndices();
        }
        
        Color GetCurGradientColor()
        {
            float t = (currentTime - StartTime) / (EndTime + FadeTime - StartTime);
            return MyGradient.Evaluate(t);
        }

        #endregion

    }

}