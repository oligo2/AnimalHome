#if UNITY_EDITOR
using System;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEditor.Rendering;
using UnityEngine;

namespace TCOcean.InfiniteOceanSystem
{
    [CustomEditor(typeof(TCInfiniteOceanSystem))]
    public class TCInfiniteOceanSystemInspector : Editor
    {
        private Texture2D mButtonTex;
        private GUIStyle mButtonStyle;
        private GUIStyle mHelpBoxStyle;
        private GUIStyle mNotesLabelStyleFade;
        private GUIStyle mNotesLabelStyle;

        // private bool isActive = false;
        private const string mEditorPrefKey = "TCInfiniteOceanSystem";
        private bool mShowMeshSetting;
        private bool mShowWaveFormSetting;


        private TCInfiniteOceanSystem mTCOceanSystem;
        private SerializedObject mSerializedObject2;
        private SerializedProperty mTCOceanPreset;

        //网格设置
        private SerializedProperty mOceanLevel;
        private SerializedProperty mTCOceanMeshType;
        private SerializedProperty mPlaneMeshQualityWeights;
        private SerializedProperty mPlaneMeshDoMainSize;
        private SerializedProperty mCircleGridNumber;
        private SerializedProperty mTrapezoidalUpperLine;

        //网格设置 — 曲面细分
        private SerializedProperty mUseTesselation;
        private SerializedProperty mMateritalUnableTesselation;
        private SerializedProperty mMateritalAbleTesselation;
        private SerializedProperty mTesselationFactorWeights;
        private SerializedProperty mTesselationMaxFactor;
        private SerializedProperty mTesselationMaxDistance;

        //波形设置
        private SerializedProperty mTCOceanWaveFormType;
        private SerializedProperty mGerstnerWaveCount;
        private SerializedProperty mGerstnerWaveAmplitude;
        private SerializedProperty mGerstnerWaveDirection;
        private SerializedProperty mGerstnerWaveLength;
        private SerializedProperty mGerstnerWaveRandomSeed;


        protected void OnInit()
        {
            var o = new PropertyFetcher<TCInfiniteOceanSystemObject>(mSerializedObject2);
            //网格设置
            mOceanLevel = o.Find(x => x.m_OceanLevel);
            mTCOceanMeshType = o.Find(x => x.m_TCOceanMeshType);
            mPlaneMeshQualityWeights = o.Find(x => x.m_PlaneMeshQualityWeights);
            mPlaneMeshDoMainSize = o.Find(x => x.m_PlaneMeshDoMainSize);
            mCircleGridNumber = o.Find(x => x.m_CircleGridNumber);
            mTrapezoidalUpperLine = o.Find(x => x.m_TrapezoidalUpperLine);
            //网格设置 — 曲面细分
            mUseTesselation = o.Find(x => x.m_UseTesselation);
            mMateritalUnableTesselation = o.Find(x => x.m_MateritalUnableTesselation);
            mMateritalAbleTesselation = o.Find(x => x.m_MateritalAbleTesselation);
            mTesselationFactorWeights = o.Find(x => x.m_TesselationFactorWeights);
            mTesselationMaxFactor = o.Find(x => x.m_TesselationMaxFactor);
            mTesselationMaxDistance = o.Find(x => x.m_TesselationMaxDistance);
            //波形设置
            mTCOceanWaveFormType = o.Find(x => x.m_TCOceanWaveFormType);
            mGerstnerWaveCount = o.Find(x => x.m_GerstnerWaveCount);
            mGerstnerWaveAmplitude = o.Find(x => x.m_GerstnerWaveAmplitude);
            mGerstnerWaveDirection = o.Find(x => x.m_GerstnerWaveDirection);
            mGerstnerWaveLength = o.Find(x => x.m_GerstnerWaveLength);
            mGerstnerWaveRandomSeed = o.Find(x => x.m_GerstnerWaveRandomSeed);
        }

