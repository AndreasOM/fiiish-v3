using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class InGameSettingsDialog : MonoBehaviour
{
    public Game game;
    public ToggleableUiElement musicToggle;
    public ToggleableUiElement soundToggle;
    // Start is called before the first frame update
    /*
    void Start()
    {
        Debug.Log("InGameSettingsDialog.Start()");
        Setup();
        Configure();
    }
    */
    void Awake()
    {
        Debug.Log("InGameSettingsDialog.Awake()");
        Setup();
        Configure();
    }

    public void SetGame(Game game)
    {
        this.game = game;
        Configure();
    }
    void Setup()
    {
        
    }

    void Configure()
    {
        if (game == null)
        {
            return;
        }
        var player  = game.GetPlayer();

        if (player.IsMusicEnabled())
        {
            musicToggle.GotoA( 0.0f );
        }
        else
        {
            musicToggle.GotoB( 0.0f );
        }
        if (player.IsSoundEnabled())
        {
            soundToggle.GotoA( 0.0f );
        }
        else
        {
            // Debug.Log("Sound is disabled");
            soundToggle.GotoB( 0.0f );
        }
    }
    // Update is called once per frame
    void Update()
    {
        
    }

    public void OnMusicToggled(ToggleableUiElement.State state)
    {
        Debug.Log($"OnMusicToggled: {state}");
        switch (state)
        {
            case ToggleableUiElement.State.A:
                {
                    game.EnableMusic();
                }
                break;
            case ToggleableUiElement.State.B:
                {
                    game.DisableMusic();
                }
                break;
        }
        // game.GetPlayer().Save();
    }
    
    public void OnSoundToggled(ToggleableUiElement.State state)
    {
        Debug.Log($"OnSoundToggled: {state}");
        switch (state)
        {
            case ToggleableUiElement.State.A:
                {
                    game.EnableSound();
                }
                break;
            case ToggleableUiElement.State.B:
                {
                    game.DisableSound();
                }
                break;
        }
        // game.GetPlayer().Save();
    }
}
