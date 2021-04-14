package com.hs.face;

import android.app.Activity;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.util.Log;

import com.alibaba.fastjson.JSON;
import com.arcsoft.face.ActiveFileInfo;
import com.arcsoft.face.ErrorInfo;
import com.arcsoft.face.FaceEngine;
import com.arcsoft.face.FaceFeature;
import com.arcsoft.face.FaceInfo;
import com.arcsoft.face.FaceSimilar;
import com.arcsoft.face.VersionInfo;
import com.arcsoft.face.enums.CompareModel;
import com.arcsoft.face.enums.DetectFaceOrientPriority;
import com.arcsoft.face.enums.DetectMode;
import com.arcsoft.face.enums.DetectModel;
import com.arcsoft.imageutil.ArcSoftImageFormat;
import com.hs.face.util.ConfigUtil;

import io.flutter.plugin.common.MethodChannel.Result;

import com.arcsoft.imageutil.ArcSoftImageUtil;
import com.arcsoft.imageutil.ArcSoftImageUtilError;

import java.util.ArrayList;
import java.util.List;

public class FaceMethodCall {

    private static final String TAG = "FaceMethodCall";
    private Activity activity;

    public FaceMethodCall(Activity activity) {
        this.activity = activity;
    }

    private FaceEngine faceEngine = null;

    /**
     * 执行注册sdk
     *
     * @param appId
     * @param sdkKey
     * @param result
     */
    public void handlerActiveOnline(String appId, String sdkKey, Result result) {
        Log.i(TAG, "context：" + activity + "，appId：" + appId + "，sdkKey：" + sdkKey);
        int code = FaceEngine.activeOnline(activity, appId, sdkKey);
        Log.i(TAG, "engine result：" + code);
        if (code == ErrorInfo.MOK || code == ErrorInfo.MERR_ASF_ALREADY_ACTIVATED) {
            result.success(true);
        } else {
            Log.e(TAG, "Face SDK Register Error，ErrorCode： " + code);
            result.error("" + code, "激活失败，错误码：" + code + "请根据错误码查询对应错误", null);
        }
    }

    /**
     * 获取激活文件信息
     *
     * @return
     */
    public void handlerGetActiveFileInfo(Result result) {
        ActiveFileInfo activeFileInfo = new ActiveFileInfo();
        int code = FaceEngine.getActiveFileInfo(activity, activeFileInfo);
        if (code == ErrorInfo.MOK) {
            Log.i(TAG, "获取激活文件信息：" + activeFileInfo.toString());
            result.success(JSON.toJSONString(activeFileInfo));
        } else {
            Log.e(TAG, "GetActiveFileInfo failed, code is  : " + code);
            result.error("" + code, "获取激活文件信息失败，错误码：" + code + "请根据错误码查询对应错误", null);
        }
    }

    /**
     * 获取sdk版本
     *
     * @return
     */
    public void handlerGetSdkVersion(Result result) {
        VersionInfo versionInfo = new VersionInfo();
        int code = FaceEngine.getVersion(versionInfo);
        if (code == ErrorInfo.MOK) {
            Log.i(TAG, "获取版本信息：" + versionInfo.toString());
            result.success(JSON.toJSONString(versionInfo));
        } else {
            Log.e(TAG, "GetSdkVersion failed, code is  : " + code);
            result.error("" + code, "获取sdk版本信息，错误码：" + code + "请根据错误码查询对应错误", null);
        }
    }

    /// 设置视频人脸检测角度
    public void handlerSetFaceDetectOrientPriority(int faceDetectOrientPriority, Result result) {
        switch (faceDetectOrientPriority) {
            case 1:
                ConfigUtil.setFtOrient(activity, DetectFaceOrientPriority.ASF_OP_0_ONLY);
                break;
            case 2:
                ConfigUtil.setFtOrient(activity, DetectFaceOrientPriority.ASF_OP_90_ONLY);
                break;
            case 3:
                ConfigUtil.setFtOrient(activity, DetectFaceOrientPriority.ASF_OP_270_ONLY);
                break;
            case 4:
                ConfigUtil.setFtOrient(activity, DetectFaceOrientPriority.ASF_OP_180_ONLY);
                break;
            default:
                ConfigUtil.setFtOrient(activity, DetectFaceOrientPriority.ASF_OP_ALL_OUT);
                break;
        }
        result.success(faceDetectOrientPriority);
    }


    public void handlerGetImageUtilVersion(Result result) {
        result.success(ArcSoftImageUtil.getVersion());
    }

