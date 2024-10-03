--Xây dựng proc, với đầu vào là tháng và năm, và biến sắp xếp
--Nếu biến này bằng 1 thì sắp xếp tăng dần, nếu là 0 thì sx giảm dần
create proc Cau6 @month int, @year int, @sx bit
as
begin
     declare @sql nvarchar(max)
     set @sql = 'select HDB.SoHDB, sum(SLBan*DonGiaBan) as tong
                 from tHoaDonBan as HDB join tChiTietHDB s on HDB.SoHDB = s.SoHDB
                                        join tSach n on n.MaSach = s.MaSach
                 where MONTH(HDB.NgayBan) = '+ str(@month) +' 
				   and YEAR(HDB.NgayBan) = '+ str(@year) +'
                 group by HDB.SoHDB'
     if @sx = 1
           set @sql = @sql + ' order by tong DESC'
     if @sx = 0
           set @sql = @sql + ' order by tong ASC' 

     exec sp_Executesql @sql
end
go
exec Cau6 @month = 4, @year = 2013, @sx = 1