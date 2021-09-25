using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BloomEffect : MonoBehaviour
{
    [SerializeField]
    private Shader blurShader;
    [SerializeField]
    private Shader bloomShader;
    [Range(0, 0.35f)]
    public float saturation = 0.3f;
    [Range(1, 20)]
    public int blur = 5;

    Material blurMat = null;
    Material bloomMat = null;
    protected Material blurMaterial {
        get{
            if (blurMat == null){
                blurMat = new Material(blurShader);
                blurMat.hideFlags = HideFlags.DontSave;
            }
            return blurMat;
        }
    }
    protected Material bloomMaterial {
        get{
            if (bloomMat == null){
                bloomMat = new Material(bloomShader);
                bloomMat.hideFlags = HideFlags.DontSave;
            }
            return bloomMat;
        }
    }
    protected void OnDisable() {
        if (blurMat) {
            DestroyImmediate(blurMat);
        }
        if (bloomMat) {
            DestroyImmediate(bloomMat);
        }
    }

    void OnRenderImage(RenderTexture src, RenderTexture dst) {
        
        // create a buffer texture with lower resolution
        int rtW = src.width / 4;
        int rtH = src.height / 4;
        RenderTexture buffer = RenderTexture.GetTemporary(rtW, rtH, 0);

        // blur the input texture
        blurMaterial.SetTexture("_MainTexture", src);
        blurMaterial.SetFloat("_bias", saturation);
        blurMaterial.SetInt("_filterSize", blur);
        Graphics.Blit(src, buffer, blurMaterial);

        // apply the blur to the texture that camera sees
        bloomMaterial.SetTexture("_MainTexture", src);
        bloomMaterial.SetTexture("_BlurTexture", buffer);
        Graphics.Blit(src, dst, bloomMaterial);

        RenderTexture.ReleaseTemporary(buffer);

    }
}
