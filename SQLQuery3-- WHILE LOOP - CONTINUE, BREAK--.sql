-- WHILE LOOP - CONTINUE, BREAK--
-- continue ~ thường để test

--EXAMPLE 1: Tạo hàm tính giai thừa N
create function GIAI_THUA(@N int)
returns int
as
begin 
	declare @i int = 1
	declare @GiaiThua int =1
	while @i <= @N
	begin
		set @GiaiThua *= @i
		set @i = @i + 1
	end
	return @GiaiThua
end
select DBO.GIAI_THUA(3)