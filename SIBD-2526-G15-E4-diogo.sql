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