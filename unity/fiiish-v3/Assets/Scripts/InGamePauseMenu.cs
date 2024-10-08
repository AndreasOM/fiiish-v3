using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

//using UnityEngine.UIElements;

public class InGamePauseMenu : MonoBehaviour
{
    public Game game = null;

    /*
    private Button _pauseButton;
    private Button _settingsButton;
    */
    public Button pauseButton = null;
    public Button settingsButton = null;
    
    // Start is called before the first frame update
    public IEnumerator Start()
    {
        Setup();
        return Configure();
    }

    void Setup()
    {
        /*
        var pauseButtonGo = GameObject.Find("PauseButton");
        _pauseButton = pauseButtonGo.GetComponent<Button>();

        var settingsButtonGo = GameObject.Find("SettingsButton");
        _settingsButton = settingsButtonGo.GetComponent<Button>();
        */
    }

    IEnumerator Configure()
    {
        pauseButton.gameObject.SetActive(false);
        settingsButton.gameObject.SetActive(false);
        yield return new WaitForEndOfFrame();
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
            settingsButton.gameObject.SetActive(true);
            //settingsButton.visible = true;
        }
        else
        {
            settingsButton.gameObject.SetActive(false);
            //settingsButton.visible = false;
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
