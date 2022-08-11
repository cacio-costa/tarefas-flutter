import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';

void main() {
  runApp(TarefasBoticarioApp());
}

class TarefasBoticarioApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Boticário - Gerenciamento de Tarefas',
      home: TelaListagemDeTarefas(),
    );
  }
}

class Tarefa {
  int? id;
  String descricao;

  Tarefa(this.id, this.descricao);
}

Future<List<Tarefa>> recuperaTarefas() async {
  Response resposta = await get(Uri.parse('http://localhost:3000/tarefas'));
  String corpoDaResposta = resposta.body;

  List<dynamic> listaJson = jsonDecode(corpoDaResposta);
  return listaJson.map((json) => Tarefa(int.tryParse(json['_id']), json['descricao']))
      .toList();
}


class Cartao extends StatelessWidget {
  Tarefa tarefa;

  Cartao(this.tarefa);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: 100, minWidth: double.infinity),
      padding: EdgeInsets.all(16.0),
      margin: EdgeInsets.only(bottom: 16.0),
      width: double.infinity,
      alignment: Alignment.center,
      color: Color(0xffebef40),
      child: Text(this.tarefa.descricao, style: TextStyle(fontSize: 16.0)),
    );
  }
}

class TelaListagemDeTarefas extends StatefulWidget {

  @override
  State<TelaListagemDeTarefas> createState() => _TelaListagemDeTarefasState();
}

class _TelaListagemDeTarefasState extends State<TelaListagemDeTarefas> {

  List<Tarefa> todasAsTarefas = [];
  List<Tarefa> tarefasFiltradas = [];

  @override
  void initState() {
    super.initState();

    recuperaTarefas()
      .then((tarefas) {
        setState(() {
          todasAsTarefas = tarefas;
          tarefasFiltradas = tarefas;
        });
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tarefas'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 32.0),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Filtrar tarefas',
                  suffixIcon: Icon(Icons.search),
                ),
                onChanged: filtra,
              ),
            ),
            Visibility(
              visible: tarefasFiltradas.isEmpty,
              child: Text('Nenhum tarefa encontrada', style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              )),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: tarefasFiltradas.length,
                itemBuilder: (context, indice) {
                  return Cartao(tarefasFiltradas[indice]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void filtra(String filtro) {
    List<Tarefa> tarefasFiltradas = todasAsTarefas
        .where(
          (tarefa) => tarefa.descricao.toLowerCase().contains(filtro.toLowerCase()),
        )
        .toList();

    setState(() => this.tarefasFiltradas = tarefasFiltradas);
  }

}
