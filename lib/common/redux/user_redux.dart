import 'package:github_app_flutter/common/zyf_state.dart';
import 'package:github_app_flutter/model/User.dart';
import 'package:redux/redux.dart';

/// 用户相关Redux
/// Create by zyf
/// Date: 2019/7/23

/// redux 的 combineReducers, 通过 TypedReducer
/// 将 UpdateUserAction 与 reducers 关联起来
final userReducer = combineReducers<User>([
  TypedReducer<User, UpdateUserAction>(_updateLoaded),
]);

User _updateLoaded(User user, UpdateUserAction action) {
  user = action.userInfo;
  return user;
}

class UpdateUserAction {
  final User userInfo;

  UpdateUserAction(this.userInfo);
}

class FetchUserAction {}

class UserInfoMiddleware implements MiddlewareClass<ZYFState> {
  @override
  void call(Store<ZYFState> store, dynamic action, NextDispatcher next) {
    if (action is UpdateUserAction) {
      print("*********** UserInfoMiddleware *********** ");
    }
    next(action);
  }
}
