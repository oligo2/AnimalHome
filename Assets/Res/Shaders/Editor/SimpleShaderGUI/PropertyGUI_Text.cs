using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using UnityEngine.SceneManagement;

//文本显示
namespace Scarecrow
{
    public class TextDrawer : MaterialPropertyDrawer
    {
        private bool _enbale = true;
        private SimpleShaderGUI _simpleShaderGUI;
        private string[] _showList = new string[0];
        int type = 0;

        public TextDrawer()
        {
        }
        public TextDrawer(params string[] showList)
        {
            type = 0;
            _showList = showList;
        }
        public TextDrawer(float t, params string[] showList)
        {
            type = (int)t;
            _showList = showList;
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
            _simpleShaderGUI = editor.customShaderGUI as SimpleShaderGUI;
            if(type == 1)  //说明类型
            {
                
                GUILayout.Label(label); 
            }
            else
            {
                GUILayout.Label(label); 
                

            }
        }
    }
}