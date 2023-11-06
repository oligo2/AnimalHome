float _GlobeInteractivesProcess;
float _GlobeInteractivesCount;
float4 _GlobeInteractives[20];

float3 CaculateWindAnimation(float3 windDirection, float3 worldDir, float3 worldPos, float3 vertex, float2 uv, out float w)
{
    //计算风力动画旋转
    float speed = _Time.y * _WindSpeed; 
    float rotate = _SwingingRange ;
    float2 uv2 = worldPos.xz / _WindMap_ST / (100/ _SwingingRhythm) + speed/10 * (half2(worldDir.z,worldDir.x));
    float windSample = tex2Dlod(_WindMap, float4(uv2, uv)).r;
    rotate = lerp(0, rotate, windSample);
    w = windSample;

    //判断草与人物距离
    if(_EnableInteractive == 1)
    {
        half isInteractive = 0;
        float3 dir = 0;
        half process = 100;
        float3 currentPos = _EnableInteractiveWhole == 1 ? TransformObjectToWorld(0) : worldPos;
        float range = 0;
 
        for (int i = 0; i < 1; i++)
        {
            float3 pressPos = float3(_GlobeInteractives[i].x, _GlobeInteractives[i].y, _GlobeInteractives[i].z);
            pressPos.y = max(pressPos.y, currentPos.y);
            range = _GlobeInteractives[i].w;

            half dist = distance(pressPos, currentPos);
            if (dist < range )
            {
                dir = normalize(float3(currentPos.x, 0, currentPos.z) - float3(pressPos.x, 0, pressPos.z));        
                process =  (range - dist)/ range;           
                dir.y = -(process);
                // dir.xz = 0;

                // vertex = vertex + dir * process * vertex.y * _InteractivePow; 
                vertex = vertex + dir * process * vertex.y * _InteractivePow; 
                // rotate *= process;
            }
        }
    }
    
    float3 finalVertex = RotateAroundAxisYZero(float3(vertex.x, 0, vertex.z), vertex, windDirection.xz, -rotate);
    return finalVertex;
}