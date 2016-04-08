use ISEL
go
--trigger que coloca a palavra passe em md5
if OBJECT_ID('dbo.utilizadorIU') is not null
	drop trigger dbo.utilizadorIU
if OBJECT_ID('dbo.deleteUtilizador') is not null
	drop trigger deleteUtilizador
--(c) Inserir, remover e actualizar informação de um utilizador;
if OBJECT_ID('dbo.inserirUtilizador') is not null
	drop proc dbo.inserirUtilizador
if OBJECT_ID('dbo.atualizarUtilizador') is not null
	drop proc dbo.atualizarUtilizador
if OBJECT_ID('dbo.apagarUtilizador') is not null
	drop proc dbo.apagarUtilizador
go

create trigger dbo.utilizadorIU on dbo.Utilizador
after insert, update
as
	declare @pp varchar(50), @pp1 varchar(50), @morada1 varchar(100), @morada2 varchar(100)
	if(not exists (select * from deleted))
	begin
		select @pp=(select palavraPasse from inserted)
		if (DATALENGTH(@pp)>6)
			update Utilizador set palavraPasse=(SELECT HashBytes('MD5',@pp)) where email=(select email from inserted)
	end
	else
	begin
		select @morada1=(select TOP 1 MORADA from inserted) 
		select @morada2=(select TOP 1 MORADA from deleted)
		select @pp=(select TOP 1 palavraPasse from deleted)
		if (@morada1<>@morada2)
			insert into dbo.HistoricoUtilizador(morada,dataTempo,email) values ((select morada from inserted),GETDATE(),(select email from inserted))
	end
go

create trigger dbo.deleteUtilizador on dbo.Utilizador
INSTEAD OF DELETE
as
	declare @email varchar(100)
	select @email = (select email from deleted)
	UPDATE dbo.Utilizador set unCheck=0 where email=@email
	UPDATE dbo.Compra set unCheck=0 where email=@email
	UPDATE dbo.Licitacao set unCheck=0 where email=@email
	UPDATE dbo.Venda set unCheck=0 where email=@email
go
create proc dbo.inserirUtilizador @email varchar(100), @pp varchar(50), @nome varchar(50), @morada varchar(100)
as
	insert into dbo.Utilizador(email,palavraPasse,nome,morada) values (@email,@pp,@nome,@morada);
go
 
create proc dbo.atualizarUtilizador @email varchar(100), @pp varchar(50)=null, @nome varchar(50)=null, @morada varchar(100)=null
as
	if(DATALENGTH(@pp)>6)
		update Utilizador set palavraPasse=(SELECT HashBytes('MD5',@pp)) where email=@email;
	if(DATALENGTH(@nome)>0)
		update dbo.Utilizador set nome=@nome where email=@email;
	if(DATALENGTH(@morada)>0)
		update dbo.Utilizador set morada=@morada where email=@email;
go

create proc dbo.apagarUtilizador @email varchar(100)
as
	delete dbo.Utilizador where email=@email
go

--test
exec dbo.inserirUtilizador @email='sss_sara11@hotmail.com', @pp='xxxxxxxxx', @nome='Sara', @morada='Casal de Cambra'
select*from Utilizador
exec dbo.inserirUtilizador @email='a40602@alunos.isel.pt', @pp='zzzzzzzzz', @nome=null, @morada='Casal de Cambra'
select*from Utilizador
--atualizar nome 
exec dbo.atualizarUtilizador @email='a40602@alunos.isel.pt', @nome='Sara Sobral'
select*from Utilizador
--atualizar morada
exec dbo.atualizarUtilizador @email='sss_sara11@hotmail.com', @pp=null, @nome='Sobral', @morada='Londres'
select*from Utilizador
--atualizar palavra-passe
exec dbo.atualizarUtilizador @email='a40602@alunos.isel.pt', @pp='yyyyyyyyy', @nome=null, @morada=null
select*from Utilizador
select*from HistoricoUtilizador

exec dbo.apagarUtilizador @email='sss_sara11@hotmail.com'
exec dbo.apagarUtilizador @email='a40602@alunos.isel.pt'

select*from Utilizador
select*from HistoricoUtilizador

