using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ComputeScript : MonoBehaviour
{
    public ComputeShader compute;
    public Color color;
    public MeshRenderer rend;
    public RenderTexture result;
    public Material Mat;
    // Start is called before the first frame update
    void Start()
    {

        result = new RenderTexture(128, 128, 24);
        result.enableRandomWrite = true;
        result.Create();
        rend.material.SetTexture("_MainTex", result);
        Mat.SetTexture("_WindDistortionMap", result);


    }

    // Update is called once per frame
    void Update()
    {

        Vector2 windDir = new Vector2(Mat.GetVector("_WindDirection").x, Mat.GetVector("_WindDirection").z);
        int kernel = compute.FindKernel("CSMain");

        

        compute.SetTexture(kernel, "Result", result);
        compute.SetFloat("time", Time.time);
        compute.SetVector("windDir", windDir);
        compute.Dispatch(kernel, 128 / 8, 128 / 8, 1);
    }
}
