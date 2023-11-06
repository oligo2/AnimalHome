using UnityEditor;
using UnityEngine;
using XftWeapon;

[CustomEditor(typeof(XWeaponTrail))]
[CanEditMultipleObjects]
public class XWeaponTrailEditor : Editor 
{
    XWeaponTrail weaponTrail;

    public override void OnInspectorGUI() 
    {
        weaponTrail = (XWeaponTrail)target;


        weaponTrail.type = (XWeaponTrail.TrailType)EditorGUILayout.EnumPopup("刀光类型", weaponTrail.type);
        EditorGUI.indentLevel++;
        if (weaponTrail.type == XWeaponTrail.TrailType.Circle)
        {
            weaponTrail.Radius = EditorGUILayout.Slider("半径", weaponTrail.Radius, 0, 5);
            weaponTrail.Diversion = EditorGUILayout.Slider("偏转", weaponTrail.Diversion, -180, 180);
            weaponTrail.CenterPointOffset = EditorGUILayout.Slider("中心点偏移", weaponTrail.CenterPointOffset, -10, 10);

            EditorGUILayout.Space();

            weaponTrail.HeadStartWorldPos = EditorGUILayout.Vector3Field("顶端开始位置", weaponTrail.HeadStartWorldPos);
            weaponTrail.TailStartWorldPos = EditorGUILayout.Vector3Field("底端开始位置", weaponTrail.TailStartWorldPos);
            weaponTrail.HeadEndWorldPos = EditorGUILayout.Vector3Field("顶端结束位置", weaponTrail.HeadEndWorldPos);
            weaponTrail.TailEndWorldPos = EditorGUILayout.Vector3Field("底端结束位置", weaponTrail.TailEndWorldPos);

            if (GUILayout.Button("记录刀口初始位置"))
            {
                weaponTrail.CharacterPos = weaponTrail.CharacterPoint.transform.position;
                weaponTrail.CharacterForward = weaponTrail.CharacterPoint.transform.forward;

                weaponTrail.HeadStartWorldPos = weaponTrail.MeshStartPoint.position;
                weaponTrail.TailStartWorldPos = weaponTrail.MeshEndPoint.position;
            }
            else if (GUILayout.Button("记录刀口结束位置"))
            {
                weaponTrail.CharacterPos = weaponTrail.CharacterPoint.transform.position;
                weaponTrail.CharacterForward = weaponTrail.CharacterPoint.transform.forward;

                weaponTrail.HeadEndWorldPos = weaponTrail.MeshStartPoint.position;
                weaponTrail.TailEndWorldPos = weaponTrail.MeshEndPoint.position;
            }
        }

        EditorGUI.indentLevel--;


        EditorGUILayout.Space();
        weaponTrail.StartTime = EditorGUILayout.Slider("开始时间", weaponTrail.StartTime, 0, 5);
        weaponTrail.SpanTime = EditorGUILayout.Slider("持续时间", weaponTrail.SpanTime, 0, 5);
        weaponTrail.FadeTime = EditorGUILayout.Slider("消失时间", weaponTrail.FadeTime, 0, 5);
        weaponTrail.MyGradient = EditorGUILayout.GradientField("颜色变化", weaponTrail.MyGradient);

        EditorGUILayout.Space();
        weaponTrail.MaxFrame = EditorGUILayout.IntSlider("拖尾长度", weaponTrail.MaxFrame, 0, 100);
        weaponTrail.Granularity = EditorGUILayout.IntSlider("面数", weaponTrail.Granularity, 0, 40);     

        EditorGUILayout.Space();        
        EditorGUILayout.PropertyField(serializedObject.FindProperty("CharacterPoint"), new GUIContent("角色节点"));
        EditorGUILayout.PropertyField(serializedObject.FindProperty("MeshStartPoint"), new GUIContent("mesh顶端位置"));
        EditorGUILayout.PropertyField(serializedObject.FindProperty("MeshEndPoint"), new GUIContent("mesh底端位置"));
        SerializedProperty UseWithSRP = serializedObject.FindProperty("UseWithSRP");
        EditorGUILayout.PropertyField(UseWithSRP);


        EditorGUILayout.Space();
        EditorGUILayout.PropertyField(serializedObject.FindProperty("MyMaterial"), new GUIContent("正常材质"));
        EditorGUILayout.PropertyField(serializedObject.FindProperty("HeatMaterial"), new GUIContent("热扰动材质"));

        if (GUI.changed) {

            serializedObject.ApplyModifiedProperties();

            EditorUtility.SetDirty(target);
        }
    }
}