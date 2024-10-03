-----IF----ELSE lồng nhau ----
--1. check xem giá trị nhập vào (@VAR float) là số nguyên hay số thập phân
-----tạo procedure print ra
--C1:
create proc IntOrFloat(@var float)
as
begin
	if @var <> floor(@var)
		print N'Số thập phân'
	else
		print N'Số nguyên'
end
exec IntOrFloat 4
--C2:
create proc IntOrFloat(@var float)
as
begin
	if round(@var,0) = @var
		print N'Số nguyên'
	else
		print N'Số thập phân'
end
exec IntOrFloat 4
--C3:
create proc IntOrFloat(@var float)
as
begin
	declare @var2 int
	set @var2 = @var
	if @var2 = @var
		print N'Số nguyên'
	else
		print N'Số thập phân'
end
exec IntOrFloat 4


--C4: scalar function
create function check_giatri(@var float)
returns nvarchar(max)
as
begin
	declare @var2 int
	set @var2 = @var

	declare @kq nvarchar(max)
	if @var2 = @var
		set @kq = N'Số nguyên'
	else
		set @kq = N'Số thập phân'
	return @kq
end
select DBO.check_giatri(4.5)
