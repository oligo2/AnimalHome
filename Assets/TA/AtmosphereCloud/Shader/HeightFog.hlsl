
struct ScreenSpace
{
    float3           cameraPos;
    float3           worldPos;
    float            maxDist;
    float3           rayDir;

}; 


struct HorizontalRegion
{
    float height;
    float thickness;
    float2 softness;
};

struct Ray
{
    float from;
    float to;
    float max;
    float length;
};

struct HorizontalShapeView
{
    float CameraY;
    float CameraToBottomVDistance;
    float CameraToTopVDistance;
    float NearDistance;
    float FarDistance;
    float MaxDistance;
    float Length;
};

HorizontalShapeView CalculateHorizontalShapeView(
          ScreenSpace      ss,
          HorizontalRegion region)
{
    HorizontalShapeView hsv;

    
    const float3 up = float3(0, 1, 0);
    float  maxDist          =  ss.maxDist;
    float  cameraY          =  ss.cameraPos.y;
    float  dbottom          = (region.height                       - cameraY);
    float  dtop             = ((region.height  + max(1, region.thickness)) - cameraY);
    float  horizontalFactor = dot(ss.rayDir, up);
    float  bottomDist       = max(0, dbottom / horizontalFactor);
    float  topDist          = max(0, dtop / horizontalFactor);
    
    float  fromDist         = min(bottomDist, topDist);
    float  toDist           = max(bottomDist, topDist);
    
    hsv.CameraY = cameraY;
    hsv.CameraToBottomVDistance = dbottom;
    hsv.CameraToTopVDistance = dtop;
    hsv.NearDistance = fromDist;
    hsv.FarDistance = toDist;
    hsv.MaxDistance = maxDist;
    hsv.Length = toDist - fromDist;
    
    return hsv;
}