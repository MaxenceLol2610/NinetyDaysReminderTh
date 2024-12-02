import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  AwesomeNotifications().initialize(
    'resource://drawable/res_app_icon', // Change this to your app icon
    [
      NotificationChannel(
        channelKey: 'basic_channel',
        channelName: 'Basic notifications',
        defaultColor: Color(0xFF9D50DD),
        importance: NotificationImportance.High,
        channelShowBadge: true, channelDescription: '',
      ),
    ],
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '90 Days Report',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DateTime? _arrivalDate;
  DateTime? _dueDate;
  DateTime? _mailDate;
  DateTime? _inPersonFromDate;
  DateTime? _inPersonToDate;
  DateTime? _onlineFromDate;
  DateTime? _onlineToDate;

  @override
  void initState() {
    super.initState();
    _loadArrivalDate();
  }

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2020, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != _arrivalDate) {
      setState(() {
        _arrivalDate = picked;
        _calculateDates();
        _scheduleNotifications();
        _saveArrivalDate(picked);
      });
    }
  }

  void _calculateDates() {
    setState(() {
      _dueDate = _arrivalDate!.add(Duration(days: 90));
      _mailDate = _dueDate!.subtract(Duration(days: 15));
      _inPersonFromDate = _dueDate!.subtract(Duration(days: 15));
      _inPersonToDate = _dueDate!.add(Duration(days: 7));
      _onlineFromDate = _dueDate!.subtract(Duration(days: 15));
      _onlineToDate = _dueDate;
    });
  }

  Future<void> _scheduleNotifications() async {
    if (_mailDate != null) {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 1,
          channelKey: 'basic_channel',
          title: 'Mail Report Reminder',
          body: 'Your mail report is due by ${DateFormat.yMMMd().format(_mailDate!)}',
        ),
        schedule: NotificationCalendar.fromDate(date: _mailDate!.subtract(Duration(days: 2))),
      );
    }
    if (_inPersonFromDate != null) {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 2,
          channelKey: 'basic_channel',
          title: 'In-Person Report Reminder',
          body: 'Your in-person report is due from ${DateFormat.yMMMd().format(_inPersonFromDate!)} to ${DateFormat.yMMMd().format(_inPersonToDate!)}',
        ),
        schedule: NotificationCalendar.fromDate(date: _inPersonFromDate!),
      );
    }
    if (_onlineFromDate != null) {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 3,
          channelKey: 'basic_channel',
          title: 'Online Report Reminder',
          body: 'Your online report is due from ${DateFormat.yMMMd().format(_onlineFromDate!)} to ${DateFormat.yMMMd().format(_onlineToDate!)}',
        ),
        schedule: NotificationCalendar.fromDate(date: _onlineFromDate!),
      );
    }
  }

  Future<void> _loadArrivalDate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? arrivalDateString = prefs.getString('arrivalDate');
    if (arrivalDateString != null) {
      setState(() {
        _arrivalDate = DateTime.parse(arrivalDateString);
        _calculateDates();
      });
    }
  }

  Future<void> _saveArrivalDate(DateTime date) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('arrivalDate', date.toIso8601String());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('90 Days Report'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Arrival Date',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              _arrivalDate == null
                  ? 'Choose a date'
                  : DateFormat.yMMMd().format(_arrivalDate!),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _selectDate(context),
              child: Text('Select Arrival Date'),
            ),
            if (_arrivalDate != null) ...[
              SizedBox(height: 20),
              Text(
                'Mail Reporting up to: ${DateFormat.yMMMd().format(_mailDate!)}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              Text(
                'In Person Reporting: ${DateFormat.yMMMd().format(_inPersonFromDate!)} to ${DateFormat.yMMMd().format(_inPersonToDate!)}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              Text(
                'Online Reporting: ${DateFormat.yMMMd().format(_onlineFromDate!)} to ${DateFormat.yMMMd().format(_onlineToDate!)}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
