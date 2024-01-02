import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:meditation_app/models/tip.dart';
import 'package:meditation_app/models/token.dart';
import 'package:meditation_app/providrors/AuthProvider.dart';
import 'package:provider/provider.dart';

class TipsPage extends StatefulWidget {
  TipsPage({Key? key}) : super(key: key);

  @override
  _TipsPageState createState() => _TipsPageState();
}

class _TipsPageState extends State<TipsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Tip> allTips = [];
  List<Tip> userTips = [];
  TextEditingController _tipTextController = TextEditingController();
  String? authenticatedUserName;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchAllTips();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    authenticatedUserName =
        Provider.of<AuthProvider>(context, listen: false).getUserUsername();
    if (authenticatedUserName != null) {
      fetchUserTips();
    }
  }
// class _TipsPageState extends State<TipsPage>
//     with SingleTickerProviderStateMixin {
//   // Controller for the tab view
//   late TabController _tabController;

//   List<Tip> allTips = [];
//   List<Tip> userTips = [];
//   TextEditingController _tipTextController = TextEditingController();

//   // Variable to store the authenticated user's name
//   String? authenticatedUserName;

//   @override
//   void initState() {
//     super.initState();
//     // Retrieve the authenticated user's name
//     authenticatedUserName = context.read<AuthProvider>().getUserUsername();

//     // Fetch all tips and user tips when the widget is created
//     fetchAllTips();
//     fetchUserTips();

//     // Initialize the tab controller with 2 tabs
//     _tabController = TabController(length: 2, vsync: this);
//   }

