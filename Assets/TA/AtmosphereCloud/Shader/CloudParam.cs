using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CloudParam : ScriptableObject
{
    public Color SunColor;
    public Vector4 SunDir;
    [Range(0,1)] public float Attenuation;
    public Vector4 MoonDir;
    public Color MoonColor;
    [Range(0, 1)] public float MoonAttenuation;

}
