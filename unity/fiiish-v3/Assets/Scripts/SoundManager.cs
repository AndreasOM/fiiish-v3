using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AddressableAssets;
using UnityEngine.ResourceManagement.AsyncOperations;

public class SoundManager : MonoBehaviour
{
    class SoundConfig
    {
        private AsyncOperationHandle<AudioClip> handle;
        private List<GameObject> instances = new List<GameObject>();
        private int _amount = 0;
        private string _key = "";
        private Transform _parentTransform;
        private float _lastTrigger = 0.0f;
        private float _minSeperation = 0.0f;
        public SoundConfig(Transform parentTransform, string key, int amount, float minSeperation = 0.0f)
        {
            _parentTransform = parentTransform;
            _amount = amount;
            _key = key;
            _minSeperation = minSeperation;
            handle = Addressables.LoadAssetAsync<AudioClip>(key);
            handle.Completed += OnLoadCompleted;
        }

        public bool Trigger()
        {
            // audioSource.Play();
            if (_minSeperation > 0.0f)
            {
                if (_lastTrigger > Time.time - _minSeperation)
                {
                    return false;
                }
            }
            foreach (var instance in instances)
            {
                var ac = instance.GetComponent<AudioSource>();
                if (!ac.isPlaying)
                {
                    _lastTrigger = Time.time;
                    ac.Play();
                    return true;
                }
            }
            return false;
        }

        public void Update()
        {
        }

        private void OnLoadCompleted(AsyncOperationHandle<AudioClip> handle)
        {
            if( handle.Result != null)
            {
                for (var i = 0; i < _amount; ++i)
                {
                    var go = new GameObject();
                    go.transform.SetParent(_parentTransform);
                    go.name = $"SoundConfig_{_key}_{i}";
                    var audioSource = go.AddComponent<AudioSource>();
                    audioSource.clip = handle.Result;
                    instances.Add(go);
                }
            } 
        }
    }
    private Dictionary<AudioEffectId, AsyncOperationHandle<AudioClip>> _audioClips = new Dictionary<AudioEffectId, AsyncOperationHandle<AudioClip>>();

    private Dictionary<AudioEffectId, SoundConfig> _soundConfigs = new();
    
    // Start is called before the first frame update
    void Start()
    {
        Setup();
        Configure();
    }

    void Setup()
    {
        
    }

    private void AddAudioEffect( AudioEffectId audioEffectId, string key, int amount, float minSeperation = 0.0f)
    {
        _soundConfigs[audioEffectId] = new SoundConfig( gameObject.transform, key, amount, minSeperation);
    }
    void Configure()
    {

        AddAudioEffect( AudioEffectId.CoinPickup, "sound_picked_coin", 50, 0.025f);
        AddAudioEffect( AudioEffectId.FishDeath, "sound_fish_death", 1);
    }
    // Update is called once per frame
    void Update()
    {
        foreach (var kvp in _soundConfigs)
        {
            kvp.Value.Update();
        }
    }

    public void TriggerSound(AudioEffectId audioEffectId)
    {
        if (_soundConfigs.ContainsKey(audioEffectId))
        {
            var soundConfig = _soundConfigs[audioEffectId];
            
            soundConfig.Trigger();
        }
    }
}
