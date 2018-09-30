import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'session.dart';
//import 'package:json_serializable/builder.dart';
import 'dart:convert';
import 'dart:async';
//import 'package:flutter/material.dart';
void main() => runApp(new MyApp());

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
String _username,_password;
var loginresult;
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appTitle = 'Form Validation Demo';

    return MaterialApp(
      title: appTitle,
      home: new MyCustomForm(),
      routes: <String, WidgetBuilder>{
        './login': (BuildContext context) => new MyCustomForm(),
        './chats': (BuildContext context) => new Chats()

      },
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

  @override
  Widget build(BuildContext context) {
    if (loginresult == null) {
      return new Scaffold(
        appBar: new AppBar(
          title: new Text('Login Page'),
        ),
        body: _loginform1(),
      );
    }
//     Navigator.push(context,
//        MaterialPageRoute(builder: (context) => Chats()));

}
//  void initState(){
//    super.initState();
//    print('2');
//      if(loginresult!=null){
//        Navigator.push(context,
//            MaterialPageRoute(builder: (context) => Chats()));
//      }
//      else{
//        setState(() {
//          loginresult=1;
//        });
//      }
//
//  }
  void _submit(){
    final form = _formKey.currentState;
    if(form.validate()){
      form.save();

      _performLogin();
    }
  }
  void _performLogin() {
    Session loginsession = new Session();
//  print(_username);
//  print(_password);
    loginsession.post('http://192.168.2.7:8080/lab6/LoginServlet', {'userid': _username, 'password': _password}).then((sa) {
      Map status = jsonDecode(sa);

      if(status['status'].toString()=='true'){
//        setState(() {
//          loginresult=1;
//        });
        Navigator.of(context).pushReplacementNamed('./chats');
      }
//          else{
//            Scaffold.of(context)
//                .showSnackBar(SnackBar(content: Text('Invalid Credentails')));
//          }
//            StatefulWidget

//  JSONObject reader = new JSONObject(sa);
//  Navigator.of(context).pushNamed(home.tag)

    });
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

class Chats extends StatefulWidget {
  @override
  _Chats createState() {
    return _Chats();
  }
}
class _Chats extends State<Chats>{
  var _result;
  final List<WordPair> _suggestions = <WordPair>[];
  final TextStyle _biggerFont = const TextStyle(fontSize: 18.0);

  void initState(){
    super.initState();
    Session loginsession = new Session();
    loginsession.post('http://192.168.2.7:8080/lab6/AllConversations',
        {'userid': _username}).then((sa) {
      Map status = jsonDecode(sa);
      print(sa);
      for (int i = 0; i < status['data'].length; i++) {
        if(status['data'][i]['last_timestamp']==null){
          _suggestions.add(new WordPair(
              status['data'][i]['uid'], "1"));
        }
        else{
          _suggestions.add(new WordPair(
              status['data'][i]['uid'], status['data'][i]['last_timestamp']));
        }

      }
      setState(() {
        if(_result==null) {
          _result = 1;
        }
        else
          {
            _result+=1;
          }
      });

    });
  }
  void logout(){
    loginresult=null;
    Navigator.of(context).pushNamedAndRemoveUntil('./login',
            (Route<dynamic> route) => false);

  }
  @override
  Widget build(BuildContext context) {
    if(_result==null){
      return new Scaffold(
        appBar: new AppBar(
          title: new Text('Chats'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.home),
              onPressed: () {
                Chats();
              },
            ),
            IconButton(
              icon: Icon(Icons.exit_to_app),
              onPressed: () {
                logout();
              },
            ),
          ],
        ),
        body: new Center(
          child: new Text('Loading..'),
        ),
      );
    }
    return new Scaffold(
        appBar: new AppBar(
          title: new Text('Chats'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.home),
              onPressed: () {
                Chats();
              },
            ),
            IconButton(
              icon: Icon(Icons.exit_to_app),
              onPressed: () {
                logout();
              },
            ),
          ],
        ),
        body: _showchats()
    );
  }
  Widget _buildRow(WordPair pair) {
    return new ListTile(
      title: new Text(
        pair.asPascalCase,
        style: _biggerFont,

      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Conversation(uid: pair.first),
          ),
        );
      },
//      onTap:() => {/
//
//        Navigator.push(context,
//        MaterialPageRoute(builder: (context) => Conversation(uid: pair.first),
//        ),
//        );
//      },///////
    );
  }



  Widget _showchats(){
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
        print(_suggestions.length);
        return _buildRow(_suggestions[index]);
      },
      itemCount: 2*_suggestions.length,
    );
  }
}


class Conversation extends StatefulWidget {
  final String uid;

  Conversation({Key key, this.uid}) : super(key: key);

