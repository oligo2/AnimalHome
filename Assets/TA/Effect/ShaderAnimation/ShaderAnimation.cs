
using UnityEngine;

public class ShaderAnimation : MonoBehaviour
{
    [Label("��������")]
    public AnimationCurve animationCurve = AnimationCurve.EaseInOut(0, 1, 1, 1);

    [Label("������*")]
    public string controlName = "_AlphaIntensity";

    [Label("��������2")]
    public AnimationCurve animationCurve2 = AnimationCurve.EaseInOut(0, 1, 1, 1);

    [Label("������2*")]
    public string controlName2 = "_DissolveSpeed";

    //[Label("�ȴ�ʱ��")]
    //public float waitTime = 0f;
    //[Label("��ʾʱ�� (��0->1)")]
    //public float showTime = 0f;
    //[Label("����ʱ��")]
    //public float keepTime = 0f;
    //[Label("��ʧʱ�� (��1->0)")]
    //public float fadeTime = 1f;
    //[Label("Ŀ��ֵ*")]
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