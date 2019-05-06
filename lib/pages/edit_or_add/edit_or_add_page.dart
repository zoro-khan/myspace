import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc_pattern/flutter_bloc_pattern.dart';
import 'package:sqlite_bloc_rxdart/domain/contact.dart';
import 'package:sqlite_bloc_rxdart/pages/edit_or_add/edit_or_add_bloc.dart';
import 'package:sqlite_bloc_rxdart/pages/edit_or_add/edit_or_add_state.dart';
import 'package:sqlite_bloc_rxdart/utils.dart';

class EditOrAddPage extends StatefulWidget {
  final bool addMode;

  const EditOrAddPage({
    Key key,
    @required this.addMode,
  })  : assert(addMode != null),
        super(key: key);

  @override
  _EditOrAddPageState createState() => _EditOrAddPageState();
}

class _EditOrAddPageState extends State<EditOrAddPage>
    with SingleTickerProviderStateMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  StreamSubscription<EditOrAddMessage> _subscriptionMessage;
  StreamSubscription<bool> _subscriptionIsLoading;

  AnimationController _fadeController;
  Animation<double> _fadeAnim;

  FocusNode _phoneFocusNode;
  FocusNode _addressFocusNode;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        curve: Curves.fastOutSlowIn,
        parent: _fadeController,
      ),
    );

    _phoneFocusNode = FocusNode();
    _addressFocusNode = FocusNode();
  }

  @override
  void didChangeDependencies() {
    _subscriptionIsLoading ??=
        BlocProvider.of<EditOrAddBloc>(context).isLoading$.listen((isLoading) {
      if (isLoading) {
        _fadeController.forward();
      } else {
        _fadeController.reverse();
      }
    });
    _subscriptionMessage ??=
        BlocProvider.of<EditOrAddBloc>(context).message$.listen((message) {
      final scaffoldState = _scaffoldKey?.currentState;

      if (message is InvalidInformation) {
        showSnackBar(
          scaffoldState,
          'Invalid information',
        );
      }
      if (message is AddContactSuccess) {
        showSnackBar(
          scaffoldState,
          'Add contact successfully',
        );
      }
      if (message is AddContactFailure) {
        showSnackBar(
          scaffoldState,
          'Add contact not successfully',
        );
      }
      if (message is UpdateContactSuccess) {
        showSnackBar(
          scaffoldState,
          'Update contact successfully',
        );
      }
      if (message is UpdateContactFailure) {
        showSnackBar(
          scaffoldState,
          'Update contact not successfully',
        );
      }
    });
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _subscriptionIsLoading?.cancel();
    _subscriptionMessage?.cancel();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<EditOrAddBloc>(context);

    final nameTextField = StreamBuilder<NameError>(
      stream: bloc.nameError$,
      builder: (context, snapshot) {
        getErrorText(NameError nameError) {
          if (nameError is LengthOfNameIsLessThanThreeCharacters) {
            return 'At least 3 characters';
          }
        }
        final errorText = getErrorText(snapshot.data);

        return TextField(
          autocorrect: true,
          decoration: InputDecoration(
            prefixIcon: Padding(
              padding: EdgeInsetsDirectional.only(end: 8.0),
              child: Icon(Icons.person_outline),
            ),
            labelText: 'Name',
            errorText: errorText,
          ),
          keyboardType: TextInputType.text,
          maxLines: 1,
          autofocus: true,
          onChanged: bloc.nameChanged,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) {
            FocusScope.of(context).requestFocus(_phoneFocusNode);
          },
          style: TextStyle(fontSize: 16.0),
        );
      },
    );

    final phoneTextField = StreamBuilder<PhoneError>(
      stream: bloc.phoneError$,
      builder: (context, snapshot) {
        getErrorText(PhoneError phoneError) {}
        final errorText = getErrorText(snapshot.data);

        return TextField(
          focusNode: _phoneFocusNode,
          autocorrect: true,
          decoration: InputDecoration(
            prefixIcon: Padding(
              padding: EdgeInsetsDirectional.only(end: 8.0),
              child: Icon(Icons.phone),
            ),
            labelText: 'Phone number',
            errorText: errorText,
          ),
          keyboardType: TextInputType.text,
          maxLines: 1,
          autofocus: true,
          onChanged: bloc.phoneChanged,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) {
            FocusScope.of(context).requestFocus(_addressFocusNode);
          },
          style: TextStyle(fontSize: 16.0),
        );
      },
    );

    final addressTextField = StreamBuilder<AddressError>(
      stream: bloc.addressError$,
      builder: (context, snapshot) {
        getErrorText(AddressError phoneError) {}
        final errorText = getErrorText(snapshot.data);

        return TextField(
          focusNode: _addressFocusNode,
          autocorrect: true,
          decoration: InputDecoration(
            prefixIcon: Padding(
              padding: EdgeInsetsDirectional.only(end: 8.0),
              child: Icon(Icons.label),
            ),
            labelText: 'Address',
            errorText: errorText,
          ),
          keyboardType: TextInputType.text,
          maxLines: 1,
          autofocus: true,
          onChanged: bloc.addressChanged,
          textInputAction: TextInputAction.next,
          style: TextStyle(fontSize: 16.0),
        );
      },
    );

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          widget.addMode ? 'Add contact' : 'Edit contact',
        ),
      ),
      body: Container(
        constraints: BoxConstraints.expand(),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: nameTextField,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: phoneTextField,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: addressTextField,
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: StreamBuilder<Gender>(
                    stream: bloc.gender$,
                    initialData: bloc.gender$.value,
                    builder: (context, snapshot) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Radio<Gender>(
                            value: Gender.male,
                            groupValue: snapshot.data,
                            onChanged: bloc.genderChanged,
                          ),
                          Text(
                            'Male',
                            style: TextStyle(
                              fontSize: 16.0,
                            ),
                          ),
                          Radio<Gender>(
                            value: Gender.female,
                            groupValue: snapshot.data,
                            onChanged: bloc.genderChanged,
                          ),
                          Text(
                            'Female',
                            style: TextStyle(
                              fontSize: 16.0,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                Center(
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                  ),
                  child: RaisedButton(
                    child: Text(
                      widget.addMode ? 'Add' : 'Update',
                    ),
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        8,
                      ),
                    ),
                    color: Theme.of(context).cardColor,
                    splashColor: Theme.of(context).accentColor,
                    onPressed: bloc.submit,
                  ),
                ),
                SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
