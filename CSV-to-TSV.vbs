Option Explicit

Dim Args
Dim Cmd
Dim tmp
Dim FS,file,tmpfile,buf,arrLines
Dim objSJIS,objUTF8,objNew,objNew2
Dim array,i,colname,rowcount
Dim delFO
'書き込みモード、読み込みモード
Const ForReading = 1, ForWriting = 2
Dim nowTime
nowTime = Replace(Replace(Replace(Now(), "/", ""), ":", ""), " ", "_")
Set Args = WScript.Arguments
If Args.Count < 1 Then
  WScript.Echo "当スクリプトにファイルをドラッグ&ドロップして処理を実行してください。"
  WScript.Quit
End If
With CreateObject("Scripting.FileSystemObject")
      'Args(0) :: file full pass
      Set FS = CreateObject("Scripting.FileSystemObject").GetFolder(CreateObject("Scripting.FileSystemObject").GetParentFolderName(WScript.ScriptFullName))
      'FS :: file directory
  Select Case LCase(.GetExtensionName(Args(0)))
    '対応形式は適宜追加
    Case "txt", "csv", "vbs", "js", "ini", "php", "cgi", "htm", "html", "xml", "css"
'clipboard copy
'      Cmd = "cmd /c ""clip < """"""" & Args(0) & """"""""""
'      CreateObject("WScript.Shell").Run Cmd, 0
'window show
'      WScript.Echo .OpenTextFile(Args(0)).ReadAll
        '.CopyFile Args(0) , FS & "\" & Replace(Replace(Replace(Now(), "/", ""), ":", ""), " ", "_") & ".csv", True
        'Set file = .OpenTextFile(Args(0), ForReading)
        'tmp = FS & "\" & Replace(Replace(Replace(Now(), "/", ""), ":", ""), " ", "_") & ".csv"
        'Set tmpfile = .OpenTextFile(tmp, ForWriting, True)
        'do while not file.AtEndOfStream
        '    buf = file.ReadLine
        '    tmpfile.Write buf & vbLf
        'loop
        'file.Close
        'tmpfile.Close
        Set objSJIS = CreateObject("ADODB.Stream")
        Set objUTF8 = CreateObject("ADODB.Stream")
        objUTF8.Type = 2
        objUTF8.Charset = "UTF-8"
        objUTF8.Open
        objUTF8.LoadFromFile Args(0)
        objSJIS.Type = 2
        objSJIS.Charset = "Shift_JIS"
        objSJIS.Open
        buf = objUTF8.ReadText

        '備考欄の改行を1行に改変
        'ここ順番大事
        buf = Replace(buf, vbCrLf, "")
        buf = Replace(buf, vbLf, vbCrLf)
        objSJIS.WriteText buf, 1
        '一時保存
        objSJIS.SaveTofile FS & "\" & nowTime & "_tmp.csv", ForWriting
        objSJIS.Close
        objUTF8.Close
        set objSJIS = Nothing
        set objUTF8 = Nothing

        Set objNew = CreateObject("ADODB.Stream")
        objNew.Type = 2
        objNew.Charset = "Shift_JIS"
        objNew.Mode = 3 '読み取り/書き込みモード
        objNew.Type = 2 'テキストデータ
        objNew.Open
        objNew.LoadFromFile FS & "\" & nowTime & "_tmp.csv"
        Set objNew2 = CreateObject("ADODB.Stream")
        objNew2.Type = 2
        objNew2.Charset = "Shift_JIS"
        objNew2.Mode = 3 '読み取り/書き込みモード
        objNew2.Type = 2 'テキストデータ
        objNew2.Open

        rowcount = 0
        Do Until objNew.EOS
            arrLines = objNew.ReadText(-2)
            array = Split(arrLines,",")
            For i = 0 To UBound(array)
                array(i) = Replace(array(i), """", "")
                If rowcount = 1 Then
                  colname = array
                End If
                If i <> UBound(array) Then
                  'adWriteChar	0	文字を書き込む
                  'adWriteLine	1	文字を改行付きで書き込む
                  objNew2.WriteText array(i) & vbTab, 0
                Else
                  objNew2.WriteText array(i), 1
                End If
            Next
            rowcount = rowcount + 1
'                objNew.Position = objNew.Size
        Loop
        objNew2.SaveTofile FS & "\" & nowTime & ".csv", ForWriting
        'objNew.DeleteFile FS & "\" & nowTime & "_tmp.csv"
        objNew.Close
        set objNew = Nothing
        objNew2.Close
        set objNew2 = Nothing
        Set delFO = CreateObject("Scripting.FileSystemObject")
        delFO.DeleteFile FS & "\" & nowTime & "_tmp.csv"
        Set delFO = Nothing

'        Wscript.Echo "要素数は" &UBound(array) +1 & "個"
        'buf = Replace(buf, ",", vbTab)
        'buf = Replace(buf, """", "")
        'objSJIS.WriteText buf, 1
        'objUTF8.CopyTo objSJIS
    'Wordドキュメントの場合
    Case "doc", "docx", "docm", "rtf"
      CopyWordDocument Args(0)
    Case Else
      If Len(.GetExtensionName(Args(0))) < 1 Then
        If Lcase(TypeName(Args(0))) = "string" Then
          Cmd = "cmd /c ""echo " & Args(0) & "| clip"""
          CreateObject("WScript.Shell").Run Cmd, 0
        End If
      Else
        WScript.Echo "未対応のファイル形式です。"
        WScript.Quit
      End If
  End Select
End With
Set Args = Nothing
'WScript.Echo "内容をクリップボードにコピーしました。"

Private Sub CopyWordDocument(ByVal FilePath)
'Wordドキュメントのコピー
  With CreateObject("Word.Application")
    .Visible = False
    With .Documents.Open(FilePath, False, True)
      .Content.Copy
      .Close 0
    End With
    .Quit 0
  End With
End Sub
