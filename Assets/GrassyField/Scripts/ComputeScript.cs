using System.Collections;
using System.Collections.Generic;
using System.Security.Permissions;
using UnityEngine;

public class ComputeScript : MonoBehaviour
{
    [Header("Compute Shader Variables")]
    public ComputeShader compute;
    public MeshRenderer rend;
    public RenderTexture result;
    public Material Mat;
    [Header("Noise Paramerters")]
    [Range(0,0.05f)]
    public float fractalScale = 0.05f;
    BoxCollider spawnArea;
    Bounds spawnBounds;
    [Header("Trample Parameters")]
    public GameObject trampleObj;
    Vector2 tramplePos;
    [Range(0,1)]
    public float radius;
    private Vector2 bottomLeft;
    bool once;
    Vector2 _objectPos, _windDir;
    float  _scl , _frequency,_radius;
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
        Vector2 boundsSize = new Vector2(spawnBounds.size.x, spawnBounds.size.z);

        int kernel = compute.FindKernel("CSMain");



        if (!once)
        {
            compute.SetFloat("radius", radius / 5);
            compute.SetVector("bottomLeft", bottomLeft);
            compute.SetVector("boundsSize", new Vector2(spawnBounds.size.x, spawnBounds.size.z));
            once = true;
        }

        if (_objectPos != tramplePos)
        {
            Vector2 pos = tramplePos;
            float posX = tramplePos.x;
            posX -= bottomLeft.x;
            posX /= boundsSize.x;
            float posY = tramplePos.y;
            posY -= bottomLeft.y;
            posY /= boundsSize.y;
            compute.SetVector("objectPos", new Vector2(posX, posY));
        }

        if(_windDir != windDir) compute.SetVector("windDir", windDir);
        if(_scl != fractalScale) compute.SetFloat("scl", fractalScale);
        if(_frequency != frequency) compute.SetFloat("frequency", frequency);   
        if(_radius != radius) compute.SetFloat("radius", radius);   


        compute.SetFloat("time", Time.time);
      
        
        compute.SetTexture(kernel, "Result", result);
 
        compute.Dispatch(kernel, 512 / 32, 512 / 32, 1);

        _objectPos = tramplePos;
        _scl = fractalScale;
        _frequency = frequency;
        _windDir = windDir;
        _radius = radius;


    }
}
