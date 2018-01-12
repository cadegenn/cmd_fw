'
' IUT La Rochelle
'
' script pour cr�er des raccourcis windows
'
' [AR] 2013.03.14
' . besoin de sp�cifier la propri�t� 'WorkingDirectory' du raccourci � cr�er => ajout d'un param�tre en ligne de commande -workingdir
'
' [charly] 2011.01.17
' . am�lioration du parse des arguments. D�sormais, on peut mixer des arguments avec des guillemets :
'   ex: -target net start 'mon service' sera traduit dans l'ic�ne par net start "mon service"
'
' [charly] 2010.11.25
' . possibilit� de transmettre des arguments � TARGET en les s�parant par des espaces tout simplement : -target net start 'mon service'
'
' [charly] 2008.02.14
' . cr�ation du script parce que j'en ai besoin pour l'histoire de changement de config vnc
'
' FIN

' si aucun argument, on affiche un bref usage
if (WScript.Arguments.Length <= 0 ) then
	WScript.echo "USAGE :"
	WScript.echo WScript.ScriptName & " -name drive:\path\to\shortcut.lnk -target drive:\path\to\target avec 'des parametres' [-ico drive:\path\to\icon.ico] [-workingdir drive:\path\to\workingdir]"
	WScript.Quit(0)
end if

' d�claration des variables
strNAMELNK	= ""
strTARGET	= ""
strARGS		= ""
strICON		= ""
strWORKINGDIR	= ""

' une peu de debug
'i=0
'while (i < WScript.Arguments.Count)
'	WScript.Echo "arg(" & i & ") = " & WScript.Arguments(i)
'	i=i+1
'wend

ParseCommandLine

' une peu de debug
'WScript.Echo "strNAMELNK= " & strNAMELNK
'Script.Echo "strTARGET	= " & strTARGET
'WScript.Echo "strARGS	= " & strARGS
'WScript.Echo "strICON	= " & strICON
'WScript.Echo "strWORKINGDIR = " & strWORKINGDIR

Set objShell 	= WScript.CreateObject("WScript.Shell")
Set objShortcut = objShell.CreateShortcut(strNAMELNK)
if (strTARGET <> "") 	then objShortcut.TargetPath		= strTARGET
if (strARGS <> "") 	then objShortcut.Arguments		= strARGS
if (strICON <> "") 	then objShortcut.IconLocation		= strICON
if (strWORKINGDIR <>"") then objShortcut.WorkingDirectory 	= strWORKINGDIR	
objShortcut.Save

function ParseCommandLine
	i=0
	while (i < WScript.Arguments.Count)
		if (WScript.Arguments(i) = "-name") then
			i=i+1
			strNAMELNK = WScript.Arguments(i)
		elseif (WScript.Arguments(i) = "-target") then
			i=i+1
			strTARGET = WScript.Arguments(i)
		elseif (WScript.Arguments(i) = "-ico") then
			i=i+1
			strICON = WScript.Arguments(i)
		elseif (WScript.Arguments(i) = "-workingdir") then
			i=i+1
			strWORKINGDIR = WScript.Arguments(i)
		else
			strARGS = strARGS & " " & Replace(WScript.Arguments(i), "'", chr(34))
		end if
		i=i+1
	wend
end function
