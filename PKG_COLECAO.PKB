CREATE OR REPLACE PACKAGE BODY pkg_colecao IS
-- Função auxiliar: conta álbuns de um utilizador 
  FUNCTION total_albuns_utilizador (
    utilizador_in possui.utilizador%TYPE
  ) RETURN NUMBER IS
    total NUMBER;
  BEGIN
    SELECT COUNT(*)
    INTO total
    FROM possui
    WHERE utilizador = utilizador_in;

    RETURN total;
  END;

   -- 1. Registar artista
  --------------------------------------------------------------------
  PROCEDURE regista_artista (
    isni_in   artista.isni%TYPE,
    nome_in   artista.nome%TYPE,
    inicio_in artista.inicio%TYPE
  ) IS
  BEGIN
    INSERT INTO artista (isni, nome, inicio)
    VALUES (isni_in, nome_in, inicio_in);

  EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
      RAISE_APPLICATION_ERROR(-20001, 'Já existe um artista com esse ISNI.');
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20002, SQLERRM);
  END;

   -- 2. Registar álbum
  --------------------------------------------------------------------
  PROCEDURE regista_album (
    ean_in     album.ean%TYPE,
    titulo_in  album.titulo%TYPE,
    tipo_in    album.tipo%TYPE,
    ano_in     album.ano%TYPE,
    artista_in album.artista%TYPE,
    suporte_in album.suporte%TYPE,
    versao_in  album.versao%TYPE DEFAULT NULL
  ) IS
    ano_inicio_artista artista.inicio%TYPE;
  BEGIN
    SELECT inicio
    INTO ano_inicio_artista
    FROM artista
    WHERE isni = artista_in;

    IF ano_in < ano_inicio_artista THEN
      RAISE e_ano_album_invalido;
    END IF;

    INSERT INTO album (ean, titulo, tipo, ano, artista, suporte, versao)
    VALUES (ean_in, titulo_in, tipo_in, ano_in, artista_in, suporte_in, versao_in);

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE e_artista_inexistente;
    WHEN e_ano_album_invalido THEN
      RAISE_APPLICATION_ERROR(
        -20003,
        'Ano do álbum inferior ao início de atividade do artista.'
      );
    WHEN DUP_VAL_ON_INDEX THEN
      RAISE_APPLICATION_ERROR(-20004, 'Já existe um álbum com esse EAN.');
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20005, SQLERRM);
  END;

  -- 3. Registar utilizador
  --------------------------------------------------------------------
  PROCEDURE regista_utilizador (
    username_in   utilizador.username%TYPE,
    email_in      utilizador.email%TYPE,
    senha_in      utilizador.senha%TYPE,
    nascimento_in utilizador.nascimento%TYPE,
    artista_in    utilizador.artista%TYPE DEFAULT NULL
  ) IS
    ano_atual NUMBER := TO_NUMBER(TO_CHAR(SYSDATE, 'YYYY'));
  BEGIN
    IF ano_atual - nascimento_in < 13 THEN
      RAISE e_idade_invalida;
    END IF;

    INSERT INTO utilizador (username, email, senha, nascimento, artista)
    VALUES (username_in, email_in, senha_in, nascimento_in, artista_in);

  EXCEPTION
    WHEN e_idade_invalida THEN
      RAISE_APPLICATION_ERROR(
        -20006,
        'O utilizador tem de ter pelo menos 13 anos.'
      );
    WHEN DUP_VAL_ON_INDEX THEN
      RAISE_APPLICATION_ERROR(
        -20007,
        'Username ou e-mail já existente.'
      );
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20008, SQLERRM);
  END;

  -- 4. Registar posse
  --------------------------------------------------------------------
  FUNCTION regista_posse (
    utilizador_in possui.utilizador%TYPE,
    album_in      possui.album%TYPE,
    desde_in      possui.desde%TYPE DEFAULT SYSDATE
  ) RETURN NUMBER IS
    ano_album album.ano%TYPE;
    nasc_util utilizador.nascimento%TYPE;
  BEGIN
    SELECT ano
    INTO ano_album
    FROM album
    WHERE ean = album_in;

    SELECT nascimento
    INTO nasc_util
    FROM utilizador
    WHERE username = utilizador_in;

    IF TO_NUMBER(TO_CHAR(desde_in, 'YYYY')) < ano_album OR
       TO_NUMBER(TO_CHAR(desde_in, 'YYYY')) < nasc_util + 13 THEN
      RAISE e_data_posse_invalida;
    END IF;

    INSERT INTO possui (utilizador, album, desde)
    VALUES (utilizador_in, album_in, desde_in);

    RETURN total_albuns_utilizador(utilizador_in);

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR(
        -20009,
        'Utilizador ou álbum inexistente.'
      );
    WHEN e_data_posse_invalida THEN
      RAISE_APPLICATION_ERROR(
        -20010,
        'Data de posse inválida face ao álbum ou idade do utilizador.'
      );
    WHEN DUP_VAL_ON_INDEX THEN
      RAISE_APPLICATION_ERROR(
        -20011,
        'O utilizador já possui esse álbum.'
      );
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20012, SQLERRM);
  END;

  -- 5. Remover posse
  FUNCTION remove_posse (utilizador_in IN utilizador.username%TYPE, album_in IN album.ean%TYPE) RETURN NUMBER 
