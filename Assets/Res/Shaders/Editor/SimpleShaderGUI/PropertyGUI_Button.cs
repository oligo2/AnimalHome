using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using UnityEngine.SceneManagement;

//按钮
namespace Scarecrow
{
    public class ButtonDrawer : MaterialPropertyDrawer
    {
        private bool _enbale = true;
        private SimpleShaderGUI _simpleShaderGUI;
        private string[] _showList = new string[0];

        public ButtonDrawer()
        {

        }
        public ButtonDrawer(params string[] showList)
        {
            _showList = showList;
        }


        public override void Apply(MaterialProperty prop)
        {
            base.Apply(prop);

            // //初始化关键字,并设置列表
            // if (prop.type == MaterialProperty.PropType.Float)
            // {
            //     _enbale = (int)prop.floatValue == 0 ? false : true;
            //     SetToggleKeyword(prop, _enbale);        
            //     SetToggleSwitch(prop, _enbale);
            // }
        }

        public override float GetPropertyHeight(MaterialProperty prop, string label, MaterialEditor editor)
        {
            return -2;
        }

        Material matLod0;
        Material matLod1;
        Material matLod2;
        public override void OnGUI(Rect position, MaterialProperty prop, string label, MaterialEditor editor)
        {
            _simpleShaderGUI = editor.customShaderGUI as SimpleShaderGUI;

            GUILayout.BeginHorizontal(); 
            if ( GUILayout.Button(label) && label == "创建LOD材质")
            {
                Material mat = prop.targets[0] as Material;
                
                string path = AssetDatabase.GetAssetPath(mat);
                if (path.Contains("_Lod1"))
                {
                    path = path.Substring(0, path.LastIndexOf("_Lod"));
                    CreateLod0(path, mat);
                    CreateLod2(path, mat);
                }
                else if (path.Contains("_Lod2"))
                {
                    path = path.Substring(0, path.LastIndexOf("_Lod"));
                    CreateLod0(path, mat);
                    CreateLod1(path, mat);
                }
                else  //lod0
                {
                    path = path.Substring(0, path.LastIndexOf('.'));
                    CreateLod1(path, mat);
                    CreateLod2(path, mat);
                }

                GameObject ob = Selection.activeGameObject;
                string name = ob.name;
                name = name.Substring(0, name.LastIndexOf("_"));

                GameObject lod0 = GameObject.Find(name + "_LOD00");
                if (lod0 != null)
                    lod0.GetComponent<MeshRenderer>().material = matLod0;

                GameObject lod1 = GameObject.Find(name + "_LOD01");
                if (lod1 != null)
                    lod1.GetComponent<MeshRenderer>().material = matLod0;


                GameObject lod2 = GameObject.Find(name + "_LOD02");
                if (lod2 != null)
                    lod2.GetComponent<MeshRenderer>().material = matLod1;


                GameObject lod3 = GameObject.Find(name + "_LOD03");
                if (lod3 != null)
                    lod3.GetComponent<MeshRenderer>().material = matLod1;


                GameObject lod4 = GameObject.Find(name + "_LOD04");
                if (lod4 != null)
                    lod4.GetComponent<MeshRenderer>().material = matLod2;

            }
            GUILayout.EndHorizontal();
        }
        void CreateLod0(string path, Material mat)
        {
            matLod0 = new Material(mat);
            matLod0.SetInt("_Lod", 0);
            AssetDatabase.CreateAsset(matLod0, path + ".mat");
        }
        void CreateLod1(string path, Material mat)
        {
            matLod1 = new Material(mat);
            matLod1.SetInt("_Lod", 1);
            AssetDatabase.CreateAsset(matLod1, path + "_Lod1.mat");
        }
        void CreateLod2(string path, Material mat)
        {
            matLod2 = new Material(mat);
            matLod2.SetInt("_Lod", 2);
            AssetDatabase.CreateAsset(matLod2, path + "_Lod2.mat");
        }
    }
}