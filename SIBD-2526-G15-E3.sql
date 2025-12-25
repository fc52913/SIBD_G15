-- ----------------------------------------------------------------------------
DROP TABLE possui;
DROP TABLE utilizador;
DROP TABLE album;
DROP TABLE artista;
-- ----------------------------------------------------------------------------
CREATE TABLE artista (
    isni CHAR (16),
    nome VARCHAR (80) CONSTRAINT nn_artista_nome NOT NULL,
    inicio NUMBER (4) CONSTRAINT nn_artista_inicio NOT NULL,
    -- Ano de início de atividade.
    --
    CONSTRAINT pk_artista
    PRIMARY KEY (isni),
    --
    CONSTRAINT ck_artista_isni -- RIA 07.
    CHECK (REGEXP_LIKE(isni, '[0-9]{15}[0-9X]', 'i')),
    --
    CONSTRAINT ck_artista_inicio -- Impede erros básicos.
    CHECK (inicio > 0)
);
-- ----------------------------------------------------------------------------
CREATE TABLE album (
    -- Adaptação dos conjuntos de entidades Álbum, Suporte Físico, e Versão, e
    -- dos conjuntos de associações Em e De. O MBID foi omitido por simplicidade.
    ean CHAR (13),
    titulo VARCHAR (80) CONSTRAINT nn_album_titulo NOT NULL,
    tipo VARCHAR (6) CONSTRAINT nn_album_tipo NOT NULL,
    ano NUMBER (4) CONSTRAINT nn_album_ano NOT NULL,
    artista CONSTRAINT nn_album_artista NOT NULL, -- Intérprete.
    suporte VARCHAR (7) CONSTRAINT nn_album_suporte NOT NULL,
    versao VARCHAR (80), -- Pode não estar preenchida.
    --
    CONSTRAINT pk_album
    PRIMARY KEY (ean),
    --
    CONSTRAINT fk_album_artista
    FOREIGN KEY (artista)
    REFERENCES artista (isni),
    --
    CONSTRAINT ck_versao_ean -- RIA 12.
    CHECK (REGEXP_LIKE(ean, '[0-9]{13}', 'i')),
    
    --
    CONSTRAINT ck_album_tipo
    CHECK (tipo IN ('single', 'EP', 'LP')), -- RIA 02.
    --
    CONSTRAINT ck_album_ano -- Impede erros básicos.
    CHECK (ano >= 1900),
    --
    CONSTRAINT ck_album_suporte -- RIA 11.
    CHECK (suporte IN ('CD', 'vinil', 'cassete'))
);
-- ----------------------------------------------------------------------------
CREATE TABLE utilizador (
    username VARCHAR (40),
    email VARCHAR (80) CONSTRAINT nn_utilizador_email NOT NULL, -- RIA 13.
    senha VARCHAR (40) CONSTRAINT nn_utilizador_senha NOT NULL,
    nascimento NUMBER (4) CONSTRAINT nn_utilizador_nascimento NOT NULL,
    -- Só o ano da data de nascimento, por simplicidade.
    artista, -- Favorito.
    --
    CONSTRAINT pk_utilizador
    PRIMARY KEY (username),
    --
    CONSTRAINT fk_utilizador_artista
    FOREIGN KEY (artista)
    REFERENCES artista (isni),
    --
    CONSTRAINT un_utilizador_email -- RIA 13.
    UNIQUE (email),
    --
    CONSTRAINT ck_utilizador_username -- RIA 14.
    CHECK (REGEXP_LIKE(username, '[a-z0-9]+', 'i')),
    --
    CONSTRAINT ck_utilizador_nascimento -- Impede erros básicos.
    CHECK (nascimento >= 1900)
);
-- ----------------------------------------------------------------------------
CREATE TABLE possui (
    utilizador,
    album,
    desde DATE CONSTRAINT nn_possui_desde NOT NULL, -- Data de registo.
    --
    CONSTRAINT pk_possui
    PRIMARY KEY (utilizador, album),
    --
    CONSTRAINT fk_possui_utilizador
    FOREIGN KEY (utilizador)
    REFERENCES utilizador (username),
    --
    CONSTRAINT fk_possui_album
    FOREIGN KEY (album)
    REFERENCES album (ean),
    --
    CONSTRAINT ck_possui_desde -- Impede erros básicos.
    CHECK (desde >= TO_DATE('01.01.1900', 'DD.MM.YYYY'))
);
-- ----------------------------------------------------------------------------


