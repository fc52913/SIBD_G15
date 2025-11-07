-- Ex. Students(sid: integer, name: string, login: string, age: integer, gpa: real) 

-- CREATE TABLE students ( sid INTEGER,
--  name CHAR(30),
--  login CHAR(20),
--  age INTEGER,
--  gpa REAL )


--Album( mbid: CHAR(36), titulo: string, tipo: string, ano_de_lancamento: CHAR(4))

CREATE TABLE artista (
	isni NUMBER(16) PRIMARY KEY,
	nome CHAR(100) UNIQUE NOT NULL,
	ano_inicio_atividade NUMBER(4),
	CHECK (ano_inicio_atividade BETWEEN 1800 AND YEAR(GETDATE()))
)


CREATE TABLE album (
	mbid NUMBER(36) PRIMARY KEY,
 	titulo char(100) UNIQUE NOT NULL,
 	tipo CHAR(30),
 	ano_de_lancamento NUMBER(4), 
 	CHECK (ano_de_lancamento BETWEEN 1800 AND YEAR(GETDATE())	
 )


CREATE TABLE utilizador (
    username CHAR(100) PRIMARY KEY,
    email CHAR(100) UNIQUE NOT NULL,
    palavra_passe CHAR(100) NOT NULL,
    data_nascimento DATE NOT NULL
    
)       

CREATE TABLE versao (
    ean13 NUMBER(13) PRIMARY KEY,
    designacao CHAR(30) NOT NULL,
    CHECK (ean13 >= 0)
)

 CREATE TABLE artista (
    isni NUMBER(16) PRIMARY KEY,
    nome CHAR(80) NOT NULL,
    ano_inicio_atividade DATE
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
    FOREIGN KEY (mbid) REFERENCES Album(mbid),
    FOREIGN KEY (tipo) REFERENCES suporte_fisico(tipo)
)

CREATE TABLE possui (
    username CHAR(100),
    ean13 NUMBER(13),
    data_adicao DATE,
    PRIMARY KEY (username, ean13),
    FOREIGN KEY (username) REFERENCES utilizador,
    FOREIGN KEY (ean13) REFERENCES versao
)

CREATE TABLE de (
    ean13 NUMBER(13),
    mbid NUMBER(36),
    tipo VARCHAR(7),
    PRIMARY KEY (ean13, mbid, tipo),
    FOREIGN kEY (ean13) REFERENCES versao,
    FOREIGN KEY (mbid, tipo) REFERENCES em
)

CREATE TABLE membro (
    isni NUMBER(16),
    PRIMARY KEY isni,
    FOREIGN KEY (isni) REFERENCES artista --ON DELETE CASCADE
)

CREATE TABLE solista(
    isni NUMBER(16),
    PRIMARY KEY (insi) REFERENCES artista,
    FOREIGN KEY (insi) REFERENCES artista ON DELETE CASCADE,
)

CREATE TABLE grupo (
    isni NUMBER(16),
    PRIMARY KEY (insi) REFERENCES artista
    FOREIGN KEY (insi) REFERENCES artista ON DELETE CASCADE,
)

CREATE TABLE lista_personalizada (
    nome VARCHAR(80) NOT NULL,
    PRIMARY KEY nome
)


CREATE TABLE cria (
    nome VARCHAR(80),
    username VARCHAR(100),
    PRIMARY KEY (nome, username),
    FOREIGN KEY nome REFERENCES lista_personalizada,
)