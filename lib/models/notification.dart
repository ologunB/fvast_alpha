class NotificationModel {
   String title;
   
  NotificationModel(
      this.title,
      );

  NotificationModel.map(dynamic obj) {
 
    title = obj["displayType"].toString();
  }
}
