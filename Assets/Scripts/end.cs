using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
public class end : MonoBehaviour
{
    public  GameObject endUI;
    public  Text endMessage;
    public static end Inst;
    void Awake()
    {
        Inst = this;
        endUI.SetActive(false);
    }
    // Start is called before the first frame update
    public  void Failed()
    {
        endUI.SetActive(true);
        endMessage.text="Ê§ °Ü";
    }

    // Update is called once per frame
    public void Win()
    {
        endUI.SetActive(true);
        endMessage.text = "Ê¤ Àû";
    }
}
