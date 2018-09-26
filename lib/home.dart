import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'session.dart';
//import 'package:flutter/material.dart';

//class MyApp extends StatelessWidget {
//  @override
//  Widget build(BuildContext context) {
////    final wordPair = new WordPair.random();
//    return new MaterialApp(
//      title: 'Welcome to Flutter',
//      home: new RandomWords(),
//    );
//  }
//}

class home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appTitle = 'Form Validation Demo';

    return MaterialApp(
      title: appTitle,
      home: MyCustomForm(),
    );
  }
}

// Create a Form Widget
class MyCustomForm extends StatefulWidget {
  @override
  MyCustomFormState createState() {
    return MyCustomFormState();
  }
}

// Create a corresponding State class. This class will hold the data related to
// the form.
class MyCustomFormState extends State<MyCustomForm> {
  // Create a global key that will uniquely identify the Form widget and allow
  // us to validate the form
  //
  // Note: This is a GlobalKey<FormState>, not a GlobalKey<MyCustomFormState>!
  final _formKey = GlobalKey<FormState>();
  String _username,_password;
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Login Page'),
      ),
      body: _loginform1(),
    );
  }
  void _submit(){
    final form = _formKey.currentState;
    if(form.validate()){
      form.save();

      _performLogin();
    }
  }
  void _performLogin(){
    Session loginsession = new Session();
    print(_username);
    print(_password);
    loginsession.post('http://10.196.14.94:8080/lab6/LoginServlet',{'userid':_username,'password':_password}).then((sa)=>print(sa));
  }
  Widget _loginform1(){ // Build a Form widget using the _formKey we created above
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            decoration: const InputDecoration(labelText: 'Username'),
            validator: (value) {
              if (value.isEmpty) {
                return 'Please enter username';
              }
            },
            onSaved: (value){_username=value;},
          ),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Password'),
            obscureText: true,
            validator: (value) {
              if (value.isEmpty) {
                return 'Please enter password';
              }
            },
            onSaved:(value) { _password=value;},
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: RaisedButton(
              onPressed: _submit,
              child: Text('Submit'),
            ),
          ),
        ],
      ),
    );
  }
}

class RandomWordsState extends State<RandomWords> {
  final List<WordPair> _suggestions=<WordPair>[];
  final TextStyle _biggerFont = const TextStyle(fontSize: 18.0);
  @override
  Widget build(BuildContext context){
    return new Scaffold(
      appBar : new AppBar(
        title: new Text('Startup Name Generator'),
      ),
      body: _buildSuggestions(),
    );
  }
  Widget _buildRow(WordPair pair) {
    return new ListTile(
      title: new Text(
        pair.asPascalCase,
        style: _biggerFont,
      ),
    );
  }
  Widget _buildSuggestions() {
    return new ListView.builder(
        padding: const EdgeInsets.all(16.0),
        // The itemBuilder callback is called once per suggested
        // word pairing, and places each suggestion into a ListTile
        // row. For even rows, the function adds a ListTile row for
        // the word pairing. For odd rows, the function adds a
        // Divider widget to visually separate the entries. Note that
        // the divider may be difficult to see on smaller devices.
        itemBuilder: (BuildContext _context, int i) {
          // Add a one-pixel-high divider widget before each row
          // in the ListView.
          if (i.isOdd) {
            return new Divider();
          }

          // The syntax "i ~/ 2" divides i by 2 and returns an
          // integer result.
          // For example: 1, 2, 3, 4, 5 becomes 0, 1, 1, 2, 2.
          // This calculates the actual number of word pairings
          // in the ListView,minus the divider widgets.
          final int index = i ~/ 2;
          // If you've reached the end of the available word
          // pairings...
          if (index >= _suggestions.length) {
            // ...then generate 10 more and add them to the
            // suggestions list.
            _suggestions.addAll(generateWordPairs().take(10));
          }
          return _buildRow(_suggestions[index]);
        }
    );
  }
}

class RandomWords extends StatefulWidget{
  @override
  RandomWordsState createState()=> new RandomWordsState();
}
