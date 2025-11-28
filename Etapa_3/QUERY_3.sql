
-- ----------------------------------------------------------------------------
--Nome e ano de início de atividade de artistas tais que todos os utilizadores 
--nascidos de 2000 em diante tenham registado a posse de pelo menos um álbum
--interpretado por esses artistas, com as seguintes restrições adicionais: 
--só artistas que tenham lançado um ou mais álbuns nos dois últimos anos,
--e os registos de posse dos utilizadores têm de ter sido feitos entre as 12h e as 19h59.
--O resultado deve vir ordenado por nome de artista de forma ascendente e pelo
--seu ano de início de atividade de forma descendente. 
--Nota: a data de um registo de posse de álbum também guarda as horas e minutos.
--Variantes com menor cotação: a) sem a verificação do número de álbuns lançados 
--pelos atistas nos dois últimos anos;
--b) sem a verificação da hora dos registos de posse de álbuns.
-- ----------------------------------------------------------------------------
--      Artista (isni, nome, inicio)
--        Album (ean, titulo, tipo, ano, artista, suporte, versao)
--   Utilizador (username, email, senha, nascimento, artista)
--       Possui (utilizador, album, desde)
-- ----------------------------------------------------------------------------
                        -- ERROS CORRIGIDOS --
 SELECT AR.nome, AR.inicio AS inicio_de_atividade
  FROM artista AR, album AL, utilizador U, possui P
 WHERE AR.isni = AL.artista
   AND AL.ean = P.album
   AND U.username = P.utilizador
   AND NOT EXISTS ( 
   SELECT 1
     FROM utilizador U2
    WHERE U2.nascimento >= 2000
      AND NOT EXISTS ( 
      SELECT 1
        FROM album AL2, possui P2
       WHERE U2.username = P2.utilizador
         AND AL2.ean = P2.album
         AND AL2.artista = AR.isni 
         AND TO_NUMBER(TO_CHAR(P2.desde,'HH24')) BETWEEN 12 AND 19)
      )
GROUP BY AR.isni, AR.nome, AR.inicio
HAVING (MAX(AL.ano)) >= TO_NUMBER(TO_CHAR(SYSDATE,'YYYY')) - 2
ORDER BY AR.nome ASC, AR.inicio DESC;
