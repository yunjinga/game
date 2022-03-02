using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class player : MonoBehaviour
{
    public Rigidbody rd;
    float rushTime = 5.0f;//可冲刺时间
    float waitTime = 1.0f;//等待时间
    public Slider slider;
    public float speed = 10f;//速度
    public float breath = 1.0f;
    void Start()
    {
        rd = GetComponent<Rigidbody>();
        slider.value = 1;
        slider.gameObject.SetActive(false);
    }
    void Update()
    {
        float h = Input.GetAxis("Horizontal");
        float v = Input.GetAxis("Vertical");
        //Debug.Log(h);
        Vector3 sped= new Vector3(h, 0, v);
        sped = sped.normalized;
        rd.velocity = sped * speed;
        slider.value = rushTime / 5;
        if (Input.GetKey(KeyCode.LeftShift) && rushTime > 0)//冲刺计时
        {
            slider.gameObject.SetActive(true);
            waitTime = 2;
            rushTime -= Time.deltaTime;
            rd.velocity *= 2;
        }
        else
        {
            if (waitTime > 0 && !Input.GetKey(KeyCode.LeftShift) && rushTime < 5)
            {
                waitTime -= Time.deltaTime;
            }
            else if (rushTime < 5 && waitTime <= 0)
            {
                rushTime += Time.deltaTime;
                if (rushTime >= 5)
                {
                    slider.gameObject.SetActive(false);
                    waitTime = 2.0f;
                    rushTime = 5;
                }
            }
        }
    }
}
