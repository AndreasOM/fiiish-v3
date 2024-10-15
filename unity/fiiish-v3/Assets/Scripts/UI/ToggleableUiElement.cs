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
        Undefined,
    }
    
    [System.Serializable]
    public class ToggledEvent : UnityEvent< State > {}
    
    public FadeableUiElement a;
    public FadeableUiElement b;

    
    // [SerializeField]
    public ToggledEvent onToggled;// = new ToggleableUiElementToggledEvent();
    
    private State _state = State.Undefined;
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

        if (_state == State.Undefined)
        {
            a.FadeOut(0.0f);
            b.FadeOut(0.0f);
            GotoA(0.0f);
        }
    }
    
    // Update is called once per frame
    void Update()
    {
        
    }

    public State GetState()
    {
        return _state;
    }
    
    public void GotoA(float duration)
    {
        // Debug.Log($"Goto A - ${name}");
        a.FadeIn(duration);
        b.FadeOut(duration);
        _state = State.A;
    }
    public void GotoB(float duration)
    {
        // Debug.Log($"Goto B - ${name}");
        a.FadeOut(duration);
        b.FadeIn(duration);
        _state = State.B;
    }

    public void OnAClicked()
    {
        GotoB( 0.3f );
        onToggled.Invoke( State.B );
    }
    public void OnBClicked()
    {
        GotoA( 0.3f );
        onToggled.Invoke( State.A );
    }
}
