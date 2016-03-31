use ISEL
go
--(c) Inserir, remover e actualizar informação de um utilizador;
if OBJECT_ID('dbo.inserirUtilizadorHistorico') is not null
	drop trigger dbo.inserirUtilizadorHistorico
if OBJECT_ID('dbo.apagarUtilizadorHistorico') is not null
	drop trigger dbo.apagarUtilizadorHistorico
if OBJECT_ID('dbo.inserirUtilizador') is not null
	drop proc dbo.inserirUtilizador
if OBJECT_ID('dbo.atualizarUtilizador') is not null
	drop proc dbo.atualizarUtilizador
if OBJECT_ID('dbo.apagarUtilizador') is not null
	drop proc dbo.apagarUtilizador
go

create trigger inserirUtilizadorHistorico on dbo.Utilizador
after update
as
--
	if (exists (select * from deleted))
	begin
		declare @a varchar(100)
		select @a=(select morada from inserted where morada is not null)
		if (@a<>null)
			insert into dbo.HistoricoUtilizador(dataTempo,email,morada) values ('2016-06-06 02:02:02',(select inserted.email from inserted),(select inserted.morada from inserted));
	end
	
go

create trigger apagarUtilizadorHistorico on dbo.Utilizador
instead of delete
as
--ver o caso de licit etc
	delete from dbo.HistoricoUtilizador where email=(select deleted.email from deleted)
	delete from dbo.Utilizador where email=(select deleted.email from deleted)
go

create proc dbo.inserirUtilizador @email varchar(100), @pp varchar(50), @nome varchar(50), @morada varchar(100)
as
	insert into dbo.Utilizador(email,palavraPasse,nome,morada) values (@email,@pp,@nome,@morada);
go
 
create proc dbo.atualizarUtilizador @email varchar(100), @pp varchar(50)=null, @nome varchar(50)=null, @morada varchar(100)=null
as
	if(DATALENGTH(@pp)>0)
		update dbo.Utilizador set palavraPasse=@pp where email=@email;
	if(DATALENGTH(@nome)>0)
		update dbo.Utilizador set nome=@nome where email=@email;
	if(DATALENGTH(@morada)>0)
		update dbo.Utilizador set morada=@morada where email=@email;
go

create proc dbo.apagarUtilizador @email varchar(100)
as
	delete from dbo.Utilizador where email=@email
go

--test
exec dbo.inserirUtilizador @email='sss_sara11@hotmail.com', @pp='xxx', @nome='Sara', @morada='Casal de Cambra'
exec dbo.inserirUtilizador @email='a40602@alunos.isel.pt', @pp='zzz', @nome=null, @morada='Casal de Cambra'
--atualizar nome 
exec dbo.atualizarUtilizador @email='a40602@alunos.isel.pt', @nome='Sara Sobral'
--atualizar palavra-passe
exec dbo.atualizarUtilizador @email='a40602@alunos.isel.pt', @pp='yyy', @nome=null, @morada=null
--atualizar morada
exec dbo.atualizarUtilizador @email='sss_sara11@hotmail.com', @pp=null, @nome='Sobral', @morada='Sintra'
select*from HistoricoUtilizador

exec dbo.apagarUtilizador @email='sss_sara11@hotmail.com'
exec dbo.apagarUtilizador @email='a40602@alunos.isel.pt'
