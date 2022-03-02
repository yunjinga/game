using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class control : MonoBehaviour
{
    float _rotationX;
    float rotationY;
    public float sensitivityHor = 5.0f;
    public float sensitivityVert = 5.0f;
    public float minimumVert = -45.0f;
    public float maximumVert = 45.0f;
    public  Transform playerTransform;
    private Vector3 offset;
    // Start is called before the first frame update
    void Start()
    {
        offset = transform.position - playerTransform.position;
    }

    // Update is called once per frame
    void Update()
    {
        transform.position = playerTransform.position + offset;
        if (Input.GetMouseButton(1))
        {
            rotationY = transform.localEulerAngles.y + Input.GetAxis("Mouse X") * sensitivityHor;
            _rotationX -= Input.GetAxis("Mouse Y") * sensitivityVert;
            _rotationX = Mathf.Clamp(_rotationX, minimumVert, maximumVert);
            transform.localEulerAngles = new Vector3(_rotationX, rotationY, 0);
        }
    }
}
