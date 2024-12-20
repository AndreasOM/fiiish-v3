using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

using UnityEngine.AddressableAssets;
using UnityEngine.ResourceManagement.AsyncOperations;

using System;
using System.IO;
using JetBrains.Annotations;
using Unity.VisualScripting;
using UnityEngine.Serialization;
//using Random = System.Random;
using Random = UnityEngine.Random;


class EntityConfig
{
    public AsyncOperationHandle<GameObject> handle;
    public UnityEvent<Game.State> OnStateChanged;
    
    public void LoadFromAssetAsync( string name )
    {
        handle = Addressables.LoadAssetAsync<GameObject>(name);
        handle.Completed += OnLoadComplete;
    }

    void OnLoadComplete(AsyncOperationHandle<GameObject> asyncOperationHandle)
    {
        //Debug.Log($"AsyncOperationHandle Status: {asyncOperationHandle.Status}");
        //Debug.Log("Load complete.");
    }
    public void OnDisable()
    {
        handle.Completed -= OnLoadComplete;
    }

}

class ZoneLoader
{
    private string _zone_file = null;
    private NewZone _zone = null;
    public ZoneLoader(string zone_file)
    {
        _zone_file = zone_file;
    }

    public NewZone Zone()
    {
        return _zone;
    }
    public IEnumerator Load()
    {
        var serializer = new Serializer();
        var c = serializer.LoadFileOrUrl(_zone_file);
        while (c.MoveNext())
        {
            yield return null;
        }
        //yield return serializer.LoadFileOrUrl(_zone_file);
        
        if (serializer.CanRead())
        {
            //Debug.Log("File exists " + path );
            var zone = ScriptableObject.CreateInstance<NewZone>();
            if( !zone.Serialize( ref serializer ) )
            {
                Debug.LogWarning( "Failed loading " + _zone_file );
            } else
            {
                _zone = zone;
                //yield break;
            }
        } else {
            Debug.LogWarning( "Serializer failed loading: " + _zone_file );
        }

        yield break;
    }
}
public class GameManager : MonoBehaviour
{
    public float pixelsPerMeter = 100.0f;
    public float speed = 240.0f;
    public bool wrapWorld = true;
    public float zoneSpawnOffset = 0.0f;
    
    public UnityEvent<String> OnZoneChanged;
    public UnityEvent<Game.State> onStateChanged;
    public UnityEvent<AudioEffectId> onAudioEffectTriggered;

    public List<ZoneList> zoneLists;
    
    private int _coins = 0;
    private float _distance = 0.0f;
    private bool moving = false;

    private GameObject obstacles = null;

    private Dictionary<UInt32, EntityConfig> m_entityConfigs = new Dictionary<UInt32, EntityConfig>();
    
    private NewZone _currentZone = null;
    private List<NewZone> _zones = new List<NewZone>();
    private List<string> _queuedZones = new List<string>();

    private Vector2 _zonePos;
    private float _closest_ever = float.MaxValue;


    private float _coinRainDuration = 0.0f;
    private float _coinRainPerSecond = 3.3f;
    private float _coinRainCounter = 0.0f;
    
    private bool _paused = false;

    private float _pickupZBias = 0.0f;

    private bool _isFullyLoaded = false;
    
    private void AddEntityConfig( UInt32 crc, string addressableName)
    {
        var ec = new EntityConfig();
        ec.LoadFromAssetAsync(addressableName);
        m_entityConfigs.Add(crc, ec);
    }
    
    enum EntityId : UInt32
    {
        Coin = 0x5569975d, // old coin, unused
        PickupCoin = 0xe4c651aa,
        PickupRain = 0x06fd4c5a,
        PickupExplosion = 0xf75fd92f,
        PickupMagnet = 0x235a41dd,
    };

