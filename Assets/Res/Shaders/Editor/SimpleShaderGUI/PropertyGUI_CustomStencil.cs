using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using UnityEngine.SceneManagement;

//勾选并统计总和
namespace Scarecrow
{
    public class CustomStencilDrawer : MaterialPropertyDrawer
    {
        bool _enbale = true;
        SimpleShaderGUI _simpleShaderGUI;
        string[] _showList = new string[0];

        List<bool> _toggleList = new List<bool> { };
        float _value;
        int _length;

        public CustomStencilDrawer(params string[] showList)
        {
            _showList = showList;
            _length = _showList.Length;
            for (int i = 0; i < _length; i ++)
            {
                _toggleList.Add(false);
            }
        }

        public override void Apply(MaterialProperty prop)
        {
            base.Apply(prop);
        }

        public override float GetPropertyHeight(MaterialProperty prop, string label, MaterialEditor editor)
        {
            return -2;
        }

        public override void OnGUI(Rect position, MaterialProperty prop, string label, MaterialEditor editor)
        {
            _value = prop.floatValue;

            EditorGUILayout.BeginHorizontal();
            GUILayout.Label("模板测试："+prop.floatValue);
            GUILayout.Space(10);

            int count = 0;
            for (int i=0; i< _length; i++)
            {
                string name = _showList[i];

                int v = GetValue(name);
                _toggleList[i] = ((int)_value & v) != 0 ? true : false;
                _toggleList[i] = GUILayout.Toggle(_toggleList[i], new GUIContent(Translate(name)));

                if(_toggleList[i] == true)
                {
                    count += v;
                }
            }
            EditorGUILayout.EndHorizontal();
                        
            prop.floatValue = count;
        }

        int GetValue(string name)
        {
            switch (name)
            {
                case "Hair":
                    return 1;
                case "NoTonemapping":
                    return 2;
                case "Eyebrow":
                    return 4;
                case "NoGroundDecal":
                    return 8;
                case "NoHbao":
                    return 16;
            }
            return 0;
        }

        string Translate(string name)
        {
            //Hair, NoTonemapping, Eyebrow, NoGroundDecal
            switch (name)
            {
                case "Hair":
                    return "头发投影";
                case "NoTonemapping":
                    return "剔除Tonemapping";
                case "Eyebrow":
                    return "眉毛眼睛";
                case "NoGroundDecal":
                    return "过滤贴花";
                case "NoHbao":
                    return "过滤HBAO";
            }

            return name;
        }
    }

}