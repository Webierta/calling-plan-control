import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../localization/language/languages.dart';
import '../models/language_data.dart';
import '../models/data.dart';
import '../widgets/button_back.dart';
import '../widgets/fecha.dart';
import 'call_screen.dart';

class SettingsScreen extends StatelessWidget {
  static const String id = 'settings_screen';

  @override
  Widget build(BuildContext context) {
    Data _myProvider = Provider.of<Data>(context);
    TextEditingController _controller =
        TextEditingController(text: _myProvider.diaField.toString());
    Languages lang = Languages.of(context);
    Color colorCustom = _myProvider.ciclo == CicloPlan.custom ? Colors.white : Colors.grey;
    Color colorMensual = _myProvider.ciclo == CicloPlan.custom ? Colors.grey : Colors.white;

    _showDialog(String titulo, String contenido) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(titulo),
            content: Text(contenido),
            actions: <Widget>[
              FlatButton(
                child: Text(lang.close),
                onPressed: () => Navigator.of(context).pop(),
              )
            ],
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(lang.settings),
        leading: _myProvider.minutosPlan != null ? ButtonBack() : null,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 30.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              InputDecorator(
                decoration: InputDecoration(
                  labelText: lang.labelSelectLanguage,
                  enabled: true,
                  contentPadding: EdgeInsets.only(left: 20.0, bottom: 10.0),
                  labelStyle: TextStyle(fontSize: 20.0),
                ),
                child: Container(
                  padding: const EdgeInsets.only(bottom: 10.0, right: 20.0),
                  alignment: Alignment.centerRight,
                  child: FractionallySizedBox(
                    widthFactor: 0.6,
                    child: DropdownButton<String>(
                      value: _myProvider.dropdownValor,
                      iconSize: 24,
                      elevation: 16,
                      underline: Container(
                        height: 2,
                        color: Theme.of(context).accentColor,
                      ),
                      isExpanded: true,
                      onChanged: (String value) {
                        _myProvider.updateDropDown = value;
                        _myProvider.setPrefLang = _myProvider.dropdownValor;
                      },
                      items: LanguageData.langs
                          .map(
                            (lang) => DropdownMenuItem(
                              value: lang.languageCode,
                              child: Text('${lang.flag}  ${lang.name}'),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: lang.labelSliderPlan,
                    enabled: true,
                    contentPadding: EdgeInsets.only(left: 20.0, bottom: 10.0),
                    labelStyle: TextStyle(fontSize: 20.0),
                  ),
                  child: Row(
                    children: <Widget>[
                      SizedBox(
                        width: 40.0,
                        child: Text(
                          _myProvider.sliderValor == 0 ? '∞' : '${_myProvider.sliderValor}',
                          style: TextStyle(fontSize: 18.0),
                        ),
                      ),
                      Expanded(
                        child: Slider(
                          value: _myProvider.sliderValor?.toDouble(),
                          min: 0,
                          max: 500,
                          divisions: 100,
                          activeColor: Theme.of(context).accentColor,
                          label: _myProvider.sliderValor == 0
                              ? lang.unlimited
                              : _myProvider.sliderValor.toString() + ' min',
                          onChanged: (double value) => _myProvider.updateSlider = value.toInt(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: RadioListTile<CicloPlan>(
                  title: Text(
                    lang.planMensual,
                    style: TextStyle(color: colorMensual),
                  ),
                  value: CicloPlan.mensual,
                  groupValue: _myProvider.ciclo,
                  activeColor: Theme.of(context).accentColor,
                  onChanged: (value) {
                    _myProvider
                      ..ciclo = value
                      ..setFromDatePicked(DateTime(DateTime.now().year, DateTime.now().month, 1))
                      ..setToDatePicked(DateTime.now());
                  },
                  subtitle: TextFormField(
                    decoration: InputDecoration(
                      labelText: lang.startDay,
                      enabled: _myProvider.ciclo == CicloPlan.custom ? false : true,
                      suffixIcon: Icon(Icons.insert_invitation),
                      contentPadding: EdgeInsets.only(top: 8.0),
                    ),
                    controller: _controller,
                    onChanged: (value) => _myProvider.updateDiaField = int.parse(value),
                    style: TextStyle(color: colorMensual),
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10.0, bottom: 20.0),
                child: RadioListTile<CicloPlan>(
                  title: Text(
                    lang.customDate,
                    style: TextStyle(color: colorCustom),
                  ),
                  value: CicloPlan.custom,
                  groupValue: _myProvider.ciclo,
                  activeColor: Theme.of(context).accentColor,
                  onChanged: (value) {
                    _myProvider
                      ..ciclo = value
                      ..updateDiaField = _myProvider.diaD;
                  },
                  subtitle: Column(
                    children: [
                      Fecha(
                        fecha: _myProvider.fromDatePicked,
                        label: lang.fromDate,
                        update: _myProvider.setFromDatePicked,
                      ),
                      Fecha(
                        fecha: _myProvider.toDatePicked,
                        label: lang.toDate,
                        update: _myProvider.setToDatePicked,
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Divider(height: 2.0, color: Colors.grey),
              ),
              Container(
                width: double.infinity,
                child: RaisedButton(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  color: Theme.of(context).accentColor,
                  elevation: 10.0,
                  onPressed: () async {
                    bool error = false;
                    if (_myProvider.ciclo == CicloPlan.custom) {
                      if (_myProvider.fromDatePicked.difference(_myProvider.toDatePicked).inDays >
                          0) {
                        error = true;
                        _showDialog('Error', lang.errorRange);
                      } else {
                        _myProvider.setDates(_myProvider.fromDatePicked.millisecondsSinceEpoch,
                            _myProvider.toDatePicked.millisecondsSinceEpoch + 86400000);
                      }
                    } else {
                      if (int.parse(_controller.text) < 1 || int.parse(_controller.text) > 31) {
                        error = true;
                        _showDialog('Error', lang.errorDay);
                      } else {
                        _myProvider.updateDiaField = int.parse(_controller.text);
                        _myProvider.setPrefDia = _myProvider.diaField;
                      }
                    }
                    if (!error) {
                      _myProvider.setPrefPlan = _myProvider.sliderValor;
                      _myProvider.setPrefLang = _myProvider.dropdownValor;
                      Navigator.pushNamed(context, CallScreen.id);
                    }
                  },
                  child: Text(lang.getData),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}