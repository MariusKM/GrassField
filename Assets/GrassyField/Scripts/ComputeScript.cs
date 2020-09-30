using System.Collections;
using System.Collections.Generic;
using System.Security.Permissions;
using UnityEngine;

public class ComputeScript : MonoBehaviour
{
    public ComputeShader compute;
    public Color color;
    public MeshRenderer rend;
    public RenderTexture result;
    public Material Mat;
    [Header("Noise Stuff")]
    [Range(0,0.05f)]
    public float fractalScale = 0.05f;
    BoxCollider spawnArea;
    Bounds spawnBounds;
    [Header("Trample Stuff")]
    public GameObject trampleObj;
    public Vector2 tramplePos;
    [Range(0,1)]
    public float radius;
    private Vector2 bottomLeft;
    bool once;
    Vector2 _objectPos, _windDir;
    float  _scl , _frequency;
    // Start is called before the first frame update
    void Start()
    {

        result = new RenderTexture(512, 512, 24);
        result.enableRandomWrite = true;
        result.Create();

       
        rend.material.SetTexture("_MainTex", result);
        Mat.SetTexture("_WindDistortionMap", result);
        Mat.SetTexture("_TrampleMap", result);
        spawnArea = GetComponent<BoxCollider>();
        spawnArea.isTrigger = true;
        spawnBounds = spawnArea.bounds;
        bottomLeft = GetComponent<GrassSpawner>().getBottomLeft();
        Mat.SetVector("_BoundsSize", new Vector2(spawnBounds.size.x, spawnBounds.size.z));
        Mat.SetVector("_BottomLeft", bottomLeft);

    }

    // Update is called once per frame
    void Update()
    {

        tramplePos = new Vector2( trampleObj.transform.position.x,trampleObj.transform.position.z);


        Vector2 windDir = new Vector2(Mat.GetVector("_WindDirection").x, Mat.GetVector("_WindDirection").z);
        float frequency = Mat.GetFloat("_WindFrecuency");
        Mat.SetVector("_ObjectPos", trampleObj.transform.position);


        int kernel = compute.FindKernel("CSMain");



        if (!once)
        {
            compute.SetFloat("radius", radius / 5);
            compute.SetVector("bottomLeft", bottomLeft);
            compute.SetVector("boundsSize", new Vector2(spawnBounds.size.x, spawnBounds.size.z));
            once = true;
        }

        if(_objectPos != tramplePos) compute.SetVector("objectPos", tramplePos);
        if(_windDir != windDir) compute.SetVector("windDir", windDir);
        if(_scl != fractalScale) compute.SetFloat("scl", fractalScale);
        if(_frequency != frequency) compute.SetFloat("frequency", frequency);   
     /*  compute.SetVector("objectPos", tramplePos);
       compute.SetVector("windDir", windDir);
       compute.SetFloat("scl", fractalScale);
       compute.SetFloat("frequency", frequency);*/



        compute.SetFloat("time", Time.time);
      
        
        compute.SetTexture(kernel, "Result", result);
 
        compute.Dispatch(kernel, 512 / 32, 512 / 32, 1);

        _objectPos = tramplePos;
        _scl = fractalScale;
        _frequency = frequency;
        _windDir = windDir;


    }
}