        private void OnEnable()
        {
            var myFetcher = new PropertyFetcher<TCInfiniteOceanSystem>(serializedObject);
            mTCOceanPreset = myFetcher.Find(x => x.m_TCOceanPreset);
            mSerializedObject2 = new SerializedObject(mTCOceanPreset.objectReferenceValue);
            OnInit();
        }

        public override void OnInspectorGUI()
        {
            mTCOceanSystem = (TCInfiniteOceanSystem)target;
            if (mButtonStyle == null)
            {
                InitializeStyles();
            }

            EditorGUILayout.BeginVertical(EditorStyles.helpBox);
            {
                serializedObject.Update();
                EditorGUILayout.PropertyField(mTCOceanPreset, Styles.mTCOceanPreset);
                serializedObject.ApplyModifiedProperties();

                if (mTCOceanSystem.m_TCOceanPreset == null)
                {
                    EditorGUILayout.HelpBox(Styles.mNoVolumeMessage, MessageType.Error);
                    EditorGUILayout.EndVertical();
                    return;
                }
            }
            EditorGUILayout.EndVertical();
            mShowMeshSetting = GetFoldoutState("MeshSetting");
            AddMeshSetting();
            mShowWaveFormSetting = GetFoldoutState("WaveFormSetting");
            AddWaveFormSetting();
        }

        void AddMeshSetting()
        {
            EditorGUILayout.BeginVertical(EditorStyles.helpBox);
            EditorGUILayout.BeginHorizontal(mButtonStyle);
            EditorGUILayout.LabelField("", GUILayout.MaxWidth(10));
            var myMeshSetting = EditorGUILayout.Foldout(mShowMeshSetting, Styles.mMeshSetting, true);
            SetFoldoutState("MeshSetting", mShowMeshSetting, myMeshSetting);
            EditorGUILayout.EndHorizontal();
            if (myMeshSetting)
            {
                mSerializedObject2.Update();
                EditorGUI.BeginChangeCheck();
                EditorGUILayout.PropertyField(mOceanLevel, Styles.mOceanLevel);
                EditorGUILayout.PropertyField(mTCOceanMeshType, Styles.mTCOceanMeshType);
                switch (mTCOceanSystem.m_TCOceanPreset.m_TCOceanMeshType)
                {
                    case TCInfiniteOceanSystemObject.TCOceanMeshTypeEnum.InfinitePlane:
                        EditorGUILayout.PropertyField(mPlaneMeshQualityWeights, Styles.mPlaneMeshQualityWeights);
                        EditorGUILayout.PropertyField(mPlaneMeshDoMainSize, Styles.mPlaneMeshDoMainSize);
                        break;

                    case TCInfiniteOceanSystemObject.TCOceanMeshTypeEnum.CircleTrapezoid:
                        EditorGUILayout.PropertyField(mCircleGridNumber, Styles.mCircleGridNumber);
                        EditorGUILayout.PropertyField(mTrapezoidalUpperLine, Styles.mTrapezoidalUpperLiner);
                        break;
                }

                if (EditorGUI.EndChangeCheck())
                {
                    mTCOceanSystem.InitializeMesh();
                }

                EditorGUI.BeginChangeCheck();
                EditorGUILayout.PropertyField(mUseTesselation, Styles.mUseTesselation);
                if (mTCOceanSystem.m_TCOceanPreset.m_UseTesselation)
                {
                    EditorGUILayout.PropertyField(mMateritalAbleTesselation, Styles.mMateritalAbleTesselation);
                    EditorGUI.indentLevel++;
                    {
                        EditorGUILayout.PropertyField(mTesselationFactorWeights, Styles.mTesselationFactorWeights);
                        EditorGUILayout.PropertyField(mTesselationMaxFactor, Styles.mTesselationMaxFactor);
                        EditorGUILayout.PropertyField(mTesselationMaxDistance, Styles.mTesselationMaxDistance);
                    }
                    EditorGUI.indentLevel--;
                }
                else
                {
                    EditorGUILayout.PropertyField(mMateritalUnableTesselation, Styles.mMateritalUnableTesselation);
                }

                if (EditorGUI.EndChangeCheck())
                {
                    mTCOceanSystem.InitializeMaterial();
                }

                mSerializedObject2.ApplyModifiedProperties();
            }

            EditorGUILayout.EndVertical();
        }

