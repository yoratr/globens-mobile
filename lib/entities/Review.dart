import 'package:globens_flutter_client/entities/GlobensUser.dart';

class Review {
  //region Variables
  int _id;
  int _productId;
  int _stars;
  String _review;
  GlobensUser _reviewer;
  // endregion

  Review.create(String review, {int id, int productId, int stars, GlobensUser reviewer}) {
    this._review = review;
    this._id = id;
    this._productId = productId;
    this._stars = stars;
    this._reviewer = reviewer;
  }

  //region Getters
  GlobensUser get reviewer => _reviewer;

  String get review => _review;

  int get stars => _stars;

  int get productId => _productId;

  int get id => _id;
//endregion
}
