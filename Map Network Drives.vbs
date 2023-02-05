'''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''
'' Purpose:	
''		Map network shared drives to members of a 
''		particular group.
'''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''
''On an error keep on going.  
on error resume Next

'''''''Local Variables'''''''''
Dim WSHNetwork
Dim FSO
''Current user
Dim strUserName 
''Current User's domain name
Dim strUserDomain 
''Dictionary of groups to which the user belongs
Dim ObjGroupDict 
'''''''''''''''''''''''''''''''

''Creates Network object
Set WSHNetwork = WScript.CreateObject("WScript.Network")
Set FSO = CreateObject("Scripting.FileSystemObject")
''Retrieves Network Drive Objects
Set CheckDrive = WSHNetwork.EnumNetworkDrives() 
''Initializes variable
strUserName = ""

''Wait until the user is really logged in...
While strUserName = ""
	WScript.Sleep 100 ' 1/10 th of a second
	strUserName = WSHNetwork.UserName
Wend

strUserDomain = WSHNetwork.UserDomain

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''This section is to delete the network drive mappings''''''''''''''
'RemoveNetowrkDrives()
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
WshNetwork.RemoveNetworkDrive "G:", True, True
WshNetwork.RemoveNetworkDrive "L:", True, True
WshNetwork.RemoveNetworkDrive "O:", True, True
WshNetwork.RemoveNetworkDrive "P:", True, True
WshNetwork.RemoveNetworkDrive "T:", True, True
WshNetwork.RemoveNetworkDrive "U:", True, True
WshNetwork.RemoveNetworkDrive "V:", True, True
WshNetwork.RemoveNetworkDrive "X:", True, True
WshNetwork.RemoveNetworkDrive "Z:", True, True
WshNetwork.RemoveNetworkDrive "J:", True, True

' Read the user's account "Member Of" tab info across the network
' once into a dictionary object. 
Set ObjGroupDict = CreateMemberOfObject(strUserDomain, strUserName)


'WScript.Echo("=============================")
'WScript.Echo("Network Drives Being Mapped")
'WScript.Echo("=============================")

If MemberOf(ObjGroupDict, "Security-Group-Name-Here") Then
'	WScript.Echo("\\high5.local\Games")
	WSHNetwork.MapNetworkDrive "G:", "\\Folder\Path\Location"
End If

If MemberOf(ObjGroupDict, "Security-Group-Name-Here") Then
'	WScript.Echo("\\HIGH5-EV\Exports$")
	WSHNetwork.MapNetworkDrive "R:", "\\Folder\Path\Location"
End If

'This will map the users personal folder based on username
'Option Explicit
'Dim objNetwork
'Dim strDriveLetter, strRemotePath, strUserName
strDriveLetter = "U:"
strRemotePath = "\\Folder\Path\Location\documents\"

' Purpose of the script to create a network object. (objNetwork)
' Then to apply the MapNetworkDrive method. Result U: drive
Set objNetwork = WScript.CreateObject("WScript.Network")
' Here is where we extract the UserName
strUserName = objNetwork.UserName
objNetwork.MapNetworkDrive strDriveLetter, strRemotePath & strUserName


'''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''
'' Function Name:	
''		RemoveNetowrkDrives
'' Description:	
''		Deletes the pre-existing network mapped drives
'' Parameters:
''		Nothing
'' Return:
''		Nothing
'' History:
''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''

Sub RemoveNetowrkDrives()

	For intDrive = 0 To CheckDrive.Count - 1 Step 2
	    wshNetwork.RemoveNetworkDrive CheckDrive.Item(intDrive), bforce
	Next

End Sub


'''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''
'' Function Name:	
''		MemberOf
'' Description:	
''		Checks whether the user is part of a group.
'' Parameters:
''		ObjDict - Dictionary Object
''		strKey - String
'' Return:
''		True - Member of Group
''		False - Not Member of Group
'' History:
''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function MemberOf(ObjDict, strKey)

	''Given a Dictionary object containing groups to which the user
	''is a member of and a group name, then returns True if the group
	''is in the Dictionary else return False. 
	MemberOf = CBool(ObjGroupDict.Exists(strKey))

End Function

'''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''
'' Function Name:	
''		CreateMemberOfObject
'' Description:	
''		Checks whether the user is part of a group.
'' Parameters:
''		strDomain - String
''		strUserName - String
'' Return:
''		Dictionary Object
'' History:
''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function CreateMemberOfObject(strDomain, strUserName)
	' Given a domain name and username, returns a Dictionary
	' object of groups to which the user is a member of.
	
	Dim objUser, objGroup
	
	Set CreateMemberOfObject = CreateObject("Scripting.Dictionary")
	
	CreateMemberOfObject.CompareMode = vbTextCompare
	
	Set objUser = GetObject("WinNT://" & strDomain & "/" & strUserName & ",user")
	
	For Each objGroup In objUser.Groups
	
		CreateMemberOfObject.Add objGroup.Name, "-"
	
	Next
	
	Set objUser = Nothing

End Function