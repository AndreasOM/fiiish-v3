using System.Collections;
using System.Collections.Generic;
using UnityEngine;

using UnityEngine.AddressableAssets;
using UnityEngine.ResourceManagement.AsyncOperations;

public class GameManager : MonoBehaviour
{
    public float speed = 240.0f;
    public bool wrapWorld = true;

    private bool moving = false;

    private GameObject obstacles = null;

    private AsyncOperationHandle<GameObject> m_ObstaclesRockBHandle;

    // Start is called before the first frame update
    void Start()
    {
        this.obstacles = GameObject.FindWithTag("Obstacles");

        m_ObstaclesRockBHandle = Addressables.LoadAssetAsync<GameObject>("ObstaclesRockB");
        m_ObstaclesRockBHandle.Completed += OnLoadComplete;
    }

    void OnDisable()
    {
        m_ObstaclesRockBHandle.Completed -= OnLoadComplete;
    }

    void OnLoadComplete(AsyncOperationHandle<GameObject> asyncOperationHandle)
    {
        Debug.Log($"AsyncOperationHandle Status: {asyncOperationHandle.Status}");
        Debug.Log("Load complete.");
    }
    // Update is called once per frame
    void Update()
    {
        
    }

    public void SpawnZone()
    {
        if( this.obstacles != null )
        {
            if (m_ObstaclesRockBHandle.Status == AsyncOperationStatus.Succeeded)
            {
                {
                    GameObject o = Instantiate(m_ObstaclesRockBHandle.Result, new Vector3(1200.0f, -410.0f, 0.0f), Quaternion.identity);
                    o.transform.SetParent( this.obstacles.transform );
                }
                {
                    GameObject o = Instantiate(m_ObstaclesRockBHandle.Result, new Vector3(1500.0f, -410.0f, 0.0f), Quaternion.identity);
                    o.transform.SetParent( this.obstacles.transform );
                }
                {
                    GameObject o = Instantiate(m_ObstaclesRockBHandle.Result, new Vector3(1800.0f, -410.0f, 0.0f), Quaternion.identity);
                    o.transform.SetParent( this.obstacles.transform );
                }
            }
        }
    }

    public void Cleanup()
    {
        Debug.Log("Cleanup");
        if( this.obstacles != null )
        {
             foreach (Transform child in obstacles.transform)
             {
                Debug.Log( "Destroying "+ child );
                Destroy( child.gameObject );
             }
        }        
    }
    public float CurrentSpeed()
    {

        if ( this.moving ) {
            return this.speed;
        } else {
            return 0.0f;
        }
    }

    public void PauseMovement()
    {
        this.moving = false;
    }

    public void ResumeMovement()
    {
        this.moving = true;
    }
}
