'
' Δόξα Θεῷ πάντων ἒνεκα.
'

'Requires string functions to be available.


'Table of Russian names for grammatical terms.
russianTable = Array("pres", "настоящее", "fut", "будущее", "aor", "аорист", "imperf", "несовершенное", _
			"perf", "совершенное", "plup", "преждесовершенное", "futperf", "будущее совершенное", _
			"ind", "изъявительное", "subj", "сослагательное", "opt", "желательное", "imperat", "повелительное", _
			"act", "действительный", "mp", "средне-страдательный", "mid", "средний", "pass", "страдательный", _
			"inf", "инфинитив", "1st", "1-е л.", "2nd", "2-е л.", "3rd", "3-е л.", _
			"sg", "ед.ч.", "pl", "мн.ч.", "dl", "дв.ч.", _
			"masc", "мужской род", "fem", "женский род", "neut", "средний род", _
			"nom", "именительный", "gen", "родительный", "dat", "дательный", _
			"acc", "винительный", "voc", "звательный",_
			"comp", "сравнительная степень", "superl", "превосходная степень", _
			"noun", "существительное", "verb", "глагол", "part", "причастие", _
			"adj", "прилагательное", "adv", "наречие", "num", "числительное", _
			"prep", "предлог")


positionsMap = Array("nouns: noun", _
"adjectives: adj", _
"verbs: verb", _
"participles: part", _
"pronouns: pron", _
"indeclinables:exclam adv partic article conj irreg interj prep numeral")


Set posTable=CreateObject("scripting.dictionary")
For Each map In positionsMap
	table= Trim(RegExSubMatch(map, "(^.+):"))
	'echo table
	For Each pos In Split(Trim(RegExSubMatch(map, ":(.+$)")))
		posTable(Trim(pos)) = table
	next  
Next

			
Set russian = CreateObject("scripting.dictionary")

'prepare translation table.
For Each elem In russianTable
	If Len(key)=0 then
		key = elem
	Else
		russian.Add key, capitalize(elem)
		key=""
	End if
Next



prefixes =Array("δι","δυσ")

'===========================================
unwantedChars = "[.,·\;\[\]·]|<.+>|（.+）|^\s+|\s+$"
Function CleanWord(word)
	
'	echo "Cleaning word " & word
	
	clean=regexmatch(word, "[A-Za-z\u0390-\u1fff]+")
	'word=regexreplace(word, unwantedChars, "")
    
 '   alert "Clean word" &  word
    CleanWord=clean
End function


'===========================================
vowels = "ή η η ά α α ε ε έ ο ι ι υ υ ω" 
vowelsWB = "ἤ ἠ ἡ ἄ ἀ ἁ ἐ ἑ ἔ ὀ ἰ ἱ ὑ ὐ ὠ"

Function Breathing(byval word)
	For Each vowel In Split(vowels)
		If strbegin(word, vowel) Then
			If (InStr(vowelsWB, Mid(word,2,1))=0) Then
				letter1=Mid(vowelsWB, InStr(vowels, vowel), 1)
				restOfWord=Mid(word, 2)

				word=letter1 & restOfWord
				Exit For
			End if
		End If
	Next
	breathing=word
End Function

Function Normalize(byval word)
	word=CleanWord(word)
	word=Left(word,1) & LCase(Mid(word,2))
		
	word=breathing(word)
	
	For i=3 To Len(word)
		char=Mid(word, i, 1)
		instrchar=InStr(vowelsWB, char)
		If instrchar Then
			char=Mid(vowels, instrchar,1)
			word = Left(word, i-1) & char & Mid(word, i+1)
		End if		
	Next
	
	Normalize=(CorrectAccents(word))
End Function



'Function GreekCompare(l1, l2)
'	If breathing(l1)=breathing(l2) Then
'		GreekCompare=0
'	Else
'		GreekCompare=1
'	End if
'End Function
'==============================================================


Function GreekToLatin(ByVal word)
	dim i
	
	greek = "ύµαἀᾷάἁἂᾶὰβγδΔΔεέἐἑὲἒζηήῄἠἡἣῆὴῃθιἰίἱὶῖκλμνξοόὀὁὸπῥρσςτυύὒὓῦὐὺφχψωώὠὣῶῷὼῳὡὑῇᾳὧὦἌᾀὑῤἵἔἵἔἧὅῄὑἎᾀἶϊὑἄὑἶἶὕὖἅᾳἴἄὑἔὑὑᾳᾳἅἜῇᾷἎᾀἔἥὦἜἔἵῃὑὥἌᾀἢἃἕὔὄὃῒᾗἓἦὤἷᾠὗῴΐὢἬᾄᾔᾖᾆἤἳᾧἪϛὋἝᾅὌᾐᾴᾑὂϋ"
	latin = "umaaaaaaaabgdddeeeeeezhhhhhhhhhqiiiiiiklmncoooooprrsstuuuuuuufxywwwwwwwwwuhawwAaurieiehohuAaiiuauiiuuaaiaueuuaaaEhaAaehwEeihuwAahaeuooihehwiwuwiwHahhahiwHsOEaOhahou"

	word = LCase(word)

	For i = 1 To Len(word)
		char = Mid(word, i, 1)
		
		if char = "∆" then result = result + "D"
			
		If InStr(greek, char) Then
			char = Mid(latin, InStr(greek, char), 1)
			result = result + char
		End if
		
	Next
	GreekToLatin = result

