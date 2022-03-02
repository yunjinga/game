using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;

public class enemy : MonoBehaviour
{
    // Start is called before the first frame update
    public Transform goal;
    public float viewRadius = 20.0f;      // ������Ұ��Զ�ľ���
    public float viewAngleStep = 30f;
    public float waitTime = 0f;
    public Vector3 begin;
    public float waring = 0;
    public float waringTime=0;
    void Start()
    {
        begin = transform.position;
    }

    // Update is called once per frame
    void Update()
    {
        DrawFieldOfView();
    }
    void DrawFieldOfView()
    {
        // ���������������ߵ������������ǰ�����Ƕ���-45
        Vector3 forward_left = Quaternion.Euler(0, -45, 0) * transform.forward * viewRadius;
        // ���δ���ÿһ������
        for (int i = 0; i <= viewAngleStep; i++)
        {
            // ÿ�����߶���forward_left�Ļ�����ƫתһ�㣬���һ������ƫת90�ȵ��������Ҳ�
            Vector3 v = Quaternion.Euler(0, (90.0f / viewAngleStep) * i, 0) * forward_left; ;

            // ��������
            Ray ray = new Ray(transform.position, v);
            RaycastHit hitt = new RaycastHit();
            // ����ֻ�����ֲ���ײ��ע�����ֺ�����ӵ�layerһ�£����������
            int mask = LayerMask.GetMask("Obstacle", "Enemy");
            Physics.Raycast(ray, out hitt, viewRadius, mask);

            // Playerλ�ü�v�����������յ�pos
            Vector3 pos = transform.position + v;
            if (hitt.transform != null)
            {
                // �����ײ��ʲô�����������յ�ͱ�Ϊ��ײ�ĵ���
                pos = hitt.point;
            }
            // �����λ�õ�pos���߶Σ�ֻ���ڱ༭���￴��
            Debug.DrawLine(transform.position, pos, Color.red); ;

            // ��������ײ�����ˣ���һ������
            if (hitt.transform != null && hitt.transform.gameObject.layer == LayerMask.NameToLayer("Enemy"))
            {
                //OnEnemySpotted(hitt.transform.gameObject);
                waitTime = 2.0f;
            }
        }
        if(waitTime>0)
        {
            waitTime -= Time.deltaTime;
            runToPlayer();
        }
        else
        {
            NavMeshAgent agent = GetComponent<NavMeshAgent>();
            agent.destination = begin;
        }
        getbreathe();
        Debug.Log(waring);
    }
    void runToPlayer()
    {
        NavMeshAgent agent = GetComponent<NavMeshAgent>();
        agent.destination = goal.position;
    }
    void getbreathe()
    {
        float distance = Vector3.Distance(goal.position, transform.position);
        if(distance<=50)
        {
            waring += goal.gameObject.GetComponent<player>().breath;
            waringTime = 2;
        }
        if (waring >= 100)
        {
            waitTime = 2.0f;
            waring = 0;
        }
        if (waring > 0&&distance>100)
        {
            if(waringTime > 0)
            waringTime -= Time.deltaTime;
            else if(waringTime<=0)
            {
                waring-=2;
            }
        }

    }
    
        
}
