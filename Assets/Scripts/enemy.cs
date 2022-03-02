using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;

public class enemy : MonoBehaviour
{
    // Start is called before the first frame update
    public Transform goal;
    public float viewRadius = 20.0f;      // 代表视野最远的距离
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
        // 获得最左边那条射线的向量，相对正前方，角度是-45
        Vector3 forward_left = Quaternion.Euler(0, -45, 0) * transform.forward * viewRadius;
        // 依次处理每一条射线
        for (int i = 0; i <= viewAngleStep; i++)
        {
            // 每条射线都在forward_left的基础上偏转一点，最后一个正好偏转90度到视线最右侧
            Vector3 v = Quaternion.Euler(0, (90.0f / viewAngleStep) * i, 0) * forward_left; ;

            // 创建射线
            Ray ray = new Ray(transform.position, v);
            RaycastHit hitt = new RaycastHit();
            // 射线只与两种层碰撞，注意名字和你添加的layer一致，其他层忽略
            int mask = LayerMask.GetMask("Obstacle", "Enemy");
            Physics.Raycast(ray, out hitt, viewRadius, mask);

            // Player位置加v，就是射线终点pos
            Vector3 pos = transform.position + v;
            if (hitt.transform != null)
            {
                // 如果碰撞到什么东西，射线终点就变为碰撞的点了
                pos = hitt.point;
            }
            // 从玩家位置到pos画线段，只会在编辑器里看到
            Debug.DrawLine(transform.position, pos, Color.red); ;

            // 如果真的碰撞到敌人，进一步处理
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
