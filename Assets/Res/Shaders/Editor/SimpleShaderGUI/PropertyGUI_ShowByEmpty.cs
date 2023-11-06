using UnityEditor;
using UnityEngine;

//当对象为空时显示
namespace Scarecrow
{
    public class ShowByEmptyDrawer : MaterialPropertyDrawer
    {
        private SimpleShaderGUI _simpleShaderGUI;
        private string _show;

        public ShowByEmptyDrawer( string show)
        {
            _show = show;
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

            editor.DefaultShaderProperty(prop, label);
            if (prop.textureValue == null)
            {
                if (_simpleShaderGUI.ShowList.Contains(_show))
                    _simpleShaderGUI.ShowList.Remove(_show);
            }
            else
            {
                if(!_simpleShaderGUI.ShowList.Contains(_show))
                    _simpleShaderGUI.ShowList.Add(_show);
            }
        }
    }
}
