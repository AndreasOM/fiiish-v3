
using UnityEngine;

public class EasedInteger
{
    public enum EasingFunction
    {
        Linear,
        InOutCubic,
    }

    private float _startTime;
    private float _endTime;
    private float _startValue;
    private float _endValue;
    
    private EasingFunction _easingFunction;

    public EasedInteger(float startTime, float endTime, int startValue, int endValue, EasingFunction easingFunction)
    {
        _startTime = startTime;
        _endTime = endTime;
        _startValue = (float)startValue;
        _endValue = (float)endValue;
        _easingFunction = easingFunction;
    }

    public int GetForTime(float time)
    {

        switch (_easingFunction)
        {
            case EasingFunction.Linear:
                return GetLinearForTime(time);        
            default:
                return GetInOutCubicForTime(time);        
        }

        return 0;
    }

    private int GetLinearForTime(float time)
    {
        float x = Mathf.Clamp01( (time - _startTime) / (_endTime - _startTime) );
        float y = _startValue + (x * (_endValue - _startValue));
        
        return Mathf.FloorToInt(y);
    }
    private int GetInOutCubicForTime(float time)
    {
        float x = Mathf.Clamp01( (time - _startTime) / (_endTime - _startTime) );
        float p = x < 0.5 ? 4 * x * x * x : 1 - Mathf.Pow(-2 * x + 2, 3) / 2;
        float y = _startValue + (p * (_endValue - _startValue));
        
        return Mathf.FloorToInt(y);
    }
}
