using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class player : MonoBehaviour
{
    public Rigidbody rd;
    float rushTime = 5.0f;          //�ɳ��ʱ��
    float waitTime = 1.0f;          //�ȴ�ʱ��
    public Slider slider;
    public float speed = 0f;        //�ٶ�
    public float breath = 1.0f;     //��Ϣֵ
    public float speed_a;           //��¼��ʼ�ٶȵ�ֵ
    public float direct_y;          //��ת�Ƕ�
    public double sin_1, cos_1;     //��������������cos��sin
    Animator ator;
    Vector3 direct;
    void Start()
    {
        rd = GetComponent<Rigidbody>();
        slider.value = 1;
        slider.gameObject.SetActive(false);
        speed_a = speed;
        direct = transform.localEulerAngles;
        if (direct.y > 180)
        {
            direct.y = direct.y - 360;
        }
        direct_y = direct.y;
        //Debug.Log("direct_y=" + direct_y);
        sin_1 = Mathf.Sin(Mathf.Deg2Rad * direct_y);
        cos_1 = Mathf.Cos(Mathf.Deg2Rad * direct_y);
        //Debug.Log("sin_1=" + sin_1 + " cos_1=" + cos_1);
        ator = transform.GetComponent<Animator>();
    }
    void Update()
    {
        RushTime();
    }
    void FixedUpdate()
    {
        Move();
    }

    private void Move()
    {
        float h = Input.GetAxis("Horizontal");
        float v = Input.GetAxis("Vertical");
        //Debug.Log(h);
        Vector3 sped = new Vector3(h, 0, v);
        sped = sped.normalized;
        Vector3 sped_x = sped;
        //Debug.Log("sped.x * sin_1=" + sped.z * cos_1 + " sped.x * sin_1= " + sped.x * sin_1);
        sped.x = (float)(sped_x.x * cos_1 + sped_x.z * sin_1);
        sped.z = (float)(sped_x.z * cos_1 - sped_x.x * sin_1);
        //sped.x = (float)(sped_x.x * cos_1 - sped_x.z * sin_1);
        //sped.z = (float)(sped_x.z * cos_1 + sped_x.x * sin_1);
        if(sped!=Vector3.zero)
        {
            ator.SetBool("isRun", true);
        }
        else
        {
            ator.SetBool("isRun", false);
        }
        transform.Translate(sped * Time.deltaTime * speed, Space.World);
        transform.LookAt(transform.position + sped);

    }
    private void RushTime()
    {
        slider.value = rushTime / 5;
        if (Input.GetKey(KeyCode.LeftShift) && rushTime > 0)//��̼�ʱ
        {
            slider.gameObject.SetActive(true);
            waitTime = 2;
            rushTime -= Time.deltaTime;
            if(speed==speed_a)
            speed *= 2;
        }
        else
        {
            speed = speed_a;
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