    // Start is called before the first frame update
    void Start()
    {
        // Debug.Log("GameManager - Start");
        this.obstacles = GameObject.FindWithTag("Obstacles");
/*
    #ROCKA           = 0xd058353c,
    #ROCKB           = 0x49516486,
    #ROCKC           = 0x3e565410,
    #ROCKD           = 0xa032c1b3,
    #ROCKE           = 0xd735f125,
    #ROCKF           = 0x4e3ca09f,
*/
/*
    #SEAWEEDA        = 0x6fe93bef,
    #SEAWEEDB        = 0xf6e06a55,
    #SEAWEEDC        = 0x81e75ac3,
    #SEAWEEDD        = 0x1f83cf60,
    #SEAWEEDE        = 0x6884fff6,
    #SEAWEEDF        = 0xf18dae4c,
    #SEAWEEDG        = 0x868a9eda,

 */
/*
    #COIN            = 0x5569975d, // old coin, unused
    #PICKUPCOIN      = 0xe4c651aa,    
    #PICKUPRAIN      = 0x06fd4c5a,
    #PICKUPEXPLOSION = 0xf75fd92f,
    #PICKUPMAGNET    = 0x235a41dd,
 */
        
        try
        {
            AddEntityConfig(0x00000000, "ObstaclesBlock1x1");
            
            AddEntityConfig(0xd058353c, "ObstaclesRockA");
            AddEntityConfig(0x49516486, "ObstaclesRockB");
            AddEntityConfig(0x3e565410, "ObstaclesRockC");
            AddEntityConfig(0xa032c1b3, "ObstaclesRockD");
            AddEntityConfig(0xd735f125, "ObstaclesRockE");
            AddEntityConfig(0x4e3ca09f, "ObstaclesRockF");
            
            AddEntityConfig(0x6fe93bef, "ObstaclesSeaweedA");
            AddEntityConfig(0xf6e06a55, "ObstaclesSeaweedB");
            AddEntityConfig(0x81e75ac3, "ObstaclesSeaweedC");
            AddEntityConfig(0x1f83cf60, "ObstaclesSeaweedD");
            AddEntityConfig(0x6884fff6, "ObstaclesSeaweedE");
            AddEntityConfig(0xf18dae4c, "ObstaclesSeaweedF");
            AddEntityConfig(0x868a9eda, "ObstaclesSeaweedG");
            
//            AddEntityConfig(0xe4c651aa, "PickupsCoin");
            AddEntityConfig((UInt32)EntityId.PickupCoin, "PickupsCoin");
            AddEntityConfig((UInt32)EntityId.PickupRain, "PickupsRain");
            AddEntityConfig((UInt32)EntityId.PickupExplosion, "PickupsExplosion");
            AddEntityConfig((UInt32)EntityId.PickupMagnet, "PickupsMagnet");
            
        }
        catch (Exception e)
        {
            Debug.Log($"Exception adding entity configs {e}");
            // Console.WriteLine(e);
            throw;
        }

        StartCoroutine(LoadZones());

        //Debug.Log("Started.");
    }

    private IEnumerator LoadZone(string zone_file)
    {
        // Debug.Log("Loading " + zone_file);
        var zl = new ZoneLoader(zone_file);
        var czl = zl.Load();
        //var zl = StartCoroutine(ZoneLoad.Load(zone_file));
        while (czl.MoveNext())
        {
            yield return null;    
        }

        var z = zl.Zone();
        //var z = LoadNewZone(zone_file);
        
        _zones.Add(z);

        //yield return null;
        yield break;
    }
    private IEnumerator LoadZones()
    {
        // :HACK: needs cleanup

        List<string> zones = new List<string>();
        var zone_path = Application.streamingAssetsPath + "/Zones/";
        if (!zone_path.StartsWith("http://") && !zone_path.StartsWith("https://"))
        {
            //Debug.Log($"Scanning for zones in {zone_path}");
            try
            {
                var zone_pattern = "*.nzne";
                var zone_files = Directory.GetFiles(zone_path, zone_pattern);
                foreach (var zone_file in zone_files)
                {
                    var zone = Path.GetFileName(zone_file);
                    if (!zones.Contains(zone))
                    {
                        zones.Add(zone);
                    }
                }
            }
            catch (Exception ex)
            {
                Debug.Log($"Exception scanning zones {ex}");
                // don't rethrow, just continue
            }
        }
        else
        {
            //Debug.Log($"Not scanning for zones in {zone_path}");
        }

        // Debug.Log("ZoneLists: ", zoneLists);
        if (zoneLists.Count > 0)
        {
            foreach (var zlo in zoneLists)
            {
                //Debug.Log($"ZoneListObject: {zlo.name}");
                var zl = zlo.GetComponent<ZoneList>();
                //Debug.Log($"ZoneList: {zl.name}");
                var zs = zl.GetZones();
                if (zs.Count > 0)
                {
                    Debug.Log($"Adding {zs.Count} zones");
                    foreach (var zone in zs)
                    {
                        if (!zones.Contains(zone))
                        {
                            zones.Add(zone);
                        }
                    }
                }
                else
                {
                    //Debug.Log("Empty ZoneList");
                }
            }
        }
        else
        {
            //Debug.Log("No ZoneLists to add!");
        }

        // zone_path = "https://games.omnimad.net/alpha/fiiish-v3/unity/StreamingAssets/Zones/";
        if (zones.Count > 0)
        {
            //Debug.Log($"Loading {zones.Count} zones");
            foreach (var zone in zones)
            {
                var zone_file = zone_path + zone;
                var c = LoadZone(zone_file);
                while (c.MoveNext())
                {
                    yield return null;
                }
                //yield return LoadZone(zone_file);
            }
        }
        else
        {
            Debug.LogWarning("No zones to load");
        }

        if (zones.Count > 0)
        {
            _currentZone = _zones[0];
        }

        QueueInitialZones();

        _isFullyLoaded = true;
        yield break;
    }
    
