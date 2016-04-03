use master
/*if exists (select name from master.dbo.sysdatabases where name = N'ISEL')
begin
	print('Removing database named ISEL...'); 
    alter database [ISEL] set single_user with rollback immediate
    drop database [ISEL];
end

go
print('Creating database named ISEL...'); 
create database [ISEL];
*/

go
use ISEL
begin tran

if OBJECT_ID('dbo.Compra') is not null
	drop table dbo.Compra
if OBJECT_ID('dbo.Licitacao') is not null
	drop table dbo.Licitacao
if OBJECT_ID('dbo.Venda') is not null
	drop table dbo.Venda
if OBJECT_ID('dbo.VendaDirecta') is not null
	drop table dbo.VendaDirecta
if OBJECT_ID('dbo.Leilao') is not null
	drop table dbo.Leilao
if OBJECT_ID('dbo.Artigo') is not null
	drop table dbo.Artigo
if OBJECT_ID('dbo.HistoricoUtilizador') is not null
	drop table dbo.HistoricoUtilizador
if OBJECT_ID('dbo.Utilizador') is not null
	drop table dbo.Utilizador
if OBJECT_ID('dbo.Porte') is not null
	drop table dbo.Porte
go
create table dbo.Porte(
	preco money, 
	moradaOrigem varchar(2), 
	moradaDestino varchar(2),
	primary key(preco, moradaOrigem, moradaDestino),
	check (preco>0)
)

create table dbo.Utilizador(
	email varchar(100) primary key,
	palavraPasse varchar(50) not null,
	nome varchar(50),
	morada varchar(100) not null,
	unCheck int default 1, 
	check(DATALENGTH(palavraPasse)>6 and (unCheck=0 or unCheck=1)) 
)
go

create table dbo.HistoricoUtilizador(
	dataTempo dateTime not null, 
	morada varchar(100) not null, 
	email varchar(100),
	primary key(email, dataTempo),
	foreign key(email) references Utilizador(email),
)
go
create table dbo.Artigo(
	id int identity(1,1) primary key,
	dataTempo dateTime not null,
	unCheck int default 1, 
	check(unCheck=0 or unCheck=1)
)
go
create table dbo.Leilao(
	artigoId int primary key , 
	licitacaoMin money not null, 
	valorMin money not null,
	foreign key(artigoId) references Artigo(id),
	check ((licitacaoMin>1 or licitacaoMin>0.10*valorMin) and valorMin>0)
)

create table dbo.VendaDirecta(
	artigoId int primary key, 
	precoVenda money not null,
	foreign key(artigoId) references Artigo(id),
	check (precoVenda>0)
)

create table dbo.Venda(
	descricao varchar(100), 
	dataInicio dateTime not null, 
	dataFim dateTime not null, 
	localOrigem varchar(2) not null, 
	condicao varchar(16), 
	email varchar(100), 
	artigoId int,
	unCheck int default 1, 	
	primary key(email, artigoId),
	constraint fk1_idArtigo foreign key(artigoId) references Artigo,
	constraint fk1_emailUtilizador foreign key(email) references Utilizador,
	check (condicao='Novo' or condicao='Usado' or condicao='Como novo' or condicao='Velharia vintage'),
	check (dataFim>dataInicio),
	check(unCheck=0 or unCheck=1)
)

create table dbo.Licitacao(
	dataHora dateTime not null, 
	unCheck int default 1, 
	preco money, 
	email varchar(100), 
	artigoId int,
	primary key(email, artigoId,dataHora),
	constraint fk2_idArtigo foreign key(artigoId) references Artigo,
	constraint fk2_emailUtilizador foreign key(email) references Utilizador,
	check (preco>0 and (unCheck=0 or unCheck=1))
)

create table dbo.Compra(
	codigo int identity(1,1) primary key, --implica ter o email e o id com pk?????????
	dataCompra dateTime not null,
	localDestino varchar(2) not null, 
	cartaoCredito int not null,
	email varchar(100), 
	artigoId int,
	unCheck int default 1, 
	constraint fk3_idArtigo foreign key(artigoId) references Artigo,
	constraint fk3_emailUtilizador foreign key(email) references Utilizador,
	check (unCheck=0 or unCheck=1)
)
go
commit

print('Finished creating database ISEL.'); 
/*
Regras de neg�cio:
-Por quest�es de seguran�a, a palavra passe n�o ser� guardada em claro, ficando apenas registado o resultado da fun��o de hash MD5.
- Em leilao, Se o valor m�nimo n�o for atingido o artigo n�o ser� vendido.	
licita�aoDoUser < valorMinino nao h� compra
-Todos os artigos podem ser licitados
-Se for uma venda directa, a licita��o s� � v�lida se o valor for igual ao valor de venda.
valorDoUser = ValorDeVenda
-Se for um leil�o, a licita��o tem de ser superior � �ltima licita��o, acrescida da licita��o m�nima.
-N�o s�o permitidas inser��es de novas licita��es sempre que o tempo definido para a venda tenha terminado.
-Depois das licita��es terem terminado, o vencedor (quem fez a licita��o mais alta) tem at� 2 dias para formalizar a compra.
-o pre�o dos portes a pagar entre localiza��es, sendo estas definidas de acordo com o ISO 3166-1.
PT-Portugal BR-Brasil CN-China DE-Alemanha DK-Dinamarca FR-Fran�a TR-Turquia
-O pre�o dos portes ser� acrescido ao valor de compra.
-Em qualquer momento deve ser poss�vel simular o custo total de compra, usando um valor de licita��o v�lido e uma localiza��o de entrega
-� ainda poss�vel um utilizador retirar uma licita��o que efectuou, desde que dentro do per�odo de venda. No entanto, essa informa��o n�o pode ser removida do sistema.


RI1 - condicao da venda pode ter os valores (i) �Novo�, (ii) �Usado�, (iii) �Como novo� e (iv) �Velharia vintage�.
RI2 - o valor da licita��o m�nima, sempre entre 1 euro e 10% do valor de venda
RI3 - Para garantir um correcto ordenamento das licita��es, todas as datas t�m de ser inseridas na base de dados com precis�o de milissegundos.
RI4 - uma data de compra (diferente da data de licita��o se for um leil�o), 
RI5 - O sistema n�o deve permitir altera��es do email dos utilizadores.
*/