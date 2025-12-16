/*#################################################################################
#  Username e e-mail dos utilizadores nascidos em 1990, que têm como artista	  #
#  favorito Day6, e que, durante o ano de 2025, registaram a posse de um ou mais  #
#  álbuns interpretados por esse artista. O EAN-13, título, e ano de lançamento	  #
#  dos álbuns também devem ser mostrados, bem como o número de dias que		  #
#  passaram desde a data dos registos de posse. A ordenação do resultado deve	  #
#  ser ascendente pelo username dos utilizadores e descendente pelo número de	  #
#  dias que passaram desde os registos de posse e pelo EAN-13 dos álbuns.	  #
#################################################################################*/
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