    void OnDisable()
    {
        foreach (var ec in m_entityConfigs.Values)
        {
            ec.OnDisable();
        }
    }

    public int Coins()
    {
        return _coins;
    }

    public int TakeCoins()
    {
        var c = _coins;
        _coins = 0;
        return c;
    }
    
    public int CurrentDistanceInMeters()
    {
        
        return (int)Mathf.Floor(_distance / pixelsPerMeter);
    }
    
    public int TakeCurrentDistanceInMeters()
    {
        var d = CurrentDistanceInMeters();
        _distance = 0.0f;
        return d;
    }

    // Update is called once per frame
    void Update()
    {
#if UNITY_EDITOR        
        if (Input.GetKeyDown("c"))
        {
            _coins += 100;
        }
        if (Input.GetKeyDown("d"))
        {
            _distance += 100*pixelsPerMeter;
        }
#endif        
        if (_paused)
        {
            return;
        }
        if (this.moving)
        {
            float speed = CurrentSpeed() * Time.deltaTime;
            _zonePos.x += speed;
            _distance += speed;
            if (_zonePos.x > _currentZone.GetSize().x)
            {
                SpawnZone();
            }
        }
        UpdatePickups();
    }

    void UpdatePickups()
    {
        var fishes = GameObject.FindGameObjectsWithTag("Fishes");
        var pickups = GameObject.FindGameObjectsWithTag("Pickups");

        // Debug.Log("Fish Count:" + fishes.Length);
        // Debug.Log("Pickup Count:" + pickups.Length);
        var closest = float.MaxValue;
        
        foreach (var fish in fishes)
        {
            var f = fish.GetComponent<Fish>();
            if (f == null)
            {
                // Debug.LogWarning( "Fish could not be found in " + fish.name );
                continue;
            }
            if (!f.IsAlive())
            {
                // Debug.LogWarning("Fish is NOT alive");
                continue;
            }

            var fp = fish.transform.localPosition;
            fp.z = 0.0f;
            var pickup_range_sqr = f.PickupRange() * f.PickupRange();
            var magnet_range_sqr = f.MagnetRange() * f.MagnetRange();
            var magnet_speed = f.MagnetSpeed();
            
            
            foreach (var pickup in pickups)
            {
                var p = pickup.GetComponent<Pickup>();
                if (p == null)
                {
                    // Debug.LogWarning( "Pickup could not be found in " + pickup.name );
                    continue;
                }

                if (!p.IsAlive())
                {
                    // Debug.LogWarning("Pickup is NOT alive");
                    continue;
                }
                
                var pp = pickup.transform.localPosition;
                pp.z = 0.0f;
                var delta = pp - fp;
                var ls = delta.sqrMagnitude;
                // Debug.Log( "fp: " + fp );
                // Debug.Log( "pp: " + pp );
                //Debug.Log( "ls: " + ls );
                //Debug.Log( "pickup_range_sqr: " + pickup_range_sqr );
                // ls = float.MaxValue; // far far away
                if (ls < closest)
                {
                    closest = ls;
                }
                if (ls < pickup_range_sqr)
                {
                    // Debug.Log( "Collect: " + pickup );
                    p.Collect();
                    // :TODO: play PICKED_COIN
                    var effect = p.Effect();
                    switch (effect)
                    {
                        case PickupEffect.Magnet:
                            f.ApplyMagnetBoost( 3.0f, 10.0f, 1.5f );
                            break;
                        case PickupEffect.Explosion:
                            SpawnCoinExplosion( pickup.transform.position );
                            break;
                        case PickupEffect.Rain:
                            _coinRainDuration += 3.0f;
                            _coinRainPerSecond = 33.3f;
                            break;
                        case PickupEffect.None:
                            break;
                    } 
                    _coins += p.CoinValue();
                    var audioEffect = p.CollectAudioEffect();
                    onAudioEffectTriggered.Invoke(audioEffect);
                    Destroy( pickup );
                } else if (ls < magnet_range_sqr)
                {
                    var speed = -magnet_speed * Time.deltaTime;
                    delta.Normalize();
                    delta = speed * delta;
                    pickup.transform.position += delta;
                }
            }
            if(Input.GetKeyDown("e"))
            {
                SpawnCoinExplosion( new Vector3( 10.0f, 0.0f, 0.0f ) + fish.transform.position );
            }
        }
        //Debug.Log("Closest: "+closest);
        if (closest < _closest_ever)
        {
            _closest_ever = closest;
        }
        //Debug.Log("Closest Ever: "+_closest_ever);

        if (_coinRainDuration > 0.0f)
        {
            // Debug.Log("_coinRainDuration > 0.0f"+_coinRainDuration);
            var t = Mathf.Min( Time.deltaTime, _coinRainDuration );
            _coinRainCounter += t * _coinRainPerSecond;
            _coinRainDuration -= Time.deltaTime;
            
            var cc = (int)_coinRainCounter;
            if (cc > 0)
            {
                _coinRainCounter -= cc;

                SpawnCoins(cc);
            }
        }
        
    }

