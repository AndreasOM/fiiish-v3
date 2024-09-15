using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

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
    public float zoneSpawnOffset = 0.0f;
    
    public UnityEvent<String> OnZoneChanged;

    private bool moving = false;

    private GameObject obstacles = null;

    private Dictionary<uint, EntityConfig> m_entityConfigs = new Dictionary<uint, EntityConfig>();
    
    private NewZone m_zone = null;

    private Vector2 _zonePos;
    
    private void AddEntityConfig( uint crc, string addressableName)
    {
        var ec = new EntityConfig();
        ec.LoadFromAssetAsync(addressableName);
        m_entityConfigs.Add(crc, ec);
    }
    // Start is called before the first frame update
    void Start()
    {
        this.obstacles = GameObject.FindWithTag("Obstacles");
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
            AddEntityConfig(0xd058353c, "ObstaclesRockA");
            AddEntityConfig(0x49516486, "ObstaclesRockB");
            AddEntityConfig(0x3e565410, "ObstaclesRockC");
            AddEntityConfig(0xa032c1b3, "ObstaclesRockD");
            AddEntityConfig(0xd735f125, "ObstaclesRockE");
            AddEntityConfig(0x4e3ca09f, "ObstaclesRockF");
        }
        catch (Exception e)
        {
            Console.WriteLine(e);
            throw;
        }
        // :HACK: needs cleanup

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
    }

    // Update is called once per frame
    void Update()
    {
        if (this.moving)
        {
            float speed = CurrentSpeed() * Time.deltaTime;
            _zonePos.x += speed;
            if (_zonePos.x > m_zone.GetSize().x)
            {
                SpawnZone();
            }
        }
    }

    public void SpawnZone()
    {
        if( this.obstacles != null )
        {
            if (m_zone != null)
            {
                string[] rendered_layers = { "Obstacles", "Obstacles_01" };
                foreach (NewZoneLayer l in m_zone.Layers())
                {
                    if (!Array.Exists(rendered_layers, e => e == l.Name()))
                    {
                        continue;
                    }

                    foreach (NewZoneLayerObject o in l.Objects())
                    {
                        uint crc = o.Crc();
                        EntityConfig ec;
                        if (m_entityConfigs.TryGetValue(crc, out ec))
                        {
                            if (ec.handle.Result != null)
                            {
                                GameObject go = Instantiate(ec.handle.Result, new Vector3(o.PosX()+zoneSpawnOffset, o.PosY(), 0.0f),
                                    Quaternion.Euler(0.0f, 0.0f, o.Rotation()));
                                go.transform.SetParent(this.obstacles.transform, false);
                            }
                        }
                        else
                        {
                            // Debug.Log( "Entity Config not found for " + crc.ToString("X") );
                        }
                    }
                }

                _zonePos = new Vector2();
                OnZoneChanged.Invoke(m_zone.name);
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

    public float GetZoneProgress()
    {
        var progress = _zonePos.x / m_zone.GetSize().x;
        return Mathf.Clamp01( progress );
    }

    public void GotoNextZone()
    {
        Debug.Log("GotoNextZone");
        Cleanup();
        SpawnZone();
    }
}
