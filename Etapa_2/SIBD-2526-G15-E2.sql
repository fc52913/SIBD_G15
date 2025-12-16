-- SIBD2526 E2 G15
-- António , 52913, TP11
-- Diogo , 61887 , TP13
-- Duarte Rodrigues, 63746, TP13
-- Jaime , 63732 , TP13

---------------------------------------------------------------
-- TABELAS
---------------------------------------------------------------

CREATE TABLE artista (
	isni NUMBER(16) PRIMARY KEY,
	nome CHAR(100) UNIQUE NOT NULL,
	ano_inicio_atividade NUMBER(4),
	CHECK (ano_inicio_atividade BETWEEN 1800 AND YEAR(GETDATE()))
	-- CHECK (ano_inicio_atividade <= ano_de_lancamento)
) 

CREATE TABLE album (
	mbid NUMBER(36) PRIMARY KEY,
 	titulo CHAR(100) UNIQUE NOT NULL,
 	tipo CHAR(30),
 	ano_de_lancamento NUMBER(4),
 	CHECK (tipo IN ('Single', 'EP', 'LP')),
 	CHECK (ano_de_lancamento BETWEEN 1800 AND YEAR(GETDATE()))
) 

CREATE TABLE utilizador (
    username CHAR(100) PRIMARY KEY, -- apenas letras e dígitos
    email CHAR(100) UNIQUE NOT NULL,
    palavra_passe CHAR(100) NOT NULL,
    data_nascimento DATE NOT NULL
) 

CREATE TABLE versao (
    ean13 NUMBER(13) PRIMARY KEY,
    designacao CHAR(30) NOT NULL,
    CHECK (ean13 >= 0)
) 

CREATE TABLE favorito (
    username CHAR(100),
    isni NUMBER(16),
    PRIMARY KEY (username),
    FOREIGN KEY (username) REFERENCES utilizador,
    FOREIGN KEY (isni) REFERENCES artista
) 

CREATE TABLE suporte_fisico( 
	tipo VARCHAR(7) PRIMARY KEY,
	CHECK (tipo IN ('CD', 'Vinil', 'Cassete'))
) 

CREATE TABLE em (
    mbid CHAR(36) NOT NULL,
    tipo VARCHAR(7) NOT NULL,
    PRIMARY KEY (mbid, tipo),
    FOREIGN KEY (mbid) REFERENCES album(mbid),
    FOREIGN KEY (tipo) REFERENCES suporte_fisico(tipo)
) 

CREATE TABLE possui (
    username CHAR(100),
    ean13 NUMBER(13),
    data_adicao DATE,
    PRIMARY KEY (username, ean13),
    FOREIGN KEY (username) REFERENCES utilizador,
    FOREIGN KEY (ean13) REFERENCES versao
	-- CHECK (data_adicao >= ano_de_lancamento)
) 

CREATE TABLE de (
    ean13 NUMBER(13),
    mbid NUMBER(36),
    tipo VARCHAR(7),
    PRIMARY KEY (ean13, mbid, tipo),
    FOREIGN KEY (ean13) REFERENCES versao,
    FOREIGN KEY (mbid, tipo) REFERENCES em
) 

CREATE TABLE membro (
    isni NUMBER(16),
    PRIMARY KEY (isni),
    FOREIGN KEY (isni) REFERENCES artista -- ON DELETE CASCADE
) 

CREATE TABLE solista(
    isni NUMBER(16),
    PRIMARY KEY (isni),
    FOREIGN KEY (isni) REFERENCES artista ON DELETE CASCADE
) 

CREATE TABLE grupo (
    isni NUMBER(16),
    PRIMARY KEY (isni),
    FOREIGN KEY (isni) REFERENCES artista ON DELETE CASCADE
) 

CREATE TABLE lista_personalizada (
    nome VARCHAR(80) NOT NULL,
    PRIMARY KEY (nome)
) 

CREATE TABLE refere(
	mbid NUMBER(35),
	nome VARCHAR(80),
	PRIMARY KEY (mbid, nome),
	FOREIGN KEY (mbid) REFERENCES album,
	FOREIGN KEY (nome) REFERENCES lista_personalizada
) 

CREATE TABLE cria (
    nome VARCHAR(80),
    username VARCHAR(100),
    PRIMARY KEY (nome, username),
    FOREIGN KEY (nome) REFERENCES lista_personalizada
) 

CREATE TABLE interpretado(
	isni NUMBER(16),
	mbid NUMBER(35),
	PRIMARY KEY (isni, mbid),
	FOREIGN KEY (isni) REFERENCES artista,
	FOREIGN KEY (mbid) REFERENCES album
) 

---------------------------------------------------------------
-- INSERÇÕES
---------------------------------------------------------------

INSERT INTO artista (isni, nome, ano_inicio_atividade)
    VALUES 
        (1245124512451245, 'VornatosIoleta', 1999),
        (1245124512451246, 'KSI', 2025),
        (1245124512451247, 'CAPA', 2025),
        (1245124512458952, 'RapaCoach', 2000) 

INSERT INTO album (mbid, titulo, tipo, ano_de_lancamento)
    VALUES 
        (111111111111111111111111111111111111, 'O monstro precisa de férias', 'Single', 2025),
        (111111111111111111111111111111111123, 'Numbers', 'EP', 2021) 

INSERT INTO utilizador (username, email, palavra_passe, data_nascimento)
    VALUES
        ('joao', 'joao@mail.com', 'passeinsegura', '1990-05-10'),
        ('maria', 'maria@mail.com', 'passemenosinsegura', '1995-11-22') 

INSERT INTO versao (ean13, designacao)
    VALUES
        (1234567890123, 'levedoispagueum'),
        (9876543210987, 'levetrêspagueum') 

INSERT INTO favorito (username, isni)
    VALUES
        ('joao', 1245124512451245),
        ('maria', 1245124512458952) 

INSERT INTO suporte_fisico (tipo)
    VALUES
        ('CD'),
        ('Vinil'),
        ('Cassete') 

INSERT INTO em (mbid, tipo)
    VALUES
        (111111111111111111111111111111111111, 'CD'),
        (111111111111111111111111111111111123, 'Vinil') 

INSERT INTO possui (username, ean13, data_adicao)
    VALUES
        ('joao', 1234567890123, '2024-01-10'),
        ('maria', 9876543210987, '2024-03-15') 

INSERT INTO de (ean13, mbid, tipo)
    VALUES
        (1234567890123, 111111111111111111111111111111111111, 'CD'),
        (9876543210987, 111111111111111111111111111111111123, 'Vinil') 

INSERT INTO membro (isni)
    VALUES
        (1245124512451246),
        (1245124512451247) 

INSERT INTO solista (isni)
    VALUES
        (1245124512451246),
        (1245124512451247) 

INSERT INTO grupo (isni)
    VALUES
        (1245124512451245),
        (1245124512458952) 

INSERT INTO lista_personalizada (nome)
    VALUES
        ('Gym'),
        ('Shower') 

INSERT INTO refere (mbid, nome)
    VALUES
        (111111111111111111111111111111111111, 'Gym'),
        (111111111111111111111111111111111123, 'Shower') 

INSERT INTO cria (nome, username)
    VALUES
        ('Gym', 'joao'),
        ('Shower', 'maria') 

INSERT INTO interpretado (isni, mbid)
    VALUES
        (1245124512451245, 111111111111111111111111111111111111),
        (1245124512458952, 111111111111111111111111111111111123) 
