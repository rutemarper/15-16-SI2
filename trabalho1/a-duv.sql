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
use [ISEL]
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
	--faço um trigger q de seguida coloca isto em md5??????????????????????????????? sim
	nome varchar(50),
	morada varchar(100) not null
)
go

create table dbo.HistoricoUtilizador(
	dataTempo dateTime, 
	morada varchar(100), 
	email varchar(100),
	primary key(email, dataTempo),
	foreign key(email) references Utilizador
)
go
create table dbo.Artigo(
	id int identity(1,1) primary key,
	dataTempo dateTime unique
)
go
create table dbo.Leilao(
	artigoId int primary key, 
	licitacaoMin money not null, 
	valorMin money not null,
	foreign key(artigoId) references Artigo(id),
	check (licitacaoMin between 1 and 0.10*valorMin and valorMin>0)
)

create table dbo.VendaDirecta(
	artigoId int primary key, 
	precoVenda money not null,
	foreign key(artigoId) references Artigo(id),
	check (precoVenda>0)
)

create table dbo.Venda(
	descricao varchar(100), 
	dataInicio dateTime, 
	dataFim dateTime, 
	localOrigem varchar(2), 
	condicao varchar(16), 
	email varchar(100), 
	artigoId int,
	primary key(email, artigoId),
	constraint fk1_idArtigo foreign key(artigoId) references Artigo,
	constraint fk1_emailUtilizador foreign key(email) references Utilizador,
	check (condicao='Novo' or condicao='Usado' or condicao='Como novo' or condicao='Velharia vintage'),
	check (dataFim>dataInicio)
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
	dataCompra dateTime, 
	codigo int identity(1,1) primary key, --implica ter o email e o id com pk?????????
	localDestino varchar(2), 
	cartaoCredito int,
	email varchar(100), 
	artigoId int,
	constraint fk3_idArtigo foreign key(artigoId) references Artigo,
	constraint fk3_emailUtilizador foreign key(email) references Utilizador
)
go
commit

print('Finished creating database ISEL.'); 
/*
Regras de negócio:
-Por questões de segurança, a palavra passe não será guardada em claro, ficando apenas registado o resultado da função de hash MD5.
- Em leilao, Se o valor mínimo não for atingido o artigo não será vendido.	
licitaçaoDoUser < valorMinino nao há compra
-Todos os artigos podem ser licitados
-Se for uma venda directa, a licitação só é válida se o valor for igual ao valor de venda.
valorDoUser = ValorDeVenda
-Se for um leilão, a licitação tem de ser superior à última licitação, acrescida da licitação mínima.
-Não são permitidas inserções de novas licitações sempre que o tempo definido para a venda tenha terminado.
-Depois das licitações terem terminado, o vencedor (quem fez a licitação mais alta) tem até 2 dias para formalizar a compra.
-o preço dos portes a pagar entre localizações, sendo estas definidas de acordo com o ISO 3166-1.
PT-Portugal BR-Brasil CN-China DE-Alemanha DK-Dinamarca FR-França TR-Turquia
-O preço dos portes será acrescido ao valor de compra.
-Em qualquer momento deve ser possível simular o custo total de compra, usando um valor de licitação válido e uma localização de entrega
-É ainda possível um utilizador retirar uma licitação que efectuou, desde que dentro do período de venda. No entanto, essa informação não pode ser removida do sistema.


RI1 - condicao da venda pode ter os valores (i) “Novo”, (ii) “Usado”, (iii) “Como novo” e (iv) “Velharia vintage”.
RI2 - o valor da licitação mínima, sempre entre 1 euro e 10% do valor de venda
RI3 - Para garantir um correcto ordenamento das licitações, todas as datas têm de ser inseridas na base de dados com precisão de milissegundos.
RI4 - uma data de compra (diferente da data de licitação se for um leilão), 
RI5 - O sistema não deve permitir alterações do email dos utilizadores.
*/