IS
    albuns_i NUMBER;
    posse_nao_existe EXCEPTION;
BEGIN
    SELECT COUNT(*) INTO albuns_i -- numero de albuns possuidos pelo utilizador.
        FROM possui -- substituir depois por uma funcao da pkg.
        WHERE(utilizador = utilizador_in);

    DELETE FROM possui
        WHERE (utilizador = utilizador_in AND album = album_in);

    IF (SQL%ROWCOUNT = 0) THEN
        RAISE posse_nao_existe;
    END IF;

    RETURN albuns_i - 1; -- só existe uma posse.

    EXCEPTION
        WHEN posse_nao_existe THEN
            DBMS_OUTPUT.PUT_LINE('ERRO: O utilizador ' || utilizador_in || ' não possui o album ' || album_in);
            RETURN -1;
END remove_posse;


  -- 6. Remover utilizador
  -----------------------------------------------------------------------
  PROCEDURE remove_utilizador(username_in IN utilizador.username%TYPE)
IS
    err_utilizador_nao_existe EXCEPTION;
BEGIN 
    FOR i IN (
        SELECT album
        FROM possui
        WHERE utilizador = username_in
    ) LOOP
        remove_posse(username_in, i.album); 
        --invocar remove_posse antes de remover o utilizador
        --percorre todos os albuns do possui com o utilizador dado
    END LOOP; 
    DELETE FROM utilizador WHERE (username = username_in);
    
    IF SQL%ROWCOUNT = 0 THEN --se deletar 0 rows, nao ha esse utilizador
        RAISE err_utilizador_nao_existe;
    END IF;

    EXCEPTION 
        WHEN err_utilizador_nao_existe THEN
            DBMS_OUTPUT.PUT_LINE('ERRO: Nao existe nenhum utilizador com username ' || username_in);
    END;
END remove_utilizador;

-- 7. Remover álbum
-----------------------------------------------
PROCEDURE remove_album(ean_in IN album.ean%TYPE)
IS
     err_album_nao_existe EXCEPTION;
BEGIN 
    FOR i IN (
        SELECT utilizador
        FROM possui
        WHERE album = ean_in
    ) LOOP
        remove_posse(i.utilizador, ean_in); 
        --invocar remove_posse antes de remover o album
        --percorre todos os utilizadores do possui com o album dado
    END LOOP; 
    DELETE FROM album WHERE (ean = ean_in);
    
    IF SQL%ROWCOUNT = 0 THEN --se deletar 0 rows, entao nao existe esse album
        RAISE  err_album_nao_existe;
    END IF;

    EXCEPTION 
        WHEN  err_album_nao_existe THEN
            DBMS_OUTPUT.PUT_LINE('ERRO: Nao existe nenhum album com ean ' || ean_in);
    END;
END remove_album;

 -- 8. Remover artista
  -----------------------------------------------------------------------
PROCEDURE remove_artista (isni_in IN artista.isni%TYPE) 
IS    
    linhas NUMBER; -- define a variável local utilizada para detetar se utilizador existe.
    artista_nao_existe EXCEPTION; -- exceção usada para quando o utilizador removido não existe.
    CURSOR c_albuns IS -- cursor dos álbuns do artista.
        SELECT ean FROM album
        WHERE (artista = isni_in)
        FOR UPDATE OF album;
BEGIN
    DELETE FROM artista
        WHERE isni = isni_in;
        linhas := SQL%ROWCOUNT;

        IF linhas = 0 THEN
            RAISE artista_nao_existe;
        ELSE
            OPEN c_albuns;
            FOR ean IN c_albuns LOOP
                remove_album(ean);
            END LOOP;   
            CLOSE c_albuns;
            DBMS_OUTPUT.PUT_LINE('SUCESSO: artista com isni ' || isni || 'foi removido.');
        END IF;

    EXCEPTION
        WHEN artista_nao_existe THEN
            DBMS_OUTPUT.PUT_LINE('ERRO: artista com isni ' || isni || ' não existe.');
END remove_artista;
