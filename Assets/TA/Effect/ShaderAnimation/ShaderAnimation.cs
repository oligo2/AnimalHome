
using UnityEngine;

public class ShaderAnimation : MonoBehaviour
{
    [Label("动画曲线")]
    public AnimationCurve animationCurve = AnimationCurve.EaseInOut(0, 1, 1, 1);

    [Label("属性名*")]
    public string controlName = "_AlphaIntensity";

    [Label("动画曲线2")]
    public AnimationCurve animationCurve2 = AnimationCurve.EaseInOut(0, 1, 1, 1);

    [Label("属性名2*")]
    public string controlName2 = "_DissolveSpeed";

    //[Label("等待时长")]
    //public float waitTime = 0f;
    //[Label("显示时长 (从0->1)")]
    //public float showTime = 0f;
    //[Label("持续时长")]
    //public float keepTime = 0f;
    //[Label("消失时长 (从1->0)")]
    //public float fadeTime = 1f;
    //[Label("目标值*")]
    //public float value = 1;

    Material mat;

    void OnEnable()
    {

        mat = this.GetComponent<MeshRenderer>().materials[0];// : this.GetComponent<MeshRenderer>().sharedMaterials[0];
        time = 0;
    }

    float time = 0f;
    void Update()
    {
        if (mat == null)
            return;

        time += Time.deltaTime;

        float process = animationCurve.Evaluate(time);
        mat.SetFloat(controlName, process);

        float process2 = animationCurve2.Evaluate(time);
        mat.SetFloat(controlName2, process2);
    }

}