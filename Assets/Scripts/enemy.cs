using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;


public class enemy : MonoBehaviour
{
    // Start is called before the first frame update
    public Transform goal;
    public float viewRadius = 20.0f;      // 代表视野最远的距离
    public float viewAngleStep = 30f; //射线数量
    public float waitTime = 0f; //等待时间
    public Vector3 begin;//开始时的位置
    public float waring = 0f;//警戒值
    public float waringTime = 0f;//寻敌时间
    private Vector3 beginrotation;//初始旋转值
    private Mesh mesh;
    public float distance_a;
    private Vector3[] vertices;//mesh的vertices
    int[] tringles;//mesh的tringles
    Vector2[] _uvs;//mesh的uv
    Quaternion targetPoint;
    bool b;
    Animator ator;  //动画组件
    MeshFilter mf;
    MeshRenderer mr;
    Shader shader;
    void Start()
    {
        mesh = new Mesh();
        mf = transform.gameObject.AddComponent<MeshFilter>();
        mr = transform.gameObject.AddComponent<MeshRenderer>();
        GetComponent<MeshFilter>().mesh = mesh;
        mesh.name = "mesh";
        _uvs = new Vector2[(int)(viewAngleStep + 1)];
        vertices = new Vector3[(int)viewAngleStep + 1];
        tringles = new int[((int)viewAngleStep - 1) * 3];
        vertices[0] = transform.position;

        begin = transform.localPosition;
        beginrotation = transform.localEulerAngles;

        targetPoint = Quaternion.Euler(beginrotation);
        ator = transform.GetComponent<Animator>();
    }

    // Update is called once per frame
    void Update()
    {
        DrawFieldOfView();
        Rotate();
    }
    void Rotate()//如果到达初始地点则恢复原本的面朝方向
    {
        Vector3 v = transform.localEulerAngles - beginrotation;
        if (Mathf.Abs(transform.position.x - begin.x) <= 0.1f && Mathf.Abs(transform.position.y - begin.y) <= 0.1f && Mathf.Abs(transform.position.z - begin.z) <= 0.1f)  //获得的数据为一位小数，但实际可能为好几位小数所以加个范围
        {
            transform.rotation = Quaternion.Slerp(transform.rotation, targetPoint, 3 * Time.deltaTime);//平滑转向
            ator.SetBool("isWalk", false);
        }
    }
    void DrawFieldOfView()
    {
        // 获得最左边那条射线的向量，相对正前方，角度是-45
        Vector3 forward_left = Quaternion.Euler(0, -45, 0) * transform.forward * viewRadius;
        // 依次处理每一条射线
        for (int i = 0; i < viewAngleStep; i++)
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
            vertices[i + 1] = pos;
            // 从玩家位置到pos画线段，只会在编辑器里看到
            Debug.DrawLine(transform.position, pos, Color.red); ;

            // 如果真的碰撞到敌人，进一步处理
            if (hitt.transform != null && hitt.transform.gameObject.layer == LayerMask.NameToLayer("Enemy"))
            {
                //OnEnemySpotted(hitt.transform.gameObject);
                waitTime = 2.0f;
            }
        }
        makeMesh();
        //Debug.Log(vertices[30]);
        if (waitTime > 0)//如果waitTime大于0则进行追击
        {
            waitTime -= Time.deltaTime;
            runToPlayer();
        }
        else
        {
            runToBegin();
        }
        getbreathe();
    }
    void makeMesh()//生成mesh
    {
        int tringles_x = 1;
        for (int i = 0; i < (int)viewAngleStep - 1 ; i++)
        {
            tringles[3 * i] = 0;
            tringles[3 * i + 1] = i + 1;
            tringles[3 * i + 2] = i + 2;
        }
        for (int i = 0; i < viewAngleStep - 1; i++)
        {
            Debug.Log("tringles[i * 3]=" + tringles[i * 3] + " tringles[i * 3 + 1]=" + tringles[i * 3 + 1] + " tringles[i * 3 + 2]=" + tringles[i * 3 + 2]);
        }
        
        
        mesh.vertices = vertices;
        mesh.triangles = tringles;
        mesh.RecalculateNormals();
        mf.mesh = mesh;
        mr.material.shader=shader;
        mr.material.color = Color.red;
    }
    void runToPlayer()//目标设置为玩家
    {
        NavMeshAgent agent = GetComponent<NavMeshAgent>();
        agent.destination = goal.position;
        ator.SetBool("isRun", true);
    }
    void runToBegin()//将目标设置为最开始的起点
    {
        NavMeshAgent agent = GetComponent<NavMeshAgent>();
        agent.destination = begin;
        ator.SetBool("isRun", false);
        ator.SetBool("isWalk", true);
    }
    void getbreathe()
    {
        float distance = Vector3.Distance(goal.position, transform.position);
        if (distance <= distance_a)
        {
            waring += goal.gameObject.GetComponent<player>().breath * Time.deltaTime;
            waringTime = 2;
        }
        if (waring >= 20)
        {
            waitTime = 2.0f;
            waring = 0;
        }
        if (waring > 0 && distance > distance_a)
        {
            if (waringTime > 0)
                waringTime -= Time.deltaTime;
            else if (waringTime <= 0)
            {
                waring = 0;
            }
        }

    }


}
