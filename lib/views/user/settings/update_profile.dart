import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fvastalpha/views/cou_service/settings/change_password.dart';
import 'package:fvastalpha/views/partials/utils/constants.dart';
import 'package:fvastalpha/views/partials/utils/styles.dart';
import 'package:fvastalpha/views/partials/widgets/custom_button.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';

class UpdateCusProfile extends StatefulWidget {
  @override
  _UpdateCusProfileState createState() => _UpdateCusProfileState();
}

class _UpdateCusProfileState extends State<UpdateCusProfile> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  TextEditingController name, email, phone;
  String avatar;
  bool isLoading = true;

  void getDetails() async {
    DocumentSnapshot doc =
        await Firestore.instance.collection('All').document(MY_UID).get();

    print(doc.data.toString());

    name = TextEditingController(text: doc.data["Name"]);
    email = TextEditingController(text: doc.data["Email"]);
    phone = TextEditingController(text: doc.data["Phone"]);
    avatar = doc.data["Avatar"];

    isLoading = false;
    setState(() {});
  }

  @override
  void initState() {
    getDetails();
    super.initState();
  }

  File image;

  Future getImageGallery() async {
    var img = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      image = img;
    });
    processImage(img);
  }

  Future getImageCamera() async {
    var img = await ImagePicker.pickImage(source: ImageSource.camera);

    setState(() {
      image = img;
    });
    processImage(img);
  }

  void processImage(File file) async {
    if (file != null) {
      String url = await uploadImage(file);

      Firestore.instance
          .collection("All")
          .document(MY_UID)
          .updateData({"Avatar": url});

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("image", url);
      MY_IMAGE = url;
      setState(() {});

      showCenterToast("Image Uploaded", context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LoadingOverlay(
        isLoading: isLoading,
        child: Scaffold(
            key: scaffoldKey,
            appBar: AppBar(
              iconTheme: IconThemeData(color: Colors.black),
              backgroundColor: Colors.white,
              elevation: 0.0,
              title: Text(
                "Update Profile",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(blurRadius: 3, color: Colors.grey)
                            ],
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(35)),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: image == null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(30.0),
                                  child: CachedNetworkImage(
                                    imageUrl: avatar ?? "ere",
                                    height: 60,
                                    width: 60,
                                    placeholder: (context, url) => ClipRRect(
                                      borderRadius: BorderRadius.circular(30.0),
                                      child: Image(
                                          image: AssetImage(
                                              "assets/images/person.png"),
                                          height: 60,
                                          width: 60,
                                          fit: BoxFit.contain),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        ClipRRect(
                                      borderRadius: BorderRadius.circular(30.0),
                                      child: Image(
                                          image: AssetImage(
                                              "assets/images/person.png"),
                                          height: 60,
                                          width: 60,
                                          fit: BoxFit.contain),
                                    ),
                                  ),
                                )
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(30.0),
                                  child: Image.file(image,
                                      height: 60,
                                      width: 60,
                                      fit: BoxFit.contain),
                                ),
                        ),
                      ),
                    ),
                    Center(
                      child: InkWell(
                        onTap: () {
                          showDialog(
                              context: context,
                            //  barrierDismissible: false,
                              builder: (_) {
                                return AlertDialog(
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      InkWell(
                                        onTap: () {
                                          getImageGallery();
                                          Navigator.pop(context);
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                              "Choose Avatar from Gallery"),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          getImageCamera();
                                          Navigator.pop(context);
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text("Take image from Camera"),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              });
                        },
                        child: Text("Change Avatar",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blueAccent,
                            )),
                      ),
                    ),
                    Text(
                      "Name",
                      style: TextStyle(
                          fontSize: 17, color: Styles.appPrimaryColor),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5.0),
                      child: Theme(
                        data: ThemeData(
                            primaryColor: Styles.commonDarkBackground,
                            hintColor: Styles.commonDarkBackground),
                        child: TextFormField(
                          controller: name,
                          decoration: InputDecoration(
                              fillColor: Styles.commonDarkBackground,
                              filled: true,
                              contentPadding: EdgeInsets.all(10),
                              hintText: 'Name',
                              hintStyle: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 18,
                                  fontWeight: FontWeight.w400),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0),
                              )),
                          keyboardType: TextInputType.text,
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                    ),
                    Text(
                      "Email",
                      style: TextStyle(
                          fontSize: 17, color: Styles.appPrimaryColor),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5.0),
                      child: Theme(
                        data: ThemeData(
                            primaryColor: Styles.commonDarkBackground,
                            hintColor: Styles.commonDarkBackground),
                        child: TextFormField(
                          controller: email,
                          decoration: InputDecoration(
                              fillColor: Styles.commonDarkBackground,
                              filled: true,
                              contentPadding: EdgeInsets.all(10),
                              hintText: 'Email',
                              hintStyle: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 18,
                                  fontWeight: FontWeight.w400),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0),
                              )),
                          keyboardType: TextInputType.emailAddress,
                          enabled: false,

                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                    ),
                    Text(
                      "Phone Number",
                      style: TextStyle(
                          fontSize: 17, color: Styles.appPrimaryColor),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5.0),
                      child: Theme(
                        data: ThemeData(
                            primaryColor: Styles.commonDarkBackground,
                            hintColor: Styles.commonDarkBackground),
                        child: TextFormField(
                          controller: phone,
                          decoration: InputDecoration(
                              fillColor: Styles.commonDarkBackground,
                              filled: true,
                              contentPadding: EdgeInsets.all(10),
                              hintText: 'Phone Number',
                              hintStyle: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 18,
                                  fontWeight: FontWeight.w400),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0),
                              )),
                          keyboardType: TextInputType.number,
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                    ),

                    ListTile(
                      title: Text("Change password"),
                      trailing: Icon(Icons.arrow_forward_ios_sharp),
                      onTap: () {
                        moveTo(context, ChangePasswordPage());
                      },
                    ),
                    CustomButton(
                      title: "Update",
                      onPress: () {
                        if (name.text.trim().isEmpty ||
                            email.text.trim().isEmpty ||
                            phone.text.trim().isEmpty) {
                          showCenterToast("Fill all the empty Fields", context);
                          return;
                        }
                        isLoading = true;
                        setState(() {});
                        Map<String, Object> mData = Map();
                        mData.putIfAbsent("Name", () => name.text);
                        mData.putIfAbsent("Email", () => email.text);
                        mData.putIfAbsent("Phone", () => phone.text);
                       //   mData.putIfAbsent("Avatar", () => "mm");

                        Firestore.instance
                            .collection("All")
                            .document(MY_UID)
                            .updateData(mData)
                            .then((value) async{
                          isLoading = false;
                          setState(() {});

                          final SharedPreferences prefs = await SharedPreferences.getInstance();
                          prefs.setString("name", name.text);
                          prefs.setString("phone", phone.text);
                          MY_NAME = name.text;
                          MY_NUMBER = phone.text;
                          setState(() {});


                          showDialog(
                              context: context,
                              builder: (_) {
                                return AlertDialog(
                                  content: Text(
                                    "Details Updated",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 18),
                                  ),
                                  actions: <Widget>[
                                    Center(
                                      child: Padding(
                                        padding: EdgeInsets.all(5.0),
                                        child: Container(
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                              color: Colors.red),
                                          child: FlatButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: Text(
                                              "  OK  ",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w900,
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                );
                              });
                        });
                      },
                    )
                  ],
                ),
              ),
            )),
      ),
    );
  }
}
