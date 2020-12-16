import 'package:mysql1/mysql1.dart';

Future<MySqlConnection> getDBConnection() async {
  var settings = ConnectionSettings(
      host: 'localhost',
      port: 3306,
      user: 'root',
      password: 'root',
      db: 'example_dart_mysql');
  return await MySqlConnection.connect(settings);
}

Future<void> cadastrarAluno(String aluno, String turma) async {
  var conn = await getDBConnection();
  var result = await conn
      .query('INSERT aluno(cd_aluno, nome) VALUES (null, ?)', [aluno]);

  var alunoId = result.insertId;
  var turmaId = await getTurmaId(turma);
  await conn.query('INSERT INTO turma_aluno VALUES (?,?)', [turmaId, alunoId]);
  await conn.close();
}

Future<String> atualizarAluno(int id, String nome) async {
  var conn = await getDBConnection();
  var result = await conn
      .query('UPDATE aluno SET nome = ? WHERE cd_aluno = ?', [nome, id]);
  await conn.close();
  if (result.affectedRows > 0) {
    return 'Aluno atualizado com sucesso -> ${result.insertId}';
  } else {
    return 'Aluno não encontrado';
  }
}

Future<int> getTurmaId(String nomeTurma) async {
  var conn = await getDBConnection();
  var result =
      await conn.query('SELECT id FROM turma WHERE nome = ?', [nomeTurma]);

  await conn.close();
  return result.first[0];
}

Future<Results> getAlunoETurma() async {
  var conn = await getDBConnection();
  var result = await conn
      .query('''SELECT t.nome, a.nome FROM turma t INNER JOIN turma_aluno ta
                          ON t.id = ta.turma_id INNER JOIN aluno a ON ta.aluno_id = a.cd_aluno''');
  await conn.close();
  return result;
}

void run() async {
  //await cadastrarAluno('Isabel', 'Turma2');
  //var mensagem = await atualizarAluno(4, 'Anderson');
  //print(mensagem);
  var result = await getAlunoETurma();
  result.forEach((row) {
    print('O aluno: ${row[1]}, está na turma ${row[0]}');
  });
}
