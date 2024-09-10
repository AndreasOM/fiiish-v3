using System.Collections;
using System.Collections.Generic;
using UnityEngine;

using UnityEngine.AddressableAssets;
using UnityEngine.ResourceManagement.AsyncOperations;

using System;
using System.IO;

public class GameManager : MonoBehaviour
{
    public float speed = 240.0f;
    public bool wrapWorld = true;

    private bool moving = false;

    private GameObject obstacles = null;

    private AsyncOperationHandle<GameObject> m_ObstaclesRockBHandle;

    private NewZone m_zone = null;
    // Start is called before the first frame update
    void Start()
    {
        this.obstacles = GameObject.FindWithTag("Obstacles");

        m_ObstaclesRockBHandle = Addressables.LoadAssetAsync<GameObject>("ObstaclesRockB");
        m_ObstaclesRockBHandle.Completed += OnLoadComplete;

        // :HACK: needs cleanup

        // var file = Resources.Load<TextAsset>("Zones/0000_ILoveFiiish");
        //var file = Resources.Load<TextAsset>("Zones/test_zone");
        var path = Application.streamingAssetsPath + "/Zones/0000_ILoveFiiish.nzne";

        var serializer = new Serializer();

        if (serializer.LoadFile(path))
        {
            Debug.Log("File exists " + path );
            var zone = ScriptableObject.CreateInstance<NewZone>();
            if( !zone.Serialize( ref serializer ) )
            {
                Debug.LogWarning( "Failed loading " + path );
            } else {
                m_zone = zone;
            }
        } else {
            Debug.LogWarning( "Serializer failed loading: " + path );
        }
        Debug.Log("Started.");
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
/*
    #ROCKA           = 0xd058353c,
    #ROCKB           = 0x49516486,
    #ROCKC           = 0x3e565410,
    #ROCKD           = 0xa032c1b3,
    #ROCKE           = 0xd735f125,
    #ROCKF           = 0x4e3ca09f,
*/
        if( this.obstacles != null )
        {
            if( m_zone != null ) {
                string[] rendered_layers = {"Obstacles", "Obstacles_01"};
                foreach( NewZoneLayer l in m_zone.Layers() ){
                    if( !Array.Exists(rendered_layers, e => e == l.Name() ) )
                    //if ( !rendered_layers.Contains( l.Name() ) )
                    {
                        continue;
                    }
                    foreach( NewZoneLayerObject o in l.Objects() ){
                        GameObject go = Instantiate(m_ObstaclesRockBHandle.Result, new Vector3(o.PosX(), o.PosY(), 0.0f), Quaternion.Euler(0.0f, 0.0f, o.Rotation()));
                        go.transform.SetParent( this.obstacles.transform );
                    }
                }
            } else {
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
