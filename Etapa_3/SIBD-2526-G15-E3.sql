-- SIBD2526 E2 G15 --------------------------------------
-- António Cabral, 52913, TP11
-- Diogo Domingos, 61887 , TP13
-- Duarte Rodrigues, 63746, TP13
-- Jaime Vardasca, 63732 , TP13
---------------------------------------------------------
--Q1 -> António
--Q2 -> Diogo
--Q3 -> Jaime
--Q4 -> Duarte
-----------------------------------------------------------
--1. Username e e-mail dos utilizadores nascidos em 1990, que têm como artista
--favorito Day6, e que, durante o ano de 2025, registaram a posse de um ou mais
--álbuns interpretados por esse artista. O EAN-13, título, e ano de lançamento
--dos álbuns também devem ser mostrados, bem como o número de dias que
--passaram desde a data dos registos de posse. A ordenação do resultado deve
--ser ascendente pelo username dos utilizadores e descendente pelo número de
--dias que passaram desde os registos de posse e pelo EAN-13 dos álbuns.

SELECT
	/*
	Na seleção principal, queremos retornar o nome de utilizador e 
	o email a este associado, bem como o código EAN do àlbum, o seu
	título juntamente com o seu ano de lançamento e, por fim, uma 
	coluna calculada a que chamamos "dias_desde_registo", que corres-
	ponderá ao número de dias entre o dia de hoje e o dia em que o 
	utilizador adquiriu um àlbum de um certo artista, neste caso, o
	artista Day6. Dado que não utilizamos um DISTINCT ou uma agregação,
	múltiplas linhas podem ser retornadas no caso de um utilizador possuir
	múltiplas obras desse mesmo artista.
	*/
	usr.username, 												-- O nome do utilizador
	usr.email,													-- O seu email
	alb.ean,													-- O identificador do àlbum
	alb.titulo,													-- O título do àlbum
	alb.ano,													-- O seu ano de lançamento
	TRUNC(SYSDATE) - TRUNC(psi.desde) AS dias_desde_registo		-- O nº de dias de posse
FROM
	/*
	Começamos com um utilizador e iniciamos um JOIN a um artista
	utilizando usr.artista = art.isni, i.e., o artista perferido
	faz referência a um identificador ISNI.
	Juntamos a isto um link entre o utilizador e um album, usando
	psi.utilizador = usr.username, psi.album = alb.ean, requerindo
	simultâneamente que alb.artista = art.isni, i.e., o album 
	pertence ao mesmo artista perferido pelo utilizador.
	*/  									
	utilizador usr
	JOIN
		artista art
		ON
			usr.artista = art.isni				
	JOIN
		possui psi 
		ON
			psi.utilizador = usr.username
	JOIN
		album alb
		ON
			alb.ean = psi.album
			AND
			alb.artista = art.isni
WHERE
	/*
	Agora, filtramos o resultado do nosso SELECT para que obedeça
	às regras impostas pelo objetivo proposto. São estas, a saber:
	Só queremos utilizadores que tenham nascido em 1990 
		usr.nascimento = 1990
	E cujo artista perferido seja o artista de nome Day6
		art.nome = 'Day6'
	E que estejam na posse de àlbums deste artista ente 1/1/2025
	e 31/12/2025, inclusivamente
		psi.desde >= DATE '2025-01-01'
		psi.desde < 1/1/2026
	*/
	usr.nascimento = 1990
	AND
	art.nome = 'Day6'
	AND
	psi.desde >= DATE '2025-01-01'
	AND
	psi.desde < DATE '2026-01-01'
ORDER BY
	/*
	Finalmente, ordenamos os dados retornados de forma ascendente
	quanto ao nome de utilizador, depois por ordem descendente por
	dias_desde_registo (dos mais antigos para os mais recentes) e
	finalmente, de forma descendente pelo EAN do àlbum em questão.
	*/
	usr.username ASC,
	dias_desde_registo DESC,
	alb.ean DESC;
--------------------------------------------------------------------------
--2. Username dos utilizadores com endereço de e-mail no gmail.com que,
--considerando apenas os registos de posse efetuados entre 2000 e 2020,
--ou não possuem álbuns interpretados pelo artista Dire Straits, ou possuem no máximo
--três álbuns desse artista. Adicionalmente, os utilizadores não podem possuir
--álbuns do tipo single, seja qual for o artista e o ano do registo. O resultado deve
--vir ordenado pelo username de forma ascendente.

