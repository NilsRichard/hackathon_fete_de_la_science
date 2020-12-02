import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hackathon_fete_de_la_science/utilities/database.dart';

//class used when the filter button has been clicked
class FilteredSearchForm extends StatefulWidget {
  FilteredSearchForm({Key key}) : super(key: key);

  @override
  _FilteredSearchFormState createState() => _FilteredSearchFormState();
}
class _FilteredSearchFormState extends State<FilteredSearchForm> {
  final _formKey = GlobalKey<FormState>();

  //Date stuff:
  DateTime selectedDate = DateTime.now();
  TextEditingController _date = new TextEditingController();

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(1901, 1),
        lastDate: DateTime(2100));
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        _date.value = TextEditingValue(text: picked.toString());
      });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          //Location:
          TextFormField(
            decoration: const InputDecoration(
              hintText: 'Enter Location',
            ),
            validator: (value) {
              return null;
            },
          ),
          //Date, call the function created at start of class:
          GestureDetector(
            onTap: () => _selectDate(context),
            child: AbsorbPointer(
              child: TextFormField(
                controller: _date,
                keyboardType: TextInputType.datetime,
                decoration: InputDecoration(
                  hintText: 'Enter Date',
                ),
              ),
            ),
          ),
          //Theme:
          TextFormField(
            decoration: const InputDecoration(
              hintText: 'Enter Theme',
            ),
            validator: (value) {
              return null;
            },
          ),
        ],
      ),
    );
  }
}

/// Class to make searches.
class SearchForm extends StatefulWidget {
  final runSearch;
  SearchForm({Key key, this.runSearch}) : super(key: key);

  @override
  _SearchFormState createState() => _SearchFormState();
}

/// This is the private State class that goes with SearchForm.
class _SearchFormState extends State<SearchForm> {
  final _formKey = GlobalKey<FormState>();

  String _searchBar;
  bool showFilters = false;

  bool streamEmptyReturn;

  void myCallback(bool b) {
    streamEmptyReturn = b;
  }

  void _onSearchButtonPressed(){
    final form = _formKey.currentState;
    form.save();
    Stream<QuerySnapshot> byTitle = DataBase().getEventsByTitle(_searchBar);
    Future<bool> emptyStream = byTitle.isEmpty;
    emptyStream.then(myCallback);
    //while(streamEmptyReturn==null){print("jesus fucking christ");}

    widget.runSearch(DataBase().getEventsByTitle(_searchBar));

  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Stack(
              alignment: Alignment.centerRight,
              children: <Widget>[
                TextFormField(
                  onSaved: (value) => _searchBar = value,
                  decoration: const InputDecoration(
                    hintText: 'Enter search',
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.search,
                    color: Colors.black,
                  ),
                  onPressed: (){_onSearchButtonPressed();},
                ),
              ]
            ),
            TextButton(
              onPressed: () {
                //show filters
                showFilters = !showFilters;
                setState(() {
                });
              },
              child: Text('Filters'),
            ),

          ],
        ),
      ),
        if(showFilters)
          FilteredSearchForm()
    ]
    );
  }
}