use ISEL
--(m) Verificar a password de um utilizador; 
if OBJECT_ID('dbo.verificarPp') is not null
	drop proc dbo.verificarPp
go
create proc dbo.verificarPp @email varchar(100), @ppVer varchar(50)
as
	declare @ppAtual varchar(50)
	select @ppAtual = (select palavraPasse from Utilizador where email=@email)
	declare @p1 int, @p2 int
	select @p1 = (SELECT HashBytes('MD5', @ppAtual))
	select @p2 = (SELECT HashBytes('MD5', @ppVer))
	if (@p1=@p2)
		print('A password a verificar está correta')
	else
		print('A password a verificar está incorreta')
		
go


insert into dbo.Utilizador(email,palavraPasse,nome,morada) values('sss_sara11@hotmail.com','xxx','Sara','Casal de Cambra')
exec dbo.verificarPp 'sss_sara11@hotmail.com','xxx'
exec dbo.verificarPp 'sss_sara11@hotmail.com','123'