//   @override
  void dispose() {
    // Dispose of the tab controller when the widget is disposed
    _tabController.dispose();
    super.dispose();
  }

  Future<void> fetchAllTips() async {
    try {
      // Make the API request to fetch all tips
      final response = await http.get(
        Uri.parse('https://coded-meditation.eapi.joincoded.com/tips'),
      );

      // Parse the response data
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          // Update the all tips list with the parsed data
          allTips = data.map((tip) => Tip.fromJson(tip)).toList();
        });
      } else {
        // Handle error if the request was not successful
        print('Failed to load all tips: ${response.statusCode}');
      }
    } catch (e) {
      // Handle any exceptions that might occur
      print('Error fetching all tips: $e');
    }
  }

  Future<void> fetchUserTips() async {
    try {
      // Obtain the authentication token from your authentication provider
      String? authToken = context.read<AuthProvider>().getAuthToken();

      // Check if the user is authenticated
      if (authToken != null) {
        // Make the API request to fetch tips created by the user
        final response = await http.get(
          Uri.parse('https://coded-meditation.eapi.joincoded.com/tips/user'),
          headers: {
            'Authorization': 'Bearer $authToken',
          },
        );

        // Parse the response data
        if (response.statusCode == 200) {
          List<dynamic> data = json.decode(response.body);
          setState(() {
            // Update the user tips list with the parsed data
            userTips = data.map((tip) => Tip.fromJson(tip)).toList();
          });
        } else {
          // Handle error if the request was not successful
          print('Failed to load user tips: ${response.statusCode}');
        }
      }
    } catch (e) {
      // Handle any exceptions that might occur
      print('Error fetching user tips: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tips'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            GoRouter.of(context).goNamed("homepage");
          },
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'All Tips'),
            Tab(text: 'My Tips'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          tipsTab(allTips, false), // Pass false for the "All Tips" tab
          tipsTab(userTips, true), // Pass true for the "My Tips" tab
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showTipCreationForm(context);
        },
        tooltip: 'Create a Tip',
        child: Icon(Icons.add),
      ),
    );
  }

  // Function to show the tip creation form
  void _showTipCreationForm(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Create a Tip'),
          content: TextField(
            controller: _tipTextController,
            decoration: InputDecoration(labelText: 'Enter your tip'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Handle tip creation here
                _createTip(context);
              },
              child: Text('Create'),
            ),
          ],
        );
      },
    );
  }

  void _createTip(BuildContext context) async {
    final String tipText = _tipTextController.text.trim();

    if (tipText.isNotEmpty) {
      // Retrieve the token string from AuthProvider
      String? authToken =
          Provider.of<AuthProvider>(context, listen: false).getAuthToken();

      if (authToken != null) {
        // Prepare the data for the POST request
        var data = {
          'text': tipText,
          'author': authenticatedUserName ?? 'Unknown',
          // Add other fields if required by the API
        };

        try {
          // Send POST request to the API
          final response = await http.post(
            Uri.parse('https://coded-meditation.eapi.joincoded.com/tips'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $authToken', // Use the token here
            },
            body: json.encode(data),
          );

          if (response.statusCode == 200 || response.statusCode == 201) {
            // Parse the response and get the actual tip data from the server
            var responseData = json.decode(response.body);
            Tip newTip = Tip.fromJson(responseData);

            // Update the state with the new tip
            setState(() {
              allTips.add(newTip);
              if (authenticatedUserName != null) {
                userTips.add(newTip);
              }
            });

            _tipTextController.clear(); // Clear the text field
            Navigator.of(context).pop(); // Close the dialog
          } else {
            // Handle error response
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text('Failed to create tip. Please try again.')),
            );
          }
        } catch (e) {
          // Handle exception
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error creating tip.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Authentication token not available. Please log in.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid tip.')),
      );
    }
  }

  // Function to handle tip deletion
  void _deleteTip(int tipId, List<Tip> tipsList) async {
    try {
      print('Deleting tip ID: $tipId');
      print(
          'API Endpoint: https://coded-meditation.eapi.joincoded.com/tips/$tipId');

      // Obtain the authentication token from your authentication provider
      String? authToken = context.read<AuthProvider>().getAuthToken();

      // Check if the user is authenticated
      if (authToken != null) {
        // Add headers for authentication
        final response = await http.delete(
          Uri.parse('https://coded-meditation.eapi.joincoded.com/tips/$tipId'),
          headers: {
            'Authorization': 'Bearer $authToken',
          },
        );

        print('Response Status Code: ${response.statusCode}');
        print('Response Body: ${response.body}');

        // Check if the deletion was successful
        if (response.statusCode == 204) {
          // Remove the deleted tip from the local list
          setState(() {
            tipsList.removeWhere((tip) => tip.id == tipId);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Tip deleted successfully.'),
            ),
          );
        } else {
          // Handle the case where the deletion was not successful
          print('Failed to delete tip: ${response.statusCode}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete tip.'),
            ),
          );
        }
      } else {
        // Handle the case where the user is not authenticated
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User not authenticated.'),
          ),
        );
      }
    } catch (e) {
      // Handle any exceptions that might occur during the API call
      print('Error deleting tip: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting tip.'),
        ),
      );
    }
  }

  // Function to show the delete confirmation dialog
  void _showDeleteConfirmationDialog(
      BuildContext context, int tipId, List<Tip> tipsList) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete this tip?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Handle tip deletion here
                _deleteTip(tipId, tipsList);
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Widget tipsTab(List<Tip> tipsList, bool isUserTipsTab) {
    return tipsList.isEmpty
        ? Center(child: Text('No tips available.'))
        : ListView.builder(
            itemCount: tipsList.length,
            itemBuilder: (context, index) {
              Tip currentTip = tipsList[index];
              // Verify if the authenticated user is the owner of the tip
              bool isOwner = currentTip.owner == authenticatedUserName;
              return ListTile(
                title: Text(currentTip.text ?? 'Default tip text'),
                subtitle: Text('Author: ${currentTip.author ?? 'Unknown'}'),
                // Show the delete button if it's the user's tip and we're in the "My Tips" tab
                trailing: isUserTipsTab && isOwner
                    ? IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _showDeleteConfirmationDialog(
                            context, currentTip.id, tipsList),
                      )
                    : null,
              );
            },
          );
  }
}
