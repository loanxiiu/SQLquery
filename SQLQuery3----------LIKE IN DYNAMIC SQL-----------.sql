----------LIKE IN DYNAMIC SQL-----------
drop proc search
create proc search @ten nvarchar(100), @tg nvarchar(30)
as
begin
declare @sql nvarchar(max)
set @sql = ('select * from tSach where 1=1')
if @ten is not null or @ten <> ''
    set @sql = @sql + ' and TenSach like N'''+ '%' +@ten+ '%' +''''
if @tg is not null or @tg <> ''
    set @sql = @sql + ' and TacGia like N'''+ '%' +@tg+ '%' +''''

	print(@sql)
  exec sp_Executesql @sql
  end
  go
  exec search @ten = N'con', @tg = ''