    private void SpawnCoinExplosion(Vector3 position)
    {
        float z = position.z;
        position.x += 120.0f;
        
        EntityConfig ec;
        if (m_entityConfigs.TryGetValue((UInt32)EntityId.PickupCoin, out ec))
        {
            if (ec.handle.Result != null)
            {

                var amount = 50;
                var periodOffset = Random.Range(0.0f, 6.28f);
                var periodScale = Random.Range(0.9f, 1.1f);
                for (int i = 0; i < amount; ++i)
                {
                    position.z = z + NextPickupZBias();
                    GameObject go = Instantiate(ec.handle.Result, position,
                        Quaternion.identity);
                    go.transform.SetParent(this.obstacles.transform, false);
                    var obstacle = go.GetComponent<Obstacle>();
                    if (obstacle != null)
                    {
                        float prevDuration;// = 0.0f;
                        {
                            var target = Vector2.right * 200.0f;
                            var duration = 0.15f;
                            var rotation = (i+0.5f - (amount / 2.0f)) / amount;
                            target *= 1.25f+( 0.125f*Mathf.Sin( ( rotation+periodOffset )*25.0f*periodScale ) );
                            // Debug.Log( "rotation " + rotation );
                            target = RotateDeg( target, rotation*120.0f);
                            var velocity = target / duration;
                            velocity.x += speed;
                            obstacle.SetVelocity(velocity);

                            prevDuration = duration;
                            target *= Random.Range(0.5f, 0.75f);
                            duration = 0.5f;
                            velocity = target / duration;
                            
                            obstacle.AddTimedVelocity( prevDuration, velocity );
                            prevDuration = duration;
                        }
                        prevDuration *= Random.Range(0.5f, 1.2f);
                        obstacle.AddTimedVelocity( prevDuration, Vector2.zero );
                    }
                }
            }
        }
    }
    
    // :TODO: factor out intp helper
    static Vector2 RotateDeg(Vector2 v, float degrees) {
        float s = Mathf.Sin(degrees * Mathf.Deg2Rad);
        float c = Mathf.Cos(degrees * Mathf.Deg2Rad);
		
        float tx = v.x;
        float ty = v.y;
        v.x = (c * tx) - (s * ty);
        v.y = (s * tx) + (c * ty);
        return v;
    }
    private float NextPickupZBias()
    {
        _pickupZBias = (_pickupZBias + 0.0001f)%1.0f;
        return _pickupZBias;
    }
    private void SpawnCoins(int amount)
    {
        EntityConfig ec;
        if (m_entityConfigs.TryGetValue((UInt32)EntityId.PickupCoin, out ec))
        {
            if (ec.handle.Result != null)
            {
                for (int i = 0; i < amount; ++i)
                {
                    var position = new Vector3(Random.Range(0.0f, 1000.0f), Random.Range(600.0f, 1100.0f), 0.0f+NextPickupZBias());
                    GameObject go = Instantiate(ec.handle.Result, position,
                        Quaternion.identity);
                    go.transform.SetParent(this.obstacles.transform, false);
                    var obstacle = go.GetComponent<Obstacle>();
                    if (obstacle != null)
                    {
                        obstacle.SetVelocity( new Vector2( Random.Range( -10.0f, 10.0f ), Random.Range(-400.0f, -250.0f) ) );
                    }
                }
            }
            else
            {
                Debug.LogWarning("No handle in entity config for PickupCoin");    
            }
        }
        else
        {
            Debug.LogWarning("No entity config found for PickupCoin");
        }
    }
    private void QueueInitialZones()
    {
        string[] initialZones =
        {
            "0000_ILoveFiiish",
        };

        _queuedZones.Clear();
        foreach (var zn in initialZones)
        {
            _queuedZones.Add( zn );   
        }
    }
    private NewZone PickNextZone()
    {
        string[] blockedZones =
        {
            "0000_Start",
            "0000_ILoveFiiish",
            "0000_ILoveFiiishAndRust",
            "8000_MarketingScreenshots",
            "9998_AssetTest",
            "9999_Test"
        };

        if (_queuedZones.Count > 0)
        {
            var nextZoneName = _queuedZones[0];
            _queuedZones.RemoveAt( 0 );
            var nextZone = _zones.Find(e => e.name == nextZoneName);
            if (nextZone != null)
            {
                return nextZone;
            }
            else
            {
                Debug.LogWarning("Queued zone not found: " + nextZoneName );
            }
        }
        var candidateZoneIndices = new List<int>();

        for (int i = 0; i < _zones.Count; i++)
        {
            var z = _zones[i];
            if (Array.Exists(blockedZones, e => e == z.name))
            {
                continue;
            }
            candidateZoneIndices.Add( i );
        }
        if( candidateZoneIndices.Count == 0 )
        {
            return null;
        }
        //var rnd = new Random();
        //var r = rnd.Next(candidateZoneIndices.Count);
        var r = Random.Range(0, candidateZoneIndices.Count);
        var zi = candidateZoneIndices[r];
        return _zones[zi];
    }

