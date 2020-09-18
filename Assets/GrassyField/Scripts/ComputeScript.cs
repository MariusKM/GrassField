using System.Collections;
using System.Collections.Generic;
using System.Security.Permissions;
using UnityEngine;

public class ComputeScript : MonoBehaviour
{
    public ComputeShader compute,computeTrample;
    public Color color;
    public MeshRenderer rend;
    public RenderTexture result,result2;
    public Material Mat;
    [Header("Noise Stuff")]
    [Range(0,0.5f)]
    public float fractalScale = 0.05f;
    BoxCollider spawnArea;
    Bounds spawnBounds;
    [Header("Trample Stuff")]
    public GameObject trampleObj;
    public Vector2 tramplePos;
    [Range(0,1)]
    public float radius;
    // Start is called before the first frame update
    void Start()
    {

        result = new RenderTexture(128, 128, 24);
        result.enableRandomWrite = true;
        result.Create();

        result2 = new RenderTexture(128, 128, 24);
        result2.enableRandomWrite = true;
        result2.Create();

        rend.material.SetTexture("_MainTex", result2);
        Mat.SetTexture("_WindDistortionMap", result);
        Mat.SetTexture("_TrampleMap", result2);
        spawnArea = GetComponent<BoxCollider>();
        spawnArea.isTrigger = true;
        spawnBounds = spawnArea.bounds;

        Mat.SetVector("_BoundsSize", new Vector2(spawnBounds.size.x, spawnBounds.size.z));

    }

    // Update is called once per frame
    void Update()
    {

        tramplePos = new Vector2( trampleObj.transform.position.x,trampleObj.transform.position.z);
        tramplePos.x /= spawnBounds.size.x;
        tramplePos.y /= spawnBounds.size.z;
        int kernel2 = computeTrample.FindKernel("CSMain");
        computeTrample.SetTexture(kernel2, "Result", result2);
        computeTrample.SetFloat("radius", radius/10);
        computeTrample.SetVector("objectPos",tramplePos );
        computeTrample.Dispatch(kernel2, 128 / 8, 128 / 8, 1);


        Vector2 windDir = new Vector2(Mat.GetVector("_WindDirection").x, Mat.GetVector("_WindDirection").z);
        float frequency = Mat.GetFloat("_WindFrecuency");
        int kernel = compute.FindKernel("CSMain");

        compute.SetFloat("scl", fractalScale);
        compute.SetTexture(kernel, "Result", result);
        compute.SetFloat("time", Time.time);
        compute.SetFloat("frequency", frequency);
        compute.SetVector("windDir", windDir);
        compute.Dispatch(kernel, 128 / 8, 128 / 8, 1);
    }
}
