using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class InGameSettingsDialog : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    public void OnMusicToggled(ToggleableUiElement.State state)
    {
        Debug.Log($"OnMusicToggled: {state}");
    }
    
    public void OnSoundToggled(ToggleableUiElement.State state)
    {
        Debug.Log($"OnSoundToggled: {state}");
    }
}
