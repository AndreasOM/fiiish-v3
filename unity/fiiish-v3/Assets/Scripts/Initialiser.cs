using UnityEngine;

public class Initialiser : MonoBehaviour
{
    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        #if DEMO
            Debug.Log("DEMO build");
        #else
            Debug.Log("Normal build");
        #endif
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
