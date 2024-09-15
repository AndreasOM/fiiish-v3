using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Obstacle : MonoBehaviour
{

    private GameManager gameManager = null;

    // Start is called before the first frame update
    void Start()
    {
        this.gameManager = GameObject.FindObjectOfType<GameManager>();

        Debug.Log( "Obstacle - Speed: " + this.gameManager.speed );
    }

    // Update is called once per frame
    void Update()
    {
        if( this.gameManager != null ) {
            float speed = -this.gameManager.CurrentSpeed() * Time.deltaTime;
            /*
            if (transform.eulerAngles.z != 0.0f)
            {
                speed = -speed;
            }
            */
            transform.localPosition = transform.localPosition + new Vector3( speed, 0.0f, 0.0f );
            if( transform.localPosition.x < -1200.0 ) {
                if( this.gameManager.wrapWorld ) {
                    transform.localPosition = transform.localPosition + new Vector3( 2400.0f, 0.0f, 0.0f );
                } else {
                    Destroy( this.gameObject );
                }
            }
        }        
    }
}
