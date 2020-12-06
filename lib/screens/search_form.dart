import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hackathon_fete_de_la_science/utilities/database.dart';

//class used when the filter button has been clicked
class FilteredSearchForm extends StatefulWidget {
  final updateFilters;
  FilterData oldFilter;
  FilteredSearchForm({Key key, this.updateFilters, this.oldFilter}) : super(key: key);

  @override
  _FilteredSearchFormState createState() => _FilteredSearchFormState();
}
class _FilteredSearchFormState extends State<FilteredSearchForm> {
  final _formKey = GlobalKey<FormState>();

  String address;
  String themes;
  DateTime date;
  TextEditingController _date;

  @override
  void initState() {
    super.initState();
    date = widget.oldFilter.date;
    if(date!=null) {
      _date = new TextEditingController(
          text: date.day.toString() + " / " + date.month.toString() + " / " +
              date.year.toString()
      );
    }
    else{
      _date = new TextEditingController();
    }
    address = widget.oldFilter.location;
  }

  //Date stuff:
  DateTime selectedDate = DateTime(2019, 10, 1);


  void updateFilter(){
    widget.updateFilters(FilterData(date, address, themes));

  }

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(1901, 1),
        lastDate: DateTime(2100));
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        date = selectedDate;
        _date.value = TextEditingValue(text:
        picked.day.toString() + " / " + picked.month.toString() + " / " +
            picked.year.toString());
        updateFilter();
      });

    }
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
            initialValue: address,
            //onSaved: (String value){print("saving adress");address = value; updateFilter();},
            onChanged: (String value){address = value; updateFilter();},
            decoration: const InputDecoration(
              hintText: 'Enter Location',
            ),
            validator: (value) {
              return null;
            },
          ),
          //Date, call the function created at start of class:
          Stack(
            alignment: Alignment.centerRight,
            children: <Widget>[
              GestureDetector(
                onTap: () => _selectDate(context),
                child: AbsorbPointer(
                  child: TextFormField(
                    //initialValue: selectedDate.day.toString() + " / " + selectedDate.month.toString() + " / " +selectedDate.year.toString(),
                    controller: _date,
                    keyboardType: TextInputType.datetime,
                    decoration: InputDecoration(
                      hintText: 'Enter Date',
                    ),
                  ),
                ),
              ),
              //Button to erase value of date.
              IconButton(
                icon: Icon(
                  Icons.cancel,
                  color: Colors.black,
                ),
                onPressed: (){date = null; updateFilter();_date.value = TextEditingValue(text: "");},
              ),
            ]
          ),
          //Theme:
          TextFormField(
            onSaved: (String value){themes = value; updateFilter();},
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
  FilterData filters = FilterData.emptyFilter();
  bool showFilters = false;

  void updateFilters(FilterData _filters){
    filters = _filters;
  }


  void _onSearchButtonPressed(){
    final form = _formKey.currentState;
    form.save();

    Stream<QuerySnapshot> filteredEvents = DataBase().searchEvents(_searchBar);

    //applys function given from parent, replaces _events

    widget.runSearch(filteredEvents, filters);

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
          FilteredSearchForm(updateFilters: updateFilters, oldFilter: filters)
    ]
    );
  }
}

class FilterData{
  DateTime date;
  String location;
  String themes;
  FilterData.emptyFilter(){}
  FilterData(DateTime date, String location, String themes){
    this.date = date;
    this.location = location;
    this.themes = themes;
  }
}