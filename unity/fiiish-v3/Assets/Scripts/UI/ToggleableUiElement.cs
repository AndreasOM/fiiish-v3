using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;


public class ToggleableUiElement : MonoBehaviour
{
    public enum State
    {
        A,
        B,
    }
    
    [System.Serializable]
    public class ToggledEvent : UnityEvent< State > {}
    
    public FadeableUiElement a;
    public FadeableUiElement b;

    
    // [SerializeField]
    public ToggledEvent onToggled;// = new ToggleableUiElementToggledEvent();
    
    // Start is called before the first frame update
    IEnumerator Start()
    {
        Setup();
        return Configure();
    }

    private void Setup()
    {
        
    }

    private IEnumerator Configure()
    {
        // a.FadeOut(0.0f);
        // b.FadeOut(0.0f);
        
        yield return new WaitForEndOfFrame();
        
        a.FadeOut(0.0f);
        b.FadeOut(0.0f);
        gotoA( 0.0f );
    }
    
    // Update is called once per frame
    void Update()
    {
        
    }

    public void gotoA(float duration)
    {
        a.FadeIn(duration);
        b.FadeOut(duration);
    }
    public void gotoB(float duration)
    {
        a.FadeOut(duration);
        b.FadeIn(duration);
    }

    public void OnAClicked()
    {
        gotoB( 0.3f );
        onToggled.Invoke( State.B );
    }
    public void OnBClicked()
    {
        gotoA( 0.3f );
        onToggled.Invoke( State.A );
    }
}
