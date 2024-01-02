import 'dart:convert';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:meditation_app/models/tip.dart';
import 'package:meditation_app/services/client.dart'; // Ensure correct import for ApiClient
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

  List<Tip> filteredTipsList = [];
  List<Tip> allTips = [];
  List<Tip> userTips = [];
  List<Tip> filteredAllTips = [];
  List<Tip> filteredUserTips = [];
  TextEditingController _tipTextController = TextEditingController();
  TextEditingController _searchController = TextEditingController();
  String? authenticatedUserName;

  bool isSorted = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      // This makes sure the AppBar gets rebuilt when the tab changes.
      setState(() {});
    });
    fetchAllTips();
    _searchController.addListener(_onSearchChanged);
  }

//
  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      setState(() {}); // Forces the widget to rebuild when a tab is selected
    }
  }
//

  Future<void> fetchAllTips() async {
    try {
      final response = await http.get(
        Uri.parse('https://coded-meditation.eapi.joincoded.com/tips'),
      );
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);

        setState(() {
          allTips = data.map((tip) => Tip.fromJson(tip)).toList();
          filteredAllTips = allTips;
        });
      } else {
        print('Failed to load all tips: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching all tips: $e');
    }
  }

  Future<void> fetchUserTips() async {
    try {
      String? authToken =
          Provider.of<AuthProvider>(context, listen: false).getAuthToken();
      final response = await http.get(
        Uri.parse('https://coded-meditation.eapi.joincoded.com/tips/user'),
        headers: {
          'Authorization': 'Bearer $authToken',
        },
      );
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          userTips = data.map((tip) => Tip.fromJson(tip)).toList();
          filteredUserTips = userTips;
        });
      } else {
        print('Failed to load user tips: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching user tips: $e');
    }
  }

  Future<void> upVoteTip(int id) async {
    try {
      final Response response = await ApiClient.put("/tips/$id/upvote");
      if (response.statusCode == 200) {
        fetchAllTips(); // Refresh tips list after voting
      } else if (response.statusCode == 204) {
        // Manually increment the vote count for the tip with the given id
        // if the server doesn't send back the updated tip data.
        setState(() {
          final tipIndex = allTips.indexWhere((tip) => tip.id == id);
          if (tipIndex != -1) {
            allTips[tipIndex].netVotes++;
            filteredAllTips =
                List.from(allTips); // Update the filtered list if needed
          }
        });
      } else {
        print('Failed to upvote tip: ${response.statusCode}');
      }
    } catch (e) {
      print('Error upvoting tip: $e');
    }
  }

  Future<void> downVoteTip(int id) async {
    try {
      final Response response = await ApiClient.put("/tips/$id/downvote");
      if (response.statusCode == 200) {
        fetchAllTips(); // Refresh tips list after voting
      } else if (response.statusCode == 204) {
        // Manually decrement the vote count for the tip with the given id
        // if the server doesn't send back the updated tip data.
        setState(() {
          final tipIndex = allTips.indexWhere((tip) => tip.id == id);
          if (tipIndex != -1) {
            allTips[tipIndex].netVotes--;
            filteredAllTips =
                List.from(allTips); // Update the filtered list if needed
          }
        });
      } else {
        print('Failed to downvote tip: ${response.statusCode}');
      }
    } catch (e) {
      print('Error downvoting tip: $e');
    }
  }

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
      String? authToken =
          Provider.of<AuthProvider>(context, listen: false).getAuthToken();
      if (authToken != null) {
        var data = {
          'text': tipText,
          'author': authenticatedUserName ?? 'Unknown',
        };
        try {
          final response = await http.post(
            Uri.parse('https://coded-meditation.eapi.joincoded.com/tips'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $authToken',
            },
            body: json.encode(data),
          );
          if (response.statusCode == 200 || response.statusCode == 201) {
            var responseData = json.decode(response.body);
            Tip newTip = Tip.fromJson(responseData);

            setState(() {
              // Update both allTips and userTips lists
              allTips.insert(0,
                  newTip); // Add new tip at the beginning of the all tips list
              filteredAllTips =
                  List.from(allTips); // Update filtered all tips list

              // Since it's a new tip by the user, add it to userTips as well
              userTips.insert(0,
                  newTip); // Add new tip at the beginning of the user tips list
              filteredUserTips =
                  List.from(userTips); // Update filtered user tips list
            });

            _tipTextController.clear(); // Clear the text field
            Navigator.of(context).pop(); // Close the dialog
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text('Failed to create tip. Please try again.')),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error creating tip: $e')),
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

  void _deleteTip(int tipId, List<Tip> tipsList) async {
    try {
      String? authToken = context.read<AuthProvider>().getAuthToken();
      if (authToken != null) {
        final response = await http.delete(
          Uri.parse('https://coded-meditation.eapi.joincoded.com/tips/$tipId'),
          headers: {
            'Authorization': 'Bearer $authToken',
          },
        );
        if (response.statusCode == 204) {
          setState(() {
            tipsList.removeWhere((tip) => tip.id == tipId);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Tip deleted successfully.')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete tip.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User not authenticated.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting tip.')),
      );
    }
  }

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

  void _onSearchChanged() {
    // Use setState to rebuild the UI with the filtered list
    setState(() {
      if (_searchController.text.isEmpty) {
        filteredTipsList =
            allTips; // Assuming allTips is available in your state
      } else {
        // Filter the allTips list based on the search term
        filteredTipsList = allTips.where((tip) {
          String searchTerm = _searchController.text.toLowerCase();
          return tip.text.toLowerCase().contains(searchTerm);
        }).toList();
      }
    });
  }

  void sortTips() {
    setState(() {
      if (isSorted) {
        allTips = allTips.reversed.toList();
      } else {
        allTips.sort((Tip a, Tip b) => _customCompare(a.text, b.text));
      }
      filteredAllTips = List.from(allTips);
      isSorted = !isSorted;
    });
  }

  int _customCompare(String a, String b) {
    // Remove leading whitespace and convert to uppercase for case-insensitive comparison
    a = a.trim().toUpperCase();
    b = b.trim().toUpperCase();

    int maxLength = max(a.length, b.length);
    for (int i = 0; i < maxLength; i++) {
      // If we reach the end of either string, the shorter string comes first
      if (i >= a.length) return -1;
      if (i >= b.length) return 1;

      int charCodeA = a.codeUnitAt(i);
      int charCodeB = b.codeUnitAt(i);

      // Check if both characters are digits
      bool isDigitA = charCodeA >= 48 && charCodeA <= 57;
      bool isDigitB = charCodeB >= 48 && charCodeB <= 57;

      if (isDigitA && !isDigitB) return -1; // Digit before non-digit
      if (!isDigitA && isDigitB) return 1; // Non-digit after digit

      // If both are digits or both are non-digits, we compare them directly
      if (charCodeA != charCodeB) return charCodeA - charCodeB;
    }

    // If all compared characters are equal, the strings are equal in sorting
    return 0;
  }

  Widget tipsTab(bool isUserTipsTab) {
    List<Tip> tipsToDisplay = isUserTipsTab ? userTips : filteredTipsList;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(8.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Search Tips',
              suffixIcon: Icon(Icons.search),
            ),
            onChanged: (value) => _onSearchChanged(),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: tipsToDisplay.length,
            itemBuilder: (context, index) {
              Tip currentTip = tipsToDisplay[index];
              bool isOwner = currentTip.owner == authenticatedUserName;
              return ListTile(
                title: Text(currentTip.text ?? 'Default tip text'),
                subtitle: Text(
                    'Author: ${currentTip.author}, Votes: ${currentTip.netVotes}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.thumb_up),
                      color:
                          currentTip.userHasVoted ? Colors.grey : Colors.green,
                      onPressed: currentTip.userHasVoted
                          ? null
                          : () => upVoteTip(currentTip.id),
                    ),
                    // The delete button should be here if it's the 'My Tips' tab
                    if (isUserTipsTab)
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _showDeleteConfirmationDialog(
                            context, currentTip.id, tipsToDisplay),
                      ),
                    if (!isUserTipsTab)
                      IconButton(
                        icon: Icon(Icons.thumb_down),
                        color:
                            currentTip.userHasVoted ? Colors.grey : Colors.red,
                        onPressed: currentTip.userHasVoted
                            ? null
                            : () => downVoteTip(currentTip.id),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Widget tipsTab(bool isUserTipsTab) {
  //   List<Tip> tipsToDisplay = isUserTipsTab ? userTips : filteredTipsList;

  //   return Column(
  //     children: [
  //       Padding(
  //         padding: EdgeInsets.all(8.0),
  //         child: TextField(
  //           controller: _searchController,
  //           decoration: InputDecoration(
  //             labelText: 'Search Tips',
  //             suffixIcon: Icon(Icons.search),
  //           ),
  //           onChanged: (value) =>
  //               _onSearchChanged(), // Add the search functionality here
  //         ),
  //       ),
  //       Expanded(
  //         child: ListView.builder(
  //           itemCount: tipsToDisplay.length,
  //           itemBuilder: (context, index) {
  //             Tip currentTip = tipsToDisplay[index];
  //             bool isOwner = currentTip.owner == authenticatedUserName;
  //             return ListTile(
  //               title: Text(currentTip.text ?? 'Default tip text'),
  //               subtitle: Text(
  //                   'Author: ${currentTip.author}, Votes: ${currentTip.netVotes}'),
  //               trailing: Row(
  //                 mainAxisSize: MainAxisSize.min,
  //                 children: <Widget>[
  //                   IconButton(
  //                     icon: Icon(Icons.thumb_up),
  //                     color:
  //                         currentTip.userHasVoted ? Colors.grey : Colors.green,
  //                     onPressed: currentTip.userHasVoted
  //                         ? null
  //                         : () => upVoteTip(currentTip.id),
  //                   ),
  //                   IconButton(
  //                     icon: Icon(Icons.thumb_down),
  //                     color: currentTip.userHasVoted ? Colors.grey : Colors.red,
  //                     onPressed: currentTip.userHasVoted
  //                         ? null
  //                         : () => downVoteTip(currentTip.id),
  //                   ),
  //                   isUserTipsTab && isOwner
  //                       ? IconButton(
  //                           icon: Icon(Icons.delete),
  //                           onPressed: () => _showDeleteConfirmationDialog(
  //                               context, currentTip.id, tipsToDisplay),
  //                         )
  //                       : Container(),
  //                 ],
  //               ),
  //             );
  //           },
  //         ),
  //       ),
  //     ],
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    authenticatedUserName =
        Provider.of<AuthProvider>(context, listen: false).getUserUsername();

    return DefaultTabController(
      length: 2, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tips'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              GoRouter.of(context).goNamed("homepage");
            },
          ),
          bottom: TabBar(
            controller:
                _tabController, // Make sure this is initialized in initState
            tabs: [
              Tab(text: 'All Tips'),
              Tab(text: 'My Tips'),
            ],
          ),
          actions: <Widget>[
            // This button will only be visible in the 'All Tips' tab.
            if (_tabController.index == 0)
              IconButton(
                icon: isSorted ? Icon(Icons.sort_by_alpha) : Icon(Icons.sort),
                onPressed: sortTips,
                tooltip: isSorted ? 'Unsort Tips' : 'Sort Tips A-Z',
              ),
          ],
        ),
        body: TabBarView(
          controller: _tabController, // Use the initialized _tabController
          children: [
            tipsTab(false), // Passing boolean instead of the list
            tipsTab(true),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _showTipCreationForm(context);
          },
          tooltip: 'Create a Tip',
          child: Icon(Icons.add),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _tabController.removeListener(_handleTabSelection);
    _searchController.dispose();
    _tabController.removeListener(() {}); // Add this line.
    super.dispose();
  }
}
