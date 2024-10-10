using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

//using UnityEngine.UIElements;

public class InGamePauseMenu : MonoBehaviour
{
    public Game game = null;

    public Button pauseButton = null;
    public FadeableUiElement settingsUiElement = null;
    
    // Start is called before the first frame update
    public IEnumerator Start()
    {
        Setup();
        return Configure();
    }

    void Setup()
    {
    }

    IEnumerator Configure()
    {
        pauseButton.gameObject.SetActive(false);
        settingsUiElement.FadeOut(0.0f);
        yield return new WaitForEndOfFrame();
        // settingsUiElement.FadeOut(0.0f);
        pauseButton.gameObject.SetActive(true);
        UpdateSettingsButton();
    }
    
    // Update is called once per frame
    void Update()
    {
    }

    private void UpdateSettingsButton()
    {
        if (game.IsPaused())
        {
            settingsUiElement.FadeIn( 0.3f );
        }
        else
        {
            settingsUiElement.FadeOut( 0.3f );
        }
    }
    private void TogglePause()
    {
        var paused = game.TogglePause();
        
        UpdateSettingsButton();
    }
    public void OnPauseButtonClicked()
    {
        TogglePause();
    }
    public void OnSettingsButtonClicked()
    {
        Debug.Log("OnSettingsButtonClicked");
    }
}
