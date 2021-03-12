import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class TandCs extends StatefulWidget {
  @override
  _TandCsState createState() => _TandCsState();
}

class _TandCsState extends State<TandCs> {
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
              "Terms and Conditions",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: RichText(
                text: TextSpan(
                    text: 'INTRODUCTION',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                    children: <TextSpan>[
                      TextSpan(
                          text:
                              '''\nWelcome to fvast.com, this site is owned and managed by FVAST ENTERPRISE , a business duly registered with the corporate affairs commission in Nigeria, with registration number BN: 2956782
FVAST ENTERPRISE registered address is at No.9a Mogadishu Street Wuse zone 4, Abuja.
FVAST is a web based app for ordering logistics; it communicates logistics service requests to the logistics service providers who have been registered as users of the FVAST app.
FVAST makes it easy for customers who require logistics services in any part of Nigeria and beyond to be linked up to riders who are willing to render such services provided both parties are signed on to the FVAST app. 
FVAST APP, grants both riders and customers a non-exclusive, revocable license to access the app and its associated services. The eligibility to qualify for the numerous benefits embedded therein is dependent on riders and customers agreement to its terms and conditions which is geared towards protecting its valued users. FVAST may only terminate use of the website and services if in breach of its terms and conditions and this won’t be without giving proper notifications, several warnings and fair hearing to the affected users.''',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w400),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              // navigate to desired screen
                            }),
                      TextSpan(
                        text: '''\n\n1. USE OF FVAST APP''',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                      TextSpan(
                        text:
                            '''\nBy using FVAST APP, you agree to these conditions. Please read them carefully. 
 1.1. The use of the FVAST app requires installation of the software and registration of a user account ( Riders and customers alike). During the installation of the FVAST app, the mobile number of the FVAST user is linked to the respective user account and added to the database.
 1.2. When using the FVAST app, the customer can choose whether he/she wishes to pay in cash or via in-App payment for the logistics service rendered.
 1.3. Any complaints can be sent to our support team via emaill fvastsupp0rt@gmail.com through the FVAST App or by calling our support line +2347082575119''',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w400),
                      ),
                      TextSpan(
                        text: '''\n\n 2. FVAST-IN-APP PAYMENT CONDITIONS
''',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                      TextSpan(
                        text:
                            ''' 2.1 In-App payments can be made by a user of the FVAST APP who has included his/her card on the app.
  2.2 When making in-App payments, the receiver of the payment is FVAST ENTERPRISE, who forwards the received payment to the logistics service provider.
  2.3 When making in-App payments, a service is added per each order of logistics service. The named service fee includes payment commission fees.''',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w400),
                      ),
                      TextSpan(
                        text:
                            '''\n\n3. ORDERING OR CANCELLING A LOGISTICS SERVICE''',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                      TextSpan(
                        text:
                            '''\n 3.1 If the FVAST APP user orders a dispatch rider and the rider and the rider has confirmed the receipt of service then the logistics service is considered pre-ordered.
  3.2 Cancelling the use of an ordered logistics is considered to be the situation, where the rider has been notified about the receipt of an order and the FVAST app user waives the use of the logistics service after a noticed has been received.  
  3.3 Cancelling the use of an ordered logistics service is also considered to be the situation where the user of the FVAST APP or people whom the logistics service was ordered for do not show up within 10minutes as of the time when the rider notified them about the arrival of the dispatch ride in its destination.
  3.4 In case of cancelling customers request frequently by the riders, the rider guilty of this, will be required to pay a certain penalty or risk being suspended from using the FVAST APP for a certain period of time. The FVAST customers also stand of chance of being suspended from using the FVAST APP, where the rate of cancellation of orders for logistics services becomes to frequent within a 24hrs period.''',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w400),
                      ),
                      TextSpan(
                        text: '''\n\n4. CONDITION OF USE''',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                      TextSpan(
                        text:
                            '''\nIf these conditions of use are inconsistent with the service terms, those service terms will supersede.
  4.1 FVAST is a mobile app that links customers and logistics companies. Ensuring that the customers find a suitable logistics service provider closest to them. 
  4.2 The use of the FVAST APP is based on a non-exclusive licence issued by FVAST ENTERPRISE. The License agreement is valid for a non-limited period and is free of charge for all customers. In case of fault in the software, we shall endeavor to correct them as soon as possible, but do keep in mind that the functionality of this app  may be restricted due to occasional technical errors and we are not  able to guarantee the unlimited faultless functioning of the app at all times. We shall not be held liable for any lost incurred as a consequence of the FVAST APP not functioning or not being usable in the desired manner. In the event that the customer’s right to use the app is cancelled, the non-exclusive license shall also be repealed.
  4.3 FVAST is basically a link between customers and logistics service providers and as such cannot influence or take any responsibility for the quality or defects of the services of the riders. The riders and logistics services providers are not FVAST employees and as such, FVAST is unable to guarantee consistently accurate and fault free provision of logistics services located via FVAST.
  4.4 The FVAST APP is not a means for organizing the provision of logistics services. It’s also not an agency service for finding customers for logistics providers.
  4.5 The customer’s right of refund is not applicable to FVAST APP orders except where stated otherwise.
  4.6 To use the FVAST APP, a rider must be up to the age of 18 years and above; legally capable of entering into binding contracts; and not in any way whatsoever prohibited by the applicable law to enter into these terms in the jurisdiction which they are currently located, to be able to register and ride.
  4.7 You may not be able to access and use the website as a non-registered user as your ability to read the full text of the content or to receive services may be limited except you are registered. 
  4.8 You may not publish, modify, sell, transfer, transmit, display or perform any of these related functions wholly or partly except you are fully registered, subscribed, expressly permitted in these terms or/and of cause authorized by FVAST APP. 
  4.9 You may not use electronic means or any other means whatsoever to extract details or information from the app without prior authorization. Nor shall you extract information about users in order to offer them any services outside of this website. 
  4.10 In your use of the website and/or services, you shall comply with all applicable laws, regulations, directives and guidelines which apply to your use of the website and/or its services in whatsoever jurisdiction you are physically located. 
  4.11 Users of this app are obligated to provide FVAST with accurate information and should incase any of the information provided changes or becomes in accurate, such should as well be communicated in record time for adequate changes. 
  4.12 Where you have reasons to believe that any intellectual property Rights or any rights of any third party may have been infringed; co-operate with reasonable security or other checks or request for information made by FVAST in the given circumstance. 
  4.13 FVAST reserves the sole right in its discretion to take any action that it deems necessary and most appropriate in the event it considers that there is a breach or attempted breach of the terms.''',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w400),
                      ),
                      TextSpan(
                        text:
                            '''\n\n5. BY REGISTERING AN ACCOUNT WITH FVAST, A CUSTOMER /RIDER SHALL ACCEPT THE FOLLOWING CONDITIONS.''',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                      TextSpan(
                        text:
                            '''\n 5.1 FVAST shall have the right to add the personal data of the app user to FVAST database and to forward the data to all authorities   such as logistics providers in accordance with FVAST privacy policy.
  5.2 FVAST shall have a right to make unilateral arrangements to the terms and conditions policy and to relinquish the database to third parties. We may notify users of changes to terms and conditions as well as privacy policy.
  5.3 FVAST shall be entitled to transfer the data base of personal data to third parties without prior notification of the app users. In case of a transfer of the business or database, the rights and conditions   arising from this license agreement shall be transferred as well.
  5.4 FVAST shall be entitled to forward personal data and bank data to credit card and mobile payment intermediaries.
  5.5 FVAST has the right to send marketing messages and authentication codes through SMS messages
  5.6 FVAST only encourages the use of 2 modes of payments i.e. cash payment and the in-app payment (card) FVAST bears no liability on damages that may occur outside the outlined acceptable payment methods.''',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w400),
                      ),
                      TextSpan(
                        text:
                            '''\n\n6. GOOD PRACTICE OF USING THE FVAST APP.''',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                      TextSpan(
                        text:
                            '''\n  6.1 As FVAST is not a provider or broker of the logistics service, we are unable to influence the quality of the logistics   service. Any issues with defects or quality of the logistics service shall be resolved in accordance with the rules and regulations of the logistics service provider or the relevant supervisory authority.
  6.2 FVAST is committed to contributing to improvement of the quality of logistics services. For this reason, we continuously collate ratings and ask to fill out a feedback form in the FVAST app. This enables US TO offer suggestions to the logistics service providers for improving the quality of their service.
  6.3 We expect that the users of the FVAST app use the app in good faith and accord respect to one another be it the riders or the customers.
  6.4 FVAST shall make every effort to ensure that only riders, who have integrity, use the FVAST app. However, we are in no position to guarantee that every provider of logistics services, located via the FVAST APP, satisfies the aforementioned criteria at all times. If you experience objectionable logistics service, please notify the company responsible for the service, a supervisory authority or our support team.
  6.5 Where a complaint is made by a customer to FVAST that has an element of the commission of crime in it by a logistics service provider or vice versa, the affected user shall make a formal complaint to the Nigerian police force, a report is tendered, and the logistics service provider shall cooperate with the Nigeria police force in ensuring that the matter is diligently investigated.
  6.6 Where either of the users as the case maybe, is accused falsely of a crime he/she did not commit, the affected party is free to seek legal redress in court against damages to their character.
  6.7 FVAST has the right to block any riders/customers’ accounts if it suspects any fraudulent activities and charge the rider/customer for the damages caused. ''',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w400),
                      ),
                      TextSpan(
                        text: '''\n\n7. FVAST'S RIGHTS AND OBLIGATIONS''',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                      TextSpan(
                        text:
                            '''\n 7.1  Except otherwise stated, nothing in these terms shall serve to transfer from FVAST to you, any intellectual property rights belonging to FVAST APP as well as all its rights, interest and titles will remain exclusively that of FVAST APP and/or its licensors.
  7.2  FVAST reserves the right to make changes to the services and/or the website or any part thereof, as the case maybe, and may modify, remove, add and/or vary any elements of features and functionalities of the website or its services
  7.3  FVAST reserves the right to monitor your use of the website and/or services from time to time.
  7.4  FVAST shall ensure that the website and its services are available to you at all times, but FVAST APP cannot guarantee an uninterrupted and fault free service which is only likely to occur when the site is undergoing an upgrade.
  7.5  FVAST shall guarantee that all subscribers referred to users are protected as well as their intellectual properties and shall ensure efficient delivery of goods and services by its riders to its customers.''',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w400),
                      ),
                      TextSpan(
                        text: '''\n\n 8.  FVAST VERIFICATION POLICY''',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                      TextSpan(
                        text:
                            '''\nBefore a rider can be subscribed to the FVAST app, the rider will be required to undergo a verification process to ensure that only trusted and reliable riders are subscribed to the FVAST app. Upon request for verification by a rider, the FVAST service team will request that the following information be submitted by means of uploading to the site. Such Information are – 
 • Business name
 • Address
 • CAC certificate number
 • Tax Identification number
 • Bank details
 • Social media handles
 • Personal name
 • Phone number
 • Valid email
 • Drivers license.''',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w400),
                      ),
                      TextSpan(
                        text: '''\n\nFVAST BILLING POLICY''',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                      TextSpan(
                        text:
                            '''\n • RIDERS – A non-refundable fee will be paid by each subscriber (RIDERS) being a subscription charge for creating an account on this app. This payment is a one off payment and as such will never be paid again by any vendor that subscribe to this app.	
 • CUSTOMERS- The users of the FVAST APP will do so at no cost at all. The users will not pay to create their accounts.
 • Commission: Riders will be obliged to pay a 15% commission on each trip made to FVAST.
 • Taxation – All taxes with regards to transactions carried on, on the FVAST App, will be taken care of by the FVAST and as such the logistics service providers are not eligible to pay taxes and should not charge customers for taxes on services rendered.''',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w400),
                      ),
                      TextSpan(
                        text: '''\n\nDISCLAIMER''',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                      TextSpan(
                        text:
                            '''\nThis site is purely for the purpose of linking customers to logistics service providers. FVAST will not be responsible for transactions or any other relationships carried out or formed outside the confines of this site.
FVAST may assist but will not be held responsible for any attempt made on users account by a third party
FVAST will not be responsible for any bad behavior on the part of the users to one another, such as being rude, use of foul languages etc. So where this happens, and the affected user lodges a complaint this will earn the guilty party a temporal closure of their wallet on the FVAST APP for a given period''',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w400),
                      ),
                      TextSpan(
                        text: '''\n\nDISPUTES''',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                      TextSpan(
                        text:
                            '''\nAny dispute or claim relating in any way to your use of any FVAST service, or to any products or services sold or distributed by FVAST or through the FVAST app will be resolved by binding arbitration, rather than in court, and the arbitration act will govern this agreement. This will hold in a location that will be chosen by the parties.''',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w400),
                      ),
                      TextSpan(
                        text: '''\n\nAPPLICABLE LAWS''',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                      TextSpan(
                        text:
                            '''\nThese Terms shall be governed by and construed in accordance with the Laws of Nigeria and as such you irrevocably submit to the exclusive jurisdiction of the Nigerian court to settle any dispute that may arise in connections with these terms. If you live outside Nigeria, the English Law shall apply provided that it does not deprive you of any legal protection in accordance with the law of your place of residence (Local law). Where the English law deprives you of any legal protection which is accorded to you under the local law, then these terms shall be governed by the local law and any dispute or claim arising out of or in connection with these terms shall be subject to the non-exclusive jurisdiction of the courts where you are habitually resident.''',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w400),
                      ),
                      TextSpan(
                        text:
                            '''\n\nSITE POLICIES, MODIFICATION, AND SEVERABILITY''',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                      TextSpan(
                        text:
                            '''\nFVAST may alter or amend these terms as the need may arise by amending them on the website. Your continuous use of the website and/or its services after such amendment will be deemed to mean your acceptance of such amendment as the case may be. If any of these conditions shall be deemed invalid, void of for any reason unenforceable, that condition shall be deemed severable and shall not affect the validity and enforceability of any remaining condition.''',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w400),
                      ),
                    ]),
              ),
            ),
          )),
    );
  }
}