--------------------------------- TMP DATA ----------------------------------
INSERT INTO artista (isni, nome, inicio) VALUES
('0000000000000001', 'Dire Straits', 1977);

INSERT INTO artista (isni, nome, inicio) VALUES
('0000000000000002', 'Pink Floyd', 1965);

INSERT INTO artista (isni, nome, inicio) VALUES
('0000000000000003', 'Metallica', 1981);

INSERT INTO album (ean, titulo, tipo, ano, artista, suporte, versao) VALUES
('1111111111111', 'Brothers in Arms', 'LP', 1985, '0000000000000001', 'CD', NULL);

INSERT INTO album VALUES
('1111111111112', 'Love Over Gold', 'LP', 1982, '0000000000000001', 'vinil', NULL);

INSERT INTO album VALUES
('1111111111113', 'Making Movies', 'LP', 1980, '0000000000000001', 'CD', NULL);

INSERT INTO album VALUES
('1111111111114', 'Dire Straits (Debut)', 'LP', 1978, '0000000000000001', 'CD', NULL);

INSERT INTO album VALUES
('2222222222221', 'The Dark Side of the Moon', 'LP', 1973, '0000000000000002', 'vinil', NULL);

INSERT INTO album VALUES
('2222222222222', 'Wish You Were Here', 'LP', 1975, '0000000000000002', 'CD', NULL);

INSERT INTO album VALUES
('3333333333331', 'Master of Puppets', 'LP', 1986, '0000000000000003', 'CD', NULL);

INSERT INTO utilizador (username, email, senha, nascimento, artista) VALUES
('user1', 'user1@gmail.com', 'pass', 1990, '0000000000000001');

INSERT INTO utilizador VALUES
('user2', 'user2@gmail.com', 'pass', 1985, '0000000000000002');

INSERT INTO utilizador VALUES
('user3', 'user3@yahoo.com', 'pass', 1992, '0000000000000001');

INSERT INTO utilizador VALUES
('user4', 'user4@gmail.com', 'pass', 1975, '0000000000000003');

INSERT INTO utilizador VALUES
('user5', 'user5@gmail.com', 'pass', 1980, '0000000000000001');

-- user1 → 3 Dire Straits (datas válidas → PASSA)
INSERT INTO possui VALUES ('user1', '1111111111111', DATE '2005-05-10');
INSERT INTO possui VALUES ('user1', '1111111111112', DATE '2010-07-15');
INSERT INTO possui VALUES ('user1', '1111111111113', DATE '2015-03-20');

-- user2 → 4 Dire Straits (→ NÃO PASSA)
INSERT INTO possui VALUES ('user2', '1111111111111', DATE '2001-01-01');
INSERT INTO possui VALUES ('user2', '1111111111112', DATE '2002-02-02');
INSERT INTO possui VALUES ('user2', '1111111111113', DATE '2003-03-03');
INSERT INTO possui VALUES ('user2', '1111111111114', DATE '2004-04-04');

-- user3 → email não é Gmail (→ NÃO PASSA)
INSERT INTO possui VALUES ('user3', '1111111111111', DATE '2005-06-06');

-- user4 → 0 Dire Straits + datas válidas (→ PASSA)
INSERT INTO possui VALUES ('user4', '2222222222221', DATE '2010-10-10');

-- user5 → datas fora do intervalo (→ NÃO PASSA)
INSERT INTO possui VALUES ('user5', '1111111111111', DATE '1990-01-01');
INSERT INTO possui VALUES ('user5', '2222222222222', DATE '1995-01-01');


-----------------------------------------------------------------------------

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
      ) <= 3;



