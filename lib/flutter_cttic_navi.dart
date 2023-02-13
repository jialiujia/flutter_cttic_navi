import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_cttic_navi/flutter_cttic_navi_platform_interface.dart';

import 'center_dialog.dart';
import 'nav_point.dart';

class FlutterCtticNavi {

  /// 场外导航
  /// userId             用户ID，必填参数
  /// deviceId           运单设备号，必填参数
  /// carNo              车牌号，必填参数
  /// startPoint         起始位置
  /// endPoint           结束位置，必填参数
  /// intermediatePoints 中间点数组
  /// onComplete         点击弹框完成导航回调
  /// onCancel           点击弹框未完成导航回调
  Future<bool> startAmapNavigation(BuildContext context, String userId,
      String deviceId, String carNo, NavPoint? startPoint,
      NavPoint endPoint, List<NavPoint>intermediatePoints, {onComplete, onCancel}) async {
      if (userId.trim().isEmpty) {
        throw Exception("用户ID不能为空");
      }
      if (deviceId.trim().isEmpty) {
        throw Exception("运单设备号不能为空");
      }
      if (carNo.trim().isEmpty) {
        throw Exception("车牌号不能为空");
      }
      if (endPoint.name.trim().isEmpty && (endPoint.longitude == 0 || endPoint.latitude == 0)) {
        throw Exception("结束位置不能为空");
      }

      if (!await FlutterCtticNaviPlatform.instance.isMsdAppInstalled()) {
        print("场外导航调用失败，请检查码上道App是否安装");
        showDialog(context: context, builder: (BuildContext context) {
          return const AlertDialog(title: Text("提示"), content: Text("场外导航调用失败，请检查码上道App是否安装"),);
        });
        return false;
      }
      
      bool result = await FlutterCtticNaviPlatform.instance.startAmapNavigation(userId, deviceId, carNo, startPoint,
          endPoint, intermediatePoints);

      if (!result) {
        print("场外导航调用失败，请检查参数是否正确");
      }

      await showDialog(context: context, builder:  (BuildContext context) {
        return CenterAlterWidget("提示", "是否完成导航",
          onConfirm: () {
            if (onComplete != null) {
              onComplete();
            }
          },
          onCancel: () {
          if (onCancel != null) {
            onCancel();
          }
          },
        );
      });
      
      return result;
  }

  /// 场內导航
  /// userId             用户ID，必填参数
  /// deviceId           运单设备号，必填参数
  /// carNo              车牌号，必填参数
  /// startPoint         起始位置
  /// endPoint           结束位置，必填参数
  /// intermediatePoints 中间点数组
  /// onComplete         点击弹框完成导航回调
  /// onCancel           点击弹框未完成导航回调
  Future<bool> startDockNavigation(BuildContext context, String userId,
      String deviceId, String carNo, NavPoint? startPoint,
      NavPoint endPoint, List<NavPoint>intermediatePoints,  {onComplete, onCancel}) async {
    if (userId.trim().isEmpty) {
      throw Exception("用户ID不能为空");
    }
    if (deviceId.trim().isEmpty) {
      throw Exception("运单设备号不能为空");
    }
    if (carNo.trim().isEmpty) {
      throw Exception("车牌号不能为空");
    }
    if (endPoint.longitude == 0 || endPoint.latitude == 0) {
      throw Exception("结束位置不能为空");
    }

    if (!await FlutterCtticNaviPlatform.instance.isMsdAppInstalled()) {
      print("场內导航调用失败，请检查码上道App是否安装");
      showDialog(context: context, builder: (BuildContext context) {
        return const AlertDialog(title: Text("提示"), content: Text("场內导航调用失败，请检查码上道App是否安装"),);
      });
      return false;
    }

    bool result = await FlutterCtticNaviPlatform.instance.startDockNavigation(userId, deviceId, carNo, startPoint,
        endPoint, intermediatePoints);

    if (!result) {
      print("场內导航调用失败，请检查参数是否正确");
    }
    await showDialog(context: context, builder:  (BuildContext context) {
      return CenterAlterWidget("提示", "是否已完成导航",
        onConfirm: () {
          if (onComplete != null) {
            onComplete();
          }
        },
        onCancel: () {
          if (onCancel != null) {
            onCancel();
          }
        },
      );
    });
    return result;
  }
}
