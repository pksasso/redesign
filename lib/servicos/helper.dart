import 'package:redesign/modulos/usuario/usuario.dart';

class Helper {

  static const String emailLabdis = "labdis.ufrj@gmail.com";

  /// Retorna o nome da ocupação para o tipo de instituição passada.
  /// Ocupacao secundária: Aluno, Bolsista, Estudante.
  ///
  /// Ex: Para laboratórios, retorna "Bolsista".
  /// Para Escolas, retorna "Aluno"
  static String getOcupacaoSecundariaParaInstituicao(String ocupacao_instituicao){
    switch(ocupacao_instituicao){
      case Ocupacao.incubadora:
        return "";

      case Ocupacao.laboratorio:
        return Ocupacao.bolsista;

      case Ocupacao.escola:
        return Ocupacao.aluno;

      default:
        return Ocupacao.bolsista;
    }
  }

  /// Retorna um titulo no plural para a instituicao.
  static String getTituloOcupacaoSecundaria(String ocupacao_instituicao){
    switch(ocupacao_instituicao){
      case Ocupacao.incubadora:
        return "";

      case Ocupacao.laboratorio:
        return "Bolsistas";

      case Ocupacao.escola:
        return "Alunos";

      default:
        return "Bolsistas";
    }
  }

  /// Retorna o nome da ocupação para o tipo de instituição passada.
  /// Ocupacao primária: Professor ou Empreendedor.
  ///
  /// Ex: Para laboratórios, retorna "Professor".
  /// Para Escolas, retorna "Professor"
  static String getOcupacaoPrimariaParaInstituicao(String ocupacao_instituicao){
    switch(ocupacao_instituicao){
      case Ocupacao.incubadora:
        return Ocupacao.empreendedor;

      case Ocupacao.laboratorio:
      case Ocupacao.escola:
        return Ocupacao.professor;

      default:
        return Ocupacao.professor;
    }
  }

  /// Retorna um titulo no plural para a instituicao.
  static String getTituloOcupacaoPrimaria(String ocupacao_instituicao){
    switch(ocupacao_instituicao){
      case Ocupacao.incubadora:
        return "Empreendedores";

      case Ocupacao.laboratorio:
      case Ocupacao.escola:
        return "Professores";

      default:
        return "Professores";
    }
  }
}