using System.Collections;
using System.Collections.Generic;
using UnityEngine;

using UnityEngine.AddressableAssets;
using UnityEngine.ResourceManagement.AsyncOperations;

using System;
using System.IO;


class EntityConfig
{
    public AsyncOperationHandle<GameObject> handle;

    public void LoadFromAssetAsync( string name )
    {
        handle = Addressables.LoadAssetAsync<GameObject>(name);
        handle.Completed += OnLoadComplete;
    }

    void OnLoadComplete(AsyncOperationHandle<GameObject> asyncOperationHandle)
    {
        Debug.Log($"AsyncOperationHandle Status: {asyncOperationHandle.Status}");
        Debug.Log("Load complete.");
    }
    public void OnDisable()
    {
        handle.Completed -= OnLoadComplete;
    }

}

public class GameManager : MonoBehaviour
{
    public float speed = 240.0f;
    public bool wrapWorld = true;

    private bool moving = false;

    private GameObject obstacles = null;

    // private AsyncOperationHandle<GameObject> m_ObstaclesRockBHandle;
    // private EntityConfig m_ObstacleRockBEntityConfig;
    //private Dictionary<uint, EntityConfig> m_entityConfigs = new Dictionary<uint, EntityConfig>();
    private Dictionary<uint, EntityConfig> m_entityConfigs = new Dictionary<uint, EntityConfig>();
    
    private NewZone m_zone = null;

    GameManager()
    {
        Debug.Log( "Creating GameManager");    
    }
    // Start is called before the first frame update
    void Start()
    {
        this.obstacles = GameObject.FindWithTag("Obstacles");

        /*
        m_ObstaclesRockBHandle = Addressables.LoadAssetAsync<GameObject>("ObstaclesRockB");
        m_ObstaclesRockBHandle.Completed += OnLoadComplete;
        */
        //m_ObstacleRockBEntityConfig = new EntityConfig();
        //m_ObstacleRockBEntityConfig.LoadFromAssetAsync( "ObstaclesRockB" );
/*
    #ROCKA           = 0xd058353c,
    #ROCKB           = 0x49516486,
    #ROCKC           = 0x3e565410,
    #ROCKD           = 0xa032c1b3,
    #ROCKE           = 0xd735f125,
    #ROCKF           = 0x4e3ca09f,
*/

        try
        {
            {
                // RockA
                var ec = new EntityConfig();
                ec.LoadFromAssetAsync("ObstaclesRockA");
                m_entityConfigs.Add(0xd058353c, ec);
            }
            {
                // RockB
                var ec = new EntityConfig();
                ec.LoadFromAssetAsync("ObstaclesRockB");
                m_entityConfigs.Add(0x49516486, ec);
            }
            {
                // RockC
                var ec = new EntityConfig();
                ec.LoadFromAssetAsync("ObstaclesRockC");
                m_entityConfigs.Add(0x3e565410, ec);
            }
            {
                // RockD
                var ec = new EntityConfig();
                ec.LoadFromAssetAsync("ObstaclesRockD");
                m_entityConfigs.Add(0xa032c1b3, ec);
            }
            {
                // RockE
                var ec = new EntityConfig();
                ec.LoadFromAssetAsync("ObstaclesRockE");
                m_entityConfigs.Add(0xd735f125, ec);
            }
            {
                // RockF
                var ec = new EntityConfig();
                ec.LoadFromAssetAsync("ObstaclesRockF");
                m_entityConfigs.Add(0x4e3ca09f, ec);
            }
        }
        catch (Exception e)
        {
            Console.WriteLine(e);
            throw;
        }
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
        foreach (var ec in m_entityConfigs.Values)
        {
            ec.OnDisable();
        }
        // m_ObstacleRockBEntityConfig.OnDisable();
        // m_ObstaclesRockBHandle.Completed -= OnLoadComplete;
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    public void SpawnZone()
    {
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
                    foreach( NewZoneLayerObject o in l.Objects() )
                    {
                        uint crc = o.Crc();
                        EntityConfig ec;
                        if( m_entityConfigs.TryGetValue( crc, out ec))
                        {
                            if (ec.handle.Result != null)
                            {
                                GameObject go = Instantiate(ec.handle.Result, new Vector3(o.PosX(), o.PosY(), 0.0f),
                                    Quaternion.Euler(0.0f, 0.0f, o.Rotation()));
                                go.transform.SetParent(this.obstacles.transform);
                            }
                        }
                        else
                        {
                            // Debug.Log( "Entity Config not found for " + crc.ToString("X") );
                        }
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
