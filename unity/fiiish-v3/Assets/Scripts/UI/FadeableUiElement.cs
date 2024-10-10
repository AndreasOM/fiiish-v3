using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FadeableUiElement : MonoBehaviour
{
    private float _fadeSpeed = 0.0f;
    
    private CanvasGroup _canvasGroup;
    
    // Start is called before the first frame update
    void Start()
    {
        Setup();
        Configure();
    }

    private void Setup()
    {
        _canvasGroup = GetComponent<CanvasGroup>();
        if (_canvasGroup == null)
        {
            Debug.LogError($"FadeableUiElement::Setup(): canvas group is null for {gameObject.name}");
        }
    }

    private void Configure()
    {
        
    }
    // Update is called once per frame
    void Update()
    {
        if (_canvasGroup)
        {
            if (_fadeSpeed != 0.0f)
            {
                // Debug.Log($"Fading {_canvasGroup.alpha} += {_fadeSpeed} * {Time.deltaTime}");
                _canvasGroup.alpha += _fadeSpeed * Time.deltaTime;
                if (_canvasGroup.alpha >= 1.0f)
                {
                    _fadeSpeed = 0.0f;
                    _canvasGroup.alpha = 1.0f;
                }
                else if (_canvasGroup.alpha <= 0.0f)
                {
                    _fadeSpeed = 0.0f;
                    _canvasGroup.alpha = 0.0f;
                }
            }
        }
    }

    public bool IsFadeIn()
    {
        return _canvasGroup.alpha >= 1.0f || _fadeSpeed >= 1.0f;
    }
    
    public void ToggleFade( float duration )
    {
        if (IsFadeIn())
        {
            FadeOut(duration);
        }
        else
        {
            FadeIn(duration);
        }
    }
    
    public void FadeIn( float duration )
    {
        // Debug.Log($"FadeIn {duration}");
        
        _canvasGroup.interactable = true;
        _canvasGroup.blocksRaycasts = true;
        
        if (duration <= 0.0f)
        {
            _canvasGroup.alpha = 1.0f;
            return;
        }
        
        _fadeSpeed = 1.0f / duration;
    }

    public void FadeOut(float duration)
    {
        // Debug.Log($"FadeOut {duration}");
        
        _canvasGroup.interactable = false;
        _canvasGroup.blocksRaycasts = false;
        
        if (duration <= 0.0f)
        {
            _canvasGroup.alpha = 0.0f;
            return;
        }

        _fadeSpeed = -1.0f / duration;
    }
}
