using UnityEngine;
using UnityEngine.SceneManagement;

public class Initialiser : MonoBehaviour
{
    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        #if DEMO
            Debug.Log("DEMO build");
            SceneManager.LoadScene("DemoOverlayScene", LoadSceneMode.Additive);
        #else
            Debug.Log("Normal build");
        #endif
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
