--EXAMPLE 1: Tạo function/ procedure để hiển thị danh sách các SoHDB có SLBan > @value
-- Trong trường hợp @value < 10 thì giá trị trả ra là 'Biến @value không được nhỏ hơn 10'

--C1: procedure
drop procedure DANH_SACH
create proc DANH_SACH @value int
as
begin
	if @value >= 10
		select SoHDB
		from tChiTietHDB
		group by SoHDB
		having sum(SLBan) > @value
	else 
		print N'Biến @value không được nhỏ hơn 10'
end

exec DANH_SACH 20


--C2: table_valued function
--declare (name) table or returns table
drop function GET_SOHD2
create function GET_SOHD2 (@value int)
returns @BIENBANG table
(
	SOHDB nvarchar(max)
)
as
begin
	if @value >= 10
		begin
			insert into @BIENBANG
			select SoHDB
			from tChiTietHDB
			group by SoHDB
			having sum(SLBan) > @value
		end
	else
		begin
			insert into @BIENBANG
			values (N'Biến @value không được nhỏ hơn 10')
		end
	return
end
select * from GET_SOHD2(20)
