using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

public class Fish : MonoBehaviour
{
    public Game game = null;
    public UnityEvent<Game.State> onStateChanged;

    enum Direction {
        Up,
        Neutral,
        Down,
    }

    public float pickup_range = 10.0f;
    public float magnet_range = 200.0f;
    public float magnet_speed = 300.0f;
    
    private float rotation_speed = 120.0f;

    private Game.State _state = Game.State.WaitingForStart;
    private Direction direction = Direction.Neutral;

    private float _magnet_range_boost = 1.0f;
    private float _magnet_speed_boost = 1.0f;
    private float _magnet_boost_duration = 0.0f;

    private Animator animator;
    private GameManager gameManager = null;

    // Start is called before the first frame update
    void Start()
    {
        this.gameManager = GameObject.FindObjectOfType<GameManager>();

        animator = GetComponent<Animator>(); 
        animator.Play("FishSwim");
    }

    public void ApplyMagnetBoost(float range, float speed, float duration)
    {
        _magnet_range_boost = range;
        _magnet_speed_boost = speed;
        _magnet_boost_duration = duration;
    }
    public float PickupRange()
    {
        return pickup_range;
    }
    public float MagnetRange()
    {
        return magnet_range * _magnet_range_boost;
    }
    public float MagnetSpeed()
    {
        return magnet_speed * _magnet_speed_boost;
    }
    public bool IsAlive()
    {
        switch (this._state)
        {
            case Game.State.WaitingForStart: return false;
            case Game.State.Swimming:        return true;
            case Game.State.Dying:           return false;
            case Game.State.Dead:            return false;
            case Game.State.Respawning:      return false;
        }

        return false;
    }
    
    // Update is called once per frame
    void Update()
    {
        if (game.IsPaused())
        {
            animator.speed = 0.0f;
        }
        else
        {
            animator.speed = 1.0f;
        }
        switch ( this._state ) {
            case Game.State.WaitingForStart:
                UpdateWaitingForStart();
                break;
            case Game.State.Swimming:
                UpdateSwimming();
                break;
            case Game.State.Dead:
                UpdateDead();
                break;
            default:
                break;
        }
    }

    void UpdateWaitingForStart()
    {
        if(Input.GetKey(KeyCode.Space))
        {
            GotoSwimming();
        }

    }
    void UpdateSwimming()
    {
        if (game.IsPaused())
        {
            return;
        }
        if(Input.GetKey(KeyCode.Space))
        {
            this.direction = Direction.Down;
        } else {
            this.direction = Direction.Up;
        }
#if UNITY_EDITOR
        if(Input.GetKeyDown("k"))
        {
            GotoDying();
        }
#endif
        if (_magnet_boost_duration > 0.0f)
        {
            _magnet_boost_duration -= Time.deltaTime;
            if (_magnet_boost_duration < 0.0f)
            {
                _magnet_boost_duration = 0.0f;
                _magnet_range_boost = 1.0f;
                _magnet_speed_boost = 1.0f;
            }
        }
    }
    void UpdateDead()
    {
        if(Input.GetKey(KeyCode.Space))
        {
            GotoRespawning();
        }
    }

    void SetState(Game.State state)
    {
        this._state = state;
        onStateChanged?.Invoke(state);
    }
    void GotoRespawning()
    {
        SetState( Game.State.Respawning);
        
        animator.Play("FishSwim");
        var pos = transform.localPosition;
        pos.x = -1024.0f;
        pos.y = 0.0f;
        transform.localPosition = pos;
        transform.localEulerAngles = new Vector3( 0.0f, 0.0f, 0.0f );
        if( this.gameManager != null ){
            //this.gameManager.Cleanup();
            this.gameManager.PrepareRespawn();
        }
        _magnet_boost_duration = 0.0f;
        _magnet_range_boost = 1.0f;
        _magnet_speed_boost = 1.0f;
    }
    void GotoWaitingForStart()
    {        
        SetState( Game.State.WaitingForStart);
        Debug.Log( "WaitingForStart" );
    }
    void GotoSwimming()
    {
        SetState( Game.State.Swimming);
        if( this.gameManager != null ) {
            this.gameManager.ResumeMovement();
            this.gameManager.SpawnZone();
        }
    }

