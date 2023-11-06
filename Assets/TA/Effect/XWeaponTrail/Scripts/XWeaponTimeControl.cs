using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Rendering;
using XftWeapon;

[ExecuteAlways]
public class XWeaponTimeControl : MonoBehaviour
{
    [Header("Runtime")] public List<XWeaponTrail> weaponTrails = new List<XWeaponTrail>();

    [Header("编辑时预览配置")] public PlayableDirector playableDirector;
    public bool start = false;
    bool oldStart = false;
    float speed = 0.0166f;
    public float currentTime = 0;

    public void SetTimeScale(float scale)
    {
        for(int i = 0;i<weaponTrails.Count;i++)
        {
            weaponTrails[i].TotalTimeScale = scale;
        }
    }

    void Awake()
    {
        if (!Application.isPlaying)
        {
            return;
        }
    }
    void OnEnable()
    {
        //运行时，OnEnable显示子级所有Trail
        if (Application.isPlaying)
        {
            foreach (var wt in weaponTrails)
            {
                wt.gameObject.SetActive(true); // = true;
            }
        }
        //非运行时，添加回调直接绘制
        else
        {
            currentTime = 0;
#if UNITY_EDITOR
            RenderPipelineManager.beginCameraRendering += RenderPipeline;
#endif
        }
    }

    void OnDisable()
    {
        //运行时，OnDisable隐藏子级所有Trail
        if (Application.isPlaying)
        {
        }
        //非运行时，移除回调不再绘制
        else
        {
#if UNITY_EDITOR
            RenderPipelineManager.beginCameraRendering -= RenderPipeline;
#endif
        }
    }

    #region EditMode PreView
#if UNITY_EDITOR
    private void RenderPipeline(ScriptableRenderContext ctx, Camera cam)
    {
        if (weaponTrails == null || playableDirector == null || weaponTrails.Count == 0)
            return;

        if (start)
        {
            currentTime += speed;
            if (start != oldStart)
            {
                oldStart = start;

                foreach (var wt in weaponTrails)
                {
                    wt.gameObject.SetActive(true); // = true;
                    wt.OnEnable();
                }
            }
        }
        else
        {
            if (oldStart == true)
            {
                oldStart = false;
                currentTime = 0;
            }
        }

        foreach (var wt in weaponTrails)
        {
            if (currentTime >= 0 && wt.gameObject.activeSelf == false)
            {
                wt.gameObject.SetActive(true);
                wt.OnEnable();
            }

            wt.currentTime = currentTime;
        }

        playableDirector.time = currentTime;
        playableDirector.Evaluate();
    }

    private void OnValidate()
    {
        if (Application.isPlaying)
        {
            return;
        }
        //保证直接修改面板参数时，playableDirector的参数能变化
        if (playableDirector != null)
        {
            playableDirector.time = currentTime;
            playableDirector.Evaluate();
        }
    }

#endif

    #endregion
}