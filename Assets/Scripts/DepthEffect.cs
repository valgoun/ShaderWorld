using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Camera)), ImageEffectAllowedInSceneView, ExecuteInEditMode]
public class DepthEffect : MonoBehaviour
{
    public Shader Shader;
    private Material _material;
    private Camera _camera;

    private void Init()
    {
        if (Shader == null)
            return;
        _material = new Material(Shader);
        _camera = GetComponent<Camera>();
        // _camera.depthTextureMode = DepthTextureMode.Depth;
        _camera.depthTextureMode = DepthTextureMode.DepthNormals;
    }

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (_material == null)
            Init();
        _material.SetMatrix("_inverseView", _camera.cameraToWorldMatrix);
        Graphics.Blit(src, dest, _material);
    }
}
