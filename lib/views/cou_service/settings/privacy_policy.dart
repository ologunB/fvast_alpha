import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fvastalpha/views/partials/widgets/toast.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyPo extends StatefulWidget {
  @override
  _PrivacyPoState createState() => _PrivacyPoState();
}

class _PrivacyPoState extends State<PrivacyPo> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          key: scaffoldKey,
          appBar: AppBar(
            iconTheme: IconThemeData(color: Colors.black),
            backgroundColor: Colors.white,
            elevation: 0.0,
            title: Text(
              "FVAST Privacy Policy",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: RichText(
                text: TextSpan(
                    text: '',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                    children: <TextSpan>[
                      TextSpan(
                          text:
                          '''FVAST ENTERPRISE owners of FVAST APP (Business registration number BN 2956782) located at No.9A Mogadishu street , Wuse zone 4 , Abuja, is the controller of personal data of riders as well as  customers and has appointed a data protection  officer to that effect. We are very aware of the fact that you care so much about how secure your personal data as well as information relating to your business are with us, we do appreciate your trust and rest assured that we will do so sensibly and carefully. This privacy notice describes how FVAST Collates and processes your personal information through the FVAST websites, devices, products, services, online and physical as well as applications that reference this privacy notice. By using this FVAST APP you are consenting to the practices described in this privacy notice.''',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w400),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              // navigate to desired screen
                            }),
                      TextSpan(
                        text:
                        '''\n\n • What personal information about customers (riders and customers) does FVAST collect''',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w400),
                      ),
                      TextSpan(
                        text:
                        '''\n • For what purpose does FVAST collect these personal information''',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w400),
                      ),
                      TextSpan(
                        text:
                        '''\n • Does FVAST share your personal information''',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w400),
                      ),
                      TextSpan(
                        text: '''\n • How secure is information about me''',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w400),
                      ),
                      TextSpan(
                        text: '''\n • What information can I access''',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w400),
                      ),
                      TextSpan(
                        text:
                        '''\n • What about cookies and other identifiers''',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w400),
                      ),
                      TextSpan(
                        text: '''\n • What choices do I have''',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w400),
                      ),
                      TextSpan(
                        text: '''\n • What about advertising''',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w400),
                      ),
                      TextSpan(
                        text:
                        '''\n • What is the age restriction to the use of this FVAST app''',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w400),
                      ),
                      TextSpan(
                        text:
                        '''\n • Conditions of use , Notices and revisions''',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w400),
                      ),
                      TextSpan(
                        text: '''\n • Related practices and information''',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w400),
                      ),
                      TextSpan(
                        text:
                        '''\n\nWHAT PERSONAL INFORMATION ABOUT CUSTOMERS (RIDERS AND CUSTOMERS) DOES FVAST COLLECT?\n RIDERS''',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                      TextSpan(
                        text:
                        '''\n • Name, e-mail, phone number, place of residence.
 • Geo location of drivers and driving routes.
 • Information about vehicles (including registration number).
 • Driver’s efficiency and ratings.
 • Driver’s license, photo, profession and identity documents.
 • Data about criminal convictions and offences. The financial data of providing dispatch/delivery services is not considered as personal data , because drivers provide services in the course of economic and professional activities''',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w400),
                      ),
                      TextSpan(
                        text: '''\n CUSTOMERS''',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                      TextSpan(
                        text:
                        '''\n • Name, e-mail, phone number, place of residence.
 • Geo location of customer, the time and the destination of the pick-up and drop-off.
 • Payment Information.
 • Information about disputes.
 • Identification data of the device on which the FVAST app has been installed.''',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w400),
                      ),
                      TextSpan(
                        text:
                        '''\n\nOTHER OF SUCH PERSONAL INFORMATION INCLUDE, BUT NOT LIMITED TO;''',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                      TextSpan(
                        text:
                        '''\n • The information you give us- we receive and store any information you provide in relation to FVAST services. You can choose not to provide certain information, but doing this may stall your abilities to take advantage of many of our FVAST services
 • Automatic information – We automatically collect and store certain types of information about your use of FVAST APP services, including information about your interaction with content and services available through FVAST services. Like many websites , we use ‘cookies’ and other unique identifiers, and we obtain certain types of information when your web browser of device accesses FVAST services and other content served by or on behalf of FVAST on other websites.
 • Information from other sources- We might receive information about you from other sources, such as updated address information from our carriers, which we use to correct our records and deliver your next purchase more easily.''',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w400),
                      ),
                      TextSpan(
                        text:
                        '''\n\nWHY DOES FVAST NEED YOUR PERSONAL INFORMATION?''',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                      TextSpan(
                        text:
                        '''\nWe use your personal information to operate, develop, operate and improve the products and services that we offer our subscribers. The purposes include;
 • For the purpose of connecting customers with dispatch riders to help them carry out the task of delivery of items from one point to another more effectively and efficiently.
 • We display geo location data and the phone number of passengers to drivers to enable efficient pickup and delivery. The geo location data is collected only when the FVAST app is activated. The collection of geo location data stops after closing the FVAST app.
 • FVAST obtains payment details to process passengers’ payment on behalf of riders for logistics services.
 • We use your personal information to take and handle booking orders , deliveries , payments as well as to communicate to you about the afore listed promotional offers not excluded.
 • For the purpose of recommending features, products and services that might be of interest to you, identify your preferences and personalize your experiences with FVAST.
 • By gathering your personal information, the riders and customers geo location and driving routes are processed to analyze the geographical area and give suggestions to the riders as well as customers as the case may be. If you do not want to disclose your geo location for any reason, you must close the FVAST app or indicate in the FVAST app that your offline and currently not providing dispatch services.
 • Riders license, profession, identity documents and criminal convictions /offences are processed to determine the compliance with the legal requirements and suitability of pursuing a profession as a dispatch rider.
 • FVAST APP displays rider’s photo, name and motor bike details to the customers for sake of identification.
 • Summaries of the riders performance on each completed trip will be on display on the FVAST riders portal, that way it’s easier to rate the efficiency and reliability.
 • Provide troubleshoot, and improve Fvast services - with your personal information, we will be able to provide functionality, analyze performance, fix errors and improve the effectiveness and efficiency of FVAST''',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w400),
                      ),
                      TextSpan(
                        text: '''\n\nLEGAL OBLIGATIONS COMPLIANCE-''',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                      TextSpan(
                        text:
                        '''\n • we collect and use your personal information to comply with the requirements of the law.
 • Personal data may be processed on the ground of legitimate interest in investigating and detecting fraudulent payments.
 • Personal data is processed for the performance of the contract concluded with the driver. The condition for the use of the use of FVAST services is the processing of riders identification and geo location data. 
 • Data regarding the criminal convictions and offences is processed for compliance with a legal obligation.''',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w400),
                      ),
                      TextSpan(
                        text: '''\n\nRECIPIENTS''',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                      TextSpan(
                        text:
                        '''\n • Your personal data is only disclosed to riders/customers as the case maybe, whose order has been accepted by you. Customers/riders will see riders/customers name, motor bikes/vehicles, phone number and photo and geo location data. 
 • Depending on the location of the driver, the personal data may be disclosed to the FVAST agents and affiliates. Processing of personal data by FVAST will occur under the same conditions as established in this privacy policy.
 • Feedback given by customers regarding the quality of services is anonymous and drivers do not receive names and telephone numbers of the passenger who provided the rating and feedback.''',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w400),
                      ),
                      TextSpan(
                        text: '''\n\nEFFECTIVE COMMUNICATION''',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                      TextSpan(
                        text:
                        '''\nWe use your personal information to communicate with you in relation to FVAST services via different channels (e.g. by phone, email, chat)''',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w400),
                      ),
                      TextSpan(
                        text: '''\n\nFRAUD PREVENTION CREDIT RISKS''',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                      TextSpan(
                        text:
                        '''\n We use personal information to prevent and detect fraud and abuse in order to protect the security of our customers, FVAST and others. We may also use scoring methods to assess and manage credit risks.''',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w400),
                      ),
                      TextSpan(
                        text:
                        '''\n\nPROCESSING CUSTOMERS ( RIDERS AND CUSTOMERS) PERSONAL DATA''',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                      TextSpan(
                        text:
                        '''\nYou may not process the personal data of riders/customers without the permission of FVAST. You may not contact any riders/customer or record, collect, grant access, store etc. , the personal data provided by the customers or accessible to you via the FVAST App for any reason whatsoever other than for the purposes of fulfilling the logistics services.
You must comply with the rules and conditions for processing of personal data of passengers as set forth in the privacy policy for customers. If by any means, any of these requirements are violated with regards to the processing of personal information of riders/customers, we may terminate your rider/customer account and claim damages from you accordingly''',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w400),
                      ),
                      TextSpan(
                        text:
                        '''\n\nDOES FVAST SHARE YOUR PERSONAL INFORMATION?''',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                      TextSpan(
                        text:
                        '''\nFvast has a very strong privacy policy which we hold very carefully and sensibly and as such will on no account share the personal detailed of our subscribers except the need calls. Such as, where a third party needs the services of a subscriber , the personal information will be recalled on the site to enable such a transaction where rightly verified by our site to pull through.
Other than as may be very necessary and unavoidable with recourse to our terms and conditions, all subscribers will receive notice when personal information about them is to be shared with third parties, and you will have an opportunity accept or reject.''',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w400),
                      ),
                      TextSpan(
                        text: '''\n\nHOW SECURE IS INFORMATION ABOUT ME''',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                      TextSpan(
                        text:
                        '''\nThe FVAST app is designed with your utmost security and privacy in mind.
 • We use encryption protocols and software, to ensure the security of your personal information during transmission
 • We follow the payment card industry Data Security Standard (PCI DSS) when handling credit card data
 • We may on certain occasions as the case maybe request proof of identity before we disclose personal information to you.
 • Our devices offer security features to protect them against unauthorized access and loss of data. This feature can be controlled and configured to meet your specific needs.
 • It’s important for you to protect against unauthorized access to your password and to your devices. Be sure to sign off when finished using a shared computer''',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w400),
                      ),
                      TextSpan(
                        text:
                        '''\n\nACCESS, CORRECTION, RETENTION, DELETION AND DATA PORTABILITY''',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                      TextSpan(
                        text:
                        '''\n • All information pertaining to you personally can be viewed and corrected in Fvast riders portal
 • Your personal data will be preserved for as long as you have an active rider’s account. If your account will be closed the personal data will be stored for an additional period of 3 years.
 • Data necessary for accounting purposes shall be stored for 7years.
 • In the event of suspicions of a administrational or criminal offence , fraud or false information, the data shall be stored for 10years
 • In the event of disputes, the data shall be retained until the claim is satisfied or the expiry date of such claims.
 • We respond to the request for deleting and transferring personal data submitted by an email within a month and specify the period of data deletion and transfer.''',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w400),
                      ),
                      TextSpan(
                        text:
                        '''\n\nWHAT ABOUT COOKIES AND OTHER IDENTIFIERS''',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                      TextSpan(
                        text:
                        '''\nTo enable our systems to recognize your browser or device and to improve FVAST services, we use cookies and other identifiers.''',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w400),
                      ),
                      TextSpan(
                        text: '''\n\nDISPUTE RESOLUTION''',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                      TextSpan(
                        text:
                        '''\nDisputes relating to the processing of personal data are resolved through customer support email ''',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w400),
                      ),
                      TextSpan(
                          text: '''fvastsupp0rt@gmail.com ''',
                          style: TextStyle(
                              color: Colors.blueAccent,
                              fontSize: 14,
                              fontWeight: FontWeight.w400),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () async {
                              String _messageTitle = "Messsage To FVAST";
                              String _url =
                                  "mailto:fvastsupp0rt@gmail.com?subject=$_messageTitle";

                              if (await canLaunch(_url)) {
                                await launch(_url);
                              } else {
                                Toast.show(" Could not launch $_url", context,
                                    duration: Toast.LENGTH_SHORT,
                                    gravity: Toast.BOTTOM);
                                throw 'Could not launch $_url';
                              }
                            }
                      ),
                      TextSpan(
                        text: '''or by calling us via ''',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w400),
                      ),
                      TextSpan(
                          text: '''+2347082575119''',
                          style: TextStyle(
                              color: Colors.blueAccent,
                              fontSize: 14,
                              fontWeight: FontWeight.w400),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () async{
                               String _url = "tel:+2347082575119";

                              if (await canLaunch(_url)) {
                              await launch(_url);
                              } else {
                              Toast.show(" Could not launch $_url", context,
                              duration: Toast.LENGTH_SHORT,
                              gravity: Toast.BOTTOM);
                              throw 'Could not launch $_url';
                              }
                          }
                      ),
                    ]),
              ),
            ),
          )),
    );
  }
}

