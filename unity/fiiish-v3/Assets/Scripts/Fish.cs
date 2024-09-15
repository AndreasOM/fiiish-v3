using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Fish : MonoBehaviour
{
    enum State {
        WaitingForStart,
        Swimming,
        Dying,
        Dead,
        Respawning,
    }
    enum Direction {
        Up,
        Neutral,
        Down,
    }

    private float rotation_speed = 120.0f;

    private State state = State.WaitingForStart;
    private Direction direction = Direction.Neutral;


    private Animator animator;
    private GameManager gameManager = null;

    // Start is called before the first frame update
    void Start()
    {
        this.gameManager = GameObject.FindObjectOfType<GameManager>();

        animator = GetComponent<Animator>(); 
        animator.Play("FishSwim");
    }

    // Update is called once per frame
    void Update()
    {
        switch ( this.state ) {
            case State.WaitingForStart:
                UpdateWaitingForStart();
                break;
            case State.Swimming:
                UpdateSwimming();
                break;
            case State.Dead:
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
        if(Input.GetKey(KeyCode.Space))
        {
            this.direction = Direction.Down;
        } else {
            this.direction = Direction.Up;
        }

        if(Input.GetKey("k"))
        {
            GotoDying();
        }

    }
    void UpdateDead()
    {
        if(Input.GetKey(KeyCode.Space))
        {
            GotoRespawning();
        }
    }
    void GotoRespawning()
    {
        this.state = State.Respawning;
        animator.Play("FishSwim");
        var pos = transform.localPosition;
        pos.x = -1024.0f;
        pos.y = 0.0f;
        transform.localPosition = pos;
        transform.localEulerAngles = new Vector3( 0.0f, 0.0f, 0.0f );
        if( this.gameManager != null ) {
            this.gameManager.Cleanup();
        }
    }
    void GotoWaitingForStart()
    {        
        this.state = State.WaitingForStart;
        Debug.Log( "WaitingForStart" );
    }
    void GotoSwimming()
    {
        this.state = State.Swimming;
        if( this.gameManager != null ) {
            this.gameManager.ResumeMovement();
            this.gameManager.SpawnZone();
        }
    }

    void GotoDying()
    {
        this.state = State.Dying;

        // change animation
        animator.Play("FishDying");

        if( this.gameManager != null ) {
            this.gameManager.PauseMovement();
        }
    }

    void FixedUpdate()
    {
        switch ( this.state ) {
            case State.Swimming:
                FixedUpdateSwimming();
                break;
            case State.Dying:
                FixedUpdateDying();
                break;
            case State.Respawning:
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
            this.state = State.Dead;
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
        if ( this.state == State.Swimming ) {
            GotoDying();
        }
    }
}