        void AddWaveFormSetting()
        {
            EditorGUILayout.BeginVertical(EditorStyles.helpBox);
            EditorGUILayout.BeginHorizontal(mButtonStyle);
            EditorGUILayout.LabelField("", GUILayout.MaxWidth(10));
            var myWaveFormSetting = EditorGUILayout.Foldout(mShowWaveFormSetting, Styles.mWaveFormSetting, true);
            SetFoldoutState("WaveFormSetting", mShowWaveFormSetting, myWaveFormSetting);
            EditorGUILayout.EndHorizontal();
            if (myWaveFormSetting)
            {
                mSerializedObject2.Update();
                EditorGUI.BeginChangeCheck();
                EditorGUILayout.PropertyField(mTCOceanWaveFormType, Styles.mTCOceanWaveFormType);

                switch (mTCOceanSystem.m_TCOceanPreset.m_TCOceanWaveFormType)
                {
                    case TCInfiniteOceanSystemObject.TCOceanWaveFormTypeEnum.Gerstner:
                        EditorGUI.indentLevel++;
                    {
                        EditorGUILayout.PropertyField(mGerstnerWaveCount, Styles.mGerstnerWaveCount);
                        EditorGUILayout.PropertyField(mGerstnerWaveAmplitude, Styles.mGerstnerWaveAmplitude);
                        EditorGUILayout.PropertyField(mGerstnerWaveDirection, Styles.mGerstnerWaveDirection);
                        EditorGUILayout.PropertyField(mGerstnerWaveLength, Styles.mGerstnerWaveLength);
                        EditorGUILayout.BeginHorizontal();
                        {
                            EditorGUILayout.PropertyField(mGerstnerWaveRandomSeed, Styles.mGerstnerWaveRandomSeed);
                            var myButtom = GUILayout.Button(new GUIContent("Random"));
                            if (myButtom)
                            {
                                mGerstnerWaveRandomSeed.intValue = DateTime.Now.Millisecond * 100 - DateTime.Now.Millisecond;
                            }
                        }
                        EditorGUILayout.EndHorizontal();
                    }
                        EditorGUI.indentLevel--;
                        break;
                    case TCInfiniteOceanSystemObject.TCOceanWaveFormTypeEnum.FFT:
                        break;
                }


                if (EditorGUI.EndChangeCheck())
                {
                    mTCOceanSystem.InitializeMaterial();
                }

                mSerializedObject2.ApplyModifiedProperties();
            }

            EditorGUILayout.EndVertical();
        }


        #region 存储开关状态

        //存储开关状态
        private bool GetFoldoutState(string name)
        {
            // Get value from EditorPrefs
            return EditorPrefs.GetBool($"{mEditorPrefKey}.{name}");
        }

        private void SetFoldoutState(string name, bool field, bool value)
        {
            if (field == value)
                return;

            // Set value to EditorPrefs and field
            EditorPrefs.SetBool($"{mEditorPrefKey}.{name}", value);
        }

        #endregion

        #region Style

        //Style
        private Texture2D CreateTex(int width, int height, Color col)
        {
            Color[] pix = new Color[width * height];

            for (int i = 0; i < pix.Length; i++)
                pix[i] = col;

            Texture2D result = new Texture2D(width, height);
            result.SetPixels(pix);
            result.Apply();

            return result;
        }

