#ifndef INFINITE_OCEAN_WAVEFORM_INCLUDED
#define INFINITE_OCEAN_WAVEFORM_INCLUDED

struct WaveStruct
{
    float3 position;
    float3 normal;
};

struct Wave
{
    half amplitude; //振幅
    half direction; //方向
    half waveLength; //波长
};

WaveStruct GerstnerWave(half2 pos, half amplitude, half direction, half wavelength, uint waveCount)
{
    WaveStruct waveOutPout = (WaveStruct)0;
    half waveCountMulti = 1.0 / waveCount;
    half3 wave = 0; // wave vector
    half k = 6.28318 / wavelength; // 2*PI
    half c = sqrt(9.8 * k); // frequency of the wave based off wavelength
    half peak = 1.5; // peak value, 1 is the sharpest peaks
    half qi = peak / (amplitude * k * waveCount);
    direction = radians(direction); // convert the incoming degrees to radians, for directional waves
    half2 dirWaveInput = half2(sin(direction), cos(direction));
    half2 windDir = normalize(dirWaveInput); // calculate wind direction
    half dir = dot(windDir, pos); // calculate a gradient along the wind direction
    ////////////////////////////position output calculations/////////////////////////
    half calc = dir * k + -_Time.y * c; // the wave calculation
    half cosCalc = cos(calc); // cosine version(used for horizontal undulation)
    half sinCalc = sin(calc); // sin version(used for vertical undulation)
    // calculate the offsets for the current point
    wave.xz = qi * amplitude * windDir.xy * cosCalc;
    wave.y = ((sinCalc * amplitude)) * waveCountMulti; // the height is divided by the number of waves
    ////////////////////////////normal output calculations/////////////////////////
    half wa = k * amplitude;
    // normal vector
    half3 n = half3(-(windDir.xy * wa * cosCalc), 1 - (qi * wa * sinCalc));
    ////////////////////////////////assign to output///////////////////////////////
    waveOutPout.position = wave * saturate(amplitude * 10000);
    waveOutPout.normal = (n.xzy * waveCountMulti);
    return waveOutPout;
}

void CalculateWave(inout VertexPositionInputs VPInput, inout VertexNormalInputs VNInput, half4 waveData[10], uint waveCount)
{
    float3 position = 0;
    float3 normal = 0;
    half3 pos = VPInput.positionWS;
    UNITY_LOOP
    for (uint i = 0; i < waveCount; i ++)
    {
        Wave w = (Wave)0;
        w.amplitude = waveData[i].x;
        w.direction = waveData[i].y;
        w.waveLength = waveData[i].z;
        WaveStruct wave = GerstnerWave(pos.xz, w.amplitude, w.direction, w.waveLength, waveCount);
        position += wave.position;
        normal += wave.normal;
    }
    VNInput.normalWS = normalize(normal);
    VPInput.positionWS += position;
}

#endif
