using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;

public class ResultRow : MonoBehaviour
{
    public TextMeshProUGUI totalLabel = null;
    public TextMeshProUGUI currentLabel = null;
    
    // Start is called before the first frame update
    void Start()
    {
        Setup();
        Configure();
    }

    void Setup()
    {
        
    }

    void Configure()
    {
        
    }
    // Update is called once per frame
    void Update()
    {
        
    }

    public void SetTotal(string total)
    {
        totalLabel.text = total;
    }

    public void SetCurrent(string current)
    {
        currentLabel.text = current;
    }
}
