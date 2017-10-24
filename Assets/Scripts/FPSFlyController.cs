using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FPSFlyController : MonoBehaviour
{
    public float Speed;

    private Transform _transform;
    // Use this for initialization
    void Start()
    {
        _transform = transform;
        Cursor.lockState = CursorLockMode.Locked;
    }

    // Update is called once per frame
    void Update()
    {
        float mouseX = Input.GetAxis("Mouse X");
        float mouseY = -Input.GetAxis("Mouse Y");

        float Horizontal = Input.GetAxis("Horizontal");
        float Vertical = Input.GetAxis("Vertical");
        float Up = Input.GetAxis("Up");

        _transform.Rotate(0, mouseX * Mathf.Rad2Deg * Time.deltaTime, 0, Space.World);
        _transform.Rotate(mouseY * Mathf.Rad2Deg * Time.deltaTime, 0, 0, Space.Self);

        _transform.Translate(Vector3.ClampMagnitude(_transform.forward * Vertical + _transform.right * Horizontal + Vector3.up * Up, 1) * Speed * Time.deltaTime, Space.World);
    }
}