    public bool isFullyLoaded()
    {
        return _isFullyLoaded;
    }
    
    public void SpawnZone()
    {
        if (!_isFullyLoaded)
        {
            while (!_isFullyLoaded)
            {
                Debug.Log("SpawnZone waiting to be fully loaded");
            }
        }
        if( this.obstacles != null )
        {
            var nextZone = PickNextZone();
            if (nextZone != null)
            {
                var missingAssetCrcs = new HashSet<uint>();
                
                _currentZone = nextZone;
                string[] rendered_layers = { "Obstacles", "Obstacles_01", "Pickups_00" };
                var layerOffsetZ = 1.0f;
                foreach (NewZoneLayer l in _currentZone.Layers())
                {
                    layerOffsetZ -= 0.1f;
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
                                GameObject go = Instantiate(ec.handle.Result, new Vector3(o.PosX()+zoneSpawnOffset, o.PosY(), 0.0f+layerOffsetZ+NextPickupZBias()),
                                    Quaternion.Euler(0.0f, 0.0f, o.Rotation()));
                                go.transform.SetParent(this.obstacles.transform, false);
                            }
                            else
                            {
                                if (m_entityConfigs.TryGetValue(0x00000000, out ec))
                                {
                                    if (ec.handle.Result != null)
                                    {
                                        GameObject go = Instantiate(ec.handle.Result,
                                            new Vector3(o.PosX() + zoneSpawnOffset, o.PosY(), 0.0f + layerOffsetZ),
                                            Quaternion.Euler(0.0f, 0.0f, o.Rotation()));
                                        go.transform.SetParent(this.obstacles.transform, false);
                                    }
                                }
                            }
                        }
                        else
                        {
                            // Debug.Log( "Entity Config not found for " + crc.ToString("X") );
                            missingAssetCrcs.Add(crc);
                        }
                    }
                }

                foreach (var crc in missingAssetCrcs)
                {
                    Debug.Log("Missing Assets CRC: " + crc.ToString("X"));
                }
                _zonePos = new Vector2();
                OnZoneChanged.Invoke(_currentZone.name);
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

        if ( this.moving && !_paused ) {
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
        var progress = _zonePos.x / _currentZone.GetSize().x;
        return Mathf.Clamp01( progress );
    }

    public void GotoNextZone()
    {
        Debug.Log("GotoNextZone");
        Cleanup();
        SpawnZone();
    }

    public void PrepareRespawn()
    {
        Cleanup();
        QueueInitialZones();
        _coins = 0;
        _coinRainDuration = 0.0f;
        _distance = 0.0f;
    }

    public bool TogglePause()
    {
        _paused = !_paused;

        if (_paused)
        {
            Debug.Log("Paused");
        }
        else
        {
            Debug.Log("Resumed");
        }
        return _paused;
    }

    public bool IsPaused()
    {
        return _paused;
    }

    public void OnFishStateChanged(Game.State state)
    {
        onStateChanged?.Invoke(state);
    }
}