    public void handlerCompareFaceFeature(byte[] buffer1,byte[] buffer2, Result result){
        if (faceEngine == null) {
            faceEngine = new FaceEngine();
            int faceEngineCode = faceEngine.init(activity, DetectMode.ASF_DETECT_MODE_IMAGE, DetectFaceOrientPriority.ASF_OP_ALL_OUT,
                    16, 10, FaceEngine.ASF_FACE_RECOGNITION | FaceEngine.ASF_FACE_DETECT | FaceEngine.ASF_AGE | FaceEngine.ASF_GENDER | FaceEngine.ASF_FACE3DANGLE | FaceEngine.ASF_LIVENESS);
            Log.i(TAG, "initEngine: init: " + faceEngineCode);
        }
        FaceFeature faceFeature1 = new FaceFeature();
        FaceFeature faceFeature2 = new FaceFeature();
        faceFeature1.setFeatureData(buffer1);
        faceFeature2.setFeatureData(buffer2);

        FaceSimilar matching = new FaceSimilar();
        int compareResult =  faceEngine.compareFaceFeature(faceFeature1, faceFeature2, CompareModel.LIFE_PHOTO, matching);
        if (compareResult == ErrorInfo.MOK) {
            result.success(matching.getScore());
        } else {
            Log.e(TAG, "compareFaceFeature failed, code is " + compareResult);
            result.error("-1", "compareFaceFeature failed, code is " + compareResult, null);
        }
    }

    public void handlerGetFaceId(byte[] buffer, Result result) {
        if (faceEngine == null) {
            faceEngine = new FaceEngine();
            int faceEngineCode = faceEngine.init(activity, DetectMode.ASF_DETECT_MODE_IMAGE, DetectFaceOrientPriority.ASF_OP_ALL_OUT,
                    16, 10, FaceEngine.ASF_FACE_RECOGNITION | FaceEngine.ASF_FACE_DETECT | FaceEngine.ASF_AGE | FaceEngine.ASF_GENDER | FaceEngine.ASF_FACE3DANGLE | FaceEngine.ASF_LIVENESS);
            Log.i(TAG, "initEngine: init: " + faceEngineCode);
        }

        if (buffer == null || buffer.length <= 0) {
            result.error("-1", "this buffer is empty!", null);
            return;
        }
        Bitmap bitmap = BitmapFactory.decodeByteArray(buffer, 0, buffer.length);
        Bitmap alignedBitmap = ArcSoftImageUtil.getAlignedBitmap(bitmap, true);
        int width = alignedBitmap.getWidth();
        int height = alignedBitmap.getHeight();
        // bitmap转bgr24
        long start = System.currentTimeMillis();
        byte[] bgr24 = ArcSoftImageUtil.createImageData(width, height, ArcSoftImageFormat.BGR24);
        int transformCode = ArcSoftImageUtil.bitmapToImageData(alignedBitmap, bgr24, ArcSoftImageFormat.BGR24);
        if (transformCode != ArcSoftImageUtilError.CODE_SUCCESS) {
            Log.e(TAG, "transform failed, code is " + transformCode);
            result.error("-1", "transform failed, code is " + transformCode, null);
            return;
        }
        Log.i(TAG, "processImage:bitmapToBgr24 cost =  " + (System.currentTimeMillis() - start));
        List<FaceInfo> faceInfoList = new ArrayList<>();
        int detectCode = faceEngine.detectFaces(bgr24, width, height, FaceEngine.CP_PAF_BGR24, DetectModel.RGB, faceInfoList);
        if (detectCode == ErrorInfo.MOK) {
            Log.i(TAG, "processImage: fd costTime = " + (System.currentTimeMillis() - start));
        }

        if (faceInfoList.size() > 0) {
            ArrayList<byte[]> retFeatures = new ArrayList<byte[]>();
            FaceFeature[] faceFeatures = new FaceFeature[faceInfoList.size()];
            int[] extractFaceFeatureCodes = new int[faceInfoList.size()];
            for (int i = 0; i < faceInfoList.size(); i++) {
                faceFeatures[i] = new FaceFeature();
                //从图片解析出人脸特征数据
                long frStartTime = System.currentTimeMillis();
                extractFaceFeatureCodes[i] = faceEngine.extractFaceFeature(bgr24, width, height, FaceEngine.CP_PAF_BGR24, faceInfoList.get(i), faceFeatures[i]);
                if (extractFaceFeatureCodes[i] != ErrorInfo.MOK) {
                    Log.e(TAG, "extractFaceFeature failed, code is " + extractFaceFeatureCodes[i]);
                    result.error("-1", "extractFaceFeature failed, code is " + extractFaceFeatureCodes[i], null);
                    return;
                } else {
                    retFeatures.add(faceFeatures[i].getFeatureData());
                    Log.i(TAG, "processImage: fr costTime = " + (System.currentTimeMillis() - frStartTime));
                    result.success(retFeatures);
                    return;
                }
            }
        }
        result.success(null);
    }
}
