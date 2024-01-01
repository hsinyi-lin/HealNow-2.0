import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';


String formatDateString(String dateString) {
  DateFormat inputFormat = DateFormat('EEE, dd MMM yyyy HH:mm:ss \'GMT\'');
  DateTime dateTime = inputFormat.parse(dateString, true).toLocal();
  String formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);
  return formattedDate;
}


void launchURL(String? urlString) async {
  if (urlString == null) return;

  final Uri url = Uri.parse(urlString);

  if (await canLaunchUrl(url)) {
    await launchUrl(url);
  } else {
    throw 'can not open $urlString';
  }
}

