-------- DYNAMIC SQL, -------------

-- 1. Sử dụng exec()
-- VD 1: SQL động
declare @sql nvarchar(max)
set @sql = 'select * from CTHOADON'
exec(@sql)

-- VD 2: Thêm giá trị vào chuỗi sql động
declare @SoHD nvarchar(max)
set @SoHD = '''S032'''
declare @sql nvarchar(max)
set @sql = 'select * from CTHOADON where SoHD = '+ @SoHD +''
print (@sql)
exec(@sql)

declare @SoHD nvarchar(max)
set @SoHD = 'S032'
declare @sql nvarchar(max)
set @sql = 'select * from CTHOADON where SoHD = ' +''''+ @SoHD +''''
print (@sql)
exec(@sql)

-- VD 3: Sử dụng sql động trong procedure
-- VD: Tạo proc với biến @var, 
-- Trong TH @var = 1 thì trả ra toàn bộ thông tin cho bảng CTHOADON
-- Trong TH @var = 2 thì trả ra toàn bộ thông tin bảng hoa_don

-- C1:
drop proc cthd
create proc cthd @var int
as
begin
	declare @sql nvarchar(max)
	set @sql = ' if '+ convert(nvarchar(max), @var) +' = 1
					select * from CTHOADON
				 if '+ convert(nvarchar(max), @var) +' = 2
					select * from hoa_don'
	print(@sql)
	exec Sp_Executesql @sql 
end
exec cthd @var= 1

C2:
create proc cthd @var int
as
begin
	declare @sql nvarchar(max)
	if @var = 1
		begin 
			set @sql = 'select * from CTHOADON'
		end
	if @var = 2
		begin
			set @sql = 'select * from hoa_don'
		end
	print(@sql)
	exec(@sql)
end
exec cthd @var =2
		


-- 2. SỬ DỤNG SP_EXECUTESQL()
-- Ví dụ 1: Cấu trúc
-- SP_EXECUTESQL([@chuỗi sql động], @[khai báo danh sách biến trong chuỗi sql động], @[từng biến trong ds biến được khai báo])
declare @sql nvarchar(max)
set @sql = 'select * from CTHOADON where SoHD > @SOHD and SoLuong > @SL'
declare @params nvarchar(max)
set @params = '@SOHD nvarchar(max), @SL int'
exec sp_Executesql @sql, @params, @SOHD ='S032', @SL = 10


-- VD: Tạo procedure chứa logic trên, nội dung không sử dụng sp_Exceutesql, sử dụng exec([dynamic sql])
drop proc get_info
create proc get_info @SOHD nvarchar(max), @SL nvarchar(max)
as
begin
	declare @sql nvarchar(max)
	set @sql = 'select * from CTHOADON where SoHD > '''+ @SOHD +''' and SoLuong > '''+ @SL +''''
	print (@sql)
	
end
exec get_info @SOHD = 'S022', @SL = 10

select * from CTHOADON


-- EXAMPLE 1: Viết vòng loop để kiểm tra số dòng của các bảng trong db TEST
-- select * from sys.table -- danh sách bảng trong sql server
-- select * from sys.columns -- danh sách cột trong sql server
-- In ra màn hình thống kê số lượng dòng cho từng bảng N'[Tên bảng] có [xxx] dòng

select name from sys.tables
where name in ('CTHOADON', 'hoa_don', 'khach_hang')
--

declare CUR cursor for
	select name from sys.tables
open CUR

declare @table nvarchar(max)
fetch next from CUR into @table

while @@FETCH_STATUS = 0
	begin
		declare @sql nvarchar(max)
		set @sql = '
			declare @so_dong nvarchar(max)
			set @so_dong =  (select count (*) from '+ @table +')
			print N'''+ @table +' có ''+ @so_dong +'' dòng''
			'
		fetch next from CUR into @table 
		PRINT(@sql)
		exec(@sql)
	end
close CUR
deallocate CUR


-- EXAMPLE 2: Sử dụng vòng lặp hiển thị số lượng giá trị null trong từng cột bảng CTHOADON
select * from sys.tables
select * from sys columns
-- In ra màn hình thống kê số lượng giá trị null cho từng cột  N'[Tên cột] có [xxx] giá trị null'
select name from sys.columns
where object_id = (select object_id from sys.tables where name = 'CTHOADON')
-------
declare CUR cursor for
	select name from sys.columns
	where object_id = (select object_id from sys.tables where name = 'CTHOADON')
open CUR

declare @column nvarchar(max)
fetch next from CUR into @column

while @@FETCH_STATUS = 0 
	begin
		declare @sql nvarchar(max)
		set @sql = '
			declare @so_null nvarchar(max)
			set @so_null = (select count(*) from CTHOADON where '+ @column +' is null )
			print N'''+ @column +' có ''+ @so_null +'' dòng''
			'
			exec(@sql)
			fetch next from CUR into @column
	end
close CUR
deallocate CUR




 -- 3. BÀI TẬP: Sử dụng truy vấn động thêm dòng từ bảng CTHOADON vào bảng trống CTHOADON_2





 