End Function


Function LatinToGreek(byval word)
	word = LCase(word)
	
	If strbegin(word, "*") Or InStr(word, "—") Then
		LatinToGreek=""
		Exit Function
	End If
	word=CleanWord(word)
	
	latin="abcdefghijklmnopqrstuvwxyz"
	greek="αβξδεφγηι κλμνοπθρστυϝωχψζ"
	Dim aux,c
	
	i=1
	For i=1 To Len(word)
		char = Mid(word, i, 1)
		
		If InStr(latin, char) Then
			If Len(aux) Then
				For j=1 To Len(aux)
					Select Case Mid(aux,j,1)
						Case ")"
							c=c & chrw(&H313)	'psili
						Case "("
							c=c & chrw(&H314)	'dasia
						Case "/"
							c=c & chrw(&H0301)	'oxia, tonos
						Case "\"
							c=c & chrw(&H0300)	'varia		
						Case "="
							c=c & chrw(&H342)	'perispomeni
						Case "|"
							c=c & chrw(&H345)	'upogegrammeni (iota subscr.)
						Case "+"
							c=c & chrw(&H308)
						Case "_"
						Case Else
							c=c & Mid(aux,j,1)
					End Select
						
				next
			End If

			char = Mid(greek, Asc(char)-Asc("a")+1, 1)
			result = result &  c & char
			aux=""
			c=""

		Else
			aux=aux & char
		End If
		
	Next
	If Len(aux) Then
		For j=1 To Len(aux)
			Select Case Mid(aux,j,1)
				Case ")"
					c=c & chrw(&H313)	'psili
				Case "("
					c=c & chrw(&H314)	'dasia
				Case "/"
					c=c & chrw(&H0301)	'oxia, tonos
				Case "\"
					c=c & chrw(&H0300)	'varia		
				Case "="
					c=c & chrw(&H342)	'perispomeni
				Case "|"
					c=c & chrw(&H345)	'upogegrammeni (iota subscr.)
				Case "+"
					c=c & chrw(&H308)
				Case "'"
					c=c & "᾽"
				Case "_"
				Case Else
					c=c & Mid(aux,j,1)
			End Select
		next
		result = result + c
	End If
	
	If Right(result,1)="σ" Then result = Left(result, Len(result)-1) & "ς"
	result=Replace(result, "σ ", "ς ")
	result=Replace(result, "σ,", "ς,")
	result=Replace(result, "σ.", "ς.")
	result=Replace(result, "σ" & vblf, "ς" & vblf)
	
	latintogreek = (result)
End Function


'снимает второе ударение и первое делает острым.
'removes second accent and makes the first one acute	
Function CorrectAccents(word)
	
	reply=word
	acute="ά έ ί ό ύ ή ώ"
	grave="ὰ ὲ ὶ ὸ ὺ ὴ ὼ"
	noaccent = "α ε ι ο υ η ω"
	
	dim i
	For i=1 To Len(acute)
		reply=Replace(reply, Mid(grave,i,1), Mid(acute, i,1))
	Next
		
	For i = 1 To Len(reply)
		char =Mid(reply,i,1)
	'	echo char
		If InStr(acute, char) Then
		'	echo acute
			If firstAccentFound Then
				'second accent. remove it with
			
				reply=Left(reply, i-1) & Replace(reply, char, Mid(noaccent, InStr(acute, char),1), i, 1)
			Else
			
				firstAccentFound=true
			End If
		End If
	Next 
	
	CorrectAccents=reply
	
End Function


'Function ReplaceExtChars(text)

'	lowChars = "[ύάέίόήώ]"	' Greek regular, with low char codes.
'	extChars = "[ύάέίόήώ]"	' Greek extended, high char codes
'	regex.pattern=extChars 
'	For Each match In regex.Execute(text)
'		greekChar= Mid(lowChars, InStr(extChars, match.value), 1)
'		text = Replace(text, match.value, greekChar)
'	Next
	
'	ReplaceExtChars=text
'End Function

Function CheckDiacritics(text)
	regEx.Pattern="[\u0300-\u036F]"
	CheckDiacritics = regex.Test(text)
End function

'================================================================


'	Set fso = CreateObject("scripting.filesystemobject")
'	Set wShell = CreateObject("WScript.Shell")
'	Set shApp = CreateObject("Shell.Application")
'	
'	Set xmlHttp = CreateObject("MSXML2.ServerXMLHTTP.6.0")
	'Set oStream = CreateObject("ADODB.Stream")
	'Set ie = CreateObject("InternetExplorer.Application")
'	
'	Set xml = CreateObject("MSXML2.DomDocument.6.0")
'	Set regEx = CreateObject("VBScript.RegExp") 

