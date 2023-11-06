using System;
using UnityEditor;
using UnityEngine;

//根据条件隐藏
namespace Scarecrow
{
    public class ShowDrawer : MaterialPropertyDrawer
    {
        private float _oldFloat;
        private string _show;
        private bool _waitChange = false;

        public ShowDrawer( string show)
        {
            _show = show;
            _oldFloat = 1;
        }

        public override void Apply(MaterialProperty prop)
        {
            base.Apply(prop);
        }

        public override float GetPropertyHeight(MaterialProperty prop, string label, MaterialEditor editor)
        {
            return -1.5f;
        }

        public override void OnGUI(Rect position, MaterialProperty prop, string label, MaterialEditor editor)
        {
            SimpleShaderGUI _simpleShaderGUI = editor.customShaderGUI as SimpleShaderGUI;
                            
            if (!_simpleShaderGUI.ShowList.Contains(_show))
            {
                editor.DefaultShaderProperty(prop, label);
                if (_waitChange)
                {
                    prop.floatValue = _oldFloat;
                }
                _oldFloat = prop.floatValue;
                _waitChange = false;
            }
            else
            {
                prop.floatValue = 1;
                _waitChange = true;
                GUILayout.Space(0);
            }
        }
    }
}
