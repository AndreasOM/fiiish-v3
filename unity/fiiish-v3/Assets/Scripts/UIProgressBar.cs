using UnityEngine;
using UnityEngine.UI;

public class UIProgressBar : MonoBehaviour
{
    private Image _background;// = null;
    private Image _foreground;// = null;
    
    // Start is called before the first frame update
    void Start()
    {
        Setup();
        Configure();
    }

    void Setup()
    {
        var background = transform.Find("Background");
        var backgroundGo = background.gameObject;
        _background = backgroundGo.GetComponent<Image>();
        var foreground = transform.Find("Foreground");
        var foregroundGo = foreground.gameObject;
        _foreground = foregroundGo.GetComponent<Image>();
    }

    void Configure()
    {
        SetProgress( 0.9f );
    }

    public void SetProgress(float progress)
    {
        var ur = _background.GetComponent<RectTransform>().sizeDelta;
        //Debug.Log( "ur:" + ur );
        ur.x *= progress;
        //Debug.Log( "Scaled ur:" + ur );
        _foreground.GetComponent<RectTransform>().sizeDelta = ur;
    }
    /*
    void Update()
    {
        
    }
    */
}