SELECT usr.username 
FROM utilizador usr  
WHERE usr.email LIKE '%@gmail.com'
  AND EXISTS (
        SELECT 1 
        FROM possui p
        WHERE usr.username = p.utilizador
          AND p.desde BETWEEN '2000-01-01' AND '2020-12-31'
  )
  AND (
        SELECT COUNT(*)
        FROM possui p2
        JOIN album a ON a.ean = p2.album
        JOIN artista ar ON ar.isni = a.artista
        WHERE p2.utilizador = usr.username
          AND ar.nome = 'Dire Straits'
      ) <= 3;
----------------------------------------------------------------------------
--3. Nome e ano de início de atividade de artistas tais que todos os 
--utilizadores nascidos de 2000 em diante tenham registado a posse de pelo menos um álbum
--interpretado por esses artistas, com as seguintes restrições adicionais:
--só artistas que tenham lançado um ou mais álbuns nos dois últimos anos, 
--e os registos de posse dos utilizadores têm de ter sido feitos entre as 12h e as 19h59.
--O resultado deve vir ordenado por nome de artista de forma ascendente e pelo
--seu ano de início de atividade de forma descendente. Nota: a data de um registo
--de posse de álbum também guarda as horas e minutos.

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
-----------------------------------------------------------------------
--4. Username dos utilizadores com mais registos de posse de álbuns em suporte
--vinil em cada ano, separadamente para utilizadores nascidos nas décadas de
--1980 e 1990, devendo a década de nascimento dos utilizadores e o número total
--de registos de posse de álbuns em cada ano também aparecer no resultado. A
--ordenação do resultado deve ser descendente pelo ano e ascendente pela década
--de nascimento dos utilizadores. No caso de haver mais do que um utilizador 
--nascido na mesma década e com o mesmo número máximo de registos de
--posse de álbuns num ano, devem ser mostrados todos esses utilizadores. Nota:
--por conveniência, está disponível a função decada_de_ano, que arredonda um
--ano com quatro dígitos à década; por exemplo, decada_de_ano(2025) = 2020.
--------------
--Username ~~mais albuns 'vinil' GROUP BY ano(adição)(desc) -com(decada_nasc e total_registros)
--~~Separados para User.Birthdate decadas 80 e 90 (asc)
--
--em caso de colisão, mostrar todos
--------------
-- SELECT 
--     PO.utilizador, 
--     decada_de_ano(PO.utilizador.nascimento) AS decada_nasc, 
--     TO_CHAR(possui.desde, 'YYYY') AS ano_registro,
--     COUNT(*) AS total_possuido
-- FROM possui PO
-- INNER JOIN album AL 
--     ON PO.album=AL.ean
-- INNER JOIN utilizador UT 
--     ON UT.username=PO.utilizador
-- WHERE AL.suporte = 'vinil'
-- GROUP BY 
--     PO.utilizador, 
--     TO_CHAR(PO.desde, 'YYYY')
-- ORDER BY 
--     total_possuido DESC, 
--     ano_registro DESC, 
--     decada_nasc ASC;

SELECT 
    RankTable.ano,
    RankTable.decada,
    RankTable.username,
    RankTable.total
FROM (
    SELECT
        UT.username,
        decada_de_ano(UT.nascimento) AS decada,
        TO_CHAR(PO.desde, 'YYYY') AS ano,
        COUNT(*) AS total,
        RANK() OVER (
                PARTITION BY 
                    decada_de_ano(UT.nascimento),
                    TO_CHAR(PO.desde, 'YYYY')
                ORDER BY COUNT(*) DESC
            ) AS rnk
    FROM possui PO
    JOIN album AL  
        ON PO.album = AL.ean
    JOIN utilizador UT 
       ON PO.utilizador = UT.username 
    WHERE 
        AL.suporte = 'vinil'
        AND decada_de_ano(UT.nascimento) IN (1980, 1990)
    GROUP BY
        UT.username,
        decada_de_ano(UT.nascimento),
        TO_CHAR(PO.desde, 'YYYY')
) RankTable
WHERE RankTable.rnk = 1
ORDER BY
    ano DESC,

    decada ASC