  @override
  _Conversation createState() {
    return _Conversation();
  }
}
//}
//  @override
class _Conversation extends State<Conversation>{
  var _result;
  String _text1;
  final _formKey1 = GlobalKey<FormState>();

  final List<String> _text = <String>[];
  final List<String> _uuid = <String>[];
//  final TextStyle _biggerFont = const TextStyle(fontSize: 18.0);
//
  void initState(){
    super.initState();
    Session loginsession = new Session();
    loginsession.post('http://192.168.2.7:8080/lab6/ConversationDetail',
        {'id': _username, 'other_id' : widget.uid}).then((sa) {
      Map status = jsonDecode(sa);
      print(sa);
      for (int i = 0; i < status['data'].length; i++) {
//        if(status['data'][i]['last_timestamp']==null){
        _text.add(status['data'][i]['text']);
        if(status['data'][i]['uid']==_username){
          _uuid.add('You');
        }
        else{
          _uuid.add(status['data'][i]['name']);
        }
//        }
//        else{
//          _suggestions.add(new WordPair(
//              status['data'][i]['uid'], status['data'][i]['last_timestamp']));
//        }

      }
      setState(() {
        _result=1;
      });

    });
  }
//  final String first=pairr.first;
//  print(uid);

  @override
  Widget build(BuildContext context) {
    if(_result==null){
      return new Scaffold(
        appBar: new AppBar(
          title: new Text(widget.uid),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.home),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            IconButton(
              icon: Icon(Icons.exit_to_app),
              onPressed: () {
                loginresult=null;
                Navigator.of(context).pushNamedAndRemoveUntil('./login',
                        (Route<dynamic> route) => false);

              },
            ),
          ],
        ),
        body: new Center(
          child: new Text('Loading..'),
        ),
      );
    }
    return new Scaffold(
        appBar: new AppBar(
          title: new Text('Chats'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.home),
              onPressed: () {

                Navigator.of(context).pop();
              },
            ),
            IconButton(
              icon: Icon(Icons.exit_to_app),
              onPressed: () {
                loginresult=null;
                Navigator.of(context).pushNamedAndRemoveUntil('./login',
                        (Route<dynamic> route) => false);

              },
            ),
          ],
        ),
        body: new Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.max,
            children:<Widget>[
              Expanded(
                child:_buildConversationDetail(),

              ),
//          _buildConversationDetail(),

              _sendmessage(),
            ]
        )

    );

  }

  void _sendnewmessage() {
    final form = _formKey1.currentState;
    if (form.validate()) {
      form.save();

      _sendnewmessage1();
    }
  }
  void _sendnewmessage1(){
    Session loginsession = new Session();
//  print(_username);
//  print(_password);
    loginsession.post('http://192.168.2.7:8080/lab6/NewMessage',
        {'id': _username, 'other_id': widget.uid, 'msg': _text1})
        .then((sa) {
      Map status = jsonDecode(sa);
      print(sa);
//      if(status['status'].toString()=='true'){
//        Navigator.push(context,
//            MaterialPageRoute(builder: (context) => Chats()));
//      }
//    initState();
      Navigator.of(context).pop();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Conversation(uid: widget.uid),
        ),
      );
    });
//    setState((){
//      _result=5;
//    });
  }

  Widget _sendmessage(){
    return Form(
      key: _formKey1,
//    String _text,
      child: Row(

        children: <Widget>[
//          TextFormField(
//            decoration: const InputDecoration(labelText: 'Username'),
//            validator: (value) {
//              if (value.isEmpty) {
//                return 'Please enter username';
//              }
//            },
//            onSaved: (value){_username=value;},
//          ),
          new Flexible(
          child: TextFormField(
            decoration: const InputDecoration(hintText: 'new messsage'),
//            obscureText: true,
            validator: (value) {
              if (value.isEmpty) {
                return 'Please enter non empty text';
              }
            },
            onSaved:(value) { _text1=value;},
          ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6.0),
            child: RaisedButton(
              onPressed: _sendnewmessage,
              child: Text('Send'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String text) {
    return new ListTile(
      title: new Text(
        text,
//          style: _biggerFont,

      ),
//        onTap: () {
//          Navigator.push(
//            context,
//            MaterialPageRoute(
//              builder: (context) => Conversation(uid: pair.first),
//            ),
//          );
//        },
//      onTap:() => {/
//
//        Navigator.push(context,
//        MaterialPageRoute(builder: (context) => Conversation(uid: pair.first),
//        ),
//        );
//      },///////
    );
  }

  Widget _buildConversationDetail(){
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
        print(_text.length);
        String qwe= _uuid[index]+ ": " + _text[index];
        return _buildRow(qwe);
      },
      itemCount: 2*_text.length,
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