        void InitializeStyles()
        {
            mButtonStyle = new GUIStyle();
            mButtonStyle.overflow.left = mButtonStyle.overflow.right = 3;
            mButtonStyle.overflow.top = 2;
            mButtonStyle.overflow.bottom = 0;
            if (mButtonTex == null)
            {
                if (EditorGUIUtility.isProSkin)
                    mButtonTex = CreateTex(32, 32, new Color(80 / 255f, 80 / 255f, 80 / 255f));
                else mButtonTex = CreateTex(32, 32, new Color(171 / 255f, 171 / 255f, 171 / 255f));
            }

            mButtonStyle.normal.background = mButtonTex;

            mHelpBoxStyle = new GUIStyle("button");
            mHelpBoxStyle.alignment = TextAnchor.MiddleCenter;
            mHelpBoxStyle.stretchHeight = false;
            mHelpBoxStyle.stretchWidth = false;

            mNotesLabelStyleFade = new GUIStyle("label");
            mNotesLabelStyleFade.normal.textColor = EditorGUIUtility.isProSkin
                ? new Color(0.75f, 0.75f, 0.75f, 0.5f)
                : new Color(0.1f, 0.1f, 0.1f, 0.3f);

            mNotesLabelStyle = new GUIStyle("label");
            mNotesLabelStyle.normal.textColor = EditorGUIUtility.isProSkin
                ? new Color(0.85f, 0.25f, 0.25f, 0.95f)
                : new Color(0.7f, 0.1f, 0.1f, 0.95f);
        }

        private struct Styles
        {
            public static readonly string mNoVolumeMessage = L10n.Tr("必须存在一个配置文件，如果没有请在Asset下右键创建！");
            public static readonly GUIContent mTCOceanPreset = new GUIContent("Ocean Preset", "海洋配置文件");

            //网格设置
            public static readonly GUIContent mOceanLevel = new GUIContent("Ocean Level", "海平面高度");
            public static readonly GUIContent mMeshSetting = new GUIContent("Mesh Settings", "网格设置");
            public static readonly GUIContent mTCOceanMeshType = new GUIContent("Mesh Type", "网格类型");
            public static readonly GUIContent mPlaneMeshQualityWeights = new GUIContent("Mesh Quality", "网格质量权重");
            public static readonly GUIContent mPlaneMeshDoMainSize = new GUIContent("Mesh DoMain Size", "最中心初始块区域的大小");
            public static readonly GUIContent mCircleGridNumber = new GUIContent("Grid Number", "网格数量");
            public static readonly GUIContent mTrapezoidalUpperLiner = new GUIContent("Trapezoidal Upper Line", "不规则梯形上底大小");

            //网格设置 — 曲面细分
            public static readonly GUIContent mUseTesselation = new GUIContent("Use Tesselation", "使用曲面细分");
            public static readonly GUIContent mMateritalAbleTesselation = new GUIContent("Tesselation Materital", "曲面细分材质");
            public static readonly GUIContent mMateritalUnableTesselation = new GUIContent("Standard Materital", "非曲面细分的标准材质");
            public static readonly GUIContent mTesselationFactorWeights = new GUIContent("Tesselation Factor Weights", "曲面细分权重");
            public static readonly GUIContent mTesselationMaxFactor = new GUIContent("Tesselation Max Factor", "曲面细分最大细分级别");
            public static readonly GUIContent mTesselationMaxDistance = new GUIContent("Tesselation Max Distance", "曲面细分最大距离");

            //波形
            public static readonly GUIContent mWaveFormSetting = new GUIContent("Wave Form Settings", "波形设置");
            public static readonly GUIContent mTCOceanWaveFormType = new GUIContent("Wave Form Type", "波形类型");
            public static readonly GUIContent mGerstnerWaveCount = new GUIContent("Gerstner Wave Count", "Gerstner波型叠加数量");
            public static readonly GUIContent mGerstnerWaveAmplitude = new GUIContent("Gerstner Wave Amplitude", "波形振幅");
            public static readonly GUIContent mGerstnerWaveDirection = new GUIContent("Gerstner Wave Direction", "波形方向");
            public static readonly GUIContent mGerstnerWaveLength = new GUIContent("Gerstner Wave Length", "波长");

            public static readonly GUIContent mGerstnerWaveRandomSeed = new GUIContent("Random Seed", "波形随机种子");
        }

        #endregion
    }
}
#endif