USE [eConfig]
GO
/****** Object:  UserDefinedFunction [iprules].[GetIpsfromsubnet]    Script Date: 02/25/2014 16:39:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [iprules].[GetIpsfromsubnet] ( @ip  nchar(20) )
RETURNS @iptable TABLE
   (
   IP nchar(20)
   )
AS
BEGIN
  DECLARE @valueList varchar(8000)
, @pos INT
, @len INT
, @value varchar(8000)
, @b1 as int
, @b2 as int
, @b3 as int
, @b4 as int
, @subnet as int
, @start1 int, @end int,@start2 int,@start3 int
 

 set @valueList= LEFT(@ip, LEN(@ip) - 3)+'.'
set @pos = 0
set @len = 0
set @b1=0
set @b2=0
set @b3=0
set @b4=0
if  left(right(rtrim(@ip),2),1)='/'
begin
 set @valueList= LEFT(@ip, LEN(@ip) - 2)+'.'
 set @subnet= right(rtrim(@ip),1)
end
else
begin
set @subnet= right(rtrim(@ip),2)
set @valueList= LEFT(@ip, LEN(@ip) - 3)+'.'
end

---get parts if ip broken up
WHILE CHARINDEX('.', @valueList, @pos+1)>0
BEGIN
    set @len = CHARINDEX('.', @valueList, @pos+1) - @pos
    set @value = SUBSTRING(@valueList, @pos, @len)

      if @b1=0
      begin
          set @b1=@value
      end  
    else if @b2=0
      begin
          set @b2=@value
      end  
          else if @b3=0
      begin
          set @b3=@value
      end  
          else if @b4=0
      begin
          set @b4=@value
      end  
  

    set @pos = CHARINDEX('.', @valueList, @pos+@len) +1
END


--If only the first segement of network is used for host
if @subnet>=24
begin

 set @start1=@b4+1
 set @end=(power(2 ,32-@subnet)+@b4)-2
 while @start1<=@end
 begin
 insert into @iptable
 values( rtrim(ltrim(cast(@b1 as nchar)))+'.'+rtrim(ltrim(cast(@b2 as nchar)))+'.'+rtrim(ltrim(cast(@b3 as nchar)))+'.'+rtrim(ltrim(cast(@start1 as nchar)))) 
 set @start1=@start1+1
 end
 end
 
 --If the first and second segement of network is used for host
 else if @subnet<24 and @subnet>15
 begin
 set @subnet =@subnet+8
 set @start2=@b4
 set @end=(power(2 ,32-@subnet)+@b3)-1
 while @start2<=@end
 begin
set @start1=1
while @start1<255
begin
insert into @iptable
 values( rtrim(ltrim(cast(@b1 as nchar)))+'.'+rtrim(ltrim(cast(@b2 as nchar)))+'.'+rtrim(ltrim(cast(@start2 as nchar)))+'.'+rtrim(ltrim(cast(@start1 as nchar)))) 
set @start1=@start1+1
end
 set @start2=@start2+1
 end
 end
--if the first second and third
 else if @subnet<16 and @subnet>7
 begin
 set @subnet =@subnet+16
 set @start3=@b2
 set @end=(power(2 ,32-@subnet)+@b2)-1
 while @start3<=@end
 begin
 set @start2=0
 while @start2<=255
 begin
set @start1=1
while @start1<255
begin
insert into @iptable
 values( rtrim(ltrim(cast(@b1 as nchar)))+'.'+rtrim(ltrim(cast(@start3 as nchar)))+'.'+rtrim(ltrim(cast(@start2 as nchar)))+'.'+rtrim(ltrim(cast(@start1 as nchar)))) 
set @start1=@start1+1
end
set @start2=@start2+1
end
 set @start3=@start3+1
 end
 end
   RETURN
END