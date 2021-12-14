-- Extract users from database
DECLARE @DatabaseUserName [sysname]

SET NOCOUNT ON
DECLARE
@errStatement [varchar](8000),
@msgStatement [varchar](8000),
@DatabaseUserID [smallint],
@ServerUserName [sysname],
@RoleName [varchar](8000),
@ObjectID [int],
@ObjectName [varchar](261),
@name varchar(100),
@loginName varchar(100)

DECLARE db_cursor CURSOR FOR

select a.[name] as userName, b.[name] as loginName from sysusers a
INNER JOIN master..syslogins b ON b.sid = a.sid
--INNER JOIN master.sys.server_principals b ON b.sid = a.sid
--where b.type = 'U' 

OPEN db_cursor  
FETCH NEXT FROM db_cursor INTO @name, @loginName

WHILE @@FETCH_STATUS = 0  
BEGIN   

SET @DatabaseUserName = @name

SELECT
@DatabaseUserID = [sysusers].[uid],
@ServerUserName = [master].[dbo].[syslogins].[loginname]
FROM [dbo].[sysusers]
INNER JOIN [master].[dbo].[syslogins]
ON [sysusers].[sid] = [master].[dbo].[syslogins].[sid]
WHERE [sysusers].[name] = @DatabaseUserName
IF @DatabaseUserID IS NULL
BEGIN
SET @errStatement = 'User ' + @DatabaseUserName + ' does not exist in ' + DB_NAME() + CHAR(13) +
'Please provide the name of a current user in ' + DB_NAME() + ' you wish to script.'
RAISERROR(@errStatement, 16, 1)
END
ELSE
BEGIN
SET @msgStatement =
'USE [' + DB_NAME() + ']' + CHAR(13) +
'CREATE USER [' + @DatabaseUserName  + '] FOR LOGIN [' + @ServerUserName + '] WITH DEFAULT_SCHEMA = [dbo];'+ CHAR(13) +
'--Add User To Roles'
PRINT @msgStatement
DECLARE _sysusers
CURSOR
LOCAL
FORWARD_ONLY
READ_ONLY
FOR
SELECT
[name]
FROM [dbo].[sysusers]
WHERE
[uid] IN
(
SELECT
[groupuid]
FROM [dbo].[sysmembers]
WHERE [memberuid] = @DatabaseUserID
)
OPEN _sysusers
FETCH
NEXT
FROM _sysusers
INTO @RoleName
WHILE @@FETCH_STATUS = 0
BEGIN
SET @msgStatement = 'EXEC [sp_addrolemember]' + CHAR(13) +
CHAR(9) + '@rolename = ''' + @RoleName + ''',' + CHAR(13) +
CHAR(9) + '@membername = ''' + @DatabaseUserName + ''''
PRINT @msgStatement
FETCH
NEXT
FROM _sysusers
INTO @RoleName
END
SET @msgStatement = 'GO' + CHAR(13) +
'--Set Object Specific Permissions'
PRINT @msgStatement
			DECLARE _sysobjects
			CURSOR
			LOCAL
			FORWARD_ONLY
			READ_ONLY
			FOR
			SELECT
			DISTINCT([sysobjects].[id]),
			'[' + USER_NAME([sysobjects].[uid]) + '].[' + [sysobjects].[name] + ']'
			FROM [dbo].[sysprotects]
			INNER JOIN [dbo].[sysobjects]
			ON [sysprotects].[id] = [sysobjects].[id]
			WHERE [sysprotects].[uid] = @DatabaseUserID
			OPEN _sysobjects
			FETCH
			NEXT
			FROM _sysobjects
			INTO
			@ObjectID,
			@ObjectName
			WHILE @@FETCH_STATUS = 0
			BEGIN
			SET @msgStatement = ''
			IF EXISTS(SELECT * FROM [dbo].[sysprotects] WHERE [id] = @ObjectID AND [uid] = @DatabaseUserID AND [action] = 193 AND [protecttype] = 205)
			SET @msgStatement = @msgStatement + 'SELECT,'
			IF EXISTS(SELECT * FROM [dbo].[sysprotects] WHERE [id] = @ObjectID AND [uid] = @DatabaseUserID AND [action] = 195 AND [protecttype] = 205)
			SET @msgStatement = @msgStatement + 'INSERT,'
			IF EXISTS(SELECT * FROM [dbo].[sysprotects] WHERE [id] = @ObjectID AND [uid] = @DatabaseUserID AND [action] = 197 AND [protecttype] = 205)
			SET @msgStatement = @msgStatement + 'UPDATE,'
			IF EXISTS(SELECT * FROM [dbo].[sysprotects] WHERE [id] = @ObjectID AND [uid] = @DatabaseUserID AND [action] = 196 AND [protecttype] = 205)
			SET @msgStatement = @msgStatement + 'DELETE,'
			IF EXISTS(SELECT * FROM [dbo].[sysprotects] WHERE [id] = @ObjectID AND [uid] = @DatabaseUserID AND [action] = 224 AND [protecttype] = 205)
			SET @msgStatement = @msgStatement + 'EXECUTE,'
			IF EXISTS(SELECT * FROM [dbo].[sysprotects] WHERE [id] = @ObjectID AND [uid] = @DatabaseUserID AND [action] = 26 AND [protecttype] = 205)
			SET @msgStatement = @msgStatement + 'REFERENCES,'
			IF LEN(@msgStatement) > 0
			BEGIN
			IF RIGHT(@msgStatement, 1) = ','
			SET @msgStatement = LEFT(@msgStatement, LEN(@msgStatement) - 1)
			SET @msgStatement = 'GRANT' + CHAR(13) +
			CHAR(9) + @msgStatement + CHAR(13) +
			CHAR(9) + 'ON ' + @ObjectName + CHAR(13) +
			CHAR(9) + 'TO [' + @DatabaseUserName + ']'
			PRINT @msgStatement
			END
			SET @msgStatement = ''
			IF EXISTS(SELECT * FROM [dbo].[sysprotects] WHERE [id] = @ObjectID AND [uid] = @DatabaseUserID AND [action] = 193 AND [protecttype] = 206)
			SET @msgStatement = @msgStatement + 'SELECT,'
			IF EXISTS(SELECT * FROM [dbo].[sysprotects] WHERE [id] = @ObjectID AND [uid] = @DatabaseUserID AND [action] = 195 AND [protecttype] = 206)
			SET @msgStatement = @msgStatement + 'INSERT,'
			IF EXISTS(SELECT * FROM [dbo].[sysprotects] WHERE [id] = @ObjectID AND [uid] = @DatabaseUserID AND [action] = 197 AND [protecttype] = 206)
			SET @msgStatement = @msgStatement + 'UPDATE,'
			IF EXISTS(SELECT * FROM [dbo].[sysprotects] WHERE [id] = @ObjectID AND [uid] = @DatabaseUserID AND [action] = 196 AND [protecttype] = 206)
			SET @msgStatement = @msgStatement + 'DELETE,'
			IF EXISTS(SELECT * FROM [dbo].[sysprotects] WHERE [id] = @ObjectID AND [uid] = @DatabaseUserID AND [action] = 224 AND [protecttype] = 206)
			SET @msgStatement = @msgStatement + 'EXECUTE,'
			IF EXISTS(SELECT * FROM [dbo].[sysprotects] WHERE [id] = @ObjectID AND [uid] = @DatabaseUserID AND [action] = 26 AND [protecttype] = 206)
			SET @msgStatement = @msgStatement + 'REFERENCES,'
			IF LEN(@msgStatement) > 0
			BEGIN
			IF RIGHT(@msgStatement, 1) = ','
			SET @msgStatement = LEFT(@msgStatement, LEN(@msgStatement) - 1)
			SET @msgStatement = 'DENY' + CHAR(13) +
			CHAR(9) + @msgStatement + CHAR(13) +
			CHAR(9) + 'ON ' + @ObjectName + CHAR(13) +
			CHAR(9) + 'TO [' + @DatabaseUserName + '];'
			PRINT @msgStatement
			END
			FETCH
			NEXT
			FROM _sysobjects
			INTO
			@ObjectID,
			@ObjectName
			END
			CLOSE _sysobjects
			DEALLOCATE _sysobjects
			--PRINT 'GO'
			END

CLOSE _sysusers  
DEALLOCATE _sysusers

 FETCH NEXT FROM db_cursor INTO @name, @loginName
END  

CLOSE db_cursor  
DEALLOCATE db_cursor
