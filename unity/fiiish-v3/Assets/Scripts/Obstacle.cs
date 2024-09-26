using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Obstacle : MonoBehaviour
{
    class TimedVelocity
    {
        public float duration;
        public Vector2 velocity;
    }

    private GameManager gameManager = null;
    private Vector3 _velocity = Vector3.zero;
    private List<TimedVelocity> _timedVelocities = new List<TimedVelocity>();

    // Start is called before the first frame update
    void Start()
    {
        this.gameManager = GameObject.FindObjectOfType<GameManager>();

        // Debug.Log( "Obstacle - Speed: " + this.gameManager.speed );
    }

    // Update is called once per frame
    void Update()
    {
        // :TODO: handle world speed factor, and pause
        if (_timedVelocities.Count > 0)
        {
            _timedVelocities[0].duration -= Time.deltaTime;
            if (_timedVelocities[0].duration <= 0)
            {
                _velocity.x = _timedVelocities[0].velocity.x;
                _velocity.y = _timedVelocities[0].velocity.y;
                _timedVelocities.RemoveAt(0);
            }
        }
        if( this.gameManager != null ) {
            float speed = -this.gameManager.CurrentSpeed() * Time.deltaTime * 1.0f;
            /*
            if (transform.eulerAngles.z != 0.0f)
            {
                speed = -speed;
            }
            */
            transform.localPosition = transform.localPosition + new Vector3( speed, 0.0f, 0.0f ) + Time.deltaTime * _velocity;
            if( transform.localPosition.x < -1200.0 || transform.localPosition.y > 2000.0 || transform.localPosition.y < -2000.0 ) {
                if( this.gameManager.wrapWorld ) {
                    transform.localPosition = transform.localPosition + new Vector3( 2400.0f, 0.0f, 0.0f );
                } else {
                    Destroy( this.gameObject );
                }
            }
        }        
    }

    public void SetVelocity(Vector2 velocity)
    {
        _velocity.x = velocity.x;
        _velocity.y = velocity.y;
    }

    public void AddTimedVelocity( float duration, Vector2 velocity)
    {
        var tv = new TimedVelocity
        {
            duration = duration,
            velocity = velocity,
        };
        _timedVelocities.Add( tv );
    }
}