    void GotoDying()
    {
        SetState( Game.State.Dying);

        // change animation
        animator.Play("FishDying");

        if( this.gameManager != null ) {
            this.gameManager.PauseMovement();
        }
    }

    void FixedUpdate()
    {
        if (game.IsPaused())
        {
            return;
        }
        switch ( this._state ) {
            case Game.State.Swimming:
                FixedUpdateSwimming();
                break;
            case Game.State.Dying:
                FixedUpdateDying();
                break;
            case Game.State.Respawning:
                FixedUpdateRespawning();
                break;
            default:
                break;
        }
    }
/*
    fn get_angle_range_for_y(y: f32) -> (f32, f32) {
        let limit = 35.0;
        let range = 1.0 / 280.0;

        let a = (y.abs() * range).sin();
        // float a = Functions::getSin( Functions::getAbs( y )*range );
        let m = limit * (1.0 - a * a * a * a);
        // float m = limit*( 1.0-a*a*a*a );

        if y < 0.0 {
            (-limit, m)
        //            *pMinAngle = -limit;
        //            *pMaxAngle = m;
        } else {
            (-m, limit)
            //            *pMinAngle = -m;
            //            *pMaxAngle = limit;
        }
    }
*/
    
    ( float, float ) GetAngleRangeForY( float y ) {
        float limit = 35.0f;
        float range = 1.0f / 280.0f;

        float a = Mathf.Sin((Mathf.Abs(y) * range));
        float m = limit * (1.0f - a * a * a * a);

        if ( y > 0.0f ) {
            return (-limit, m);
        } else {
            return (-m, limit);
        }
        // return ( -35.0f, 35.0f );
    }
    

    void FixedUpdateSwimming()
    {
        Vector3 lea = transform.localEulerAngles;

        float rot_z = 0.0f;
        switch ( this.direction ) {
            case Direction.Up:
                rot_z = this.rotation_speed * Time.deltaTime;
                break;
            case Direction.Down:
                rot_z = -this.rotation_speed * Time.deltaTime;
                break;
            case Direction.Neutral:
                break;
        }        

        // :HACK: since unity normalizes angles to 0.0 -> 360.0
        if( lea.z > 180.0f ) {
            lea.z -= 360.0f;
        }

        lea.z = lea.z + rot_z;
        ( float min_a, float max_a ) = GetAngleRangeForY( transform.localPosition.y );

        // float ta = Mathf.Clamp( lea.z, min_a, max_a );
        // Debug.Log( "Clamp " + lea.z + " " + min_a + " " + max_a + "->" + ta );

        lea.z = Mathf.Clamp( lea.z, min_a, max_a );

        float a = lea.z;
        float dy = (Mathf.Sin(a / 57.2957795f)) * 350.0f * Time.deltaTime;

        transform.localPosition = transform.localPosition + new Vector3( 0.0f, dy, 0.0f );
        transform.localEulerAngles = lea;
    }

    void FixedUpdateDying()
    {
        transform.localPosition = transform.localPosition + new Vector3( 0.0f, 1.5f * 128.0f * Time.deltaTime, 0.0f );
        Vector3 lea = transform.localEulerAngles;
        // :HACK: since unity normalizes angles to 0.0 -> 360.0
        if( lea.z > 180.0f ) {
            lea.z -= 360.0f;
        }
        lea.z = Mathf.Min( 90.0f, lea.z + 60.0f*Time.deltaTime );
        transform.localEulerAngles = lea;

        if( transform.localPosition.y > 512.0+128.0 ) {
            SetState(Game.State.Dead);
            Debug.Log( "Dead" );
        }
    }

    void FixedUpdateRespawning()
    {
        transform.localPosition = transform.localPosition + new Vector3( 256.0f * Time.deltaTime, 0.0f, 0.0f );
        if ( transform.localPosition.x >= -512.0 ) {
            GotoWaitingForStart();
        }
    }


    private void OnTriggerEnter2D(Collider2D other)
    {
        Debug.Log( "Fish - Colliding");
        if ( this._state == Game.State.Swimming ) {
            GotoDying();
        }
    }
}
