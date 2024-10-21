using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AddressableAssets;
using UnityEngine.ResourceManagement.AsyncOperations;

public class SoundManager : MonoBehaviour
{
    private Dictionary<AudioEffectId, AsyncOperationHandle<AudioClip>> _audioClips = new Dictionary<AudioEffectId, AsyncOperationHandle<AudioClip>>();
    // Start is called before the first frame update
    IEnumerator Start()
    {
        Setup();
        return Configure();
    }

    void Setup()
    {
        
    }

    IEnumerator Configure()
    {

        {
            var handle = Addressables.LoadAssetAsync<AudioClip>("sound_picked_coin");
            _audioClips[AudioEffectId.CoinPickup] = handle;
        }        
        {
            var handle = Addressables.LoadAssetAsync<AudioClip>("sound_fish_death");
            _audioClips[AudioEffectId.FishDeath] = handle;
        }        
        return null;
    }
    // Update is called once per frame
    void Update()
    {
        foreach (var audioSource in GetComponentsInChildren<AudioSource>())
        {
            if (!audioSource.isPlaying)
            {
                Destroy(audioSource.gameObject);
            }
        }
    }

    public void TriggerSound(AudioEffectId audioEffectId)
    {
        if (_audioClips.ContainsKey(audioEffectId))
        {
            var ach = _audioClips[audioEffectId];
            if (ach.Result != null)
            {
                var ac = ach.Result;
                var go = new GameObject();
                var audioSource = go.AddComponent<AudioSource>();
                audioSource.clip = ac;
                audioSource.Play();
                go.transform.parent = transform;
            }
        }
    }
}
