SELECT 
ID
, [NAME]
, NETWORKALIAS
, NETWORKDOMAIN
, [SID]
, IDENTITYPROVIDER
, [ENABLE]
FROM USERINFO
WHERE NETWORKALIAS LIKE @Email