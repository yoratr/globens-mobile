import 'package:globens_flutter_client/widgets/modal_views/SingleTimePickerModalView.dart';
import 'package:globens_flutter_client/widgets/modal_views/WeeklyTimePickerModalView.dart';
import 'package:globens_flutter_client/widgets/screens/ProductPurchaseScreen.dart';
import 'package:globens_flutter_client/widgets/screens/ProductReviewsScreen.dart';
import 'package:globens_flutter_client/widgets/screens/DriveContentViewer.dart';
import 'package:globens_flutter_client/generated_protos/gb_service.pb.dart';
import 'package:globens_flutter_client/entities/AppUser.dart';
import 'package:globens_flutter_client/entities/Product.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:globens_flutter_client/utils/Locale.dart';
import 'package:globens_flutter_client/utils/Utils.dart';
import 'package:flutter/material.dart';

class ProductViewerScreen extends StatefulWidget {
  static const String route_name = '/product_viewer_screen';

  ProductViewerScreen();

  @override
  _ProductViewerScreenState createState() => _ProductViewerScreenState();
}

class _ProductViewerScreenState extends State<ProductViewerScreen> {
  Product _product;
  var _contents = <Content>[];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _product = ModalRoute.of(context).settings.arguments as Product;
    loadContents();
  }

  @override
  Widget build(BuildContext context) {
    bool isFile = _product.productType == ProductDeliveryType.FILE_DOWNLOADABLE || _product.productType == ProductDeliveryType.FILE_STREAMED;
    bool isSchedule = !isFile && (_product.productType == ProductDeliveryType.SCHEDULED_FACE_TO_FACE || _product.productType == ProductDeliveryType.SCHEDULED_ONLINE_CALL);

    return Scaffold(
        backgroundColor: Color.fromRGBO(240, 242, 245, 1),
        body: SafeArea(
          child: ListView(
            padding: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 30.0 + MediaQuery.of(context).viewInsets.bottom),
            shrinkWrap: true,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios),
                    onPressed: _onBackButtonPressed,
                  ),
                  getTitleWidget(Locale.get('Product details'), textColor: Colors.black, margin: EdgeInsets.all(0))
                ],
              ),
              getSectionSplitter(Locale.get("Basic information")),
              Card(
                  color: Colors.white,
                  margin: EdgeInsets.zero,
                  elevation: 1.0,
                  child: Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(4.0),
                                topRight: Radius.circular(4.0),
                              ),
                              child: AspectRatio(aspectRatio: 1, child: Image.memory(_product.pictureBlob, fit: BoxFit.cover)),
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 10.0),
                              padding: EdgeInsets.symmetric(horizontal: 5.0),
                              color: Colors.white,
                              child: Text(
                                _product.priceStr,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0, color: Colors.deepOrange),
                              ),
                            ),
                            GestureDetector(
                              onTap: _openProductReviews,
                              child: Align(
                                alignment: Alignment.topRight,
                                child: Container(
                                  margin: EdgeInsets.only(top: 5.0),
                                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                                  color: Colors.white,
                                  child: Wrap(
                                    children: [
                                      RatingBarIndicator(
                                        rating: _product.stars,
                                        direction: Axis.horizontal,
                                        itemCount: 5,
                                        itemSize: 15.0,
                                        itemBuilder: (context, _) => Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                        ),
                                      ),
                                      Text("(${_product.reviewsCount})"),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 10.0),
                          child: Container(
                            height: 20.0,
                            margin: EdgeInsets.symmetric(vertical: 10),
                            child: Text(_product.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0, color: Colors.blueAccent)),
                          ),
                        )
                      ],
                    ),
                  )),
              getSectionSplitter(Locale.get("Product description")),
              Card(
                  margin: EdgeInsets.only(top: 10.0),
                  child: Container(
                      padding: EdgeInsets.all(10.0),
                      child: Text(
                        _product.description,
                        maxLines: 10,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0, color: Colors.blueAccent),
                      ))),
              getSectionSplitter(Locale.get("Product content")),
              if (isFile && _product != null)
                Card(
                  margin: EdgeInsets.only(top: 10.0),
                  child: Container(
                    height: 100,
                    padding: EdgeInsets.all(5),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _product.contents['ids'].length,
                      itemBuilder: _getFileContentWidget
                    ),
                  ),
                ),
              if (isSchedule)
                Container(
                    margin: EdgeInsets.only(top: 20.0, left: 30.0, right: 30.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        RaisedButton.icon(onPressed: _openTryTimeSlotSelector, color: Colors.blueAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))), icon: Icon(Icons.checkroom, color: Colors.white), label: Text(Locale.get("Try"), style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                        RaisedButton.icon(onPressed: _openSignUpTimeSlotSelector, color: Colors.blueAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))), icon: Icon(Icons.app_registration, color: Colors.white), label: Text(Locale.get("Sign up"), style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                      ],
                    )),
              getSectionSplitter(Locale.get("Actions")),
              if (isFile) Container(margin: EdgeInsets.only(top: 20.0, left: 30.0, right: 30.0), child: RaisedButton.icon(onPressed: _purchaseProduct, color: Colors.blueAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))), icon: Icon(Icons.shopping_bag, color: Colors.white), label: Text(Locale.get("Purchase"), style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
            ],
          ),
        ));
  }

  void _onBackButtonPressed() {
    Navigator.of(context).pop();
  }

  void _openTryTimeSlotSelector() async {
    var timeSlot = TimeSlot();
    await showModalBottomSheet(context: context, builder: (context) => SingleTimePickerModalView(_product, timeSlot));
  }

  void _openSignUpTimeSlotSelector() async {
    var timeSlots = <TimeSlot>[];
    await showModalBottomSheet(context: context, builder: (context) => WeeklyTimePickerModalView(_product, timeSlots));
    // todo purchase here
  }

  Widget _getFileContentWidget(BuildContext context, int index) {
    _product.contents;
    return GestureDetector(
      onTap: () => _onContentPressed(index),
      child: RaisedButton.icon(onPressed: null, icon: Icon(Icons.ac_unit), label: Text("${_product.contents['ids'][index]}")),
    );
  }

  void _onContentPressed(int index) async {
    // Navigator.push(context, MaterialPageRoute(builder: (context) => DriveContentViewer(content)));
  }

  void _purchaseProduct() async {
    await Navigator.of(context).pushNamed(ProductPurchaseScreen.route_name, arguments: _product);
  }

  void _openProductReviews() async {
    await Navigator.of(context).pushNamed(ProductReviewsScreen.route_name, arguments: _product);
  }

  Future<void> loadContents() async {
    _contents.clear();
    for (var contentId in _product.contents['ids']) {
      final res = await grpcFetchContentDetails(AppUser.sessionKey, contentId);
      if (res.item1) {
        _contents.add(res.item2);
      }
    }
    setState(() {});
  }
}
