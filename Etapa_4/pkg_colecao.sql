CREATE OR REPLACE PACKAGE pkg_colecao 
  IS
  /*
  Lista de exceções e descrição:
    err_artista_existe: o artista referido já existe (ISNI duplicado);
    err_artista_nao_existe: o artista referido não existe;
    err_album_existe: álbum referido já existe (EAN duplicado);
    err_album_nao_existe: álbum referido não existe;
    err_utilizador_existe: utilizador referido já existe;
    err_utilizador_nao_existe: utilizador referido não existe;
    err_posse_existe: posse já existe;
    err_posse_nao_existe: posse não existe;
    err_idade_invalida: utilizador tem menos de 13 anos de idade(RIA-15);
    err_ano_album_invalido: ano do álbum anterior ao início de atividade do artista (RIA-08);
    err_data_posse_invalida: data de posse é inválida (RIA-16/17);
    err_remocao_nao_existente: tentativa de remover registo inexistente;
    err_integridade: erro de integridade referencial/constraint;
  */

  PROCEDURE regista_artista(
    isni_in IN artista.isni%TYPE,
    nome_in IN artista.nome%TYPE,
    inicio_in IN artista.inicio%TYPE
  );

  PROCEDURE regista_album(
    ean_in IN album.ean%TYPE,
    titulo_in IN album.titulo%TYPE,
    tipo_in IN album.tipo%TYPE,
    ano_in IN album.ano%TYPE,
    artista_in IN album.artista%TYPE,
    suporte_in IN album.suporte%TYPE,
    versao_in IN album.versao%TYPE := NULL
    );

  PROCEDURE regista_utilizador(
    username_in IN utilizador.username%TYPE,
    email_in IN utilizador.email%TYPE,
    senha_in IN utilizador.senha%TYPE,
    nascimento_in IN utilizador.nascimento%TYPE,
    artista_in IN utilizador.artista%TYPE := NULL
    );

  FUNCTION regista_posse(
    utilizador_in IN possui.utilizador%TYPE,
    album_in IN possui.album%TYPE,
    desde_in IN possui.desde%TYPE := SYSDATE
    ) RETURN NUMBER;

  FUNCTION remove_posse(
    utilizador_in IN possui.utilizador%TYPE,
    album_in IN possui.album%TYPE
    ) RETURN NUMBER;

  PROCEDURE remove_utilizador(
    username_in IN utilizador.username%TYPE
    );

  PROCEDURE remove_album(
    ean_in IN album.ean%TYPE
    );

  PROCEDURE remove_artista(
    isni_in IN artista.isni%TYPE
    );

  FUNCTION lista_albuns(
    utilizador_in IN utilizador.username%TYPE
    ) RETURN SYS_REFCURSOR;
END pkg_colecao;
