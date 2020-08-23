


using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

[CustomEditor(typeof(GrassSpawner))]
public class GrassSpawnerUtil : Editor
{

    public override void OnInspectorGUI()
    {
        DrawDefaultInspector();

        GrassSpawner myScript = (GrassSpawner)target;
        if (GUILayout.Button("Spawn Objects"))
        {
            myScript.Init();
        }
        if (GUILayout.Button("Fit to Ground Plane"))
        {
            myScript.fitToGroundPlane();
        }
        if (GUILayout.Button("Clear Objects"))
        {
            myScript.Clear();
        }


    }
}

