using System.Collections;
//using System.Collections.Generic;
//using UnityEditor.SceneManagement;
using UnityEngine;
//using UnityEngine.UI;

//using UnityEngine.UIElements;

public class InGamePauseMenu : MonoBehaviour
{
    public Game game = null;

    public ToggleableUiElement pausePlayToggleButton = null;
    public FadeableUiElement settingsUiElement = null;
    public FadeableUiElement settingsDialog = null;
    
    public GameObject settingsDialogPrefab = null;
    
    // Start is called before the first frame update
    public IEnumerator Start()
    {
        // Time.timeScale = 0.01f;
        Setup();
        return Configure();
    }

    void Setup()
    {
        if (settingsDialogPrefab != null)
        {
            Debug.Log("Instantiating settingsDialog");
            var go = Instantiate(settingsDialogPrefab, transform); 
            settingsDialog = go.GetComponent<FadeableUiElement>();
            var inGameSettingsDialog = go.GetComponent<InGameSettingsDialog>();
            inGameSettingsDialog.SetGame( game );
        }
    }

    IEnumerator Configure()
    {
        //yield return new WaitForEndOfFrame();
        settingsUiElement.FadeOut(0.0f);
        settingsDialog.FadeOut( 0.0f );
        yield return new WaitForEndOfFrame();
        settingsUiElement.FadeOut(0.0f);
        UpdateSettingsButton();
    }
    
    // Update is called once per frame
    void Update()
    {
        if(Input.GetKeyDown("p"))
        {
            TogglePause();
        }
    }

    private void UpdateSettingsButton()
    {
        if (game.IsPaused())
        {
            settingsUiElement.FadeIn( 0.3f );
            pausePlayToggleButton.GotoB( 0.3f );
        }
        else
        {
            settingsUiElement.FadeOut( 0.3f );
            pausePlayToggleButton.GotoA( 0.3f );
            settingsDialog.FadeOut( 0.3f );
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
        settingsDialog.ToggleFade( 0.3f );
    }

    public void OnPlayPauseToggled( ToggleableUiElement.State state )
    {
        Debug.Log($"OnPlayPauseToggled {state}");
         // A -> Showing Pause -> Playing
         // B -> Showing Play -> Paused

         var paused = game.TogglePause();
        
         UpdateSettingsButton();

    }
}
