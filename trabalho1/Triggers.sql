use ISEL
--trigger q coloca a palavra em md5
if OBJECT_ID('dbo.codificarPass') is not null
	drop trigger dbo.codificarPass
	go

create trigger codificarPass on dbo.Utilizador
after insert
as
	if (exists (select * from inserted))
	begin
		declare @pp varchar(50)
		select @pp=(select palavraPasse from inserted)
		if (@pp<>null)
			update Utilizador set palavraPasse=(SELECT HashBytes('MD5',@pp))
	end


	