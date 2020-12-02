import 'package:flutter/material.dart';

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
  SearchForm({Key key}) : super(key: key);

  @override
  _SearchFormState createState() => _SearchFormState();
}

/// This is the private State class that goes with SearchForm.
class _SearchFormState extends State<SearchForm> {
  final _formKey = GlobalKey<FormState>();

  bool showFilters = false;

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
            TextFormField(
              decoration: const InputDecoration(
                hintText: 'Enter search',
                suffixIcon: IconButton(
                  icon: Icon(
                    Icons.search,
                    color: Colors.black,
                  ),
                  /*onPressed: () {
                    print('trying to tweet');
                    tweet();
                  },*/
                ),
              ),
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              },
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
          Expanded(child: FilteredSearchForm())
    ]
    );
  }
}
