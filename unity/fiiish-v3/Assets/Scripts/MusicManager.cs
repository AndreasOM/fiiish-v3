using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MusicManager : MonoBehaviour
{
    private float _fadeSpeed = 0.0f;
    private AudioSource _audioSource;
    // Start is called before the first frame update
    void Start()
    {
        Setup();
    }

    void Setup()
    {
        _audioSource = GetComponent<AudioSource>();
    }
    // Update is called once per frame
    void Update()
    {
        if (_fadeSpeed != 0.0f)
        {
            _audioSource.volume += _fadeSpeed * Time.deltaTime;
            switch (_audioSource.volume)
            {
                case >= 1.0f:
                    _fadeSpeed = 0.0f;
                    _audioSource.volume = 1.0f;
                    break;
                case <= 0.0f:
                    _fadeSpeed = 0.0f;
                    _audioSource.volume = 0.0f;
                    _audioSource.mute = true;
                    break;
            }
        }
    }

    public void FadeOutMusic(float duration)
    {
        if (duration <= 0.0f)
        {
            _fadeSpeed = 0.0f;
            _audioSource.volume = 0.0f;
            _audioSource.mute = true;
        }
        else
        {
            _fadeSpeed = -1.0f / duration;
        }
    }
    public void FadeInMusic(float duration)
    {
        if (duration <= 0.0f)
        {
            _fadeSpeed = 0.0f;
            _audioSource.volume = 1.0f;
        }
        else
        {
            _fadeSpeed = 1.0f / duration;
        }
        _audioSource.mute = false;
    }
}
