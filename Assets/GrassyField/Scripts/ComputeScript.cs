﻿using System.Collections;
using System.Collections.Generic;

using UnityEngine;

public class ComputeScript : MonoBehaviour
{
    public ComputeShader compute;
    public Color color;
    public MeshRenderer rend;
    public RenderTexture result;
    public Material Mat;
    [Range(0,0.5f)]
    public float fractalScale = 0.05f;
    BoxCollider spawnArea;
    Bounds spawnBounds;
    // Start is called before the first frame update
    void Start()
    {

        result = new RenderTexture(128, 128, 24);
        result.enableRandomWrite = true;
        result.Create();
        rend.material.SetTexture("_MainTex", result);
        Mat.SetTexture("_WindDistortionMap", result);
        spawnArea = GetComponent<BoxCollider>();
        spawnArea.isTrigger = true;
        spawnBounds = spawnArea.bounds;

        Mat.SetVector("_BoundsSize", new Vector2(spawnBounds.size.x, spawnBounds.size.z));

    }

    // Update is called once per frame
    void Update()
    {

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
