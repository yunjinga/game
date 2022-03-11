using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;


public class enemy : MonoBehaviour
{
    // Start is called before the first frame update
    public Transform goal;
    public float viewRadius = 20.0f;      // ������Ұ��Զ�ľ���
    public float viewAngleStep = 30f; //��������
    public float waitTime = 0f; //�ȴ�ʱ��
    public Vector3 begin;//��ʼʱ��λ��
    public float waring = 0f;//����ֵ
    public float waringTime = 0f;//Ѱ��ʱ��
    private Vector3 beginrotation;//��ʼ��תֵ
    private Mesh mesh;
    public float distance_a;
    private Vector3[] vertices;//mesh��vertices
    int[] tringles;//mesh��tringles
    Vector2[] _uvs;//mesh��uv
    Quaternion targetPoint;
    bool b;
    Animator ator;  //�������
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
    void Rotate()//��������ʼ�ص���ָ�ԭ�����泯����
    {
        Vector3 v = transform.localEulerAngles - beginrotation;
        if (Mathf.Abs(transform.position.x - begin.x) <= 0.1f && Mathf.Abs(transform.position.y - begin.y) <= 0.1f && Mathf.Abs(transform.position.z - begin.z) <= 0.1f)  //��õ�����ΪһλС������ʵ�ʿ���Ϊ�ü�λС�����ԼӸ���Χ
        {
            transform.rotation = Quaternion.Slerp(transform.rotation, targetPoint, 3 * Time.deltaTime);//ƽ��ת��
            ator.SetBool("isWalk", false);
        }
    }
    void DrawFieldOfView()
    {
        // ���������������ߵ������������ǰ�����Ƕ���-45
        Vector3 forward_left = Quaternion.Euler(0, -45, 0) * transform.forward * viewRadius;
        // ���δ���ÿһ������
        for (int i = 0; i < viewAngleStep; i++)
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
            vertices[i + 1] = pos;
            // �����λ�õ�pos���߶Σ�ֻ���ڱ༭���￴��
            Debug.DrawLine(transform.position, pos, Color.red); ;

            // ��������ײ�����ˣ���һ������
            if (hitt.transform != null && hitt.transform.gameObject.layer == LayerMask.NameToLayer("Enemy"))
            {
                //OnEnemySpotted(hitt.transform.gameObject);
                waitTime = 2.0f;
            }
        }
        makeMesh();
        //Debug.Log(vertices[30]);
        if (waitTime > 0)//���waitTime����0�����׷��
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
    void makeMesh()//����mesh
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
    void runToPlayer()//Ŀ������Ϊ���
    {
        NavMeshAgent agent = GetComponent<NavMeshAgent>();
        agent.destination = goal.position;
        ator.SetBool("isRun", true);
    }
    void runToBegin()//��Ŀ������Ϊ�ʼ�����
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
